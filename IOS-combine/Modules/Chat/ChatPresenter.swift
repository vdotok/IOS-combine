//
//  ChatPresenter.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import Foundation
import iOSSDKConnect

final class ChatPresenter {

    // MARK: - Private properties -

    private unowned let view: ChatViewInterface
    private let interactor: ChatInteractorInterface
    private let wireframe: ChatWireframeInterface
    var mqtt: ChatClient
    var group: Group
    var messages: [ChatMessage] = []
    var user: UserResponse
    var chatOutput: ChatOutput?


    // MARK: - Lifecycle -

    init(
        view: ChatViewInterface,
        interactor: ChatInteractorInterface,
        wireframe: ChatWireframeInterface,
        client: ChatClient,
        group: Group,
        user: UserResponse,
        messages: [ChatMessage]
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.mqtt = client
        self.group = group
        self.messages = messages
        self.user = user
    }
    
    enum Output {
        case reload
    }
    
}

// MARK: - Extensions -

// MARK:
extension ChatPresenter {
    func setupDelegate() {
        mqtt.setReceiptAcknowledge(receiptAcknowledge: self)
        mqtt.setReceiptDelegate(receiptDelegate: self)
    }
    
    func publish(file data: Data, with ext: String, type: Int) {
        let now = Date()
        let timeInterval = now.millisecondsSince1970
        mqtt.publish(file: data, fileExt: ext, topic: group.channelName, key: group.channelKey, from: user.refID!, type: type, date: timeInterval)
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
            } else {
                messages.append(ChatMessage(id: id, sender: username, content: "", status: .delivered, fileType: fileType, date: date))
            }
           
            chatOutput?(.reload)
            
            return
        }

        let chatMessage = ChatMessage(id: id,sender: username, content: content, status: user.refID == username ? .sent :.delivered, date: date)
        messages.append(chatMessage)
        chatOutput?(.reload)
        
    }
    
    func sendSeenMessage(message: ChatMessage, row: Int) {
        
        if message.status == .delivered  {
            let receipt = ReceiptModel(type: ReceiptType.seen.rawValue,
                                       key: group.channelKey, date: 1622801248314,
                                       messageId: message.id,
                                       from: user.fullName!,
                                       topic: group.channelName)
            if user.fullName != message.sender {
                self.messages[row].status = .seen
            }
            self.send(receipt: receipt, status: .seen, isMyMessage: user.fullName == message.sender)
        }
        
    }
  
}




extension ChatPresenter: ChatPresenterInterface {

    func dispatchPackage(start: Bool) {
        if start {
            let messageModel = MessageModel(id: UUID().uuidString,
                                            to: group.channelName,
                                            key: group.channelKey,
                                            from: user.refID!,
                                            type: "typing",
                                            content: "1",
                                            size: 0,
                                            isGroupMessage: false,
                                            status: 0,
                                            date: 1622801248314)
            self.mqtt.publish(message: messageModel)
        } else {
            let messageModel = MessageModel(id: UUID().uuidString,
                                            to: group.channelName,
                                            key: group.channelKey,
                                            from: user.refID!,
                                            type: "typing",
                                            content: "0",
                                            size: 0,
                                            isGroupMessage: false,
                                            status: 0,
                                            date: 1622801248314)
            self.mqtt.publish(message: messageModel)
        }
    }
    
    func sendMessage(text: String) {
        let now = Date()
        let timeInterval = now.millisecondsSince1970
        let message = MessageModel(id: UUID().uuidString,
                                   to: group.channelName,
                                   key: group.channelKey,
                                   from: user.refID!,
                                   content: text.prefix(400).description,
                                   size: 0,
                                   isGroupMessage: false,
                                   status: 0,
                                   date: timeInterval)
        mqtt.publish(message: message)
        dispatchPackage(start: false)
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
    
    func messageCount() -> Int {
        return messages.count
    }
    
}

extension ChatPresenter: ReceiptAcknowledge {
    func didReceive(receipt: Receipt, status: ReceiptType) {
        guard user.fullName != receipt.from, let messageIndex = self.messages.firstIndex(where: {$0.id == receipt.messageId}) else {return}
        if  user.refID != receipt.from {
            messages[messageIndex].status = status
           // self.output?(.reloadCell(indexPath: IndexPath(row: messageIndex, section: 0)))
        }
    }
    
    
}


extension ChatPresenter: ReceiptDelegate {
    func send(receipt: Receipt, status: ReceiptType, isMyMessage: Bool) {
        guard !isMyMessage else {return}
        mqtt.publish(receipt: receipt)
        print("send receipt \(status) \(receipt.from)")
    }
    
    
}
