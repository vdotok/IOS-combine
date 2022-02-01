//
//  AllGroupRequest.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 06/05/2021.
//

import Foundation

struct AllGroupRequest: Codable, APIRequest {
    
    func getMethod() -> RequestType {
        .GET
    }
    
    func getPath() -> String {
        "AllGroups"
    }
    
    func getBody() -> Data? {
        return nil
    }
    
}
