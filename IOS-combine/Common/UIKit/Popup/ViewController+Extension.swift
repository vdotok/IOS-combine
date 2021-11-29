//
//  ViewController+Extension.swift
//  IOS-combine
//
//  Created by usama farooq on 21/10/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    var topbarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}
