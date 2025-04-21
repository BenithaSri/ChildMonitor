//
//  AddChildViewController.swift
//  ChildCareApp
//
//  Created by Benitha on 04/02/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD

class AddChildViewController: UIViewController {
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    let firebaseAPIKey = "AIzaSyBaXvU_9kU57pbB0w44Qo2GKzrd4YduWvM" // Get from Firebase Console
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = "Add Child"
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func add(_ sender: Any) {
        
        if nameTF.text == "" {
            
            self.showAlert(str: "Please enter name")
        }else if ageTF.text == "" {
            
            self.showAlert(str: "Please enter age")
        }else if emailTF.text == "" {
            
            self.showAlert(str: "Please enter email")
        }else if passwordTF.text == "" {
            
            self.showAlert(str: "Please enter password")
        }else {
            
            createChildAccount(email: emailTF.text!, password: passwordTF.text!, childName: nameTF.text!) { success, errorMessage in
                if success {
                    self.addChildAsUser(childUID: errorMessage ?? "")
                } else {
                    self.showAlert(str: "❌ Error: \(errorMessage ?? "Unknown error")")
                }
            }
        }
    }
    
    func addChildAsUser(childUID: String) -> Void {
        
        let params = ["user_id": childUID,
                      "name": nameTF.text!,
                      "email": emailTF.text!,
                      "type": 2] as [String : Any]
        
        let path = String(format: "%@", "Users")
        let db = Firestore.firestore()
        
        db.collection(path).document().setData(params) { err in
            if let err = err {
                
                SVProgressHUD.dismiss()
                self.showAlert(str: err.localizedDescription)
                
            } else {
                
                self.addChild(childUID: childUID)
            }
        }
    }
    
    
    func addChild(childUID: String) -> Void {
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let name = Auth.auth().currentUser?.displayName ?? ""
        let params = ["parent_id": id,
                      "parent_name": name,
                      "id": childUID,
                      "name": nameTF.text!,
                      "age": ageTF.text!,
                      "email": emailTF.text!,
                      "password": passwordTF.text!,
                      "type": 2] as [String : Any]
        
        let path = String(format: "%@", "Childs")
        let db = Firestore.firestore()
        
        db.collection(path).document().setData(params) { err in
            if let err = err {
                
                SVProgressHUD.dismiss()
                self.showAlert(str: err.localizedDescription)
                
            } else {
                
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "", message: "Child added successfully", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.destructive, handler: { action in
                    
                    self.navigationController?.popViewController(animated: true)
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func showAlert(str: String) -> Void {
        
        let alert = UIAlertController(title: "", message: str, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createChildAccount(email: String, password: String, childName: String, completion: @escaping (Bool, String?) -> Void) {
        let url = URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=\(firebaseAPIKey)")! // Replace with your API endpoint
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "displayName": childName,
            "parentId": Auth.auth().currentUser?.uid ?? "" // Attach parent ID
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        SVProgressHUD.show()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                if let error = error {
                    SVProgressHUD.dismiss()
                    completion(false, "Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    SVProgressHUD.dismiss()
                    completion(false, "No data received from server")
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    
                    if let errorResponse = jsonResponse?["error"] as? [String: Any],
                       let message = errorResponse["message"] as? String {
                        SVProgressHUD.dismiss()
                        completion(false, message) // Return error message
                    } else {
                        
                        if let uid = jsonResponse?["localId"] as? String {
                            print("New Child UID: \(uid)") // ✅ Here you get the child's UID
                            
                            completion(true, uid) // Success, no error

                        }
                    }
                } catch {
                    SVProgressHUD.dismiss()
                    completion(false, "JSON Parsing error: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
    }
    
    
    func createChildAccount(email: String, password: String, childName: String) {
        let url = URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=\(firebaseAPIKey)")!
        
        let requestBody: [String: Any] = [
            "email": email,
            "password": password,
            "displayName": childName,
            "returnSecureToken": false // Prevents Firebase from logging in the new user
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        SVProgressHUD.show()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                
                SVProgressHUD.dismiss()
                self.showAlert(str: "Error creating child user: \(error.localizedDescription)")
                //print("Error creating child user: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            do {
                let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("Child account created successfully: \(responseJSON ?? [:])")
                
                if let uid = responseJSON?["localId"] as? String {
                    print("New Child UID: \(uid)") // ✅ Here you get the child's UID
                    
                    DispatchQueue.main.async {
                        self.addChildAsUser(childUID: uid)
                    }
                }
                
            } catch {
                SVProgressHUD.dismiss()
                self.showAlert(str: "Error creating child user: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}
