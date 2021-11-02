//
//  SmallCallingView.swift
//  IOS-combine
//
//  Created by usama farooq on 20/10/2021.
//

import Foundation
import UIKit
import iOSSDKStreaming

protocol SmallCallingViewDelegate: AnyObject {
    func didTapView()
}

class SmallCallingView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: SmallCallingViewDelegate?
    var streamingManager: StreamingMananger?
    var streams: [UserStream] = []
    var groupID: Int? = nil
    var session: VTokBaseSession?
    
    override func awakeFromNib() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView?.register(UINib(nibName: "GroupCallingCell", bundle: nil), forCellWithReuseIdentifier: "GroupCallingCell")
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.collectionView.addGestureRecognizer(tap)
    }
    
   static func getView(streamingManager: StreamingMananger) -> SmallCallingView {
        let viewsArray = Bundle.main.loadNibNamed("SmallCallingView", owner: self, options: nil) as AnyObject as? NSArray
            guard (viewsArray?.count)! < 0 else {
                let view = viewsArray?.firstObject as! SmallCallingView
                view.translatesAutoresizingMaskIntoConstraints = false
                view.streamingManager = streamingManager
               // view.streamingManager?.delegate = self
                return view
            }
        
        return SmallCallingView()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        let userInfo: [AnyHashable: Any]? = ["callType": NotifyCallType.fetchStreams.callType,
                                             "groupId": streamingManager?.groupID ?? 0,
                                             "session": session ]
        NotificationCenter.default.post(name: NotifyCallType.notificationName, object: userInfo)
        
        delegate?.didTapView()
    }
    
    func getUserStream() {
        guard let manager = streamingManager else {return}
        streamingManager?.delegate = self
        manager.getStreams()
        collectionView.reloadData()
    }
    
}

extension SmallCallingView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return streams.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCallingCell", for: indexPath) as! GroupCallingCell
        cell.configure(with: streams[indexPath.row], users: nil)
        return cell
    }

}

extension SmallCallingView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 5, height: 100)
    }
}

protocol SmallCallingViewModel {
    

}

class SmallCallingViewModelImpl: SmallCallingViewModel {
    
}

extension SmallCallingView: StreamingDelegate {

    
    func configureLocalViewFor(session: VTokBaseSession, with steams: [UserStream]) {
     //   guard let renderer = steams.first?.renderer else {return}
        self.streams = steams
        collectionView.reloadData()
//        output?(.configureLocal(view: renderer, session: session))
    }
    
    func configureRemoteViews(for session: VTokBaseSession, with streams: [UserStream]) {
        
        if session.callType == .onetomany  {
            if let index = self.streams.firstIndex(where: {$0.sessionUUID == streams.first?.sessionUUID}) {
                self.streams[index] = streams.first!
            } else {
                guard let stream = streams.first else {return}
                self.streams.append(stream)
            }
           
        } else {
            self.streams = streams
        }
        self.session = session
        
        collectionView.reloadData()
    }
    
    func didGetPublicUrl(for session: VTokBaseSession, with url: String) {
        
    }
    
    func stateDidUpdate(for session: VTokBaseSession) {
        switch session.state {
        case .rejected:
            NotificationCenter.default.post(name: Notification.Name.hangup, object: nil)
        case .hangup:
            NotificationCenter.default.post(name: Notification.Name.hangup, object: nil)
        default:
            break
        }
    }
    
    
}
