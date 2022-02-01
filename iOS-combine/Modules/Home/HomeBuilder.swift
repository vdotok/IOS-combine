//  
//  HomeBuilder.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 17/05/2021.
//

import Foundation
import UIKit

class HomeBuilder {

    func build(with navigationController: UINavigationController?) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Home", bundle: Bundle(for: HomeBuilder.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        let coordinator = HomeRouter(navigationController: navigationController)
        let viewModel = HomeViewModelImpl(router: coordinator)

        viewController.viewModel = viewModel
        
        return viewController
    }
}


