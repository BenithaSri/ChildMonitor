import UIKit
import MapKit

class LocationViewController: UIViewController, UISearchBarDelegate, MKLocalSearchCompleterDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults: [MKLocalSearchCompletion] = []
    let searchCompleter = MKLocalSearchCompleter()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationServices()
    }
    
    private func setupUI() {
        search.delegate = self
        search.showsCancelButton = true
        searchCompleter.delegate = self
        map.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        
        view.bringSubviewToFront(tableView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Saved Places",
                                                          style: .plain,
                                                          target: self,
                                                          action: #selector(showSavedLocations))
        
        map.register(MKMarkerAnnotationView.self,
                    forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        map.register(MKMarkerAnnotationView.self,
                    forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    private func setupLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            map.showsUserLocation = true
        }
    }
    
    @objc func showSavedLocations() {
        performSegue(withIdentifier: "ShowSavedLocations", sender: nil)
        printSavedLocations() // Print locations when viewing saved places
    }
    
    // MARK: - Search Bar Delegate Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
        tableView.isHidden = searchText.isEmpty
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        searchLocation(query: query)
        searchBar.resignFirstResponder()
        tableView.isHidden = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.isHidden = true
        searchResults.removeAll()
        tableView.reloadData()
    }
    
    // MARK: - Console Logging Methods
    func printSavedLocations() {
        let savedLocations = UserDefaults.standard.array(forKey: "savedLocations") as? [[String: Any]] ?? []
        print("\n=== Saved Locations ===")
        if savedLocations.isEmpty {
            print("No locations saved yet.")
        }
        savedLocations.enumerated().forEach { (index, location) in
            print("\nLocation #\(index + 1)")
            print("Name: \(location["name"] ?? "Unknown")")
            print("Latitude: \(location["latitude"] ?? 0)")
            print("Longitude: \(location["longitude"] ?? 0)")
            print("Distance: \(formatDistance(location["distance"] as? Double ?? 0))")
            if let timestamp = location["timestamp"] as? TimeInterval {
                let date = Date(timeIntervalSince1970: timestamp)
                print("Saved on: \(date)")
            }
            print("------------------------")
        }
    }
    
    func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return String(format: "%.0f meters", distance)
        } else {
            return String(format: "%.2f km", distance/1000)
        }
    }
    
    // MARK: - MKLocalSearch Completer Delegate Method
    func localSearchCompleterDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableView.reloadData()
        tableView.isHidden = searchResults.isEmpty
    }
    
    // MARK: - Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        searchLocation(query: result.title)
        tableView.isHidden = true
        search.resignFirstResponder()
    }
    
    // MARK: - Map View Delegate Methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let identifier = "LocationPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let saveButton = UIButton(type: .system)
            saveButton.setTitle("Save Location", for: .normal)
            saveButton.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
            annotationView?.rightCalloutAccessoryView = saveButton
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation else { return }
        
        saveLocation(name: annotation.title ?? "Unknown Location",
                    coordinate: annotation.coordinate)
        
        let alert = UIAlertController(title: "Success",
                                    message: "Location saved successfully!",
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Search Location Method
    func searchLocation(query: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error searching for location: \(error.localizedDescription)")
                return
            }
            
            guard let response = response, let item = response.mapItems.first else { return }
            
            self.map.removeAnnotations(self.map.annotations)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = item.placemark.coordinate
            annotation.title = item.name
            annotation.subtitle = item.placemark.title
            self.map.addAnnotation(annotation)
            
            let region = MKCoordinateRegion(center: item.placemark.coordinate,
                                          latitudinalMeters: 1000,
                                          longitudinalMeters: 1000)
            self.map.setRegion(region, animated: true)
        }
    }
    
    // MARK: - Save Location Method
    func saveLocation(name: String?, coordinate: CLLocationCoordinate2D) {
        guard let name = name else { return }
        
        var savedLocations = UserDefaults.standard.array(forKey: "savedLocations") as? [[String: Any]] ?? []
        
        var distance: CLLocationDistance?
        if let userLocation = locationManager.location {
            let locationCoordinate = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            distance = userLocation.distance(from: locationCoordinate)
        }
        
        let location: [String: Any] = [
            "name": name,
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "timestamp": Date().timeIntervalSince1970,
            "distance": distance ?? 0
        ]
        
        savedLocations.append(location)
        UserDefaults.standard.set(savedLocations, forKey: "savedLocations")
        
        // Print saved locations to console
        printSavedLocations()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                      latitudinalMeters: 1000,
                                      longitudinalMeters: 1000)
        map.setRegion(region, animated: true)
        
        locationManager.stopUpdatingLocation()
    }
}



// Method to search for a location and update the map
    func searchLocation(query: String) {
        let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            
            let search = MKLocalSearch(request: request)
            
            search.start { (response, error) in
                if let error = error {
                    print("Error searching location: \(error.localizedDescription)")
                    self.showAlert(message: "Error searching location: \(error.localizedDescription)")
                    return
                }
                
                if let response = response, let item = response.mapItems.first {
                    let coordinate = item.placemark.coordinate
                    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                    
                    self.mapKit.setRegion(region, animated: true)
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = item.name
                    self.mapKit.addAnnotation(annotation)
                    
                    // Store last searched annotation
                    self.lastSearchedAnnotation = annotation
                }
            }
    }
