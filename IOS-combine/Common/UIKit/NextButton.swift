//
//  NextButton.swift
//  IOS-combine
//
//  Created by usama farooq on 03/11/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
import UIKit

class NextButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
       
    }
    
    func setupButton() {
        layer.cornerRadius = 8
        backgroundColor = .white
        setTitleColor(.appDarkIndigoColor, for: .normal)
        titleLabel?.font = UIFont.init(name: "Manrope-Bold", size: 14)
        titleEdgeInsets = UIEdgeInsets(top: 2,left: 10,bottom:2,right: 10)
        layer.borderWidth = 3
        layer.borderColor = UIColor.appDarkIndigoColor.cgColor
        titleLabel?.adjustsFontSizeToFitWidth = true
    }
}
