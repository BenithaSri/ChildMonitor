//
//  ChildLocationViewController.swift
//  ChildCareApp
//
//  Created by Benitha on 03/04/2025.
//

import UIKit
import GoogleMaps
import FirebaseAuth
import FirebaseFirestore


class ChildLocationViewController: UIViewController {

    @IBOutlet weak var addressLBL: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    var childData: ChildModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = childData?.name ?? "Child Location"
        // Do any additional setup after loading the view.
        self.getChildDetails()
    }
    
    func getChildDetails() -> Void {
        
        let database = Firestore.firestore()
        let id = Auth.auth().currentUser?.uid ?? ""
        let child_id = self.childData?.id ?? ""
        
        let docRef = database.collection("Childs")
            .whereField("parent_id", isEqualTo: id)
            .whereField("id", isEqualTo: child_id)
        
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                
                print("Error getting documents: \(err)")
                
            } else {
                
                guard let document = querySnapshot?.documents, !document.isEmpty else {
                    print("Document does not exist")
                    return
                }
                
                let data = document[0].data()
                var child = ChildModel()
                
                child.name = data["name"] as? String ?? ""
                
                child.lat = data["lat"] as? Double ?? 0.0
                child.lng = data["lng"] as? Double ?? 0.0
                child.address = data["address"] as? String ?? ""
                
                self.childData = child
                
                self.setMap()
            }
        }
    }
    
    
    func setMap() -> Void {
        
        if let lat = self.childData?.lat, let lng = self.childData?.lng {
            
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 15)
            self.mapView.camera = camera
            
            mapView.clear()
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            
            marker.map = mapView
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
