//
//  ProfileViewController.swift
//  ChildCareApp
//
//  Created by Benitha on 06/02/2025.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var emailLBL: UILabel!
    @IBOutlet weak var nameLBL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Profile"
        
        nameLBL.text = Auth.auth().currentUser?.displayName ?? ""
        emailLBL.text = Auth.auth().currentUser?.email ?? ""
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func logout(_ sender: Any) {
        do {
            
            try Auth.auth().signOut()
        } catch {}
        
        let vc = self.storyboard?.instantiateViewController(identifier: "SplashViewController") as! SplashViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }
}
