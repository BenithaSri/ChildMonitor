//
//  HomeViewController.swift
//  ChildCareApp
//
//  Created by Benitha on 03/02/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SVProgressHUD

var appLaunchTime: TimeInterval = 0

class HomeViewController: UIViewController {

    @IBOutlet weak var childsCV: UICollectionView!
    var listeners: [ListenerRegistration] = []

    var allChildsList: [ChildModel] = []
    var selectedChild: ChildModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        childsCV.backgroundColor = .clear
        navigationItem.hidesBackButton = true
        navigationItem.title = "Home"
        self.listenForMessages()
        listenForRestrictedArea()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.getMyChilds()
    }
    
    func listenForMessages() {
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let myTimeStamp = appLaunchTime
        
        let db = Firestore.firestore()
        db.collection("Chats")
            .whereField("receiver_id", isEqualTo: id)
            .whereField("isRead", isEqualTo: false)
          .addSnapshotListener { (querySnapshot, error) in
              guard let snapshot = querySnapshot else { return }
              for diff in snapshot.documentChanges {
                  if diff.type == .added {
                      let messageData = diff.document.data()
                      if let timestamp = messageData["timestamp"] as? Double, timestamp > myTimeStamp {
                          self.showNotification(for: messageData)
                      }
                  }
              }
          }
    }
    
    func showNotification(for messageData: [String: Any]) {
        let content = UNMutableNotificationContent()
        content.title = messageData["sender_name"] as? String ?? "New Message"
        content.body = messageData["message"] as? String ?? "You have a new message"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error)")
            }
        }
    }
    
    
    func listenForRestrictedArea() {
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let myTimeStamp = appLaunchTime
        
        let db = Firestore.firestore()
        db.collection("Notifications")
            .whereField("parent_id", isEqualTo: id)
          .addSnapshotListener { (querySnapshot, error) in
              guard let snapshot = querySnapshot else { return }
              for diff in snapshot.documentChanges {
                  if diff.type == .added {
                      let messageData = diff.document.data()
                      if let timestamp = messageData["timestamp"] as? Double, timestamp > myTimeStamp {
                          self.showRestrictedNotification(for: messageData)
                      }
                  }
              }
          }
    }

    
    func showRestrictedNotification(for messageData: [String: Any]) {
        let content = UNMutableNotificationContent()
        
        let type = messageData["type"] as? Int ?? 0
        if type == 3 {
            
            let childName = messageData["child_name"] as? String ?? ""
            let address = messageData["address"] as? String ?? ""
            
            content.title = "Restricted Area"
            let txt = String(format: "%@ has entered your restricted area. %@", childName, address)
            content.body = txt
            content.sound = .default
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error showing notification: \(error)")
                }
            }
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "childDetail" {
            
            let vc = segue.destination as! ChildDetailViewController
            vc.childData = self.selectedChild
        }
        
    }
    

    func getMyChilds() -> Void {
        
        let database = Firestore.firestore()
        let id = Auth.auth().currentUser?.uid ?? ""
        
        let docRef = database.collection("Childs")
            .whereField("parent_id", isEqualTo: id)
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                
                print("Error getting documents: \(err)")
                
            } else {
                
                self.allChildsList.removeAll()
                
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let data = document.data()
                    
                    var child = ChildModel()
                    child.id = data["id"] as? String ?? ""
                    child.parent_id = data["parent_id"] as? String ?? ""
                    child.parent_name = data["parent_name"] as? String ?? ""
                    child.name = data["name"] as? String ?? ""
                    child.age = data["age"] as? String ?? ""
                    child.email = data["email"] as? String ?? ""
                    child.image = data["image"] as? String ?? ""
                    child.lat = data["lat"] as? Double ?? 0.0
                    child.lng = data["lng"] as? Double ?? 0.0
                    child.address = data["address"] as? String ?? ""
                    
                    self.allChildsList.append(child)
                }
                
                self.checkUnreadMessagesForAllChildren()
            }
        }
    }

    
    func checkUnreadMessagesForAllChildren() {
        let db = Firestore.firestore()
        let id = Auth.auth().currentUser?.uid ?? ""

        for i in 0..<allChildsList.count {
            let child = allChildsList[i]
            guard let childID = child.id else {
                print("Child ID is nil for index \(i)")
                continue
            }

            let listener = db.collection("Chats")
                .whereField("receiver_id", isEqualTo: id)
                .whereField("sender_id", isEqualTo: childID)
                .whereField("isRead", isEqualTo: false)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error fetching messages for child \(childID): \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            if i < self.allChildsList.count {
                                self.allChildsList[i].hasUnreadMessages = false
                            }
                        }
                        return
                    }

                    if let documents = snapshot?.documents, !documents.isEmpty {
                        DispatchQueue.main.async {
                            if i < self.allChildsList.count {
                                self.allChildsList[i].hasUnreadMessages = true
                                self.childsCV.reloadData()  // Reload collection view to reflect changes
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            if i < self.allChildsList.count {
                                self.allChildsList[i].hasUnreadMessages = false
                                self.childsCV.reloadData()
                            }
                        }
                    }
                }
            listeners.append(listener)
        }
    }
    
    // Function to remove all listeners when the screen is dismissed
    func removeAllListeners() {
        for listener in listeners {
            listener.remove()
        }
        listeners.removeAll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeAllListeners()
    }
}


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.allChildsList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width = 0.0
        let view = self.view.frame.size.width - 34
        
        width = Double(view / 2)
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : ChildCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChildCVC
        cell.backgroundColor = .clear
        
        if indexPath.item == self.allChildsList.count {
            
            cell.unreadView.isHidden = true
            cell.imgView.image = UIImage(systemName: "plus.circle")
            cell.txtLbl.text = "Add Child"
        }else {
            
            let childData = self.allChildsList[indexPath.item]
            
            cell.unreadView.isHidden = !(childData.hasUnreadMessages ?? false)
            cell.imgView.image = UIImage(systemName: "person.circle")
            cell.txtLbl.text = childData.name
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == self.allChildsList.count {
            
            self.performSegue(withIdentifier: "addChild", sender: nil)
        }else {
            
            selectedChild = allChildsList[indexPath.item]
            self.performSegue(withIdentifier: "childDetail", sender: nil)
        }
    }
}
