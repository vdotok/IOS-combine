//
//  ChatInteractor.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import Foundation
import iOSSDKConnect

final class ChatInteractor {
    
    
    var mqttClient: ChatClient?
    var user: User
    var group: Group
    var broadcastData: BroadcastData?
    var messages: [ChatMessage]
    weak var presenter: ChatInteractorToPresenter? {didSet {
        presenter?.updateGroup(with: group, user: user, messages: messages)
    }}
    
    init(mqttClient: ChatClient, user: User, group: Group, messages:[ChatMessage]) {
        self.mqttClient = mqttClient
        self.user = user
        self.group = group
        self.messages = messages
        setupDelegates()
    }
    
}

// MARK: - Extensions -

extension ChatInteractor: ChatInteractorInterface {
    
    func setupDelegates() {
        mqttClient?.setReceiptAcknowledge(receiptAcknowledge: self)
        mqttClient?.setReceiptDelegate(receiptDelegate: self)
    
    }
    
    func sendMessage(with text: String) {
        let now = Date()
        let timeInterval = now.millisecondsSince1970
        let message = MessageModel(id: UUID().uuidString,
                                   to: group.channelName,
                                   key: group.channelKey,
                                   from: user.refID,
                                   content: text.prefix(400).description,
                                   size: 0,
                                   isGroupMessage: false,
                                   status: 0,
                                   date: timeInterval)
        mqttClient?.publish(message: message)
        dispatchPackage(start: false)
    }
    
    func dispatchPackage(start: Bool) {
        if start {
            let messageModel = MessageModel(id: UUID().uuidString,
                                            to: group.channelName,
                                            key: group.channelKey,
                                            from: user.refID,
                                            type: "typing",
                                            content: "1",
                                            size: 0,
                                            isGroupMessage: false,
                                            status: 0,
                                            date: 1622801248314)
            mqttClient?.publish(message: messageModel)
        } else {
            let messageModel = MessageModel(id: UUID().uuidString,
                                            to: group.channelName,
                                            key: group.channelKey,
                                            from: user.refID,
                                            type: "typing",
                                            content: "0",
                                            size: 0,
                                            isGroupMessage: false,
                                            status: 0,
                                            date: 1622801248314)
            mqttClient?.publish(message: messageModel)
        }
    }
    
    func sendSeenMessage(message: ChatMessage, row: Int) {
        
        if message.status == .delivered  {
            let receipt = ReceiptModel(type: ReceiptType.seen.rawValue,
                                       key: group.channelKey, date: 1622801248314,
                                       messageId: message.id,
                                       from: user.fullName,
                                       topic: group.channelName)
            if user.fullName != message.sender {
                self.messages[row].status = .seen
            }
            self.send(receipt: receipt, status: .seen, isMyMessage: user.fullName == message.sender)
        }
        
    }
    
    func receivedMessage(userInfo: [String: AnyObject]) {
        let content = userInfo[Constants.messageKey] as! String
        let username = userInfo[Constants.usernameKey] as! String
        let id = userInfo[Constants.idKey] as? String ?? UUID().uuidString
        let fileType = userInfo[Constants.fileKey] as? URL
        let mediaType = userInfo[Constants.mediaType] as? Int
        let date = userInfo[Constants.date] as! UInt64
        
        
        guard let topic = userInfo[Constants.topicKey] as? String,
              topic == group.channelName
        else { return }
        if content.contains("left") {

            return
        } else if content.contains("joined"){

            return
        }
        if content.isEmpty {

            if let mediaType = mediaType {
                messages.append(ChatMessage(id: id, sender: username, content: "", status: user.refID == username ? .sent : .delivered, fileType: fileType, mediaType: MediaType(rawValue: mediaType), date: date))
                ProgressHud.hide()
            } else {
                messages.append(ChatMessage(id: id, sender: username, content: "", status: .delivered, fileType: fileType, date: date))
            }
           
            presenter?.update(messages: messages)
           // chatOutput?(.reload)
            
            return
        }

        let chatMessage = ChatMessage(id: id,sender: username, content: content, status: user.refID == username ? .sent :.delivered, date: date)
        messages.append(chatMessage)
        presenter?.update(messages: messages)
      //  chatOutput?(.reload)
        
    }
    
    func publish(file data: Data, with ext: String, type: Int) {
        let now = Date()
        let timeInterval = now.millisecondsSince1970
        mqttClient?.publish(file: data, fileExt: ext, topic: group.channelName, key: group.channelKey, from: user.refID, type: type, date: timeInterval)
        ProgressHud.show()
    }
    func itemAt(row: Int) -> (ChatMessage,CellType) {
        
        if messages[row].sender != user.refID && messages[row].content == "" {
            
            switch messages[row].mediaType {
            case .image:
                return (messages[row], .incomingImage)
            case .file:
                return (messages[row], .incomingAttachment)
            case .video:
                return (messages[row], .incomingAttachment)
            case .audio:
                return (messages[row], .incomingAttachment)
            default:
                break
            }
           
        } else if messages[row].sender == user.refID && messages[row].content == ""  {
            
            switch messages[row].mediaType {
            case .image:
                return (messages[row], .outGoingImage)
            case .file:
                return (messages[row], .outgoingAttachment)
            case .video:
                return (messages[row], .outgoingAttachment)
            case .audio:
                return (messages[row], .outgoingAttachment)
            default:
                break
            }
        }
        if messages[row].sender == user.refID {
            return (messages[row], .outGoingText)
        }else {
            return (messages[row], .incomingText)
        }
    }
}

extension ChatInteractor: ReceiptAcknowledge {
    func didReceive(receipt: Receipt, status: ReceiptType) {
        guard user.fullName != receipt.from, let messageIndex = self.messages.firstIndex(where: {$0.id == receipt.messageId}) else {return}
        if  user.refID != receipt.from {
            messages[messageIndex].status = status
           // self.output?(.reloadCell(indexPath: IndexPath(row: messageIndex, section: 0)))
            self.presenter?.reloadCell(with: IndexPath(row: messageIndex, section: 0))
        }
    }
    }
    
    


extension ChatInteractor: ReceiptDelegate {
    func send(receipt: Receipt, status: ReceiptType, isMyMessage: Bool) {
        guard !isMyMessage else {return}
        mqttClient?.publish(receipt: receipt)
        print("send receipt \(status) \(receipt.from)")
    }
    
    
}

extension ChatInteractor {
    func moveToCallingView(broadcastData: BroadcastData) {
        let groupId = group.id
        
        let userInfo: [AnyHashable: Any]? = ["callType": NotifyCallType.cameraBroadcast.callType,
                                             "groupId": groupId,
                                             "broadcastData": broadcastData,
                                             "participants": group.participants]
        NotificationCenter.default.post(name: NotifyCallType.notificationName, object: userInfo)
    }
    
    func moveToSSView(broadcastData: BroadcastData) {
        let groupId = group.id
        let userInfo: [AnyHashable: Any]? = ["callType": NotifyCallType.broadcast.callType,
                                             "groupId": groupId,
                                             "broadcastData": broadcastData,
                                             "participants": group.participants]
        NotificationCenter.default.post(name: NotifyCallType.notificationName, object: userInfo)
    }
}
