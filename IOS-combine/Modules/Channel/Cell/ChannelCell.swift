//
//  ChannelCell.swift
//  IOS-combine
//
//  Created by usama farooq on 31/08/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit

class ChannelCell: UITableViewCell {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var participentsCount: UILabel!
    @IBOutlet weak var messageCountLabel: UILabel!
    @IBOutlet weak var messageCountView: UIView!
    
    var onlineParticipent: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureAppearance()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    func configure(with model: Group, online: Int, lastMessage: String, unreadCount: Int) {
       guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        
        messageCountView.isHidden = true
        messageCountLabel.isHidden = true
        participentsCount.textColor = .appDarkGreenColor
        
        if model.participants.count <= 2 {
            let data =  model.participants.filter({$0.refID != user.refID})
            groupNameLabel.text = data.first?.fullName
            if  online == 2 {
                participentsCount.text = "Online"
                participentsCount.textColor = .appDarkGreenColor
                
            } else {
                participentsCount.textColor = .appRedColor
                participentsCount.text = "offline"
            }
            
        } else {
            groupNameLabel.text = model.groupTitle
            participentsCount.text = "\(online)/\(model.participants.count) \(" Online")"
        }
        
        lastMessageLabel.text = lastMessage
        if unreadCount > 0 {
            messageCountView.isHidden = false
            messageCountLabel.isHidden = false
            messageCountLabel.text = "\(unreadCount)"
        }
    
    }
    
    private func configureAppearance() {
        groupNameLabel.textColor = .appDarkColor
        lastMessageLabel.textColor = .appLightIndigoColor
        participentsCount.textColor = .appDarkGreenColor
        groupNameLabel.font = UIFont(name: "Manrope-Medium", size: 20)
        lastMessageLabel.font = UIFont(name: "Inter-Regular", size: 14)
        participentsCount.font = UIFont(name: "Poppins-Regular", size: 10)
        messageCountView.backgroundColor = .appRedColor
        messageCountView.layer.cornerRadius = 10
        messageCountView.layer.masksToBounds = true
        messageCountLabel.textColor = .white
        messageCountLabel.font = UIFont(name: "Inter-ExtraBold", size: 12)
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
