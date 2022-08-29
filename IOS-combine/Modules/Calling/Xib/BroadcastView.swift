//
//  BroadcastView.swift
//  iOS-one2many
//
//  Created by usama farooq on 09/07/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//


//MARKTags

// 0 -> call renderer
// 1 -> paused call view
// 2 -> screenshare renderer
// 3 -> paused screenshare view



import UIKit
import iOSSDKStreaming
import MMWormhole
import ReplayKit
import AVKit
import WebKit

protocol BroadcastDelegate: AnyObject {
    func didTapMuteSS(for baseSession: VTokBaseSession, state: AudioState)
    func didTapHangUp(for session: VTokBaseSession)
    func didTapSpeaker(for session: VTokBaseSession, state: SpeakerState)
    func didTapFlipCamera(for session: VTokBaseSession, type: CameraType)
    func didTapVideo(for session: VTokBaseSession, type: VideoState)
    func didTapStream( with state: StreamStatus )
    func didTapRoute()
    func didTapDismiss()

    
}

class BroadcastView: UIView {
   
    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var smallLocalView: DraggableView! {
        didSet {
            smallLocalView.clipsToBounds = true
            smallLocalView.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var screenShareBtn: UIButton!
    @IBOutlet weak var hangupBtn: UIButton!
    @IBOutlet weak var copyURL: UIButton! {
        didSet {
            copyURL.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var screenShareAudio: UIButton!
    @IBOutlet weak var cameraSwitchIcon: UIButton!
    @IBOutlet weak var speakerIcon: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var broadCastDummyView: UIStackView!
    @IBOutlet weak var streamcontrolView: UIStackView!{
        didSet{
            streamcontrolView.isHidden = true
        }
    }
    @IBOutlet weak var copyUrlBtn: UIButton! {
        didSet {
            copyUrlBtn.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var broadCastTitle: UILabel!
    @IBOutlet weak var broadCastIcon: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var connectedUser: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var routePickerViewContainer: UIView!
    
    var externalWindow: UIWindow!
    var secondScreenView : UIView?
    var testScreen: UIScreen = UIScreen()
    var selectedStreams: [UserStream] = []
    
    var screenSharePausedView: UIView {
        
        let screenSharePausedView = UIView()
        screenSharePausedView.backgroundColor = .white
        let broadCastView = UIImageView(image: UIImage(named: "broadcast"))
        broadCastView.addConstraintsFor(width: 80, and: 80)
        let message = UILabel()
        message.numberOfLines = 0
        message.text = "Stream paused"
        message.setContentCompressionResistancePriority(.required, for: .vertical)
        let stackView = UIStackView(arrangedSubviews: [message, broadCastView])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        
        screenSharePausedView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.fixInMiddleOfSuperView()
        
        screenSharePausedView.tag = 1
        
        return screenSharePausedView
    }
    
    
    var videoPausedView: UIView {
        let videoPausedView = UIView()
        videoPausedView.backgroundColor = .white
        let broadCastView = UIImageView(image: UIImage(named: "broadcast"))
        broadCastView.addConstraintsFor(width: 80, and: 80)
        broadCastView.contentMode = .scaleAspectFit
        let message = UILabel()
        message.numberOfLines = 0
        message.text = "Stream paused"
        message.setContentCompressionResistancePriority(.required, for: .vertical)
        let stackView = UIStackView(arrangedSubviews: [message, broadCastView])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        stackView.alignment = .center
        videoPausedView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.fixInMiddleOfSuperView()
        videoPausedView.tag = 0
        return videoPausedView
    }
    
    var publicURL: String?
    var session: VTokBaseSession? {
        didSet{
            if session?.sessionDirection == .incoming{
                streamcontrolView?.isHidden = false
            }
        }
    }
    weak var delegate: BroadcastDelegate?
    private var counter: Int = 0
    let wormhole = MMWormhole(applicationGroupIdentifier: AppsGroup.APP_GROUP,
                              optionalDirectory: "wormhole")
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addNotificationObserver()
         addRoutePicker()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapLocalView))
        tap.numberOfTapsRequired = 2
        smallLocalView.addGestureRecognizer(tap)
        smallLocalView.frame = CGRect(x: UIScreen.main.bounds.size.width - smallLocalView.frame.size.width + 1.1, y: UIScreen.main.bounds.size.height - smallLocalView.frame.size.height * 1.1, width: 120, height: 170)
        webView.navigationDelegate = self
        let url = URL(string: "https://www.google.com")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        wormhole.passMessageObject(nil, identifier: "commandScreenShareStates")
        listenForSSButtonStates()
       
    }
    
    
    
    @IBAction func didTapStream(_ sender: UIButton) {
        delegate?.didTapStream(with: .initiate)
    }
    
    
    @IBAction func didTapStreamPlay(_ sender: UIButton) {
//        sender.isHighlighted = !sender.isHighlighted
        delegate?.didTapStream(with: sender.isHighlighted == true ? .play : .pause)
    }
    
    @IBAction func didTapStreamStop(_ sender: UIButton) {
        sender.isHighlighted = !sender.isHighlighted
        delegate?.didTapStream(with: .stop)
    }
    
    
    @IBAction func didTapPlay(_ sender: UIButton) {
        
    }

        @IBAction func didTapRoute(_ sender: UIButton) {
            delegate?.didTapRoute()
    
        }
        
        @IBAction func didTapAppAudio(_ sender: UIButton) {
            screenShareAudio.isSelected = !sender.isSelected
            let message = getScreenShareAudio(state: screenShareAudio.isSelected ? .none : .passAll)
            wormhole.passMessageObject(message, identifier: "updateAudioState")
        }
        
        @IBAction func didTapScreenShare(_ sender: UIButton) {
            screenShareBtn.isSelected = !sender.isSelected
            let message = getScreenShareScreen(state: screenShareBtn.isSelected ? .none : .passAll)
            wormhole.passMessageObject(message, identifier: "updateScreenState")
        }
        
        @IBAction func didTapHangup(_ sender: UIButton) {
            guard let session = session else {return}
            delegate?.didTapHangUp(for: session)
        }
        
        @IBAction func didTapFlip(_ sender: UIButton) {
            sender.isSelected = !sender.isSelected
            guard let session = session else {return}
            delegate?.didTapFlipCamera(for: session, type: sender.isSelected ? .front : .rear)
        }
        
        @IBAction func didTapSpeaker(_ sender: UIButton) {
            sender.isSelected = !sender.isSelected
            guard let session = session else {return}
            
            switch session.sessionMediaType {
            case .audioCall:
                delegate?.didTapSpeaker(for: session , state: sender.isSelected ? .onSpeaker : .onEarPiece)
            case .videoCall:
                delegate?.didTapSpeaker(for: session , state: sender.isSelected ? .onSpeaker : .onEarPiece)
               
            }
        }
        
        @IBAction func didTapAppleTV(_ sender: UIButton) {
            setUpExternal(screen: testScreen, streams: selectedStreams)
        }
        
        @IBAction func didTapMute(_ sender: UIButton) {
            sender.isSelected = !sender.isSelected
            guard let session = session else {return}
            
            switch session.broadcastOption {
            case .screenShareWithMicAudio:
                screenShareAudio.isSelected = sender.isSelected
                let message = getScreenShareAudio(state: screenShareAudio.isSelected ? .none : .passAll)
                wormhole.passMessageObject(message, identifier: "updateAudioState")
            default:
                delegate?.didTapMuteSS(for: session, state: sender.isSelected ? .mute : .unMute)
            }
        }
        
        @IBAction func didTapCopyURL(_ sender: UIButton) {
            guard let url = publicURL else { return }
            print("<<<<<public url \(url)")
            let pastBoard = UIPasteboard.general
            pastBoard.string = url
            ProgressHud.showMessage(text: "URL coppied")
        }
        
        @IBAction func didTapVideo(_ sender: UIButton) {
            sender.isSelected = !sender.isSelected
            guard let session = session else {return}
            delegate?.didTapVideo(for: session, type: sender.isSelected ? .videoDisabled : .videoEnabled)
        }
        
    @IBAction func didTapBack(_ sender: UIButton) {
        delegate?.didTapDismiss()
    }
    
        func addNotificationObserver() {
            NotificationCenter.default.addObserver(self, selector: #selector(handleScreenDidConnect(_:)), name: UIScreen.didConnectNotification , object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleScreenDidDisconnect(_:)), name: UIScreen.didDisconnectNotification , object: nil)
            
        }
        
        @objc  func handleScreenDidConnect(_ notification: Notification) {
            guard let newScreen = notification.object as? UIScreen else {
                return
            }
            self.testScreen = newScreen
            setUpExternal(screen: testScreen, streams: selectedStreams)
                
        }
        
        @objc   func handleScreenDidDisconnect(_ notification: Notification){
            guard externalWindow != nil else {
                return
            }
            externalWindow.isHidden = true
            externalWindow = nil
            
        }
        
        @objc func didTapLocalView()  {
            guard let session = session else {return}
            switch session.sessionDirection {
            case .incoming:
                guard let smallView = smallLocalView, let largeView = localView else {return}
                let smallSubView = smallView.subviews.first!
                let largeSubView = largeView.subviews.first!
                smallView.removeAllSubViews()
                largeView.removeAllSubViews()
                smallView.addSubview(largeSubView)
                largeSubView.fixInSuperView()
                largeView.addSubview(smallSubView)
                smallSubView.fixInSuperView()
                let callTag = smallView.tag
                let ssTag = largeView.tag
                smallView.tag = ssTag
                largeView.tag = callTag
                
            default:
                break
            }
        }
        
        func updateUser(count: Int) {
            if count != 0 {
                connectedUser.text = "+ \(count)"
                connectedUser.isHidden = false
            } else {
                connectedUser.isHidden = true
            }
           
        }
        
        private func getScreenShareScreen(state: ScreenShareBytes) -> NSString {
            let data = ScreenShareScreenState(screenShareScreen: state)
            let jsonData = try! JSONEncoder().encode(data)
            let jsonString = String(data: jsonData, encoding: .utf8)! as NSString
            return jsonString
        }
        
        private func getScreenShareAudio(state: ScreenShareBytes) -> NSString {
            let data = ScreenShareAudioState(screenShareAudio: state)
            let jsonData = try! JSONEncoder().encode(data)
            let jsonString = String(data: jsonData, encoding: .utf8)! as NSString
            return jsonString
        }
        
    
    func update(for session: VTokBaseSession) {
        self.session = session
        
        handleSessionState(session: session)
        switch session.sessionDirection {
        case .incoming:
            setIncomingViews(for: session)
        case .outgoing:
            setOutGoingView(for: session)
        }
        
        
    }
    
    func handleSessionState(session: VTokBaseSession) {
        switch session.state {
        case .missedCall:
            delegate?.didTapDismiss()
        case .hangup:
            delegate?.didTapDismiss()
        case .rejected:
            delegate?.didTapDismiss()
        case .suspendedByProvider:
            delegate?.didTapDismiss()
        case .insufficientBalance:
            delegate?.didTapDismiss()
        default:
            break
            
        }
    }
    
    func setIncomingViews(for session: VTokBaseSession) {
        hangupBtn.isUserInteractionEnabled = false
        webView.isHidden = true
        cameraButton.isHidden = true
        muteButton.isHidden = true
        broadCastTitle.isHidden = true
        screenShareBtn.isHidden = true
        screenShareAudio.isHidden = true
        cameraSwitchIcon.isHidden = true
        muteButton.isHidden = true
        speakerIcon.isHidden = false
        titlelabel.isHidden = true
        copyURL.isHidden = true
        hangupBtn.isHidden = false
        
        if session.associatedSessionUUID != nil {
            smallLocalView.isHidden = false
        } else {
            smallLocalView.isHidden = true
        }
        
    }

    
//        func updateView(with session: VTokBaseSession) {
//            self.session = session
//            switch session.sessionDirection {
//            case .incoming:
//                broadCastTitle.isHidden = true
//                cameraButton.isHidden = true
//                    setIncomingView(for: session)
//            case .outgoing:
//                switch session.broadcastOption {
//                case .videoCall, .screenShareWithAppAudioAndVideoCall, .screenShareWithVideoCall:
//                    cameraButton.isHidden = false
//                default:
//                    cameraButton.isHidden = true
//                }
//                guard let broadCastType = session.broadcastType
//                else {return}
//                if timer == nil {
//                    configureTimer()
//                }
//

//                setOutGoingView(for: session)
//
//            }
//        }
        
        func updateURL(with url: String) {
            publicURL = url
            copyURL.isEnabled = true
            copyURL.backgroundColor = .appDarkGreenColor
            print("Hello this for test")
        }
        
        func configureView(with userStreams: [UserStream], and session: VTokBaseSession) {
            guard let stream = userStreams.first else {return}
            self.selectedStreams = [stream]
            configureTimer()
            
            if stream.stateInformation?.audioInformation == 0 {
                muteButton.isSelected = true
            } else {
                muteButton.isSelected = false
            }
            
            if stream.stateInformation?.videoInformation == 0 {
                cameraButton.isSelected = true
            } else {
                cameraButton.isSelected = false
            }
            
            self.session = session
            if session.sessionDirection == .incoming {
                setViewsForIncoming(session: session, with: stream)
            }
 
        }
        
        
        func handleStateView(session: VTokBaseSession, with userStream: UserStream){
            
            guard let stateInfo = userStream.stateInformation else {
                return
            }
       
            if stateInfo.videoInformation == 0 {
                switch session.sessionType {
                case .call:
                    let callContainerView : UIView! = localView.tag == 0 ? localView : smallLocalView
                    callContainerView.removeAllSubViews()
                    let videoPausedView = self.videoPausedView
                    callContainerView.addSubview(videoPausedView)
                    videoPausedView.fixInSuperView()
                    
                case .screenshare:
                    let ssContainerView : UIView! = localView.tag == 1 ? localView : smallLocalView
                    ssContainerView.removeAllSubViews()
                    let ssPausedView = self.screenSharePausedView
                    ssContainerView.addSubview(ssPausedView)
                    ssPausedView.fixInSuperView()
            }
            
            }
            else {
                switch session.sessionType {
                case .call:
                    let callContainerView : UIView! = localView.tag == 0 ? localView : smallLocalView
                    callContainerView.removeAllSubViews()
                    callContainerView.addSubview(userStream.renderer)
                    userStream.renderer.fixInSuperView()
                    
                case .screenshare:
                    let ssContainerView : UIView! = localView.tag == 1 ? localView : smallLocalView
                    ssContainerView.removeAllSubViews()
                    ssContainerView.addSubview(userStream.renderer)
                    userStream.renderer.fixInSuperView()
                }
            }
        }
        
        
        private func setViewsForIncoming(session: VTokBaseSession, with userStream: UserStream) {
        
            hangupBtn.isUserInteractionEnabled = true
            switch session.sessionType {
            case .call:
                if session.associatedSessionUUID != nil {
                    let callView: UIView! = localView.tag == 0 ? localView : smallLocalView
                    callView.isHidden = false
                    callView.removeAllSubViews()
                    callView.addSubview(userStream.renderer)
                    userStream.renderer.fixInSuperView()
                    callView.tag = callView.tag
                    
                } else {
                    
                    localView.removeAllSubViews()
                    localView.addSubview(userStream.renderer)
                    smallLocalView.isHidden = true
                    userStream.renderer.translatesAutoresizingMaskIntoConstraints = false
                    userStream.renderer.fixInSuperView()
                    localView.tag = 0
                }
            case .screenshare:
                
                let ssView: UIView! = localView.tag == 1 ? localView : smallLocalView
                let callView: UIView! = localView.tag == 0 ? localView : smallLocalView
                
                titlelabel.isHidden = true
                broadCastDummyView.isHidden = true
                ssView.removeAllSubViews()
                ssView.addSubview(userStream.renderer)
                userStream.renderer.fixInSuperView()
                ssView.tag = ssView.tag
                if session.associatedSessionUUID != nil {
                    ssView.isHidden = false
                    callView.isHidden = false
                    
                } else {
                    ssView.isHidden = false
                    callView.isHidden = true
                }
            }
            
            handleStateView(session: session, with: userStream)
            
           
            
        }
        
        func setViewsForOutGoing(session: VTokBaseSession, stream: UserStream) {
            if session.broadcastOption == .videoCall {

                localView.isHidden = false
                localView.removeAllSubViews()
                localView.addSubview(stream.renderer)
                localView.removeAllSubViews()
                localView.addSubview(stream.renderer)
                stream.renderer.translatesAutoresizingMaskIntoConstraints = false
                stream.renderer.fixInSuperView()
              
                
            } else {

                localView.isHidden = true
                smallLocalView.isHidden = false
                smallLocalView.removeAllSubViews()
                smallLocalView.addSubview(stream.renderer)
                stream.renderer.translatesAutoresizingMaskIntoConstraints = false
                stream.renderer.fixInSuperView()
            }
            
        }

        private func setIncomingView(for session: VTokBaseSession) {
            copyURL.isHidden = true
           
     
            if let _ = session.associatedSessionUUID {
                screenShareBtn.isHidden = true
                screenShareAudio.isHidden = true
                cameraSwitchIcon.isHidden = true
                speakerIcon.isHidden = false
                smallLocalView.isHidden = false
                muteButton.isHidden = true
               
            } else {
                screenShareBtn.isHidden = true
                screenShareAudio.isHidden = true
                cameraSwitchIcon.isHidden = true
                speakerIcon.isHidden = false
                smallLocalView.isHidden = true
                muteButton.isHidden = true
                
            }
            
        }
        
        private func setOutGoingView(for session: VTokBaseSession) {
            self.updateUser(count: session.connectedUsers.count)
            hangupBtn.isHidden = false
            switch session.broadcastType {
            case .group:
                broadCastTitle.text = "Group BroadCast"
                copyURL.isHidden = true
            case .publicURL:
                broadCastTitle.text = "Public BroadCast"
                copyURL.isHidden = false
                
            default:
                break
            }
            guard let options = session.broadcastOption else {return}
            switch options {
            case .screenShareWithAppAudio:
                screenShareBtn.isHidden = false
                screenShareAudio.isHidden = false
                cameraSwitchIcon.isHidden = true
                speakerIcon.isHidden = true
                smallLocalView.isHidden = true
                muteButton.isHidden = true
                broadCastDummyView.isHidden = true
                addRPViewToSSButton()
                webView.isHidden = false
                
            case .screenShareWithMicAudio:
                screenShareBtn.isHidden = false
                screenShareAudio.isHidden = true
                cameraSwitchIcon.isHidden = true
                speakerIcon.isHidden = true
                smallLocalView.isHidden = true
                muteButton.isHidden = false
                broadCastDummyView.isHidden = true
                addRPViewToSSButton()
                webView.isHidden = false
                
            case .videoCall:
                webView.isHidden = true
                screenShareBtn.isHidden = true
                screenShareAudio.isHidden = true
                cameraSwitchIcon.isHidden = false
                speakerIcon.isHidden = true
                smallLocalView.isHidden = true
                muteButton.isHidden = false
                titlelabel.isHidden = true
                broadCastIcon.isHidden = true
                hangupBtn.isHidden = false
                cameraButton.isHidden = false
                if session.broadcastType == .publicURL {
                    copyURL.isHidden = false
                    broadCastDummyView.isHidden = false
                }
            case .screenShareWithAppAudioAndVideoCall, .screenShareWithVideoCall:
                webView.isHidden = false
                screenShareBtn.isHidden = false
                screenShareAudio.isHidden = false
                cameraSwitchIcon.isHidden = false
                speakerIcon.isHidden = true
                smallLocalView.isHidden = false
                muteButton.isHidden = false
                broadCastDummyView.isHidden = true
                addRPViewToSSButton()
                cameraButton.isHidden = false
            }
            
        }
    
    deinit {
        print("broadcastView")
    }

}


extension BroadcastView {
    static func loadView() -> BroadcastView {
        let viewsArray = Bundle.main.loadNibNamed("BroadcastView", owner: self, options: nil) as AnyObject as? NSArray
            guard (viewsArray?.count)! < 0 else{
                let view = viewsArray?.firstObject as! BroadcastView
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }
        return BroadcastView()
    }
    
    func addRPViewToSSButton() {
        
        let recordingView = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        recordingView.preferredExtension = AppsGroup.SCREEN_SHARE_PREFERED_EXTENSION
        guard let options = session?.broadcastOption else {return}
        
        switch options {
        case .screenShareWithMicAudio:
            recordingView.showsMicrophoneButton = true
        default:
            recordingView.showsMicrophoneButton = false
        }
        recordingView.tintColor = .white
        
        for subView in recordingView.subviews {
            if subView is UIButton, let button = subView as? UIButton{
                if let _ = UIImage(named: "EndScreenShare") {
                    button.setImage(nil, for: .normal)
                }
            }
        }
        hangupBtn.addSubview(recordingView)

    }
}


extension BroadcastView {
    private func configureTimer() {
        switch session?.broadcastOption {
        case .screenShareWithAppAudio, .screenShareWithMicAudio:
            listenForScene()
        default:
            break
        }
        
    }
}

extension BroadcastView {
    func listenForScene() {
        NotificationCenter.default.addObserver(self, selector: #selector(didRecieveActive(notification:)), name: Notification.Name("sceneActive"), object: nil)
    }
    
    @objc  func didRecieveActive(notification: Notification) {
        print(notification.object ?? "")
        guard let time = notification.userInfo?["interval"] as? TimeInterval else {return}
        counter += Int(time)
        
    }
}


extension BroadcastView {
    
    func addRoutePicker(){
        let routePickerView = AVRoutePickerView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        routePickerView.backgroundColor = UIColor.clear
        routePickerViewContainer.addSubview(routePickerView)
        routePickerView.prioritizesVideoDevices = true
        routePickerView.fixInSuperView()
    }
}


extension BroadcastView {
    func setUpExternal(screen: UIScreen, streams: [UserStream]) {
        self.externalWindow = UIWindow(frame: screen.bounds)
        
        //windows require a root view controller
           // let viewcontroller = TVBroadCastBuilder().build(with: nil, userStreams: streams)
        self.externalWindow.rootViewController = UIViewController()
        
        //tell the window which screen to use
        self.externalWindow?.screen = screen
        guard let firstStream = streams.first else {return}
        let stream = firstStream
        let renderer = stream.renderer
        self.externalWindow.addSubview(renderer)
        renderer.fixInSuperView()
        
        
        self.externalWindow?.isHidden = false

    }
    
    func updateSSButton(audioState: Bool, videoState: Bool) {
       
    }
    
    
    func listenForSSButtonStates() {
        wormhole.listenForMessage(withIdentifier: "configureLocalStream" ) { [weak self] message -> Void in
            guard let self = self else {return}
            if let message = message as? String {

                let data = message.convertToDictionary()
                guard let dict = data else {return}
                let videoData = dict["videoState"] as! Int
                let audioData = dict["audioState"] as! Int
                self.screenShareAudio.isSelected = audioData == 1 ? true : false
                self.screenShareBtn.isSelected = videoData == 1 ? true : false
                guard let session = self.session else {return}
                if session.broadcastOption == .screenShareWithMicAudio {
                    self.muteButton.isSelected = audioData == 1 ? true : false
                }
                guard let connectedUsers = dict["connectedUsers"] as? Int else {return}
                self.updateUser(count: connectedUsers)
               print(audioData)
            }
        }
    }
}

extension BroadcastView: WKNavigationDelegate {
    
}

