//
//  DeleteGroupRequest.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 25/06/2021.
//

import Foundation

struct DeleteGroupRequest: APIRequest {
    func getMethod() -> RequestType {
        .POST
    }
    
    func getPath() -> String {
        "DeleteGroup"
    }
    
    let group_id: Int
}
