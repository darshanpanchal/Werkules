//
//  GroupEarningTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS on 10/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

protocol GroupEarningUpdateTableViewCellDelegate {
    func buttonSeeDetailSelector(senderIndex:IndexPath)
}
class GroupEarningUpdateTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCompanyName:UILabel!
    @IBOutlet weak var lblPromotionName:UILabel!
    @IBOutlet weak var lblPromotionAmount:UILabel!
    //@IBOutlet weak var containerView:UIView!
    @IBOutlet weak var imageViewBusinessness:UIImageView!
    
    @IBOutlet weak var buttondetail:UIButton!
    
    var currentIndexPath:IndexPath = IndexPath()
    var delegate:GroupEarningUpdateTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            let underlineSeeDetail = NSAttributedString(string: "See Details",
                                                                      attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
            self.buttondetail.setAttributedTitle(underlineSeeDetail, for: .normal)
            self.imageViewBusinessness.layer.cornerRadius = 20.0
            self.imageViewBusinessness.clipsToBounds = true
            //self.containerView.layer.cornerRadius = 6.0
//            self.containerView.clipsToBounds = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonSeeDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonSeeDetailSelector(senderIndex: self.currentIndexPath)
        }
    }
}
