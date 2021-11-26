//
//  ReviewCollectionViewCell.swift
//  Entreprenetwork
//
//  Created by IPS on 20/01/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import FloatRatingView

class ReviewCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var containerView:MyBorderView!
    @IBOutlet weak var imgUser:UIImageView!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var lblReview:UILabel!
    @IBOutlet weak var objReview:FloatRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 15.0
        self.imgUser.clipsToBounds = true
        self.imgUser.layer.cornerRadius = 20.0
        self.imgUser.contentMode = .scaleAspectFill
    }
    override func prepareForReuse() {
        self.imgUser.image = UIImage.init(named: "user_placeholder")
    }
}
