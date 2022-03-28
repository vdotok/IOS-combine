//
//  StreamingManager.swift
//  IOS-combine
//
//  Created by usama farooq on 14/10/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
import iOSSDKStreaming
import UIKit

protocol StreamingDelegate: AnyObject {
    func configureLocalViewFor(session: VTokBaseSession, with steams: [UserStream])
    func configureRemoteViews(for session: VTokBaseSession, with streams: [UserStream])
    func didGetPublicUrl(for session: VTokBaseSession, with url: String)
    func stateDidUpdate(for session: VTokBaseSession)
    func sessionTimeDidUpdate(with value: String)
    
}


class StreamingMananger {
    weak var delegate: StreamingDelegate?
    var remoteStreams: [UserStream] = []
    var session: VTokBaseSession? =  nil
    var vtokSDK: VTokSDK? {
        didSet {
            print("vtok sdk did set")
        }
    }
    var groupID: Int? = nil
    var url: String? = nil
    
    init(vtokSDK: VTokSDK? = nil) {
        self.vtokSDK = vtokSDK
    }
    
    func getStreams() {
        guard let sdk = vtokSDK else {return }
        sdk.fetchStreams()
    }
    
    func makeCall(session: VTokBaseSession) {
        
    }
    
    func activeSession() -> Int {
        guard let sdk = vtokSDK else {return 0}
        return sdk.sessionCount()
    }
}

extension StreamingMananger: SessionDelegate {
    func sessionTimeDidUpdate(with value: String) {
        delegate?.sessionTimeDidUpdate(with: value)
    }
    
    func configureLocalViewFor(session: VTokBaseSession, with stream: [UserStream]) {
        remoteStreams = stream
        self.session = session
        delegate?.configureLocalViewFor(session: session, with: stream)
    }
    
    func configureRemoteViews(for session: VTokBaseSession, with streams: [UserStream]) {
        remoteStreams = streams
        self.session = session
        delegate?.configureRemoteViews(for: session, with: streams)
    }
    
    func didGetPublicUrl(for session: VTokBaseSession, with url: String) {
        self.session = session
        delegate?.didGetPublicUrl(for: session, with: url)
    }
    
    func stateDidUpdate(for session: VTokBaseSession) {
        delegate?.stateDidUpdate(for: session)
    }
    

    
    
}
