//
//  PayementHistoryDetailTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS on 04/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol CustomerPaymentHistoryDelegate {
    func buttonfileDisputeSelected(index:Int)
}

class PayementHistoryDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shadowView:ShadowBackgroundView!
    @IBOutlet weak var containerView:UIView!
    
    @IBOutlet weak var lblJOBTitle:UILabel!
    @IBOutlet weak var lblJOBDate:UILabel!
    @IBOutlet weak var lblJOBID:UILabel!
    @IBOutlet weak var lblJOBPrice:UILabel!
    @IBOutlet weak var lblJOBFromToPaid:UILabel!
    
    @IBOutlet weak var lblAmountAvailable:UILabel!
    @IBOutlet weak var lblDeductionAmountAvailable:UILabel!
    
    @IBOutlet weak var lblWerkulesFees:UILabel!
    @IBOutlet weak var lblTransactionFees:UILabel!
    
    var delegate:CustomerPaymentHistoryDelegate?
    
    @IBOutlet weak var heightOfJOBTitle:NSLayoutConstraint!
    
    @IBOutlet weak var viewWerkulesAmount:UIView!
    @IBOutlet weak var viewTransactionFees:UIView!
    @IBOutlet weak var viewAmountAvailable:UIView!
    
    @IBOutlet weak var buttonFileDispute:UIButton!
    
    @IBOutlet weak var viewPromotionPriceContainer:UIView!
       @IBOutlet weak var lblPromotionOffer:UILabel!
       @IBOutlet weak var lblPromotionOfferAmount:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.containerView.layer.cornerRadius = 0.0
            self.containerView.layer.borderColor = UIColor.black.cgColor
            self.containerView.layer.borderWidth = 0.7
            self.containerView.clipsToBounds = true
            
            self.shadowView.rounding = 0.0
            self.shadowView.layoutSubviews()
            let underlineSeeDetail = NSAttributedString(string: "File A Dispute",
                                                                        attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
             //  self.buttonFileDispute.titleLabel?.attributedText = underlineSeeDetail
            self.lblPromotionOfferAmount.textColor = UIColor.init(hex: "F21600")
        }
    }
    func hideJOBTitle(){
        DispatchQueue.main.async {
            if let _ = self.heightOfJOBTitle{
                self.heightOfJOBTitle.constant = 0.0
            }
        }
    }
    func showJOBTitle(){
        DispatchQueue.main.async {
            if let _ = self.heightOfJOBTitle{
                self.heightOfJOBTitle.constant = 65.0
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonFileDisputeSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonfileDisputeSelected(index: self.tag)
        }
    }
    
}
