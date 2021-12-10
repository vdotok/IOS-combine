//
//  ChannelInterfaces.swift
//  IOS-combine
//
//  Created by usama farooq on 30/08/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import iOSSDKConnect
import iOSSDKStreaming

enum ChannelNavigationOptions {
    case chat
    case broadcastOverlay
}

enum SocketType {
    case chat
    case streaming
}

enum ConnectConnectionStatus {
    case connected
    case disconnected
}

enum StreamConnectionStatus {
    case connected
    case disconnected
    case request(session: VTokBaseSession, sdk: VTokSDK)
}



typealias ChannelOutput = (ChannelPresenter.Output) -> Void

typealias ChannelComplition = ((Result<GroupResponse, Error>) -> Void)

protocol ChannelWireframeInterface: WireframeInterface {
    func move(to: ChannelNavigationOptions,client: ChatClient, group: Group?, user: User, messages: [ChatMessage],sdk: VTokSDK?, streamingManager: StreamingMananger)
    func moveToCreateGroup(client: ChatClient, sdk: VTokSDK)
    func moveToCalling(particinats: [Participant], users: [User], sdk: VTokSDK, broadCastData: BroadcastData?, screenType: ScreenType, session: VTokBaseSession?, sessionDirection: SessionDirection)
    func moveToIncomingCall(sdk: VTokSDK, baseSession: VTokBaseSession, users: [User], sessionDirection: SessionDirection)
    func moveToAudio(sdk: VTokSDK, participants: [Participant], users: [User], sessionDirection: SessionDirection)
    func dismissView(sdk: VTokSDK, screenType: ScreenType, broadCastData: BroadcastData,participant: [Participant], user: [User])
}

protocol ChannelViewInterface: ViewInterface {
}

protocol ChannelPresenterInterface: PresenterInterface {
    var channelOutput: ChannelOutput? {get set}
    var isSearching: Bool {get set }
    var messages: [String: [ChatMessage]] {get set}
    var groups: [Group]  {get set}
    var unreadMessages:[String:[ChatMessage]] {get set}
    var streamingManager: StreamingMananger {get set}
    var vtokSDK: VTokSDK? {get set}
    func subscribe(group: Group) 
    func fetchGroups()
    func viewDidLoad()
    func viewWillAppear()
    func itemAt(row: Int) -> TempGroup?
    func channelsCount() -> Int
    func logout()
    func navigation(to: ChannelNavigationOptions, messages: [ChatMessage], group: Group?)
    func moveToCreateGroup()
    func deleteGroup(with id: Int)
    func editGroup(with title: String, id: Int) 

}

protocol ChannelInteractorInterface: InteractorInterface {
    var broadCastData: BroadcastData? {get set}
    var presenter: ChannelInteractorToPresenter? {get set}
    var vtokSdk: VTokSDK? {get set}
    func fetchGroups()
    func fetchUsers()
    func connectVdoTok()
  
}


protocol ChannelInteractorToPresenter: AnyObject {
    var vtokSDK: VTokSDK? {get set}
    func channelFetched(with group: [Group])
    func channelFetchedFailed(with error: String)
    func usersFetched(with user: [User])
    func usersFetchedFailded(with error: String)
    var streamingManager: StreamingMananger {get set}
    func streaming(connectionStats: StreamConnectionStatus, sdk: VTokSDK?)
    func connect(status: ConnectConnectionStatus, sdk: ChatClient?)
    func updatePresence(with presence: [String: [String]])
    func hideProgress()
    func dismissView(sdk: VTokSDK, screenType: ScreenType, broadCastData: BroadcastData)
    func messageReceived(with readMessages: [String: [ChatMessage]], unreadMessages: [String:[ChatMessage]])
    func moveToCallingView(sdk: VTokSDK, screenType: ScreenType, broadCastData: BroadcastData, participant: [Participant], user: [User])
}
