//
//  ChannelWireframe.swift
//  IOS-combine
//
//  Created by usama farooq on 30/08/2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import iOSSDKConnect
import iOSSDKStreaming

final class ChannelWireframe: BaseWireframe<ChannelViewController> {

    // MARK: - Private properties -

    private let storyboard = UIStoryboard(name: "Channel", bundle: nil)
    var streamingManager: StreamingMananger?

    // MARK: - Module setup -
    let interactor = ChannelInteractor()
    init(broadCastData: BroadcastData? = nil, streamingManager: StreamingMananger) {
        let moduleViewController = storyboard.instantiateViewController(ofType: ChannelViewController.self)
        super.init(viewController: moduleViewController)

        self.streamingManager = streamingManager
        let presenter = ChannelPresenter(view: moduleViewController, interactor: interactor, wireframe: self, streamingManager: streamingManager)
        moduleViewController.presenter = presenter
        presenter.interactor?.presenter = presenter
    }

}

// MARK: - Extensions -

extension ChannelWireframe: ChannelWireframeInterface {
    func moveToCalling(particinats: [Participant], users: [User], sdk: VTokSDK, broadCastData: BroadcastData?, screenType: ScreenType, session: VTokBaseSession?, sessionDirection: SessionDirection) {
        let frame = CallingWireframe(vtokSdk: sdk, participants: particinats, screenType: screenType, session: session,contact: users, broadCastData: broadCastData, streamingManager: streamingManager!, sessionDirection: sessionDirection)
        navigationController?.viewControllers.last?.presentWireframe(frame)
    }
    
    func moveToIncomingCall(sdk: VTokSDK, baseSession: VTokBaseSession, users: [User],sessionDirection: SessionDirection) {
        let frame = CallingWireframe(vtokSdk: sdk, participants: nil, screenType: .incomingCall, session: baseSession, contact: users, streamingManager: streamingManager!, sessionDirection: sessionDirection)
        navigationController?.presentWireframe(frame)
    }
    
    func moveToAudio(sdk: VTokSDK, participants: [Participant], users: [User], sessionDirection: SessionDirection) {
        let frame = CallingWireframe(vtokSdk: sdk, participants: participants, screenType: .audioView, contact: users, streamingManager: streamingManager!, sessionDirection: sessionDirection)
        navigationController?.presentWireframe(frame)
    }
    
    func move(to: ChannelNavigationOptions,client: ChatClient, group: Group?, user: UserResponse, messages: [ChatMessage], sdk: VTokSDK? = nil, streamingManager: StreamingMananger) {
        switch to {
        case .chat:
            guard let group = group else {return}
            navigationController?.pushWireframe(ChatWireframe(client: client, group: group, user: user, messages: messages, vtokSDK: sdk, streamingManager: streamingManager))
        case .broadcastOverlay:
            let vc = BroadcastOverlay()
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            vc.delegate = self
            navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    func moveToCreateGroup(client: ChatClient) {
        
        let frame = ContactWireframe(client: client, streamingManager: self.streamingManager!)
        navigationController?.pushWireframe(frame)
    }
    
    func dismissView() {
        navigationController?.dismiss(animated: true, completion: {
    
        })
    }
    
}

extension ChannelWireframe: BroadcastOverlayDelegate {
    func moveToCallingView(broadcastData: BroadcastData) {
        interactor.moveToCallingView(broadcastData: broadcastData)
    }
    
    func didUpdate(broadcastData: BroadcastData) {
        interactor.broadCastData = broadcastData
    }
    
    
}
