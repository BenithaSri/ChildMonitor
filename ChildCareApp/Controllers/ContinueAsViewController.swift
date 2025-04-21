//
//  ContinueAsViewController.swift
//  ChildCareApp
//
//  Created by Benitha on 21/02/2025.
//

import UIKit

var userType = 1 // 1 as parent 2 as child

class ContinueAsViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    //MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func parent(_ sender: Any) {
        
        userType = 1
        self.performSegue(withIdentifier: "initial", sender: self)
    }
    
    @IBAction func child(_ sender: Any) {
        
        userType = 2
        self.performSegue(withIdentifier: "initial", sender: self)
    }
}
