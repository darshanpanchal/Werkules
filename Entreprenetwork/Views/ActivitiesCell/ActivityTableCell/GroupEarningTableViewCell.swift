//
//  GroupEarningTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS on 10/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class GroupEarningTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCompanyName:UILabel!
    @IBOutlet weak var lblPromotionName:UILabel!
    @IBOutlet weak var lblPromotionAmount:UILabel!
    @IBOutlet weak var containerView:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.containerView.layer.cornerRadius = 6.0
            self.containerView.clipsToBounds = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
