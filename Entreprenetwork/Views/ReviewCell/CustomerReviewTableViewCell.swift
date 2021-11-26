//
//  CustomerReviewTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS on 22/01/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import FloatRatingView
protocol CustomerReviewTableViewCellDelegate {
    func buttonEditSelector(index:Int)
    func buttonUserProfileClick(index:Int)
}

class CustomerReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var imgUser:UIImageView!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var lblReview:UILabel!
    @IBOutlet weak var objReview:FloatRatingView!
    @IBOutlet weak var buttonEdit:UIButton!
    
    var delegate:CustomerReviewTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgUser.contentMode = .scaleAspectFill
        self.imgUser.clipsToBounds = true
        self.imgUser.layer.cornerRadius = 20.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonEditSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate?.buttonEditSelector(index: self.tag)
        }
    }
    @IBAction func buttonUserImageAndName(sender:UIButton){
        if let _ = self.delegate{
            self.delegate?.buttonUserProfileClick(index: self.tag)
        }
    }
    override func prepareForReuse() {
        self.imgUser.image = UIImage.init(named: "user_placeholder")
        self.buttonEdit.isHidden = true
    }
}
