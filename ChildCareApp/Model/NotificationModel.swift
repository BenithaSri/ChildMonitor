//
//  NotificationModel.swift
//  ChildCareApp
//
//  Created by Benitha on 02/03/2025.
//

struct NotificationModel: Codable {
    
    var id: String?
    var parent_id: String?
    var child_id: String?
    var child_name: String?
    var type: Int?
    var lat: Double?
    var lng: Double?
    var address: String?
    var time: String?
    
    init() {}
}
