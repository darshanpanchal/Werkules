//
//  UpdateProviderHomeCollectionViewCell.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 19/10/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
class UpdateProviderHomeCollectionViewCell: UICollectionViewCell {

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
    @IBOutlet weak var lblAllReview:UILabel!

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


    @IBOutlet weak var viewKeyword:UIView!
    @IBOutlet weak var lblKeyword:UILabel!

    var delegate:ProviderOfferCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))

            self.lblCustomerName.isUserInteractionEnabled = true
            self.lblCustomerName.addGestureRecognizer(tapGesture)
            self.containerView.clipsToBounds = true
                   self.containerView.layer.cornerRadius = 6.0

                   self.imgViewCustomer.clipsToBounds = true
                   self.imgViewCustomer.layer.cornerRadius = 25.0

                   self.buttonmore.setImage(UIImage(named: "ellipsis_selected"), for: UIControl.State.selected)
                    self.buttonmore.setImage(UIImage(named: "ellipsis"), for: UIControl.State.normal)
                   //self.buttonmore.setImage(UIImage(named: "ellipsis"), for: UIControl.State.normal)

                      self.viewMore.clipsToBounds = true
                      self.viewMore.layer.cornerRadius = 7.0
                      self.viewMore.layer.borderColor = UIColor.darkGray.cgColor
                      self.viewMore.layer.borderWidth = 0.7
                      self.buttonmore.tintColor = UIColor.darkGray
        }
    }
    @objc func handleTap(){
        if let _ = self.delegate{
            self.delegate!.buttonCustomerDetailClick(index: self.tag)
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
