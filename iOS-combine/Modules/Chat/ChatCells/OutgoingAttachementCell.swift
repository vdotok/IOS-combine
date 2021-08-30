//
//  OutgoingAttachementCell.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 31/05/2021.
//

import UIKit

class OutgoingAttachementCell: UITableViewCell {

    weak var delegate: DidTapAttachmentDelagate?
    @IBOutlet weak var attachmentButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageStatus: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    var url = URL(fileURLWithPath: "")
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(seen status: String ) {
        messageStatus.text = status
    }
    
    @IBAction func didTapAttachment(_ sender: UIButton) {
        self.delegate?.didTapAttachment(url: url)
    }
    
}
