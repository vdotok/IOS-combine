//
//  GroupCallingUpdatedView.swift
//  IOS-combine
//
//  Created by usama farooq on 18/10/2021.
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
        delegate?.didTapSpeaker(baseSession: session , state: sender.isSelected ? .onSpeaker : .onEarPiece)
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
        delegate?.didTapVideo(for: session, state: sender.isSelected ? .videoDisabled :.videoEnabled )
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
      
        callStatus.isHidden = false
        userNames.isHidden = false
        speakerButton.isHidden = true
        self.session = session
        switch session.state {
        case .calling:
            callStatus.text = "Calling.."
            cameraSwitch.isHidden = true
            speakerButton.isHidden = true
            cameraButton.isEnabled = false
            setNames()
        case .ringing:
            cameraSwitch.isHidden = true
            speakerButton.isHidden = true
            callStatus.text = "Ringing.."
            cameraButton.isEnabled = false
            setNames()
        case .connected:
            connectedState()
       
        case .rejected:
            callStatus.text = "Rejected"
            
        default:
            break
        }
    }
    
    func updateAudioVideoview(for session: VTokBaseSession) {
        
        self.session = session
      
        switch session.sessionMediaType {
        case .audioCall:
//            titleLable.text = "You are audio calling with"
//            localView.isHidden = true
            cameraSwitch.isHidden = true
            cameraButton.isHidden = true
        case .videoCall:
//            titleLable.text = "You are video calling with"
//            localView.isHidden = false
            cameraSwitch.isHidden = false
            cameraButton.isHidden = false
       
        }
    }
    
    private func connectedState() {
        userAvatar.isHidden = true
        callStatus.isHidden = true
//        connectedView.isHidden = false
        userNames.isHidden = true
        speakerButton.isHidden = false
        cameraSwitch.isHidden = false
        speakerButton.isHidden = false
        if timer != nil {
            configureTimer()
        }
       
    }

}

extension GroupCallingUpdatedView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userStreams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCallingCell", for: indexPath) as! GroupCallingCell
//
//        let stream = viewModel!.userStreams[indexPath.row]
        let stream = userStreams[indexPath.row]
        cell.configure(with: stream, users: users!)
        return cell
    }
    
    func updateDataSource(with streams: [UserStream], session: VTokBaseSession) {
        connectedState()
        self.session = session
        userStreams = streams.filter({$0.referenceID != selectedStream?.referenceID})
        setNames()
        guard streams.first?.sessionMediaType != .audioCall else {
            collectionView.reloadData()
            return
            
        }
        if selectedStream == nil {
            selectedStream = userStreams[0]
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
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { [weak self] in
          //  self?.cameraButton.isEnabled = true
        })
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
        return CGSize(width: UIScreen.main.bounds.width / 4 , height: 200)
    }
}


protocol GroGroupCallingUpdatedViewModel: AnyObject {
    var userStreams: [UserStream] {get set}
}

class GroGroupCallingUpdatedViewModelImpl: GroGroupCallingUpdatedViewModel {
    var userStreams: [UserStream]  = []
    
}

extension GroupCallingUpdatedView {
    private func configureTimer() {
        timer?.invalidate()
        timer = nil
        counter = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc private func timerAction() {
        counter += 1
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds: counter)
        var timeString = ""
        if h > 0 {
            timeString += intervalFormatter(interval: h) + ":"
        }
        timeString += intervalFormatter(interval: m) + ":" +
                        intervalFormatter(interval: s)
        callTime?.text = timeString
    }
    
    private func intervalFormatter(interval: Int) -> String {
        if interval < 10 {
            return "0\(interval)"
        }
        return "\(interval)"
    }
    
    private func secondsToHoursMinutesSeconds (seconds :Int) -> (hours: Int, minutes: Int, seconds: Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
