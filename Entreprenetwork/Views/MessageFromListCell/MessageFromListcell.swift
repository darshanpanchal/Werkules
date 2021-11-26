//
//  MessageFromListcell.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 13/03/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit

class MessageFromListcell: UITableViewCell {
    
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var imgViewarrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
