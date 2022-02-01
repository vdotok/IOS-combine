//  
//  ContactBuilder.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 20/05/2021.
//

import Foundation
import UIKit
import iOSSDKConnect

class ContactBuilder {

    func build(with navigationController: UINavigationController?, client: ChatClient, callingControl: NonGroupCallingControl? = nil) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Contact", bundle: Bundle(for: ContactBuilder.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
        let coordinator = ContactRouter(navigationController: navigationController)
        let viewModel = ContactViewModelImpl(router: coordinator, client: client, callingControl: callingControl)

        viewController.viewModel = viewModel
        
        return viewController
    }
}


