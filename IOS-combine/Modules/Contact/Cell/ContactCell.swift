//
//  ContactCell.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit

protocol ContactCellProtocol: AnyObject {
    func didTapChat()
}

class ContactCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    weak var delegate: ContactCellProtocol?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configureAppearance() {
        userName.font = UIFont(name: "Manrope-Medium", size: 15)
        userName.textColor = .appDarkColor
    }
    
    func configure(with model: User) {
        userName.text = model.fullName
    }
    
    @IBAction func didTapChat(_ sender: UIButton) {
        delegate?.didTapChat()
    }
}
