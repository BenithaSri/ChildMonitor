//
//  LoginViewController.swift
//  ChildCareApp
//
//  Created by Benitha on 29/01/2025.
//

import UIKit
import FirebaseAuth
import SVProgressHUD
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var passBtn: UIButton!
    
    var parentID = ""
    var userType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "Login"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            
            try Auth.auth().signOut()
        } catch {}
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func login(_ sender: Any) {
        
        if emailTF.text == "" {
            
            self.showAlert(str: "Please enter email")
            return
        }
        
        if passwordTF.text == "" {
            
            self.showAlert(str: "Please enter password")
            return
        }
        
        SVProgressHUD.show()
        login(email: emailTF.text!, password: passwordTF.text!)
    }
    
    func login(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            
            if error != nil {
                
                SVProgressHUD.dismiss()
                self.showAlert(str: error?.localizedDescription ?? "")
            }else{
                
                self.checkUserType()
            }
        }
    }
    
    func checkUserType()-> Void {
        
        let database = Firestore.firestore()
        let id = Auth.auth().currentUser?.uid ?? ""
        
        let docRef = database.collection("Users")
            .whereField("user_id", isEqualTo: id)
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                
                SVProgressHUD.dismiss()
                print("Error getting documents: \(err)")
                
            } else {
                
                SVProgressHUD.dismiss()
                
                let docmetns = querySnapshot?.documents ?? []
                if docmetns.count > 0 {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        let data = document.data()
                        let type = data["type"] as? Int ?? 1
                        self.moveToView(type: type)
                    }
                }else {
                    
                    do {
                        
                        try Auth.auth().signOut()
                    } catch {}
                    
                    self.showAlert(str: "Invalid email or password!")
                }
            }
        }
    }
    
    func moveToView(type: Int) -> Void {
        
        self.navigationController?.navigationBar.isHidden = true
        
        UserDefaults.standard.set(type, forKey: "user_type")
        UserDefaults.standard.synchronize()
        
        if type == 1 {
            
            let vc = self.storyboard?.instantiateViewController(identifier: "myTabBar") as! UITabBarController
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            
            self.getChildData()
        }
    }
    
    func getChildData() -> Void {
        
        let database = Firestore.firestore()
        let id = Auth.auth().currentUser?.uid ?? ""
        
        let docRef = database.collection("Childs")
            .whereField("id", isEqualTo: id)
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                
                print("Error getting documents: \(err)")
                
            } else {
                
                if querySnapshot?.documents.count ?? 0 > 0 {
                    
                    let document = querySnapshot!.documents[0]
                    
                    let data = document.data()
                    self.parentID = data["parent_id"] as? String ?? ""
                    
                    self.sendNotification()
                }
            }
        }
    }
    
    func sendNotification() -> Void {
        
        let path = String(format: "%@", "Notifications")
        let db = Firestore.firestore()
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let name = Auth.auth().currentUser?.displayName ?? ""
        
        let myTimeStamp = Date().timeIntervalSince1970
        
        let notifData: [String: Any] = [
            "child_name": name,
            "parent_id": self.parentID,
            "child_id": id,
            "type": 1,
            "timestamp": myTimeStamp
        ]
        
        db.collection(path).document().setData(notifData) { err in
            if let _ = err {
                
            }else {
                
                let vc = self.storyboard?.instantiateViewController(identifier: "childTabBar") as! UITabBarController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func showAlert(str: String) -> Void {
        
        let alert = UIAlertController(title: "", message: str, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func password(_ sender: Any) {
        
        passwordTF.isSecureTextEntry.toggle()
        if passwordTF.isSecureTextEntry {
            
            passBtn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }else {
            
            passBtn.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
}
