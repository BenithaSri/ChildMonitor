//
//  SplashViewController.swift
//  ChildCareApp
//
//  Created by Benitha on 29/01/2025.
//

import UIKit
import FirebaseAuth
import Lottie


let mapKey = "AIzaSyD6n_2K2q9sCXfAiSFYqDLtnDm4QfSjzBs"
class SplashViewController: UIViewController {
    
    @IBOutlet weak var launchLAV: LottieAnimationView!
    var userType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        launchLAV.loopMode = .playOnce
        launchLAV.play { completed in
            if completed {
                
                self.moveToView()
            }
        }
    }
    
    func moveToView() -> Void {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            if Auth.auth().currentUser == nil {
                
                self.performSegue(withIdentifier: "start", sender: self)
                
            }else {
                
                let type = UserDefaults.standard.integer(forKey: "user_type")
                if type == 1 {
                    
                    let vc = self.storyboard?.instantiateViewController(identifier: "myTabBar") as! UITabBarController
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    
                    let vc = self.storyboard?.instantiateViewController(identifier: "childTabBar") as! UITabBarController
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
