//
//  StreamingManager.swift
//  IOS-combine
//
//  Created by usama farooq on 14/10/2021.
//

import Foundation
import iOSSDKStreaming


protocol StreamingDelegate: AnyObject {
    func configureLocalViewFor(session: VTokBaseSession, with steams: [UserStream])
    func configureRemoteViews(for session: VTokBaseSession, with streams: [UserStream])
    func didGetPublicUrl(for session: VTokBaseSession, with url: String)
    func stateDidUpdate(for session: VTokBaseSession)
    
}


class StreamingMananger {
    weak var delegate: StreamingDelegate?
    var remoteStreams: [UserStream] = []
    var vtokSDK: VTokSDK?
    var groupID: Int? = nil
    
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
    
//    func configureLocalViewFor(session: VTokBaseSession, renderer: UIView) {
//        delegate?.configureLocalViewFor(session: session, renderer: renderer)
//    }
    
    func configureLocalViewFor(session: VTokBaseSession, with stream: [UserStream]) {
        remoteStreams = stream
        delegate?.configureLocalViewFor(session: session, with: stream)
    }
    
    func configureRemoteViews(for session: VTokBaseSession, with streams: [UserStream]) {
        remoteStreams = streams
        delegate?.configureRemoteViews(for: session, with: streams)
    }
    
    func didGetPublicUrl(for session: VTokBaseSession, with url: String) {
        delegate?.didGetPublicUrl(for: session, with: url)
    }
    
    func stateDidUpdate(for session: VTokBaseSession) {
        delegate?.stateDidUpdate(for: session)
    }
    

    
    
}
