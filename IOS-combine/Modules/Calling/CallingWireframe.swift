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
    var callingManager: CallingManager
    // MARK: - Module setup -
    
    init(
        screenType: ScreenType,
        session: VTokBaseSession? = nil,
        broadCastData: BroadcastData? = nil,
        streamingManager: StreamingMananger,
        sessionDirection: SessionDirection,
        callingManager: CallingManager) {
            let moduleViewController = storyboard.instantiateViewController(ofType: CallingViewController.self)
            self.streamingManager = streamingManager
            self.callingManager = callingManager
            super.init(viewController: moduleViewController)
    
            let interactor = CallingInteractor()
            
            let presenter = CallingPresenter(view: moduleViewController, interactor: interactor, wireframe: self, screenType: screenType, session: session, broadCastData: broadCastData, streamingManager: streamingManager, sessionDirection: sessionDirection, callingManager: callingManager)
            moduleViewController.presenter = presenter
        }
    
}

// MARK: - Extensions -

extension CallingWireframe: CallingWireframeInterface {
    
    func moveToCalling(sdk: VTokSDK, particinats: [Participant], users: [User],sessionDirection: SessionDirection) {
//        let frame = CallingWireframe(vtokSdk: sdk, participants: particinats, screenType: .videoView, contact: users, streamingManager: streamingManager!, sessionDirection: sessionDirection)
        
        let frame = CallingWireframe(screenType: .videoView, streamingManager: streamingManager!, sessionDirection: sessionDirection, callingManager: callingManager)
        
        navigationController?.viewControllers.last?.presentWireframe(frame)
    }
    func moveToIncomingCall(sdk: VTokSDK, baseSession: VTokBaseSession, users: [User],sessionDirection: SessionDirection) {
        let frame = CallingWireframe(screenType: .incomingCall, session: baseSession, streamingManager: streamingManager!, sessionDirection: sessionDirection, callingManager: callingManager)
        navigationController?.presentWireframe(frame)

    }
    
    func moveToAudio(sdk: VTokSDK, participants: [Participant], users: [User],sessionDirection: SessionDirection) {
//        let frame = CallingWireframe(vtokSdk: sdk, participants: participants, screenType: .audioView, contact: users, streamingManager: streamingManager!, sessionDirection: sessionDirection)
        let frame = CallingWireframe(screenType: .audioView, streamingManager: streamingManager!, sessionDirection: sessionDirection, callingManager: callingManager)
        navigationController?.presentWireframe(frame)
    }
    
    
}
