//
//  AllUserRequest.swift
//  IOS-combine
//
//  Created by usama farooq on 02/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
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
