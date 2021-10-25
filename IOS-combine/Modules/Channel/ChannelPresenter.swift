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
import iOSSDKConnect
import iOSSDKStreaming



final class ChannelPresenter {

    // MARK: - Private properties -

    private unowned let view: ChannelViewInterface
    var interactor: ChannelInteractorInterface?
    private let wireframe: ChannelWireframeInterface
    private var channels: GroupResponse?
    var channelOutput: ChannelOutput?
    var isSearching: Bool = false
    var groups: [Group] = []
    var contacts: [User] = []
    var vtokSDK: VTokSDK?
    var mqttClient: ChatClient?
    var presentCandidates: [String: [String]] = [:]
    var messages: [String: [ChatMessage]] = [:]
    var unreadMessages: [String:[ChatMessage]] = [:]
    var particinpants: [Participant]?
    var streamingManager: StreamingMananger
  
    
    

    // MARK: - Lifecycle -

    init(
        view: ChannelViewInterface,
        interactor: ChannelInteractorInterface,
        wireframe: ChannelWireframeInterface,
        streamingManager: StreamingMananger
   
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.streamingManager = streamingManager
    }
    
    enum Output {
        case reload
        case showProgress
        case hideProgress
        case connected(_ sdkType: SDKType)
        case disconnected(_ sdkType: SDKType)
        case failure(message: String)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NotifyCallType.notificationName, object: nil)
    }
    
}

// MARK: - Extensions -

extension ChannelPresenter: ChannelPresenterInterface {
  
    func viewDidLoad() {
        fetchGroups()
        interactor?.connectVdoTok()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: NotifyCallType.notificationName, object: nil)
    }
    
    func viewWillAppear() {
        channelOutput?(.reload)
    }
    
    func channelsCount() -> Int {
        return groups.count
    }
    
    func subscribe(group: Group) {
        subscribe(groups: [group])
    }
    
    private func subscribe(groups: [Group]) {
        let topics = groups.map({ $0.channelKey + "/" + $0.channelName})
        for topic in topics {
            mqttClient?.subscribe(topic: topic)
        }
    }
     
    func itemAt(row: Int) -> TempGroup? {
        
        let channel = groups[row].channelName
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
        interactor?.fetchGroups()
    }
    
    func fetchUsers() {
        channelOutput?(.showProgress)
        interactor?.fetchUsers()
        
    }
    
    func logout() {
        mqttClient?.disConnect()
        vtokSDK?.closeConnection()
    }
    
    func moveToCreateGroup() {
        guard let client = mqttClient else {return}
        wireframe.moveToCreateGroup(client: client)
    }
    
    
    func navigation(to: ChannelNavigationOptions, messages: [ChatMessage], group: Group?) {
        guard let client = mqttClient,let user = VDOTOKObject<UserResponse>().getData() else {return}
        switch to {
        case .chat:
           guard let group = group else {return}
            wireframe.move(to: .chat, client: client, group: group, user: user, messages: messages, sdk: vtokSDK, streamingManager: streamingManager)
        case .broadcastOverlay:
            wireframe.move(to: .broadcastOverlay, client: client, group: nil, user: user, messages: messages, sdk: vtokSDK, streamingManager: streamingManager)
        }
    }
    
    
}


extension ChannelPresenter {
}
 
extension ChannelPresenter: SDKConnectionDelegate {
    func didGenerate(output: SDKOutPut) {
        switch output {
        case .registered:
            self.channelOutput?(.connected(.stream))
        case .disconnected(_):
            self.channelOutput?(.disconnected(.stream))
        case .sessionRequest(let sessionRequest):
            guard let sdk = vtokSDK else {return}
            wireframe.moveToIncomingCall(sdk: sdk, baseSession: sessionRequest, users: contacts, sessionDirection: .incoming)
         
        }
    }
    
}


// MARK: Connect
extension ChannelPresenter {

    
    @objc func methodOfReceivedNotification(notification: Notification) {
        guard let info = notification.object as? [AnyHashable: Any],
              let callType = info["callType"] as? String,
              let groupId = info["groupId"] as? Int
               else {return}
        
        if callType == NotifyCallType.audio.callType {
           guard let group = groups.first(where: { $0.id == groupId }) else
           {return}
             moveToAudio(users: group.participants)
        } else if callType == NotifyCallType.video.callType {
            guard let group = groups.first(where: { $0.id == groupId }) else
            {return}
              moveToVideo(users: group.participants)
        } else if callType == NotifyCallType.broadcast.callType {
            var broadcastdata = info["broadcastData"] as? BroadcastData
            broadcastdata?.broadcastType = .group
            interactor?.broadCastData = broadcastdata
            particinpants = info["participants"] as? [Participant]
        } else if callType == NotifyCallType.fetchStreams.callType {
            guard let session = info["session"] as? VTokBaseSession else {return}
            switch session.callType {
            case .onetomany:
                moveToVideo(users: [], screenType: .fetchonetomany, session: session)
             
            case .manytomany, .onetoone:
                moveToVideo(users: [], screenType: .fetchStreams, session: session)
            }
        }
        else if callType == NotifyCallType.cameraBroadcast.callType {
            guard let group = groups.first(where: { $0.id == groupId }) else
            {return}
            guard var broadcastdata = info["broadcastData"] as? BroadcastData else {return}
            self.particinpants = group.participants
            broadcastdata.broadcastGroupID = String(groupId)
            moveToCallingView(sdk: vtokSDK!, screenType: .videoAndScreenShare, broadCastData: broadcastdata)
        }
    }
    
    func convertArray<T, U>(array: [T]) -> [U] {
        var newArray = [U]()
        for element in array {
            guard let newElement = element as? U else {
                print("downcast failed!")
                return []
            }
            newArray.append(newElement)
        }
        return newArray
    }
    
    func moveToVideo(users: [Participant], screenType: ScreenType, session: VTokBaseSession) {
        guard let sdk = vtokSDK else {return}
        wireframe.moveToCalling(particinats: users, users: contacts, sdk: sdk, broadCastData: nil, screenType: screenType, session: session, sessionDirection: .outgoing)
    }
    
    func moveToVideo(users: [Participant]) {
         guard let sdk = vtokSDK else {return}
//        wireframe.moveToCalling(sdk: sdk, particinats: users, users: contacts, broadCastData: nil)
        wireframe.moveToCalling(particinats: users, users: contacts, sdk: sdk, broadCastData: nil, screenType: .videoView, session: nil, sessionDirection: .outgoing)
    }
    
    func moveToAudio(users: [Participant]) {
        guard let sdk = vtokSDK else {return}
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.wireframe.moveToAudio(sdk: sdk, participants: users, users: self.contacts, sessionDirection: .outgoing)
        }
    }
}


extension ChannelPresenter: ChannelInteractorToPresenter {

    
    func connect(status: ConnectConnectionStatus, sdk: ChatClient?) {
        switch status {
        case .connected:
            channelOutput?(.connected(.chat))
            self.mqttClient = sdk
        case .disconnected:
            channelOutput?(.disconnected(.chat))
        }
    }
    
    func streaming(connectionStats: StreamConnectionStatus, sdk: VTokSDK?) {
        switch connectionStats {
        case .connected:
            channelOutput?(.connected(.stream))
        case .disconnected:
            channelOutput?(.disconnected(.stream))
        case .request(let session, let sdk):
            
            wireframe.moveToIncomingCall(sdk: sdk, baseSession: session, users: contacts, sessionDirection: .incoming)
        
        }
    }
    
    func messageReceived(with readMessages: [String : [ChatMessage]], unreadMessages: [String : [ChatMessage]]) {
        self.messages = readMessages
        self.unreadMessages = unreadMessages
        channelOutput?(.reload)
    }
    
    func updatePresence(with presence: [String : [String]]) {
        self.presentCandidates = presence
        channelOutput?(.reload)
    }
    
    func channelFetched(with group: [Group]) {
        self.groups = group
        channelOutput?(.hideProgress)
        channelOutput?(.reload)

    }
    
    func channelFetchedFailed(with error: String) {
        channelOutput?(.hideProgress)
        channelOutput?(.failure(message: error))
    }
    
    func usersFetched(with user: [User]) {
        channelOutput?(.hideProgress)
        self.contacts = user
    }
    
    func usersFetchedFailded(with error: String) {
        channelOutput?(.hideProgress)
        channelOutput?(.failure(message: error))
    }
    
    func hideProgress() {
        channelOutput?(.hideProgress)
        channelOutput?(.reload)
    }
    
    func moveToCallingView(sdk: VTokSDK, screenType: ScreenType, broadCastData: BroadcastData) {
       // wireframe.dismissView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.wireframe.moveToCalling(particinats: self?.particinpants ?? [], users: self?.contacts ?? [], sdk: sdk, broadCastData: broadCastData, screenType: .videoAndScreenShare, session: nil, sessionDirection: .outgoing)
        }
       
    }
    
    func dismissView() {
        wireframe.dismissView()
    }

}
