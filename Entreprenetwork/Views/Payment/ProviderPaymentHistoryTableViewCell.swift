//
//  ProviderPaymentHistoryTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS on 06/05/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol ProviderPaymentHistoryDelegate {
    func buttonfileDisputeSelected(index:Int)
}
class ProviderPaymentHistoryTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var containrerView:UIView!
    
    @IBOutlet weak var buttonFileDispute:UIButton!
    
    @IBOutlet weak var lblJOBTitle:UILabel!
    @IBOutlet weak var lblJOBDate:UILabel!
    @IBOutlet weak var lblJOBID:UILabel!
    @IBOutlet weak var lblCustomerName:UILabel!
    
    @IBOutlet weak var lblJOBPrice:UILabel!
    @IBOutlet weak var lblJOBFromToPaid:UILabel!
    
    @IBOutlet weak var lblPromotionAmount:UILabel!
    @IBOutlet weak var lblAffilliateAmount:UILabel!
    
    @IBOutlet weak var lblAmountAvailable:UILabel!
    @IBOutlet weak var lblDeductionAmountAvailable:UILabel!
    
    @IBOutlet weak var lblWerkulesFees:UILabel!
    @IBOutlet weak var lblTransactionFees:UILabel!
    
    @IBOutlet weak var viewPromotion1:UIView!
    @IBOutlet weak var viewPromotion2:UIView!
    
    @IBOutlet weak var viewPromotion:UIView!
    
    
    
    
    @IBOutlet weak var lblPromotionName:UILabel!
    
    @IBOutlet weak var viewWerkulesAmount:UIView!
    @IBOutlet weak var viewTransactionFees:UIView!
    @IBOutlet weak var viewAmountAvailable:UIView!
    
    var delegate:ProviderPaymentHistoryDelegate?
    
    
    @IBOutlet weak var lblFullAmountOnPromotion:UILabel!
    @IBOutlet weak var lblPromotionDiscountDetail:UILabel!
    @IBOutlet weak var lblDiscountAmountOnPromotion:UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        DispatchQueue.main.async {
            self.containrerView.layer.borderWidth = 0.7
            self.containrerView.layer.borderColor = UIColor.black.cgColor
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
