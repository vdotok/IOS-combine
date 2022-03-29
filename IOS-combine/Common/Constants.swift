//
//  Constants.swift
//  IOS-combine
//
//  Created by usama farooq on 31/08/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation

struct Constants {
    static let host =  "vte2.vdotok.com"
    static let toTopic = "AACO5B_L67HeJxw7InqZzyiGyb92KyJQ/NorgicStagingChannel/?me=0"
    static let topic = "AACO5B_L67HeJxw7InqZzyiGyb92KyJQ/NorgicStagingChannel/?last=20"
    static let channel = "NorgicStagingChannel/"
    static let key = "AACO5B_L67HeJxw7InqZzyiGyb92KyJQ"
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
    static let TenantId = "U6WM5"
    static let Wormhole = "wormhole"
}

struct AuthenticationConstants {
    static let PROJECTID = "741S88M"
    static let AUTHTOKEN = "53fd514fe5356b103c2c126e6a041466"
    static let HOST = "q-tenant.vdotok.dev"
}

struct AppsGroup {
    static let  APP_GROUP = "group.com.norgic.combined.broadcast"
    static let SCREEN_SHARE_PREFERED_EXTENSION = "com.norgic.ios-combinedapp.ScreenShare"
}
