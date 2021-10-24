//
//  ViewController+Extension.swift
//  IOS-combine
//
//  Created by usama farooq on 21/10/2021.
//

import Foundation
import UIKit

extension UIViewController {
    var topbarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}
