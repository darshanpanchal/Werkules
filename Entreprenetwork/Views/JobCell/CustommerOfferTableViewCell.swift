//
//  CustommerOfferTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS on 22/02/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit


protocol CustomerOfferCellDelegate {
    func buttonContactSelectorWith(index:Int)
    func buttonAttachmentSelectorWith(index:Int)
    func buttonProviderDetailSelectorWith(index:Int)
    func buttonBookJOBSelectorWith(index:Int)
    func buttonPaymentSelectorWith(index:Int)
    func buttonReportProblemSelectorWith(index:Int)
    func buttonPaymentHistorySelectorWith(index:Int)
    func buttonPromotionDetailSelector(index:Int)
    func buttonJOBDetailWith(index:Int)
}

class CustommerOfferTableViewCell: UITableViewCell {

    
    var delegate:CustomerOfferCellDelegate?
    
    @IBOutlet weak var lbltitle:UILabel!
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblAskingPriceName:UILabel!
    
    @IBOutlet weak var lblAskingPrice:UILabel!
    @IBOutlet weak var lblAcceptedPrice:UILabel!
    @IBOutlet weak var lblOfferPrice:UILabel!
    @IBOutlet weak var lblBusinessName:UILabel!
    @IBOutlet weak var lblRating:UILabel!
    @IBOutlet weak var lbldateofpost:UILabel!
    @IBOutlet weak var lbltimeofpost:UILabel!
    @IBOutlet weak var lbldateofaccepted:UILabel!
    @IBOutlet weak var lbltimeofaccepted:UILabel!
    
    @IBOutlet weak var lblOfferDate:UILabel!
    @IBOutlet weak var lblOfferTime:UILabel!
    
    
    @IBOutlet weak var btnAttachment:UIButton!
    @IBOutlet weak var btnNoAttachment:UIButton!
    
    @IBOutlet weak var btnContact:UIButton!
    @IBOutlet weak var btnProviderDetail:UIButton!
    @IBOutlet weak var buttonPayment:UIButton!
    @IBOutlet weak var buttonReportProblem:UIButton!
    @IBOutlet weak var buttonPaymentHistory:UIButton!
    @IBOutlet weak var btnBookNow:UIButton!
    
    @IBOutlet weak var businessLogo:UIImageView!
    
    @IBOutlet weak var containerView:UIView!
    @IBOutlet weak var objshadowview:ShadowBackgroundView!
    @IBOutlet weak var objshadowviewContact:ShadowBackgroundView!
    
    @IBOutlet weak var viewAcceptedPrice:UIView!
    @IBOutlet weak var viewAskingPrice:UIView!
    @IBOutlet weak var viewOfferPrice:UIView!
    @IBOutlet weak var viewDocument:UIView!
    @IBOutlet weak var viewDateOfPost:UIView!
    @IBOutlet weak var viewDateofAccepted:UIView!
    @IBOutlet weak var viewTimeofAccepted:UIView!
    @IBOutlet weak var viewTimeOfPost:UIView!
    
    @IBOutlet weak var viewProviderDetail:UIView!
    
    
    @IBOutlet weak var heightOfProviderDetailView:NSLayoutConstraint!
    
    @IBOutlet weak var lblDateOfCompleted:UILabel!
    
    
    @IBOutlet weak var viewPromotionContainer:UIView!
    @IBOutlet weak var lblPromotionOfferAmount:UILabel!
    @IBOutlet weak var lblPromotionOffer:UILabel!
    @IBOutlet weak var btnPromotionDetail:UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.objshadowview.rounding = 15.0
        self.objshadowview.layer.cornerRadius = 15.0
        self.objshadowview.layoutIfNeeded()
        
        self.objshadowviewContact.rounding = 20.0
        self.objshadowviewContact.layer.cornerRadius = 20.0
        self.objshadowviewContact.layoutIfNeeded()
        
        
        
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 15.0
        self.businessLogo.contentMode = .scaleAspectFill
        self.businessLogo.clipsToBounds = true
        self.businessLogo.layer.cornerRadius = 15.0
        self.businessLogo.layer.borderColor = UIColor.lightGray.cgColor
        self.businessLogo.layer.borderWidth = 0.5
        
        let underlineSeeDetail = NSAttributedString(string: "Attachment",
                                                                         attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnAttachment.setAttributedTitle(underlineSeeDetail, for: .normal)
        //self.btnAttachment.titleLabel?.attributedText = underlineSeeDetail
        self.btnProviderDetail.setTitle("Provider Details", for: .normal)
        //self.btnProviderDetail.titleLabel?.text = "Provider Details"
        let underlineSeeDetail1 = NSAttributedString(string: "See Details",
                                                                              attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnPromotionDetail.setAttributedTitle(underlineSeeDetail1, for: .normal)
        
        //self.btnPromotionDetail.titleLabel?.attributedText = underlineSeeDetail1
        
        self.buttonPayment.imageView?.contentMode = .scaleAspectFit
        
        
        self.btnContact.imageView?.contentMode = .scaleAspectFit
        self.lblPromotionOfferAmount.textColor = UIColor.init(hex: "F21600")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func btnJobDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonJOBDetailWith(index: self.tag)
        }
    }
    @IBAction func buttonContactSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonContactSelectorWith(index: self.tag)
        }
    }
    @IBAction func buttonAttachmentSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonAttachmentSelectorWith(index: self.tag)
        }
    }
    @IBAction func buttonProviderDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonProviderDetailSelectorWith(index: self.tag)
        }
    }
    @IBAction func buttonBookselector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonBookJOBSelectorWith(index: self.tag)
        }
    }
    @IBAction func buttonPaymentselector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonPaymentSelectorWith(index: self.tag)
        }
    }
    @IBAction func buttonPaymentHistoryselector(sender:UIButton){
        if let _ = self.delegate{
                   self.delegate!.buttonPaymentHistorySelectorWith(index: self.tag)
               }
    }
    @IBAction func buttonReportProblemselector(sender:UIButton){
           if let _ = self.delegate{
            self.delegate!.buttonReportProblemSelectorWith(index: self.tag)
           }
       }
    @IBAction func buttonPromotionDetailselector(sender:UIButton){
        if let _  = self.delegate{
            self.delegate!.buttonPromotionDetailSelector(index: self.tag)
        }
    }
    
    
}
