//
//  CallingWireframe.swift
//  IOS-combine
//
//  Created by usama farooq on 02/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import iOSSDKStreaming

final class CallingWireframe: BaseWireframe<CallingViewController> {

    // MARK: - Private properties -

    private let storyboard = UIStoryboard(name: "Calling", bundle: nil)
    var streamingManager: StreamingMananger?
    // MARK: - Module setup -

    init(vtokSdk: VideoTalkSDK,
         participants: [Participant]?,
         screenType: ScreenType,
         session: VTokBaseSession? = nil,
         contact: [User]? = nil,
         broadCastData: BroadcastData? = nil,
         streamingManager: StreamingMananger,
         sessionDirection: SessionDirection) {
        let moduleViewController = storyboard.instantiateViewController(ofType: CallingViewController.self)
        super.init(viewController: moduleViewController)
        self.streamingManager = streamingManager
        let interactor = CallingInteractor()
        
        let presenter = CallingPresenter(view: moduleViewController, interactor: interactor, wireframe: self, vtokSdk: vtokSdk, participants: participants, screenType: screenType, session: session, users: contact, broadCastData: broadCastData, streamingManager: streamingManager, sessionDirection: sessionDirection)
        moduleViewController.presenter = presenter
    }

}

// MARK: - Extensions -

extension CallingWireframe: CallingWireframeInterface {
    
    func moveToCalling(sdk: VTokSDK, particinats: [Participant], users: [User],sessionDirection: SessionDirection) {
        let frame = CallingWireframe(vtokSdk: sdk, participants: particinats, screenType: .videoView, contact: users, streamingManager: streamingManager!, sessionDirection: sessionDirection)
        navigationController?.viewControllers.last?.presentWireframe(frame)
    }
    func moveToIncomingCall(sdk: VTokSDK, baseSession: VTokBaseSession, users: [User],sessionDirection: SessionDirection) {
        let frame = CallingWireframe(vtokSdk: sdk, participants: nil, screenType: .incomingCall, session: baseSession, contact: users, streamingManager: streamingManager!, sessionDirection: sessionDirection)
        navigationController?.presentWireframe(frame)

    }
    
    func moveToAudio(sdk: VTokSDK, participants: [Participant], users: [User],sessionDirection: SessionDirection) {
        let frame = CallingWireframe(vtokSdk: sdk, participants: participants, screenType: .audioView, contact: users, streamingManager: streamingManager!, sessionDirection: sessionDirection)
        navigationController?.presentWireframe(frame)
    }
    
    
}
