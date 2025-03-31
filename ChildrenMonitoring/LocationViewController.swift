import UIKit
import MapKit

// ViewController responsible for handling map-based location search and display
class LocationViewController: UIViewController, UISearchBarDelegate, MKLocalSearchCompleterDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    // UI Elements
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // Stores search results
    var searchResults: [MKLocalSearchCompletion] = []
    let searchCompleter = MKLocalSearchCompleter() // Autocomplete search suggestions
    let locationManager = CLLocationManager() // Manages user location updates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationServices()
    }
    
    // Setup UI components and delegates
    private func setupUI() {
        search.delegate = self
        search.showsCancelButton = true
        searchCompleter.delegate = self
        map.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true // Hide search results initially
        
        view.bringSubviewToFront(tableView) // Ensure search results appear above map
        
        // Add a navigation button to allow users to view saved locations
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Saved Places",
                                                          style: .plain,
                                                          target: self,
                                                          action: #selector(showSavedLocations))
        
        // Register annotation views for map markers
        map.register(MKMarkerAnnotationView.self,
                    forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        map.register(MKMarkerAnnotationView.self,
                    forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    // Setup location services and request permission
    private func setupLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        // Start updating location if services are enabled
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            map.showsUserLocation = true
        }
    }
    
    // Show saved locations when navigation button is tapped
    @objc func showSavedLocations() {
        performSegue(withIdentifier: "ShowSavedLocations", sender: nil)
        printSavedLocations() // Print saved locations to console
    }
    
    // MARK: - Search Bar Delegate Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText // Update autocomplete suggestions
        tableView.isHidden = searchText.isEmpty // Hide table if no text is entered
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        searchLocation(query: query) // Perform search
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
    // Prints saved locations stored in UserDefaults
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
    
    // Converts distance to a human-readable format
    func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return String(format: "%.0f meters", distance)
        } else {
            return String(format: "%.2f km", distance/1000)
        }
    }
    
    // MARK: - MKLocalSearch Completer Delegate Method
    // Updates search results when autocomplete suggestions change
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
    
    // Handles selection of a search result
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        searchLocation(query: result.title) // Search for selected location
        tableView.isHidden = true
        search.resignFirstResponder()
    }
    
    // MARK: - Search Location Method
    // Searches for a location based on user input
    func searchLocation(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error searching for location: \(error.localizedDescription)")
                return
            }
            
            guard let response = response, let item = response.mapItems.first else { return }
            
            // Remove existing annotations before adding new ones
            self.map.removeAnnotations(self.map.annotations)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = item.placemark.coordinate
            annotation.title = item.name
            annotation.subtitle = item.placemark.title
            self.map.addAnnotation(annotation)
            
            // Zoom into the searched location
            let region = MKCoordinateRegion(center: item.placemark.coordinate,
                                            latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
            self.map.setRegion(region, animated: true)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationViewController: CLLocationManagerDelegate {
    // Updates user's location on the map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        map.setRegion(region, animated: true)
        
        locationManager.stopUpdatingLocation() // Stop updates to save battery
    }
}
