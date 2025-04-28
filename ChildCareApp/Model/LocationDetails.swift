//
//  LocationDetails.swift
//  ChildCareApp
//
//  Created by Benitha on 01/03/2025.
//

import Foundation
import UIKit

// Struct to handle location-related API requests using Google Maps APIs
struct LocationDetails {
    
    // Private key for Google Maps API, assumed to be defined elsewhere
    private var key = mapKey
    
    /// Creates a request for Google Places Autocomplete API
    /// - Parameters:
    ///   - searchString: Base search text (user input)
    ///   - text: Additional text to append to the search
    /// - Returns: A configured NSMutableURLRequest for autocomplete
    func getRequest(searchString: String, text: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest()
        request.cachePolicy = .useProtocolCachePolicy
        
        // Constructing the URL for Places Autocomplete API
        let url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\((searchString + text as NSString).addingPercentEscapes(using: String.Encoding.utf8.rawValue) ?? "")&language=en&key=\(key)"
        
        request.url = URL(string: url)
        request.timeoutInterval = 60.0 // Setting timeout for request
        
        return request
    }
    
    /// Creates a request for Google Place Details API
    /// - Parameter place: Place ID obtained from autocomplete API
    /// - Returns: A configured NSMutableURLRequest for place details
    func getLocationDetail(place: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest()
        request.cachePolicy = .useProtocolCachePolicy
        
        // Constructing the URL for Place Details API
        let url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place)&key=\(key)"
        
        request.url = URL(string: url)
        request.timeoutInterval = 60.0 // Setting timeout for request
        
        return request
    }
    
    /// Converts raw Data into a NSDictionary parsed from JSON
    /// - Parameter data: Data object from URL response
    /// - Returns: Parsed JSON as NSDictionary if successful, otherwise nil
    func jsonValue(_ data: Data?) -> NSDictionary? {
        var decodedString: String? = nil
        if let data = data {
            // Attempting to decode data into a UTF-8 string
            decodedString = String(data: data, encoding: .utf8)
        }
        
        let jsonData = decodedString?.data(using: .utf8)
        
        var allKeys: Any? = nil
        do {
            // Attempting to parse JSON data
            if let jsonData = jsonData {
                allKeys = try JSONSerialization.jsonObject(with: jsonData, options: .init())
            }
        } catch {
            // Silently catching errors (no action taken)
        }
        
        let dict = allKeys as? NSDictionary
        return dict
    }
}
