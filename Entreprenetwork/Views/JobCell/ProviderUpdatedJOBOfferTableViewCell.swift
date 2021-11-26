//
//  ProviderUpdatedJOBOfferTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS on 31/05/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol ProviderOfferUpdateCellDelegate {
    func buttonDeleteJOBWith(index:Int)
    func buttonWithDrawWith(index:Int)
    func buttonJOBDetailWith(index:Int)
    func buttonContactDetailWith(index:Int)
    func buttonCustomerDetailWith(index:Int)
    func buttonSendOfferWith(index:Int)
      func buttonMoreProviderCellClick(index:Int)
    func buttonPromotionDetailSelector(index:Int)
    func buttonAttachmentSelectorWith(index:Int)
}
class ProviderUpdatedJOBOfferTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView:UIView!
    @IBOutlet weak var objshadowview:ShadowBackgroundView!
    
    @IBOutlet weak var viewWaitingForSentOfferReply:UIView!
    
    @IBOutlet weak var btnMore:UIButton!
    @IBOutlet weak var viewMore:UIView!

    @IBOutlet weak var ViewDeleteJOB:UIView!
    @IBOutlet weak var ViewCustomerDetail:UIView!
    @IBOutlet weak var ViewContact:UIView!
    @IBOutlet weak var ViewWithDrawOffer:UIView!
    
    @IBOutlet weak var lbltitle:UILabel!
    
    @IBOutlet weak var lblOfferDate:UILabel!
    @IBOutlet weak var lblOfferTime:UILabel!
    
    
    @IBOutlet weak var viewOfferAmount:UIView!
    @IBOutlet weak var lblOfferAmount:UILabel!
    
    @IBOutlet weak var viewAskingPrice:UIView!
    @IBOutlet weak var lblAskingPrice:UILabel!
    
    @IBOutlet weak var viewDateOfPost:UIView!
    @IBOutlet weak var lbldateofpost:UILabel!
    
    
    @IBOutlet weak var lblrating:UILabel!
    
   @IBOutlet weak var lblCustomerName:UILabel!
   @IBOutlet weak var imgCustomerLogo:UIImageView!
   @IBOutlet weak var buttonContact:UIButton!
    @IBOutlet weak var buttonJOBDetail:UIButton!
    
    @IBOutlet weak var viewPromotionContainer:UIView!
     @IBOutlet weak var lblPromotionOfferAmount:UILabel!
     @IBOutlet weak var lblPromotionOffer:UILabel!
     @IBOutlet weak var btnPromotionDetail:UIButton!
    
    @IBOutlet weak var viewDocument:UIView!
    @IBOutlet weak var btnAttachment:UIButton!
    @IBOutlet weak var btnNoAttachment:UIButton!
    
    
    @IBOutlet weak var heightOfSendOfferDetailView:NSLayoutConstraint! // 40 - 0
    
    var delegate:ProviderOfferUpdateCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let underlineSeeDetail = NSAttributedString(string: "Attachment",
                                                                         attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnAttachment.setAttributedTitle(underlineSeeDetail, for: .normal)
        //self.btnAttachment.titleLabel?.attributedText = underlineSeeDetail
        
        self.lblPromotionOfferAmount.textColor = UIColor.init(hex: "F21600")
        let underlineSeeDetail1 = NSAttributedString(string: "See Details",attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnPromotionDetail.setAttributedTitle(underlineSeeDetail1, for: .normal)
        //self.btnPromotionDetail.titleLabel?.attributedText = underlineSeeDetail1
                     
        // Initialization code
        self.objshadowview.rounding = 15.0
        self.objshadowview.layer.cornerRadius = 15.0
        self.objshadowview.layoutIfNeeded()
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 15.0
        self.btnMore.tintColor = UIColor.darkGray

        self.btnMore.setImage(UIImage(named: "ellipsis_selected"), for: UIControl.State.selected)
        self.btnMore.setImage(UIImage(named: "ellipsis"), for: UIControl.State.normal)
        self.viewMore.clipsToBounds = true
        self.viewMore.layer.cornerRadius = 7.0
        self.viewMore.layer.borderColor = UIColor.darkGray.cgColor
        self.viewMore.layer.borderWidth = 0.7
        self.imgCustomerLogo.clipsToBounds = true
        self.imgCustomerLogo.layer.cornerRadius = 20.0
        self.imgCustomerLogo.contentMode = .scaleAspectFill
               self.imgCustomerLogo.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
      func configureOfferCell(isOfferSent:Bool){
              DispatchQueue.main.async {
                    if isOfferSent{
                        
                        self.viewWaitingForSentOfferReply.isHidden = false
                        self.ViewDeleteJOB.isHidden = true
                        self.ViewCustomerDetail.isHidden = false
                        self.ViewContact.isHidden = false
                        self.ViewWithDrawOffer.isHidden = false
                        self.viewOfferAmount.isHidden = false
                        self.viewDateOfPost.isHidden = false
                        self.buttonJOBDetail.isHidden = false
                        self.buttonContact.isHidden = true
                        self.heightOfSendOfferDetailView.constant = 0
                        
                    }else{
                        
                        self.viewWaitingForSentOfferReply.isHidden = true
                        self.ViewDeleteJOB.isHidden = false
                        self.ViewCustomerDetail.isHidden = true
                        self.ViewContact.isHidden = true
                        self.ViewWithDrawOffer.isHidden = true
                        self.viewOfferAmount.isHidden = true
                        self.viewDateOfPost.isHidden = true
                        self.buttonJOBDetail.isHidden = true
                        self.buttonContact.isHidden = false
                        self.heightOfSendOfferDetailView.constant = 40
                        
                        
                    }
                  self.layoutIfNeeded()
                }
          
    
         }
    @IBAction func buttonAttachmentSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonAttachmentSelectorWith(index: self.tag)
        }
    }
    @IBAction func buttonPromotionDetailselector(sender:UIButton){
          if let _  = self.delegate{
              self.delegate!.buttonPromotionDetailSelector(index: self.tag)
          }
      }
    @IBAction func btnJobDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonJOBDetailWith(index: self.tag)
        }
    }
 
    @IBAction func btnSendOfferSelector(sender:UIButton){
            if let _ = self.delegate{
                self.delegate!.buttonSendOfferWith(index: self.tag)
            }
        }
    @IBAction func btnMoreslector(sender:UIButton){
        if let _ = self.delegate{
                  self.delegate!.buttonMoreProviderCellClick(index: self.tag)
              }
        }
    @IBAction func btnDeleteJOBselector(sender:UIButton){
         if let _ = self.delegate{
            self.delegate!.buttonDeleteJOBWith(index: self.tag)
                   self.delegate!.buttonMoreProviderCellClick(index: self.tag)
               }
         }
     
    @IBAction func btnCustomerDetailselector(sender:UIButton){
         if let _ = self.delegate{
            self.delegate!.buttonCustomerDetailWith(index: self.tag)
                   //self.delegate!.buttonMoreProviderCellClick(index: self.tag)
               }
         }
     
    @IBAction func btnContactselector(sender:UIButton){
         if let _ = self.delegate{
                   self.delegate!.buttonContactDetailWith(index: self.tag)
                   //self.delegate!.buttonMoreProviderCellClick(index: self.tag)
               }
         }
     
    @IBAction func btnWthDrawofferselector(sender:UIButton){
         if let _ = self.delegate{
            self.delegate!.buttonWithDrawWith(index: self.tag)
               }
         }
     
    
    
}
