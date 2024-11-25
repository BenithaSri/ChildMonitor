//
//  LoginViewController.swift
//  ChildrenMonitoring
//
//  Created by Benitha Sri Panchagiri on 11/23/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabaseInternal

// LoginViewController handles login functionality for both Parent and Child users
class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // UI Outlets
    @IBOutlet weak var toggleSwitch: UISwitch! // Switch to toggle between Parent and Child login
    @IBOutlet weak var loginLabel: UILabel! // Label indicating the current login mode
    @IBOutlet weak var usernameTextField: UITextField! // TextField for username input
    @IBOutlet weak var passwordTextField: UITextField! // TextField for password input
    @IBOutlet weak var parentIDTextField: UITextField! // TextField for Parent ID input (Child login only)
    @IBOutlet weak var loginButton: UIButton! // Button to perform login action
    @IBOutlet weak var parentID: UILabel! // Label for Parent ID (Child login only)
    @IBOutlet weak var forgotPasswordButton: UIButton! // Button to reset password

    // Lifecycle method called when the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the initial UI for Parent login
        setupViewForParent()
        
        // Add observers to TextFields for enabling/disabling login button based on input validation
        setupTextFieldObservers()

        // Set initial state of the login button
        updateLoginButtonState()

        // Assign delegates for TextFields to handle input validation
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        parentIDTextField.delegate = self

        // Make the password field secure (hide characters)
        passwordTextField.isSecureTextEntry = true
    }
    
    // Configure UI for Parent Login
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
    
    // Update the state of the login button based on input validity
    @objc func updateLoginButtonState() {
        let isParent = toggleSwitch.isOn // Check if toggle switch is set to Parent login
        let isUsernameValid = !(usernameTextField.text?.isEmpty ?? true) // Validate username input
        let isPasswordValid = !(passwordTextField.text?.isEmpty ?? true) && validatePassword(passwordTextField.text ?? "") // Validate password input
        let isParentIDValid = isParent || !(parentIDTextField.text?.isEmpty ?? true) // Validate Parent ID if in Child login mode
        
        // Enable login button only if all required fields are valid
        loginButton.isEnabled = isUsernameValid && isPasswordValid && isParentIDValid
    }

    // Add observers to TextFields to listen for text changes and update login button state
    func setupTextFieldObservers() {
        [usernameTextField, passwordTextField, parentIDTextField].forEach { textField in
            textField?.addTarget(self, action: #selector(updateLoginButtonState), for: .editingChanged)
        }
    }

    // Action triggered by the toggle switch to change login mode
    @IBAction func toggleRole(_ sender: Any) {
        if (sender as AnyObject).isOn {
            setupViewForParent()
        } else {
            setupViewForChild()
        }
    }

    // Display an alert message
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Action triggered when the login button is tapped
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let email = usernameTextField.text, !email.isEmpty, // Validate username
              let password = passwordTextField.text, !password.isEmpty else { // Validate password
            showAlert(title: "Error", message: "Username and Password cannot be empty.")
            return
        }
        
        // Check if the login is for Parent or Child and proceed accordingly
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

    // Authenticate Parent user using Firebase Auth
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

    // Validate Parent ID against Firebase Database
    func validateParentID(_ parentID: String, completion: @escaping (Bool) -> Void) {
        let databaseRef = Database.database().reference()
        databaseRef.child("parents").child(parentID).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }

    // Authenticate Child user and validate Parent ID
    func authenticateChild(email: String, password: String, parentID: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(title: "Error", message: "Login failed: \(error.localizedDescription)")
            } else {
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

    // Validate password based on specific rules
    func validatePassword(_ password: String) -> Bool {
        let minLengthRule = password.count >= 6 // Minimum length of 6 characters
        let specialCharRule = password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil // At least one special character
        let numberRule = password.rangeOfCharacter(from: .decimalDigits) != nil // At least one numeric digit
        
        return minLengthRule && specialCharRule && numberRule
    }

    // UITextFieldDelegate method to validate password after editing ends
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == passwordTextField {
            if !validatePassword(textField.text ?? "") {
                showAlert(title: "Error", message: "Password does not meet the required criteria.")
            }
        }
        updateLoginButtonState() // Update login button state after editing
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
