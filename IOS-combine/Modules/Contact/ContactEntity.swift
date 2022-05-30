//
//  ContactEntity.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation

enum ContactNavigationOptions {
    case chat
    case createGroup
    case audioCall
    case videoCall
}

struct AllUsersResponse: Codable {
    let message: String
    let processTime, status: Int
    let users: [User]?

    enum CodingKeys: String, CodingKey {
        case message
        case processTime = "process_time"
        case status, users
    }
}

// MARK: - User

struct User: Codable {
    let email, fullName, refID: String
    let userID: Int

    enum CodingKeys: String, CodingKey {
        case email
        case fullName = "full_name"
        case refID = "ref_id"
        case userID = "user_id"
    }
}
struct CreateGroupResponse: Codable {
    let group: Group?
    let message: String
    let processTime, status: Int
    let isalreadyCreated: Bool?

    enum CodingKeys: String, CodingKey {
        case group, message
        case processTime = "process_time"
        case status
        case isalreadyCreated = "is_already_created"
        
    }
}

