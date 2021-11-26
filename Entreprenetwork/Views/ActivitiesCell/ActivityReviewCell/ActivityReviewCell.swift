//
//  ActivityReviewCell.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 18/02/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit

class ActivityReviewCell: UITableViewCell {
    
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var btnJobPic: UIButton!
    @IBOutlet weak var lblReviewText: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
