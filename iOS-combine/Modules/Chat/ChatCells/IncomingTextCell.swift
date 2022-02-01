//
//  IncomingTextCell.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 19/05/2021.
//

import UIKit

class IncomingTextCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubbleView: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureAppearance()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configureAppearance() {
        bubbleView.backgroundColor = .appDarkGreenColor
        messageLabel.font = UIFont(name: "Inter-Regular", size: 14)
        bubbleView.layer.cornerRadius = 8
        
    }
    
    func configure(seen status: String ) {
        self.messageStatus.text = status
    }
}
