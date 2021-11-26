//
//  CustomerCompletedUpdatedTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 31/08/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit


protocol CustomerCompletedCellDelegate {
    func buttonMoreProviderCellClick(index:Int)
    func buttonPostDetailCellClick(inde:Int)
    func buttonCancelPostClick(index:Int)
    func buttonContactSelectorWith(index:Int)
    func buttonPromotionDetailSelector(index:Int)
    func buttonAttachmentSelectorWith(index:Int)
    func buttonProviderDetailSelectorWith(index:Int)
    func buttonPaymentSelectorWith(index:Int)
    func buttonReportProblemSelectorWith(index:Int)
    func buttonPaymentHistorySelectorWith(index:Int)
}
class CustomerCompletedUpdatedTableViewCell: UITableViewCell {

    var delegate:CustomerCompletedCellDelegate?

    @IBOutlet weak var containerView:UIView!
    @IBOutlet weak var objshadowview:ShadowBackgroundView!

    @IBOutlet weak var lbltitle:UILabel!
    @IBOutlet weak var btnMore:UIButton!
    @IBOutlet weak var viewMore:UIView!



    @IBOutlet weak var viewAcceptedPrice:UIView!
    @IBOutlet weak var lblAcceptedPrice:UILabel!
    @IBOutlet weak var lblAcceptedPriceName:UILabel!


    @IBOutlet weak var viewAskingPrice:UIView!
    @IBOutlet weak var lblAskingPrice:UILabel!
    @IBOutlet weak var lblAskingPriceName:UILabel!

    @IBOutlet weak var viewDocument:UIView!
    @IBOutlet weak var btnAttachment:UIButton!
    @IBOutlet weak var btnNoAttachment:UIButton!


    @IBOutlet weak var viewPromotionContainer:UIView!
    @IBOutlet weak var lblPromotionOfferAmount:UILabel!
    @IBOutlet weak var lblPromotionOffer:UILabel!
    @IBOutlet weak var btnPromotionDetail:UIButton!

    @IBOutlet weak var viewDateOfPost:UIView!
    @IBOutlet weak var lblDateOfPost:UILabel!
    @IBOutlet weak var viewDateofAccepted:UIView!
    @IBOutlet weak var lblDateOfAccepted:UILabel!

    @IBOutlet weak var businessLogo:UIImageView!
    @IBOutlet weak var lblBusinessName:UILabel!
    @IBOutlet weak var lblRating:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.objshadowview.rounding = 15.0
        self.objshadowview.layer.cornerRadius = 15.0
        self.objshadowview.layoutIfNeeded()

        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 15.0
        self.viewMore.clipsToBounds = true
        self.viewMore.layer.cornerRadius = 7.0
        self.viewMore.layer.borderColor = UIColor.darkGray.cgColor
        self.viewMore.layer.borderWidth = 0.7
        self.btnMore.tintColor = UIColor.darkGray
        self.btnMore.setImage(UIImage(named: "ellipsis_selected"), for: UIControl.State.selected)
        self.btnMore.setImage(UIImage(named: "ellipsis"), for: UIControl.State.normal)

        self.businessLogo.contentMode = .scaleAspectFill
               self.businessLogo.clipsToBounds = true
        self.businessLogo.clipsToBounds = true
        self.businessLogo.layer.cornerRadius = 20.0
        self.businessLogo.layer.borderColor = UIColor.lightGray.cgColor
        self.businessLogo.layer.borderWidth = 0.7


        let underlineSeeDetail = NSAttributedString(string: "Attachment",
                                                                         attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnAttachment.setAttributedTitle(underlineSeeDetail, for: .normal)
        //self.btnAttachment.titleLabel?.attributedText = underlineSeeDetail

        let underlineSeeDetail1 = NSAttributedString(string: "See Details",
                                                                              attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnPromotionDetail.setAttributedTitle(underlineSeeDetail1, for: .normal)
        //self.btnPromotionDetail.titleLabel?.attributedText = underlineSeeDetail
        self.lblPromotionOfferAmount.textColor = UIColor.init(hex: "F21600")

        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func btnMoreslector(sender:UIButton){
            if let _ = self.delegate{
                       self.delegate!.buttonMoreProviderCellClick(index: self.tag)
                   }
       }
    @IBAction func buttonPostDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonPostDetailCellClick(inde: self.tag)
            self.delegate!.buttonMoreProviderCellClick(index: self.tag)
        }
    }
    @IBAction func buttonPostCancelSelector(sender:UIButton){
             if let _ = self.delegate{
               self.delegate!.buttonCancelPostClick(index:self.tag)
               self.delegate!.buttonMoreProviderCellClick(index: self.tag)
             }
         }
    @IBAction func buttonContactSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonContactSelectorWith(index: self.tag)
        }
    }
    @IBAction func buttonPromotionDetailselector(sender:UIButton){
        if let _  = self.delegate{
            self.delegate!.buttonPromotionDetailSelector(index: self.tag)
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
    @IBAction func buttonPaymentselector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonPaymentSelectorWith(index: self.tag)
        }
    }
    @IBAction func buttonReportProblemselector(sender:UIButton){
           if let _ = self.delegate{
            self.delegate!.buttonReportProblemSelectorWith(index: self.tag)
           }
       }
    @IBAction func buttonPaymentHistoryselector(sender:UIButton){
        if let _ = self.delegate{
                   self.delegate!.buttonPaymentHistorySelectorWith(index: self.tag)
               }
    }

}
