//
//  UserCell.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 27/07/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var btnUserProfile: UIButton!
    @IBOutlet weak var lblSeparator: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnReview: UIButton!
    @IBOutlet weak var lblMsgCount: UILabel!
    @IBOutlet weak var imgViewDot : UIImageView!
    @IBOutlet weak var imgviewThreeDots: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
