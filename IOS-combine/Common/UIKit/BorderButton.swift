//
//  BorderButton.swift
//  IOS-combine
//
//  Created by usama farooq on 08/10/2021.
//

import Foundation
import UIKit

class BorderButton: UIButton {
    
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected == true {
                self.backgroundColor = UIColor.appYellowColor
                setTitleColor(.appDarkIndigoColor, for: .selected)
            } else {
                setTitleColor(.appDarkIndigoColor, for: .normal)
                self.backgroundColor = UIColor.white
            }
        }
    }
   
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
    
    private func setupButton() {
        layer.cornerRadius = 8
        layer.borderWidth = 2
        self.tintColor = UIColor.clear
        layer.borderColor = UIColor.appDarkIndigoColor.cgColor
        setTitleColor(.blue, for: .normal)
        titleLabel?.font = UIFont.init(name: "Manrope-Bold", size: 14)
        titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
}
