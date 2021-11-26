//
//  ReceiverCell.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 10/09/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class ReceiverCell: UITableViewCell {
    
//    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgVwProfilePic: UIImageView!
    @IBOutlet weak var lblChatText: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewwidth : NSLayoutConstraint!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgVwProfilePic.contentMode = .scaleAspectFill
        self.imgVwProfilePic.layer.cornerRadius = 25
        self.imgVwProfilePic.clipsToBounds = true

        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //self.imgVwProfilePic.layer.cornerRadius = 10.0
        self.imgVwProfilePic.clipsToBounds = true
        self.imgVwProfilePic.layer.borderWidth = 0.5
        self.imgVwProfilePic.layer.borderColor = UIColor.lightGray.cgColor
        DispatchQueue.main.async {
            self.lblChatText.roundCorners(corners: [.topRight,.topLeft,.bottomLeft], radius: 20.0)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
