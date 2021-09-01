//
//  TextView+Extensions.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//

import Foundation
import UIKit

extension UITextView {

    func setPlaceholder() {

        let placeholderLabel = UILabel()
        placeholderLabel.text = "Type your message"
        placeholderLabel.font = UIFont.init(name: "Manrope-Medium", size: 16)
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 222
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.font?.pointSize)! / 2)
        placeholderLabel.textColor = .placeHolder
        placeholderLabel.isHidden = !self.text.isEmpty

        self.addSubview(placeholderLabel)
    }

    func checkPlaceholder() {
        let placeholderLabel = self.viewWithTag(222) as! UILabel
        placeholderLabel.isHidden = !self.text.isEmpty
    }

}
