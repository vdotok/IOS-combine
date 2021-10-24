//
//  ContactWireframe.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import iOSSDKConnect

final class ContactWireframe: BaseWireframe<ContactViewController> {

    // MARK: - Private properties -

    private let storyboard = UIStoryboard(name: "Contact", bundle: nil)

    // MARK: - Module setup -

    init(client: ChatClient) {
        let moduleViewController = storyboard.instantiateViewController(ofType: ContactViewController.self)
        super.init(viewController: moduleViewController)

        let interactor = ContactInteractor()
        let presenter = ContactPresenter(view: moduleViewController, interactor: interactor, wireframe: self, client: client)
        interactor.presenter = presenter
        moduleViewController.presenter = presenter
    }

}

// MARK: - Extensions -

extension ContactWireframe: ContactWireframeInterface {
    func navigate(to: ContactNavigationOptions, client: ChatClient, group: Group? = nil, user: UserResponse? = nil) {
        switch to {
        case .chat:
            guard let group = group,
                  let user = user
            else { return }
            let wireFrame = ChatWireframe(client: client, group: group, user: user, messages: [], vtokSDK: nil)
            navigationController?.pushWireframe(wireFrame)
        case .createGroup:
            navigationController?.pushWireframe(CreateGroupWireframe(client: client))
        }
    }
    

}
