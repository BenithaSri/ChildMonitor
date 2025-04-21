//
//  ResetPasswordViewController.swift
//  ChildCareApp
//
//  Created by Benitha on 18/02/2025.
//

import UIKit
import SVProgressHUD
import FirebaseAuth

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var oldPassTF: UITextField!
    @IBOutlet weak var newPassTF: UITextField!
    @IBOutlet weak var confirmPassTF: UITextField!
    
    
    @IBOutlet weak var oldPassBtn: UIButton!
    @IBOutlet weak var newPassBtn: UIButton!
    @IBOutlet weak var confirmPassBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
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

    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>])[A-Za-z\\d!@#$%^&*(),.?\":{}|<>]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    
    
    @IBAction func update(_ sender: Any) {
        
        if oldPassTF.text == "" {
            
            self.showAlert(str: "enter old password")
        }else if newPassTF.text == "" {
            
            self.showAlert(str: "enter new password")
        }else if confirmPassTF.text == "" {
            
            self.showAlert(str: "enter confirm password")
        }else {
            
            if !isValidPassword(newPassTF.text!) {
                
                self.showAlert(str: "Password must be at least 8 characters long and include uppercase, lowercase, digit, and special character.")
                
            }else if oldPassTF.text != confirmPassTF.text {
                
                self.showAlert(str: "Password and confirm password must be same")
            }else {
                
                self.updatePassword()
            }
        }
    }
    
    func updatePassword() -> Void {
        
        SVProgressHUD.show()
        updatePassword(oldPassword: oldPassTF.text!, newPassword: newPassTF.text!)
        
    }
    
    func updatePassword(oldPassword: String, newPassword: String) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            print("User not found or email is missing")
            return
        }
        
        // Step 1: Create credential with email and old password
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
        
        // Step 2: Reauthenticate user
        user.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                print("Reauthentication failed: \(error.localizedDescription)")
                return
            }
            
            print("Reauthentication successful")
            
            // Step 3: Update Password
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    print("Error updating password: \(error.localizedDescription)")
                } else {
                    self.showAlert()
                }
            }
        }
    }
    
    
    func showAlert() -> Void {
        
        // create the alert
        let alert = UIAlertController(title: "Alert", message: "Password updated successfully", preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            
            self.navigationController?.popViewController(animated: true)
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showAlert(str: String) -> Void {
        
        let alert = UIAlertController(title: "", message: str, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func oldPassword(_ sender: Any) {
        
        oldPassTF.isSecureTextEntry.toggle()
        if oldPassTF.isSecureTextEntry {
            
            oldPassBtn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }else {
            
            oldPassBtn.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
    
    @IBAction func newPassword(_ sender: Any) {
        
        newPassTF.isSecureTextEntry.toggle()
        if newPassTF.isSecureTextEntry {
            
            newPassBtn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }else {
            
            newPassBtn.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
    @IBAction func confirmPassword(_ sender: Any) {
        
        confirmPassTF.isSecureTextEntry.toggle()
        if confirmPassTF.isSecureTextEntry {
            
            confirmPassBtn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }else {
            
            confirmPassBtn.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
}
