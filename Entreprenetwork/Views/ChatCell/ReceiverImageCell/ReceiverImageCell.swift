//
//  ReceiverImageCell.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 27/12/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class ReceiverImageCell: UITableViewCell {
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgVwProfilePic: UIImageView!
    @IBOutlet weak var chatImage: UIImageView!
    @IBOutlet weak var lblTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgVwProfilePic.contentMode = .scaleAspectFill
        self.imgVwProfilePic.layer.cornerRadius = 25
        self.imgVwProfilePic.clipsToBounds = true

        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft,.bottomLeft,.topRight], radius: 20.0)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
