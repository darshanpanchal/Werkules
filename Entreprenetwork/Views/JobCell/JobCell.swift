//
//  JobCell.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 24/07/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
protocol JOBCellDelegate {
    func buttonAttachmentClick(index:Int)
    func buttonProviderDetailClick(index:Int)
    func buttonContactDetailClick(index:Int)
    func buttonBookJOBDetailClick(index:Int)
    
    //more option
    func buttonDeleteOfferClick(index:Int)
    func buttonCancelOfferClick(index:Int)
    func buttonPostDetailClick(index:Int)
 
    func buttonMoreClick(index:Int)
}

class JobCell: UICollectionViewCell {

    
    @IBOutlet weak var viewMore:UIView!

    @IBOutlet weak var buttonmore:UIButton!
    
    @IBOutlet weak var containerView:UIView!
    @IBOutlet weak var imgViewBGBox: UIImageView!
    @IBOutlet weak var lblJobTitle: UILabel!
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblProviderBusinessName:UILabel!
    
    @IBOutlet weak var lblAskingPriceTitle: UILabel!
    @IBOutlet weak var lblAskingPrice: UILabel!
    
    @IBOutlet weak var lblOfferPriceTitle: UILabel!
    @IBOutlet weak var lblOfferPrice: UILabel!
    
    @IBOutlet weak var imgStar: UIImageView!
    @IBOutlet weak var lblRatings: UILabel!
    
    @IBOutlet weak var viewOfferPriceContainer:UIView!
    
    @IBOutlet weak var viewPromotionPriceContainer:UIView!
    @IBOutlet weak var lblPromotionOffer:UILabel!
    @IBOutlet weak var lblPromotionOfferAmount:UILabel!
    
    @IBOutlet weak var viewAttachmentContainer:UIView!
    
    @IBOutlet weak var providerBusinessImage:UIImageView!
    @IBOutlet weak var offerGreenView:UIView!
    @IBOutlet weak var viewDeleteOffer:UIView!
    
    @IBOutlet weak var heightOfferGreen:NSLayoutConstraint!
    
    var delegate:JOBCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            
            self.buttonmore.setImage(UIImage(named: "ellipsis"), for: UIControl.State.normal)
            self.buttonmore.setImage(UIImage(named: "ellipsis"), for: UIControl.State.selected)
            //self.buttonmore.setImage(UIImage(named: "ellipsis"), for: UIControl.State.normal)
            
            // Initialization code
           self.containerView.clipsToBounds = true
           self.containerView.layer.cornerRadius = 20.0
           
           self.providerBusinessImage.clipsToBounds = true
            self.providerBusinessImage.layer.cornerRadius = 17.5
            
            self.viewMore.clipsToBounds = true
            self.viewMore.layer.cornerRadius = 7.0
            self.viewMore.layer.borderColor = UIColor.darkGray.cgColor
            self.viewMore.layer.borderWidth = 0.7
            
            self.buttonmore.tintColor = UIColor.darkGray
        }
       
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        DispatchQueue.main.async {
            //self.viewAttachmentContainer.isHidden = true
            //self.viewPromotionPriceContainer.isHidden = true
        }
       
    }
    func configureSelectedStatus(isCurrent:Bool){
        
        if isCurrent{
            self.imgViewBGBox.isHidden = false
            self.lblJobTitle.textColor = UIColor.init(hex: "FFFFFF")
            self.lblRatings.textColor = UIColor.init(hex: "FFFFFF")
            self.lblDate.textColor = UIColor.init(hex: "FFFFFF")
            self.lblProviderBusinessName.textColor = UIColor.init(hex: "FFFFFF")
            self.lblOfferPriceTitle.textColor = UIColor.init(hex: "FFFFFF")
            //self.lblOfferPrice.textColor = UIColor.init(hex: "FFFFFF")
            self.lblAskingPriceTitle.textColor = UIColor.init(hex: "FFFFFF")
            self.lblAskingPrice.textColor = UIColor.init(hex: "FFFFFF")
            self.lblPromotionOffer.textColor = UIColor.init(hex: "FFFFFF")
            self.lblPromotionOfferAmount.textColor = UIColor.init(hex: "FFC107")
            self.buttonmore.tintColor = UIColor.white
        }else{
            self.buttonmore.tintColor = UIColor.darkGray
            self.imgViewBGBox.isHidden = true
            self.lblJobTitle.textColor = UIColor.init(hex: "38B5A3")
            self.lblRatings.textColor = UIColor.init(hex: "000000")
            self.lblDate.textColor = UIColor.init(hex: "000000")
            self.lblProviderBusinessName.textColor = UIColor.init(hex: "000000")
            self.lblOfferPriceTitle.textColor = UIColor.init(hex: "000000")
            //self.lblOfferPrice.textColor = UIColor.init(hex: "000000")
            self.lblAskingPriceTitle.textColor = UIColor.init(hex: "000000")
            self.lblAskingPrice.textColor = UIColor.init(hex: "000000")
            self.lblPromotionOffer.textColor = UIColor.init(hex: "000000")
            self.lblPromotionOfferAmount.textColor = UIColor.init(hex: "F21600")
        }
    }
    //MARK:- SELECTOR METHODS
    @IBAction func btnMoreslector(sender:UIButton){
        if let _ = self.delegate{
                   self.delegate!.buttonMoreClick(index: self.tag)
               }
    }
    @IBAction func btnAttachmentDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonAttachmentClick(index: self.tag)
        }
    }
    @IBAction func btnProviderDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonProviderDetailClick(index: self.tag)
        }
    }
    @IBAction func btnProviderContactSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonContactDetailClick(index: self.tag)
        }
    }
    @IBAction func btnRequestOfferDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonBookJOBDetailClick(index: self.tag)
        }
    }
    @IBAction func btnPostdetailDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonPostDetailClick(index: self.tag)
            self.delegate!.buttonMoreClick(index: self.tag)
        }
    }
    @IBAction func btnPostdeleteDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonDeleteOfferClick(index: self.tag)
            self.delegate!.buttonMoreClick(index: self.tag)
            
        }
    }
    @IBAction func btnPostcancleSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonCancelOfferClick(index: self.tag)
            self.delegate!.buttonMoreClick(index: self.tag)
        }
    }
    
    
}
protocol ProviderOfferCellDelegate {
    func buttonAttachmentClick(index:Int)
    func buttonJOBDetailClick(index:Int)
    func buttonCustomerDetailClick(index:Int)
    func buttonContactClick(index:Int)
    func buttonSendOfferClick(index:Int)
    func buttonMoreProviderCellClick(index:Int)
    func buttonDeleteProviderCellClick(index:Int)
    func buttonWithDrawWith(index:Int)
}

class ProviderOfferCell:UICollectionViewCell{
    
    
    @IBOutlet weak var viewMore:UIView!

    @IBOutlet weak var buttonmore:UIButton!
    
    @IBOutlet weak var imgViewCustomer: UIImageView!
    @IBOutlet weak var lblCustomerName: UILabel!
    
    @IBOutlet weak var offerYellowView:UIView!
    @IBOutlet weak var lblOffer:UILabel!
    
    @IBOutlet weak var containerView:UIView!
      @IBOutlet weak var imgViewBGBox: UIImageView!
      @IBOutlet weak var lblJobTitle: UILabel!
      @IBOutlet weak var lblDate:UILabel!
      @IBOutlet weak var lblProviderBusinessName:UILabel!
      
      @IBOutlet weak var lblAskingPriceTitle: UILabel!
      @IBOutlet weak var lblAskingPrice: UILabel!
      
      @IBOutlet weak var lblOfferPriceTitle: UILabel!
      @IBOutlet weak var lblOfferPrice: UILabel!
      
      @IBOutlet weak var imgStar: UIImageView!
      @IBOutlet weak var lblRatings: UILabel!
      
      @IBOutlet weak var viewOfferPriceContainer:UIView!
      @IBOutlet weak var viewAttachmentContainer:UIView!
    
    @IBOutlet weak var heightWaitingForOffer:NSLayoutConstraint!

    @IBOutlet weak var viewPromotionPriceContainer:UIView!
      @IBOutlet weak var lblPromotionOffer:UILabel!
      @IBOutlet weak var lblPromotionOfferAmount:UILabel!
    
    @IBOutlet weak var buttonSendOffer:UIButton!
    @IBOutlet weak var viewSendOffer:UIView!
    
    @IBOutlet weak var viewJobDetail:UIView!
    @IBOutlet weak var viewDeleteJobDetail:UIView!
    @IBOutlet weak var viewCustomerDetail:UIView!
    @IBOutlet weak var viewContactDetail:UIView!
    @IBOutlet weak var viewWithdrawOfferDetail:UIView!
    
    
    
    var delegate:ProviderOfferCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.containerView.clipsToBounds = true
                   self.containerView.layer.cornerRadius = 20.0
                   
                   self.imgViewCustomer.clipsToBounds = true
                   self.imgViewCustomer.layer.cornerRadius = 15.0
                   
                   self.buttonmore.setImage(UIImage(named: "ellipsis"), for: UIControl.State.selected)
                    self.buttonmore.setImage(UIImage(named: "ellipsis"), for: UIControl.State.normal)
                   //self.buttonmore.setImage(UIImage(named: "ellipsis"), for: UIControl.State.normal)
            
                      self.viewMore.clipsToBounds = true
                      self.viewMore.layer.cornerRadius = 7.0
                      self.viewMore.layer.borderColor = UIColor.darkGray.cgColor
                      self.viewMore.layer.borderWidth = 0.7
                      self.buttonmore.tintColor = UIColor.darkGray
        }
       
                   
    }
    func configureSelectedStatus(isCurrent:Bool){
        
        if isCurrent{
            self.imgViewBGBox.isHidden = false
            self.lblJobTitle.textColor = UIColor.init(hex: "FFFFFF")
            self.lblRatings.textColor = UIColor.init(hex: "FFFFFF")
            self.lblDate.textColor = UIColor.init(hex: "FFFFFF")
            self.lblProviderBusinessName.textColor = UIColor.init(hex: "FFFFFF")
            self.lblOfferPriceTitle.textColor = UIColor.init(hex: "FFFFFF")
            //self.lblOfferPrice.textColor = UIColor.init(hex: "FFFFFF")
            self.lblAskingPriceTitle.textColor = UIColor.init(hex: "FFFFFF")
            self.lblAskingPrice.textColor = UIColor.init(hex: "FFFFFF")
            self.lblCustomerName.textColor = UIColor.init(hex: "FFFFFF")
            self.buttonmore.tintColor = UIColor.white
            self.lblPromotionOffer.textColor = UIColor.init(hex: "FFFFFF")
            self.lblPromotionOfferAmount.textColor = UIColor.yellow
        }else{
            self.lblPromotionOffer.textColor = UIColor.init(hex: "000000")
            self.buttonmore.tintColor = UIColor.darkGray
            self.imgViewBGBox.isHidden = true
            self.lblJobTitle.textColor = UIColor.init(hex: "38B5A3")
            self.lblRatings.textColor = UIColor.init(hex: "000000")
            self.lblDate.textColor = UIColor.init(hex: "000000")
            self.lblProviderBusinessName.textColor = UIColor.init(hex: "000000")
            self.lblOfferPriceTitle.textColor = UIColor.init(hex: "000000")
            //self.lblOfferPrice.textColor = UIColor.init(hex: "000000")
            self.lblAskingPriceTitle.textColor = UIColor.init(hex: "000000")
            self.lblAskingPrice.textColor = UIColor.init(hex: "000000")
            self.lblCustomerName.textColor = UIColor.init(hex: "000000 ")
            self.lblPromotionOfferAmount.textColor = UIColor.init(hex: "F21600")
        }
    }
    //MARK:- SELECTOR METHODS
    @IBAction func btnAttachmentDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonAttachmentClick(index: self.tag)
        }
    }
    @IBAction func btnJOBDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonJOBDetailClick(index: self.tag)
        }
    }
    @IBAction func btnCustomerDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonCustomerDetailClick(index: self.tag)
        }
    }
    @IBAction func btnContactSelector(sender:UIButton){
        if let _ = self.delegate{
                   self.delegate!.buttonContactClick(index: self.tag)
               }
    }
    @IBAction func btnRequestOfferDetailSelector(sender:UIButton){
        if let _ = self.delegate{
                   self.delegate!.buttonSendOfferClick(index: self.tag)
               }
    }
    @IBAction func btnMoreslector(sender:UIButton){
         if let _ = self.delegate{
                    self.delegate!.buttonMoreProviderCellClick(index: self.tag)
                }
    }
    @IBAction func btnPostdetailDetailSelector(sender:UIButton){
           if let _ = self.delegate{
               self.delegate!.buttonJOBDetailClick(index: self.tag)
               self.delegate!.buttonMoreProviderCellClick(index: self.tag)
           }
       }
       @IBAction func btnPostdeleteDetailSelector(sender:UIButton){
           if let _ = self.delegate{
               self.delegate!.buttonDeleteProviderCellClick(index: self.tag)
               self.delegate!.buttonMoreProviderCellClick(index: self.tag)
               
           }
       }
    @IBAction func btnWithdrawSelector(sender:UIButton){
          if let _ = self.delegate{
            self.delegate!.buttonWithDrawWith(index: self.tag)
              self.delegate!.buttonMoreProviderCellClick(index: self.tag)
              
          }
      }
    
}
extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
        return attributeString
    }
}
