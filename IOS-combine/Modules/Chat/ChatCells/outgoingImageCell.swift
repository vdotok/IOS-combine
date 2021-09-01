//
//  outgoingImageCell.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 01/06/2021.
//

import UIKit

class outgoingImageCell: UITableViewCell {
    
    @IBOutlet weak var chatImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageStatus: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with url: URL?) {
        if let url = url {
            if let data = try? Data(contentsOf: url)
            {
                let image: UIImage = UIImage(data: data)!
                chatImage.image = image
            }
        }
    }
    
    func configure(seen status: String ) {
        messageStatus.text = status
    }
    
}
