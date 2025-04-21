//
//  InitialViewController.swift
//  ChildCareApp
//
//  Created by Benitha on 29/01/2025.
//

import UIKit

class InitialViewController: UIViewController {
    
    @IBOutlet weak var registerBTN: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userType == 2 {
            
            registerBTN.isHidden = true
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
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
