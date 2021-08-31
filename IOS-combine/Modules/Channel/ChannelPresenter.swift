//
//  ChannelPresenter.swift
//  IOS-combine
//
//  Created by usama farooq on 30/08/2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import Foundation
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

final class ChannelPresenter {

    // MARK: - Private properties -

    private unowned let view: ChannelViewInterface
    private let interactor: ChannelInteractorInterface
    private let wireframe: ChannelWireframeInterface
    private var channels: GroupResponse?
    var channelOutput: ChannelOutput?
    var isSearching: Bool = false
    
    var presentCandidates: [String: [String]] = [:]
    var messages: [String: [ChatMessage]] = [:]
    var unreadMessages:[String:[ChatMessage]] = [:]
    
    

    // MARK: - Lifecycle -

    init(
        view: ChannelViewInterface,
        interactor: ChannelInteractorInterface,
        wireframe: ChannelWireframeInterface
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
    
    enum Output {
        case reload
        case showProgress
        case hideProgress
//        case connected(_ sdkType: SDKType)
//        case disconnected(_ sdkType: SDKType)
        case failure(message: String)
    }
    
}

// MARK: - Extensions -

extension ChannelPresenter: ChannelPresenterInterface {
    
    func viewDidLoad() {
        fetchGroups()
    }
    
    func viewWillAppear() {
        
    }
    
    func channelsCount() -> Int {
        return channels?.groups?.count ?? 0
    }
     
    func itemAt(row: Int) -> TempGroup? {
        guard let channels = channels, let groups = channels.groups else {return  nil}
        
        guard let channel = channels.groups?[row].channelName else {return nil}
        let present = presentCandidates[channel]
        let topic =  messages[channel]
        let unReadmessages = unreadMessages[channel]
        var lastMessage = ""
        if unReadmessages?.count ?? 0 >= 1 {
            lastMessage = "Misread messages"
        }
        else {
            if let message = topic?.last?.content {
                lastMessage = message
            }
            if let _ = topic?.last?.fileType {
                lastMessage = "Attachment"
            }
               
        }
        
        let group = TempGroup(group: groups[row], unReadMessageCount: unReadmessages?.count ?? 0, lastMessage: lastMessage, presentParticipant: present?.count ?? 0)
        
        return group
        
    }
    
    func fetchGroups() {
        guard let output = channelOutput else {return}
        output(.showProgress)
        interactor.fetchGroups { [weak self] result in
            output(.hideProgress)
            guard let self = self else {return}
            switch result {
            case .success(let response):
                self.channels = response
                output(.reload)
            case .failure(let error):
                break
            }
        }
    }
    

    
}
