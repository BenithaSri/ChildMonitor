//
//  RegisterViewController.swift
//  ChildCareApp
//
//  Created by Benitha on 30/01/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var cpasswordTF: UITextField!
    
    @IBOutlet weak var passBtn: UIButton!
    @IBOutlet weak var cpassBtn: UIButton!
    
    @IBOutlet weak var termsTV: UITextView!
    @IBOutlet weak var termsBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        termsTV.isEditable = false
        termsTV.isScrollEnabled = false
        termsTV.backgroundColor = .clear
        termsTV.textAlignment = .left
        
        let text = "By registering, you agree to our Terms and Conditions."
        let attributedString = NSMutableAttributedString(string: text)
        let linkRange = (text as NSString).range(of: "Terms and Conditions")
        
        attributedString.addAttribute(.link, value: "https://google.com/", range: linkRange)
        termsTV.attributedText = attributedString
        termsTV.font = UIFont.systemFont(ofSize: 17)
        
        termsTV.textContainerInset = .zero
        termsTV.textContainer.lineFragmentPadding = 0
        
        termsBtn.setImage(UIImage(systemName: "square"), for: .normal)
        termsBtn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    @IBAction func terms(_ sender: Any) {
        
        termsBtn.isSelected.toggle()
    }
    
    @IBAction func register(_ sender: Any) {
        
        if nameTF.text == "" {
            
            self.showAlert(str: "Please enter name")
        }else if emailTF.text == "" {
            
            self.showAlert(str: "Please enter email")
        }else if passwordTF.text == "" {
            
            self.showAlert(str: "Please enter password")
        }else if cpasswordTF.text == "" {
            
            self.showAlert(str: "Please enter confirm password")
        }else {
            
            if !isValidPassword(passwordTF.text!) {
                
                self.showAlert(str: "Password must be at least 8 characters long and include uppercase, lowercase, digit, and special character.")
                
            }else if passwordTF.text != cpasswordTF.text {
                
                self.showAlert(str: "Password and confirm password must be same")
            }else if !termsBtn.isSelected {
                
                self.showAlert(str: "Accept terms & conditions to continue")
            }else {
                
                SVProgressHUD.show()
                register(email: emailTF.text!, password: passwordTF.text!)
            }
        }
    }
    
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>])[A-Za-z\\d!@#$%^&*(),.?\":{}|<>]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    
    func register(email: String, password: String) {
        
        Auth.auth().createUser(withEmail: emailTF.text!,
                               password: passwordTF.text!) { authResult, error in
          
            if error != nil {
                
                SVProgressHUD.dismiss()
                self.showAlert(str: error?.localizedDescription ?? "")
            }else{
                
                let profile = authResult?.user.createProfileChangeRequest()
                profile?.displayName = String(format: "%@", self.nameTF.text!)
                profile?.commitChanges(completion: { error in
                    if error != nil {
                        
                        SVProgressHUD.dismiss()
                        self.showAlert(str: error?.localizedDescription ?? "")
                    }else{
                        
                        self.saveUser()
                    }
                })
            }
        }
    }
    
    func saveUser() -> Void {
        
        let id = Auth.auth().currentUser?.uid ?? ""
        
        let params = ["user_id": id,
                      "name": nameTF.text!,
                      "email": emailTF.text!,
                      "type": 1
        ] as [String : Any]
        
        let path = String(format: "%@", "Users")
        let db = Firestore.firestore()
        
        SVProgressHUD.show()
        db.collection(path).document().setData(params) { err in
            if let err = err {
                
                SVProgressHUD.dismiss()
                self.showAlert(str: err.localizedDescription)
                
            } else {
                
                do {
                    try Auth.auth().signOut()
                    print("User signed out successfully")
                } catch let signOutError as NSError {
                    print("Error signing out: \(signOutError.localizedDescription)")
                }
                
                SVProgressHUD.dismiss()
                self.showAlert()
            }
        }
    }
    
    
    func showAlert() -> Void {
        
        // create the alert
        let alert = UIAlertController(title: "Alert", message: "Account Created successfully", preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            
            self.navigationController?.popViewController(animated: true)
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func login(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
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
    
    
    @IBAction func cpassword(_ sender: Any) {
        
        cpasswordTF.isSecureTextEntry.toggle()
        if cpasswordTF.isSecureTextEntry {
            
            cpassBtn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }else {
            
            cpassBtn.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
}
