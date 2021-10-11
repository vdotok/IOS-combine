//
//  BroadcastOverlay.swift
//  IOS-combine
//
//  Created by usama farooq on 08/10/2021.
//

import UIKit
import iOSSDKStreaming
import VisualEffectView

class BroadcastOverlay: UIViewController {
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var screenShareAppAudioBtn: BorderButton!
    @IBOutlet weak var screenShareMicAudioBtn: BorderButton!
    @IBOutlet weak var continueBtn: UIButton! {
        didSet {
            continueBtn.layer.cornerRadius = 8
        }
    }
    var broadCastData: BroadcastData = BroadcastData(broadcastType: .none,
                                                     broadcastOptions: .screenShareWithAppAudio)
    @IBOutlet weak var camera: BorderButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        addBlureView()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapBroadCastOption(_ sender: UIButton) {
    
        switch sender.tag {
        case 102:
          // screen sharing with app audio
            guard !screenShareMicAudioBtn.isSelected else{return}
            screenShareAppAudioBtn.isSelected = !sender.isSelected
            broadCastData.broadcastOptions = .screenShareWithAppAudio
            
            break
        case 103:
            // screen sharing with mic
            guard !screenShareAppAudioBtn.isSelected else{return}
            screenShareMicAudioBtn.isSelected = !sender.isSelected
            break
        case 104:
        // camera
            camera.isSelected = !sender.isSelected
            break
        default:
            break
        }
        
        continueStatsHandling ()
    }
    
    @IBAction func didTapContinue(_ sender: UIButton) {
        broadCastButtonHandling()
        switch broadCastData.broadcastType {
        case .group:
            break
           // viewModel.moveToChat(with: broadCastData)
        case .publicURL:
            break
            if broadCastData.broadcastOptions != .videoCall {
//                self.viewModel.broadCastData = broadCastData
//                moveToPublicView()
            } else {
                
              //  self.viewModel.moveToCalling(with: broadCastData)
            }
        default:
            break
        }
        
    }
    
    @IBAction func didTapClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
   private func addBlureView() {
        let visualEffectView = VisualEffectView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

        // Configure the view with tint color, blur radius, etc
        visualEffectView.colorTint = .black
        visualEffectView.colorTintAlpha = 0.2
        visualEffectView.blurRadius = 10
        visualEffectView.scale = 1

        blurView.addSubview(visualEffectView)
    }
    
    private func broadCastButtonHandling() {
        
        if camera.isSelected {
            broadCastData.broadcastOptions = .videoCall
        }
        if screenShareMicAudioBtn.isSelected {
            broadCastData.broadcastOptions = .screenShareWithMicAudio
        }
         if screenShareAppAudioBtn.isSelected {
            broadCastData.broadcastOptions = .screenShareWithAppAudio
        }
         if camera.isSelected && screenShareMicAudioBtn.isSelected {
            broadCastData.broadcastOptions = .screenShareWithVideoCall
        }
         if camera.isSelected && screenShareAppAudioBtn.isSelected {
            broadCastData.broadcastOptions = .screenShareWithAppAudioAndVideoCall
        }
    }
    
    private func continueStatsHandling () {
        if screenShareAppAudioBtn.isSelected == true ||
           screenShareMicAudioBtn.isSelected == true ||
            camera.isSelected == true  {
            continueBtn.backgroundColor = broadCastData.broadcastType == .none ? .appDarkGray :  .appDarkGreenColor
            continueBtn.isEnabled =  broadCastData.broadcastType == .none ? false :  true
        } else {
            continueBtn.backgroundColor = .appDarkGray
            continueBtn.isEnabled = false
        }
    }

}
