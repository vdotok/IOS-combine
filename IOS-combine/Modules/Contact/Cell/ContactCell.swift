//
//  ContactCell.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit

protocol ContactCellProtocol: AnyObject {
    func didTapChat(with user: User)
    func didTapVideo(with user: User)
    func didTapAudio(with user: User)
}

class ContactCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    private var user: User?
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
        user = model
    }
    
    @IBAction func didTapChat(_ sender: UIButton) {
        guard let user = user else { return }
        delegate?.didTapChat(with: user)
    }
    
    @IBAction func didTapVideo(_ sender: UIButton) {
        guard let user = user else { return }
        delegate?.didTapVideo(with: user)
    }
    
    @IBAction func didTapAudio(_ sender: UIButton) {
        guard let user = user else { return }
        delegate?.didTapAudio(with: user)
    }
}
