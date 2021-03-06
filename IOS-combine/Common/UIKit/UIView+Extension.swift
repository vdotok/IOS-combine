//
//  UIView+Extension.swift
//  IOS-combine
//
//  Created by usama farooq on 12/10/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func removeAllSubViews() {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
    }
    
    func fixInSuperView() {
        guard let _superView = self.superview else {return}
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: _superView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo:_superView.trailingAnchor),
            self.topAnchor.constraint(equalTo: _superView.topAnchor),
            self.bottomAnchor.constraint(equalTo: _superView.bottomAnchor)
        ])
    }
    
    func fixInMiddleOfSuperView(){
        guard let _superView = self.superview else {return}
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: _superView.centerXAnchor),
            self.centerYAnchor.constraint(equalTo:_superView.centerYAnchor)
        ])
    }
    
    func addConstraintsFor(width: CGFloat, and height: CGFloat){
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: height),
            self.widthAnchor.constraint(equalToConstant: width)
        ])
    }
    
    func addTopConstraint(size: CGFloat) {
        guard let _superView = self.superview else {return}
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: _superView.topAnchor, constant: size)
        ])
    }
}
