//
//  ProviderJOBOfferTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS on 23/02/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol OfferProviderTableCellDelegate {
    func buttonJOBDetailWith(index:Int)
    func buttonContactDetailWith(index:Int)
    func buttonCustomerDetailWith(index:Int)
    func buttonSendOfferWith(index:Int)
    func buttonStartSelector(index:Int)
    func buttonPaymentSelector(index:Int)
    func buttonReportProblemSelector(index:Int)
    func buttonPaymentHistorySelector(index:Int)
    func buttonPromotionDetailSelector(index:Int)
    func buttonAttachmentSelectorWith(index:Int)
}
class ProviderJOBOfferTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView:UIView!
    @IBOutlet weak var objshadowview:ShadowBackgroundView!
    
    
    @IBOutlet weak var lbltitle:UILabel!
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblTime:UILabel!
    @IBOutlet weak var lblAskingPriceName:UILabel!
    @IBOutlet weak var lblAskingPrice:UILabel!
    @IBOutlet weak var lblCustomerName:UILabel!
    @IBOutlet weak var imgCustomerLogo:UIImageView!
    
    @IBOutlet weak var lblrating:UILabel!
    
    @IBOutlet weak var btnJOBDetailTop:UIButton!
    @IBOutlet weak var btnContactDetailTop:UIButton!
    @IBOutlet weak var btnreportproblem:UIButton!
    
    @IBOutlet weak var btnPaymenthistory:UIButton!
    @IBOutlet weak var btnStart:UIButton!
    @IBOutlet weak var btnCustomerDetail:UIButton!
    @IBOutlet weak var btnJOBDetailbottom:UIButton!
    @IBOutlet weak var btnSendOffer:UIButton!
    @IBOutlet weak var btnPayment:UIButton!
    
    @IBOutlet weak var viewOfferAmount:UIView!
    @IBOutlet weak var lblOfferAmount:UILabel!

    @IBOutlet weak var viewPromotionContainer:UIView!
    @IBOutlet weak var lblPromotionOfferAmount:UILabel!
    @IBOutlet weak var lblPromotionOffer:UILabel!
    @IBOutlet weak var btnPromotionDetail:UIButton!
    
    var deleagate:OfferProviderTableCellDelegate?
    @IBOutlet weak var viewDocument:UIView!
    @IBOutlet weak var btnAttachment:UIButton!
    @IBOutlet weak var btnNoAttachment:UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let underlineSeeDetail = NSAttributedString(string: "Attachment",
                                                                         attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnAttachment.setAttributedTitle(underlineSeeDetail, for: .normal)
        //self.btnAttachment.titleLabel?.attributedText = underlineSeeDetail
        // Initialization code
        self.lblPromotionOfferAmount.textColor = UIColor.init(hex: "F21600")
        self.objshadowview.rounding = 15.0
        self.objshadowview.layer.cornerRadius = 15.0
        self.objshadowview.layoutIfNeeded()
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 15.0
        
        self.imgCustomerLogo.clipsToBounds = true
        self.imgCustomerLogo.layer.cornerRadius = 15.0
        self.imgCustomerLogo.layer.borderColor = UIColor.lightGray.cgColor
        self.imgCustomerLogo.layer.borderWidth = 0.5
        
        self.imgCustomerLogo.contentMode = .scaleAspectFill
        self.imgCustomerLogo.clipsToBounds = true
        
        let underlineSeeDetail1 = NSAttributedString(string: "See Details",attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnPromotionDetail.setAttributedTitle(underlineSeeDetail1, for: .normal)
        //self.btnPromotionDetail.titleLabel?.attributedText = underlineSeeDetail1
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    //MARK:- Selector methods
    @IBAction func buttonAttachmentSelector(sender:UIButton){
        if let _ = self.deleagate{
            self.deleagate!.buttonAttachmentSelectorWith(index: self.tag)
        }
    }
    @IBAction func buttonPromotionDetailselector(sender:UIButton){
             if let _  = self.deleagate{
                 self.deleagate!.buttonPromotionDetailSelector(index: self.tag)
             }
         }
    @IBAction func buttonJOBDetail(sender:UIButton){
        if let _ = self.deleagate{
            self.deleagate!.buttonJOBDetailWith(index: self.tag)
        }
    }
    @IBAction func buttonContactDetailTopSelector(sender:UIButton){
        if let _ = self.deleagate{
            self.deleagate!.buttonContactDetailWith(index: self.tag)
        }
    }
    @IBAction func buttonCustomerDetail(sender:UIButton){
        if let _ = self.deleagate{
            self.deleagate!.buttonCustomerDetailWith(index: self.tag)
        }
    }
    @IBAction func buttonSendOfferDetail(sender:UIButton){
        if let _ = self.deleagate{
            self.deleagate!.buttonSendOfferWith(index: self.tag)
        }
    }
    @IBAction func buttonStartJOB(sender:UIButton){
        if let _ = self.deleagate{
            self.deleagate!.buttonStartSelector(index: self.tag)
        }
    }
    @IBAction func buttonPaymentSelector(sender:UIButton){
        if let _ = self.deleagate{
            self.deleagate!.buttonPaymentSelector(index: self.tag)
        }
    }
    @IBAction func buttonReportProblemSelector(sender:UIButton){
        if let _ = self.deleagate{
            self.deleagate!.buttonReportProblemSelector(index: self.tag)
        }
    }
    @IBAction func buttonPaymentHistorySelector(sender:UIButton){
        if let _ = self.deleagate{
            self.deleagate!.buttonPaymentHistorySelector(index: self.tag)
        }
    }
}
