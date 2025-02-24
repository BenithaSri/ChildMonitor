//
//  MapsViewController.swift
//  ChildCareApp
//
//  Created by Piyush on 18/02/2025.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapsViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    var location = CLLocation()
    var selectedLocation: CLLocation?
    
    
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

    @IBAction func current(_ sender: Any) {
        
        self.initializeLocationManager()
    }
}

extension MapsViewController: CLLocationManagerDelegate {
    
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

extension MapsViewController: GMSMapViewDelegate {
    
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
                    
                    //self.addressTF.text = str
                }
            }
        })
    }
}
