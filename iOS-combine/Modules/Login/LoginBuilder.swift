//  
//  LoginBuilder.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 06/05/2021.
//

import Foundation
import UIKit

class LoginBuilder {

    func build(with navigationController: UINavigationController?) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Login", bundle: Bundle(for: LoginBuilder.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let coordinator = LoginRouter(navigationController: navigationController)
        let viewModel = LoginViewModelImpl(router: coordinator)

        viewController.viewModel = viewModel
        
        return viewController
    }
}


