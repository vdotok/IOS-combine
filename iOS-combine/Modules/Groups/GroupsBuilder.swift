//  
//  GroupsBuilder.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 06/05/2021.
//

import Foundation
import UIKit

class GroupsBuilder {

    func build(with navigationController: UINavigationController?) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Groups", bundle: Bundle(for: GroupsBuilder.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: "GroupsViewController") as! GroupsViewController
        let coordinator = GroupsRouter(navigationController: navigationController)
        let viewModel = GroupsViewModelImpl(router: coordinator)

        viewController.viewModel = viewModel
        
        return viewController
    }
}


