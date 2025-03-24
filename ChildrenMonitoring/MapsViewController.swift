//
//  MapsViewController.swift
//  ChildCareApp
//
//  Created by Piyush on 18/02/2025.
//

import UIKit
import GoogleMaps
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import GooglePlaces

class MapsViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLBL: UILabel!
    
    var autocompleteController = GMSAutocompleteViewController()
    
    var locationManager = CLLocationManager()
    var location = CLLocation()
    var selectedLocation: CLLocation?
    
    let model = LocationDetails()
    var allChildsList: [ChildModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeMap()
        self.initializeLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getMyChilds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationManager.stopUpdatingLocation()
        
    }
    
    func getMyChilds() -> Void {
        
        let database = Firestore.firestore()
        let id = Auth.auth().currentUser?.uid ?? ""
        
        let docRef = database.collection("Childs")
            .whereField("parent_id", isEqualTo: id)
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                
                print("Error getting documents: \(err)")
                
            } else {
                
                self.allChildsList.removeAll()
                
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let data = document.data()
                    
                    var child = ChildModel()
                    child.id = data["id"] as? String ?? ""
                    child.parent_id = data["parent_id"] as? String ?? ""
                    child.parent_name = data["parent_name"] as? String ?? ""
                    child.name = data["name"] as? String ?? ""
                    child.age = data["age"] as? String ?? ""
                    child.email = data["email"] as? String ?? ""
                    child.image = data["image"] as? String ?? ""
                    child.lat = data["lat"] as? Double ?? 0.0
                    child.lng = data["lng"] as? Double ?? 0.0
                    child.address = data["address"] as? String ?? ""
                    
                    self.allChildsList.append(child)
                }
                
                self.showOnMap()
            }
        }
    }
    
    func showOnMap() -> Void {
        
        self.mapView.clear()
        var bounds = GMSCoordinateBounds()
        
        for child in self.allChildsList {
            
            let position = CLLocationCoordinate2D(latitude: child.lat ?? 0.0,
                                                  longitude: child.lng ?? 0.0)
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: position.latitude,
                                                     longitude: position.longitude)
            marker.title = String(format: "%@ \n%@", child.name ?? "", child.address ?? "")
            marker.map = mapView
            
            // Extend bounds to include this marker's position
            bounds = bounds.includingCoordinate(position)
        }
        
        // Update camera to fit all markers
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
        mapView.animate(with: update)
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
    
    
    @IBAction func address(_ sender: Any) {
        
        //self.searchAddress()
        
        let autocompleteVC = GMSAutocompleteViewController()
        autocompleteVC.delegate = self
        present(autocompleteVC, animated: true, completion: nil)
        
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
                    
                    self.addressLBL.text = str
                }
            }
        })
    }
}

//
//extension MapsViewController {
//    
//    @objc func addressSelected(place: GMSPlace) -> Void {
//        
//        let request = model.getLocationDetail(place: "\(place.placeID ?? "")")
//        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: .main) { [self] (response, data, error) in
//            if data == nil {
//                print("ignore")
//                
//            }else {
//                let dic = model.jsonValue(data)
//                let result = dic?.value(forKey: "result") as? NSDictionary ?? NSDictionary()
//                let geometry = result.value(forKey: "geometry") as? NSDictionary ?? NSDictionary()
//                let location = geometry.value(forKey: "location") as? NSDictionary ?? NSDictionary()
//                
//                let lat_Str = "\(String(describing: location["lat"] ?? "0.0"))"
//                let lng_Str = "\(String(describing: location["lng"] ?? "0.0"))"
//                
//                let lat = Double(lat_Str)
//                let lng = Double(lng_Str)
//                
//                let camera = GMSCameraPosition.camera(withLatitude: lat ?? 0.0,
//                                                      longitude: lng ?? 0.0,
//                                                      zoom: 15.0)
//                self.mapView?.animate(to: camera)
//                
//                //delegate?.didSelectAddress(lat: lat ?? 0.00, lng: lng ?? 0.00)
//                //self.navigationController?.popViewController(animated: true)
//            }
//        }
//    }
//    
//    func searchAddress() -> Void {
//        
//        autocompleteController.delegate = self
//        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.name.rawValue) |
//                                                                   UInt(GMSPlaceField.placeID.rawValue)))
//        autocompleteController.placeFields = fields
//        
//        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//
//        // Specify a filter.
//        let filter = GMSAutocompleteFilter()
//        //filter.type = .city
//        filter.country = "USA"
//        autocompleteController.autocompleteFilter = filter
//        
//        // Display the autocomplete view controller.
//        present(autocompleteController, animated: true, completion: nil)
//    }
//}
//
//extension MapsViewController: GMSAutocompleteViewControllerDelegate {
//    
//    // Handle the user's selection.
//    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//        
//        perform(#selector(addressSelected(place:)), with: place, afterDelay: 0.2)
//        dismiss(animated: true, completion: nil)
//    }
//    
//    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
//        // TODO: handle the error.
//        print("Error: ", error.localizedDescription)
//    }
//    
//    // User canceled the operation.
//    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    // Turn the network activity indicator on and off again.
//    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//    }
//    
//    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
//}

extension MapsViewController: GMSAutocompleteViewControllerDelegate {
    
    // MARK: - GMSAutocompleteViewControllerDelegate Methods
        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            print("Selected Place: \(place.name ?? ""), Address: \(place.formattedAddress ?? ""), Place ID: \(place.placeID ?? "No ID")")

            // Manually fetch place details
            fetchPlaceDetails(placeID: place.placeID ?? "")

            dismiss(animated: true, completion: nil)
        }
        
        func fetchPlaceDetails(placeID: String) {
            let placesClient = GMSPlacesClient.shared()
            
            placesClient.fetchPlace(fromPlaceID: placeID, placeFields: [.name, .formattedAddress, .coordinate], sessionToken: nil) { (place, error) in
                if let error = error {
                    print("Error fetching place details: \(error.localizedDescription)")
                    return
                }
                if let place = place {
                    print("Fetched Place Details: \(place.name ?? ""), \(place.formattedAddress ?? "")")
                }
            }
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
            print("Google Places Error: \(error.localizedDescription)")
        }

        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            dismiss(animated: true, completion: nil)
        }
}
