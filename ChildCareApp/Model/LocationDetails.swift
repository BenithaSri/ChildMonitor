//
//  LocationDetails.swift
//  ChildCareApp
//
//  Created by Benitha on 01/03/2025.
//

import Foundation
import UIKit

struct LocationDetails {
    
    private var key = mapKey
    
    func getRequest(searchString: String, text: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest()
        request.cachePolicy = .useProtocolCachePolicy
        //&components=country:pk
        let url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\((searchString + text as NSString).addingPercentEscapes(using: String.Encoding.utf8.rawValue) ?? "")&language=en&key=\(key)"
        
        request.url = URL(string: url)
        request.timeoutInterval = 60.0
        
        return request
    }
    
    func getLocationDetail(place: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest()
        request.cachePolicy = .useProtocolCachePolicy
        
        let url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place)&key=\(key)"
        
        request.url = URL(string: url)
        request.timeoutInterval = 60.0
        
        return request
    }
    
    func jsonValue(_ data: Data?) -> NSDictionary? {
        var decodedString: String? = nil
        if let data = data {
            decodedString = String(data: data, encoding: .utf8)
        }
        let jsonData = decodedString?.data(using: .utf8)
        
        var _: Error?
        var allKeys: Any? = nil
        do {
            if let jsonData = jsonData {
                allKeys = try JSONSerialization.jsonObject(with: jsonData, options: .init())
            }
        } catch _ {
        }
        
        let dict = allKeys as? NSDictionary
        return dict
    }
}
