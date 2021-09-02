//
//  AllUserRequest.swift
//  IOS-combine
//
//  Created by usama farooq on 02/09/2021.
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
