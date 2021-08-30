//
//  IncomingAudioCell.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 27/05/2021.
//

import UIKit

class IncomingAudioCell: UITableViewCell {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        slider.setThumbImage(UIImage(named: "RoundWhite"), for: .normal)
        containerView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
