//
//  IndigoButton.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 20/05/2021.
//

import Foundation
import UIKit

class IndigoButton: UIButton {
    
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
        backgroundColor = .appDarkIndigoColor
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.init(name: "Manrope-Bold", size: 14)
        titleEdgeInsets = UIEdgeInsets(top: 2,left: 10,bottom:2,right: 10)
        titleLabel?.adjustsFontSizeToFitWidth = true
    }
}
