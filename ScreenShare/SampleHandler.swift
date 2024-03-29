//
//  SampleHandler.swift
//  ScreenShare
//
//  Created by usama farooq on 11/10/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import ReplayKit
import iOSSDKStreaming
import MMWormhole

protocol MyAppError : Error {
    var message: String { get }
}
enum SessionHangup : MyAppError {
    case forceStop
    

    var message: String {
        switch self {
        case .forceStop:
            return "force stop"
  
        }
    }
}

class SampleHandler: RPBroadcastSampleHandler {
    
    var vtokSdk : VideoTalkSDK?
    var request: RegisterRequest?
    var audioState: ScreenShareAudioState!
    var screenState: ScreenShareScreenState!
    let streamingManager = StreamingMananger()
    var userStream: UserStream?
    var counter = 0

    let wormhole = MMWormhole(applicationGroupIdentifier: AppsGroup.APP_GROUP, optionalDirectory: Constants.Wormhole)
    
    var baseSession : VTokBaseSession?
    var screenShareData: ScreenShareAppData?
    var callHangupTimer = Timer()
    
    
    override init() {
        super.init()
        audioState = ScreenShareAudioState(screenShareAudio: .passAll)
        screenState = ScreenShareScreenState(screenShareScreen: .passAll)
         wormhole.listenForMessage(withIdentifier: "InitScreenSharingSdk", listener: { [weak self] (messageObject) -> Void in
            guard let self = self else {return }
            if let message = messageObject as? String {
               print(message)
                self.getScreenShareAppData(with: message)
            }
        })

        wormhole.listenForMessage(withIdentifier: "updateAudioState", listener: { [weak self] (messageObject) -> Void in
            guard let self = self else {return }
            if let message = messageObject as? String {
               print(message)
                self.setScreenShareAppAudio(with: message)
            }
        })
        
        wormhole.listenForMessage(withIdentifier: "updateScreenState", listener: { [weak self] (messageObject) -> Void in
            guard let self = self else {return }
            if let message = messageObject as? String {
               print(message)
                guard let sdk = self.vtokSdk,
                      let session = self.screenShareData
                else { return }
                self.setScreenShareScreen(with: message)
              //  sdk.disableScreen(for: session.baseSession, state: self.screenState.screenShareScreen)
            }
        })
        
        wormhole.listenForMessage(withIdentifier: "getBroadcastSession") { message in
            self.getBroadcastSession()
        }
        
        wormhole.listenForMessage(withIdentifier: "commandScreenShareStates") { message in
            self.fetchSessions()
        }
        
    }
    
    func disableScreen(for session: VTokBaseSession, state: ScreenShareBytes) {
        
    }
    
    func setScreenShareAppAudio(with message: String) {
        guard let data = message.data(using: .utf8) else {return }
        audioState = try! JSONDecoder().decode(ScreenShareAudioState.self, from: data)
        
    }
    
    func setScreenShareScreen(with message: String) {
        guard let data = message.data(using: .utf8) else {return }
        screenState = try! JSONDecoder().decode(ScreenShareScreenState.self, from: data)
        
    }
    
    
    func getScreenShareAppData(with message: String) {
        
        guard let data = message.data(using: .utf8) else {return }
        screenShareData = try? JSONDecoder().decode(ScreenShareAppData.self, from: data)
        guard screenShareData != nil else { return }
        initSdk()
    }
    
    func getBroadcastSession() {
        if  vtokSdk?.sessionCount() == 0 {return}
        guard let screenShareData = screenShareData else { return }
        let jsonData = try! JSONEncoder().encode(screenShareData)
        let jsonString = String(data: jsonData, encoding: .utf8)! as NSString
        wormhole.passMessageObject(jsonString, identifier: "fetchBroadcastData")

    }
    
    
    func initSdk(){
        guard let screenShareData = screenShareData else {return }
        request = RegisterRequest(type: "request",
                                      requestType: "register",
                                      referenceID: screenShareData.baseSession.from,
                                      authorizationToken: screenShareData.authenticationToken,
                                      socketType: .screenShare,
                                      requestID: getRequestId(),
                                      projectID: AuthenticationConstants.PROJECTID)
        
        vtokSdk = VTokSDK(url: screenShareData.url, registerRequest: request!, connectionDelegate: self, connectionType: .screenShare)
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        let message : NSString =  "StartScreenSharing"
        wormhole.passMessageObject(message, identifier: "Command")
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        
        let message: String = "sessionTerminated"
        guard let vtokSdk = vtokSdk, let session = screenShareData?.baseSession else {return}
        let jsonData = try! JSONEncoder().encode(session)
        let jsonString = String(data: jsonData, encoding: .utf8)! as NSString
        wormhole.passMessageObject(jsonString, identifier: message)
        vtokSdk.hangup(session: session)
        callHangupTimer.invalidate()
        counter = 0
        
        
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video:
            switch screenState.screenShareScreen {
            case .none:
                break
            case .passAll:
                vtokSdk?.processSampleBuffer(sampleBuffer, with: sampleBufferType)
            }
        case .audioApp,.audioMic:
            switch audioState.screenShareAudio {
            case .passAll:
                vtokSdk?.processSampleBuffer(sampleBuffer, with: sampleBufferType)
            case .none:
                break
            }
        @unknown default:
            break
        }
        
    }
    
    func fetchSessions() {
        let audioState = audioState.screenShareAudio.rawValue
        let videoState = screenState.screenShareScreen.rawValue
        let connectedUsers = baseSession?.connectedUsers.count
        let json = ["audioState": audioState,
                    "videoState": videoState,
                    "connectedUsers": connectedUsers]
        let jsonData = try! JSONEncoder().encode(json)
        let jsonString = String(data: jsonData, encoding: .utf8)! as NSString
        wormhole.passMessageObject(jsonString, identifier: "configureLocalStream")
    }
}

extension SampleHandler: SDKConnectionDelegate {
    func didGenerate(output: SDKOutPut) {
        switch output {
        case .registered:
            print("==== screeen share registerd ====")
            guard let sdk = vtokSdk, let session = screenShareData else {return}
            self.screenShareData = session
            sdk.initiate(session: session.baseSession, sessionDelegate: self)
            callHangupHandling()
        case .disconnected(_):
            print("==== screeen failed to registerd ====")
            break
        case .sessionRequest(_):
            break
        }
    }
    
}



extension SampleHandler: SessionDelegate {
    
    func sessionTimeDidUpdate(with value: String) {
        guard self.baseSession?.associatedSessionUUID == nil else {return}
        let message = String(value) as NSString
        wormhole.passMessageObject(message, identifier: "sessionDuration")
    }
    
    func fetchUser(stream: [UserStream]) {
        
    }
    
    func configureLocalViewFor(session: VTokBaseSession, with stream: [UserStream]) {
   
    }
    
//    func configureLocalViewFor(session: VTokBaseSession, renderer: UIView) {
//
//    }
    
    func configureRemoteViews(for session: VTokBaseSession, with streams: [UserStream]) {
        
    }

    
    func stateDidUpdate(for session: VTokBaseSession) {
        self.baseSession = session
        switch session.state {

        case .calling:
            break
        case .ringing:
            break
        case .connected:
            callHangupTimer.invalidate()
            counter = 0
            break
        case .failed:
            break
        case .rejected:
            print("test")
           // self.finishBroadcastWithError(SessionHangup.forceStop)
            
            break
        case .onhold:
            break
        case .busy:
            break
        case .missedCall:
            break
        case .receivedSessionInitiation:
            break
        case .invalidTarget:
            break
        case .hangup:
            wormhole.passMessageObject(nil, identifier: "sessionHangup")
            self.finishBroadcastWithError(SessionHangup.forceStop)
            print("test")
        case .tryingToConnect:
            break
        case .reconnect:
            break
        case .updateParticipent:
            break
        case .insufficientBalance:
            wormhole.passMessageObject(nil, identifier: "sessionHangup")
            self.finishBroadcastWithError(SessionHangup.forceStop)
        case .suspendedByProvider:
            wormhole.passMessageObject(nil, identifier: "sessionHangup")
            self.finishBroadcastWithError(SessionHangup.forceStop)
        }
        
        let message = String(session.connectedUsers.count) as NSString
        wormhole.passMessageObject(message, identifier: "participantAdded")
    }
    
    func didGetPublicUrl(for session: VTokBaseSession, with url: String) {
        let message : NSString =  url as NSString
        wormhole.passMessageObject(message, identifier: "didGetPublicURL")
    }
    
}



extension SampleHandler {
    func getRequestId() -> String {
        
        let generatable = IdGenerator()
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval)).stringValue()
        let tenantId = "12345"
        let requestId = self.request?.referenceID ?? ""
        let token = generatable.getUUID(string: time + tenantId + requestId)
        return token
        
    }
}

extension SampleHandler {
    func callHangupHandling() {
        callHangupTimer.invalidate()
        counter = 0
        callHangupTimer = Timer.scheduledTimer(timeInterval: 1,
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
                guard let session = self.baseSession else {return}
                self.counter = 0
                self.callHangupTimer.invalidate()
                switch session.sessionDirection {
                case .incoming:
                    self.vtokSdk?.reject(session: session)
                    self.wormhole.passMessageObject(nil, identifier: "sessionHangup")
                case .outgoing:
                    self.vtokSdk?.hangup(session: session)
                    
                }
                
               
            }
        }
      
        
    }
}
