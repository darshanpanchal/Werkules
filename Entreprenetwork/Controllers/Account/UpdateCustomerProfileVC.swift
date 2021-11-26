//
//  UpdateCustomerProfileVC.swift
//  Entreprenetwork
//
//  Created by IPS on 27/01/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import SKCountryPicker
import CoreLocation
import Firebase
import Fusuma
import YPImagePicker

import CropViewController
import MobileCoreServices



class UpdateCustomerProfileVC: UIViewController,CLLocationManagerDelegate,FusumaDelegate,UITextFieldDelegate, UITextViewDelegate {
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
       @IBOutlet weak var btnCountryCode: UIButton!
       @IBOutlet weak var btnEye: UIButton!
       
       
       @IBOutlet weak var txtCity:UITextField!
       @IBOutlet weak var txtState:UITextField!
       @IBOutlet weak var txtZipCode:UITextField!
       @IBOutlet weak var txtGroupReferralCode:UITextField!
    
       @IBOutlet weak var lblTermsAndPrivacy:UILabel!
       @IBOutlet weak var btnBusinessSelector:UIButton!
       
       @IBOutlet weak var stackViewCity:UIStackView!
       @IBOutlet weak var stackViewState:UIStackView!
       @IBOutlet weak var stackViewZipCode:UIStackView!
       @IBOutlet weak var lblAddress:UILabel!
       @IBOutlet weak var btnNext:UIButton!
       @IBOutlet weak var tableViewRegister:UITableView!
       
       
       @IBOutlet weak var stackViewPassword:UIStackView!
       @IBOutlet weak var stackViewConfirmPassword:UIStackView!
       
       @IBOutlet weak var buttonOne:UIButton!
       @IBOutlet weak var buttonTwo:UIButton!
       
       @IBOutlet weak var lblSeparatedLine:UILabel!
       @IBOutlet weak var lblBusinessInformation:UILabel!
        
       @IBOutlet weak var buttonSetupBusiness:UIButton!
    
        @IBOutlet weak var viewGroupReferalCode:UIView!
    
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

       
       var objSocialMedia:SocialMediaObject?
       var isforFacebook:Bool?
    
    var objImagePickerController = UIImagePickerController()
    var imageForCrop: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtFieldEmail.delegate = self
        
        self.txtCity.keyboardType = .alphabet
        self.txtState.keyboardType = .alphabet
        self.txtCity.autocapitalizationType = .words
        self.txtState.autocapitalizationType = .words
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                                   return
            
        }
        if let _ = currentUser.businessDetail{
            self.buttonSetupBusiness.isHidden = true
           }else{
            self.buttonSetupBusiness.isHidden = false
           }
        
        
         initialize()
        //setup methods
        self.setup()
        
        // Do any additional setup after loading the view.
        //GET Customer profile api request
        self.getCurrentUserDetailsAsCustomerRequest()
        self.showHideCityStateZipCode(hide: true)
    }
    func showHideCityStateZipCode(hide:Bool){
        self.stackViewCity.isHidden = hide
        self.stackViewState.isHidden = hide
        self.stackViewZipCode.isHidden = hide
        
        if hide{
            self.sizeHeaderFit()
        }
        
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
    private func initialize() {
           scrView.isHidden = false
           /*guard let country = CountryManager.shared.currentCountry else {
               self.btnCountryCode.setTitle("Pick Country", for: .normal)
               return
           }*/
           self.customerSignUpParameters["country_code"] = "+1"//"\(country.dialingCode)"
            self.btnCountryCode.setTitle("+1", for: .normal)
           btnCountryCode.clipsToBounds = true
           //disableAutoFill()
           mylocation()
           txtFieldPassword.delegate = self
           txtFldConfirmPassword.delegate = self
           
           //setup terms and conditions and privacy
           
           let mutableString = NSMutableAttributedString.init(string: "By signing up you accept the\n", attributes: self.attributesNormal)
           let mutableStringValue1 = NSMutableAttributedString.init(string: "Term of service ", attributes: self.attributesBold)
           let mutableStringValue2 = NSMutableAttributedString.init(string: "and", attributes: self.attributesNormal)
           let mutableStringValue3 = NSMutableAttributedString.init(string: " Privacy Policy", attributes: self.attributesBold)
           
           mutableString.append(mutableStringValue1)
           mutableString.append(mutableStringValue2)
           mutableString.append(mutableStringValue3)
           
           self.lblTermsAndPrivacy.attributedText = mutableString
           
           
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
    // MARK: - Setup Methods
    func setup(){
        self.btnUserProfilePic.imageView?.contentMode = .scaleAspectFill
        self.btnUserProfilePic.imageView?.clipsToBounds = true
        self.txtCity.delegate = self
        self.txtState.delegate = self 
        
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
        self.stackViewPassword.isHidden = true
        self.stackViewConfirmPassword.isHidden = true
    }
    private func validateData() -> Bool {
            
            
        
        
            guard let _ = self.customerProfileImageData else {
                SAAlertBar.show(.error, message:"Please select a profile picture".localizedLowercase)
                return false
            }
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
                 }
            
    //        if (txtfldUserName.text?.isEmpty)!{
    //            SAAlertBar.show(.error, message:"Please enter Username".localizedLowercase)
    //            return false
    //        } */
//            self.customerSignUpParameters["username"]  = "\(self.txtfldUserName.text ?? "")"
            
            guard let email = self.txtFieldEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines),email.count > 0 else{
                            SAAlertBar.show(.error, message:"Please enter email to register")
                            return false
                        }
            
    //        if (txtFieldEmail.text?.isEmpty)!{
    //            SAAlertBar.show(.error, message:"Please enter email".localizedLowercase)
    //            return false
    //        }
        
            self.customerSignUpParameters["email"]  = "\(self.txtFieldEmail.text ?? "")"
            
            if let currentUser = UserDetail.getUserFromUserDefault(){
                if currentUser.email != "\(email)"{
                    self.customerSignUpParameters["new_email"] = "\(email)"
                }
            }
        
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
        
            if let groupreferralcode = self.txtGroupReferralCode.text?.trimmingCharacters(in: .whitespacesAndNewlines),groupreferralcode.count > 0{
                if let currentUser = UserDetail.getUserFromUserDefault(){
                    if currentUser.groupReferralCode.count > 0{
                        
                    }else{
                        self.customerSignUpParameters["group_referral_code"] = "\(groupreferralcode)"
                    }
                }
                
            }
            
             self.customerSignUpParameters["platform"] = "ios"
//            var deviceToken = String()
//            if isKeyPresentInUserDefaults(key: "fcmToken") {
//                deviceToken = UserDefaults.standard.object(forKey: "fcmToken") as! String
//            }else{
//                deviceToken = ""
//            }
//            self.customerSignUpParameters["device_token"] = "\(deviceToken)"
            
          
     /*
            if let _ = self.objSocialMedia{
                self.customerSignUpParameters["login_type"] = "\(self.objSocialMedia!.type)"
                
            }else{
                  self.customerSignUpParameters["login_type"] = ""
                    guard let password = self.txtFieldPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines),password.count > 0 else{
                                               SAAlertBar.show(.error, message:"Please enter password")
                                               return false
                                           }
                
                        if !self.isValidPassword(testStr: password){
                                   SAAlertBar.show(.error, message:"for password minimum 8 characters & must contain one number and one special character".localizedLowercase)
                                   return false
                        }
                
                       self.customerSignUpParameters["password"]  = "\(self.txtFieldPassword.text ?? "")"
                
                       guard let confirmpassword = self.txtFldConfirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines),confirmpassword.count > 0 else{
                                                            SAAlertBar.show(.error, message:"Please enter confirm password")
                                                            return false
                                                        }
                
    //                   if (txtFldConfirmPassword.text?.isEmpty)!{
    //                       SAAlertBar.show(.error, message:"Please enter confirm password".localizedLowercase)
    //                       return false
    //                   }
                       
                       if txtFieldPassword.text != txtFldConfirmPassword.text {
                           SAAlertBar.show(.error, message:"Password and confirm password should be same".localizedLowercase)
                           return false
                       }
            } */
                   
            
            
           
            
            
            
            if !self.isValidEmail(testStr: txtFieldEmail.text!){
                SAAlertBar.show(.error, message:"Please enter valid email".localizedLowercase)
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
    // MARK: - Selector Methods
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
    @IBAction func btnSetupBusinessSelector(_ sender: UIButton) {
        self.pushToCreateBusinessScreen()
    }
    func pushToCreateBusinessScreen(){
           if let objBusinessprofile = self.storyboard?.instantiateViewController(withIdentifier: "CreateBusinssProfile") as? CreateBusinssProfile {
               self.navigationController?.pushViewController(objBusinessprofile, animated: true)
           }
       }
    
    @IBAction func buttonCameraInfoSelector(sender:UIButton){
        DispatchQueue.main.async {
            let cameraInfo = UIAlertController.init(title:AppName, message: kUserProfileHelp, preferredStyle: .alert)
            cameraInfo.addAction(UIAlertAction.init(title:"Ok", style: .cancel, handler: nil))
            cameraInfo.view.tintColor = UIColor.init(hex: "#38B5A3")
            self.present(cameraInfo, animated: true, completion: nil)
        }
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
            
        }
        // can customize the countryPicker here e.g font and color
        countryController.detailColor = UIColor.red
    }
    @IBAction func btnBackClicked(_ sender: UIButton) {
          self.navigationController?.popViewController(animated: true)
      }
    @IBAction func btnUpdateProfileSelector (sender:UIButton){
        if self.validateData(){
                if let email = self.txtFieldEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines),email.count > 0{
                    if let currentUser = UserDetail.getUserFromUserDefault(){
                                          if currentUser.email != "\(email)"{
                                              self.customerSignUpParameters["new_email"] = "\(email)"
                                               //present alert
                                                let alert = UIAlertController(title: "Update Email", message: "A confirmation will be sent to your new email. You will be logged out of Werkules to confirm the change.\n Do you want to continue?", preferredStyle: .alert)
                                                
                                                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                                                    DispatchQueue.main.async {
                                                        self.customerSignUpParameters.removeValue(forKey: "new_email")
                                                        self.txtFieldEmail.text = "\(currentUser.email)"
                                                    }
                                                }))
                                                alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { action in
                                                    DispatchQueue.main.async {
                                                        self.updateCurrentUserProfileAPIRequest()
                                                    }
                                                }))
                                                alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                                                self.present(alert, animated: true, completion: nil)
                                            
                                          }else{
                                            self.updateCurrentUserProfileAPIRequest()
                                        }
                        }
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
       
    // MARK: - API Request Methods
    func getCurrentUserDetailsAsCustomerRequest(){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                   return
        }
        
        let dict = [
            APIManager.Parameter.userID : "\(currentUser.id)"
        ]
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCustomerDetails , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                      if let success = responseSuccess as? [String:Any],var userInfo = success["success_data"] as? [String:Any]{
                        if let customerData = userInfo["customer_data"] as? [String:Any]{
                            if let currentUser = UserDetail.getUserFromUserDefault(){
                                                                 userInfo["remember_token"] = currentUser.rememberToken
                                                                 let objUser = UserDetail.init(userDetail: customerData)
                                                                 objUser.setuserDetailToUserDefault()
                                                                 self.configureCurrentUserData()
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
    func configureCurrentUserData(){
               if let currentUser = UserDetail.getUserFromUserDefault(){
                   DispatchQueue.main.async {
                       self.stackViewPassword.isHidden = true
                       self.stackViewConfirmPassword.isHidden = true
                       self.txtFieldEmail.text = currentUser.email
                       self.txtfldUserName.text = currentUser.username
                       self.txtFieldFirstName.text = currentUser.firstname
                       self.txtFieldLastName.text = currentUser.lastname
                    
                       self.btnCountryCode.setTitle( currentUser.countryCode, for: .normal)
                       self.txtFieldPhoneNumber.text = currentUser.phone
                       self.txtFldAddress.text = currentUser.address
                       self.txtCity.text = currentUser.city
                       self.txtState.text = currentUser.state
                       self.txtZipCode.text = currentUser.zipcode
                        if currentUser.groupReferralCode.count > 0{
                            self.viewGroupReferalCode.backgroundColor = UIColor.lightGray
                            self.txtGroupReferralCode.isEnabled = false
                            self.txtGroupReferralCode.text = "You're in \(currentUser.groupName)'s group"//"\(currentUser.groupReferralCode)"
                        }else{
                            self.viewGroupReferalCode.backgroundColor = UIColor.clear
                            self.txtGroupReferralCode.isEnabled = true
                            self.txtGroupReferralCode.text = ""
                        }
                    if let objURL = URL.init(string: currentUser.profilePic){
                           
                        self.btnUserProfilePic.sd_setImage(with: objURL, for: .normal) { (image, error, catch, url) in
                            if let socialImage = image{
                                self.customerProfileImageData = socialImage.jpegData(compressionQuality: 0.5)
                                
                            }
                        }
                           /*self.btnUserProfilePic.sd_setBackgroundImage(with: objURL, for: .normal) { (image, error, catch, url) in
                               if let socialImage = image{
                                   self.customerProfileImageData = socialImage.jpegData(compressionQuality: 0.5)
                                   
                               }
                           }*/
                       }
                       
                       
                   }
               }
           }
    
    func popToLogInViewController(){
          let storyboard = UIStoryboard(name: "Profile", bundle: nil)
          let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
          let navigationController = UINavigationController(rootViewController:loginVC)
          let appDelegate = UIApplication.shared.delegate as! AppDelegate
          appDelegate.window?.rootViewController = navigationController
        if let root =  appDelegate.window?.rootViewController{
             UIAlertController.showOkAlert(root, aStrMessage: "Please confirm the change in the notification sent to the new email address you entered. If you do not acknowledge the update, you can login again using your existing credentials.", completion: nil)
        }
         
      }
    //Update User profile Request
    func updateCurrentUserProfileAPIRequest(){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                          return
               }
        self.customerSignUpParameters[APIManager.Parameter.userID] = "\(currentUser.id)"
        
        APIRequestClient.shared.uploadImage(requestType: .POST, queryString: kUpdateCustomerProfile, parameter: self.customerSignUpParameters as [String:AnyObject], imageData: self.customerProfileImageData, isFileUpload: false, isHudeShow: true , success: { (responseSuccess) in
            DispatchQueue.main.async {
                              ExternalClass.HideProgress()
                          }
            if let success = responseSuccess as? [String:Any],var userArrayInfo = success["success_data"] as? [String:Any],var userInfo =  userArrayInfo["customer_data"] as? [[String:Any]],userInfo.count > 0,var customerData = userInfo.first as? [String:Any]{
                             
                
                                     if let currentUser = UserDetail.getUserFromUserDefault(){
                                         customerData["remember_token"] = currentUser.rememberToken
                                         let objUser = UserDetail.init(userDetail: customerData)
                                         objUser.setuserDetailToUserDefault()
                                         self.configureCurrentUserData()
                                        DispatchQueue.main.async {
                                            if let newemail = self.customerSignUpParameters["new_email"]{
                                                if "\(newemail)".count > 0{
                                                    self.callLogoutAPI()
                                                  
                                                    //SAAlertBar.show(.error, message:"".localizedLowercase)
                                                }else{
                                                    if let successMessage = success["success_message"] as? [String]{
                                                        DispatchQueue.main.async {
                                                             if successMessage.count > 0{
                                                                 SAAlertBar.show(.error, message:"\(successMessage.first!)".localizedLowercase)
                                                             }
                                                         }
                                                    }
                                                    //SAAlertBar.show(.error, message:"Your customer profile is updated".localizedLowercase)
                                                    self.navigationController?.popViewController(animated: true)
                                                }
                                            }else{
                                                if let successMessage = success["success_message"] as? [String]{
                                                    DispatchQueue.main.async {
                                                         if successMessage.count > 0{
                                                             SAAlertBar.show(.error, message:"\(successMessage.first!)".localizedLowercase)
                                                         }
                                                     }
                                                }
                                                //SAAlertBar.show(.error, message:"Your customer profile is updated".localizedLowercase)
                                                self.navigationController?.popViewController(animated: true)
                                            }
                                            
                                        }
                                     }
                                 }else{
                                     DispatchQueue.main.async {
                                        // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
                                           // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                        }
                                    }
                                }
        }
        /*
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kUpdateCustomerProfile , parameter: self.customerSignUpParameters as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
               if let success = responseSuccess as? [String:Any],var userInfo = success["success_data"] as? [String:Any]{
                   
                           if let currentUser = UserDetail.getUserFromUserDefault(){
                               userInfo["remember_token"] = currentUser.rememberToken
                               let objUser = UserDetail.init(userDetail: userInfo)
                               objUser.setuserDetailToUserDefault()
                               self.configureCurrentUserData()
                           }
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
                       } */
        
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func callLogoutAPI() {
        
        
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kProviderCustomerLogout , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                 if let success = responseSuccess as? [String:Any],let successMessage = success["success_data"] as? [String]{
                                   
                                       DispatchQueue.main.async {
                                        if successMessage.count > 0{
                                            //SAAlertBar.show(.error, message:"\(successMessage.first!)".localizedLowercase)
                                        }
                                        DispatchQueue.main.async(execute: {
                                               UserDetail.removeUserFromUserDefault()
                                               self.popToLogInViewController()
                                               //self.navigationController?.popToRootViewController(animated: false)
                                           })
                                        
                                       }
                                        
                                      }else{
                                          DispatchQueue.main.async {
                                              //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
}
extension UpdateCustomerProfileVC{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
                    
//                    guard !typpedString.isContainWhiteSpace() else{
//                        return false
//                    }
        if textField == self.txtFieldEmail{
            guard !typpedString.isContainWhiteSpace() else{
                        return false
            }
            return typpedString.count < 255
        }
        if textField == self.txtCity || textField == self.txtState{
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
        /*else if textField == self.txtCity || textField == self.txtState{
            let numbersRange = typpedString.rangeOfCharacter(from: .decimalDigits)
            return !typpedString.hasSpecialCharacters() && (numbersRange == nil)
        }*/
//        if(textField == self.txtFieldPassword && !self.txtFieldPassword.isSecureTextEntry) {
//            self.txtFieldPassword.isSecureTextEntry = true
//        }
//        if(textField == self.txtFldConfirmPassword && !self.txtFldConfirmPassword.isSecureTextEntry) {
//            self.txtFldConfirmPassword.isSecureTextEntry = true
//        }
        
        return true
    }
  
}
extension UpdateCustomerProfileVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.btnUserProfilePic.setImage(image, for: .normal)
            //self.btnUserProfilePic.setBackgroundImage(image, for: .normal)//(UIImage.init(data: resizedImage), for: .normal)
            let resizedImage = self.resize(image)
            self.customerProfileImageData = resizedImage
        }
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
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.cropView.cropBoxResizeEnabled = false
        self.present(cropViewController, animated: true, completion: nil)
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
}
