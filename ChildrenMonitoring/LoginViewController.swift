//
//  LoginViewController.swift
//  ChildrenMonitoring
//
//  Created by Benitha Sri Panchagiri on 11/23/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabaseInternal
//import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    @IBOutlet weak var loginLabel: UILabel!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var parentIDTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBOutlet weak var parentID: UILabel!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupViewForParent()
        setupTextFieldObservers()
        updateLoginButtonState()
        
        // Set delegates for text fields
               usernameTextField.delegate = self
               passwordTextField.delegate = self
               parentIDTextField.delegate = self
        
        
        passwordTextField.isSecureTextEntry = true
    }
    
    
    func setupViewForParent() {
        loginLabel.text = "Parent Login"
           parentIDTextField.isHidden = true
        parentID.isHidden = true
       }

       // Configure UI for Child Login
       func setupViewForChild() {
           loginLabel.text = "Child Login"
           parentIDTextField.isHidden = false
           parentID.isHidden = false
       }
    
    @objc func updateLoginButtonState() {
        let isParent = toggleSwitch.isOn
                let isUsernameValid = !(usernameTextField.text?.isEmpty ?? true)
                let isPasswordValid = !(passwordTextField.text?.isEmpty ?? true) && validatePassword(passwordTextField.text ?? "")
                let isParentIDValid = isParent || !(parentIDTextField.text?.isEmpty ?? true)
                
                loginButton.isEnabled = isUsernameValid && isPasswordValid && isParentIDValid
        }
    
    
    func setupTextFieldObservers() {
            [usernameTextField, passwordTextField, parentIDTextField].forEach { textField in
                textField?.addTarget(self, action: #selector(updateLoginButtonState), for: .editingChanged)
            }
        }
    
    
    @IBAction func toggleRole(_ sender: Any) {
        
        if (sender as AnyObject).isOn {
                    setupViewForParent()
                } else {
                    setupViewForChild()
                }
    }
    
    func showAlert(title: String, message: String) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
    
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        guard let email = usernameTextField.text, !email.isEmpty,
                      let password = passwordTextField.text, !password.isEmpty else {
                    showAlert(title: "Error", message: "Username and Password cannot be empty.")
                    return
                }
                
                if toggleSwitch.isOn {
                    authenticateParent(email: email, password: password)
                } else {
                    guard let parentID = parentIDTextField.text, !parentID.isEmpty else {
                        showAlert(title: "Error", message: "Parent ID cannot be empty.")
                        return
                    }
                    authenticateChild(email: email, password: password, parentID: parentID)
                }
    }
    
    
    func authenticateParent(email: String, password: String) {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let self = self else { return }
                if let error = error {
                    self.showAlert(title: "Error", message: "Login failed: \(error.localizedDescription)")
                } else {
                    self.showAlert(title: "Success", message: "Welcome Parent!")
                    // Navigate to Parent Dashboard
                    self.performSegue(withIdentifier: "parentDashboardSegue", sender: nil)
                }
            }
        }
    
    
    func validateParentID(_ parentID: String, completion: @escaping (Bool) -> Void) {
            // Fetch Parent ID from Firebase Database (Example Logic)
            let databaseRef = Database.database().reference()
            databaseRef.child("parents").child(parentID).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    
    
    func authenticateChild(email: String, password: String, parentID: String) {
           Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
               guard let self = self else { return }
               if let error = error {
                   self.showAlert(title: "Error", message: "Login failed: \(error.localizedDescription)")
               } else {
                   // Validate Parent ID in the database
                   self.validateParentID(parentID) { isValid in
                       if isValid {
                           self.showAlert(title: "Success", message: "Welcome Child!")
                           // Navigate to Child Dashboard
                           self.performSegue(withIdentifier: "childDashboardSegue", sender: nil)
                       } else {
                           self.showAlert(title: "Error", message: "Invalid Parent ID.")
                       }
                   }
               }
           }
       }
    
    //validate password
    func validatePassword(_ password: String) -> Bool {
            let minLengthRule = password.count >= 6
            let specialCharRule = password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil
            let numberRule = password.rangeOfCharacter(from: .decimalDigits) != nil
            
            return minLengthRule && specialCharRule && numberRule
        }
    
    // UITextFieldDelegate to validate after editing ends
        func textFieldDidEndEditing(_ textField: UITextField) {
            if textField == passwordTextField {
                if !validatePassword(textField.text ?? "") {
                    showAlert(title: "Error", message: "Password does not meet the required criteria.")
                }
            }
            updateLoginButtonState()
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
