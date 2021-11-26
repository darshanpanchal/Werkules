//
//  LoginVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 26/07/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

import FacebookLogin
import GoogleSignIn
import FacebookCore
import AuthenticationServices


let kisFirstTimeLoginInDevice = "isFirstTimeLoginInDevice" //to update group work flow if user logged in then move to login screen or move to create profile screen
let kUserEmailPassword = "UserEmailPassword"

class LoginVC: UIViewController,CLLocationManagerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var txtFieldPhoneOrEmail:UITextField!
    @IBOutlet weak var txtFieldPassword:UITextField!
    @IBOutlet weak var viewTextEmailContainer:UIView!
    @IBOutlet weak var viewTextPasswordContainer:UIView!
    
    
    @IBOutlet weak var loginShadowContainer:ShadowView!
    @IBOutlet weak var loginContainerView:UIView!
    
    @IBOutlet weak var googleSignInButton:GIDSignInButton!
    @IBOutlet weak var buttonPasswordEye:UIButton!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var lat = String()
    var lng = String()
    var window: UIWindow?
    
    var strReferealCode = ""
    
    let deaultEmail = "priyanka08@gmail.com"//"darshanp@mail.com" // "harshadp.itpathsolutions@gmail.com"
    let deaultPassword = "12345678"//"ips12345"
    
    var passwordHide:Bool = true
    var isPassWordHide:Bool{
        get{
            return passwordHide
        }
        set{
            passwordHide = newValue
            //ConigureHide Password
            self.hideShowPasswordText()
        }
    }
    var isSocialMediaLogin:Bool = false
    var socialMediaParameters:SocialMediaObject?
    
    @IBOutlet weak var imageEmail:UIImageView!
    @IBOutlet weak var imagePassword:UIImageView!
    
    //MARK: - UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.loginShadowContainer.layer.cornerRadius = 10.0
        self.loginContainerView.layer.cornerRadius = 10.0
        self.loginContainerView.clipsToBounds = true
        
        self.txtFieldPhoneOrEmail.text = UserSettings.emailText
        self.navigationController?.navigationBar.isHidden = true
//        mylocation()
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
//        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        //
       
        self.txtFieldPhoneOrEmail.delegate = self
        self.txtFieldPassword.delegate = self
        
        if let _ = self.imageEmail{
            self.imageEmail.image = self.imageEmail.image?.withRenderingMode(.alwaysTemplate)
            self.imageEmail.tintColor = UIColor.lightGray
            
        }
        if let _ = self.imagePassword{
            self.imagePassword.image = self.imagePassword.image?.withRenderingMode(.alwaysTemplate)
            self.imagePassword.tintColor = UIColor.lightGray
        }
        
        //Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: .userLoginreferelcode, object: nil)
    }
    @objc func methodOfReceivedNotification(notification: Notification) {
        DispatchQueue.main.async {
            //Push to  Customer Sign up
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "createAccountSegue", sender: nil)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
//            self.txtFieldPhoneOrEmail.setPlaceHolderColor()
//            self.txtFieldPassword.setPlaceHolderColor()
            
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        if textField == self.txtFieldPhoneOrEmail{
            guard !typpedString.isContainWhiteSpace() else{
                return false
            }
            return typpedString.count < 255
        }
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
                textField.resignFirstResponder()

                if textField == self.txtFieldPhoneOrEmail{
                    self.txtFieldPassword.becomeFirstResponder()
                }else if textField == self.txtFieldPassword{
                    
                }
        }
        return true
    }
    func prefilledFields(){
        DispatchQueue.main.async {
            if let dict = kUserDefault.value(forKey: kUserEmailPassword) as? [String:String]{
                if let email = dict[APIManager.Parameter.email]{
                    self.txtFieldPhoneOrEmail.text = email
                }
                if let password = dict[APIManager.Parameter.password]{
                    self.txtFieldPassword.text = password
                }
            }else { //empty key user login first time open help
                if CommonClass.isSimulator{
                    self.txtFieldPhoneOrEmail.text = self.deaultEmail
                    self.txtFieldPassword.text = self.deaultPassword
                }
            }
        }
    }
    func hideShowPasswordText(){
        DispatchQueue.main.async {
            self.txtFieldPassword.isSecureTextEntry = self.isPassWordHide
            //"show" "hide"
            let objImage = self.isPassWordHide ?  UIImage.init(named: "hide") : UIImage.init(named: "show")
            
            self.buttonPasswordEye.setImage(objImage, for: .normal)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let registrationdone = UserDefaults.standard.bool(forKey: "RegistrationDone")
        if registrationdone == true {
            UserDefaults.standard.set(false, forKey: "RegistrationDone")
            
            self.dismiss(animated: true, completion: nil)
        }
        //SetUp Methods
        self.setupLoginView()
        //
        self.prefilledFields()
    }
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          self.locationManager.stopUpdatingLocation()
         
      }
    //MARK: - Setup Methods
    func setupLoginView(){
        // self.viewTextEmailContainer.layer.borderColor = UIColor.black.cgColor
        //self.viewTextEmailContainer.layer.borderWidth = 0.7
        
        //self.viewTextPasswordContainer.layer.borderColor = UIColor.black.cgColor
        //self.viewTextPasswordContainer.layer.borderWidth = 0.7
        
    }
    
    //MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latestLocation: AnyObject = locations[locations.count - 1]
        let mystartLocation = latestLocation as! CLLocation;
        
        self.lat = String(mystartLocation.coordinate.latitude)
        self.lng =  String(mystartLocation.coordinate.longitude)
        
    }
    
    //MARK: - SELECTOR METHODS
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonPasswordShowHide(sender:UIButton){
        self.isPassWordHide = !self.isPassWordHide
    }
    @IBAction func btnForgotPasswordClicked(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "forgotPasswordSegue", sender: self)
    }
    //Apple Login
    @IBAction func buttonAppleLogin(sender:UIButton){
        self.handleAppleIdRequest()
    }
    @objc func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    @IBAction func buttonGoogleSignIn(_ sender:UIButton){
        
        DispatchQueue.main.async {
//            GIDSignIn.sharedInstance()?.scopes =  ["https://googleapis.com/auth/userinfo.email"]
            
            
//            GIDSignIn.sharedInstance()?.presentingViewController = self
            
            GIDSignIn.sharedInstance()?.signIn()
        }
        

    }
    @IBAction func buttonFaceBookLogin(_ sender:UIButton){
//            UserDefaults.standard.removeObject(forKey: "email")
//            UserDefaults.standard.removeObject(forKey: "password")

        FaceBookLogIn.basicInfoWithCompletionHandler(self) { (result, error) in
                   guard error == nil else{
                     SAAlertBar.show(.error, message: "\(error!.localizedDescription)")
                       return
                   }
                   if let faceBookResponse = result{
                    var name = "", firstname = "", lastname = "", profileURL = "",email = "", id :String = ""
                            if let fbName = faceBookResponse["name"]{
                                name = "\(fbName)"
                            }
                            if let fbfirst_name = faceBookResponse["first_name"]{
                                firstname = "\(fbfirst_name)"
                            }
                            if let fblast_name = faceBookResponse["last_name"]{
                                lastname = "\(fblast_name)"
                            }
                            if let fbemail = faceBookResponse["email"]{
                                email = "\(fbemail)"
                            }
                            if let fbid = faceBookResponse["id"]{
                                id = "\(fbid)"
                            }
                            if let fbPicture = faceBookResponse["picture"] as? [String:Any],let imgData = fbPicture["data"] as? [String:Any],let url = imgData["url"]{
                                profileURL = "\(url)"
                            }
                    let objSocialMedia  = SocialMediaObject.init(name: name, firstname: firstname, lastname: lastname, email:email , id: id,type: "facebook", profileURL: profileURL, quickblox_id: "")
    
                    if let socialProviderAccessToken = AccessToken.current?.tokenString {
                        let socialProvider = "facebook"
                        self.callFacebookLoginAPIWithFaceBookParameters(objSocialMedia: objSocialMedia, isFacebook: true, quickbloxuser_id:"")
                        /*
                        QBRequest.logIn(withSocialProvider: socialProvider, accessToken: socialProviderAccessToken, accessTokenSecret: nil, successBlock: { (response, user) in
                            self.socialMediaParameters?.quickblox_id = String(user.id)
                            
                         
                        }, errorBlock: { (response) in
                            //Block with response instance if the request is failed.
                             print(response)
                        })*/
                    }
                    
                   }
               }
 
    }
    //MARK:- API REQUEST
    func callFacebookLoginAPIWithFaceBookParameters(objSocialMedia:SocialMediaObject,isFacebook:Bool,quickbloxuser_id: String){
        self.socialMediaParameters = objSocialMedia
        //self.socialMediaParameters?.quickblox_id = quickbloxuser_id
        var deviceToken = String()
        if isKeyPresentInUserDefaults(key: "fcmToken") {
            deviceToken = UserDefaults.standard.object(forKey: "fcmToken") as! String
        }else{
            deviceToken = ""
        }
       
        var dict = [
                   APIManager.Parameter.authId : "\(objSocialMedia.id)",
                   APIManager.Parameter.deviceToken : deviceToken,
                   APIManager.Parameter.platform : "ios",
                   APIManager.Parameter.loginType : "\(objSocialMedia.type)"//isFacebook ? "facebook" : "google"
               ]
        //For Apple Login Only Will Pass First Name Last Name Email and UserName
        if "\(objSocialMedia.type)" == "apple"{
            dict["firstname"] = "\(objSocialMedia.firstname)"
            dict["lastname"] = "\(objSocialMedia.lastname)"
            dict["username"] = "\(objSocialMedia.firstname)\(objSocialMedia.lastname)"
            dict["email"] = "\(objSocialMedia.email)"
        }
        print(dict)
        

        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSocialLogIn , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                ExternalClass.HideProgress()
                    }
            
         if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
            //if first time then redirect to register
            kUserDefault.setValue(true, forKey:kisFirstTimeLoginInDevice)
            kUserDefault.synchronize()
            if var _ = self.socialMediaParameters,let customerData = userInfo["customer_data"] as? [String:Any], let userid = customerData["id"]{
                        self.socialMediaParameters!.id = "\(userid)"
    
                if let isUserFirstTime = customerData["is_customer_data"],let isUserdata = "\(isUserFirstTime)".bool{
                        
                    if !isUserdata{ //first time sign up
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "createAccountSegue", sender: nil)
                        }
                    }else {
                        //if already login then redirect to home
                            DispatchQueue.main.async {
                                if let customerData = userInfo["customer_data"] as? [String:Any]{
                                    let objUser:UserDetail = UserDetail.init(userDetail: customerData)
                                    if let providerDetail = userInfo["provider_data"] as? [String:Any]{
                                        let objprovider:BusinessDetail = BusinessDetail.init(businessDetail: providerDetail)
                                        objUser.businessDetail = objprovider
                                    }
                                    objUser.setuserDetailToUserDefault()
                                }
                               
                                
                                NotificationCenter.default.post(name: Notification.Name("UserSignInOutNotification"), object: nil)
                                if UserDetail.isUserLoggedIn{
                                           self.callClearKeywordAPIRequest()
                                       }
                                
                                 if self.parent == nil {
                                     self.dismiss(animated: true, completion:nil)
                                 }else{
                                     let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                     let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                                     let navigationController = UINavigationController(rootViewController:VC)
                                     let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                     appDelegate.window?.rootViewController = navigationController
                                 }
                                        
                            }
                    }
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
                // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
             }
         }
        }
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    
    
    @IBAction func action_create_account(_ sender: Any) {
       
    
    }
    
    @IBAction func btnLoginClicked(_ sender: UIButton) {
        guard self.validateData() else {
            return
        }
        
        /*
        if !validateData() {
            SAAlertBar.show(.error, message: "please enter valid data")
            return
        }*/
        var deviceToken = String()
        
        if isKeyPresentInUserDefaults(key: "fcmToken") {
            deviceToken = UserDefaults.standard.object(forKey: "fcmToken") as! String
        }else{
            deviceToken = "12344"
        }
        print(deviceToken)
        
        let dict = [
            APIManager.Parameter.email : txtFieldPhoneOrEmail.text!.lowercased(),
            APIManager.Parameter.password : txtFieldPassword.text!,
            APIManager.Parameter.deviceToken : deviceToken,
            APIManager.Parameter.platform : "ios",
            APIManager.Parameter.latitude : self.lat,
            APIManager.Parameter.longitude : self.lng
        ]
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kLogin , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
                        
            
            
            if let success = responseSuccess as? [String:Any]{
                
            if let userInfo = success["success_data"] as? [String:Any]{
                DispatchQueue.main.async {
                    kUserDefault.setValue(true, forKey:kisFirstTimeLoginInDevice)
                     kUserDefault.set(dict, forKey: kUserEmailPassword)
                     kUserDefault.synchronize()
                    if let customerData = userInfo["customer_data"] as? [String:Any]{
                        let objUser:UserDetail = UserDetail.init(userDetail: customerData)
                        UserDefaults.standard.set(self.txtFieldPassword.text, forKey: "UserPassword")
                        if let providerDetail = userInfo["provider_data"] as? [String:Any]{
                            let objprovider:BusinessDetail = BusinessDetail.init(businessDetail: providerDetail)
                            objUser.businessDetail = objprovider
                        }
                        objUser.setuserDetailToUserDefault()
                    }
                   
                    NotificationCenter.default.post(name: Notification.Name("UserSignInOutNotification"), object: nil)
                     if self.parent == nil {
                         self.dismiss(animated: true, completion:nil)
                     }else{
                        //Help
                        
                        if let user = UserDetail.getUserFromUserDefault(){
                            if let strMessage = success["success_message"],"\(strMessage)".count > 0 {
                                
                                if let strName = success["screen_name"]{
                                    if "\(strName)" == "verify_email"{
                                        let alert = UIAlertController(title: AppName, message: "\(strMessage)", preferredStyle: .alert)
                                         
                                         alert.addAction(UIAlertAction(title: "Resend Email", style: .default, handler: { action in
                                            
                                            //self.pushToBankListViewController()
                                            self.callResendEmailAPIRequest(email:  self.txtFieldPhoneOrEmail.text!.lowercased())
                                         }))
                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                            
                                        }))
                                        alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    }else if "\(strName)" == "bank_list"{
                                        let alert = UIAlertController(title: AppName, message: "\(strMessage)", preferredStyle: .alert)
                                         
                                         alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                                            
                                            //self.pushToCustomerHomeViewController()
                                            self.pushToBankListViewController()
                                            
                                         }))
                                        alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                                        self.present(alert, animated: true, completion: nil)
                                    }else{
                                        
                                    }
                                }
                            }else if user.isFirstTimeLogin{
                                if let providerdetail = user.businessDetail{
                                    if providerdetail.status == "approved"{
                                        self.pushToCustomerHelpViewController()
                                    }else{
                                        self.pushToHelpViewController()
                                    }
                                }else{
                                    self.pushToHelpViewController()
                                }
                            } else {
                                self.pushToCustomerHomeViewController()
                            }
                        }
                     }
                            
                }
            }else if let strMessage = success["success_message"],"\(strMessage)".count > 0 {
                DispatchQueue.main.async {
                    if let strName = success["screen_name"]{
                        if "\(strName)" == "verify_email"{
                            let alert = UIAlertController(title: AppName, message: "\(strMessage)", preferredStyle: .alert)
                             
                             alert.addAction(UIAlertAction(title: "Resend Email", style: .default, handler: { action in
                                
                                //self.pushToBankListViewController()
                                self.callResendEmailAPIRequest(email:  self.txtFieldPhoneOrEmail.text!.lowercased())
                             }))
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                
                            }))
                            alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                            self.present(alert, animated: true, completion: nil)
                            
                        }else if "\(strName)" == "bank_list"{
                            let alert = UIAlertController(title: AppName, message: "\(strMessage)", preferredStyle: .alert)
                             
                             alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                                
                                //self.pushToCustomerHomeViewController()
                                self.pushToBankListViewController()
                                
                             }))
                            alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                            self.present(alert, animated: true, completion: nil)
                            
                        }else{
                            
                        }
                    }
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
                 //   SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
        print(dict)
        /*
        APIManager.sharedInstance.CallAPI(url: Url_Login, parameter: dict as JSONDICTIONARY) { [self] Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as? Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                let userData = dataDict["data"] as! JSONDICTIONARY
                
                let userIDNumber = userData["id"] as! NSNumber
                
                let userId:String = String(format:"%d", userIDNumber.intValue)
                var firstName = userData["firstname"] as? String
                var lastname = userData["lastname"] as? String
                
                UserSettings.userID = userId
                UserSettings.emailText = self.txtFieldPhoneOrEmail.text!
                UserSettings.PasswordText = self.txtFieldPassword.text!
                UserSettings.isUserLogin = true
                
                Analytics.logEvent(NSLocalizedString("login_successful", comment: ""), parameters: [NSLocalizedString("user_name", comment: ""): (UserSettings.emailText) as NSObject])
                let login = "\(firstName ?? "" )\(lastname ?? "")"
                 // QuickBlox User Set up
                QBRequest.logIn(withUserLogin:login,
                                password: self.txtFieldPassword.text ?? "",
                                successBlock: { [weak self] response, user in

                                    user.password = UserSettings.PasswordText
                                    user.updatedAt = Date()
                                    Profile.synchronize(user)
                                    self!.connectToChat(user: user)
                                    
                                    
                    }, errorBlock: { [weak self] response in
//                        self?.handleError(response.error?.error, domain: ErrorDomain.logIn)
                        if response.status == QBResponseStatusCode.unAuthorized {
                            // Clean profile
                            Profile.clearProfile()
                           // self?.defaultConfiguration()
                        }
                })
        
                
                var mediaArray = NSMutableArray()
                mediaArray = NSMutableArray.init()
                for index in 1...6 {
                    let fileName = "file" + String(index)
                    
                    let filePath = userData[fileName] as! String
                    if filePath.count != 0 {
                        mediaArray.add(filePath)
                    }
                }
                
                CurrentUserModel.Shared.JsonParseFromDict(userData)
                CurrentUserModel.Shared.mediaArray = mediaArray
                
                NotificationCenter.default.post(name: Notification.Name("UserSignInOutNotification"), object: nil)
                if self.parent == nil {
                    self.dismiss(animated: true, completion:nil)
                }else{

                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    let navigationController = UINavigationController(rootViewController:VC)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = navigationController
                }
               
               
            }
            else{
                if let message = JSONDICTIONARY!["response"] as? String{
                    SAAlertBar.show(.error, message:message.capitalized)
                }
                
                
            }
        }*/
    }
    func callResendEmailAPIRequest(email:String){
        var dict:[String:Any] = [:]
        dict["email"] = "\(email)"
        UserDetail.removeUserFromUserDefault()
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCustomerVerifyEmail , parameter: dict  as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_message"]  as? String{
                                  DispatchQueue.main.async {
                                    let alert = UIAlertController(title: AppName, message: "\(arrayOfJOB)", preferredStyle: .alert)
                                     
                                     alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                                        
                                        
                                     }))
                                    alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                                    self.present(alert, animated: true, completion: nil)
                                      
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
    func pushToBankListViewController(){
        DispatchQueue.main.async {
            if let bankListViewCoontroller = UIStoryboard.activity.instantiateViewController(withIdentifier: "BankListViewController") as? BankListViewController{
                self.view.endEditing(true)
                bankListViewCoontroller.delegate = self
                self.navigationController?.pushViewController(bankListViewCoontroller, animated: true)
            }
        }
    }
    
    func pushToCustomerHomeViewController(){
        if UserDetail.isUserLoggedIn{
            self.callClearKeywordAPIRequest()
        }
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
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            let navigationController = UINavigationController(rootViewController:VC)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = navigationController
        }
       
    }
    func callClearKeywordAPIRequest(){
                APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kClearKeyword , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                    
                    if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [String]{
                                          DispatchQueue.main.async {
                                              if arrayOfJOB.count > 0{
                                                  //SAAlertBar.show(.error, message:"\(arrayOfJOB.first!)".localizedLowercase)
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
                                      // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                   }
                               }
                           }
    }
    func pushToHelpViewController(isApprovedProvider:Bool = false){
        self.presentCustomerHelpViewController(isProviderVerified: isApprovedProvider)
        /*
        if let helpViewController = self.storyboard?.instantiateViewController(withIdentifier: "HelpViewController") as? HelpViewController{
            helpViewController.isForVerifiedProvider = isApprovedProvider
            self.navigationController?.pushViewController(helpViewController, animated: true)
        }*/
      
    }
    func presentCustomerHelpViewController(isProviderVerified:Bool){
        if let customerHelp = UIStoryboard.profile.instantiateViewController(withIdentifier: "CustomerProviderHelpVideoViewController") as? CustomerProviderHelpVideoViewController{
            customerHelp.modalPresentationStyle = .fullScreen
            customerHelp.delegate = self
            customerHelp.isForCustomer = true
            customerHelp.isProviderVerified = isProviderVerified
            self.navigationController?.present(customerHelp, animated: true, completion: nil)
        }
    }
    func presentProviderHelpViewController(){
        if let customerHelp = UIStoryboard.profile.instantiateViewController(withIdentifier: "CustomerProviderHelpVideoViewController") as? CustomerProviderHelpVideoViewController{
            customerHelp.modalPresentationStyle = .fullScreen
            customerHelp.delegate = self
            customerHelp.isForCustomer = false
            customerHelp.isProviderVerified = false
            self.navigationController?.present(customerHelp, animated: true, completion: nil)
        }
    }
    func pushToCustomerHelpViewController(){
        self.presentCustomerHelpViewController(isProviderVerified: true)

        /*
        if let helpViewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomerHelpViewController") as? CustomerHelpViewController{
            helpViewController.isForVerifiedProvider = true
            self.navigationController?.pushViewController(helpViewController, animated: true)
        }*/
      
    }
    
    // MARK:- User Defined Methods
    
    private func validateData() -> Bool {
        
        guard let email = self.txtFieldPhoneOrEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines),email.count > 0 else{
                     SAAlertBar.show(.error, message:"Please enter your email to login".localizedLowercase)
                      return false
             }
       guard let phone = self.txtFieldPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines),phone.count > 0 else{
                     SAAlertBar.show(.error, message:"Please enter your password to login")
                     return false
                }
        if !self.isValidEmail(testStr: txtFieldPhoneOrEmail.text!){
                   SAAlertBar.show(.error, message:"Please enter valid email".localizedLowercase)
                   return false
               }
        
//        if !self.isValidPassword(testStr: phone){
//                   SAAlertBar.show(.error, message:"for password minimum 8 characters & must contain one number and one special character".localizedLowercase)
//                   return false
//        }
        
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

    // MARK:- Redirection Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "createAccountSegue" {
            if let regsiterViewController = segue.destination as? RegistrationVC{
                regsiterViewController.strReferealCode = self.strReferealCode
                if let objSocial = self.socialMediaParameters{
                    regsiterViewController.objSocialMedia = objSocial
                }
                
            }
        }else if segue.identifier == "forgotPasswordSegue"{
            if let forgotPasswordViewController = segue.destination as? ForgotPasswordOTPVC{
                if let objEnteredEmail = self.txtFieldPhoneOrEmail.text{
                    forgotPasswordViewController.email = objEnteredEmail
                }
            }
        }
    }
}

struct LoginConstant {
    static let notSatisfyingDeviceToken = "Invalid parameter not satisfying: deviceToken != nil"
    static let enterToChat = NSLocalizedString("Enter to Video Chat", comment: "")
    static let fullNameDidChange = NSLocalizedString("Full Name Did Change", comment: "")
    static let login = NSLocalizedString("Login", comment: "")
    static let checkInternet = NSLocalizedString("Please check your Internet connection", comment: "")
    static let enterUsername = NSLocalizedString("Please enter your login and Display Name.", comment: "")
    static let shouldContainAlphanumeric = NSLocalizedString("Field should contain alphanumeric characters only in a range 3 to 20. The first character must be a letter.", comment: "")
    static let shouldContainAlphanumericWithoutSpace = NSLocalizedString("Field should contain alphanumeric characters only in a range 8 to 15, without space. The first character must be a letter.", comment: "")
    static let showUsers = "ShowUsersViewController"
    static let defaultPassword = "quickblox"
    static let infoSegue = "ShowInfoScreen"
    static let chatServiceDomain = "com.q-municate.chatservice"
    static let errorDomaimCode = -1000
}
class RoundButton:UIButton{
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = self.bounds.size.height/2
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        
    }
}
//MARK: APPLE LOGIN DELEGATE
extension LoginVC : ASAuthorizationControllerDelegate{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
        let userIdentifier = appleIDCredential.user
            var appleuserName = ""
            var applefirstname = ""
            var applelastname = ""
            var appleEmail = ""
            if let _ = kUserDefault.value(forKey: kAppleUserName){
                appleuserName = "\(kUserDefault.value(forKey: kAppleUserName) ?? "")"
                applefirstname = "\(kUserDefault.value(forKey: kAppleFirstName) ?? "")"
                applelastname = "\(kUserDefault.value(forKey: kAppleLastName) ?? "")"
                appleEmail = "\(kUserDefault.value(forKey: kAppleEmail) ?? "")"
            }else{
                appleuserName = "\(appleIDCredential.fullName?.givenName ?? "") \(appleIDCredential.fullName?.familyName ?? "")"
                kUserDefault.setValue("\(appleuserName)", forKey: kAppleUserName)
                applefirstname = "\(appleIDCredential.fullName?.givenName ?? "")"
                kUserDefault.setValue("\(applefirstname)", forKey: kAppleFirstName)
                applelastname = "\(appleIDCredential.fullName?.familyName ?? "")"
                kUserDefault.setValue("\(applelastname)", forKey: kAppleLastName)
                appleEmail = "\(appleIDCredential.email ?? "")"
                kUserDefault.setValue("\(appleEmail)", forKey: kAppleEmail)
                
               
            }
            
            let objSocialMedia = SocialMediaObject.init(name: "\(appleuserName)", firstname: "\(applefirstname)", lastname: "\(applelastname)", email: "\(appleEmail)", id: "\(userIdentifier)", type: "apple", profileURL: "", quickblox_id: "")
            //Save User Apple Login To User Default
            
            self.callFacebookLoginAPIWithFaceBookParameters(objSocialMedia: objSocialMedia, isFacebook: false, quickbloxuser_id: "")
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
        DispatchQueue.main.async {
            //SAAlertBar.show(.error, message: "\(error.localizedDescription)")
        }
    }

}
extension LoginVC:CustomerProviderHelpDelegate{
    func playerDidFinishWithPlay(isforcustomer: Bool, isForVerifiedProvider: Bool) {
        if isforcustomer && isForVerifiedProvider{
            self.presentProviderHelpViewController()
        }else{
            self.pushToCustomerHomeViewController()
        }
    }
}
//MARK: GOOGLE LOGIN DELEGATE
extension LoginVC : GIDSignInDelegate, BankListViewDelegate{
    func bankDetailBackDelegate() {
        self.pushToCustomerHomeViewController()
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
          // Perform any operations on signed in user here.
            if let googleAuthId = user.userID{
                
            var name = "", firstname = "", lastname = "", profileURL = "",email = "", id :String = ""

                name = user.profile.name
                firstname = user.profile.givenName
                lastname = user.profile.familyName
                email = user.profile.email
                profileURL = user.profile.imageURL(withDimension: 200)?.absoluteString ?? ""
                id = googleAuthId
           
                let objSocialMedia  = SocialMediaObject.init(name: name, firstname: firstname, lastname: lastname, email:email , id: id,type:"google", profileURL: profileURL, quickblox_id: "")
                self.callFacebookLoginAPIWithFaceBookParameters(objSocialMedia: objSocialMedia, isFacebook: false, quickbloxuser_id: "")
                /*
                if let accesstokenStr = AccessToken.current?.tokenString{
                  //self.signUp(fullname: objSocialMedia.name, email: objSocialMedia.email, login: accesstokenStr ,password: "quickblox")
                }*/
            }
            
        } else {
            print("\(error.localizedDescription)")
        }
//        let userId = user.userID                  // For client-side use only!
//        let idToken = user.authentication.idToken // Safe to send to the server
//        let fullName = user.profile.name
//        let givenName = user.profile.givenName
//        let familyName = user.profile.familyName
//        let email = user.profile.email
        
        
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
      // Perform any operations when the user disconnects from app here.
      // ...
    }
    
    
}
struct SocialMediaObject {
       var name , firstname, lastname, email, id, type, profileURL,quickblox_id: String
}
