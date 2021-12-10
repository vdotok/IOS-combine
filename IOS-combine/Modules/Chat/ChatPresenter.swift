//
//  ChatPresenter.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import Foundation
import iOSSDKConnect
import iOSSDKStreaming

final class ChatPresenter {

    // MARK: - Private properties -

    private unowned let view: ChatViewInterface
    var interactor: ChatInteractorInterface?
    private let wireframe: ChatWireframeInterface
    var mqtt: ChatClient?
    var group: Group?
    var messages: [ChatMessage]? = []
    var user: User?
    var chatOutput: ChatOutput?
    var sdk: VTokSDK?
    var streamingManager: StreamingMananger?

    // MARK: - Lifecycle -

    init(
        view: ChatViewInterface,
        interactor: ChatInteractorInterface,
        wireframe: ChatWireframeInterface,
        sdk: VTokSDK? = nil,
        streamingManager: StreamingMananger
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.sdk = sdk
        self.streamingManager = streamingManager
    }
    
    enum Output {
        case reload
        case reloadCell(indexPath: IndexPath)
    }
    
}

// MARK: - Extensions -

extension ChatPresenter {
    
    func publish(file data: Data, with ext: String, type: Int) {
        interactor?.publish(file: data, with: ext, type: type)
    }
    
    func receivedMessage(userInfo: [String: AnyObject]) {
        interactor?.receivedMessage(userInfo: userInfo)
    }
    
    func sendSeenMessage(message: ChatMessage, row: Int) {
        interactor?.sendSeenMessage(message: message, row: row)
    }
  
}




extension ChatPresenter: ChatPresenterInterface {

    func dispatchPackage(start: Bool) {
        interactor?.dispatchPackage(start: start)
    }
    
    func sendMessage(text: String) {
        interactor?.sendMessage(with: text)
    }
    
    func itemAt(row: Int) -> (ChatMessage,CellType) {
        return interactor!.itemAt(row: row)
    }
    
    func messageCount() -> Int {
        return messages!.count
    }
    
}

extension ChatPresenter: ChatInteractorToPresenter {
    func updateGroup(with group: Group, user: User, messages: [ChatMessage]) {
        self.group = group
        self.user = user
        self.messages = messages
    }
    
    func update(messages: [ChatMessage]) {
        self.messages = messages
        chatOutput?(.reload)
    }
    
    func moveToBroadcast() {
        wireframe.moveToBroadcastOverlay()
    }
    
    func reloadCell(with indexPath: IndexPath) {
        chatOutput?(.reloadCell(indexPath: indexPath))
    }
    
    
}
