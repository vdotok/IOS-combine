//
//  ChannelEntity.swift
//  IOS-combine
//
//  Created by usama farooq on 31/08/2021.
//

import Foundation
import iOSSDKConnect

struct GroupResponse: Codable {
    let groups: [Group]?
    let message: String
    let processTime, status: Int
    

    enum CodingKeys: String, CodingKey {
        case groups, message
        case processTime = "process_time"
        case status
        
    }
}
struct Group: Codable {
    let adminID, autoCreated: Int
    let channelKey, channelName, createdDatetime: String
    var groupTitle: String
    let id: Int
    let participants: [Participant]

    enum CodingKeys: String, CodingKey {
        case adminID = "admin_id"
        case autoCreated = "auto_created"
        case channelKey = "channel_key"
        case channelName = "channel_name"
        case createdDatetime = "created_datetime"
        case groupTitle = "group_title"
        case id, participants
    }
}



// MARK: - Participant
struct Participant: Codable {
    let colorCode: String
    let colorID: Int
    let email, fullName, refID: String
    let userID: Int

    enum CodingKeys: String, CodingKey {
        case colorCode = "color_code"
        case colorID = "color_id"
        case email
        case fullName = "full_name"
        case refID = "ref_id"
        case userID = "user_id"
    }
}

enum CellType {
    case incomingText
    case outGoingText
    case incomingAttachment
    case outgoingAttachment
    case incomingAudio
    case outgoingAudio
    case incomingImage
    case outGoingImage
}
enum SDKType {
    case stream
    case chat
}

enum MediaType: Int {
    case image
    case audio
    case video
    case file
}

class ReceiptModel: Receipt,Codable {
    var receiptType: Int
    var key: String
    var date: Double
    var messageId: String
    var from: String
    var to: String
    
    init(type: Int, key: String, date: Double, messageId: String, from: String, topic: String) {
        self.receiptType = type
        self.key = key
        self.date = date
        self.messageId = messageId
        self.from = from
        self.to = topic
    }
}

extension ReceiptType {
    func toImage() -> String? {
        switch self {
        case .sent:
            return ""
        case .delivered:
            return ""
        case .seen:
            return "Read"
        }
    }
}

struct TempGroup {
    let group: Group
    let unReadMessageCount: Int
    let lastMessage: String
    let presentParticipant: Int
}

class ChatMessage {
    let id: String
    let sender: String
    let content: String
    var status: ReceiptType
    var fileType: URL?
    var mediaType: MediaType?
    var date: UInt64
    
    
    init(id: String, sender: String, content: String, status: ReceiptType, fileType: URL? = nil, mediaType: MediaType? = nil, date: UInt64) {
        self.id = id
        self.sender = sender
        self.content = content
        self.status = status
        self.fileType = fileType
        self.mediaType = mediaType
        self.date = date

    }
}

struct AuthenticateResponse: Codable {
    let mediaServerMap: ServerMap
    let message: String
    let messagingServerMap: ServerMap
    let processTime, status: Int

    enum CodingKeys: String, CodingKey {
        case mediaServerMap = "media_server_map"
        case message
        case messagingServerMap = "messaging_server_map"
        case processTime = "process_time"
        case status
    }
}

// MARK: - ServerMap
struct ServerMap: Codable {
    let completeAddress: String
    let endPoint: String?
    let host, port, serverMapProtocol: String

    enum CodingKeys: String, CodingKey {
        case completeAddress = "complete_address"
        case endPoint = "end_point"
        case host, port
        case serverMapProtocol = "protocol"
    }
}
