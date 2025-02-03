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
   
