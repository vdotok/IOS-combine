//
//  IncomingAttachmentCell.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 31/05/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit

protocol DidTapAttachmentDelagate: AnyObject {
    func didTapAttachment(url: URL)
}

class IncomingAttachmentCell: UITableViewCell {

    weak var delegate: DidTapAttachmentDelagate?
    @IBOutlet weak var attachmentButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userName: UILabel!

    var url = URL(fileURLWithPath: "")
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 8
        userName.font = UIFont(name: "Inter-Regular", size: 14)
        userName.textColor = .appDarkGreenColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
    @IBAction func didTapAttachment(_ sender: UIButton) {
        print("TEst")
        self.delegate?.didTapAttachment(url: url)
    }
    
}
