import UIKit
import MapKit

// ViewController responsible for handling map-based location search, display, and user interaction
class LocationViewController: UIViewController, UISearchBarDelegate, MKLocalSearchCompleterDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    // MARK: - UI Elements
    
    @IBOutlet weak var map: MKMapView!              // Displays the map and location annotations
    @IBOutlet weak var search: UISearchBar!         // Search bar for entering location queries
    @IBOutlet weak var tableView: UITableView!      // Table view to show search suggestions
    
    // MARK: - Properties
    
    var searchResults: [MKLocalSearchCompletion] = []       // Stores autocomplete search results
    let searchCompleter = MKLocalSearchCompleter()          // Provides autocomplete location suggestions
    let locationManager = CLLocationManager()               // Manages access to the user's current location
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()                   // Configure UI elements
        setupLocationServices()     // Setup and request location services
    }
    
    // MARK: - Setup Methods
    
    /// Sets up UI components and their delegates
    private func setupUI() {
        // Search bar
        search.delegate = self
        search.showsCancelButton = true
        
        // Autocomplete search completer
        searchCompleter.delegate = self
        
        // Map
        map.delegate = self
        
        // TableView for search results
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true  // Initially hidden until user types something
        
        // Ensure search results table appears above map view
        view.bringSubviewToFront(tableView)
        
        // Add "Saved Places" button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Saved Places",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(showSavedLocations))
        
        // Register default marker views for single and clustered annotations
        map.register(MKMarkerAnnotationView.self,
                     forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        map.register(MKMarkerAnnotationView.self,
                     forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    /// Configures and requests user location access
    private func setupLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()  // Ask for permission
        
        // Start location updates if location services are available
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            map.showsUserLocation = true
        }
    }
    
    // MARK: - Navigation
    
    /// Triggered when the "Saved Places" button is tapped
    @objc func showSavedLocations() {
        performSegue(withIdentifier: "ShowSavedLocations", sender: nil)
        printSavedLocations() // Log saved locations to the console
    }
    
    // MARK: - UISearchBarDelegate
    
    /// Updates autocomplete suggestions as the user types
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
        tableView.isHidden = searchText.isEmpty
    }
    
    /// Initiates a search when the search button is tapped
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        searchLocation(query: query)
        searchBar.resignFirstResponder()
        tableView.isHidden = true
    }
    
    /// Cancels search input and clears suggestions
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchResults.removeAll()
        tableView.reloadData()
        tableView.isHidden = true
    }
    
    // MARK: - MKLocalSearchCompleterDelegate
    
    /// Called when autocomplete suggestions are updated
    func localSearchCompleterDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableView.reloadData()
        tableView.isHidden = searchResults.isEmpty
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    /// Returns number of suggestions in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    /// Configures each cell in the search results table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        return cell
    }
    
    /// Handles selection of a search result from the table
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        searchLocation(query: result.title)
        tableView.isHidden = true
        search.resignFirstResponder()
    }
    
    // MARK: - Location Search
    
    /// Performs a local search based on the provided query string
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
            
            // Remove previous pins before showing new location
            self.map.removeAnnotations(self.map.annotations)
            
            // Create and add annotation for the searched location
            let annotation = MKPointAnnotation()
            annotation.coordinate = item.placemark.coordinate
            annotation.title = item.name
            annotation.subtitle = item.placemark.title
            self.map.addAnnotation(annotation)
            
            // Center map around the selected location
            let region = MKCoordinateRegion(center: item.placemark.coordinate,
                                            latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
            self.map.setRegion(region, animated: true)
        }
    }
    
    // MARK: - Logging & Utility Methods
    
    /// Logs saved locations from UserDefaults to the console
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
    
    /// Converts a distance value (in meters) into a user-friendly string
    func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return String(format: "%.0f meters", distance)
        } else {
            return String(format: "%.2f km", distance / 1000)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationViewController: CLLocationManagerDelegate {
    
    /// Called when the user's location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Zoom to user's current location
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        map.setRegion(region, animated: true)
        
        // Stop further updates to conserve battery
        locationManager.stopUpdatingLocation()
    }
}
