//
//  GroupCallingUpdatedView.swift
//  IOS-combine
//
//  Created by usama farooq on 18/10/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit
import iOSSDKStreaming
protocol VideoDelegate: AnyObject {
    func didTapVideo(for baseSession: VTokBaseSession, state: VideoState)
    func didTapMute(for baseSession: VTokBaseSession, state: AudioState)
    func didTapEnd(for baseSession: VTokBaseSession)
    func didTapFlip(for baseSession: VTokBaseSession, type: CameraType)
    func didTapSpeaker(baseSession: VTokBaseSession, state: SpeakerState)
    func didTapDismiss()
}

class GroupCallingUpdatedView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var remoteView: UIView!
    @IBOutlet weak var cameraSwitch: UIButton!
    @IBOutlet weak var userNames: UILabel!
    @IBOutlet weak var callTime: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var callStatus: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var callingStackView: UIStackView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var connectedUser: UILabel!

    var viewModel: GroGroupCallingUpdatedViewModel?
    var session: VTokBaseSession? {
        didSet {
            print(session)
        }
    }
    var userStreams: [UserStream]  = []
    weak var delegate: VideoDelegate?
    var users: [User]?
    private var counter: Int = 0
    private weak var timer: Timer?
    
    var selectedStream: UserStream?
    
    
    
    @IBAction func didTapSpeaker(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let session = session else {return }
        
        switch session.sessionMediaType {
        case .audioCall:
            delegate?.didTapSpeaker(baseSession: session , state: sender.isSelected ? .onSpeaker : .onEarPiece)
        case .videoCall:
            delegate?.didTapSpeaker(baseSession: session , state: sender.isSelected ? .onEarPiece : .onSpeaker)
           
        }
        
       
    }
    
    @IBAction func didTapMute(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let session = session else { return }
        delegate?.didTapMute(for: session, state: sender.isSelected ? .mute : .unMute)
    }
    
    @IBAction func didTapCameraSwitch(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let session = session else { return }
        delegate?.didTapFlip(for: session, type: sender.isSelected ? .front : .rear)
    }
    
    @IBAction func didTapVideo(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let session = session else {return }
   //     localView.isHidden = sender.isSelected ? true : false
        cameraSwitch.isEnabled = sender.isSelected ? false : true
        delegate?.didTapVideo(for: session, state: sender.isSelected ? .videoDisabled : .videoEnabled)
    }
    
    @IBAction func didTapHangup(_ sender: UIButton) {
        guard let session = session else { return }
        delegate?.didTapEnd(for: session)
    }
    
    @IBAction func didTapChat(_ sender: UIButton) {
        delegate?.didTapDismiss()
    }
    
    override func awakeFromNib() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        viewModel = GroGroupCallingUpdatedViewModelImpl()
        collectionView.register(UINib(nibName: "GroupCallingCell", bundle: nil), forCellWithReuseIdentifier: "GroupCallingCell")
        // Do any additional setup after loading the view.
    }
    
    static func getView(user: [User]? = nil) -> GroupCallingUpdatedView {
        let viewsArray = Bundle.main.loadNibNamed("GroupCallingUpdatedView", owner: self, options: nil) as AnyObject as? NSArray
            guard (viewsArray?.count)! < 0 else{
                let view = viewsArray?.firstObject as! GroupCallingUpdatedView
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }
        return GroupCallingUpdatedView()
    }
    
    private func setNames() {
        let tempUser = users?.filter({session?.to.contains($0.refID) ?? false})
        let names = tempUser?.map({$0.fullName}).joined(separator: "\n")
        userNames.text = names
    }
    
    
    func updateView(for session: VTokBaseSession) {
        switch session.sessionDirection {
        case .outgoing:
           viewsForOutGoing(session: session)
        case .incoming:
            setViewsForIncoming(session: session)
        }
        
        switch session.sessionMediaType {
            
        case .audioCall:
            switch session.callType {
            case .onetoone:
                guard let users = users, let user = users.first, session.sessionDirection == .outgoing else {return}
                groupName.text = user.fullName
            default:
                break
            }
            titleLable.text = "You are audio calling with"
            cameraSwitch.isHidden = true
            cameraButton.isHidden = true
            
        case .videoCall:
            switch session.callType {
            case .onetoone:
                guard let users = users, let user = users.first, session.sessionDirection == .outgoing else {return}
                groupName.text = user.fullName
                
            default:
                break
            }
            titleLable.text = "You are video calling with"
        }
    }
    
   private func setViewsForIncoming(session: VTokBaseSession) {
       switch session.state {
       case .connected:
           connectedState(session: session)
       case .hangup:
           delegate?.didTapDismiss()
       case .rejected:
           delegate?.didTapDismiss()
       case .missedCall:
           delegate?.didTapDismiss()
       default:
           break
       }
    }
    
   private func viewsForOutGoing(session: VTokBaseSession) {
    
       switch session.state {
           
       case .calling:
           callStatus.text = "Calling.."
           speakerButton.isHidden = true
           cameraButton.isEnabled = false
           setNames()
           cameraSwitch.isHidden = true
       case .ringing:
           cameraSwitch.isHidden = true
           speakerButton.isHidden = true
           callStatus.text = "Ringing.."
           cameraButton.isEnabled = false
           setNames()
       case .connected:
           connectedState(session: session)
       case .failed:
           delegate?.didTapDismiss()
       case .rejected:
           delegate?.didTapDismiss()
       case .busy:
           callStatus.text = "All users are busy"
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
               self?.delegate?.didTapDismiss()
           }
           
       case .missedCall:
           delegate?.didTapDismiss()
       case .invalidTarget:
           delegate?.didTapDismiss()
       case .hangup:
           delegate?.didTapDismiss()
       default:
           break
       }
    
    }
    
    
    func connectedState(session: VTokBaseSession) {
        backbutton.isHidden = false
        callStatus.isHidden = true
        userNames.isHidden = true
        speakerButton.isHidden = false
        if session.sessionMediaType == .videoCall {
            cameraSwitch.isHidden = false
            cameraButton.isEnabled = true
        }
        userAvatar.isHidden = true
        speakerButton.isHidden = false
       // configureTimer()
        callingStackView.isHidden = false
        cameraSwitch.isHidden = false
    }

}

extension GroupCallingUpdatedView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userStreams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCallingCell", for: indexPath) as! GroupCallingCell
        let stream = userStreams[indexPath.row]
        cell.configure(with: stream, users: users!)
        return cell
    }
    
    func setRemote(name: String) {
        groupName.text = name
        titleLable.text = "You are video calling with"
    }
    
    func updateDataSource(with streams: [UserStream], session: VTokBaseSession) {
//        connectedState()
        guard streams.count != 1 else {return}
        self.session = session
        let newRefIds = streams.map({$0.referenceID})
        let oldRefIds = self.userStreams.map({$0.referenceID})
        if let seletectedStream = selectedStream {
            if !newRefIds.contains(seletectedStream.referenceID) {
                selectedStream = streams[0]
            }
        }
       
        
        userStreams = streams.filter({$0.referenceID != selectedStream?.referenceID})
//        setNames()
        guard streams.first?.sessionMediaType != .audioCall else {
        collectionView.reloadData()
            cameraSwitch.isHidden = true
            return
        }
        
        self.userStreams = streams
        guard let stream = userStreams.first else {return}
        selectedStream = selectedStream == nil ? stream : selectedStream
        selectedStream = userStreams.filter({$0.referenceID == selectedStream?.referenceID}).first

        userStreams =  userStreams.filter({$0.referenceID != selectedStream?.referenceID})
        for remoteView in remoteView.subviews {
            remoteView.removeFromSuperview()
        }
        remoteView.addSubview(selectedStream!.renderer)
        selectedStream?.renderer.fixInSuperView()
        collectionView.reloadData()
        
    }
    
    func updateViews(streams: [UserStream], session: VTokBaseSession) {
        self.userStreams  = streams
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedStream != nil {
            userStreams.append(selectedStream!)
            selectedStream = nil
        }
        
        selectedStream = userStreams[indexPath.row]
        userStreams =  userStreams.filter({$0.referenceID != selectedStream?.referenceID})
       
        for remoteView in remoteView.subviews {
            remoteView.removeFromSuperview()
        }
        remoteView.addSubview(selectedStream!.renderer)
        selectedStream?.renderer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedStream!.renderer.leadingAnchor.constraint(equalTo: self.remoteView.leadingAnchor),
            selectedStream!.renderer.trailingAnchor.constraint(equalTo:self.remoteView.trailingAnchor),
            selectedStream!.renderer.topAnchor.constraint(equalTo: self.remoteView.topAnchor),
            selectedStream!.renderer.bottomAnchor.constraint(equalTo: self.remoteView.bottomAnchor)
        ])
        collectionView.reloadData()
    }
    
    
}


extension GroupCallingUpdatedView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 4 , height: 100)
    }
}


protocol GroGroupCallingUpdatedViewModel: AnyObject {
    var userStreams: [UserStream] {get set}
}

class GroGroupCallingUpdatedViewModelImpl: GroGroupCallingUpdatedViewModel {
    var userStreams: [UserStream]  = []
    
}

extension GroupCallingUpdatedView {
}
