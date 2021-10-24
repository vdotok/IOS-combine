//
//  LoginRequest.swift
//  IOS-combine
//
//  Created by usama farooq on 30/08/2021.
//

import Foundation

struct LoginRequest: Codable, APIRequest {
    func getMethod() -> RequestType {
        .POST
    }
    
    func getPath() -> String {
        "Login"
    }
    
    func getBody() -> Data? {
        do {
           return try JSONEncoder().encode(self)
        }
        catch {
            return Data()
        }
    }
    
    let email: String
    let password: String
    var project_id: String = AuthenticationConstants.PROJECTID
    
}
