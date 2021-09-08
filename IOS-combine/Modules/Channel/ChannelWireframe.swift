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

    // MARK: - Module setup -

    init() {
        let moduleViewController = storyboard.instantiateViewController(ofType: ChannelViewController.self)
        super.init(viewController: moduleViewController)

        let interactor = ChannelInteractor()
        let presenter = ChannelPresenter(view: moduleViewController, interactor: interactor, wireframe: self)
        moduleViewController.presenter = presenter
        presenter.interactor?.presenter = presenter
    }

}

// MARK: - Extensions -

extension ChannelWireframe: ChannelWireframeInterface {
    
    func moveToCalling(sdk: VTokSDK, particinats: [Participant], users: [User]) {
        let frame = CallingWireframe(vtokSdk: sdk, participants: particinats, screenType: .videoView, contact: users)
        navigationController?.viewControllers.last?.presentWireframe(frame)
    }
    
    func moveToIncomingCall(sdk: VTokSDK, baseSession: VTokBaseSession, users: [User]) {
        let frame = CallingWireframe(vtokSdk: sdk, participants: nil, screenType: .incomingCall, session: baseSession, contact: users)
        navigationController?.presentWireframe(frame)
    }
    
    func moveToAudio(sdk: VTokSDK, participants: [Participant], users: [User]) {
        let frame = CallingWireframe(vtokSdk: sdk, participants: participants, screenType: .audioView, contact: users)
        navigationController?.presentWireframe(frame)
    }
    
    func move(to: ChannelNavigationOptions,client: ChatClient, group: Group, user: UserResponse, messages: [ChatMessage]) {
        switch to {
        case .chat:
            navigationController?.pushWireframe(ChatWireframe(client: client, group: group, user: user, messages: messages))
        }
    }
    
    func moveToCreateGroup(client: ChatClient) {
        
        let frame = ContactWireframe(client: client)
        navigationController?.pushWireframe(frame)
    }
    
    
}
