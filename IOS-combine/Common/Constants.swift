//
//  Constants.swift
//  IOS-combine
//
//  Created by usama farooq on 31/08/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation

struct Constants {
    static let presence = "emitter/presence/"
    
    //MARK: Key Constants
    static let usernameKey = "username"
    static let idKey = "id"
    static let messageKey = "message"
    static let topicKey = "topic"
    static let fileKey = "fileType"
    static let mediaType = "type"
    static let date = "date"
    
    //MARK: VDOtok Constants
    static let Request = "request"
    static let Register = "register"
    static let Wormhole = "wormhole"
}

struct AuthenticationConstants {
    static let TENANTSERVER = "s-tenant.vdotok.dev"
    static let PROJECTID = "7R1VTG"
}

struct AppsGroup {
    static let  APP_GROUP = "group.com.norgic.combined.broadcast"
    static let SCREEN_SHARE_PREFERED_EXTENSION = "com.norgic.ios-combinedapp.ScreenShare"
}
