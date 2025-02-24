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

    @IBOutlet weak var consentSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial setup
        signUpButton.isEnabled = false
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
    }
    
    @objc func validateInputs() {
        // Ensure non-empty values before checking validation
        guard let email = userName.text, !email.isEmpty,
              let pass = password.text, !pass.isEmpty,
              let confirmPass = confirmPassword.text, !confirmPass.isEmpty else {
            signUpButton.isEnabled = false
            return
        }

        let isPasswordValid = isValidPassword(pass)
        let doPasswordsMatch = pass == confirmPass
        let isEmailValid = isValidGmail(email)
        let isConsentGiven = consentSwitch.isOn  // Check if user has given consent

        // Debugging
        print("isEmailValid: \(isEmailValid), isPasswordValid: \(isPasswordValid), doPasswordsMatch: \(doPasswordsMatch), isConsentGiven: \(isConsentGiven)")

        signUpButton.isEnabled = isEmailValid && isPasswordValid && doPasswordsMatch && isConsentGiven
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
        guard let email = userName.text, let password = password.text else {
               showAlert(title: "Error", message: "Please fill in all the fields.")
               return
           }
           
           // Firebase Authentication Signup
           Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
               if let error = error {
                   // Capture and display the error message from Firebase
                   self?.handleFirebaseError(error)
               } else if let authResult = authResult {
                   // If signup is successful, show success alert
                   self?.showAlert(title: "Signup Successful", message: "Welcome, \(authResult.user.email ?? "User")!")
               }
           }
    }
    
    func handleFirebaseError(_ error: Error) {
        let nsError = error as NSError
        var errorMessage = "An unexpected error occurred. Please try again."

        // Check if the error is from Firebase Authentication
        if nsError.domain == AuthErrorDomain {
            switch AuthErrorCode(rawValue: nsError.code) {
            case .emailAlreadyInUse:
                errorMessage = "This email is already registered. Please log in instead."
            case .invalidEmail:
                errorMessage = "The email address is not valid. Please enter a valid email."
            case .weakPassword:
                errorMessage = "The password is too weak. Please choose a stronger password."
            default:
                errorMessage = nsError.localizedDescription
            }
        }

        // Show the error message in an alert
        showAlert(title: "Signup Failed", message: errorMessage)
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

    @IBAction func consentSwitchToggled(_ sender: UISwitch) {
        
        if sender.isOn {
                showTermsAndConditionsAlert()
                sender.setOn(false, animated: true) // Reset switch until user agrees
            }
    }
    
    func showTermsAndConditionsAlert() {
        var agreed = false  // To track checkbox state

        let alert = UIAlertController(title: "Terms and Conditions", message: """
        Please agree to the following terms:
        1. We collect data to enhance child safety.
        2. Your data will be encrypted and secure.
        3. You must be the legal guardian to sign up.
        """, preferredStyle: .alert)

        let agreeAction = UIAlertAction(title: "☐ Agree", style: .default) { action in
            agreed.toggle() // Toggle agreement state
            let newTitle = agreed ? "☑ Agree" : "☐ Agree"
            alert.actions[0].setValue(newTitle, forKey: "title")

            if agreed {
                self.consentSwitch.setOn(true, animated: true)
                self.validateInputs() // Revalidate sign-up button state
            } else {
                self.consentSwitch.setOn(false, animated: true)
            }
        }

        alert.addAction(agreeAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true)
    }
    

//    //xyz
//    func showAlert(title: String, message: String) {
//            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            present(alert, animated: true)
//    }
    
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    
}
