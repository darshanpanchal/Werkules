//
//  RegistrationVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 26/07/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import SKCountryPicker
import CoreLocation
import Firebase
import Fusuma
import YPImagePicker

import MobileCoreServices
import CropViewController

class RegistrationVC: UIViewController,CLLocationManagerDelegate,FusumaDelegate,UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var scrView: UIScrollView!
    @IBOutlet weak var btnUserProfilePic: UIButton!
    @IBOutlet weak var txtFieldFirstName: UITextField!
    @IBOutlet weak var txtFieldLastName: UITextField!
    @IBOutlet weak var txtFieldPhoneNumber: UITextField!
    @IBOutlet weak var txtfldUserName: UITextField!
    @IBOutlet weak var txtFldAddress: UITextView!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var txtFldConfirmPassword: UITextField!
    @IBOutlet weak var txtreferrelCode: UITextField!
    
    @IBOutlet weak var btnCountryCode: UIButton!
    @IBOutlet weak var btnEye: UIButton!
    
    
    @IBOutlet weak var txtCity:UITextField!
    @IBOutlet weak var txtState:UITextField!
    @IBOutlet weak var txtZipCode:UITextField!
    @IBOutlet weak var lblTermsAndPrivacy:UILabel!
    @IBOutlet weak var btnBusinessSelector:UIButton!
    
    @IBOutlet weak var btnTermsAndConditionSelector:UIButton!
    
    
    @IBOutlet weak var stackViewCity:UIStackView!
    @IBOutlet weak var stackViewState:UIStackView!
    @IBOutlet weak var stackViewZipCode:UIStackView!
    @IBOutlet weak var lblAddress:UILabel!
    @IBOutlet weak var btnNext:UIButton!
    @IBOutlet weak var tableViewRegister:UITableView!
    
    @IBOutlet weak var btnCountyCode:UIButton!
    
    @IBOutlet weak var stackViewPassword:UIStackView!
    @IBOutlet weak var stackViewConfirmPassword:UIStackView!

    @IBOutlet weak var viewUserprofileDetail:UIView!
    @IBOutlet weak var stackViewUserName:UIStackView!
    @IBOutlet weak var stackViewReferralCode:UIStackView!
    @IBOutlet weak var viewMoreOption:UIView!
    @IBOutlet weak var btnMoreOption:UIButton!


    @IBOutlet weak var buttonOne:UIButton!
    @IBOutlet weak var buttonTwo:UIButton!
    
    @IBOutlet weak var lblSeparatedLine:UILabel!
    @IBOutlet weak var lblBusinessInformation:UILabel!
    
    @IBOutlet weak var refrealCodeView:UIView!
    var locationManager: CLLocationManager = CLLocationManager()
    
    var customerProfileImageData:Data?
    
    var customerSignUpParameters:[String:Any] = [:]
    
    var attributesBold: [NSAttributedString.Key: Any] = [
    .font: UIFont.init(name: "Avenir Heavy", size: 12.0)!,
    .foregroundColor: UIColor.init(hex: "#248483"),
       ]
    var attributesNormal: [NSAttributedString.Key: Any] = [
       .font:  UIFont.init(name: "Avenir Medium", size: 12.0)!,
       .foregroundColor: UIColor.init(hex: "#AAAAAA"),
       ]
    let text = "By signing up you accept the Term of service and Privacy Policy"

    var registerForBusiness:Bool = false
    var isForBusiness:Bool{
        get{
            return registerForBusiness
        }
        set{
            registerForBusiness = newValue
            //Update selected image
            self.configureISSetupForBusiness()
        }
        
    }
    
    var agreedOnTermsAndCondition:Bool = false
    var isTermsAndCondition:Bool{
        get{
            return agreedOnTermsAndCondition
        }
        set{
            agreedOnTermsAndCondition = newValue
            //Update selected
            self.configureSelectedTermsAndCondition()
            
        }
    }
    var objSocialMedia:SocialMediaObject?
    var isforFacebook:Bool?
    
    var objImagePickerController = UIImagePickerController()
    var imageForCrop: UIImage?
   
    var strReferealCode: String = ""
    var isFromDynamicLink:Bool = false
    //MARK: - UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        //setup screen
        self.setUp()
        
        self.txtFieldEmail.delegate = self
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate , appDelegate.strReferrelCode.count > 0{
            self.txtreferrelCode.text = "\(appDelegate.strReferrelCode)"
        }
        if self.strReferealCode != ""{
            self.txtreferrelCode.isUserInteractionEnabled = false
            self.txtreferrelCode.text = self.strReferealCode
            self.refrealCodeView.backgroundColor = UIColor.gray
        }else{
            self.txtreferrelCode.isUserInteractionEnabled = true
            self.refrealCodeView.backgroundColor = UIColor.clear
        }
        print(UIApplication.shared.delegate?.window)

        let underlineSeeDetail = NSAttributedString(string: "More Customer Profile Options",
                                                                  attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnMoreOption.setAttributedTitle(underlineSeeDetail, for: .normal)
        self.btnMoreOption.addTarget(self, action: #selector(RegistrationVC.buttonMoreOptionsSelector(sender:)), for: .touchUpInside)
//        self.presentOTPVerificationScreen(strText: "", customerDetail: [:])
//        self.pushToCreateBusinessScreen()

    }
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          self.locationManager.stopUpdatingLocation()
         
      }
    private func setUp(){
        self.txtCity.autocapitalizationType = .words
        self.txtState.autocapitalizationType = .words
        self.txtCity.keyboardType = .alphabet
        self.txtState.keyboardType = .alphabet
          //self.txtZipCode.keyboardType = .numbersAndPunctuation
        //default hide city state and zip code
           self.txtFldAddress.delegate = self
           self.txtCity.delegate = self
            self.txtCity.autocorrectionType = .no

           self.txtState.delegate = self
           self.txtFieldPassword.delegate = self
            self.txtFldConfirmPassword.delegate = self 
        
           self.tableViewRegister.tableFooterView = UIView()
           //Default Country Coed
           self.customerSignUpParameters["country_code"] = "+1"
           self.btnCountryCode.setTitle("+1", for: .normal)
        
           self.buttonOne.layer.borderColor = UIColor.init(hex:"#248483").cgColor
           self.buttonOne.layer.borderWidth = 1.0
           self.buttonOne.clipsToBounds = true
           self.buttonOne.layer.cornerRadius = 25.0
        
           
           self.buttonTwo.layer.borderColor = UIColor.init(hex:"#AAAAAA").cgColor
           self.buttonTwo.layer.borderWidth = 1.0
           self.buttonTwo.clipsToBounds = true
           self.buttonTwo.layer.cornerRadius = 25.0
           
        
           //Configure SocialMedia Login parameters
           if let objSocial = self.objSocialMedia{
               self.customerSignUpParameters["id"]  = "\(objSocial.id)"
               self.stackViewPassword.isHidden = true
               self.stackViewConfirmPassword.isHidden = true
               self.txtFieldEmail.text = objSocial.email
               self.txtfldUserName.text = objSocial.name
               self.txtFieldFirstName.text = objSocial.firstname
               self.txtFieldLastName.text = objSocial.lastname
               if let objURL = URL.init(string: objSocial.profileURL){
                   self.btnUserProfilePic.sd_setBackgroundImage(with: objURL, for: .normal) { (image, error, catch, url) in
                       if let socialImage = image{
                           self.customerProfileImageData = socialImage.jpegData(compressionQuality: 0.5)
                           UserRegister.Shared.vProfilepic = socialImage
                           
                       }
                       
                   }
               }
               
               //self.btnUserProfilePic.setBackgroundImage(UIImage.init(data: resizedImage), for: .normal)
               
               //self.customerProfileImageData = resizedImage
               
               
               
               
           }else{
               self.stackViewPassword.isHidden = false
               self.stackViewConfirmPassword.isHidden = false
               self.txtFieldEmail.text = ""
               self.txtfldUserName.text = ""
               self.txtFieldFirstName.text = ""
               self.txtFieldLastName.text = ""
           }
           self.showHideCityStateZipCode(hide: true)
    }
    private func initialize() {
        scrView.isHidden = false

        guard let country = CountryManager.shared.currentCountry else {
            self.btnCountryCode.setTitle("+1", for: .normal)
            return
        }
        self.customerSignUpParameters["country_code"] = "\(country.dialingCode ?? "+1")"
        self.btnCountryCode.setTitle("\(country.dialingCode ?? "+1")", for: .normal)
        self.btnCountryCode.clipsToBounds = true
        //disableAutoFill()
        mylocation()
        txtFieldPassword.delegate = self
        txtFldConfirmPassword.delegate = self
        
        //setup terms and conditions and privacy
        
        let mutableString = NSMutableAttributedString.init(string: "By signing up you accept the\n", attributes: self.attributesNormal)
        let mutableStringValue1 = NSMutableAttributedString.init(string: "Terms of Service ", attributes: self.attributesBold)
        let mutableStringValue2 = NSMutableAttributedString.init(string: "and", attributes: self.attributesNormal)
        let mutableStringValue3 = NSMutableAttributedString.init(string: " Privacy Policy", attributes: self.attributesBold)
        
        mutableString.append(mutableStringValue1)
        mutableString.append(mutableStringValue2)
        mutableString.append(mutableStringValue3)
        
        self.lblTermsAndPrivacy.attributedText = mutableString
        
        self.isForBusiness = false
        
    }
    func sizeHeaderFit(){
        if let headerView =  self.tableViewRegister.tableHeaderView {
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            print(headerView.frame)
            print(headerView.bounds)
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            self.tableViewRegister.tableHeaderView = headerView
            self.view.layoutIfNeeded()
        }
    }
    func showHideCityStateZipCode(hide:Bool){
        self.stackViewCity.isHidden = hide
        self.stackViewState.isHidden = hide
        self.stackViewZipCode.isHidden = hide
        
        if hide{
            self.sizeHeaderFit()
        }
        
    }
    @IBAction func tapTest(button: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showTerms", sender: button)
        }
    }
    @IBAction func tapToSetupBusinessSelector(button: UIButton) {
        DispatchQueue.main.async {
            self.isForBusiness = !self.isForBusiness
        }
    }
    func configureISSetupForBusiness(){
        
        if self.isForBusiness{
            self.btnNext.setTitle("NEXT", for: .normal)
            self.btnBusinessSelector.setImage(UIImage.init(named: "select"), for: .normal)
            self.lblSeparatedLine.backgroundColor = UIColor.init(hex: "#248483")
            self.lblBusinessInformation.textColor = UIColor.init(hex: "#248483")
            self.buttonTwo.layer.borderColor = UIColor.init(hex:"#248483").cgColor
            self.buttonTwo.setTitleColor(UIColor.init(hex: "#248483"), for: .normal)
        }else{
            self.btnNext.setTitle("DONE", for: .normal)
            self.btnBusinessSelector.setImage(UIImage.init(named: "unselect"), for: .normal)
            self.lblSeparatedLine.backgroundColor = UIColor.init(hex: "#AAAAAA")
            self.lblBusinessInformation.textColor = UIColor.init(hex: "#AAAAAA")
            self.buttonTwo.layer.borderColor = UIColor.init(hex:"#AAAAAA").cgColor
            self.buttonTwo.setTitleColor(UIColor.init(hex: "#AAAAAA"), for: .normal)
        }

    }

    @IBAction func tapToSetupTermsAndConditionSelector(button: UIButton) {
        DispatchQueue.main.async {
            self.isTermsAndCondition = !self.isTermsAndCondition
        }
    }
    func configureSelectedTermsAndCondition(){
        if self.isTermsAndCondition{
            self.btnTermsAndConditionSelector.setImage(UIImage.init(named: "select"), for: .normal)
        }else{
            self.btnTermsAndConditionSelector.setImage(UIImage.init(named: "unselect"), for: .normal)
        }
    }
    func disableAutoFill() {
        if #available(iOS 12, *) {
            // iOS 12 & 13: Not the best solution, but it works.
            txtFieldPassword.textContentType = .oneTimeCode
            txtFldConfirmPassword.textContentType = .oneTimeCode
        } else {
            // iOS 11: Disables the autofill accessory view.
            // For more information see the explanation below.
            txtFieldPassword.textContentType = .init(rawValue: "")
            txtFldConfirmPassword.textContentType = .init(rawValue: "")
            txtFieldPassword.autocorrectionType = .no
            txtFldConfirmPassword.autocorrectionType = .no
        }
    }
    
    //MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latestLocation: AnyObject = locations[locations.count - 1]
        let mystartLocation = latestLocation as! CLLocation;
        
        UserRegister.Shared.lat = String(mystartLocation.coordinate.latitude)
        UserRegister.Shared.long =  String(mystartLocation.coordinate.longitude)
        
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("textViewShouldBeginEditing")
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.lblAddress.text = "Street Address"
                self.showHideCityStateZipCode(hide: false)
            }
        }
        
        return true
    }
    // MARK: - Actions
    @IBAction func buttonMoreOptionsSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.viewMoreOption.fadeOut() //hide
            self.viewUserprofileDetail.fadeIn() //show
            self.stackViewUserName.fadeOut() //hide
            self.stackViewReferralCode.fadeIn() //show
            do{
                //self.sizeHeaderFit()
            }
        }
    }
    @IBAction func buttonPasswordHelpSelector(sender:UIButton){
        DispatchQueue.main.async {
            let noCamera = UIAlertController.init(title:"Password Help", message: "Password must have a minimum of 8 characters with at least one number and one special character.", preferredStyle: .alert)
            let  okaySelector = UIAlertAction.init(title:"Ok", style: .cancel, handler: nil)
            okaySelector.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
            noCamera.addAction(okaySelector)
            noCamera.view.tintColor = UIColor(hex:"38B5A3")
            self.present(noCamera, animated: true, completion: nil)
        }
    }
    @IBAction func btnCoverPicClicked(_ sender: UIButton) {
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.modalPresentationStyle = .fullScreen
        fusuma.availableModes = [.library, .camera] // Add .video capturing mode to the default .library and .camera modes
        fusuma.cropHeightRatio = 0.4 // Height-to-width ratio. The default value is 1, which means a squared-size photo.
        fusuma.allowMultipleSelection = false // You can select multiple photos from the camera roll. The default value is false.
        //fusuma.photoSelectionLimit = 1
        self.present(fusuma, animated: true, completion: nil)
    }
    @IBAction func buttonCameraInfoSelector(sender:UIButton){
        DispatchQueue.main.async {
            let cameraInfo = UIAlertController.init(title:AppName, message: kUserProfileHelp, preferredStyle: .alert)
            cameraInfo.addAction(UIAlertAction.init(title:"Ok", style: .cancel, handler: nil))
            cameraInfo.view.tintColor = UIColor.init(hex: "#38B5A3")
            self.present(cameraInfo, animated: true, completion: nil)
        }
    }
    @IBAction func btnUserProfileClicked(_ sender: UIButton) {
        /*
        var config = YPImagePickerConfiguration()
        config.showsPhotoFilters = false
        config.library.maxNumberOfItems = 1
        config.isScrollToChangeModesEnabled = false
        config.startOnScreen = .library
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                let aImg = photo.image
                
                let resizedImage = self.resize(aImg)
                
                self.btnUserProfilePic.setBackgroundImage(UIImage.init(data: resizedImage), for: .normal)
                
                self.customerProfileImageData = resizedImage
                
                UserRegister.Shared.vProfilepic = UIImage.init(data: resizedImage)
                
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
        */
        self.presentCameraAndPhotosSelector()
    }
    func presentCameraAndPhotosSelector(){
        //PresentMedia Selector
        let actionSheetController = UIAlertController.init(title: "", message: "Profile", preferredStyle: .actionSheet)
        let cancelSelector = UIAlertAction.init(title: "Cancel", style: .cancel, handler:nil)
        cancelSelector.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
        
        actionSheetController.addAction(cancelSelector)
        let photosSelector = UIAlertAction.init(title: "Photos", style: .default) { (_) in
            DispatchQueue.main.async {
                self.objImagePickerController = UIImagePickerController()
                self.objImagePickerController.sourceType = .savedPhotosAlbum
                self.objImagePickerController.delegate = self
                self.objImagePickerController.allowsEditing = false
                self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                self.view.endEditing(true)
                self.presentImagePickerController()
            }
        }
        photosSelector.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
        
        actionSheetController.addAction(photosSelector)
        
   
        
        let cameraSelector = UIAlertAction.init(title: "Camera", style: .default) { (_) in
            if CommonClass.isSimulator{
                DispatchQueue.main.async {
                    let noCamera = UIAlertController.init(title:"Cameranotsupported", message: "", preferredStyle: .alert)
                    noCamera.addAction(UIAlertAction.init(title:"ok", style: .cancel, handler: nil))
                    self.present(noCamera, animated: true, completion: nil)
                }
            }else{
                DispatchQueue.main.async {
                    self.objImagePickerController = UIImagePickerController()
                    self.objImagePickerController.delegate = self
                    self.objImagePickerController.allowsEditing = false
                    self.objImagePickerController.sourceType = .camera
                    self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                    self.presentImagePickerController()
                }
            }
        }
        cameraSelector.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
        
        actionSheetController.addAction(cameraSelector)
        self.view.endEditing(true)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    func presentImagePickerController(){
           self.view.endEditing(true)
           self.objImagePickerController.modalPresentationStyle = .fullScreen
           self.present(self.objImagePickerController, animated: true, completion: nil)
          
       }
    @IBAction func btnCountryCodeClicked(_ sender: UIButton) {
        
        txtFieldFirstName.resignFirstResponder()
        txtFieldLastName.resignFirstResponder()
        txtFieldEmail.resignFirstResponder()
        txtFieldPhoneNumber.resignFirstResponder()
        txtFieldPassword.resignFirstResponder()
        txtFldConfirmPassword.resignFirstResponder()
        
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in
            
            guard let self = self else { return }
            
            self.btnCountryCode.setTitle(country.dialingCode, for: .normal)
            self.customerSignUpParameters["country_code"] = "\(country.dialingCode ?? "+1")"
            
        }
        // can customize the countryPicker here e.g font and color
        countryController.detailColor = UIColor.red
    }
    
    @IBAction func btnLoginClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: Back Button Action
    @IBAction func btnBackClicked(_ sender: Any) {
        if self.isFromDynamicLink{
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let navigationController = UINavigationController(rootViewController:loginVC)
            // Make the Tab Bar Controller the root view controller
            //connect()
            if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first{
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    // MARK:API Request
    func customerSignupAPIRequest(){
        APIRequestClient.shared.uploadImage(requestType: .POST, queryString:kCustomerRegister , parameter: self.customerSignUpParameters as [String:AnyObject], imageData:self.customerProfileImageData ?? nil , isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                ExternalClass.HideProgress()
            }
            
            
            if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                UserDefaults.standard.removeObject(forKey: "GroupReferralCode")
                UserDefaults.standard.set(self.txtFieldPassword.text, forKey: "UserPassword")
                /*
                if let customerData = userInfo["customer_data"] as? [String:Any]{
                                       let objUser:UserDetail = UserDetail.init(userDetail: customerData)
                                       if let providerDetail = userInfo["provider_data"] as? [String:Any]{
                                           let objprovider:BusinessDetail = BusinessDetail.init(businessDetail: providerDetail)
                                           objUser.businessDetail = objprovider
                                       }
                                       objUser.setuserDetailToUserDefault()
                                   }*/
//                let objUser = UserDetail.init(userDetail: userInfo)
//                objUser.setuserDetailToUserDefault()
                
                DispatchQueue.main.async {
                     //OTP update
                    if let strMessage = success["success_message"],"\(strMessage)".count > 0 {
                        if let customerData = userInfo["customer_data"] as? [String:Any]{
                            self.presentMobileAndEmailVerificationScreen(strMessage: "\(strMessage)",userDetail: customerData)
                        }

                    }
                    /*
                    //Alert

                    if self.isForBusiness{
                        self.pushToCreateBusinessScreen()
                    }else if let strMessage = success["success_message"],"\(strMessage)".count > 0 {

                        let alert = UIAlertController(title: AppName, message: "\(strMessage)", preferredStyle: .alert)
                        
                         alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                            
                            if self.isForBusiness{
                                self.pushToCreateBusinessScreen()
                            }else{
                                if self.isFromDynamicLink{
                                    let storyboard = UIStoryboard(name: "Profile", bundle: nil)
                                    let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                    let navigationController = UINavigationController(rootViewController:loginVC)
                                    if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first{
                                        window.rootViewController = navigationController
                                            window.makeKeyAndVisible()
                                    }
                                    //UIApplication.shared.keyWindow?.rootViewController? = navigationController
                                    //UIApplication.shared.keyWindow?.makeKeyAndVisible()
                                }else{
                                    self.navigationController?.popViewController(animated: true)
                                }
                                //PopToLogin Screen 07/01/21 //29/06/2021
                                //push to help screen 23/03/21
                                //self.pushToHelpViewController()
                            }
                         }))
                        alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                        self.present(alert, animated: true, completion: nil)
                        
                    }else{
                        //Sign Up Flow Update
                        if self.isForBusiness{
                            self.pushToCreateBusinessScreen()
                        }else{
                            //PopToLogin Screen 07/01/21
                             //self.navigationController?.popViewController(animated: true)
                            //push to help screen 23/03/21
                            self.pushToHelpViewController()
                        }
                    }*/
                }
            }
        }) { (responseFail) in
                DispatchQueue.main.async {
                    ExternalClass.HideProgress()
                }
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
    func presentMobileAndEmailVerificationScreen(strMessage:String,userDetail:[String:Any]){
        if let verificationViewController = UIStoryboard.profile.instantiateViewController(withIdentifier: "PhoneEmailVerificationAlertViewController") as? PhoneEmailVerificationAlertViewController{
            verificationViewController.modalPresentationStyle = .overFullScreen
            verificationViewController.strDynamicText = strMessage
            verificationViewController.strMobileNumber = self.txtFieldPhoneNumber.text ?? ""
            verificationViewController.strEmailAddress = self.txtFieldEmail.text ?? ""
            verificationViewController.isForBusinessSignUp = self.isForBusiness
            verificationViewController.customerDetail = userDetail
            verificationViewController.delegate = self
            self.present(verificationViewController, animated: true, completion: nil)
        }
    }
    func presentOTPVerificationScreen(strText:String,customerDetail:[String:Any]){
        if let otpverificationViewController = UIStoryboard.profile.instantiateViewController(withIdentifier: "OTPVerificationViewController") as? OTPVerificationViewController{
            otpverificationViewController.modalPresentationStyle = .overFullScreen
            otpverificationViewController.strDynamicText = strText
            otpverificationViewController.customerDetail = customerDetail
            otpverificationViewController.delegate = self
            self.present(otpverificationViewController, animated: true, completion: nil)

        }

    }
    func pushToHelpViewController(){
          if let helpViewController = self.storyboard?.instantiateViewController(withIdentifier: "HelpViewController") as? HelpViewController{
              self.navigationController?.pushViewController(helpViewController, animated: true)
          }
        
      }
    //MARk : Next Button Action
    @IBAction func btnNextClicked(_ sender: UIButton) {
        
//        self.pushToCreateBusinessScreen()


        if !self.validateData() {
            return
        }
        
        self.customerSignupAPIRequest()

       /* if self.objSocialMedia != nil{
            self.customerSignupAPIRequest(QBUser: Int(objSocialMedia!.quickblox_id)!)
        }else{
            self.signUp(fullName: self.txtfldUserName.text!, email: self.txtFieldEmail.text!, login: self.txtfldUserName.text!,password: self.txtFieldPassword.text!)
        }*/
        
      
    }
    
    @IBAction func btnResendCodeclicked(_ sender: UIButton) {
        
        let dict = [
            APIManager.Parameter.mobileNumber : btnCountryCode.title(for: .normal)! + txtFieldPhoneNumber.text!
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_sendOTP, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            // self.txtFieldVerCode.text = ""
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                let verCode = dataDict["data"]
                if let Verificationcode = verCode as? NSNumber
                {
                    UserDefaults.standard.set("\(Verificationcode)", forKey: "verificationCode")
                }
                
                self.scrView.isHidden = true
                
                NotificationCenter.default.post(name: Notification.Name("UserSignInOutNotification"), object: nil)
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        }
    }
    
    @IBAction func btnDoneClicked(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "RegistrationDone")
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBAction func btnShowPassword(_ sender: UIButton) {
        
        if sender.isSelected == true {
            sender.isSelected = false
            if sender.tag == 101 {
                txtFieldPassword.isSecureTextEntry = true
            }else{
                txtFldConfirmPassword.isSecureTextEntry = true
            }
        }else {
            sender.isSelected = true
            if sender.tag == 101 {
                txtFieldPassword.isSecureTextEntry = false
            }else{
                txtFldConfirmPassword.isSecureTextEntry = false
            }
        }
    }
    
    
    @IBAction func btnRegisterClicked(_ sender: UIButton) {
        
        if !validateData() {
            SAAlertBar.show(.error, message: "please enter valid data")
            return
        }
        var deviceTokennew = String()
        if isKeyPresentInUserDefaults(key: "fcmToken") {
            deviceTokennew = UserDefaults.standard.object(forKey: "fcmToken") as! String
        }
        else{
            deviceTokennew = "Sujal"
        }
        
        UserRegister.Shared.userId = ""
        
        UserRegister.Shared.vProfilepic = self.btnUserProfilePic.image(for: .normal)
        UserRegister.Shared.vfileKey = "file"
        UserRegister.Shared.vchunkedMode = "false"
        UserRegister.Shared.vmimeType = "image/png"
        UserRegister.Shared.vTimestamp = "profile.png"
        UserRegister.Shared.userType = "entrepreneur"
        
        UserRegister.Shared.firstName = txtFieldFirstName.text!
        UserRegister.Shared.lastName = txtFieldLastName.text!
        //            UserRegister.Shared.companyName = txtfldCompanyName.text!
        //            UserRegister.Shared.tagline = txtFldTagline.text!
        UserRegister.Shared.email = txtFieldEmail.text!.lowercased()
        if txtFieldPhoneNumber.text?.isEmpty == false {
            UserRegister.Shared.phone = btnCountryCode.title(for: .normal)! + txtFieldPhoneNumber.text!
        }
        UserRegister.Shared.password = txtFieldPassword.text!
        UserRegister.Shared.deviceToken = deviceTokennew
        
        let dict = [
            APIManager.Parameter.mobileNumber : btnCountryCode.title(for: .normal)! + txtFieldPhoneNumber.text!
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_sendOTP, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                let verCode = dataDict["data"]
                if let Verificationcode = verCode as? NSNumber
                {
                    UserDefaults.standard.set("\(Verificationcode)", forKey: "verificationCode")
                }
                
                self.scrView.isHidden = true
                NotificationCenter.default.post(name: Notification.Name("UserSignInOutNotification"), object: nil)
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        }
        
    }
    
    //MARK: - Fusuma Delegate Methods
    
    // Return the image which is selected from camera roll or is taken via the camera.
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        
        print("Image selected")
    }
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(image: UIImage, source: FusumaMode) {
        
        print("Called just after FusumaViewController is dismissed.")
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        print("Called just after a video has been selected.")
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
    }
    
    // Return selected images when you allow to select multiple photos.
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        
    }
    
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode, metaData: [ImageMetadata]) {
        
    }
    
    // MARK: - User Defined Methods
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func mylocation()   {
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        // Ask for Authorisation from the User.
        
        // For use in foreground
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    private func validateData() -> Bool {
        /*
        guard let _ = self.customerProfileImageData else {
            SAAlertBar.show(.error, message:"Please select a profile picture".localizedLowercase)
            return false
        }*/
        /*if btnUserProfilePic.image(for: .normal) == UIImage(named: "user_placeholder") {
            SAAlertBar.show(.error, message:"Please select a profile picture".localizedLowercase)
            return false
        }*/
        guard let firstName = self.txtFieldFirstName.text?.trimmingCharacters(in: .whitespacesAndNewlines),firstName.count > 0 else{
            SAAlertBar.show(.error, message:"Please enter first name".localizedLowercase)
            return false
        }
//        if (txtFieldFirstName.text?.isEmpty)!{
//            SAAlertBar.show(.error, message:"Please enter first name".localizedLowercase)
//            return false
//        }
        self.customerSignUpParameters["firstname"]  = "\(self.txtFieldFirstName.text ?? "")"
        
        guard let lastName = self.txtFieldLastName.text?.trimmingCharacters(in: .whitespacesAndNewlines),lastName.count > 0 else{
            SAAlertBar.show(.error, message:"Please enter last name".localizedLowercase)
            return false
        }
//        if (txtFieldLastName.text?.isEmpty)!{
//            SAAlertBar.show(.error, message:"Please enter last name".localizedLowercase)
//            return false
//        }
        self.customerSignUpParameters["lastname"]  = "\(self.txtFieldLastName.text ?? "")"
        /*
        guard let username = self.txtfldUserName.text?.trimmingCharacters(in: .whitespacesAndNewlines),username.count > 0 else{
                 SAAlertBar.show(.error, message:"Please enter Username".localizedLowercase)
                 return false
             }*/
        
//        if (txtfldUserName.text?.isEmpty)!{
//            SAAlertBar.show(.error, message:"Please enter Username".localizedLowercase)
//            return false
//        }
        if let _ = self.txtfldUserName.text{
            self.customerSignUpParameters["username"]  = "\(self.txtfldUserName.text ?? "")"
        }

        
        guard let email = self.txtFieldEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines),email.count > 0 else{
                        SAAlertBar.show(.error, message:"Please enter email to register")
                        return false
                    }
        
//        if (txtFieldEmail.text?.isEmpty)!{
//            SAAlertBar.show(.error, message:"Please enter email".localizedLowercase)
//            return false
//        }
        self.customerSignUpParameters["email"]  = "\(self.txtFieldEmail.text ?? "")"
        
       guard let phone = self.txtFieldPhoneNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines),phone.count > 0 else{
                             SAAlertBar.show(.error, message:"Please enter Phone number")
                             return false
                         }
        if (txtFieldPhoneNumber.text?.isEmpty) == false {
                  if !self.isValidContact(testStr: txtFieldPhoneNumber.text!){
                      SAAlertBar.show(.error, message:"Please enter valid phone to register".localizedLowercase)
                      return false
                  }
              }
//        if (txtFieldPhoneNumber.text?.isEmpty)!{
//                   SAAlertBar.show(.error, message:"Please enter Phone number".localizedLowercase)
//                   return false
//               }
       self.customerSignUpParameters["phone"]  = "\(self.txtFieldPhoneNumber.text ?? "")"
        
      
       guard let city = self.txtCity.text?.trimmingCharacters(in: .whitespacesAndNewlines),city.count > 0 else{
           SAAlertBar.show(.error, message:"Please enter City")
           return false
       }
//        if (self.txtCity.text?.isEmpty)!{
//            SAAlertBar.show(.error, message:"Please enter City".localizedLowercase)
//            return false
//        }
        self.customerSignUpParameters["city"]  = "\(self.txtCity.text ?? "")"
        
        guard let state = self.txtState.text?.trimmingCharacters(in: .whitespacesAndNewlines),state.count > 0 else{
                  SAAlertBar.show(.error, message:"Please enter State")
                  return false
              }
//        if (self.txtState.text?.isEmpty)!{
//            SAAlertBar.show(.error, message:"Please enter State".localizedLowercase)
//            return false
//        }
        self.customerSignUpParameters["state"]  = "\(self.txtState.text ?? "")"
        
        guard let zipcode = self.txtZipCode.text?.trimmingCharacters(in: .whitespacesAndNewlines),zipcode.count > 0 else{
                         SAAlertBar.show(.error, message:"Please enter ZipCode")
                         return false
                     }
        
//        if (self.txtZipCode.text?.isEmpty)!{
//            SAAlertBar.show(.error, message:"Please enter ZipCode".localizedLowercase)
//            return false
//        }
//        if zipcode.count > 6{
//            SAAlertBar.show(.error, message:"for zip code maximum limit 6 characters")
//            return false
//        }
        
        self.customerSignUpParameters["zipcode"]  = "\(self.txtZipCode.text ?? "")"
        
        
        guard let address = self.txtFldAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines),address.count > 0 else{
                             SAAlertBar.show(.error, message:"Please enter Address")
                             return false
                         }
//        if (self.txtFldAddress.text?.isEmpty)!{
//            SAAlertBar.show(.error, message:"Please enter Address".localizedLowercase)
//            return false
//        }
        self.customerSignUpParameters["address"]  = "\(self.txtFldAddress.text ?? "")"
        
        
         self.customerSignUpParameters["platform"] = "ios"
        var deviceToken = String()
        if isKeyPresentInUserDefaults(key: "fcmToken") {
            deviceToken = UserDefaults.standard.object(forKey: "fcmToken") as! String
        }else{
            deviceToken = ""
        }
        self.customerSignUpParameters["device_token"] = "\(deviceToken)"
        
      
 
        if let _ = self.objSocialMedia{
            self.customerSignUpParameters["login_type"] = "\(self.objSocialMedia!.type)"
            
        }else{
              self.customerSignUpParameters["login_type"] = "normal"
                guard let password = self.txtFieldPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines),password.count > 0 else{
                                           SAAlertBar.show(.error, message:"Please enter password")
                                           return false
                                       }
            
                    if !self.isValidPassword(testStr: password){
                        //Password must have a minimum of 8 characters with at least one number and one special character.
                        SAAlertBar.show(.error, message:"Password must have a minimum of 8 characters with at least one number and one special character.".localizedLowercase)
                        //SAAlertBar.show(.error, message:"for password minimum 8 characters & must contain one number and one special character".localizedLowercase)
                               return false
                    }
            
                   self.customerSignUpParameters["password"]  = "\(self.txtFieldPassword.text ?? "")"
            
                   guard let confirmpassword = self.txtFldConfirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines),confirmpassword.count > 0 else{
                                                        SAAlertBar.show(.error, message:"Please enter confirm password")
                                                        return false
                                                    }
            

                   
                   if txtFieldPassword.text != txtFldConfirmPassword.text {
                    //Your passwords do not match
                    SAAlertBar.show(.error, message:"Your passwords do not match".localizedLowercase)
                       //SAAlertBar.show(.error, message:"Password and confirm password should be same".localizedLowercase)
                       return false
                   }
            if self.isForBusiness == true{
                self.customerSignUpParameters["is_adding_business_profile"]  = true
            }else{
                self.customerSignUpParameters["is_adding_business_profile"]  = false
            }
            
            
        }
               
        
        
       
        
        
        
        if !self.isValidEmail(testStr: txtFieldEmail.text!){
            
            SAAlertBar.show(.error, message:"Please enter valid email".localizedLowercase)
            return false
        }
        if let code = self.txtreferrelCode.text?.trimmingCharacters(in: .whitespacesAndNewlines),code.count > 0{
            self.customerSignUpParameters["referal_code"] = "\(code)"
        }
        guard  self.isTermsAndCondition else {
            SAAlertBar.show(.error, message:"You must agree to Terms of Service".localizedLowercase)
            return false
        }
        
        
        
        return true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z]+([._%+-]{1}[A-Z0-9a-z]+)*@[A-Za-z0-9]+\\.([A-Za-z])*([A-Za-z0-9]+\\.[A-Za-z]{2,4})*"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    func isValidPassword(testStr:String)->Bool{
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: testStr)
    }
    func isValidContact (testStr:String) -> Bool {
        let phoneNumberRegex = "^[0-9]\\d{9}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        let isValidPhone = phoneTest.evaluate(with: testStr)
        return isValidPhone
    }
    
    func resize(_ image: UIImage) -> Data{
        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxHeight: Float = 900
        let maxWidth: Float = 900
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        //50 percent compression
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        //let imageData = UIImageJPEGRepresentation(img!, CGFloat(compressionQuality))
        // let imageData = image.jpeg(UIImage.JPEGQuality(rawValue: CGFloat(compressionQuality))!)
        let imageData = img!.jpegData(compressionQuality: 0.3)
        
        UIGraphicsEndImageContext()
        return imageData!//UIImage(data: imageData!) ?? UIImage()
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showTerms" {
            let vc = segue.destination as! ConditionPolicyVC
            vc.strTitle = "Terms & Condition"
            if let btn =  sender as? UIButton, btn.tag == 1{
                    vc.strTitle = "Privacy Policy"
                }
            }
        }
    //pushtoCreateBusinesss Screen
    func pushToCreateBusinessScreen(userID:String = ""){
        if let providerId = UserDefaults.standard.object(forKey: "ProviderId") as? String, providerId != nil{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let pdvc  = storyboard.instantiateViewController(withIdentifier: "ProviderDetailViewController") as! ProviderDetailViewController
            let navigationController = UINavigationController(rootViewController:pdvc)
            navigationController.navigationBar.isHidden = true
            pdvc.providerID = providerId
            pdvc.isFromDynamicLink = true
            pdvc.showBookNowButton = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = navigationController
        }else{
            if let objBusinessprofile = self.storyboard?.instantiateViewController(withIdentifier: "CreateBusinssProfile") as? CreateBusinssProfile {
                objBusinessprofile.is_firsttimeregister = true
                if userID.count > 0{
                    objBusinessprofile.userID = "\(userID)"
                }
                self.navigationController?.pushViewController(objBusinessprofile, animated: true)
            }
        }
        
    }
    func presentCustomerHelpViewController(){
        if let customerHelp = UIStoryboard.profile.instantiateViewController(withIdentifier: "CustomerProviderHelpVideoViewController") as? CustomerProviderHelpVideoViewController{
            customerHelp.modalPresentationStyle = .fullScreen
            customerHelp.delegate = self
            customerHelp.isForCustomer = true
            self.navigationController?.present(customerHelp, animated: true, completion: nil)
        }
    }
    //PushToHome
    func pushToCustomerHomeViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let navigationController = UINavigationController(rootViewController:VC)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }
}
extension RegistrationVC:CustomerProviderHelpDelegate{
    func playerDidFinishWithPlay(isforcustomer: Bool, isForVerifiedProvider: Bool) {

        DispatchQueue.main.async {
            self.pushToCustomerHomeViewController()
        }
    }
}
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
}
extension RegistrationVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.dismiss(animated: true, completion: nil)
        let resizedImage = self.resize(image)
                   self.btnUserProfilePic.setImage(UIImage.init(data: resizedImage), for: .normal)
                   self.customerProfileImageData = resizedImage
    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.imageForCrop = image
            
        }
        
        self.dismiss(animated: false) { [unowned self] in
                                  self.openEditor(nil, pickingViewTag: picker.view.tag)
                              }
                  
         //self.dismiss(animated:true, completion: nil)
    }
    func openEditor(_ sender: UIBarButtonItem?, pickingViewTag: Int) {
        guard let image = self.imageForCrop else {
            return
        }
        
        let cropViewController = CropViewController(image: image)
        cropViewController.setAspectRatioPreset(.presetSquare, animated: true)
        cropViewController.delegate = self
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.cropView.cropBoxResizeEnabled = false
        self.present(cropViewController, animated: true, completion: nil)
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
}

extension RegistrationVC{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
                    

        if textField == self.txtFieldEmail{
            guard !typpedString.isContainWhiteSpace() else{
                        return false
            }
         
            return typpedString.count < 255
        }/*else if textField == self.txtCity || textField == self.txtState{
            let numbersRange = typpedString.rangeOfCharacter(from: .decimalDigits)
            return !typpedString.hasSpecialCharacters() && (numbersRange == nil)
        }*/
        if let password = self.txtFieldPassword.text{
            if textField == self.txtFldConfirmPassword,typpedString.count >= password.count{
                if string.isEmpty{
                    return true
                }else if self.txtFieldPassword.text != typpedString {
                 //Your passwords do not match
                 SAAlertBar.show(.error, message:"Your passwords do not match".localizedLowercase)
                    //SAAlertBar.show(.error, message:"Password and confirm password should be same".localizedLowercase)
                    return true
                }
            }
        }
        if  textField == self.txtCity || textField == self.txtState{
            do {
                                let regex = try NSRegularExpression(pattern: ".*[^A-Za-z\\s].*", options: [])
                                if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
                                    return false
                                }
                            }
                            catch {
                                print("ERROR")
                            }
                        return true
        }
//        if(textField == self.txtFieldPassword && !self.txtFieldPassword.isSecureTextEntry) {
//            self.txtFieldPassword.isSecureTextEntry = true
//        }
//        if(textField == self.txtFldConfirmPassword && !self.txtFldConfirmPassword.isSecureTextEntry) {
//            self.txtFldConfirmPassword.isSecureTextEntry = true
//        }
        
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtFieldPassword || textField == self.txtFldConfirmPassword{
           if let text = textField.text{
               if !self.isValidPassword(testStr: text){
                          SAAlertBar.show(.error, message:"Password must have a minimum of 8 characters with at least one number and one special character.".localizedLowercase)
                                 return true
                      }
           }
        }
           return true
       }
  
}


//MARkK: Textfield Extension for MaxLength
private var __maxLengths = [UITextField: Int]()
extension String{
    func hasSpecialCharacters() -> Bool {

          do {
              let regex = try NSRegularExpression(pattern: ".*[^ A-Za-z0-9].*", options: .caseInsensitive)
              if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.count)) {
                  return true
              }

          } catch {
              debugPrint(error.localizedDescription)
              return false
          }

          return false
      }
}
extension UITextField {
    
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix( textField: UITextField) {
        let t = textField.text
        textField.text = String(t!.prefix(maxLength))
    }
}
extension RegistrationVC:OTPVerificationDelegate{
    func otpSuccessFullVerificationDelegate(customerData: [String : Any]) {
        //Sign Up Flow Update
        if self.isForBusiness{
            self.pushToCreateBusinessScreen()
        }else{
            //PopToLogin Screen 07/01/21
             //self.navigationController?.popViewController(animated: true)
            //push to help screen 23/03/21
            //self.pushToHelpViewController()
            self.presentCustomerHelpViewController()
        }
    }
}
extension RegistrationVC:PhoneEmailDelegate{
    func smsEmailVerifiedDelegate(isTextOptionSelection: Bool, customerData: [String : Any], strText: String) {
        if isTextOptionSelection{
            self.presentOTPVerificationScreen(strText: strText, customerDetail: customerData)
        }else{
            if self.isForBusiness{
                if let  objID = customerData["id"]{
                    self.pushToCreateBusinessScreen(userID: "\(objID)")
                }
            }else{
                let alert = UIAlertController(title: AppName, message: "\(strText)", preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                        if self.isFromDynamicLink{
                            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
                            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                            let navigationController = UINavigationController(rootViewController:loginVC)
                            if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first{
                                window.rootViewController = navigationController
                                    window.makeKeyAndVisible()
                            }
                            //UIApplication.shared.keyWindow?.rootViewController? = navigationController
                            //UIApplication.shared.keyWindow?.makeKeyAndVisible()
                        }else{
                            self.navigationController?.popViewController(animated: true)
                        }
                 }))
                alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
