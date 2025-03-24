//
//  LocationModel.swift
//  ChildCareApp
//
//  Created by Piyush on 12/03/2025.
//

struct LocationModel: Codable {
    
    var id: String?
    var parent_id: String?
    var child_id: String?
    var title: String?
    var address: String?
    var lat: Double?
    var lng: Double?
    var loc_type: Int?
    
    init() {}
}
