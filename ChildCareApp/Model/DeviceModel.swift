//
//  DeviceModel.swift
//  ChildCareApp
//
//  Created by Benitha on 25/02/2025.
//

struct DeviceModel: Codable {
    
    var id: String?
    var parent_id: String?
    var child_id: String?
    var child_name: String?
    var device: String?
    var os_version: String?
    
    init() {}
}
