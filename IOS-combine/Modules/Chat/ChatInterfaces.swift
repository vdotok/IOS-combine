//
//  ChatInterfaces.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import iOSSDKStreaming
import iOSSDKConnect

typealias ChatOutput = (ChatPresenter.Output) -> Void

protocol ChatWireframeInterface: WireframeInterface {
    func moveToBroadcastOverlay()
}

protocol ChatViewInterface: ViewInterface {
    
}

protocol ChatPresenterInterface: PresenterInterface {
    var group: Group? {get set}
    var interactor: ChatInteractorInterface? {get set}
    var messages: [ChatMessage]? {get set}
    var user: UserResponse? {get set}
    var chatOutput: ChatOutput? {get set}
    var sdk: VTokSDK? {get set}
    var streamingManager: StreamingMananger? {get set}
    func dispatchPackage(start: Bool)
    func sendMessage(text: String)
    func messageCount() -> Int
    func itemAt(row: Int) -> (ChatMessage,CellType)
    func receivedMessage(userInfo: [String: AnyObject])
    func sendSeenMessage(message: ChatMessage, row: Int)
    func moveToBroadcast()
    func publish(file data: Data, with ext: String, type: Int)
}

protocol ChatInteractorInterface: InteractorInterface {
    var presenter: ChatInteractorToPresenter? {get set}
    func sendMessage(with text: String)
    func dispatchPackage(start: Bool)
    func sendSeenMessage(message: ChatMessage, row: Int)
    func receivedMessage(userInfo: [String: AnyObject])
    func publish(file data: Data, with ext: String, type: Int)
    func itemAt(row: Int) -> (ChatMessage,CellType)
   
}

protocol ChatInteractorToPresenter: AnyObject {
    func update(messages: [ChatMessage])
    func updateGroup(with group: Group, user: UserResponse, messages: [ChatMessage])
    func reloadCell(with indexPath: IndexPath)
}
