//
//  NotificationsViewController.swift
//  ChildCareApp
//
//  Created by Benitha on 05/02/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD



class NotificationsViewController: UIViewController {

    
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var dataTV: UITableView!
    
    var allNotifications: [NotificationModel] = []
    
    struct NotificationModel: Codable {
        var id: String?
        var parent_id: String?
        var child_id: String?
        var child_name: String?
        var type: Int?
        var lat: Double?
        var lng: Double?
        var address: String?
        var time: String?
        var message: String?
        var timestampValue: Double?
        
        init() {}
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getNotifications()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getNotifications() -> Void {
        
        let database = Firestore.firestore()
        let id = Auth.auth().currentUser?.uid ?? ""
        
        let docRef = database.collection("Notifications")
            .whereField("parent_id", isEqualTo: id)
                .order(by: "timestamp", descending: true)
        
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                
                SVProgressHUD.dismiss()
                print("Error getting documents: \(err)")
                
            } else {
                
                SVProgressHUD.dismiss()
                
                self.allNotifications.removeAll()
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let data = document.data()
                    var model = NotificationModel()
                    
                    model.id = document.documentID
                    model.parent_id = data["parent_id"] as? String ?? ""
                    model.child_name = data["child_name"] as? String ?? ""
                    model.child_id = data["child_id"] as? String ?? ""
                    model.type = data["type"] as? Int ?? 0
                    model.address = data["address"] as? String ?? ""
                    model.lat = data["lat"] as? Double ?? 0.0
                    model.lng = data["lng"] as? Double ?? 0.0
                    
                    let t = data["timestamp"] as? Double ?? 0.0
                    model.timestampValue = t

                    let date = Date(timeIntervalSince1970: t)
                    let f = DateFormatter()
                    f.dateFormat = "MMM dd, yyyy hh:mm a"
                    model.time = f.string(from: date)
                    model.message = data["message"] as? String

                    self.allNotifications.append(model)

                }
                
                self.allNotifications.sort {
                   ($0.timestampValue ?? 0) > ($1.timestampValue ?? 0)
                 }
                
                if self.allNotifications.count > 0 {
                    
                    self.dataTV.isHidden = false
                    self.noRecordLbl.isHidden = true
                }else {
                    
                    self.dataTV.isHidden = true
                    self.noRecordLbl.isHidden = false
                }
                
                self.dataTV.reloadData()
            }
        }
    }
}


extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: NotificationTVC! = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as? NotificationTVC
        
        let notification = allNotifications[indexPath.row]
        let title: String
        switch notification.type {
        case 1:
          title = "\(notification.child_name ?? "") Login"
        case 2:
          title = "\(notification.child_name ?? "") Logout"
        case 3:
          title = "\(notification.child_name ?? "") is in 100m of restricted location \(notification.address ?? "")"
        case 4:
          // ← NEW: chat notification
          title = "\(notification.child_name ?? ""): \(notification.message ?? "")"
        default:
          title = ""
        }
        cell.titleLbl.text = title
        
        cell.dateLbl.text = notification.time ?? ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
}
