//
//  ChildModel.swift
//  ChildCareApp
//
//  Created by Benitha on 07/02/2025.
//

struct ChildModel: Codable {
    
    var id: String?
    var parent_id: String?
    var parent_name: String?
    var name: String?
    var age: String?
    var email: String?
    var image: String?
    var lat: Double?
    var lng: Double?
    var address: String?
    var hasUnreadMessages: Bool?
    
    init() {}
}
