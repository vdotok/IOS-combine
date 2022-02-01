//
//  CreateGroupRequest.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 24/05/2021.
//

import Foundation


struct CreateGroupRequest: APIRequest {
    
    func getMethod() -> RequestType {
        .POST
    }
    func getPath() -> String {
        "CreateGroup"
    }
    let groupTitle: String
    let participants: [Int]
    var autoCreated: Int? = 0
    enum CodingKeys: String, CodingKey {
        case groupTitle = "group_title"
        case participants
        case autoCreated = "auto_created"
    }
}
