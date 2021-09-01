//
//  ContactEntity.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//

import Foundation

struct AllUsersResponse: Codable {
    let message: String
    let processTime, status: Int
    let users: [User]

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
