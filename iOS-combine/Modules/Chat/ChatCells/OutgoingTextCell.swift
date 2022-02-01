//
//  OutgoingTextCell.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 19/05/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit

class OutgoingTextCell: UITableViewCell {

    @IBOutlet weak var bubbleView: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureAppearance()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func configureAppearance() {
        bubbleView.backgroundColor = .appDarkGreenColor
        messageLabel.font = UIFont(name: "Inter-Regular", size: 18)
        bubbleView.layer.cornerRadius = 8
        userName.font = UIFont(name: "Inter-Regular", size: 14)
        userName.textColor = .appDarkGreenColor
        
    }
    
}
