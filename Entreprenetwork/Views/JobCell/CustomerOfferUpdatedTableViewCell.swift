//
//  CustomerOfferUpdatedTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS on 28/05/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol CustomerOfferUpdateCellDelegate {
    func buttonContactSelectorWith(index:Int)
    func buttonAttachmentSelectorWith(index:Int)
    func buttonProviderDetailSelectorWith(index:Int)
    func buttonBookJOBSelectorWith(index:Int)
    func buttonPaymentSelectorWith(index:Int)
    func buttonReportProblemSelectorWith(index:Int)
    func buttonPaymentHistorySelectorWith(index:Int)
    func buttonPromotionDetailSelector(index:Int)
    func buttonMoreProviderCellClick(index:Int)
    func buttonPostDetailCellClick(inde:Int)
    func buttonDeleteOfferClick(index:Int)
    func buttonCancelPostClick(index:Int)
}
class CustomerOfferUpdatedTableViewCell: UITableViewCell {

    var delegate:CustomerOfferUpdateCellDelegate?

    
    @IBOutlet weak var lbltitle:UILabel!
    @IBOutlet weak var btnMore:UIButton!
    @IBOutlet weak var viewMore:UIView!
    
    @IBOutlet weak var lblDate:UILabel!
      
      @IBOutlet weak var lblAskingPrice:UILabel!
      @IBOutlet weak var lblAcceptedPrice:UILabel!
      @IBOutlet weak var lblOfferPrice:UILabel!
      @IBOutlet weak var lblBusinessName:UILabel!
      @IBOutlet weak var lblRating:UILabel!
      @IBOutlet weak var lbldateofpost:UILabel!
      @IBOutlet weak var lbltimeofpost:UILabel!
      @IBOutlet weak var lbldateofaccepted:UILabel!
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
      
      @IBOutlet weak var viewProviderDetail:UIView!
      
      
      
      
      @IBOutlet weak var lblDateOfCompleted:UILabel!
      
      
      @IBOutlet weak var viewPromotionContainer:UIView!
      @IBOutlet weak var lblPromotionOfferAmount:UILabel!
      @IBOutlet weak var lblPromotionOffer:UILabel!
      @IBOutlet weak var btnPromotionDetail:UIButton!
    
    @IBOutlet weak var heightOfProviderDetailView:NSLayoutConstraint! // 60 - 0
    @IBOutlet weak var heightOfWaitingOffer:NSLayoutConstraint! // 20 - 0
    
    @IBOutlet weak var viewWaitingForOffer:UIView!
    
    @IBOutlet weak var buttonPostDetail:UIButton!
    @IBOutlet weak var viewbuttonDeletePostDetail:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.objshadowview.rounding = 15.0
        self.objshadowview.layer.cornerRadius = 15.0
        self.objshadowview.layoutIfNeeded()
//               
//               self.objshadowviewContact.rounding = 20.0
//               self.objshadowviewContact.layer.cornerRadius = 20.0
//               self.objshadowviewContact.layoutIfNeeded()
               
               
               
               self.containerView.clipsToBounds = true
               self.containerView.layer.cornerRadius = 15.0
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
                //self.btnPromotionDetail.titleLabel?.attributedText = underlineSeeDetail1
               

               self.btnContact.imageView?.contentMode = .scaleAspectFit
        
        self.viewMore.clipsToBounds = true
        self.viewMore.layer.cornerRadius = 7.0
        self.viewMore.layer.borderColor = UIColor.darkGray.cgColor
        self.viewMore.layer.borderWidth = 0.7
        // Initialization code
        self.btnMore.tintColor = UIColor.darkGray
        self.btnMore.setImage(UIImage(named: "ellipsis_selected"), for: UIControl.State.selected)
        self.btnMore.setImage(UIImage(named: "ellipsis"), for: UIControl.State.normal)
        self.lblPromotionOfferAmount.textColor = UIColor.init(hex: "F21600")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.configureOfferCell(isPreOffer: true)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureOfferCell(isPreOffer:Bool){
        UIView.performWithoutAnimation {
            DispatchQueue.main.async {
                  if isPreOffer{
                      
                      self.viewWaitingForOffer.isHidden = false
                      self.viewDateOfPost.isHidden = true
                      self.viewAcceptedPrice.isHidden = true
                      self.viewOfferPrice.isHidden = true
                      self.btnBookNow.isHidden = true
                      self.viewDocument.isHidden = true
                      self.buttonPostDetail.isHidden = false
                      self.viewbuttonDeletePostDetail.isHidden = true
                      self.heightOfProviderDetailView.constant = 0.0
                  }else{
                      
                      self.viewWaitingForOffer.isHidden = true
                      self.viewDateOfPost.isHidden = false
                      self.viewAcceptedPrice.isHidden = true
                      self.viewOfferPrice.isHidden = false
                      self.btnBookNow.isHidden = false
                      self.viewDocument.isHidden = false
                      self.buttonPostDetail.isHidden = true
                      self.viewbuttonDeletePostDetail.isHidden = false
                      self.heightOfProviderDetailView.constant = 50.0
                  }
              }
        }
       }
    @IBAction func btnMoreslector(sender:UIButton){
            if let _ = self.delegate{
                       self.delegate!.buttonMoreProviderCellClick(index: self.tag)
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
    @IBAction func buttonPostDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonPostDetailCellClick(inde: self.tag)
        }
    }
    @IBAction func buttonPostDeleteSelector(sender:UIButton){
           if let _ = self.delegate{
            self.delegate!.buttonDeleteOfferClick(index:self.tag)
            self.delegate!.buttonMoreProviderCellClick(index: self.tag)
           }
       }
    @IBAction func buttonPostCancelSelector(sender:UIButton){
             if let _ = self.delegate{
              self.delegate!.buttonCancelPostClick(index:self.tag)
                self.delegate!.buttonMoreProviderCellClick(index: self.tag)
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
