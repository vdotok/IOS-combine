//  
//  GroupsViewModel.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 06/05/2021.
//

import Foundation
import iOSSDKConnect
import iOSSDKStreaming
import UIKit


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

enum SDKType {
    case stream
    case chat
}

protocol GroupCallingControl {
    func initiatedCall(in groupId: Int, callType: NotifyCallType)
}

protocol NonGroupCallingControl {
    func initiatedCall(users: [User], callType: NotifyCallType)
}

enum NotifyCallType {
    case audio
    case video
}

class AvailableModel: Available, Codable {
    internal init(key: String, channel: String, changes: Bool, status: Bool) {
        self.key = key
        self.channel = channel
        self.changes = changes
        self.status = status
    }
    
    var key: String
    var channel: String
    var changes: Bool
    var status: Bool
}
struct Constants {
    static let host =  "vte2.vdotok.com"
    static let toTopic = "AACO5B_L67HeJxw7InqZzyiGyb92KyJQ/NorgicStagingChannel/?me=0"
    static let topic = "AACO5B_L67HeJxw7InqZzyiGyb92KyJQ/NorgicStagingChannel/?last=20"
    static let channel = "NorgicStagingChannel/"
    static let key = "AACO5B_L67HeJxw7InqZzyiGyb92KyJQ"
    static let presence = "emitter/presence/"
    
    //MARK: Key Constants
    static let usernameKey = "username"
    static let idKey = "id"
    static let messageKey = "message"
    static let topicKey = "topic"
    static let fileKey = "fileType"
    static let mediaType = "type"
    static let date = "date"
    
    //MARK: VDOtok Constants
    static let Request = "request"
    static let Register = "register"
    static let TenantId = "U6WM5"
}


struct AuthenticationConstants {
    static let PROJECTID = "15Q89R"
    static let AUTHTOKEN = "3d9686b635b15b5bc2d19800407609fa"
}

struct TempGroup {
    let group: Group
    let unReadMessageCount: Int
    let lastMessage: String
    let presentParticipant: Int
}


typealias GroupsViewModelOutput = (GroupsViewModelImpl.Output) -> Void

protocol GroupsViewModelInput {
    func filterGroups(with text: String)
}

protocol GroupsViewModel: GroupsViewModelInput, GroupCallingControl, NonGroupCallingControl {
    var output: GroupsViewModelOutput? { get set}
    var groups: [Group] {get set}
    var searchGroup: [Group] {get set}
    var isSearching: Bool {get set}
    var mqttClient: ChatClient? {get set}
    var messages: [String: [ChatMessage]] {get set}
    var presentCandidates: [String: [String]] {get set}
    var unreadMessages:[String:[ChatMessage]] {get set}
    var vtokSdk: VTokSDK?  {get set}
    func viewModelDidLoad()
    func viewModelWillAppear()
    func fetchGroups()
    func subscribe(group: Group)
    func itemAt(row: Int) -> TempGroup
    func deleteGroup(with id: Int)
    func editGroup(with title: String, id: Int)
    func logout()
    func moveToVideo(users: [Participant])
    func moveToAudio(users: [Participant])
}

class GroupsViewModelImpl: GroupsViewModel {

    private let router: GroupsRouter
    var output: GroupsViewModelOutput?
    var store: AllGroupStroreable
    var deleteStore: DeleteStoreable = DeleteService(service: NetworkService())
    var editStore: EditGroupStoreable = EditGroupService(service: NetworkService())
    var mqttClient: ChatClient?
    var vtokSdk: VTokSDK?
    var contacts: [User] = []
    var groups: [Group] = []
    var searchGroup: [Group] = []
    var isSearching: Bool = false
    var presentCandidates: [String: [String]] = [:]
    var messages: [String: [ChatMessage]] = [:]
    var unreadMessages:[String:[ChatMessage]] = [:]
    private let allUserStoreAble: AllUserStoreAble = AllUsersService(service: NetworkService())
    
    init(router: GroupsRouter, store:AllGroupStroreable = AllGroupService(service: NetworkService()) ) {
        self.router = router
        self.store = store
        
    }
    
    func viewModelDidLoad() {
        fetchGroups()
        configureVdotTok()
    }
    
    private func conncectMqtt() {
         
        guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        guard let mediaServer = VDOTOKObject<AuthenticateResponse>().getData() else { return }
        let host = mediaServer.messagingServerMap.host
        guard let port = UInt16(mediaServer.messagingServerMap.port) else {return}
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
    
    func viewModelWillAppear() {
        output?(.reload)
    }
    
    //For all of your viewBindings
    enum Output {
        case reload
        case showProgress
        case hideProgress
        case connected(_ sdkType: SDKType)
        case disconnected(_ sdkType: SDKType)
        case failure(message: String)
    }
}

//MARK:- Calling Control Method
extension GroupsViewModelImpl {
    func initiatedCall(in groupId: Int, callType: NotifyCallType) {
        guard let group = groups.first(where: { $0.id == groupId }) else {return}
        
        if callType == NotifyCallType.audio {
            moveToAudio(users: group.participants)
        } else if callType == NotifyCallType.video {
            moveToVideo(users: group.participants)
        }
    }
    
    func initiatedCall(users: [User], callType: NotifyCallType) {
        let participants = users.map({ Participant(colorCode: "", colorID: 0, email: $0.email, fullName: $0.fullName, refID: $0.refID, userID: $0.userID)})
        if callType == NotifyCallType.audio {
            moveToAudio(users: participants)
        } else if callType == NotifyCallType.video {
            moveToVideo(users: participants)
        }
    }
}

extension GroupsViewModelImpl {
    func fetchGroups() {
        let request = AllGroupRequest()
        self.output?(.showProgress)
        store.fetchGroups(with: request) { [weak self] (response) in
            guard let self = self else {return}
            self.output?(.hideProgress)
            switch response {
            case .success(let response):
                switch response.status {
                case 503:
                    self.output?(.failure(message: response.message ))
                case 500:
                    self.output?(.failure(message: response.message))
                case 401:
                    self.output?(.failure(message: response.message))
                case 200:
                    self.fetchUsers()
                    if self.mqttClient?.isConnected() ?? false {
                        if response.groups?.count == self.groups.count {
                            
                        }
                        else {
                            guard let fetchedGroups = response.groups  else { return }
                            let channelKeys = self.groups.map({$0.channelKey})
                            let newGroups = fetchedGroups.filter({!channelKeys.contains($0.channelKey)})
                            self.subscribe(groups: newGroups)
                            self.groups = response.groups ?? []
                        }
                        DispatchQueue.main.async {
                            self.output?(.reload)
                        }
                       
                        
                    }else {
                        self.conncectMqtt()
                        self.groups = response.groups ?? []
                        DispatchQueue.main.async {
                            self.output?(.reload)
                        }
                    }
                    
                default:
                    break
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchUsers() {
        let request = AllUserRequest()
        allUserStoreAble.fetchUsers(with: request) { [weak self] (response) in
            guard let self = self else {return}
            switch response {
            case .success(let response):
                self.contacts = response.users
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func logout() {
        mqttClient?.disConnect()
        self.vtokSdk?.closeConnection()
    }
}

// VDOtok streaming extension
extension GroupsViewModelImpl {
    
    private func configureVdotTok() {
        guard let authResponse = VDOTOKObject<AuthenticateResponse>().getData() else {return}
        guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        let request = RegisterRequest(type: Constants.Request,
                                      requestType: Constants.Register,
                                      referenceID: user.refID!,
                                      authorizationToken: user.authorizationToken!,
                                      requestID: getRequestId(),
                                      tenantID: AuthenticationConstants.PROJECTID)
        self.vtokSdk = VTokSDK(url: authResponse.mediaServerMap.completeAddress, registerRequest: request, connectionDelegate: self)
        
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
    
    func moveToVideo(users: [Participant]) {
        guard let sdk = vtokSdk else {return}
        router.moveToCalling(sdk: sdk, particinats: users, users: contacts)
    }
    
    func moveToAudio(users: [Participant]) {
        guard let sdk = vtokSdk else {return}
        DispatchQueue.main.async {
            self.router.moveToAudio(sdk: sdk, participants: users, users: self.contacts)
        }
    }
}

extension GroupsViewModelImpl: GroupsViewModelInput {
    func filterGroups(with text: String) {
        self.searchGroup = groups.filter({$0.groupTitle.lowercased().prefix(text.count) == text.lowercased()})
        output?(.reload)
    }

}

extension GroupsViewModelImpl: Connectivity {
    func willConnect() {
        
    }
    
    func didConnect() {
        
    }
    
    func didSubscribe(topics: [String]) {
        let channelArray = topics[0].components(separatedBy: "/")
        print(channelArray)
        let presence = Constants.presence
        let availabe = AvailableModel(key: channelArray[0],
                                      channel: channelArray[1] + "/",
                                      changes: true,
                                      status: true)
        mqttClient?.presense(topic: presence, presense: availabe)
    }
    
    func didUnSubscribe(topic: String) {
        
    }
    
    func connectionState(status: ConnectionStatus) {
        switch status {
        case .CONNECTED:
            print("Connected")
            output?(.connected(.chat))
            subscribe(groups: groups)
        case .DISCONNECTED:
            output?(.disconnected(.chat))
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



extension GroupsViewModelImpl: CustomPacketDelegate {
    func didRecieveJson(data: Data, topic: String) {
        
    }
    
    func didRecieveCustom(packet: String, topic: String) {
        
    }
}

extension GroupsViewModelImpl: PresenceStates {
    func send(presence: [Presence]) {
        self.sendPresence(presence: presence)
    }
    
    func didSend(presence: [Presence]) {
        
    }
    
    func didFailToSend(reason: String) {
        
    }
}


extension GroupsViewModelImpl: MessageDelegate {
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
          
            output?(.reload)
//            actionHandler?(.reload)
            
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


extension GroupsViewModelImpl {
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
        output?(.reload)
//        actionHandler?(.reload)
    }
}

extension GroupsViewModelImpl {
    func send(receipt: Receipt, status: ReceiptType, isMyMessage: Bool) {
        guard !isMyMessage else {return}
        mqttClient?.publish(receipt: receipt)
        print("send receipt \(status) \(receipt.from)")
    }
    
    
    func itemAt(row: Int) -> TempGroup {
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

extension GroupsViewModelImpl: FileDelegate {
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
        output?(.reload)
    }
    
    func didReceive(header: Header) {
        
    }

}

extension GroupsViewModelImpl {
    func deleteGroup(with id: Int) {
        output?(.showProgress)
        let request = DeleteGroupRequest(group_id: groups[id].id)
        deleteStore.delete(with: request) { [weak self] response in
            self?.output?(.hideProgress)
            switch response {
            case .success(let response):
                DispatchQueue.main.async {
                    switch response.status {
                    case 503:
                        self?.output?(.failure(message: response.message ))
                    case 500:
                        self?.output?(.failure(message: response.message))
                    case 401:
                        self?.output?(.failure(message: response.message))
                    case 600:
                        self?.output?(.failure(message: response.message))
                    case 200:
                        
                    self?.groups.remove(at: id)
                    self?.output?(.reload)
                    default:
                    break
                    }
                }
                
                print("\(response)")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func editGroup(with title: String, id: Int) {
        guard  groups[id].participants.count != 1 else {
            output?(.failure(message: "one to one group name cannot be updated"))
            return
        }
        output?(.showProgress)
        let request = EditGroupRequest(group_title: title, group_id: groups[id].id)
        editStore.editGroup(with: request) { [weak self] result in
            self?.output?(.hideProgress)
            switch result {
            case .success(_):
                self?.groups[id].groupTitle = title
                DispatchQueue.main.async {
                    self?.output?(.reload)
                }
               
            case .failure(let error):
                print(error)
                
            }
        }
    }
}

extension GroupsViewModelImpl: SDKConnectionDelegate {
    func didGenerate(output: SDKOutPut) {
        switch output {
        case .registered:
            self.output?(.connected(.stream))
        case .disconnected(_):
            self.output?(.disconnected(.stream))
        case .sessionRequest(let sessionRequest):
            guard let sdk = vtokSdk else {return}
            router.moveToIncomingCall(sdk: sdk, baseSession: sessionRequest, users: self.contacts)
        }
    }
    
    func didFailToRegister(with error: String) {
        
    }
    
    func didMissedSessionRequest(sessionUUID: String, message: String) {
        
    }
}
