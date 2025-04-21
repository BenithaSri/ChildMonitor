//
//  ChatModel.swift
//  ChildCareApp
//
//  Created by Benitha on 07/02/2025.
//

import Foundation



struct Chat{
    
    var id: String?
    var message: String?
    var date: String?
    var sender_id: String?
    var sender_name: String?
    var reveiver_id: String?
    var reveiver_name: String?
}


struct ChatModel {
    
    var date: String?
    var chats: [Chat]?
    
    init() {}
}
