//
//  ScreenShareBannerView.swift
//  IOS-combine
//
//  Created by usama farooq on 28/10/2021.
//

import UIKit
import MMWormhole
import iOSSDKStreaming

class ScreenShareBannerView: UIView {
    
    @IBOutlet weak var broadcastView: UIView!
    
    var streamingManager: StreamingMananger?
    let wormhole = MMWormhole(applicationGroupIdentifier: AppsGroup.APP_GROUP,
                              optionalDirectory: "wormhole")
    var screenShareData: ScreenShareAppData?
    
    override func awakeFromNib() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        broadcastView.addGestureRecognizer(tap)
        
        wormhole.listenForMessage(withIdentifier: "fetchBroadcastData") { messageObject in
            if let message = messageObject as? String {
                print(message)
                self.getScreenShareAppData(with: message)
            }
        }

    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil)  {
        wormhole.passMessageObject(nil, identifier: "getBroadcastSession")
        
//        wormhole.listenForMessage(withIdentifier: "getBroadcastSession", listener: nil)
    
    }
    
    static func getView(streamingManager: StreamingMananger) -> ScreenShareBannerView {
         let viewsArray = Bundle.main.loadNibNamed("ScreenShareBannerView", owner: self, options: nil) as AnyObject as? NSArray
             guard (viewsArray?.count)! < 0 else {
                 let view = viewsArray?.firstObject as! ScreenShareBannerView
                 view.translatesAutoresizingMaskIntoConstraints = false
                 view.streamingManager = streamingManager
                // view.streamingManager?.delegate = self
                 return view
             }
         
         return ScreenShareBannerView()
     }
    
    
    func getScreenShareAppData(with message: String) {
        
        guard let data = message.data(using: .utf8) else {return }
        screenShareData = try? JSONDecoder().decode(ScreenShareAppData.self, from: data)
        let userInfo: [AnyHashable: Any]? = ["callType": NotifyCallType.broadcastOnly.callType,
                                             "screenShareData": screenShareData,
                                             "groupId": 1  ]
        NotificationCenter.default.post(name: NotifyCallType.notificationName, object: userInfo)
        
    }
    
}
