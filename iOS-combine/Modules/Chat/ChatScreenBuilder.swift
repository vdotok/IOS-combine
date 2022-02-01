//  
//  ChatScreenBuilder.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 18/05/2021.
//

import Foundation
import UIKit
import iOSSDKConnect

class ChatScreenBuilder {

    func build(with navigationController: UINavigationController?, client: ChatClient, group: Group, user: UserResponse, messages: [ChatMessage], callingControl: GroupCallingControl? = nil) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "ChatScreen", bundle: Bundle(for: ChatScreenBuilder.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: "ChatScreenViewController") as! ChatScreenViewController
        let coordinator = ChatScreenRouter(navigationController: navigationController)
        let viewModel = ChatScreenViewModelImpl(router: coordinator, client: client, group: group, user: user, messages: messages, callingControl: callingControl)
        viewController.viewModel = viewModel
        
        return viewController
    }
}


