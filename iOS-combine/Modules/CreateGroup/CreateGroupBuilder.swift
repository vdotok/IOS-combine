//  
//  CreateGroupBuilder.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 20/05/2021.
//

import Foundation
import UIKit
import iOSSDKConnect

class CreateGroupBuilder {

    func build(with navigationController: UINavigationController?, client: ChatClient ) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "CreateGroup", bundle: Bundle(for: CreateGroupBuilder.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: "CreateGroupViewController") as! CreateGroupViewController
        let coordinator = CreateGroupRouter(navigationController: navigationController)
        let viewModel = CreateGroupViewModelImpl(router: coordinator, client: client)
        viewController.viewModel = viewModel
        
        return viewController
    }
}


