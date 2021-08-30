//  
//  GroupsRouter.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 06/05/2021.
//

import Foundation
import UIKit
import iOSSDKStreaming

class GroupsRouter {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension GroupsRouter {

    func moveToCalling(sdk: VTokSDK, particinats: [Participant], users: [User] ) {
        let builder = CallingBuilder().build(with: self.navigationController, vtokSdk: sdk, participants: particinats, screenType: .videoView, contact: users)
        builder.modalPresentationStyle = .fullScreen
        navigationController?.viewControllers.last?.present(builder, animated: true, completion: nil)
    }
    
    func moveToIncomingCall(sdk: VTokSDK, baseSession: VTokBaseSession, users: [User]) {
        let builder = CallingBuilder().build(with: self.navigationController, vtokSdk: sdk, participants: nil, screenType: .incomingCall, session: baseSession, contact: users)
        builder.modalPresentationStyle = .fullScreen
        navigationController?.present(builder, animated: true, completion: nil)
    }
    
    func moveToAudio(sdk: VTokSDK, participants: [Participant], users: [User]) {
        let builder = CallingBuilder().build(with: self.navigationController, vtokSdk: sdk, participants: participants, screenType: .audioView, contact: users)
        builder.modalPresentationStyle = .fullScreen
        navigationController?.viewControllers.last?.present(builder, animated: true, completion: nil)
    }
}
