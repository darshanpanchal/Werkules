//
//  ReviewCell.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 01/10/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class ReviewCell: UITableViewCell {
    
    
    @IBOutlet weak var btnUserProfilePic: UIButton!
    @IBOutlet weak var lblJobTitle: UILabel!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var lblRatings: UILabel!
    @IBOutlet weak var lblSeparator: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
