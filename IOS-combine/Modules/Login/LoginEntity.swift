//
//  LoginEntity.swift
//  IOS-combine
//
//  Created by usama farooq on 30/08/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation

protocol UserProtocol: Codable {
    var userID: Int? { get set }
    var refID: String? { get set }
    var fullName: String? { get set }
}


struct UserResponse: UserProtocol {
    let authToken, authorizationToken: String?
    var fullName: String?
    let message: String
    let processTime: Int?
    var refID: String?
    let mediaServerMap: ServerMap?
    let status: Int?
    var userID: Int?
    let messagingServerMap: ServerMap?
    
    
    enum CodingKeys: String, CodingKey {
        case authToken = "auth_token"
        case authorizationToken = "authorization_token"
        case fullName = "full_name"
        case message
        case processTime = "process_time"
        case refID = "ref_id"
        case status
        case userID = "user_id"
        case mediaServerMap = "media_server_map"
        case messagingServerMap = "messaging_server_map"
    }
}
