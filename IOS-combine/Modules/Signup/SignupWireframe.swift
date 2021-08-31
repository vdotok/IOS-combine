//
//  SignupWireframe.swift
//  IOS-combine
//
//  Created by usama farooq on 30/08/2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

final class SignupWireframe: BaseWireframe<SignupViewController> {

    // MARK: - Private properties -

    private let storyboard = UIStoryboard(name: "Signup", bundle: nil)

    // MARK: - Module setup -

    init() {
        let moduleViewController = storyboard.instantiateViewController(ofType: SignupViewController.self)
        super.init(viewController: moduleViewController)

        let interactor = SignupInteractor(service: NetworkService())
        let presenter = SignupPresenter(view: moduleViewController, interactor: interactor, wireframe: self)
        moduleViewController.presenter = presenter
    }

}

// MARK: - Extensions -

extension SignupWireframe: SignupWireframeInterface {
    func navigate(to options: SignupNavigationOptions) {
        switch options {
        case .login:
            self.viewController.dismiss(animated: true, completion: nil)
        case .channel:
            navigationController?.pushWireframe(ChannelWireframe())
        }
    }
    
    
}
