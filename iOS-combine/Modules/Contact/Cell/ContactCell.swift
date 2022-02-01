//
//  ContactCell.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 20/05/2021.
//

import UIKit

protocol ContactCellProtocol: class {
    func didTapChat(cell: UITableViewCell)
    func didTapVideo(user: User)
    func didTapAudio(user: User)
}

class ContactCell: UITableViewCell {
    
    @IBOutlet weak var userName: UILabel!
    var user: User?
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
        self.user = model
    }
    
    @IBAction func didTapChat(_ sender: UIButton) {
        delegate?.didTapChat(cell: self)
    }
    
    @IBAction func didTapAudio(_ sender: UIButton) {
        guard let user = user else {return}
        delegate?.didTapAudio(user: user)
    }
    
    @IBAction func didTapVideo(_ sender: UIButton) {
        guard let user = user else {return }
        delegate?.didTapVideo(user: user)
    }
    
}
