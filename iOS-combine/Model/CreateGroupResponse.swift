//
//  CreateGroupResponse.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 24/05/2021.
//

import Foundation
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

