//
//  BankDetailTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 24/06/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol BankDetailTableViewCellDelegate {
    func buttonDeleteBankAccount(index:Int)
    func buttonSelectBankAccount(index:Int)
}

class BankDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var shadowBackground:ShadowBackgroundView!
    @IBOutlet weak var containerView:UIView!
    @IBOutlet weak var buttonDelete:UIButton!
    @IBOutlet weak var buttonSelect:UIButton!
    
    @IBOutlet weak var lblBankName:UILabel!
    @IBOutlet weak var lblBankNumber:UILabel!
    
    var delegate:BankDetailTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.shadowBackground.rounding = 15.0
        self.shadowBackground.layer.cornerRadius = 15.0
        self.shadowBackground.layoutIfNeeded()
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 15.0
        self.selectionStyle = .none
        
    }
    @IBAction func buttonDeleteBankAccount(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonDeleteBankAccount(index: self.tag)
        }
    }
    @IBAction func buttonSelectBankAccount(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonSelectBankAccount(index: self.tag)
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
