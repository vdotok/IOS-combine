//
//  GroupCallingCell.swift
//  IOS-combine
//
//  Created by usama farooq on 18/10/2021.
//

import UIKit
import iOSSDKStreaming

class GroupCallingCell: UICollectionViewCell {
    
    @IBOutlet weak var remoteView: UIView! {
        didSet {
            remoteView.layer.cornerRadius = 20
            remoteView.clipsToBounds = true
        }
    }
    @IBOutlet weak var remoteName: UILabel!
    @IBOutlet weak var personAvatar: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        for subView in remoteView.subviews {
            subView.removeFromSuperview()
        }
        remoteView.isHidden = false
        remoteName.text = nil
    }
    
    func configure(with stream: UserStream, users: [User]?) {
//
//        guard let user = users, let currentUser = user.filter({$0.refID == stream.referenceID}).first else{
//            return
//
//        }
        remoteName.text = "test"
        switch stream.sessionMediaType {
        case .audioCall:
            remoteView.isHidden = true
            
        case .videoCall:
            for subView in remoteView.subviews {
                subView.removeFromSuperview()
            }
            
            remoteView.addSubview(stream.renderer)
            stream.renderer.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stream.renderer.leadingAnchor.constraint(equalTo: self.remoteView.leadingAnchor),
                stream.renderer.trailingAnchor.constraint(equalTo:self.remoteView.trailingAnchor),
                stream.renderer.topAnchor.constraint(equalTo: self.remoteView.topAnchor),
                stream.renderer.bottomAnchor.constraint(equalTo: self.remoteView.bottomAnchor)
            ])
            if let stateInformation = stream.stateInformation {
                update(stateInformation: stateInformation)
            }
        }
    }
    func update(stateInformation: StateInformation) {
        if stateInformation.videoInformation == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                self?.remoteView.isHidden = false
                self?.personAvatar.isHidden = true
            }
        }else {
            remoteView.isHidden = true
            personAvatar.isHidden = false
        }
    }

}
