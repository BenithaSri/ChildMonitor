//
//  SignUpViewController.swift
//  ChildrenMonitoring
//
//  Created by Benitha Sri Panchagiri on 11/23/24.
//

import UIKit;
import FirebaseAuth


class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var passwordRulesLabel: UILabel!
    
    @IBOutlet weak var passwordInfoButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        signUpButton.isEnabled = false
        
        // Assign delegates to monitor text field changes
        userName.delegate = self
        password.delegate = self
        confirmPassword.delegate = self
        
        // Disable secure text entry for passwords
        password.isSecureTextEntry = true
        confirmPassword.isSecureTextEntry = true
        
        // Disable autocapitalization for password fields
                password.autocapitalizationType = .none
                confirmPassword.autocapitalizationType = .none
                
                // Set keyboard type for password fields to default
                password.keyboardType = .default
                confirmPassword.keyboardType = .default
        passwordRulesLabel.isHidden = true
    }
    
    
//    @objc func showPasswordRules() {
//           passwordRulesLabel.isHidden = false
//       }
//
//       @objc func hidePasswordRules() {
//           passwordRulesLabel.isHidden = true
//       }
//       
    // Validate inputs and enable the sign-up button
    @objc func validateInputs() {
            guard let email = userName.text, isValidGmail(email),
                  let pass = password.text, let confirmPass = confirmPassword.text else {
                signUpButton.isEnabled = false
                return
            }
            
            // Enable button if passwords match and meet all criteria
            if isValidPassword(pass) && pass == confirmPass {
                signUpButton.isEnabled = true
                stopGlowEffect() // Stop glow if password is valid
            } else {
                signUpButton.isEnabled = false
                if !isValidPassword(pass) {
                    startGlowEffect() // Glow if password is invalid
                }
            }
        }
    
    // Password validation rules
       func isValidPassword(_ password: String) -> Bool {
           // Regex: At least one special character, one number, and minimum 7 characters
           let passwordRegex = "^(?=.*[!@#$%^&*(),.?\":{}|<>])(?=.*[0-9]).{7,}$"
           let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
           return passwordTest.evaluate(with: password)
       }

    
    // Show password rules popup only when the rules are not met
        func showPasswordRulesPopup() {
            let alert = UIAlertController(title: "Password Rules", message: """
            Your password must:
            - Be at least 7 characters long
            - Contain at least 1 special character
            - Contain at least 1 number
            """, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default))
            present(alert, animated: true)
        }
    
    
    
    @IBAction func signUpButton(_ sender: Any) {
        guard let email = userName.text, let password = password.text else { return }

                // Firebase Authentication Signup
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        self.showAlert(title: "Signup Failed", message: error.localizedDescription)
                    } else if let user = authResult?.user {
                        self.showAlert(title: "Signup Successful", message: "Welcome! Your User ID is \(user.uid)")
                    }
                }

    }
    
    //Rules Button
    @IBAction func passwordInfoButtonTapped(_ sender: Any) {
        passwordRulesLabel.isHidden = false
    }
    
    
    // Start glow effect on the passwordInfoButton
        func startGlowEffect() {
            passwordInfoButton.layer.borderWidth = 2
            passwordInfoButton.layer.borderColor = UIColor.red.cgColor
            passwordInfoButton.layer.cornerRadius = 10
            
            UIView.animate(withDuration: 1.0,
                           delay: 0,
                           options: [.repeat, .autoreverse],
                           animations: {
                self.passwordInfoButton.layer.shadowColor = UIColor.red.cgColor
                self.passwordInfoButton.layer.shadowRadius = 10
                self.passwordInfoButton.layer.shadowOpacity = 1.0
                self.passwordInfoButton.layer.shadowOffset = .zero
            }, completion: nil)
        }
    
    
    // Stop glow effect
        func stopGlowEffect() {
            passwordInfoButton.layer.borderWidth = 0
            passwordInfoButton.layer.shadowOpacity = 0
        }
    
    
    // Gmail validation
       func isValidGmail(_ email: String) -> Bool {
           let gmailRegex = "^[A-Za-z0-9._%+-]+@gmail\\.com$"
           let emailTest = NSPredicate(format: "SELF MATCHES %@", gmailRegex)
           return emailTest.evaluate(with: email)
       }
       
       // Show alert utility
       func showAlert(title: String, message: String) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
    
    // Monitor changes in text fields
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            DispatchQueue.main.async {
                self.validateInputs()
            }
            return true
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
