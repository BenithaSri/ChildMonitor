//
//  OTPViewController.swift
//  ChildrenMonitoring
//
//  Created by Benitha Sri Panchagiri on 2/2/25.
//

import UIKit

class OTPViewController: UIViewController {

    var childName: String?
    var childAge: String?
    var childGender: String?
    
    @IBOutlet weak var otpLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Generate and display OTP
        let generatedOTP = generateOTP()
        otpLabel.text = "Your OTP: \(generatedOTP)"
        
        // Save OTP to UserDefaults for future use
        UserDefaults.standard.set(generatedOTP, forKey: "childOTP")
    }

    // Function to generate a random OTP
    func generateOTP() -> String {
        let otp = String(format: "%06d", arc4random_uniform(1000000))
        return otp
    }
}

