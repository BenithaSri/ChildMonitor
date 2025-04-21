//
//  UserModel.swift
//  ChildCareApp
//
//  Created by Benitha on 01/03/2025.
//


struct UserModel: Codable {
    
    var id: String?
    var parent_id: String?
    var name: String?
    var email: String?
    var image: String?
    
    init() {}
}
