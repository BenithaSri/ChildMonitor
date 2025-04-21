//
//  ChildHomeViewController.swift
//  ChildCareApp
//
//  Created by Benitha on 18/02/2025.
//

import UIKit
import GoogleMaps
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

class ChildHomeViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLBL: UILabel!
    
    var locationManager = CLLocationManager()
    var selectedLocation: CLLocation?
    var parentID = ""
    var childDocID = ""
    var locationTimer: Timer?
    
    var restrictedLocations: [RestrictedLocationModel] = []
    var isMapDragged = false
    
    var isAlertAlreadyShown = false
    
    // Device Mapping Dictionary
    let modelMapping: [String: String] = [
        "iPhone10,3": "iPhone X",
        "iPhone10,6": "iPhone X",
        "iPhone11,8": "iPhone XR",
        "iPhone11,2": "iPhone XS",
        "iPhone11,6": "iPhone XS Max",
        "iPhone12,1": "iPhone 11",
        "iPhone12,3": "iPhone 11 Pro",
        "iPhone12,5": "iPhone 11 Pro Max",
        "iPhone13,1": "iPhone 12 mini",
        "iPhone13,2": "iPhone 12",
        "iPhone13,3": "iPhone 12 Pro",
        "iPhone13,4": "iPhone 12 Pro Max",
        "iPhone14,4": "iPhone 13 mini",
        "iPhone14,5": "iPhone 13",
        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeMap()
        self.initializeLocationManager()
        
        self.getChildData()
        locationTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(updateChildLocation), userInfo: nil, repeats: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            
            self.updateChildLocation()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            
            self.getChildRestrictedLocations()
        }
        
        self.listenForMessages()
        
        // Do any additional setup after loading the view.
    }
    
    func listenForMessages() {
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let myTimeStamp = appLaunchTime
        
        let db = Firestore.firestore()
        db.collection("Chats")
            .whereField("receiver_id", isEqualTo: id)
            .whereField("isRead", isEqualTo: false)
          .addSnapshotListener { (querySnapshot, error) in
              guard let snapshot = querySnapshot else { return }
              for diff in snapshot.documentChanges {
                  if diff.type == .added {
                      let messageData = diff.document.data()
                      if let timestamp = messageData["timestamp"] as? Double, timestamp > myTimeStamp {
                          self.showNotification(for: messageData)
                      }
                  }
              }
          }
    }
    
    func showNotification(for messageData: [String: Any]) {
        let content = UNMutableNotificationContent()
        content.title = messageData["sender_name"] as? String ?? "New Message"
        content.body = messageData["message"] as? String ?? "You have a new message"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error)")
            }
        }
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
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 10
        locationManager.headingFilter = CLLocationDegrees(1)
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }
    
    func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let identifier = withUnsafeBytes(of: &systemInfo.machine) { buffer in
            buffer.compactMap { $0 != 0 ? String(UnicodeScalar(UInt8($0))) : nil }.joined()
        }
        
        return modelMapping[identifier] ?? identifier // Return model name if found, else return identifier
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getChildData() -> Void {
        
        let database = Firestore.firestore()
        let id = Auth.auth().currentUser?.uid ?? ""
        
        let docRef = database.collection("Childs")
            .whereField("id", isEqualTo: id)
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                
                print("Error getting documents: \(err)")
                
            } else {
                
                if querySnapshot?.documents.count ?? 0 > 0 {
                    
                    let document = querySnapshot!.documents[0]
                    
                    self.childDocID = document.documentID
                    let data = document.data()
                    self.parentID = data["parent_id"] as? String ?? ""
                    
                    self.saveDeviceForUser()
                }
            }
        }
    }
    
    
    func saveDeviceForUser() {
        
        let db = Firestore.firestore()
        let id = Auth.auth().currentUser?.uid ?? ""
        // Get the unique device ID
       
        // Reference to Firestore collection
        let deviceRef = db.collection("Devices")
            .whereField("child_id", isEqualTo: id)
            .whereField("model", isEqualTo: UIDevice.current.model)
        
        deviceRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                
                print("Error getting documents: \(err)")
                
            } else {
                
                if querySnapshot?.documents.count ?? 0 == 0 {
                    
                    self.addDevice()
                }
            }
        }
    }
    
    @objc func updateChildLocation() -> Void {
        
        if childDocID != "" {
            
            let path = String(format: "%@", "Childs")
            let db = Firestore.firestore()
         
            let params = ["lat": selectedLocation?.coordinate.latitude ?? 0.0,
                          "lng": selectedLocation?.coordinate.longitude ?? 0.0,
                          "address": self.addressLBL.text ?? ""
                
            ] as [String : Any]
            
            db.collection(path).document(childDocID).updateData(params) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
    }
    
    func addDevice() {
        
        let path = String(format: "%@", "Devices")
        let db = Firestore.firestore()
        
        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else { return }
        let id = Auth.auth().currentUser?.uid ?? ""
        let name = Auth.auth().currentUser?.displayName ?? ""
        
        let deviceData: [String: Any] = [
            "child_name": name,
            "parent_id": self.parentID,
            "child_id": id,
            "deviceID": deviceID,
            "model": UIDevice.current.model,
            "systemVersion": UIDevice.current.systemVersion,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection(path).document().setData(deviceData) { err in
            if let _ = err {
                
            } else {
                
            }
        }
    }
    
    @IBAction func current(_ sender: Any) {
        
        self.isMapDragged = false
        self.initializeLocationManager()
    }
    
    func getChildRestrictedLocations() {
        
        let database = Firestore.firestore()
        let id = Auth.auth().currentUser?.uid ?? ""
        
        let docRef = database.collection("Restricted_Locations")
            .whereField("child_id", isEqualTo: id)
        
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                
                print("Error getting documents: \(err)")
                
            } else {
                
                self.restrictedLocations.removeAll()
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let data = document.data()
                    var model = RestrictedLocationModel()
                    
                    model.id = document.documentID
                    model.parent_id = data["parent_id"] as? String ?? ""
                    model.child_id = data["child_id"] as? String ?? ""
                    model.title = data["title"] as? String ?? ""
                    model.address = data["address"] as? String ?? ""
                    model.lat = data["lat"] as? Double ?? 0.0
                    model.lng = data["lng"] as? Double ?? 0.0
                    
                    self.restrictedLocations.append(model)
                }
            }
        }
    }
    
    
    func showAlert() {
        
        let alert = UIAlertController(title: "Warning", message: "You are within 100m of a restricted area!", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


extension ChildHomeViewController: CLLocationManagerDelegate {
    
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
        
        let currentLocation = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (currentLocation?.coordinate.latitude)!, longitude: (currentLocation?.coordinate.longitude)!, zoom: 15.0)
        
        selectedLocation = currentLocation ?? CLLocation(latitude: 0.0, longitude: 0.0)
        
        if restrictedLocations.count > 0 {
            
            for restrictedLocation in self.restrictedLocations {
                let loc = CLLocation(latitude: restrictedLocation.lat ?? 0.0, longitude: restrictedLocation.lng ?? 0.0)
                let distance = currentLocation?.distance(from: loc) ?? 0.0// Distance in meters
                if distance <= 100 {    //can update 
                    
                    if self.isAlertAlreadyShown == false {
                        
                        self.isAlertAlreadyShown.toggle()
                        self.sendNotification()
                    }
                    break
                }
            }
        }
        
        self.mapView?.animate(to: camera)
        //self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed with error: \(error.localizedDescription)")
    }
    
    func sendNotification() -> Void {
        
        let path = String(format: "%@", "Notifications")
        let db = Firestore.firestore()
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let name = Auth.auth().currentUser?.displayName ?? ""
        
        let myTimeStamp = Date().timeIntervalSince1970
        
        let notifData: [String: Any] = [
            "child_name": name,
            "parent_id": self.parentID,
            "child_id": id,
            "type": 3,
            "lat": selectedLocation?.coordinate.latitude ?? 0.0,
            "lng": selectedLocation?.coordinate.longitude ?? 0.0,
            "address": self.addressLBL.text ?? "",
            "timestamp": myTimeStamp
        ]
        
        db.collection(path).document().setData(notifData) { err in
            if let _ = err {
                
            } else {
                
            }
        }
    }
}

extension ChildHomeViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        if gesture {
            
            isMapDragged = true
            print("map dragged")
        }else{
            print("map automatic")
        }
    }
    
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
                
                if self.isMapDragged {
                    
                    return
                }
                
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
