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
    private let interactor: ChannelInteractorInterface
    private let wireframe: ChannelWireframeInterface
    private var channels: GroupResponse?
    var channelOutput: ChannelOutput?
    var isSearching: Bool = false
    var groups: [Group] = []
    var contacts: [User] = []
    var vtokSdk: VTokSDK?
    var mqttClient: ChatClient?
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
        configureVdotTok()
    }
    
    func viewWillAppear() {
        
    }
    
    func channelsCount() -> Int {
        return groups.count
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
        interactor.fetchGroups { [weak self] result in
            output(.hideProgress)
            guard let self = self else {return}
            switch result {
            case .success(let response):
                switch response.status {
                case 503:
                    self.channelOutput?(.failure(message: response.message ))
                case 500:
                    self.channelOutput?(.failure(message: response.message))
                case 401:
                    self.channelOutput?(.failure(message: response.message))
                case 200:
                    if self.mqttClient?.isConnected() ?? false {
                        if response.groups?.count == self.groups.count {
                            
                        }
                        else {
                            guard let fetchedGroups = response.groups else { return }
                            let channelKeys = self.groups.map({$0.channelKey})
                            let newGroups = fetchedGroups.filter({!channelKeys.contains($0.channelKey)})
                            self.subscribe(groups: newGroups)
                            self.groups = response.groups ?? []
                        }
                        DispatchQueue.main.async {
                            self.channelOutput?(.reload)
                        }
                       
                        
                    }else {
                        self.conncectMqtt()
                        self.groups = response.groups ?? []
                        DispatchQueue.main.async {
                            self.channelOutput?(.reload)
                        }
                    }
                    
                default:
                    break
                }
               
            case .failure(let error):
                break
            }
        }
    }
    
    func logout() {
        mqttClient?.disConnect()
        vtokSdk?.closeConnection()
    }
    
    func moveToCreateGroup() {
        guard let client = mqttClient else {return}
        wireframe.moveToCreateGroup(client: client)
    }
    
    
    func navigation(to: ChannelNavigationOptions, messages: [ChatMessage], group: Group) {
        guard let client = mqttClient,let user = VDOTOKObject<UserResponse>().getData() else {return}
        switch to {
        case .chat:
            wireframe.move(to: .chat, client: client, group: group, user: user, messages: messages)
        }
    }
    
}

// MARK: Streaming

extension ChannelPresenter {
    private func configureVdotTok() {
        guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        let request = RegisterRequest(type: Constants.Request,
                                      requestType: Constants.Register,
                                      referenceID: user.refID!,
                                      authorizationToken: user.authorizationToken!,
                                      requestID: getRequestId(),
                                    projectID: AuthenticationConstants.PROJECTID)
        self.vtokSdk = VTokSDK(url: user.mediaServerMap.completeAddress, registerRequest: request, connectionDelegate: self)
        
    }
    
    private func getRequestId() -> String {
        let generatable = IdGenerator()
        guard let response = VDOTOKObject<UserResponse>().getData() else {return ""}
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval)).stringValue()
        let tenantId = "12345"
        let token = generatable.getUUID(string: time + tenantId + response.refID!)
        return token
        
    }
}
 
extension ChannelPresenter: SDKConnectionDelegate {
    func didGenerate(output: SDKOutPut) {
        switch output {
        case .registered:
            self.channelOutput?(.connected(.stream))
        case .disconnected(_):
            self.channelOutput?(.disconnected(.stream))
        case .sessionRequest(let sessionRequest):
            guard let sdk = vtokSdk else {return}
            wireframe.moveToIncomingCall(sdk: sdk, baseSession: sessionRequest, users: contacts)
         
        }
    }
    
    
}


// MARK: Connect
extension ChannelPresenter {
    func conncectMqtt() {
        
        guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        let host = user.messagingServerMap.host
        guard let port = UInt16(user.messagingServerMap.port) else {return}
        let userName = user.refID
        let password = user.authorizationToken
        
        let client = Client(port: port,
                            host: host,
                            userName: userName!,
                            password: password!,
                            reConnectivity: true)
        mqttClient = ChatClient(client: client, presense: self, connectivity: self, messageDelegate: self, customPacketDelegate: self)
        mqttClient?.connect()
        setDelegate()
    }
    
    func setDelegate(){
        mqttClient?.setFileDelegate(fileDelegate: self)
    }
    
    func send(receipt: Receipt, status: ReceiptType, isMyMessage: Bool) {
        guard !isMyMessage else {return}
        mqttClient?.publish(receipt: receipt)
        print("send receipt \(status) \(receipt.from)")
    }
    
    private func subscribe(groups: [Group]) {
        let topics = groups.map({ $0.channelKey + "/" + $0.channelName})
        for topic in topics {
            mqttClient?.subscribe(topic: topic)
        }
    }
    
    func subscribe(group: Group) {
        subscribe(groups: [group])
    }
    
    func sendPresence(presence: [Presence]) {
        print(presence.map({ $0.username }))
        guard let myUser = VDOTOKObject<UserResponse>().getData() else {return}
        
        let filterPresence = removeDuplicateElements(posts: presence)
        let channel = presence.first?.channel ?? ""
        let name = NSNotification.Name(rawValue: "MQTTMessageNotification" + "test")
        for user in filterPresence {
            NotificationCenter.default.post(name: name,
                                            object: self,
                                            userInfo: [Constants.messageKey: "\(user.username) \(user.type ?? "joined")",
                                                       Constants.topicKey: channel,
                                                       Constants.usernameKey: user.username])
            var users: [String] = []
            if user.type == "joined" {
                
                guard presentCandidates[channel]?.filter({$0 == user.username}).count ?? 0 < 1 else {return}
                users = presentCandidates[channel] ?? []
                users.append(user.username)
                users.removeAll(where: {$0 == myUser.refID})
                presentCandidates[channel]?.removeAll()
                presentCandidates[channel] = users
                
            } else if user.type == "left" {
                users = presentCandidates[channel] ?? []
                users.removeAll(where: { $0 == user.username })
                presentCandidates[channel]?.removeAll()
                presentCandidates[channel] = users
            }
            print(presentCandidates.map({ $0.value.map({ $0 })}))
        }
        channelOutput?(.reload)
    }
    
    func removeDuplicateElements(posts: [Presence]) -> [Presence] {
        var uniquePosts = [Presence]()
        for post in posts {
            if !uniquePosts.contains(where: {$0.username == post.username }) {
                uniquePosts.append(post)
            }
        }
        return uniquePosts
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        guard let info = notification.object as? [AnyHashable: Any],
              let callType = info["callType"] as? String,
              let groupId = info["groupId"] as? Int,
              let group = groups.first(where: { $0.id == groupId }) else {return}
        
        if callType == NotifyCallType.audio.callType {
             moveToAudio(users: group.participants)
        } else if callType == NotifyCallType.video.callType {
              moveToVideo(users: group.participants)
        }
    }
    
    func moveToVideo(users: [Participant]) {
        guard let sdk = vtokSdk else {return}
        wireframe.moveToCalling(sdk: sdk, particinats: users, users: contacts)
    }
    
    func moveToAudio(users: [Participant]) {
        guard let sdk = vtokSdk else {return}
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.wireframe.moveToAudio(sdk: sdk, participants: users, users: self.contacts)
        }
    }
}

 extension  ChannelPresenter: FileDelegate {
    func didReceive(file: FilePart, fileURL: URL, date: UInt64) {
        guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        let data = Data(bytes: file.content, count: file.content.count)
        let message = ChatMessage(id: file.messageId, sender: file.from, content: "", status: .delivered, mediaType: MediaType(rawValue: file.type), date: date)
        message.fileType = fileURL
        
        var tempMessages: [ChatMessage] = []
        var unreadMessages: [ChatMessage] = []
        
        unreadMessages = self.unreadMessages[file.topic ?? ""] ?? []
        tempMessages = messages[file.topic ?? ""] ?? []
        tempMessages.append(message)
        unreadMessages.append(ChatMessage(id: message.id, sender: message.sender, content: message.content, status: .delivered, date: message.date ))
        messages[file.topic ?? ""] = tempMessages
        self.unreadMessages[file.topic ?? ""] = unreadMessages
        let receipt = ReceiptModel(type: ReceiptType.delivered.rawValue, key: file.key, date: 1622801248314, messageId: file.messageId, from: user.fullName!, topic: file.topic ?? "")
        
        self.send(receipt: receipt, status: .delivered, isMyMessage: user.refID == file.from)
           
            
        let name = NSNotification.Name(rawValue: "MQTTMessageNotification" + user.fullName!)
        NotificationCenter.default.post(name: name, object: self,
                                        userInfo: [Constants.messageKey: "",
                                                   Constants.topicKey: file.topic,
                                                   Constants.usernameKey: file.from,
                                                   Constants.idKey: message.id,
                                                   Constants.fileKey: message.fileType,
                                                   Constants.mediaType: file.type,
                                                   Constants.date: date
                                                   
                                        ])
        channelOutput?(.reload)
    }
    
    func didReceive(header: Header) {
        
    }

}


extension ChannelPresenter: CustomPacketDelegate {
    func didRecieveJson(data: Data, topic: String) {
        
    }
    
    func didRecieveCustom(packet: String, topic: String) {
        
    }
}

extension ChannelPresenter: PresenceStates {
    func send(presence: [Presence]) {
        self.sendPresence(presence: presence)
    }
    
    func didSend(presence: [Presence]) {
        
    }
    
    func didFailToSend(reason: String) {
        
    }
}


extension ChannelPresenter: MessageDelegate {
    func onMessageReceive(_ message: Message) {
//        print(message)
        
        guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        var topic = message.to
        if message.to.split(separator: "/").count > 1 {
            topic = message.to.split(separator: "/")[1] + "/"
        }
        
        var tempMessages: [ChatMessage] = []
        var unreadMessages: [ChatMessage] = []
        
        if message.type == "text" {
            let receipt = ReceiptModel(type: ReceiptType.delivered.rawValue, key: message.key, date: 1622801248314, messageId: message.id, from: user.fullName!, topic: message.to)
            
            self.send(receipt: receipt, status: .delivered, isMyMessage: user.refID == message.from)
            let name = NSNotification.Name(rawValue: "MQTTMessageNotification" + user.fullName!)
            NotificationCenter.default.post(name: name, object: self,
                                            userInfo: [Constants.messageKey: message.content,
                                                       Constants.topicKey: topic,
                                                       Constants.usernameKey: message.from,
                                                       Constants.idKey: message.id,
                                                       Constants.date: message.date
                                            ])
            tempMessages = messages[topic] ?? []
            unreadMessages = self.unreadMessages[topic] ?? []
            tempMessages.append(ChatMessage(id: message.id, sender: message.from, content: message.content, status: .delivered, date: message.date ))
            unreadMessages.append(ChatMessage(id: message.id, sender: message.from, content: message.content, status: .delivered, date: message.date ))
            messages[topic] = tempMessages
            self.unreadMessages[topic] = unreadMessages
            channelOutput?(.reload)
            
        }
    }
    
    func onMessagePublish(_ playloadString: String, topic: String) {
        
    }
    
    func didStartTyping(_ message: Message) {
        print(message)
        guard let user = VDOTOKObject<UserResponse>().getData(), let fullName = user.fullName else { return }
        NotificationCenter.default.post(name: NSNotification.Name("didStartTyping" + fullName),
                                        object: self,
                                        userInfo: [Constants.messageKey : message.from,
                                                   "topic": message.to])
    }
    
    func didEndTyping(_ message: Message) {
        print(message)
        guard let user = VDOTOKObject<UserResponse>().getData(), let fullName = user.fullName else { return }
        NotificationCenter.default.post(name: NSNotification.Name("didEndTyping" + fullName),
                                        object: self,
                                        userInfo: [Constants.messageKey : message.from,
                                                   "topic": message.to])
    }
    
    
}

extension ChannelPresenter: Connectivity {
    func willConnect() {
        
    }
    
    func didConnect() {
        
    }
    
    func didSubscribe(topics: [String]) {
        
    }
    
    func didUnSubscribe(topic: String) {
        
    }
    
    func connectionState(status: ConnectionStatus) {
        switch status {
        case .CONNECTED:
            print("Connected")
            channelOutput?(.connected(.chat))
            subscribe(groups: groups)
        case .DISCONNECTED:
            channelOutput?(.disconnected(.chat))
            print("disconncted")
            
        }
    }
    
    func didFailToConnect(_: Error) {
        
    }
    
    func willReconnect() {
        
    }
    
    func didReconnect() {
        
    }
}
