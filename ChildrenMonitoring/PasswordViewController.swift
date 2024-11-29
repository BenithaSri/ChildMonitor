//
//  PasswordViewController.swift
//  ChildrenMonitoring
//
//  Created by Benitha Sri Panchagiri on 11/23/24.
//

import UIKit
import FirebaseAuth

class PasswordViewController: UIViewController {
    
    
    @IBOutlet weak var passwordOL: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func sendLinkBtn(_ sender: Any) {
        guard let email = passwordOL.text, !email.isEmpty else {
                    showAlert(title: "Error", message: "Please enter an email address")
                    return
                }
                
                // Validate email format
                guard isValidEmail(email) else {
                    showAlert(title: "Invalid Email", message: "Please enter a valid email address")
                    return
                }
                
                // Send password reset link
                Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
                    if let error = error {
                        // Handle specific Firebase authentication errors
                        self?.handleResetError(error)
                    } else {
                        // Successfully sent reset link
                        self?.showAlert(title: "Success", message: "Password reset link sent to \(email)")
                    }
                }
    }
    
    // Email validation method
        func isValidEmail(_ email: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: email)
        }
        
        // Handle different Firebase authentication errors
        func handleResetError(_ error: Error) {
            let nsError = error as NSError
            
            switch nsError.code {
            case AuthErrorCode.userNotFound.rawValue:
                showAlert(title: "Error", message: "No user found with this email. Please check and try again.")
            case AuthErrorCode.invalidEmail.rawValue:
                showAlert(title: "Error", message: "Invalid email format. Please enter a valid email.")
            case AuthErrorCode.networkError.rawValue:
                showAlert(title: "Network Error", message: "Please check your internet connection and try again.")
            default:
                showAlert(title: "Error", message: "Failed to send reset link. Please try again.")
            }
        }
        
        // Utility method to show alerts
        func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
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
