//
//  KeywordResultCollectionViewCell.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 21/09/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

protocol KeywordResultDelegate {
    func buttonContactSelector(index:Int)
    func buttonBookSelector(index:Int)
    func buttonDetailSelector(index:Int)
    func buttonProviderDetailSelector(index:Int)
}

class KeywordResultCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var viewProviderContainerSearchKeyword:UILabel!
    @IBOutlet weak var viewProviderContainerDate:UILabel!
    @IBOutlet weak var viewProviderContainerTime:UILabel!

    @IBOutlet weak var viewProviderContainerReview:UILabel!
    @IBOutlet weak var viewProviderContainerProviderName:UILabel!
    @IBOutlet weak var viewProviderContainerProviderImage:UIImageView!

    @IBOutlet weak var buttonBookNowTile:UIButton!
    @IBOutlet weak var buttonContactTile:UIButton!



    @IBOutlet weak var imageUserProfile:UIImageView!
    @IBOutlet weak var lblAllReview:UILabel!


    var provider:NotifiedProviderOffer?{
        didSet{
            //Configure
            DispatchQueue.main.async {
                self.configureCurrentProviderDetails()

            }
        }
    }
    var currentSearchKeyword = ""
    var delegate:KeywordResultDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.clipsToBounds = true
        self.layer.cornerRadius = 10.0
        self.imageUserProfile.layer.cornerRadius = 40.0
        self.imageUserProfile.layer.borderColor = UIColor.white.cgColor
        self.imageUserProfile.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.init(hex: "AAAAAA").cgColor
        self.layer.borderWidth = 0.5
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))

        self.viewProviderContainerProviderName.isUserInteractionEnabled = true
        self.viewProviderContainerProviderName.addGestureRecognizer(tapGesture)
    }
    @objc func handleTap(){
        guard let _ = self.delegate else {
            return
        }
        self.delegate!.buttonProviderDetailSelector(index: self.tag)
    }
    func configureCurrentProviderDetails(){
        if let currentKeyWordSearchProvider = self.provider{
            self.viewProviderContainerProviderImage.contentMode = .scaleAspectFill
            self.viewProviderContainerProviderImage.clipsToBounds = true
            self.viewProviderContainerSearchKeyword.text = self.currentSearchKeyword
            let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateformatter.date(from: currentKeyWordSearchProvider.searchDate)
                 dateformatter.dateFormat = "MM/dd/yyyy"
            if let _ = date{
                self.viewProviderContainerDate.text = dateformatter.string(from: date!.toLocalTime())
                self.viewProviderContainerTime.text = Date.getFormattedTimeForJob(string: currentKeyWordSearchProvider.searchDate)
            }



            let underlineBusinessName = NSAttributedString(string: "\(currentKeyWordSearchProvider.businessName)",
                                                                      attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
            self.viewProviderContainerProviderName.attributedText = underlineBusinessName


                    let businessLogo = currentKeyWordSearchProvider.businessLogo
                    if let imageURL = URL.init(string: "\(businessLogo)"){
                        autoreleasepool {
                        self.viewProviderContainerProviderImage!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                        }
                    }
            if let profileImage = currentKeyWordSearchProvider.customerDetail["profile_pic"]{
                if let imageURL = URL.init(string: "\(profileImage)"){
                    autoreleasepool {
                    self.imageUserProfile!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                    }
                }
            }

            if let pi: Double = Double("\(currentKeyWordSearchProvider.rating)"){
                          let rating = String(format:"%.1f", pi)
                let underlinerating = NSAttributedString(string: "\(rating)",
                                                                          attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
                           self.viewProviderContainerReview.attributedText = underlinerating
                      }
            self.lblAllReview.text = "(\(currentKeyWordSearchProvider.review) Reviews)"


            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                            return
                }
            if currentUser.id == "\(currentKeyWordSearchProvider.customerDetail["id"] ?? "")"{
                self.buttonBookNowTile.isHidden  = true
                self.buttonContactTile.isHidden = true
            }else{

                self.buttonBookNowTile.isHidden  = currentUser.userRoleType == .provider
                self.buttonContactTile.isHidden = false
            }
        }
    }
    @IBAction func buttonContactSelector(sender:UIButton){
        guard let _ = self.delegate else {
            return
        }
        self.delegate!.buttonContactSelector(index: self.tag)
    }
    @IBAction func buttonBookNowSelector(sender:UIButton){
        guard let _ = self.delegate else {
            return
        }
        self.delegate!.buttonBookSelector(index: self.tag)
    }
    @IBAction func buttonDetailSelector(sender:UIButton){
        guard let _ = self.delegate else {
            return
        }
        self.delegate!.buttonDetailSelector(index: self.tag)
    }
    @IBAction func buttonProviderDetailSelector(sender:UIButton){
        guard let _ = self.delegate else {
            return
        }
        self.delegate!.buttonProviderDetailSelector(index: self.tag)
    }

}
