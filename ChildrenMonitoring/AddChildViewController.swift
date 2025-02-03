//
//  AddChildViewController.swift
//  ChildrenMonitoring
//
//  Created by Benitha Sri Panchagiri on 2/2/25.
//

import UIKit

class AddChildViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let childName = nameTextField.text, !childName.isEmpty,
                      let childAge = ageTextField.text, !childAge.isEmpty else {
                    showAlert(message: "Please enter all details")
                    return
                }

                let selectedGender = genderSegmentedControl.selectedSegmentIndex == 0 ? "Male" : "Female"

                // Perform segue with the necessary data
               // performSegue(withIdentifier: "showOTP", sender: (childName, childAge, selectedGender))
            }
            
            // This prepares data to be passed to OTPViewController
            override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "showOTP" {
                    if let otpVC = segue.destination as? OTPViewController {
                        if let data = sender as? (String, String, String) {
                            otpVC.childName = data.0
                            otpVC.childAge = data.1
                            otpVC.childGender = data.2
                        }
                    }
                }
            }

            // Show an alert if the user doesn't enter all details
            func showAlert(message: String) {
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
