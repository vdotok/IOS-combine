//
//  CallingPresenter.swift
//  IOS-combine
//
//  Created by usama farooq on 02/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import Foundation
import iOSSDKStreaming
import MMWormhole

final class CallingPresenter: NSObject {

    // MARK: - Private properties -

    private unowned let view: CallingViewInterface
    private let interactor: CallingInteractorInterface
    private let wireframe: CallingWireframeInterface
    var users: [User]?
    var participants: [Participant]?
    var screenType: ScreenType
    var player: AVAudioPlayer?
    var broadcastData: BroadcastData?
    var counter = 0
    var timer = Timer()
    var vtokSdk: VideoTalkSDK?
    var session: VTokBaseSession?
    var ssSession: VTokBaseSession?
    var output: CallingOutput?
    let wormhole = MMWormhole(applicationGroupIdentifier: AppsGroup.APP_GROUP,
                              optionalDirectory: "wormhole")
    var streamingManager: StreamingMananger?
    var sessionDirection: SessionDirection
    var url: String? = nil
    var isBusy: Bool = false
    //var streamManager: StreamingMananger = StreamingMananger()

    // MARK: - Lifecycle -

    init(
        view: CallingViewInterface,
        interactor: CallingInteractorInterface,
        wireframe: CallingWireframeInterface,vtokSdk: VideoTalkSDK,
        participants: [Participant]? = nil,
        screenType: ScreenType,
        session: VTokBaseSession? = nil,
        users: [User]? = nil,
        broadCastData: BroadcastData? = nil,
        streamingManager: StreamingMananger? = nil,
        sessionDirection: SessionDirection
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.vtokSdk = vtokSdk
        self.participants = participants
        self.screenType = screenType
        self.session = session
        self.users = users
        self.broadcastData = broadCastData
        self.streamingManager = streamingManager
        self.sessionDirection = sessionDirection
        super.init()
        self.streamingManager?.delegate = self
    }
    
    enum Output {
        case loadView(mediaType: SessionMediaType)
        case loadIncomingCallView(session: VTokBaseSession, user: User)
        case configureLocal(stream: UserStream, session: VTokBaseSession)
        case configureRemote(streams: [UserStream], session: VTokBaseSession)
        case updateVideoView(session: VTokBaseSession)
        case loadAudioView
        case dismissCallView
        case updateView(session: VTokBaseSession)
        case loadBroadcastView(session: VTokBaseSession)
        case updateHangupButton(status: Bool)
        case updateURL(url: String)
        case updateUsers(Int)
        case fetchStreams
        case fetchonetomany(session: VTokBaseSession, url: String?)
        case update(session: VTokBaseSession)
        case configureSSButtonStates(videoState: Int, audioState: Int)
        case updateTime(value: String)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "captured" {

          if !UIScreen.main.isCaptured {
            //    UIApplication.shared.isIdleTimerDisabled = false
              guard let options = broadcastData?.broadcastOptions,
                    let sdk = vtokSdk
                  //  sessionDirection == .outgoing
              else {
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                      self?.output?(.dismissCallView)
                  }
                  return
                  
              }
              switch options {
              case .screenShareWithAppAudioAndVideoCall:
                  guard  let session = session else { return }
                  sdk.hangup(session: session)
              case .screenShareWithVideoCall:
                  guard  let session = session else {return }
                  sdk.hangup(session: session)
              case .screenShareWithAppAudio:
                  output?(.dismissCallView)
              case .screenShareWithMicAudio:
                  output?(.dismissCallView)
              case .videoCall:
                  output?(.dismissCallView)
              }
              
            }
        }

    }
    deinit {
        
    }
}

// MARK: - Extensions -

extension CallingPresenter {
    private func loadViews() {
        switch screenType {
        case .audioView:
            makeSession(with: .audioCall)
        case .videoView:
            makeSession(with: .videoCall)
        case .incomingCall:
            guard let session = session else {return}
            guard let selectedUser =  users?.filter({$0.refID == session.to.first}).first else {return}
           
            playSound()
            output?(.loadIncomingCallView(session: session, user: selectedUser))
            self.session = session
          //  callHangupHandling()
        case .videoAndScreenShare:
            handleBroadcast()
        case .fetchStreams:
            guard let session = session else {return}
            output?(.update(session: session))
            streamingManager?.getStreams()
        case .fetchonetomany:
            guard let session = session else {return}
            output?(.fetchonetomany(session: session, url: AppDelegate.appDelegate.publicURL))
            streamingManager?.getStreams()
        case .broadcastOnly:
            guard let session = session else {return}
            output?(.update(session: session))
        }
    }
    
    private func handleBroadcast() {
        guard let data = broadcastData else { return }
        switch data.broadcastOptions {
        case .screenShareWithAppAudio, .screenShareWithMicAudio:
            let sessionUUID = getRequestId()
            guard let message = getScreenShareDataString(for: sessionUUID, with: nil) else {return}
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.wormhole.passMessageObject(message, identifier: "InitScreenSharingSdk")
            })
        case .videoCall:
            let sessionUUID = getRequestId()
            makeSession(with: .videoCall, sessionUUID: sessionUUID, associatedSessionUUID: nil)
        case .screenShareWithAppAudioAndVideoCall, .screenShareWithVideoCall:
            let callSessionUUID: String = getRequestId()
            let screenShareUUID: String = getRequestId()
            makeSession(with: .videoCall, sessionUUID: callSessionUUID, associatedSessionUUID: screenShareUUID)
            guard let message = getScreenShareDataString(for: screenShareUUID, with: callSessionUUID) else {return}
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.wormhole.passMessageObject(message, identifier: "InitScreenSharingSdk")
            })
        
        }
    }
    
    private func makeSession(with sessionMediaType: SessionMediaType) {
        guard let user = VDOTOKObject<UserResponse>().getData(),
              let refID = user.refID
        else {return}
        guard let participents = participants else {return}
        let participantsRefIds = participents.map({$0.refID}).filter({$0 != user.refID })
        let requestId = getRequestId()
        let baseSession = VTokBaseSessionInit(from: refID,
                                              to: participantsRefIds,
                                              requestID: requestId,
                                              sessionUUID: requestId,
                                              sessionMediaType: sessionMediaType,
                                              callType: .manytomany)
        output?(.loadView(mediaType: sessionMediaType))
        vtokSdk?.initiate(session: baseSession, sessionDelegate: streamingManager)
      //  callHangupHandling()
    }
    
    @discardableResult
    private func makeSession(with sessionMediaType: SessionMediaType,sessionUUID: String, associatedSessionUUID: String? ) -> String? {
        guard let user = VDOTOKObject<UserResponse>().getData(),
              let refID = user.refID
        else {return nil}
        guard let participents = participants, let broadcast = broadcastData else {return nil}
        let participantsRefIds = participents.map({$0.refID}).filter({$0 != user.refID })
        
        let requestId = sessionUUID
        let baseSession = VTokBaseSessionInit(from: refID,
                                              to: broadcast.broadcastType == .group ? participantsRefIds : [],
                                              requestID: requestId,
                                              sessionUUID: requestId,
                                              sessionMediaType: sessionMediaType,
                                              callType: .onetomany,
                                              sessionType: .call,
                                              associatedSessionUUID: associatedSessionUUID,broadcastType: broadcast.broadcastType, broadcastOption: broadcast.broadcastOptions, connectedUsers: [])
        session = baseSession
        if associatedSessionUUID == nil {
            output?(.loadBroadcastView(session: baseSession))
//            output?(.loadView(mediaType: sessionMediaType))
        }else {
            output?(.loadBroadcastView(session: baseSession))
        }
        
        vtokSdk?.initiate(session: baseSession, sessionDelegate: streamingManager)
     //   callHangupHandling()
        return requestId
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
    
    func callHangupHandling() {
        timer.invalidate()
        counter = 0
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(timerAction),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func timerAction() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.counter += 1
            if self.counter > 30 {
                guard let session = self.session else {return}
                self.counter = 0
                self.timer.invalidate()
                switch session.sessionDirection {
                case .incoming:
                    self.vtokSdk?.reject(session: session)
                    self.output?(.dismissCallView)
                case .outgoing:
                    self.vtokSdk?.hangup(session: session)
                    
                }
                
               
            }
        }
      
        
    }
    
   
}

extension CallingPresenter: StreamingDelegate {
    func sessionTimeDidUpdate(with value: String) {
        print(value)
        output?(.updateTime(value: value))
    }

    func configureLocalViewFor(session: VTokBaseSession, with steams: [UserStream]) {
        guard let renderer = steams.first else {return}
        output?(.configureLocal(stream: renderer, session: session))
    }
    
    func configureRemoteViews(for session: VTokBaseSession, with streams: [UserStream]) {
        self.session = session
        output?(.configureRemote(streams: streams, session: session))
    }
    
    func didGetPublicUrl(for session: VTokBaseSession, with url: String) {
        AppDelegate.appDelegate.publicURL = url
        output?(.updateURL(url: url))
    }
    
    func stateDidUpdate(for session: VTokBaseSession) {
        self.session = session
        if session.state == .missedCall {
            output?(.dismissCallView)
            return
        }
        output?(.update(session: session))

    }
    
}

extension CallingPresenter {
    private func didConnect() {
        stopSound()
        timer.invalidate()
        counter = 0
        guard let session = session else {return}
        output?(.updateView(session: session))
        output?(.updateHangupButton(status: true))
    }
    
    private func sessionReject() {
        DispatchQueue.main.async {[weak self] in
            self?.output?(.dismissCallView)
            self?.stopSound()
        }
    }
    
    private func sessionMissed() {
        DispatchQueue.main.async {[weak self] in
            self?.output?(.dismissCallView)
            self?.stopSound()
        }
    }
    
    private func sessionHangup() {
        DispatchQueue.main.async {[weak self] in
            
            self?.output?(.dismissCallView)
        }
    }
}

extension CallingPresenter: CallingPresenterInterface {
    
    func viewModelDidLoad() {
        
        if let baseSession = session, baseSession.state == .receivedSessionInitiation {
            vtokSdk?.set(sessionDelegate: streamingManager!, for: baseSession)
        }
        loadViews()
        listenForPublicURL()
        listenForParticipantAdd()
        listenForSessionTerminate()
        
    }
    
    func viewModelWillAppear() {
        addNotificationObserver()
        listenForSessionDuration()
    }
    
    func viewModelDidDisapper() {
        removeObservers()
        removeSessionDuration()
        
    }
    
    func removeObservers(){
        UIScreen.main.removeObserver(self, forKeyPath: "captured")
    }
    
    func addNotificationObserver(){
          // Add Key-Value observer on isCaptured property of uiscreen.main
        UIScreen.main.addObserver(self, forKeyPath: "captured", options: .new, context: nil)

      }
    
    // MARK:- Key-Value Observer callback

    func acceptCall(session: VTokBaseSession) {
        stopSound()
        switch session.callType {
        case .manytomany, .onetoone:
            output?(.update(session: session))
        case .onetomany:
            output?(.loadBroadcastView(session: session))
            output?(.updateVideoView(session: session))
        }
        output?(.updateHangupButton(status: false))
        vtokSdk?.accept(session: session)
        
    }
    
    func rejectCall(session: VTokBaseSession) {
        vtokSdk?.reject(session: session)
        timer.invalidate()
        counter = 0
        output?(.dismissCallView)
        stopSound()
    }
    
    func hangupCall(session: VTokBaseSession) {
        stopSound()
        timer.invalidate()
        counter = 0
        vtokSdk?.hangup(session: session)
    }
    
    func flipCamera(session: VTokBaseSession, state: CameraType) {
        vtokSdk?.switchCamera(session: session, to: state)
    }
    
    func mute(session: VTokBaseSession, state: AudioState) {
        vtokSdk?.mute(session: session, state: state)
    }
    
    func speaker(session: VTokBaseSession, state: SpeakerState) {
        vtokSdk?.speaker(session: session, state: state)
    }
    
    func disableVideo(session: VTokBaseSession, state: VideoState) {
        vtokSdk?.disableVideo(session: session, State: state)
    }
    
}

 // MARK: - play sound
extension CallingPresenter {
    func stopSound() {
        player?.stop()
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "iphone_11_pro", withExtension: "mp3") else {
            print("url not found")
            return
        }

        do {
            /// this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            /// change fileTypeHint according to the type of your audio file (you can omit this)

            /// for iOS 11 onward, use :
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /// else :
            /// player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)

            // no need for prepareToPlay because prepareToPlay is happen automatically when calling play()
            player!.numberOfLoops = 3
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
}

extension CallingPresenter {
    
    func listenForSessionDuration() {
        wormhole.listenForMessage(withIdentifier: "sessionDuration", listener: { [weak self]
            (messageObject) -> Void in
            guard let self = self else {return}
            if let message = messageObject as? String {
                self.output?(.updateTime(value: message))
            }
            
        })
    }
    
    func removeSessionDuration() {
        wormhole.stopListeningForMessage(withIdentifier: "sessionDuration")
    }
    
    private func listenForPublicURL() {
        wormhole.listenForMessage(withIdentifier: "didGetPublicURL", listener: { [weak self] (messageObject) -> Void in
            if let message = messageObject as? String {
                self?.output?(.updateURL(url: message))
                AppDelegate.appDelegate.publicURL = message
            }
        })
    }
    
    private func listenForParticipantAdd() {
        wormhole.listenForMessage(withIdentifier: "participantAdded") { [weak self] message -> Void  in
            if let count = message as? String {
                guard let userCount = Int(count) else {return}
                self?.output?(.updateUsers(userCount))
                
            }
        }
    }
    
    private func listenForSessionTerminate() {
        wormhole.listenForMessage(withIdentifier: "sessionTerminated") { [weak self] message -> Void in
            if let sessionString = message as? String {
                guard let data = sessionString.data(using: .utf8) else {return }
                let _ = try! JSONDecoder().decode(VTokBaseSessionInit.self, from: data)
                guard let callSession = self?.session else { return }
                self?.vtokSdk?.hangup(session: callSession)
                guard let ssSession = self?.ssSession else {return}
                self?.vtokSdk?.hangup(session: ssSession)
                
            }
        }
    }
    
    private func setScreenShareSession(with message: String) {
        guard let data = message.data(using: .utf8) else {return }
        ssSession = try! JSONDecoder().decode(VTokBaseSessionInit.self, from: data)
        guard let from = ssSession?.from, let to = ssSession?.to, let sessionUUID = ssSession?.sessionUUID else{return}
        let baseSession = VTokBaseSessionInit(from: from, to: to, sessionUUID: sessionUUID, sessionMediaType: .videoCall, callType: .onetomany, connectedUsers: [])
        output?(.loadBroadcastView(session: baseSession))
        
    }
    
    func getScreenShareDataString(for sessionUUID: String, with associatedSessionUUID: String?) -> NSString? {
        guard let user = VDOTOKObject<UserResponse>().getData(),
              let token = user.authorizationToken,
              let refID = user.refID,
              let broadcastData = broadcastData
        else {return nil}
        guard let participents = participants else {return nil}
        let participantsRefIds = participents.map({$0.refID}).filter({$0 != user.refID })
        let session = VTokBaseSessionInit(from: refID,
                                          to: participantsRefIds,
                                          requestID: sessionUUID,
                                          sessionUUID: sessionUUID,
                                          sessionMediaType: .videoCall,
                                          callType: .onetomany,
                                          sessionType: .screenshare,
                                          associatedSessionUUID: associatedSessionUUID,
                                          broadcastType: broadcastData.broadcastType,
                                          broadcastOption: broadcastData.broadcastOptions, connectedUsers: [])
        
        let data = ScreenShareAppData(url: user.mediaServerMap!.completeAddress,
                                      authenticationToken: token,
                                      baseSession: session)
        self.ssSession = session
        output?(.loadBroadcastView(session: session))
        let jsonData = try! JSONEncoder().encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)! as NSString
        
        return jsonString
    }
}

extension CallingPresenter {

    func convertToDictionary(from text: String) -> [String: String] {
        guard let data = text.data(using: .utf8) else { return [:] }
        let anyResult: Any? = try? JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String: String] ?? [:]
    }
}

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
