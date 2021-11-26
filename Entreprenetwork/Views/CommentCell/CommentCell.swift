//
//  CommentCell.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 26/12/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var btnProfilePic:UIButton!
    @IBOutlet weak var lblComments:UILabel!
    @IBOutlet weak var txtFldEditComment: UITextField!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
