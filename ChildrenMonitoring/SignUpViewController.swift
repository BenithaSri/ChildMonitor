//
//  SignUpViewController.swift
//  ChildrenMonitoring
//
//  Created by Benitha Sri Panchagiri on 11/23/24.
//

import UIKit;
import FirebaseAuth


extension UITextField {
    func applyGlowEffect(color: UIColor = .red) {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize.zero
        layer.masksToBounds = false
    }
    
    func removeGlowEffect() {
        layer.shadowOpacity = 0
    }
}


class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var passwordRulesLabel: UILabel!
    
    @IBOutlet weak var passwordInfoButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var showConfirmPassword: UIButton!
    
    @IBOutlet weak var passwordShow: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial setup
                signUpButton.isEnabled = false
                //passwordRulesLabel.isHidden = true
                password.isSecureTextEntry = true
                confirmPassword.isSecureTextEntry = true
                
                // Set delegates
                userName.delegate = self
                password.delegate = self
                confirmPassword.delegate = self
                
                // Add target actions for text changes
                userName.addTarget(self, action: #selector(validateInputs), for: .editingChanged)
                password.addTarget(self, action: #selector(validateInputs), for: .editingChanged)
                confirmPassword.addTarget(self, action: #selector(validateInputs), for: .editingChanged)
        
        passwordShow.setImage(UIImage(systemName: "eye"), for: .normal)
        showConfirmPassword.setImage(UIImage(systemName: "eye"), for: .normal)
        
        signUpButton.isEnabled = true

    }
    @objc func validateInputs() {
           guard let email = userName.text,
                 let pass = password.text,
                 let confirmPass = confirmPassword.text else {
               signUpButton.isEnabled = false
               return
           }
           
           // Check if passwords match and meet validation rules
           let isPasswordValid = isValidPassword(pass)
           let doPasswordsMatch = pass == confirmPass
           
           // Apply green glow if password is valid, red glow if invalid
           if !pass.isEmpty {
               if isPasswordValid {
                   password.applyGlowEffect(color: .green)
               } else {
                   password.applyGlowEffect(color: .red)
               }
           } else {
               password.removeGlowEffect()
           }
           
           // Only apply glow effect to confirm password if it's not empty and passwords don't match
           if !confirmPass.isEmpty && pass != confirmPass {
               confirmPassword.applyGlowEffect(color: .red)
           } else {
               confirmPassword.removeGlowEffect()
           }
           
           if isValidGmail(email) && isPasswordValid && doPasswordsMatch {
               signUpButton.isEnabled = true
           } else {
               signUpButton.isEnabled = false
           }
       }
    
    // Modified text field delegate method
        func textFieldDidEndEditing(_ textField: UITextField) {
            if textField == password {
                // Glow green if valid, red if invalid
                if !textField.text!.isEmpty {
                    if isValidPassword(textField.text ?? "") {
                        textField.applyGlowEffect(color: .green)
                    } else {
                        textField.applyGlowEffect(color: .red)
                    }
                } else {
                    textField.removeGlowEffect()
                }
            }
            
            if textField == confirmPassword {
                // Only glow if confirm password is not empty and passwords don't match
                if !textField.text!.isEmpty && textField.text != password.text {
                    confirmPassword.applyGlowEffect(color: .red)
                } else {
                    confirmPassword.removeGlowEffect()
                }
            }
        }
    
    // Password validation rules
       func isValidPassword(_ password: String) -> Bool {
           // At least one special character, one number, and minimum 7 characters
           let passwordRegex = "^(?=.*[!@#$%^&*(),.?\":{}|<>])(?=.*[0-9]).{7,}$"
           let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
           return passwordTest.evaluate(with: password)
       }
       
       // Show password rules popup
       func showPasswordRulesPopup() {
           let alert = UIAlertController(title: "Password Rules", message: """
           Your password must:
           * Be at least 7 characters long
           * Contain at least 1 special character
           * Contain at least 1 number
           """, preferredStyle: .alert)
           
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           
           present(alert, animated: true)
       }
    
    @IBAction func signUpButton(_ sender: Any) {
        guard let email = userName.text, let password = password.text else { return }

        //xyz
        if !consentSwitch.isOn {
                    showAlert(title: "Consent Required", message: "You must agree to the terms before signing up.")
                    return
                }
        // xyz Ensure user has accepted consent
        if !consentSwitch.isOn {
            showAlert(title: "Consent Required", message: "You must agree to the terms before signing up.")
            return
        }
                        
                // Firebase Authentication Signup
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                    if let error = error {
                        // Check if the error is due to an existing account
                        if let authError = error as NSError?,
                           authError.domain == "FIRAuthErrorDomain",
                           authError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                            // Show alert for existing account
                            self?.showAlert(title: "Account Already Exists",
                                            message: "This email is already registered. Please log in instead.")
                        } else {
                            // Handle other signup errors
                            self?.showAlert(title: "Signup Failed", message: error.localizedDescription)
                        }
                    } else if let user = authResult?.user {
                        self?.showAlert(title: "Signup Successful", message: "Welcome!")
                    }
                }
    }
    
    //Rules Button
    @IBAction func passwordInfoButtonTapped(_ sender: Any) {
        showPasswordRulesPopup()
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
    
    
    // Track password visibility state
    private var isPasswordVisible = false
    private var isConfirmPasswordVisible = false
    
    @IBAction func showPasswordTapped(_ sender: Any) {
        // Toggle password visibility
            isPasswordVisible = !isPasswordVisible
            password.isSecureTextEntry = !isPasswordVisible
            
            // Update button appearance or icon to reflect current state
            let buttonImage = isPasswordVisible ? UIImage(systemName: "eye.slash") : UIImage(systemName: "eye")
            passwordShow.setImage(buttonImage, for: .normal)
    }
    
        
    @IBAction func showConfirmPasswordTapped(_ sender: Any) {
        // Toggle confirm password visibility
           isConfirmPasswordVisible = !isConfirmPasswordVisible
           confirmPassword.isSecureTextEntry = !isConfirmPasswordVisible
           
           // Update button appearance or icon to reflect current state
           let buttonImage = isConfirmPasswordVisible ? UIImage(systemName: "eye.slash") : UIImage(systemName: "eye")
           showConfirmPassword.setImage(buttonImage, for: .normal)
    }

    //xyz
    func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
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
