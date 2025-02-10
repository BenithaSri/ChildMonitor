//
//  LocationViewController.swift
//  ChildrenMonitoring
//
//  Created by Yamini Reddy Pesaru on 2/7/25.
//

import UIKit
import MapKit

class LocationViewController: UIViewController,  UISearchBarDelegate  {
    
    @IBOutlet weak var search: UISearchBar!
    
    @IBOutlet weak var mapKit: MKMapView!
    
    @IBOutlet weak var favourites: UIButton!
    
    var favouriteLocations: [MKPointAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Set the delegate for the search bar
               search.delegate = self
    }
    
    
    // Search bar delegate method when search is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Unwrap the search text
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        
        // Perform the search
        searchLocation(query: searchText)
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Method to search for a location and update the map
    func searchLocation(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        // Create a search object with the request
        let search = MKLocalSearch(request: request)
        
        // Perform the search
        search.start { (response, error) in
            if let error = error {
                print("Error searching location: \(error.localizedDescription)")
                self.showAlert(message: "Error searching location: \(error.localizedDescription)")
                return
            }
            
            // If results are found, show the first result on the map
            if let response = response, let item = response.mapItems.first {
                let coordinate = item.placemark.coordinate
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                
                // Set the region of the map
                self.mapKit.setRegion(region, animated: true)
                
                // Optionally, add a pin annotation to the map
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = item.name
                self.mapKit.addAnnotation(annotation)
            }
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
