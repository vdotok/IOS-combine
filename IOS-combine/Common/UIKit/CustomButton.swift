//
//  CustomButton.swift
//  IOS-combine
//
//  Created by usama farooq on 25/10/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
import UIKit

class CustomButton: UIButton {
    
   
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
        backgroundColor = UIColor(named: "AppGreenColor")
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.init(name: "Manrope-Bold", size: 14)
        titleEdgeInsets = UIEdgeInsets(top: 2,left: 10,bottom:2,right: 10)
        titleLabel?.adjustsFontSizeToFitWidth = true
    }
}
