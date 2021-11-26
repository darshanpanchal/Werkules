//
//  SenderImageCell.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 27/12/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class SenderImageCell: UITableViewCell {
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgVwProfilePic: UIImageView!
    @IBOutlet weak var chatImage: UIImageView!
    @IBOutlet weak var lblTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgVwProfilePic.contentMode = .scaleAspectFill
        self.imgVwProfilePic.clipsToBounds = true
        self.imgVwProfilePic.layer.cornerRadius = 25
        self.viewBG.backgroundColor = UIColor.init(hex: "99CCFF")
        DispatchQueue.main.async {
            self.imgVwProfilePic.layer.cornerRadius = 25
            self.imgVwProfilePic.layer.borderColor = UIColor.lightGray.cgColor
            self.imgVwProfilePic.layer.borderWidth = 0.5
            self.imgVwProfilePic.clipsToBounds = true
            self.viewBG.roundCorners(corners: [.topRight,.topLeft,.bottomRight], radius: 20.0)
            }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
