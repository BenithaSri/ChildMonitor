//
//  DevicesViewController.swift
//  ChildCareApp
//
//  Created by Benitha on 05/02/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SVProgressHUD

class DevicesViewController: UIViewController {
    
    @IBOutlet weak var dataTV: UITableView!
    @IBOutlet weak var noRecordLBL: UILabel!
    
    var devicesList: [DeviceModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getDevices()
    }
    
    func getDevices() {
        
        let database = Firestore.firestore()
        let id = Auth.auth().currentUser?.uid ?? ""
        
        let docRef = database.collection("Devices")
            .whereField("parent_id", isEqualTo: id)
        
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                
                SVProgressHUD.dismiss()
                print("Error getting documents: \(err)")
                
            } else {
                
                SVProgressHUD.dismiss()
                
                self.devicesList.removeAll()
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let data = document.data()
                    var model = DeviceModel()
                    
                    model.id = document.documentID
                    model.parent_id = data["parent_id"] as? String ?? ""
                    model.child_id = data["child_id"] as? String ?? ""
                    model.device = data["model"] as? String ?? ""
                    model.os_version = data["systemVersion"] as? String ?? ""
                    model.child_name = data["child_name"] as? String ?? ""
                    
                    self.devicesList.append(model)
                }
                
                if self.devicesList.count > 0 {
                    
                    self.dataTV.isHidden = false
                    self.noRecordLBL.isHidden = true
                }else {
                    
                    self.dataTV.isHidden = true
                    self.noRecordLBL.isHidden = false
                }
                
                self.dataTV.reloadData()
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

}


extension DevicesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return devicesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: DeviceTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "deviceCell") as? DeviceTableViewCell
        
        let device = devicesList[indexPath.row]
        
        cell.nameLBL.text = device.child_name ?? ""
        
        let str = String(format: "%@ (%@)", device.device ?? "", device.os_version ?? "")
        cell.deviceLBL.text = str
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
}
