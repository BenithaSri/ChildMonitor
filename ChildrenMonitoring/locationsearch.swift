// MARK: - Search Location
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            
            let mapItem = response.mapItems.first
            if let coordinate = mapItem?.placemark.coordinate {
                self.addPinToMap(location: coordinate, title: searchText)
            }
        }
    }
   
    
    // MARK: - Add Pin to Map
    func addPinToMap(location: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = title
        mapView.addAnnotation(annotation)
        mapView.setRegion(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
    }
    
    // MARK: - Add to Favorites
    @IBAction func addToFavorites(_ sender: Any) {
        guard let locationName = searchBar.text, !locationName.isEmpty else { return }
        
        if !favoriteLocations.contains(locationName) {
            favoriteLocations.append(locationName)
            UserDefaults.standard.set(favoriteLocations, forKey: "FavoriteLocations")
            favoritesTableView.reloadData()
        }
    }
    
    // MARK: - Location Updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        let coordinate = userLocation.coordinate
        addPinToMap(location: coordinate, title: "Your Location")
    }
}
