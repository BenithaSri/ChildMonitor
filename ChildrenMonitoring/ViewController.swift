//
//  ViewController.swift
//  ChildrenMonitoring
//
//  Created by Benitha Sri Panchagiri on 11/23/24.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var launchView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        animateImageToPosition()
        
    }

    
    func animateImageToPosition() {
            // Save the original frame of the image
            let originalFrame = launchView.frame
            
            // Make the image fill the screen
        launchView.frame = UIScreen.main.bounds
            
            // Animate back to its original position
            UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveEaseInOut, animations: {
                self.launchView.frame = originalFrame
            }, completion: nil)
        }

}

