//
//  CustomerPendingPaymentTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS on 11/05/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol CustomerPendingPaymentHistoryDelegate {
    func buttonfileDisputeSelected(index:Int)
}

class CustomerPendingPaymentTableViewCell: UITableViewCell {

    
    @IBOutlet weak var lblJOBTitle:UILabel!
    @IBOutlet weak var lblJOBDate:UILabel!
    @IBOutlet weak var lblJOBID:UILabel!
    @IBOutlet weak var lblJOBPrice:UILabel!
    @IBOutlet weak var lblJOBFromToPaid:UILabel!
    @IBOutlet weak var lblJOBFromTo:UILabel!
    
    @IBOutlet weak var containerView:UIView!

    var delegate:CustomerPendingPaymentHistoryDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.layer.cornerRadius = 0.0
        self.containerView.layer.borderColor = UIColor.black.cgColor
        self.containerView.layer.borderWidth = 0.7
        self.containerView.clipsToBounds = true
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
