//
//  ProviderDetailViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 29/01/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import FloatRatingView
import AVFoundation
import FirebaseDynamicLinks
import CoreLocation

class ProviderDetailViewController: UIViewController {

    
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
    
    
    @IBOutlet weak var lblEIN:UILabel!
    @IBOutlet weak var lblBusinessLicenseVerified:UILabel!
    @IBOutlet weak var lblDriverLicenseVerified:UILabel!
    
    
    
    @IBOutlet weak var lblHomeLongWillingToTravel:UILabel!
    @IBOutlet weak var btnDirection:UIButton!
    @IBOutlet weak var lblPromotionTitle:UILabel!
    @IBOutlet weak var lblPromotionDetail:UILabel!
    @IBOutlet weak var btnPromotionDetail:UIButton!
    
    @IBOutlet weak var lblBusinesslifeDescription:UILabel!
    @IBOutlet weak var imgBusinessLife:UIImageView!

    @IBOutlet weak var buttonViewAllBusinessLife:UIButton!
    @IBOutlet weak var lblNoBusinessReview:UILabel!
    @IBOutlet weak var videoPrevie:PlayerView!
    
    @IBOutlet weak var viewPromotion:UIView!
    @IBOutlet weak var buttonmorePromotion:UIButton!
    
    @IBOutlet weak var buttonBookNowWidth:NSLayoutConstraint!
    
    @IBOutlet weak var buttonFlag:UIButton!
    @IBOutlet weak var viewContact:UIView!

    @IBOutlet weak var lblKeywords:UILabel!

    var arrayOfProvidersNotified:[NotifiedProviderOffer] = []
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    //var offerJOBID:String = "" // if existing then show book now otherwise hide
    
    var dictJOBBooking:[String:Any] = [:]
    
    var currentProvider:NotifiedProviderOffer?
    
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
    
    var isFromDynamicLink:Bool = false
    
    var isFromSearchPersonCompany:Bool = true
    
    @IBOutlet weak var viewBookNow:UIView!

    var showBookNowButton:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
        self.imgBusinessLogo.clipsToBounds = true
        self.imgBusinessLogo.contentMode = .scaleAspectFill
        
        self.imgBusiness.clipsToBounds = true
        self.imgBusiness.contentMode = .scaleAspectFill
        
        self.imgBusinessLife.clipsToBounds = true
               self.imgBusinessLife.contentMode = .scaleAspectFill
        
        // Do any additional setup after loading the view.
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.providerID.count > 0{
            self.callGETProviderDetailAPIRequest(providerID: self.providerID)
        }
        self.firstShadowView.rounding = 15.0
        self.firstShadowView.layer.cornerRadius = 15.0
        self.firstShadowView.layoutIfNeeded()
        
        self.secondShadowView.rounding = 15.0
        self.secondShadowView.layer.cornerRadius = 15.0
        self.secondShadowView.layoutIfNeeded()
        
        self.thirdShadowView.rounding = 15.0
        self.thirdShadowView.layer.cornerRadius = 15.0
        self.thirdShadowView.layoutIfNeeded()
        
        DispatchQueue.main.async {
            /*
            if self.isFromSearchPersonCompany || self.isFromDynamicLink{
                guard let currentUser = UserDetail.getUserFromUserDefault() else {
                        return
                }
                
                let currentproviderId = currentUser.businessDetail?.id ?? ""
                
                if currentUser.userRoleType == .customer && currentproviderId != self.providerID{
                    self.buttonBookNowWidth.constant = 140.0
                }else{
                    self.buttonBookNowWidth.constant = 0
                }
            }else{
                if self.dictJOBBooking.count > 0{
                    self.buttonBookNowWidth.constant = 140.0
                }else{
                    self.buttonBookNowWidth.constant = 0
                }
            }*/
        }
        
    }
    
    func hideBottomContactBookNowAndFlag(){
        
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                              return
                          
                      }

        if let providerdetail = self.currentProviderDetail{
            if let useriD = providerdetail.userDetail?.id{
                if "\(useriD)" == currentUser.id{
                    DispatchQueue.main.async {
                        self.buttonBookNowWidth.constant = 0
//                        self.viewBookNow.isHidden = true
                        self.viewContact.isHidden = true
                        self.buttonFlag.isHidden = true
                        self.btnDirection.isHidden = true
                    }
                }else{
                    DispatchQueue.main.async {
                        if currentUser.userRoleType == .provider{
                            self.buttonBookNowWidth.constant = 140.0
//                            self.viewBookNow.isHidden = true
                        }else{
                            self.buttonBookNowWidth.constant = self.showBookNowButton ? 140 : 0
//                            self.viewBookNow.isHidden = false //!self.showBookNowButton//providerdetail.isBookNowButtonShow ? false : true
                        }

                        self.viewContact.isHidden = providerdetail.isContactButtonShow ? false : true
                        self.buttonFlag.isHidden = providerdetail.isReportFlagShow ? false : true
                        self.btnDirection.isHidden = providerdetail.isGetDirectionLinkShow ? false : true
                        
                    }
                }
            }

        }
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
    // MARK: - User Methods
    func setUp(){
        UserDefaults.standard.removeObject(forKey: "ProviderId")
        DispatchQueue.main.async {
            self.isMoreBusinessDetail = false
            self.imgProviderProfile.clipsToBounds = true
            self.imgProviderProfile.layer.cornerRadius = 12.5
            
            
            self.firstContainerView.clipsToBounds = true
            self.firstContainerView.layer.cornerRadius = 15.0
            
            self.secondContainerView.clipsToBounds = true
            self.secondContainerView.layer.cornerRadius = 15.0
//            self.secondShadowView.layer.cornerRadius = 15.0
            
            self.thirdContainerView.clipsToBounds = true
            self.thirdContainerView.layer.cornerRadius = 15.0
//            self.thirdShadowView.layer.cornerRadius = 15.0
            
            
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
            
            let underlineViewAll = NSAttributedString(string: "View All",
                                                                              attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
            
            self.buttonViewAllBusinessLife.titleLabel?.attributedText = underlineViewAll
        }
    }
    func configureIsMore(){
        if self.isMoreBusinessDetail{
            UIView.animate(withDuration: 0.3) {
                self.firstViewMoreContainer.isHidden = false
                self.firstViewHeight.constant = self.isMoreHeight
                self.view.layoutIfNeeded()
                self.view.layoutSubviews()
            }
            self.imgArrowDown.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        }else{
            UIView.animate(withDuration: 0.3) {
                self.firstViewMoreContainer.isHidden = true
               self.firstViewHeight.constant = 175.0
               self.view.layoutIfNeeded()
               self.view.layoutSubviews()
            }
            self.imgArrowDown.transform = CGAffineTransform(rotationAngle: 0);
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
            self.lblBusinessTitle.text = providerDetail.businessName
            
            if let firstName = providerDetail.userDetail?.firstname,let  lastName = providerDetail.userDetail?.lastname{
                self.providerName.text = "\(firstName) \(lastName)"
            }
            if let countrycode = providerDetail.userDetail?.countryCode,let  phone = providerDetail.phone as? String{
                self.providerPhoneNumber.text = " \(phone)".applyPatternOnNumbers(pattern: "###-###-####", replacmentCharacter: "#")
                //"\(countrycode) \(phone)"
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
            if providerDetail.ein.count > 0{
                self.lblEIN.text = "Verified"
            }else{
                self.lblEIN.text = "Not Verified"
            }
            if providerDetail.insurance.count > 0{
                self.lblBusinessInsurance.text = "Verified"
            }else{
                self.lblBusinessInsurance.text = "Not Verified"
            }
            if providerDetail.businessLicense.count > 0{
                self.lblBusinessLicenseVerified.text = "Verified"
            }else{
                self.lblBusinessLicenseVerified.text = "Not Verified"
            }
            if providerDetail.driverLicense.count > 0{
                self.lblDriverLicenseVerified.text = "Verified"
            }else{
                self.lblDriverLicenseVerified.text = "Not Verified"
            }
            self.lblKeywords.textAlignment = .left
            let strKeyword = "\(providerDetail.keywordsForBusiness)"

            self.lblKeywords.text = strKeyword
            self.lblKeywords.numberOfLines = 0

            let heightOfLable =  strKeyword.height(withConstrainedWidth: UIScreen.main.bounds.width-40.0, font: UIFont.systemFont(ofSize: 17.0))
            

            if providerDetail.businessLicense.count > 0  && providerDetail.driverLicense.count > 0{
                self.isMoreHeight = 520.0 + heightOfLable
            }else{
                if providerDetail.businessLicense.count > 0  || providerDetail.driverLicense.count > 0{
                    self.isMoreHeight = 485.0 + heightOfLable
                }else{
                    self.isMoreHeight = 450.0 + heightOfLable
                }
            }
            self.isMoreHeight += 30.0
            self.configureIsMore()

            self.lblBusinessAddress.text = "\(providerDetail.address) \(providerDetail.city) \(providerDetail.state) \(providerDetail.zipcode)"
            self.lblBusinessDescription.text = "\(providerDetail.providerDetailDescription)"
//            self.lblBusinessInsurance.text = "\(providerDetail.insurance)"
            //self.lblEIN.text = "Confirmed"//"\(providerDetail.ein)"
            self.lblHomeLongWillingToTravel.text = "\(providerDetail.howLongWillingToTravel)"
            
            if let arraypromotions = providerDetail.promotions as? [[String:Any]],arraypromotions.count > 0{
                 let firstPromotion:[String:Any] = arraypromotions[0]
                   if let name = firstPromotion["name"]{
                        self.lblPromotionTitle.text = "\(name)"
                    }
                    if let amount = firstPromotion["saving_price"]{
                    self.lblPromotionDetail.text = "\(amount)% off your total bill"
                         if let promotionType = firstPromotion["type"]{
                             if "\(promotionType)" == "percentage"{
                                 self.lblPromotionDetail.text = "\(amount)% off your total bill"
                             }else{
                                self.lblPromotionDetail.text = "\(CurrencyFormate.Currency(value: amount as! Double)) off your total bill"
                             }
                         }
                     }
                /*if let description = firstPromotion["description"]{
                        self.lblPromotionDetail.text = "\(description)"

                    }*/
                
                self.btnPromotionDetail.isHidden  = false
                self.viewPromotion.isHidden = false
                self.buttonmorePromotion.isHidden = true //false
            }else{
                self.btnPromotionDetail.isHidden  = true
                self.viewPromotion.isHidden = true
                self.buttonmorePromotion.isHidden = true
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
                                     if let videoURL = URL.init(string: "\(objImage)"){
                                         self.imgBusinessLife.sd_setImage(with: videoURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                                        /*
                                        DispatchQueue.global(qos: .background).async {
                                               if let imgURL = self.getThumbnailImage(forUrl: videoURL){
                                                 DispatchQueue.main.async {
                                                      self.imgBusinessLife.image = imgURL
                                                 }
                                               }
                                           } */
                                }
                            }
                        }
                    }
                 
                    if let description = firstbusinessLife["description"]{
                        self.lblBusinesslifeDescription.text = "\(description)"

                    }
                self.buttonViewAllBusinessLife.isHidden = false
                self.lblNoBusinessReview.isHidden = true
            }else{
                self.buttonViewAllBusinessLife.isHidden = true
                self.lblNoBusinessReview.isHidden = false
            }
            
        }
        self.hideBottomContactBookNowAndFlag()
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
                                      // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
                                     //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                   }
                               }
                           }
    }
    //CALL book job api
    func callbookjobapireqest(dict:[String:Any]){
         
     
         
             APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kBookJOB , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                     
                     if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [String:Any]{
                            DispatchQueue.main.async {
                                         if let objTabView = self.navigationController?.tabBarController{
                                             print(objTabView.viewControllers)
                                             if let objHomeNavigation:UINavigationController = objTabView.viewControllers?[1] as? UINavigationController{
                                                 if let objMyPost:MessagesVC = objHomeNavigation.viewControllers.first as? MessagesVC{
                                                     objTabView.selectedIndex = 1
                                                     //objMyPost.isFromHomeBooking = true
                                                    objMyPost.selectedIndexFromNotification = 1
                                                 }
                                             }
                                            self.navigationController?.popViewController(animated: false)

                                          }
                                     }
                                }else{
                                    DispatchQueue.main.async {
                                       // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
                                      //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
    @IBAction func buttonCallSelector(sender:UIButton){
        if let providerDetail = self.currentProviderDetail{
            if let countrycode = providerDetail.userDetail?.countryCode,let  phone = providerDetail.phone as? String{
                if let url = URL(string: "tel://\(phone)") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                 }
            }

        }


    }
    @IBAction func buttonBackSelector(sender:UIButton){
        if self.isFromDynamicLink{
                  if let objTabView = self.navigationController?.tabBarController{
                                    if let objHomeNavigation = objTabView.viewControllers?.first as? UINavigationController,let objHome = objHomeNavigation.viewControllers.first as? HomeVC{
                                      objHome.arrayOfProvidersNotified = self.arrayOfProvidersNotified
                                    }
                         }
                  let storyboard = UIStoryboard(name: "Main", bundle: nil)
                  let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                  let navigationController = UINavigationController(rootViewController:VC)
                  // Make the Tab Bar Controller the root view controller
                  //connect()
            if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first{
                window.rootViewController? = navigationController
                window.makeKeyAndVisible()
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
      
    }
    func showUserAccountSwitchAlertOnProviderBooking(){
        let strSwitch = "You need to be in Customer view to book a Provider. Would you like to switch?"

        UIAlertController.showAlertWithYesNoButton(self, aStrMessage: "\(strSwitch)") { objint, strString in
            if objint == 0{
                self.apiReuestToSwitchUserRoleAndBookProviderAtIndex()
            }
        }


    }
    func apiReuestToSwitchUserRoleAndBookProviderAtIndex(){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                   return
        }
        var dict:[String:Any]  = [:]
        if currentUser.userRoleType == .customer{
            dict["role"] = "provider"
        }else if currentUser.userRoleType == .provider{
          dict["role"] = "customer"
        }

        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSwitchAccount , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                        if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"]{
                            if currentUser.userRoleType == .customer{
                              currentUser.userRoleType = .provider
                            }else if currentUser.userRoleType == .provider{
                              currentUser.userRoleType = .customer
                            }
                            currentUser.setuserDetailToUserDefault()
                            DispatchQueue.main.async {
                                self.pushToCustomerOrProviderHomeViewController()
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                                    self.locationManager.requestWhenInUseAuthorization()

                                    if self.locationManager.authorizationStatus == .authorizedAlways || self.locationManager.authorizationStatus == .authorizedWhenInUse{
                                    guard let currentLocation = self.locationManager.location else {
                                      return
                                    }
                                    var requestParameters:[String:Any] = [:]
                                    requestParameters["provider_id"] = self.providerID
                                        if let provider = self.currentProviderDetail{
                                            if let user = provider.userDetail{
                                                requestParameters["name"] = "\(user.firstname) \(user.lastname)"
                                            }
                                        }
                                    requestParameters["lat"] = "\(currentLocation.coordinate.latitude)"
                                    requestParameters["lng"] = "\(currentLocation.coordinate.longitude)"
                                    NotificationCenter.default.post(name: .providerBookJOB, object: nil,userInfo: requestParameters)
                                    }
                                }
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
                                     //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                 }
                             }
                         }
    }
    func pushToCustomerOrProviderHomeViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let navigationController = UINavigationController(rootViewController:VC)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }
    func directBookProviderWithRequestParameters(){
        self.locationManager.requestWhenInUseAuthorization()

        if self.locationManager.authorizationStatus == .authorizedAlways || self.locationManager.authorizationStatus == .authorizedWhenInUse{
        guard let currentLocation = self.locationManager.location else {
          return
        }
        var requestParameters:[String:Any] = [:]
        requestParameters["provider_id"] = self.providerID
        requestParameters["lat"] = "\(currentLocation.coordinate.latitude)"
        requestParameters["lng"] = "\(currentLocation.coordinate.longitude)"
        self.apiRequestValidationForDirectBookProvider(requestParameters: requestParameters)
        }
    }
    @IBAction func buttonBookNowSelector(sender:UIButton){

        guard let currentUser = UserDetail.getUserFromUserDefault(), currentUser.userRoleType == .customer else {
            //Current UserRole is provider switch to customer role to direct book provider
            self.showUserAccountSwitchAlertOnProviderBooking()
            return
        }

        if self.isFromSearchPersonCompany || self.isFromDynamicLink{
            
            self.directBookProviderWithRequestParameters()

                /*if let PostJobVCViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "PostJobVC") as? PostJobVC{
                                       PostJobVCViewController.hidesBottomBarWhenPushed = true
                                       PostJobVCViewController.isForSingleProviderBook = true
                                        PostJobVCViewController.providerID = self.providerID
                                        if let provider = self.currentProviderDetail{
                                            if let user = provider.userDetail{
                                                PostJobVCViewController.providerName = "\(user.firstname) \(user.lastname)"
                                            }
                                        }
                                       self.navigationController?.pushViewController(PostJobVCViewController, animated: false)
                    }*/
            
   
        }else{
            if let objnotifiedProvider = self.currentProvider{
                     if let ispreoffer = objnotifiedProvider.isPreOffer.bool{
                         if ispreoffer{
                             self.presentUpdateAskingPricePopup(provider: objnotifiedProvider)
                         }else{
                             if self.dictJOBBooking.count > 0{
                                 self.callbookjobapireqest(dict: self.dictJOBBooking)
                             }
                             

                         }
                     }
                 }else if self.dictJOBBooking.count > 0{
                     self.callbookjobapireqest(dict: self.dictJOBBooking)
                 }
        }
    }
    func apiRequestValidationForDirectBookProvider(requestParameters:[String:Any]){
           
           APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kDirectBookValidation , parameter: requestParameters as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                   
                   if let success = responseSuccess as? [String:Any],let responseSuccessData = success["success_data"] as? [String:Any]{
                          DispatchQueue.main.async {
                               if let isvalid = responseSuccessData["is_direct_book"] as? Bool{
                                   if isvalid{
                                       self.pushToSingleProviderDirectBookViewController()
                                   }else{
                                       if let strMessage = responseSuccessData["message"]{
                                           self.presentDirectBookProviderValidatioAlert(strMessage: "\(strMessage)")
                                       }
                                   }
                               }
                            }
                              }else{
                                  DispatchQueue.main.async {
                                    //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
                                      //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                  }
                              }
                          }
       }
    func pushToSingleProviderDirectBookViewController(){
       if let PostJobVCViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "PostJobVC") as? PostJobVC{
                                   PostJobVCViewController.hidesBottomBarWhenPushed = true
                                   PostJobVCViewController.isForSingleProviderBook = true
                                    PostJobVCViewController.isForDirectBook = true 
                                    PostJobVCViewController.providerID = self.providerID
                                    if let provider = self.currentProviderDetail{
                                        if let user = provider.userDetail{
                                            PostJobVCViewController.providerName = "\(user.firstname) \(user.lastname)"
                                        }
                                    }
                                   self.navigationController?.pushViewController(PostJobVCViewController, animated: false)
                }
        
    }
    func presentDirectBookProviderValidatioAlert(strMessage:String){
        
        let alert = UIAlertController(title: AppName, message: "\(strMessage)", preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
             
         }))
         alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.pushToSingleProviderDirectBookViewController()
         }))
       alert.view.tintColor = UIColor.init(hex: "#38B5A3")
         self.present(alert, animated: true, completion: nil)
    }
    func presentUpdateAskingPricePopup(provider:NotifiedProviderOffer){
        if let updateAskingPrice = UIStoryboard.main.instantiateViewController(withIdentifier: "UpdateAskingPricePopupViewController") as? UpdateAskingPricePopupViewController{
            updateAskingPrice.modalPresentationStyle = .overFullScreen
            updateAskingPrice.delegate = self
            updateAskingPrice.currentProvider = provider
            self.present(updateAskingPrice, animated: true, completion: nil)
        }
    }
    @IBAction func buttonViewBussinessInsuranceSelector(sender:UIButton){
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
            let lat = self.currentProviderDetail!.lat
            let long = self.currentProviderDetail!.lng
            if let imgURL = URL.init(string: "https://maps.google.com/?q=\(lat),\(long)"){
                UIApplication.shared.open(imgURL, options: [:], completionHandler: nil)
            }
           

        }
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
    @IBAction func buttonProviderContactSelector(sender:UIButton){
        if let _ = self.currentProviderDetail{
            self.pushtoChatViewControllerWith(provider: self.currentProviderDetail!)
        }
       }
    func pushtoChatViewControllerWith(provider:ProviderDetail){
           if let chatViewConroller = UIStoryboard.messages.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC{
               chatViewConroller.hidesBottomBarWhenPushed = true
               chatViewConroller.strReceiverName = "\(provider.businessName)"
               chatViewConroller.strReceiverProfileURL = "\(provider.businessLogo)"
                chatViewConroller.receiverID = provider.userID
            if let senderId = provider.userDetail?.quickblox_id {
                chatViewConroller.senderID = "\(senderId)"
            }
            chatViewConroller.toUserTypeStr = "provider"
               chatViewConroller.isForCustomerToProvider = true
               self.navigationController?.pushViewController(chatViewConroller, animated: true)
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
              self.navigationController?.pushViewController(objBusinessLifeListViewController, animated: true)
              
            }
        }
    }
    func pushToListOfPromotionsController(){
        if let currentProvider = self.currentProviderDetail,let currentProviderUserDetail = currentProvider.userDetail{
            if let objPromotionListViewController:PromotionListViewController = self.storyboard?.instantiateViewController(withIdentifier: "PromotionListViewController") as? PromotionListViewController{
                objPromotionListViewController.providerId = "\(currentProvider.id)"
                objPromotionListViewController.isForProviderSide = false
              self.navigationController?.pushViewController(objPromotionListViewController, animated: true)
              
            }
        }
    }
    @IBAction func buttonUserReviewSelector(sender:UIButton){
        if let provider = self.currentProviderDetail,let userDetail  = provider.userDetail{
            self.pushToUserReviewAddEditViewController(userID: userDetail.id, userName: "\(provider.businessName)",userProfile: "\(provider.businessLogo)")
        }
    }
    @IBAction func buttonPlayBusinessLifeVideo(sender:UIButton){
        if let _ = self.currentProviderDetail{
            if let arraybusinessLife = self.currentProviderDetail!.businessLife as? [[String:Any]],arraybusinessLife.count > 0{
                 let firstbusinessLife:[String:Any] = arraybusinessLife[0]
                    if let filetype = firstbusinessLife["file_type"]{
                        if "\(filetype)" == "image" || "\(filetype)" == "IMAGE"{
                           
                        }else if "\(filetype)" == "video" || "\(filetype)" == "VIDEO"{
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
    
    @IBAction func buttonShareProfile(sender:UIButton){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                              return
                          
                      }
        var strtext = "Hi, I would like to share \(self.lblBusinessTitle.text!) with you. They offer a solid value, and great service."
               
        if var provide_id = Int(self.providerID){
            var link =  "https://werkules.com/?user_id=\(provide_id)"
                  
                  //  link.append("\(currentUser.referalCode)")
                    
                    guard let objLink = URL(string: "\(link)") else {
                        return
                        
                    }
                    let dynamicLinksDomainURIPrefix = "https://werkules.page.link"
                    
                    if let linkBuilder = DynamicLinkComponents(link: objLink, domainURIPrefix: dynamicLinksDomainURIPrefix){
                        linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID:"com.Werkules.EntreprenetworkApp")
                             linkBuilder.androidParameters = DynamicLinkAndroidParameters(packageName: "com.app.werkules")

                             guard let longDynamicLink = linkBuilder.url else { return }
                        
                             print("The long URL is: \(longDynamicLink)")
                        
                        
                               var urlString = String()
                             
                             urlString = "\(longDynamicLink)"//"https://apps.apple.com/us/app/werkules/id1488572477"//"https://apps.apple.com/ng/app/werkules/id1488572477?ign-mpt=uo%3D2"
                             strtext.append("\n\n\(longDynamicLink)")

                               let items = [strtext] as [Any]
                             let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                             activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                             
                             // present the view controller
                             self.present(activityViewController, animated: true, completion: nil)
                   }
        }

        
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
   func pushToFileReportViewController(){

       let profileStroyboard = UIStoryboard.init(name: "Profile", bundle: nil)
       if let reportBugViewController = profileStroyboard.instantiateViewController(withIdentifier: "ReportBugViewController") as? ReportBugViewController{
        reportBugViewController.providerId = self.providerID
        if let provider = self.currentProviderDetail{
            reportBugViewController.providerDetail = self.currentProviderDetail!
            if provider.isInprogressJOB.count > 0{
                reportBugViewController.isForFileDispute = true
            }else{
                reportBugViewController.isForFileDispute = false
            }
            
        }
           self.navigationController?.pushViewController(reportBugViewController, animated: true)
       }
   }
    func pushToUserReviewAddEditViewController(userID:String,userName:String,userProfile:String){
        let profileStroyboard = UIStoryboard.init(name: "Profile", bundle: nil)
              if let userReviewController = profileStroyboard.instantiateViewController(withIdentifier: "UserReviewAddEditViewController") as? UserReviewAddEditViewController{
                userReviewController.userID = userID
                userReviewController.userName = userName
                userReviewController.userProfile = userProfile
                userReviewController.isForProvider = true
                  self.navigationController?.pushViewController(userReviewController, animated: true)
              }
    }

}
extension ProviderDetailViewController:UpdateAskingPriceDelegate{
    func jobBookingdelegate() {
          DispatchQueue.main.async {
                if let objTabView = self.navigationController?.tabBarController{
                    print(objTabView.viewControllers)
                    if let objHomeNavigation:UINavigationController = objTabView.viewControllers?[1] as? UINavigationController{
                        if let objMyPost:MessagesVC = objHomeNavigation.viewControllers.first as? MessagesVC{
                            objTabView.selectedIndex = 1
                            //objMyPost.isFromHomeBooking = true
                            objMyPost.selectedIndexFromNotification = 1
                        }
                    }
                    self.navigationController?.popViewController(animated: false)

                 }
            }
      }
}
protocol PromotionAlertDelegate {
    func buttonOkaySelector(arrayOfProvider:[NotifiedProviderOffer])
}

class PromotionAlertViewController: UIViewController {

    
    @IBOutlet weak var lblPromotionsTitle:UILabel!
    @IBOutlet weak var lblPromotionsDetail:UILabel!
    @IBOutlet weak var lblPromotionsDescription:UILabel!
    @IBOutlet weak var lblPromotionsExpiryDate:UILabel!
    @IBOutlet weak var imgpromotion:UIImageView!
    @IBOutlet weak var lblDiscountOffCanOnlyUsedOnce:UILabel!
    
    var attributesBold: [NSAttributedString.Key: Any] = [
      .font: UIFont.init(name: "Avenir Heavy", size: 12.0)!,
      .foregroundColor: UIColor.init(hex: "#248483"),
         ]
      var attributesNormal: [NSAttributedString.Key: Any] = [
         .font:  UIFont.init(name: "Avenir Heavy", size: 12.0)!,
         .foregroundColor: UIColor.black,
         ]
    var objPromotion:Promotion?
    
    var arrayOfNotifiedProvider:[NotifiedProviderOffer] = []
    
    var delegate:PromotionAlertDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imgpromotion.clipsToBounds = true
                      self.imgpromotion.contentMode = .scaleAspectFill
        
        self.lblDiscountOffCanOnlyUsedOnce.textColor = UIColor.black
        if let _ = self.objPromotion{
            self.configurecurrentpromotiondetail()
        }
        // Do any additional setup after loading the view.
        if let _ = self.objPromotion{
            if let _ = self.objPromotion!.useOnce.bool{
                
            }
        }
    }
    // MARK: - configure user methods
    func configurecurrentpromotiondetail(){
        
        if let promotion = self.objPromotion{
            self.lblPromotionsTitle.text = "\(promotion.name)"
            self.lblPromotionsDescription.text = "\(promotion.promotionDescription)"
            if let isUseOnce = promotion.useOnce.bool{
                if isUseOnce{
                    self.lblDiscountOffCanOnlyUsedOnce.isHidden = false
                }else{
                    self.lblDiscountOffCanOnlyUsedOnce.isHidden = true
                }
            }else{
                self.lblDiscountOffCanOnlyUsedOnce.isHidden = true
            }
            print(promotion.useOnce.bool)
            
                if promotion.savingprice.count > 0{
                     if promotion.type.count > 0{
                        if "\(promotion.type)" == "percentage"{
                            self.lblPromotionsDetail.text = "\(promotion.savingprice)% off your total bill"
                        }else{
                            self.lblPromotionsDetail.text = "\(CurrencyFormate.Currency(value: Double(promotion.savingprice) ?? 0)) off your total bill"
                        }
                    }
                }else{
                     if promotion.type.count > 0{
                        if "\(promotion.type)" == "percentage"{
                            self.lblPromotionsDetail.text = "\(promotion.customerDiscount)% off your total bill"
                        }else{
                            self.lblPromotionsDetail.text = "\(CurrencyFormate.Currency(value: Double(promotion.customerDiscount) ?? 0)) off your total bill"
                        }
                    }
                }
                    
            
            //self.lblPromotionsDetail.text = "\(promotion.promotionDescription)"
            if promotion.image.count > 0{
                if let imgURL = URL.init(string: "\(promotion.image)"){
                     self.imgpromotion.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                 }
            }
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateformatter.date(from: promotion.expiryDate)
            dateformatter.dateFormat = "MM/dd/yyyy"
            var txtExpirydate = NSMutableAttributedString.init(string: "Expiration Date: ", attributes: attributesBold)
            var strDate = NSMutableAttributedString.init(string: "\(promotion.expiryDate)", attributes: attributesNormal)
            if let objdate = date,let updated = dateformatter.string(from: objdate) as? String{
               strDate =  NSMutableAttributedString.init(string: "\(dateformatter.string(from: date!))", attributes: attributesNormal)
            }
            txtExpirydate.append(strDate)
            self.lblPromotionsExpiryDate.attributedText = txtExpirydate
        }
    }
    
    @IBAction func buttonOkaySelector(sender:UIButton){
//        if let _ = self.delegate{
//            self.delegate!.buttonOkaySelector(arrayOfProvider:self.arrayOfNotifiedProvider)
            self.dismiss(animated: true, completion: nil)
//        }
        
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
protocol PromotionCreateEditProtocol {
    func buttonYesSelector(addUpdatePromotionParameters:[String:Any])
}

class PromotionCreateEditAlertViewController: UIViewController {

    
    @IBOutlet weak var lblPromotionsTitle:UILabel!
    @IBOutlet weak var lblPromotionsDetail:UILabel!
    @IBOutlet weak var lblPromotionsExpiryDate:UILabel!
    @IBOutlet weak var lblPromotionsDescriptionLbl:UILabel!
    @IBOutlet weak var imgpromotion:UIImageView!
    @IBOutlet weak var lblDiscountOffCanOnlyUsedOnce:UILabel!
    
    var attributesBold: [NSAttributedString.Key: Any] = [
      .font: UIFont.init(name: "Avenir Heavy", size: 12.0)!,
      .foregroundColor: UIColor.init(hex: "#248483"),
         ]
      var attributesNormal: [NSAttributedString.Key: Any] = [
         .font:  UIFont.init(name: "Avenir Heavy", size: 12.0)!,
         .foregroundColor: UIColor.black,
         ]
    var objPromotion:Promotion?
    
    var arrayOfNotifiedProvider:[NotifiedProviderOffer] = []
    
    var delegate:PromotionCreateEditProtocol?
    
    var addEditPromotionParameters:[String:Any] = [:]
    
    var promotiondata:Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgpromotion.clipsToBounds = true
                            self.imgpromotion.contentMode = .scaleAspectFill
        self.lblDiscountOffCanOnlyUsedOnce.textColor = UIColor.black
            self.configurecurrentpromotiondetail()
        /*
        if let _ = self.objPromotion{
            self.configurecurrentpromotiondetail()
        }
        // Do any additional setup after loading the view.
        if let _ = self.objPromotion{
            if let _ = self.objPromotion!.useOnce.bool{
                
            }
        }*/
    }
    // MARK: - configure user methods
    func configurecurrentpromotiondetail(){
        if self.addEditPromotionParameters.count > 0{
            if let name = self.addEditPromotionParameters["name"]{
                self.lblPromotionsTitle.text = "\(name)"
            }
            if let description = self.addEditPromotionParameters["description"]{
                self.lblPromotionsDescriptionLbl.text = "\(description)"
            }
            if let discount = self.addEditPromotionParameters["saving_price"]{
                if let discountType = self.addEditPromotionParameters["discount_type"]{
                    if "\(discountType)" == "percentage"{
                        self.lblPromotionsDetail.text = "\(discount)% off your total bill"
                    }else{
                        self.lblPromotionsDetail.text = "\(CurrencyFormateString.Currency(value: discount as! String)) off your total bill"

                     
                    }
                }
            }
            //self.lblPromotionsDetail.text = "\(promotion.promotionDescription)"
            if let imgData = self.promotiondata{
                self.imgpromotion.image = UIImage.init(data: imgData)
            }
            if let expiryDate =  self.addEditPromotionParameters["expiry_date"]{
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "dd/MM/yyyy"//"yyyy-MM-dd HH:mm:ss"
                let date = dateformatter.date(from: "\(expiryDate)")
                dateformatter.dateFormat = "MM/dd/yyyy"
                
                var txtExpirydate = NSMutableAttributedString.init(string: "Expiration Date: ", attributes: attributesBold)
                var strDate = NSMutableAttributedString.init(string: "\(expiryDate)", attributes: attributesNormal)
                if let objdate = date,let updated = dateformatter.string(from: objdate) as? String{
                   strDate =  NSMutableAttributedString.init(string: "\(dateformatter.string(from: date!))", attributes: attributesNormal)
                }
                //let strDate = NSMutableAttributedString.init(string: "\(dateformatter.string(from: date!))", attributes: attributesNormal)
//                let strDate = NSMutableAttributedString.init(string: "\(dateformatter.string(from: date!))", attributes: attributesNormal)
                txtExpirydate.append(strDate)
                self.lblPromotionsExpiryDate.attributedText = txtExpirydate
            }
            
        }
    }
    
    @IBAction func buttonOkaySelector(sender:UIButton){
//        if let _ = self.delegate{
//            self.delegate!.buttonOkaySelector(arrayOfProvider:self.arrayOfNotifiedProvider)
            self.dismiss(animated: true, completion: nil)
//        }
        
    }
    @IBAction func buttonYesSelector(sender:UIButton){
        if let _ = self.delegate{
            self.dismiss(animated: true, completion: nil)
            self.delegate!.buttonYesSelector(addUpdatePromotionParameters: self.addEditPromotionParameters)
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}




@IBDesignable
class RoundView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var defaultBordorColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = defaultBordorColor.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }


}
