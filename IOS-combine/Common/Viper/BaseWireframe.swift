//
//  BaseWireframe.swift
//  IOS-combine
//
//  Created by usama farooq on 30/08/2021.
//

import Foundation
import UIKit

protocol WireframeInterface: AnyObject {
}

class BaseWireframe<ViewController> where ViewController: UIViewController {

    private unowned var _viewController: ViewController
    
    //to retain view controller reference upon first access
    private var temporaryStoredViewController: ViewController?

    init(viewController: ViewController) {
        temporaryStoredViewController = viewController
        _viewController = viewController
    }

}

extension BaseWireframe: WireframeInterface {

}

extension BaseWireframe {
    
    var viewController: ViewController {
        defer { temporaryStoredViewController = nil }
        return _viewController
    }

    var navigationController: UINavigationController? {
        return viewController.navigationController
    }

}

extension UIViewController {
    
    func presentWireframe<ViewController>(_ wireframe: BaseWireframe<ViewController>, animated: Bool = true, completion: (() -> Void)? = nil) {
        wireframe.viewController.modalPresentationStyle = .fullScreen
        present(wireframe.viewController, animated: animated, completion: completion)
    }

}

extension UINavigationController {
    
    func pushWireframe<ViewController>(_ wireframe: BaseWireframe<ViewController>, animated: Bool = true) {
        self.pushViewController(wireframe.viewController, animated: animated)
    }
    
    func setRootWireframe<ViewController>(_ wireframe: BaseWireframe<ViewController>, animated: Bool = true) {
        self.setViewControllers([wireframe.viewController], animated: animated)
    }

}
