//
//  AllUserRequest.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 24/05/2021.
//

import Foundation

struct AllUserRequest: APIRequest {
    func getMethod() -> RequestType {
        .POST
    }
    
    func getPath() -> String {
        "AllUsers"
    }
    func getBody() -> Data? {
        return nil
    }
    
    
}
