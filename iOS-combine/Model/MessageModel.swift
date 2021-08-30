//
//  MessageModel.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 28/05/2021.
//

import Foundation
import iOSSDKConnect

class MessageModel: Message {
    var id: String
    var to: String
    var key: String
    var from: String
    var type: String
    var content: String
    var size: Double
    var isGroupMessage: Bool
    var status: Int
    var subtype: Int?
    var date: UInt64
    
    internal init(id: String,
                  to: String,
                  key: String,
                  from: String,
                  type: String = "text",
                  content: String,
                  size: Double,
                  isGroupMessage: Bool,
                  status: Int,
                  subtype: Int? = nil,
                  date: UInt64) {
        self.id = id
        self.to = to
        self.key = key
        self.from = from
        self.type = type
        self.content = content
        self.size = size
        self.isGroupMessage = isGroupMessage
        self.status = status
        self.subtype = subtype
        self.date = date
    }
    
}
