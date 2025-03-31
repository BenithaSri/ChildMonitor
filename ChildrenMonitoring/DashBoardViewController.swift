//
//  DashBoardViewController.swift
//  ChildrenMonitoring
//
//  Created by Benitha Sri Panchagiri on 11/23/24.
//

import UIKit

class DashBoardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // Setup UI Elements
    func setupUI() {
        welcomeLabel.text = "Welcome to the Dashboard"
        childActivityButton.setTitle("View Child Activity", for: .normal)
        logoutButton.setTitle("Logout", for: .normal)
        
        childActivityButton.addTarget(self, action: #selector(viewChildActivity), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
    }
    
    // Navigate to Child Activity Screen
    @objc func viewChildActivity() {
        performSegue(withIdentifier: "showChildActivity", sender: self)
    }
    
    // Logout and Navigate to Login Screen
    @objc func logout() {
        navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChildActivity" {
            // Pass any necessary data to the child activity screen
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
