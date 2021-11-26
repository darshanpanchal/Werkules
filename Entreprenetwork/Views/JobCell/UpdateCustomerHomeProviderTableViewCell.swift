//
//  UpdateCustomerHomeProviderTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 30/09/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol UpdateCustomerHomeDelegate {
    func buttonAttachmentClick(index:Int)
    func buttonProviderDetailClick(index:Int)
    func buttonContactDetailClick(index:Int)
    func buttonBookJOBDetailClick(index:Int)
    func buttonProviderDetailSelector(index:Int)
    //more option
    func buttonDeleteOfferClick(index:Int)
    func buttonCancelOfferClick(index:Int)
    func buttonPostDetailClick(index:Int)

    func buttonMoreClick(index:Int)


}
class UpdateCustomerHomeProviderTableViewCell: UICollectionViewCell {


    @IBOutlet weak var lblOfferPrice:UILabel!
    @IBOutlet weak var lblKeyword:UILabel!


    @IBOutlet weak var imageBusinessLogo:UIImageView!
    @IBOutlet weak var imageUserProfile:UIImageView!


    @IBOutlet weak var lblReview:UILabel!
    @IBOutlet weak var lblAllReview:UILabel!
    @IBOutlet weak var lblProviderBusinessName:UILabel!

    
    @IBOutlet weak var buttonBookNowTile:UIButton!
    @IBOutlet weak var buttonContactTile:UIButton!
    @IBOutlet weak var viewMore:UIView!
    @IBOutlet weak var buttonMore:UIButton!

    var delegate:UpdateCustomerHomeDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.buttonMore.tintColor = UIColor.darkGray
        self.buttonMore.setImage(UIImage(named: "ellipsis"), for: UIControl.State.normal)
        self.buttonMore.setImage(UIImage(named: "ellipsis_selected"), for: UIControl.State.selected)
        self.clipsToBounds = true
        self.layer.cornerRadius = 10.0
        self.imageUserProfile.layer.cornerRadius = 40.0
        self.imageUserProfile.layer.borderColor = UIColor.white.cgColor
        self.imageUserProfile.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.init(hex: "AAAAAA").cgColor
        self.layer.borderWidth = 0.5

        self.viewMore.clipsToBounds = true
        self.viewMore.layer.cornerRadius = 7.0
        self.viewMore.layer.borderColor = UIColor.darkGray.cgColor
        self.viewMore.layer.borderWidth = 0.7

        self.buttonMore.tintColor = UIColor.darkGray
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))

        self.lblProviderBusinessName.isUserInteractionEnabled = true
        self.lblProviderBusinessName.addGestureRecognizer(tapGesture)
    }
    @objc func handleTap(){
        guard let _ = self.delegate else {
            return
        }
        self.delegate!.buttonProviderDetailSelector(index: self.tag)
    }

    @IBAction func btnMoreslector(sender:UIButton){
        if let _ = self.delegate{
                   self.delegate!.buttonMoreClick(index: self.tag)
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
    @IBAction func buttonProviderDetailSelector(sender:UIButton){
        guard let _ = self.delegate else {
            return
        }
        self.delegate!.buttonProviderDetailClick(index: self.tag)
    }
    @IBAction func buttonContactSelector(sender:UIButton){
        guard let _ = self.delegate else {
            return
        }
        self.delegate!.buttonContactDetailClick(index: self.tag)
    }
    @IBAction func buttonBookNowSelector(sender:UIButton){
        guard let _ = self.delegate else {
            return
        }
        self.delegate!.buttonBookJOBDetailClick(index: self.tag)
    }
    
}
