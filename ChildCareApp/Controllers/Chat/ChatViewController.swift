
import UIKit
import FirebaseAuth
import FirebaseFirestore
import AVKit
import SVProgressHUD

class ChatViewController: UIViewController {
    
    
    @IBOutlet weak var chatTV: UITableView!
    @IBOutlet var msgView: UIView!
    @IBOutlet weak var msgTF: UITextField!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    var user_ID = ""
    var user_name = ""
    var allChat: [ChatModel] = []
    var chatDocRefListner: DocumentReference?
    
    private var processedChatIDs = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = "Chat"
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
        // Do any additional setup after loading the view.
        
        self.chatTV.delegate = self
        self.chatTV.dataSource = self
        
        //sendBtn.isEnabled = false
        
        self.markMessagesAsRead()
        self.getAllChat()
    }
    
    func markMessagesAsRead() {
        let db = Firestore.firestore()
        let messagesRef = db.collection("Chats")
        let id = Auth.auth().currentUser?.uid ?? ""
        
        messagesRef.whereField("sender_id", in: [id, user_ID])
            .whereField("receiver_id", in: [id, user_ID])
            .whereField("isRead", isEqualTo: false)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                for doc in documents {
                    messagesRef.document(doc.documentID).updateData(["isRead": true]) { error in
                        if let error = error {
                            print("Error updating message: \(error.localizedDescription)")
                        } else {
                            print("Message marked as read")
                        }
                    }
                }
            }
    }
    
    func scrollToLastRow() {
        let lastSection = chatTV.numberOfSections - 1
        if lastSection >= 0 {
            let lastRow = chatTV.numberOfRows(inSection: lastSection) - 1
            if lastRow >= 0 {
                let indexPath = IndexPath(row: lastRow, section: lastSection)
                chatTV.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    

    func getAllChat() -> Void {
        
        let id = Auth.auth().currentUser?.uid ?? ""
        
        let db = Firestore.firestore()
        let docRef = db.collection("Chats")
            .whereField("sender_id", in: [id, user_ID])
            .whereField("receiver_id", in: [id, user_ID])
        
        docRef.addSnapshotListener { (querySnapshot, err) in
            guard let snapshot = querySnapshot else { return }
            docRef.addSnapshotListener { [weak self] (querySnapshot, err) in
                guard let self = self, let snapshot = querySnapshot else { return }
                
                // 1️⃣ On first load, mark all existing docs as “seen”
                if self.processedChatIDs.isEmpty {
                    snapshot.documents.forEach { self.processedChatIDs.insert($0.documentID) }
                }
                
                // 2️⃣ For each *new* chat, send one notification and mark it “seen”
                for change in snapshot.documentChanges where change.type == .added {
                    let docID = change.document.documentID
                    guard !self.processedChatIDs.contains(docID) else { continue }
                    self.processedChatIDs.insert(docID)
                    
                    let data = change.document.data()
                    if let receiverId = data["receiver_id"] as? String,
                       receiverId == Auth.auth().currentUser?.uid {
                        let notifData: [String:Any] = [
                            "parent_id":   receiverId,
                            "child_id":    data["sender_id"]   as? String ?? "",
                            "child_name":  data["sender_name"] as? String ?? "",
                            "type":        4,
                            "address":     "", "lat": 0.0, "lng": 0.0,
                            "timestamp":   data["timestamp"] as? Double
                            ?? Date().timeIntervalSince1970,
                            "message":     data["message"]   as? String ?? ""
                        ]
                        Firestore.firestore()
                            .collection("Notifications")
                            .addDocument(data: notifData)
                    }
                }
            }
            if let err = err {
                print("Error getting documents: \(err)")
                SVProgressHUD.dismiss()
                
            } else {
                
                self.allChat.removeAll()
                SVProgressHUD.dismiss()
                
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let data = document.data()
                    
                    let t = data["timestamp"] as? Double ?? 0.0
                    let date = Date(timeIntervalSince1970: t)
                    
                    var chat = Chat()
                    chat.id = document.documentID
                    chat.message = data["message"] as? String ?? ""
                    chat.sender_id = data["sender_id"] as? String ?? ""
                    chat.reveiver_id = data["reveiver_id"] as? String ?? ""
                    
                    
                    let f = DateFormatter()
                    f.dateFormat = "HH:mm:ss"
                    
                    chat.date = f.string(from: date)
                    
                    f.dateFormat = "dd/MM/yyyy"
                    let date_str = f.string(from: date)
                    
                    if let existingSectionIndex = self.allChat.firstIndex(where: { $0.date == date_str }) {
                        self.allChat[existingSectionIndex].chats?.append(chat)
                    } else {
                        var newSection = ChatModel()
                        newSection.date = date_str
                        newSection.chats = [chat]
                        self.allChat.append(newSection)
                    }
                    
                    self.allChat.sort { $0.date! > $1.date! }
                    self.chatTV.reloadData()
                    
                    self.scrollToLastRow()
                    
                    //self.markMessagesAsRead()
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func showAlert(str: String) -> Void {
        
        let alert = UIAlertController(title: "", message: str, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func sendBtn(_ sender: Any) {
        
        if msgTF.text == "" {
            
            self.showAlert(str: "Please enter message")
            return
        }
        
        let myTimeStamp = Date().timeIntervalSince1970
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let name = Auth.auth().currentUser?.displayName ?? ""
        
        let params = ["message": msgTF.text!,
                      "sender_id": id,
                      "sender_name": name,
                      "receiver_id": user_ID,
                      "receiver_name": user_name,
                      "isRead": false,
                      "timestamp": myTimeStamp] as [String : Any]
        
        
        let path = String(format: "Chats")
        let db = Firestore.firestore()
        
        SVProgressHUD.show()
        db.collection(path).document().setData(params) { err in
            if let _ = err {
                
                SVProgressHUD.dismiss()
                self.showAlert(str: "Message sending failed")
            } else {
                
                SVProgressHUD.dismiss()
                self.msgTF.text = ""
            }
        }
    }
}


extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return allChat.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell: HeaderCell! = tableView.dequeueReusableCell(withIdentifier: "headerCell") as? HeaderCell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let date_str = allChat[section].date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let today = Date()
        let today_str = dateFormatter.string(from: today)
        
        let yesterday = today.addingTimeInterval(-1 * 24 * 60 * 60)
        let yesterday_str = dateFormatter.string(from: yesterday)
        
        if date_str == today_str {
            
            cell.dateLBL.text = "Today"
        }else if date_str == yesterday_str {
            
            cell.dateLBL.text = "Yesterday"
        }else {
            
            cell.dateLBL.text = date_str
        }
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let chats = allChat[section].chats ?? []
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var chats = allChat[indexPath.section].chats ?? []
        chats.sort { $0.date! < $1.date! }
        let chat = chats[indexPath.row]
        
        let id = Auth.auth().currentUser?.uid ?? ""
        if chat.sender_id == id {
            
            let cell: SenderCell! = tableView.dequeueReusableCell(withIdentifier: "senderCell") as? SenderCell
            
            cell.chat = chat
            return cell
        }else{
            
            let cell: ReceiverCell! = tableView.dequeueReusableCell(withIdentifier: "receiverCell") as? ReceiverCell
            
            cell.chat = chat
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
}
