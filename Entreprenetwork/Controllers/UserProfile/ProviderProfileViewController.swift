//
//  ProviderProfileViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 03/02/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import FloatRatingView
import AVFoundation

class ProviderProfileViewController: UIViewController {


        
        @IBOutlet weak var tableViewProvider:UITableView!
        @IBOutlet weak var imgBusinessLogo:UIImageView!
        @IBOutlet weak var imgArrowDown:UIImageView!
        
        @IBOutlet weak var firstContainerView:UIView!
        @IBOutlet weak var firstShadowView:ShadowBackgroundView!
        @IBOutlet weak var secondContainerView:UIView!
        @IBOutlet weak var secondShadowView:ShadowBackgroundView!
        @IBOutlet weak var thirdContainerView:UIView!
        @IBOutlet weak var thirdShadowView:ShadowBackgroundView!

        
        @IBOutlet weak var lblBusinessName:UILabel!
        @IBOutlet weak var ratingView:FloatRatingView!
        @IBOutlet weak var lblBusinessReview:UILabel!
        
        @IBOutlet weak var imgProviderProfile:UIImageView!
        @IBOutlet weak var providerName:UILabel!
        @IBOutlet weak var imgProviderPhone:UIImageView!
        @IBOutlet weak var providerPhoneNumber:UILabel!
        @IBOutlet weak var imgBusiness:UIImageView!
        @IBOutlet weak var lblBusinessTitle:UILabel!
        @IBOutlet weak var imgEmail:UIImageView!
        @IBOutlet weak var lblBusinessEmail:UILabel!
           
        @IBOutlet weak var firstViewHeight:NSLayoutConstraint!
        @IBOutlet weak var firstViewMoreContainer:UIView!
        
        
        @IBOutlet weak var lblBusinessAddress:UILabel!
        @IBOutlet weak var lblBusinessDescription:UILabel!
        @IBOutlet weak var lblBusinessInsurance:UILabel!
        @IBOutlet weak var lblBusinessEIN:UILabel!
    
    @IBOutlet weak var businessInsuranceContainer:UIStackView!
        @IBOutlet weak var heightOfInsuranceContainer:NSLayoutConstraint!
        @IBOutlet weak var btnBusinessInsuranceView:UIButton!
    
        @IBOutlet weak var businessLicenceContainer:UIStackView!
        @IBOutlet weak var heightOfbusinessLicenceContainer:NSLayoutConstraint!
        @IBOutlet weak var btnBusinessLicenceView:UIButton!
    
        @IBOutlet weak var driverLicenceContainer:UIStackView!
        @IBOutlet weak var heightOfdriverLicenceContainer:NSLayoutConstraint!
        @IBOutlet weak var btnBusinessDriverLicenceView:UIButton!
    
    
    
        @IBOutlet weak var lblHomeLongWillingToTravel:UILabel!
        @IBOutlet weak var lblBusinessKeywords:UILabel!
    
        @IBOutlet weak var btnDirection:UIButton!
        @IBOutlet weak var lblPromotionTitle:UILabel!
        @IBOutlet weak var lblPromotionDetail:UILabel!
        @IBOutlet weak var btnPromotionalSetup:UIButton!
        @IBOutlet weak var btnPromotionDetail:UIButton!
        
        @IBOutlet weak var lblBusinesslifeDescription:UILabel!
        @IBOutlet weak var imgBusinessLife:UIImageView!
        @IBOutlet weak var btnSetupBusinessLife:UIButton!
        @IBOutlet weak var videoPrevie:PlayerView!
        
    @IBOutlet weak var btnViewAllPromotion:UIButton!
    @IBOutlet weak var btnViewAllBusinessLife:UIButton!
    
     @IBOutlet weak var lblNoBusinessReview:UILabel!
    @IBOutlet weak var viewNoBusinessLife:UIView!
    
    @IBOutlet weak var lblNoPromotion:UILabel!
    
    @IBOutlet weak var viewPromotion:UIView!
    
    @IBOutlet weak var stackViewAllPromotion:UIStackView! // hide show based on API response

    var isMoreHeight:CGFloat = 520.0
    
        var isMore:Bool = false
        var isMoreBusinessDetail:Bool{
            get{
                return isMore
            }
            set{
                isMore = newValue
                //Configure IsMore
                self.configureIsMore()
                
            }
        }
        var providerID:String = ""
        var currentProviderDetail:ProviderDetail?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.setUp()
            
            if let _ = self.imgArrowDown{
                     self.imgArrowDown.image = self.imgArrowDown.image?.withRenderingMode(.alwaysTemplate)
                     self.imgArrowDown.tintColor = UIColor.init(hex: "38B5A3")
                 }

            if let _ = self.imgEmail{
                         self.imgEmail.image = self.imgEmail.image?.withRenderingMode(.alwaysTemplate)
                         self.imgEmail.tintColor = UIColor.init(hex: "555555")
                     }
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            self.imgBusinessLogo.isUserInteractionEnabled = true
            self.imgBusinessLogo.addGestureRecognizer(tapGestureRecognizer)

        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isMoreBusinessDetail = false
        self.configureIsMore()
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                                             return
                   }
        if let  objBusinessdetail = currentUser.businessDetail{
                 self.callGETProviderDetailAPIRequest(providerID: objBusinessdetail.id)
             }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.firstShadowView.rounding = 15.0
        self.firstShadowView.layer.cornerRadius = 15.0
        self.firstShadowView.layoutIfNeeded()
        
        self.secondShadowView.rounding = 15.0
        self.secondShadowView.layer.cornerRadius = 15.0
        self.secondShadowView.layoutIfNeeded()
        
        self.thirdShadowView.rounding = 15.0
        self.thirdShadowView.layer.cornerRadius = 15.0
        self.thirdShadowView.layoutIfNeeded()
        
        self.imgBusinessLogo.clipsToBounds = true
        self.imgBusinessLogo.contentMode = .scaleAspectFill
       
        self.imgBusinessLife.clipsToBounds = true
        self.imgBusinessLife.contentMode = .scaleAspectFill
        
     
    }
        func sizeHeaderFit(){
            if let headerView =  self.tableViewProvider.tableHeaderView {
                headerView.setNeedsLayout()
                headerView.layoutIfNeeded()
                print(headerView.frame)
                print(headerView.bounds)
                
                let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
                var frame = headerView.frame
                frame.size.height = height
                headerView.frame = frame
                self.tableViewProvider.tableHeaderView = headerView
                self.view.layoutIfNeeded()
            }
        }
        // MARK: - Selector Methods
        @IBAction func buttonMoreSelector(sender:UIButton){
            self.isMoreBusinessDetail = !self.isMoreBusinessDetail
        }
    @IBAction func buttonBusinessLifeDetailSelector(sender:UIButton){
        if let provider = self.currentProviderDetail{
            if let arraybusinessLife = provider.businessLife as? [[String:Any]],arraybusinessLife.count > 0{
                if arraybusinessLife[0].count > 0{
                    let objbusinesslife = BusinessLife.init(businessLifeDetail: arraybusinessLife[0])
                    self.pushtobusinesslifedetailView(businesslife: objbusinesslife,providerImage: provider.businessLogo)
                }
            }
           
        }
    }
    func pushtobusinesslifedetailView(businesslife:BusinessLife,providerImage:String){
        if let businesslifedetail = self.storyboard?.instantiateViewController(withIdentifier:"BusinessLifeDetailViewController") as? BusinessLifeDetailViewController{
            businesslifedetail.currentBusinessLife = businesslife
            businesslifedetail.providerProfileURL = providerImage
            
            self.navigationController?.pushViewController(businesslifedetail, animated: true)
        }
    }
        @IBAction func buttonProviderReviewSelector(sender:UIButton){
            self.pushToCustomerReviewScreen()
        }
    func pushToCustomerReviewScreen(){
        if let objCustomerReviewController = UIStoryboard.profile.instantiateViewController(withIdentifier: "CustomerReviewViewController") as? CustomerReviewViewController{
            self.navigationController?.pushViewController(objCustomerReviewController, animated: true)
        }
    }
        // MARK: - User Methods
        func setUp(){
            DispatchQueue.main.async {
                self.isMoreBusinessDetail = false
                self.imgProviderProfile.clipsToBounds = true
                self.imgProviderProfile.layer.cornerRadius = 12.5
                
                self.firstContainerView.clipsToBounds = true
                self.firstContainerView.layer.cornerRadius = 15.0
                
                
                self.secondContainerView.clipsToBounds = true
                self.secondContainerView.layer.cornerRadius = 15.0
                
                
                self.thirdContainerView.clipsToBounds = true
                self.thirdContainerView.layer.cornerRadius = 15.0
               
                
                let underlineAttriString = NSAttributedString(string: "On File",
                                                               attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
                self.btnBusinessLicenceView.titleLabel?.attributedText = underlineAttriString
                self.btnBusinessDriverLicenceView.titleLabel?.attributedText = underlineAttriString
                self.btnBusinessInsuranceView.titleLabel?.attributedText = underlineAttriString
                
                let underlineGetDirection = NSAttributedString(string: "Get Direction",
                                                                          attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
                self.btnDirection.titleLabel?.attributedText = underlineGetDirection
                
                let underlineSeeDetail = NSAttributedString(string: "See Details",
                                                                          attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
                self.btnPromotionDetail.titleLabel?.attributedText = underlineSeeDetail
                
                let underlinePromotional = NSAttributedString(string: "Add Promotion",attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
                self.btnPromotionalSetup.titleLabel?.attributedText = underlinePromotional
                
                let underlineSetupBusinessLife = NSAttributedString(string: "Add a Post",attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                self.btnSetupBusinessLife.titleLabel?.attributedText = underlineSetupBusinessLife

                let underlineViewAllBusinessLife = NSAttributedString(string: "View All",attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                self.btnViewAllBusinessLife.titleLabel?.attributedText = underlineViewAllBusinessLife
                self.btnViewAllPromotion.titleLabel?.attributedText = underlineViewAllBusinessLife
                
                
            }
        }
        func configureIsMore(){
            if self.isMoreBusinessDetail{
                self.imgArrowDown.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))

                UIView.animate(withDuration: 0.3) {
                    self.firstViewMoreContainer.isHidden = false
                    self.firstViewHeight.constant = self.isMoreHeight
                    self.view.layoutIfNeeded()
                    self.view.layoutSubviews()
                }
            }else{
                self.imgArrowDown.transform = CGAffineTransform(rotationAngle: 0);

                UIView.animate(withDuration: 0.3) {
                    self.firstViewMoreContainer.isHidden = true
                    self.firstViewHeight.constant = 175.0
                   self.view.layoutIfNeeded()
                   self.view.layoutSubviews()
                }
            }
            UIView.animate(withDuration: 0.7) {
                DispatchQueue.main.async {
                    self.sizeHeaderFit()
                }
                
            }
            
        }
        func configureCurrentProviderDetail(providerDetail:ProviderDetail){
            
            self.currentProviderDetail = providerDetail
            
            
            
            
             if let imgURL = URL.init(string:  providerDetail.businessLogo){
                                self.imgBusinessLogo.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
             }
            DispatchQueue.main.async {
                self.lblNoPromotion.text = "\(providerDetail.promotionSectionText)"
                self.stackViewAllPromotion.isHidden = !providerDetail.isViewAllButtonShow
                self.lblBusinessTitle.text = providerDetail.businessName
                
                if let firstName = providerDetail.userDetail?.firstname,let  lastName = providerDetail.userDetail?.lastname{
                    self.providerName.text = "\(firstName) \(lastName)"
                }
                if let countrycode = providerDetail.userDetail?.countryCode,let  phone = providerDetail.phone as? String{
                    self.providerPhoneNumber.text = " \(phone)".applyPatternOnNumbers(pattern: "###-###-####", replacmentCharacter: "#")//"\(countrycode) \(phone)"
               }
                if let profileImage = providerDetail.userDetail?.profilePic,let imgURL = URL.init(string: "\(profileImage)"){
                    self.imgProviderProfile.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                }
                self.lblBusinessName.text = providerDetail.businessName
                self.lblBusinessEmail.text = providerDetail.email
                
                if let objRating = Double(providerDetail.rating){
                    self.ratingView.rating = objRating
                }
                self.lblBusinessReview.text = "(\(providerDetail.review) Review)"
                
                print(self.isMoreHeight)
                if providerDetail.insurance.count > 0{
                    self.businessInsuranceContainer.isHidden = false
                    self.heightOfInsuranceContainer.constant = 30.0
                }else{
                    self.businessInsuranceContainer.isHidden = true
                    self.heightOfInsuranceContainer.constant = 0.0
                }
                
                if providerDetail.businessLicense.count > 0{
                    self.businessLicenceContainer.isHidden = false
                    self.heightOfbusinessLicenceContainer.constant = 35.0
                }else{
                    self.businessLicenceContainer.isHidden = true
                    self.heightOfbusinessLicenceContainer.constant = 0.0
                }
                if providerDetail.driverLicense.count > 0{
                   self.driverLicenceContainer.isHidden = false
                   self.heightOfdriverLicenceContainer.constant = 35.0
                }else{
                   self.driverLicenceContainer.isHidden = true
                   self.heightOfdriverLicenceContainer.constant = 0.0
                }
                let strKeyword = "\(providerDetail.keywordsForBusiness)"
                self.lblBusinessKeywords.text = "\(strKeyword)"
                self.lblBusinessKeywords.numberOfLines = 0
                var heightOfLable =  "\(strKeyword)".height(withConstrainedWidth: UIScreen.main.bounds.width-35.0, font: UIFont.systemFont(ofSize: 19.0))
                
                //var heightOfLable = self.lblBusinessKeywords.estimatedHeight(forWidth: UIScreen.main.bounds.width-35.0, text:"\(strKeyword)" , ofSize: 17.0)
                
                if self.lblBusinessKeywords.isTruncated{
                  //  heightOfLable += 10.0
                }
                if providerDetail.businessLicense.count > 0  && providerDetail.driverLicense.count > 0{
                    self.isMoreHeight = 520.0 + heightOfLable
                }else{
                    if providerDetail.businessLicense.count > 0  || providerDetail.driverLicense.count > 0{
                        self.isMoreHeight = 485.0 + heightOfLable
                    }else{
                        self.isMoreHeight = 450.0 + heightOfLable
                    }
                }
                self.isMoreHeight += 30
                self.configureIsMore()
                
                self.lblBusinessAddress.text = "\(providerDetail.address) \(providerDetail.city) \(providerDetail.state) \(providerDetail.zipcode)"
                self.lblBusinessDescription.text = "\(providerDetail.providerDetailDescription)"
                self.lblBusinessInsurance.text = "\(providerDetail.insurance)"
                self.lblBusinessEIN.text = "\(providerDetail.ein)"

                self.lblHomeLongWillingToTravel.text = "\(providerDetail.howLongWillingToTravel)"
                
                
                
                if let arraypromotions = providerDetail.promotions as? [[String:Any]],arraypromotions.count > 0{
                     let firstPromotion:[String:Any] = arraypromotions[0]
                    
                       if let name = firstPromotion["name"]{
                            self.lblPromotionTitle.text = "\(name)"
                            //self.lblPromotionDetail.text = "\(name)"

                        }
                            if let amount = firstPromotion["saving_price"]{
                                self.lblPromotionDetail.text = "\(amount)% off your total bill"
                                if let promotionType = firstPromotion["type"]{
                                    if "\(promotionType)" == "percentage"{
                                        self.lblPromotionDetail.text = "\(amount)% off your total bill"
                                    }else{
                                        self.lblPromotionDetail.text = "\((CurrencyFormate.Currency(value: amount as! Double))) off your total bill"
                                    }
                                }
                            }
                        if let description = firstPromotion["description"]{
                            

                        }
                    
                    self.btnPromotionDetail.isHidden  = false
                    self.viewPromotion.isHidden = false
                    self.lblNoPromotion.isHidden = true
                }else{
                    self.btnPromotionDetail.isHidden  = true
                    self.viewPromotion.isHidden = true
                    self.lblNoPromotion.isHidden = false
                }
                
                if let arraybusinessLife = providerDetail.businessLife as? [[String:Any]],arraybusinessLife.count > 0{
                     let firstbusinessLife:[String:Any] = arraybusinessLife[0]
                        if let filetype = firstbusinessLife["file_type"]{
                            if "\(filetype)" == "image" || "\(filetype)" == "IMAGE"{
                                self.videoPrevie.isHidden = true
                                if let objImage = firstbusinessLife["file"]{
                                      if let imgURL = URL.init(string: "\(objImage)"){
                                          self.imgBusinessLife.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                                      }
                                 }
                            }else if "\(filetype)" == "video" || "\(filetype)" == "VIDEO"{
                                self.videoPrevie.isHidden = false
                                if let objImage = firstbusinessLife["video_thumbnail_url"]{
                                    if let imgURL = URL.init(string: "\(objImage)"){
                                         self.imgBusinessLife.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                                    }
                                        /*
                                            DispatchQueue.global(qos: .background).async {
                                                   if let imgURL = self.getThumbnailImage(forUrl: videoURL){
                                                     DispatchQueue.main.async {
                                                          self.imgBusinessLife.image = imgURL
                                                     }
                                                   }
                                               }
                                   */
                                }
                            }
                        }
                     
                        if let description = firstbusinessLife["description"]{
                            self.lblBusinesslifeDescription.text = "\(description)"

                        }
                    self.btnViewAllBusinessLife.isHidden = false
                    self.viewNoBusinessLife.isHidden = true
                    self.lblNoBusinessReview.isHidden = true
                }else{
                    self.btnViewAllBusinessLife.isHidden = true
                    self.viewNoBusinessLife.isHidden = false
                    self.lblNoBusinessReview.isHidden = false
                }
                
            }
            
        }
        func getThumbnailImage(forUrl url: URL) -> UIImage? {
            let asset: AVAsset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)

            do {
                let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
                return UIImage(cgImage: thumbnailImage)
            } catch let error {
                print(error)
            }

            return nil
        }
        // MARK: - API Request Methods
        func callGETProviderDetailAPIRequest(providerID:String){
             let dict:[String:Any] = [
                        "provider_id" : "\(providerID)",
                    ]
            
                    APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGETProviderDetail , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                        
                        if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                                    let objProviderDetail = ProviderDetail.init(providerDetail: userInfo)
                                    print(objProviderDetail.email)
                                    self.configureCurrentProviderDetail(providerDetail: objProviderDetail)
                                   }else{
                                       DispatchQueue.main.async {
                                           SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                       }
                                   }
                               }) { (responseFail) in
                                if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String]{
                                    DispatchQueue.main.async {
                                        if errorMessage.count > 0{
                                            SAAlertBar.show(.error, message:"\(errorMessage.first!)".localizedLowercase)
                                        }
                                    }
                                }else{
                                       DispatchQueue.main.async {
                                           SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                       }
                                   }
                               }
        }
        // MARK: - Selector Methods
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        if let _ = self.imgBusinessLogo.image{
                if let objProfile = self.storyboard?.instantiateViewController(withIdentifier: "ProviderUserProfile") as? ProviderUserProfile{
                    objProfile.modalPresentationStyle = .overFullScreen
                    objProfile.profileStr = self.imgBusinessLogo.image
                    self.present(objProfile, animated: true, completion: nil)
                }
            }
    }
    @IBAction func buttonPushtoFollowingScreen(sender:UIButton){
        if let followingViewController = UIStoryboard.businessFeed.instantiateViewController(identifier: "FollowingBusinessLifeViewController") as? FollowingBusinessLifeViewController{
            followingViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController( followingViewController, animated: true)
        }
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonEditProviderProfileSelector(sender:UIButton){
        self.pushToEditProviderProfileViewController()
    }
    @IBAction func buttonViewInsuranceSelector(sender:UIButton){
        if let _ = self.currentProviderDetail{
            if let imgURL = URL.init(string: "\(self.currentProviderDetail!.insurance)"){
                
                UIApplication.shared.open(imgURL, options: [:], completionHandler: nil)
            }
             
            
        }
    }
        @IBAction func buttonViewBussinessLicenceSelector(sender:UIButton){
            if let _ = self.currentProviderDetail{
                if let imgURL = URL.init(string: "\(self.currentProviderDetail!.businessLicense)"){
                    
                    UIApplication.shared.open(imgURL, options: [:], completionHandler: nil)
                }
                 
                
            }
        }
        @IBAction func buttonViewBussinessDriverLicenceSelector(sender:UIButton){
            if let _ = self.currentProviderDetail{
                if let _ = self.currentProviderDetail{
                    if let imgURL = URL.init(string: "\(self.currentProviderDetail!.driverLicense)"){
                        
                        UIApplication.shared.open(imgURL, options: [:], completionHandler: nil)
                    }
                }
                
            }
        }
        @IBAction func buttonGetDirectionSelector(sender:UIButton){
            if let _ = self.currentProviderDetail{
                
            }
        }
    @IBAction func buttonPromotionalSetupSelector(sender:UIButton){
        self.pushToAddPromotionViewController()
    }
    @IBAction func buttonPromotionMoreListSelector(sender:UIButton){
           self.pushToListOfPromotionsController()
       }
    
        @IBAction func buttonPromotionalSeeDetailSelector(sender:UIButton){
            if let _ = self.currentProviderDetail{
                if let objStory = self.storyboard?.instantiateViewController(withIdentifier: "PromotionAlertViewController") as? PromotionAlertViewController{
                    objStory.modalPresentationStyle = .overFullScreen
                    if let _ = self.currentProviderDetail!.objPromotion{
                        objStory.objPromotion = self.currentProviderDetail!.objPromotion!
                    }
                    self.present(objStory, animated: true, completion: nil)
                }
            }
           }
        @IBAction func buttonShareSelector(sender:UIButton){
            
        }
        @IBAction func buttonfileDisputeselector(sender:UIButton){
            self.pushToFileReportViewController()
        }
        @IBAction func buttonMoreBusinessLifeSelector(sender:UIButton){
            if let _ = self.currentProviderDetail{
                if let arraybusinessLife = self.currentProviderDetail!.businessLife as? [[String:Any]],arraybusinessLife.count > 0{
                    self.pushtoListofBusinessLifeController()
                }
            }
        }
        func pushtoListofBusinessLifeController(){
            if let currentProvider = self.currentProviderDetail,let currentProviderUserDetail = currentProvider.userDetail{
                if let objBusinessLifeListViewController:BusinessLifeListViewController = self.storyboard?.instantiateViewController(withIdentifier: "BusinessLifeListViewController") as? BusinessLifeListViewController{
                    objBusinessLifeListViewController.providerId = "\(currentProvider.id)"
                    objBusinessLifeListViewController.providerProfileURL = "\(currentProvider.businessLogo)"
                    objBusinessLifeListViewController.isForProvider = true
                  self.navigationController?.pushViewController(objBusinessLifeListViewController, animated: true)
                  
                }
            }
        }
        @IBAction func buttonPlayBusinessLifeVideo(sender:UIButton){
            if let _ = self.currentProviderDetail{
                if let arraybusinessLife = self.currentProviderDetail!.businessLife as? [[String:Any]],arraybusinessLife.count > 0{
                     let firstbusinessLife:[String:Any] = arraybusinessLife[0]
                        if let filetype = firstbusinessLife["file_type"]{
                            if "\(filetype)" == "image"{
                               
                            }else{
                                if let objImage = firstbusinessLife["file"]{
                                         if let videoURL = URL.init(string: "\(objImage)"){
                                        if let videoViewController:videoPlayVC = self.storyboard?.instantiateViewController(withIdentifier: "videoPlayVC") as? videoPlayVC{
                                          videoViewController.hidesBottomBarWhenPushed = true
                                          videoViewController.strMediaUrl = videoURL.absoluteString
                                          self.navigationController?.present(videoViewController, animated: true, completion: nil)
                                          
                                        }
                                    }
                                }
                            }
                        }
                    
                }
                
                
                
               
            }
        }
    @IBAction func buttonAddBusinessLife(sender:UIButton){
        self.pushToAddBusinessLifeViewController()
    }
        // MARK: - Navigation
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
        }
    func pushToAddPromotionViewController(){
        if let objAddPromotionViewController:AddPromotionViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddPromotionViewController") as? AddPromotionViewController{
                        self.navigationController?.pushViewController(objAddPromotionViewController, animated: true)
                      }
    }
    func pushToAddBusinessLifeViewController(){
        if let objAddBusinessListViewController:AddBusinessListViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddBusinessListViewController") as? AddBusinessListViewController{
                               self.navigationController?.pushViewController(objAddBusinessListViewController, animated: true)
                             }
    }
    func pushToFileReportViewController(){
        let profileStroyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        if let reportBugViewController = profileStroyboard.instantiateViewController(withIdentifier: "ReportBugViewController") as? ReportBugViewController{
            if let currentProvider = self.currentProviderDetail,let currentProviderUserDetail = currentProvider.userDetail{
                reportBugViewController.providerId = "\(currentProviderUserDetail.id)"
            }
            self.navigationController?.pushViewController(reportBugViewController, animated: true)
        }
    }
    func pushToEditProviderProfileViewController(){
        let profileStroyboard = UIStoryboard.init(name: "Profile", bundle: nil)
               if let reportBugViewController = profileStroyboard.instantiateViewController(withIdentifier: "UpdateBusinessProfile") as? UpdateBusinessProfile{
                   if let currentProvider = self.currentProviderDetail,let currentProviderUserDetail = currentProvider.userDetail{
                       reportBugViewController.providerDetail = currentProvider
                   }
                   self.navigationController?.pushViewController(reportBugViewController, animated: true)
               }
    }

    func pushToListOfPromotionsController(){
          if let currentProvider = self.currentProviderDetail,let currentProviderUserDetail = currentProvider.userDetail{
              if let objPromotionListViewController:PromotionListViewController = self.storyboard?.instantiateViewController(withIdentifier: "PromotionListViewController") as? PromotionListViewController{
                  objPromotionListViewController.providerId = "\(currentProvider.id)"
                  objPromotionListViewController.isForProviderSide = true
                self.navigationController?.pushViewController(objPromotionListViewController, animated: true)
                
              }
          }
      }
    }
