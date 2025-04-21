//
//  ForgotViewController.swift
//  ChildCareApp
//
//  Created by Benitha on 30/01/2025.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class ForgotViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func send(_ sender: Any) {
        
        if emailTF.text == "" {
            
            self.showAlert(str: "enter email")
        }else {
            
            SVProgressHUD.show()
            Auth.auth().sendPasswordReset(withEmail: emailTF.text!) {error in
                
                if error != nil {
                    
                    SVProgressHUD.dismiss()
                    self.showAlert(str: error?.localizedDescription ?? "")
                }else{
                    
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "", message: "Reset password link send to the email", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
                        
                        self.navigationController?.popViewController(animated: true)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func showAlert(str: String) -> Void {
        
        let alert = UIAlertController(title: "", message: str, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
