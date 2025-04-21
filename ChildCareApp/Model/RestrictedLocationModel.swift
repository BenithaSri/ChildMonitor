//
//  RestrictedLocationModel.swift
//  ChildCareApp
//
//  Created by Benitha on 12/02/2025.
//

struct RestrictedLocationModel: Codable {
    
    var id: String?
    var parent_id: String?
    var child_id: String?
    var title: String?
    var address: String?
    var lat: Double?
    var lng: Double?
    
    init() {}
}
