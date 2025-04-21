//
//  AddRestrictedLocationViewController.swift
//  ChildCareApp
//
//  Created by Benitha on 11/02/2025.
//

import UIKit
import GoogleMaps
import FirebaseAuth
import FirebaseFirestore
import CoreLocation
import SVProgressHUD
import GooglePlaces

class AddRestrictedLocationViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var addressLBL: UILabel!
    
    var locationManager = CLLocationManager()
    var selectedLocation: CLLocation?
    
    var childData: ChildModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeMap()
        self.initializeLocationManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationManager.stopUpdatingLocation()
    }
    
    
    func initializeMap() -> Void {
        
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.tiltGestures = false
        mapView.settings.rotateGestures = true
        mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
    }
    
    func initializeLocationManager() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = CLLocationDegrees(1)
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func save(_ sender: Any) {
        
        if titleTF.text?.isEmpty ?? true {
            
            self.showAlert(str: "Please enter title")
        }else if selectedLocation == nil {
           
            self.showAlert(str: "Please select location")
        }else {
            
            self.addLocation()
        }
    }
    
    func addLocation() -> Void {
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let child_id = childData?.id ?? ""
        
        let params = ["parent_id": id,
                      "child_id": child_id,
                      "title": titleTF.text!,
                      "address": addressLBL.text!,
                      "lat": selectedLocation?.coordinate.latitude ?? 0.0,
                      "lng": selectedLocation?.coordinate.longitude ?? 0.0] as [String : Any]
        
        let path = String(format: "%@", "Restricted_Locations")
        let db = Firestore.firestore()
        
        SVProgressHUD.show()
        db.collection(path).document().setData(params) { err in
            if let err = err {
                
                SVProgressHUD.dismiss()
                self.showAlert(str: err.localizedDescription)
                
            } else {
                
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "", message: "location added successfully", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.destructive, handler: { action in
                    
                    self.navigationController?.popViewController(animated: true)
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func current(_ sender: Any) {
        
        self.initializeLocationManager()
    }
    
    func showAlert(str: String) -> Void {
        
        let alert = UIAlertController(title: "", message: str, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func seach(_ sender: Any) {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
}


extension AddRestrictedLocationViewController: CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("====\(status) ====")
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .restricted:
            break
        case .denied:
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 15.0)
        
        selectedLocation = location ?? CLLocation(latitude: 0.0, longitude: 0.0)
        self.mapView?.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed with error: \(error.localizedDescription)")
    }
}

extension AddRestrictedLocationViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        let geocoder = GMSGeocoder()
        let location = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
        
        geocoder.reverseGeocodeCoordinate(location.coordinate, completionHandler: {response,error in
            
            var result: GMSReverseGeocodeResult?
            var a = CLLocationCoordinate2D()
            
            if error == nil {
                result = response?.firstResult()
                if let coordinate = result?.coordinate {
                    a = coordinate
                }
                print(a.latitude)
                
                self.selectedLocation = location
                
                var str: String?
                var locality: String?
                var sublocality: String?
                var thoroughfare: String?
                var country: String?
                
                if let results = response?.results() {
                    
                    for addressObj in results {
                        
                        if addressObj.locality != nil && locality == nil {
                            locality = addressObj.locality ?? ""
                        }
                        if addressObj.subLocality != nil && sublocality == nil {
                            sublocality = addressObj.subLocality ?? ""
                        }
                        if addressObj.thoroughfare != nil && thoroughfare == nil {
                            thoroughfare = addressObj.thoroughfare ?? ""
                        }
                        if addressObj.country != nil && country == nil {
                            country = addressObj.country ?? ""
                        }
                        if thoroughfare != nil && sublocality != nil && locality != nil && country != nil {
                            str = ""
                            str = "\(thoroughfare!), \(sublocality!), \(locality!), \(country!)"
                        } else if thoroughfare != nil && locality != nil && country != nil {
                            str = ""
                            str = "\(thoroughfare!), \(locality!), \(country!)"
                        } else if thoroughfare != nil && sublocality != nil && country != nil {
                            str = ""
                            str = "\(thoroughfare!), \(sublocality!), \(country!)"
                        } else if sublocality != nil && locality != nil && country != nil {
                            str = ""
                            str = "\(sublocality!), \(locality!), \(country!)"
                        } else if thoroughfare != nil && country != nil {
                            str = ""
                            str = "\(thoroughfare!), \(country!)"
                        } else if locality != nil && country != nil {
                            str = ""
                            str = "\(locality!), \(country!)"
                        }else {
                            str = ""
                            let a = addressObj.lines
                            for k in 0..<a!.count {
                                if k < (a!.count - 1) {
                                    str = str! + (a![k] ) + ",  "
                                } else {
                                    str = str! + (a![k] )
                                }
                            }
                            break
                        }
                    }
                    print(str ?? "address")
                    
                    self.addressLBL.text = str
                }
            }
        })
    }
}

extension AddRestrictedLocationViewController: GMSAutocompleteViewControllerDelegate {

    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name ?? "No name")")
        print("Place address: \(place.formattedAddress ?? "No address")")
        print("Place ID: \(place.placeID ?? "No ID")")
        
        let cameraUpdate = GMSCameraUpdate.setTarget(place.coordinate, zoom: 15)
        mapView.animate(with: cameraUpdate)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.addressLBL.text = place.formattedAddress ?? "No address"
        }
        
        dismiss(animated: true, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
        dismiss(animated: true, completion: nil)
    }

    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}
