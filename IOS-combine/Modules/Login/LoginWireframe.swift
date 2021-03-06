//
//  LoginWireframe.swift
//  IOS-combine
//
//  Created by usama farooq on 30/08/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

final class LoginWireframe: BaseWireframe<LoginViewController> {

    // MARK: - Private properties -

    private let storyboard = UIStoryboard(name: "Login", bundle: nil)

    // MARK: - Module setup -

    init() {
        let moduleViewController = storyboard.instantiateViewController(ofType: LoginViewController.self)
        super.init(viewController: moduleViewController)

        let interactor = LoginInteractor()
        let presenter = LoginPresenter(view: moduleViewController, interactor: interactor, wireframe: self)
        
        moduleViewController.presenter = presenter
        moduleViewController.presenter.interactor?.presenter = presenter
    }

}

// MARK: - Extensions -

extension LoginWireframe: LoginWireframeInterface {
    func navigate(to option: LoginNavigationOption) {
        switch option {
        case .channel:
            let navigationControlr = UINavigationController()
            navigationControlr.modalPresentationStyle = .fullScreen
            let viewController = ChannelWireframe().viewController
            viewController.modalPresentationStyle = .fullScreen
            navigationControlr.setViewControllers([viewController], animated: true)
            self.viewController.present(navigationControlr, animated: true, completion: nil)
            
            
            
        case .signup:
            self.viewController.presentWireframe(SignupWireframe())
        }
    }
    
    
    
}
