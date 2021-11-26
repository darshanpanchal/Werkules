//
//  HomeVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 24/07/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GooglePlaces
import Firebase
import GoogleMaps
import Quickblox
import QuickbloxWebRTC

class HomeVC: BaseViewController,MKMapViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,CLLocationManagerDelegate,GMSAutocompleteViewControllerDelegate,UITextFieldDelegate,UIScrollViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionObj:UICollectionView!
    
    @IBOutlet weak var keywordSearchColllectionView:UICollectionView!
    
    @IBOutlet weak var viewCollectionViewContainer:UIView!
    @IBOutlet weak var lblNoJobExists: UILabel!
    @IBOutlet weak var segmentMapType: UISegmentedControl!
    
    @IBOutlet weak var objGoogleMap:GMSMapView!
    
    @IBOutlet weak var txtSearch:UITextField!
    @IBOutlet weak var lblTitle:UILabel!
    
    
    @IBOutlet weak var bottomConstaintTile:NSLayoutConstraint!
    
    var regionRadius = CLLocationDistance()
    var locationManager: CLLocationManager = CLLocationManager()
    
    var currentLat = Double()
    var currentLong = Double()
    
    var zoomRect = MKMapRect.null
    
    var isWebserviceCalled = Bool()
    var selectedTag:Int?
    var loginWSCalled = Bool()
    
    @IBOutlet weak var buttonCloseCollectionView:UIButton!
    //Filter View
    
    @IBOutlet weak var viewFilter : UIView!
    @IBOutlet weak var txtFldLocation: UITextField!
    @IBOutlet weak var txtViewDescription: UITextView!
    @IBOutlet weak var txtFldCategories: UITextField!
    @IBOutlet weak var rangeSlider: UISlider!
    @IBOutlet weak var labelRange: UILabel!
    
    @IBOutlet weak var searchViewContainer:MyBorderView!
    
    
    @IBOutlet weak var buttonKeyword:UIButton!
    @IBOutlet weak var buttonPerson:UIButton!
    @IBOutlet weak var buttonCompany:UIButton!
    
    @IBOutlet weak var buttonClearKeyword:UIButton!
    
    @IBOutlet weak var leadingContraintProviderContainer:NSLayoutConstraint!
    
    var arrCategories = NSArray()
    var categoryStrings = String()
    var filterDescription = String()
    var categoryIDS = String()
    var rangeLimit = String()
    
    
    var arrMyNetworkUsers = NSArray()
    var arrayOfProvidersNotified:[NotifiedProviderOffer] = []
    var isFromAddJOB:Bool = false
    
    var isFromChatNotificationReceive:Bool = false
    var chatNotificationreceiveID:String = ""
    var chatNotificationsenderID:String = ""
    var chatNotificationProfile:String = ""
    var chatNotificationreceiveName:String = ""
    var chatNotificationToUserType:String = ""
    
    var arrayOfKeywordSearchProvider:[NotifiedProviderOffer] = []
    
    @IBOutlet var floatingViewPan: UIPanGestureRecognizer!
    @IBOutlet weak var floatingView:UIView!
    @IBOutlet weak var imageFloatView:UIImageView!
    @IBOutlet weak var lblFloatView:UILabel!
    
    @IBOutlet weak var viewLableFloatViewContainer:UIView! //hide show
    
    @IBOutlet weak var viewLableFloatView:UIView!
    @IBOutlet weak var viewLableFloatViewShadow:ShadowBackgroundView!
    
    @IBOutlet weak var leftContraintCollectionView:NSLayoutConstraint!
    
    @IBOutlet weak var containerViewSlideCollection:UIView!
    @IBOutlet weak var containerViewSlideShowButton:UIButton!
    @IBOutlet weak var containerView1:UIView!
    @IBOutlet weak var containerShadowView:ShadowBackgroundView!
    @IBOutlet weak var containerView2:UIView!
    
    
    @IBOutlet weak var leftArrow:UIImageView!
    @IBOutlet weak var rightArrow:UIImageView!
    @IBOutlet weak var viewRight:UIView!
    @IBOutlet weak var viewLeft:UIView!
    
    @IBOutlet weak var viewProviderImage1:UIImageView!
    
    @IBOutlet weak var viewProviderImage2:UIImageView!
    
    @IBOutlet weak var viewProviderImage3:UIImageView!
    
    @IBOutlet weak var viewProviderImage4:UIImageView!
    
    @IBOutlet weak var viewProviderImage5:UIImageView!
    
    @IBOutlet weak var viewProviderImage6:UIImageView!
    
    @IBOutlet weak var lblFirstFloat:UILabel!
    @IBOutlet weak var lblSecondFloat:UILabel!
    @IBOutlet weak var lblThirdFloat:UILabel!
    
    
    @IBOutlet weak var buttonBadgeCount:UIButton!
    
    var isFirstTimeKeywordSearch:Bool = true
    var unreadMessage:Int = 0
    var totalUnreadMessage:Int{
        get{
            return unreadMessage
        }
        set{
            unreadMessage = newValue
            DispatchQueue.main.async {
                self.buttonBadgeCount.setTitle("\(newValue)", for: .normal)
                self.buttonBadgeCount.isHidden = newValue == 0
            }
        }
    }
    var isFromDidselectSearchKeyword:Bool = false
    
    //var arrayOfFloatMessage = ["Select this to turn your search into a post","Tap here to create a post and turn your search into a bidding event","Tap here to create a post and let Providers compete for your business"]
    var arrayOfFloatMessage:[String] = ["Tap here to create a post","Tap here to create a post and create a bidding event","Tap here to create a post and let Providers compete for your business"]
    
    var selectedOption:Int = 0 //0 keyword 1 person  2 company
    var selectedSearchOption:Int{
        get{
            return selectedOption
        }
        set{
            selectedOption = newValue
            //ConfigureSeleted Option
            DispatchQueue.main.async {
//                self.checkForCollectionHideButtonHideShow()
                self.configureSelectedSearchOption()
            }
            
        }
    }
    var timer: Timer?
    var totalTime = 10 //show on every 60 second
    var hideTime = 10 //hide on 10 seconds
    
    var searchedkeyword = ""
    var currentSearchKeyword:String {
        get{
            return searchedkeyword
        }
        set{
            self.searchedkeyword = newValue
            //Add Floating button And Timer
            DispatchQueue.main.async {
                self.floatingView.isHidden = false//!(newValue.count > 0)
                //self.checkForCollectionHideButtonHideShow()
            }
            
            //self.isForKeywordSearch = (newValue.count > 0) //|| self.arrayOfKeywordSearchProvider.count > 0)
            DispatchQueue.main.async {
                if self.selectedSearchOption == 0 && "\(newValue)".count > 0{
                    self.buttonClearKeyword.isHidden = false
                    self.txtSearch.text = "\(newValue)".capitalized
                }else{
                    if self.txtSearch.text == "" {
                        self.buttonClearKeyword.isHidden = true
                    }else{
                        self.buttonClearKeyword.isHidden = false
                    }
                    //  self.txtSearch.text = ""
                }
            }
            
            
            
        }
    }
    
    @IBOutlet weak var viewProviderContainerView:UIView!
    @IBOutlet weak var viewProviderContainerSearchKeyword:UILabel!
    @IBOutlet weak var viewProviderContainerDate:UILabel!
    @IBOutlet weak var viewProviderContainerReview:UILabel!
    @IBOutlet weak var viewProviderContainerProviderName:UILabel!
    @IBOutlet weak var viewProviderContainerProviderImage:UIImageView!
    
    @IBOutlet weak var widthContraintOfFloatingView:NSLayoutConstraint!
    
    @IBOutlet weak var viewbuttonSearchThisArea:UIView!
    
    var lastCenter:CGPoint = CGPoint.init(x: 40, y: 230)
    
    var currentKeyWordSearchProvider:NotifiedProviderOffer = NotifiedProviderOffer(providersDetail: [:])
    
    var isPushtoProviderDetail:Bool = false
    
    var isKeywordSearch:Bool = false
    var isForKeywordSearch:Bool{
        get{
            return isKeywordSearch
        }
        set{
            self.isKeywordSearch = newValue
            //ConfigureKeywordSearch
            self.configurePageForKeywordSearchOrOffer()
            DispatchQueue.main.async {
                if newValue{
                    self.txtSearch.text = "\(self.currentSearchKeyword)"
                    self.buttonClearKeyword.isHidden = false
                    self.buttonClearKeyword.isHidden = "\(self.currentSearchKeyword)".count > 0 ? false : true
                }else{
                    self.txtSearch.text = ""
                    self.buttonClearKeyword.isHidden = true
                }
            }
            /*
             DispatchQueue.main.async {
             self.floatingView.isHidden = !newValue
             }
             
             if newValue{
             self.addtimerWith60SecondsForFloatingOptionShow()
             }else{
             self.removeTimer()
             }*/
        }
    }
    var panGesture       = UIPanGestureRecognizer()
    
    var searchMapPinSelectedTag:Int?
    
    
    var manageUserDetailState:Bool = false
    
    @IBOutlet weak var buttonBookNowTile:UIButton!
    @IBOutlet weak var buttonContactTile:UIButton!
    
    var isFromReviewNotificationReceive: Bool = false
    
    
    var currentMapCenterlat:String = ""
    var currentMapCenterlng:String = ""
    
    
    var lastSearchLatForKeyword:String = ""
    var lastSearchLngForKeyword:String = ""
    var currentMapScale = ""

    let currentUserdefault = UserDefaults.standard
    
    //MARK: - UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewbuttonSearchThisArea.isHidden = true
        do {
            if let styleURL = Bundle.main.url(forResource: "google_map_style", withExtension: "json") {
                self.objGoogleMap.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        
        
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        floatingView.isUserInteractionEnabled = true
        floatingView.addGestureRecognizer(panGesture)
        
        //configure gesture
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationPayOut(notification:)), name: .customerHomeBankList, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: .customerHome, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfJOBBookdNotification(notification:)), name: .jobBook, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfProviderJOBBookNotification(notification:)), name: .providerBookJOB, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfNewProviderAvailableNotification(notification:)), name: .newProviderAvailable, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfNewMessageReceiveNotification(notification:)), name: .chatUnreadCount, object: nil)

        
        
        self.searchViewContainer.layer.cornerRadius = 26.0
        self.searchViewContainer.clipsToBounds = true
        
        // Do any additional setup after loading the view.
        
        Analytics.logEvent(NSLocalizedString("click_home_tab", comment: ""), parameters: [:])
        
        RegisterCell()
        
        //self.pushToProviderDetailScreenWithProviderId(providerID: "9")
        /*
         
         rangeLimit = "50"
         labelRange.text = "50 miles"
         rangeSlider.value = 50
         
         mapView.delegate = self
         mapView.showsUserLocation = true
         
         RegisterCell()
         isWebserviceCalled = false
         selectedTag = 0
         
         if UserSettings.isUserLogin == true {
         callLoginAPI()
         }
         else {
         //            mylocation()
         
         let storyboard = UIStoryboard(name: "Profile", bundle: nil)
         let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
         loginVC.modalPresentationStyle = .fullScreen
         self.navigationController?.present(loginVC, animated: true, completion: nil)
         }
         mapView.mapType = .standard
         
         NotificationCenter.default.addObserver(self, selector: #selector(reloadMapData), name: Notification.Name("UserSignInOutNotification"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(goToChat), name: Notification.Name("MessageReceivedNotification"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(goToNotificationJobProfile), name: Notification.Name("JobReceivedNotification"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(goToCommentsNotificationJobProfile), name: Notification.Name("CommentsReceivedNotification"), object: nil)
         
         let bool = UserDefaults.standard.bool(forKey: "forNotification")
         let jobbool = UserDefaults.standard.bool(forKey: "forJobNotification") //forJobNotification
         
         if bool == true {
         UserDefaults.standard.set(false, forKey: "forNotification")
         self.goToChat()
         }
         else if jobbool == true {
         UserDefaults.standard.set(false, forKey: "forJobNotification")
         self.goToNotificationJobProfile()
         }
         self.callAPIToGetMyNetworkUsers() */
        if self.isFromChatNotificationReceive{
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                self.pushToChatViewControllerOnNotification(receiverId: self.chatNotificationreceiveID, quickblox_id: self.chatNotificationsenderID)
            }
        }
        
        if self.isFromReviewNotificationReceive{
            self.reviewOfCustomerNotification()
        }
        
        
        self.lblFloatView.text = "\(self.arrayOfFloatMessage[0])"
        self.lblSecondFloat.text = "\(self.arrayOfFloatMessage[1])"
        self.lblThirdFloat.text = "\(self.arrayOfFloatMessage[2])"
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppDidBecomeActiveNotification(notification:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        self.setup()
        
    }
    func setup(){
        self.viewbuttonSearchThisArea.clipsToBounds = true
        self.viewbuttonSearchThisArea.layer.borderColor = UIColor.lightGray.cgColor
        self.viewbuttonSearchThisArea.layer.borderWidth = 0.7
    }
    override func viewWillLayoutSubviews() {
        
        DispatchQueue.main.async {
            //            self.floatingView.center = self.lastCenter
            UIView.performWithoutAnimation {
                self.floatingView.center = self.lastCenter
            }
            
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func handleAppDidBecomeActiveNotification(notification: Notification) {
        if UserDetail.isUserLoggedIn{
            if let strCode = UserDefaults.standard.object(forKey: "GroupReferralCode") as? String,strCode != ""{
                DispatchQueue.main.async {
                    self.calladdgroupmemberAPI(ReferralCode: strCode)
                }
                
            }
        }
    }
    // MARK: SignUp to QuickBlox for chat
    func signUp(fullName:String ,email: String, login: String,password:String,userId: String) {
        
        let newUser = QBUUser()
        newUser.login = login
        newUser.fullName = fullName
        //        newUser.email = email
        newUser.password = password
        
        QBRequest.signUp(newUser, successBlock: { [weak self] response, user in
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.getLogsAPI(userid: userId, module: "quickblox_signup", description: "Sign Up success: \(newUser.id)")
                }
                self?.login(fullName: fullName, email: email, login: login,password: password,userId: userId)
            }
            
        }, errorBlock: { [weak self] response in
            print("===== Sign Up fail \(response)")
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.getLogsAPI(userid: userId, module: "quickblox_signup", description: " \(response.status.rawValue) \(response.error?.error?.localizedDescription)")
                }
            }
            if response.status.rawValue == 422 {
                // The user with existent login was created earlier
                self?.login(fullName: fullName, email: email, login: login,password: password,userId: userId)
            }
        })
    }
    // MARK: Login to QuickBlox for chat
    func disconnect(completion: QBChatCompletionBlock? = nil) {
        QBChat.instance.disconnect(completionBlock: completion)
    }
    private func login(fullName: String, email: String, login: String, password: String,userId: String) {
        QBRequest.logOut(successBlock: { (response) in
            
            print("===== Logout success \(response)")
            self.disconnect()
        }, errorBlock: { (response) in
            print("===== Logout error \(response)")
        })
        
        QBRequest.logIn(withUserLogin: login,
                        password: password,
                        successBlock: { [weak self] response, user in
            user.password = password
            user.updatedAt = Date()
            Profile.synchronize(user)
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.getLogsAPI(userid: userId, module: "quickblox_login", description: "Log In success: \(user.id)")
                }
            }
            // connect to chat
            QBChat.instance.connect(withUserID:user.id,
                                    password: password,
                                    completion: { [weak self] error in
                print("===== LogIn \(error?.localizedDescription)")
                if let error = error {
                    if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                        // Clean profile
                        // Profile.clearProfile()
                    } else {
                        
                    }
                } else {
                    self?.callAddQuickBloxDetail(quickbloxId:user.id)
                }
            })
        }, errorBlock: { [weak self] response in
            print("===== LogIn \(response)")
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.getLogsAPI(userid: userId, module: "quickblox_login", description: "\(response.status.rawValue) \(response.error?.error?.localizedDescription)")
                }
            }
            if response.status == QBResponseStatusCode.unAuthorized {
                
            }
        })
    }
    // MARK:Call API add-group-member
    func calladdgroupmemberAPI(ReferralCode:String){
        let dict:[String:Any] = [
            "group_referral_code" : "\(ReferralCode)",
        ]
        DispatchQueue.main.async {
            ExternalClass.ShowProgress()
        }
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGroupAddMember , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                ExternalClass.ShowProgress()
            }

            if let success = responseSuccess as? [String:Any], let successMsg = success["success_data"] as?[String]{
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: AppName, message: successMsg[0], preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        
                    }))
                    alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                    UserDefaults.standard.removeObject(forKey: "GroupReferralCode")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }){ (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String]{
                DispatchQueue.main.async {
                    UserDefaults.standard.removeObject(forKey: "GroupReferralCode")
                    if errorMessage.count > 0{
                        SAAlertBar.show(.error, message:"\(errorMessage.first!)")
                    }
                    
                }
            }
        }
    }
    //MARK: API Call of Save QuickBlox Detail
    func callAddQuickBloxDetail(quickbloxId:Any){
        QBRequest.subscriptions(successBlock: { (response, subscriptions) in
            print("==== count \(subscriptions?.count)")
            if subscriptions!.count > 0{
                let myGroup = DispatchGroup()
                
                for (index,sub) in subscriptions!.enumerated(){
                    myGroup.enter()
                    
                    QBRequest.deleteSubscription(withID: sub.id) { (response) in
                        print("Finished \(index) Request")
                        myGroup.leave()
                    } errorBlock: { (response) in
                        print("Finished \(index) Request")
                        myGroup.leave()
                    }
                }
                myGroup.notify(queue: .main){
                    print("Finished All Request")
                    //API
                    self.createSubsciptionAndAddIDTOAPIRequest(quickbloxId: quickbloxId)
                }
            }else{
                //API
                self.createSubsciptionAndAddIDTOAPIRequest(quickbloxId: quickbloxId)
                
                
            }
        }) { (errorResponse) in
            // Create new subscriciption for current device here
            print("==== error count \(errorResponse)")
            //API
            self.createSubsciptionAndAddIDTOAPIRequest(quickbloxId: quickbloxId)
        }
    }
    func createSubsciptionAndAddIDTOAPIRequest(quickbloxId:Any){
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNSVOIP
        subscription.deviceUDID = deviceIdentifier
        var deviceToken = Data()
        if isKeyPresentInUserDefaults(key: "deviceToken") {
            if let deviceTokenvalue = UserDefaults.standard.object(forKey: "deviceToken") as? Data{
                deviceToken = deviceTokenvalue
            }
        }
        subscription.deviceToken = deviceToken//Data("\(deviceToken)".utf8)
        
        if let value =  UInt("\(quickbloxId)"){
            subscription.id = value
        }
        
        
        QBRequest.createSubscription(subscription, successBlock: { (response, objects) in
            
            self.callAPIToRegisterQuickBlox(quickbloxId: quickbloxId)
        }, errorBlock: { (response) in
            self.callAPIToRegisterQuickBlox(quickbloxId: quickbloxId)
            //debugPrint("[AppDelegate] createSubscription error: \(String(describing: response.error))")
        })
    }
    func callAPIToRegisterQuickBlox(quickbloxId:Any){
        let dict:[String:Any] = [
            "quickblox_id" : "\(quickbloxId)",
        ]
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSaveQuickBloxDetail , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any]{
                
            }
        }){ (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String]{
                
            }
        }
        
        
    }
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        //self.view.bringSubviewToFront(self.floatingView)

        let translation = sender.translation(in: self.view)
        let point = CGPoint(x: self.floatingView.center.x + translation.x, y: self.floatingView.center.y + translation.y)
        if self.objGoogleMap.frame.contains(point){
            self.lastCenter = CGPoint(x: self.floatingView.center.x + translation.x, y: self.floatingView.center.y + translation.y)
            self.floatingView.center = CGPoint(x: self.floatingView.center.x + translation.x, y: self.floatingView.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    func checkForCollectionHideButtonHideShow(){
        DispatchQueue.main.async {
            if self.arrayOfKeywordSearchProvider.count >  0 && self.arrayOfProvidersNotified.count > 0{
                self.buttonCloseCollectionView.isHidden = false
            }else{
                self.buttonCloseCollectionView.isHidden = true
            }
        }
        
    }
    func configureGeasture(){
        
        // self.viewLableFloatViewShadow.rounding = 10.0
        //self.viewLableFloatViewShadow.layer.cornerRadius = 10.0
        //self.viewLableFloatViewShadow.layoutIfNeeded()
        
        self.viewLableFloatView.layer.cornerRadius = 10.0
        self.viewLableFloatView.layoutIfNeeded()
        self.viewLableFloatView.clipsToBounds = true
        
        self.imageFloatView.layer.cornerRadius = 25.0
        self.imageFloatView.layoutIfNeeded()
        self.imageFloatView.clipsToBounds = true
        /*
         let tapGesture = UITapGestureRecognizer(
         target: self,
         action: #selector(handleTap)
         )
         
         // 4
         tapGesture.delegate = self
         //self.viewLableFloatView.addGestureRecognizer(tapGesture)
         self.imageFloatView.addGestureRecognizer(tapGesture)
         
         
         tapGesture.require(toFail: floatingViewPan) */
        
        
    }
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        //push to create job
        //        print(self.currentSearchKeyword)
        //        if self.currentSearchKeyword.count > 0{
        //            self.pushToPostJOBViewController(jobTitle: self.currentSearchKeyword)
        //        }
    }
    @IBAction func buttonShowFloatMessage(sender:UIButton){
        if true{//self.viewLableFloatViewContainer.alpha == 1.0{
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                UIView.transition(with: self.viewLableFloatViewContainer, duration: 1.0,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    DispatchQueue.main.async {
                        
                        if self.currentSearchKeyword.count > 0 || self.arrayOfKeywordSearchProvider.count > 0{
                            self.pushToPostJOBViewController(jobTitle: self.currentSearchKeyword)
                        }else{
                            self.viewLableFloatViewContainer.alpha = 0.0
                        }
                        
                    }
                })
            }
        }else{
            DispatchQueue.main.async {
                UIView.transition(with: self.viewLableFloatViewContainer, duration: 1.0,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    DispatchQueue.main.async {
                        self.viewLableFloatViewContainer.alpha = 1.0
                        let randomInt = Int.random(in: 0..<2)
                        if randomInt == 0{
                            self.lblFloatView.alpha = 1.0
                            self.lblSecondFloat.alpha = 0.0
                            self.lblThirdFloat.alpha = 0.0
                        }else if randomInt == 1{
                            self.lblFloatView.alpha = 0.0
                            self.lblSecondFloat.alpha = 1.0
                            self.lblThirdFloat.alpha = 0.0
                        }else{
                            self.lblFloatView.alpha = 0.0
                            self.lblSecondFloat.alpha = 0.0
                            self.lblThirdFloat.alpha = 1.0
                        }
                    }
                })
            }
        }
        
        
    }
    @IBAction func buttonPushToCreatePost(sender:UIButton){
        if self.currentSearchKeyword.count > 0 || self.arrayOfKeywordSearchProvider.count > 0{
            self.pushToPostJOBViewController(jobTitle: self.currentSearchKeyword)
        }
    }
    func addtimerWith60SecondsForFloatingOptionShow(){
        DispatchQueue.main.async {
            
            self.floatingView.alpha = 1.0
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true, block: { _ in
                self.updateTimer()
                
            })
        }
    }
    
    @objc func updateTimer() {
        
        DispatchQueue.main.async {
            UIView.transition(with: self.viewLableFloatViewContainer, duration: 1.0,
                              options: .transitionCrossDissolve,
                              animations: {
                DispatchQueue.main.async {
                    //                        self.floatingView.center = self.lastCenter
                    //                        self.view.layoutIfNeeded()
                    self.viewLableFloatViewContainer.alpha = 1.0
                    
                    let randomInt = Int.random(in: 0..<2)
                    if randomInt == 0{
                        self.lblFloatView.alpha = 1.0
                        self.lblSecondFloat.alpha = 0.0
                        self.lblThirdFloat.alpha = 0.0
                    }else if randomInt == 1{
                        self.lblFloatView.alpha = 0.0
                        self.lblSecondFloat.alpha = 1.0
                        self.lblThirdFloat.alpha = 0.0
                    }else{
                        self.lblFloatView.alpha = 0.0
                        self.lblSecondFloat.alpha = 0.0
                        self.lblThirdFloat.alpha = 1.0
                    }
                    
                    
                    
                }
                
                
            })
            //            self.lblFloatView.text = self.arrayOfFloatMessage.randomElement() ?? ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                UIView.transition(with: self.viewLableFloatViewContainer, duration: 1.0,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    DispatchQueue.main.async {
                        //                                    self.floatingView.center = self.lastCenter
                        //                                    self.view.layoutIfNeeded()
                        self.viewLableFloatViewContainer.alpha = 0.0
                        //self.viewLableFloatViewContainer.isHidden = true
                    }
                })
            }
        }
    }
    func removeTimer(){
        DispatchQueue.main.async {
            //            self.floatingView.center = self.lastCenter
            //            self.view.layoutIfNeeded()
            self.floatingView.alpha = 1.0
            self.timer?.invalidate()
            self.timer = nil
        }
        
    }
    func configureSelectedSearchOption(){
        DispatchQueue.main.async {
            if self.selectedSearchOption == 0{
                self.txtSearch.text = "\(self.currentSearchKeyword)"
//                self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(self.currentSearchKeyword)")
                if self.txtSearch.text == "" {
                    self.buttonClearKeyword.isHidden = true
                }else{
                    self.buttonClearKeyword.isHidden = false
                }
                self.floatingView.isHidden = false
                /*
                if self.currentSearchKeyword.count > 0{
                }else{
                    if self.arrayOfProvidersNotified.count > 0{
                        self.objGoogleMap.clear()
                        self.containerViewSlideCollection.isHidden = false
                        self.containerViewSlideShowButton.isHidden = false
                        self.hideColllectionViewandShowSlider()
                    }else{
                        self.containerViewSlideCollection.isHidden = true
                        self.containerViewSlideShowButton.isHidden = true
                    }
                    //  self.txtSearch.text = ""
                    if self.txtSearch.text == "" {
                        self.buttonClearKeyword.isHidden = true
                    }else{
                        self.buttonClearKeyword.isHidden = false
                    }
                    self.floatingView.isHidden = false
                }*/
                
                //#9CB7BF //08405D
                self.buttonKeyword.backgroundColor = UIColor.init(hex: "08405D")
                self.buttonPerson.backgroundColor = UIColor.init(hex: "9CB7BF")
                self.buttonCompany.backgroundColor = UIColor.init(hex: "9CB7BF")
                self.buttonKeyword.alpha = 1.0
                self.buttonPerson.alpha = 1.0
                self.buttonCompany.alpha = 1.0
                
//                if self.arrayOfProvidersNotified.count > 0 && self.isForKeywordSearch{
//                    self.containerViewSlideCollection.isHidden = false
//                    self.containerViewSlideShowButton.isHidden = false
//                }else{
//                    self.containerViewSlideCollection.isHidden = true
//                    self.containerViewSlideShowButton.isHidden = true
//                }
                
            }else if self.selectedSearchOption == 1{
//                if self.arrayOfProvidersNotified.count > 0{
//                    self.objGoogleMap.clear()
//                    self.hideColllectionViewandShowSlider()
//                }else{
//                    self.containerViewSlideCollection.isHidden = true
//                    self.containerViewSlideShowButton.isHidden = true
//                }
                
                self.floatingView.isHidden = false
                self.txtSearch.text = ""
                self.buttonClearKeyword.isHidden = true
                self.buttonKeyword.backgroundColor = UIColor.init(hex: "9CB7BF")
                self.buttonPerson.backgroundColor = UIColor.init(hex: "08405D")
                self.buttonCompany.backgroundColor = UIColor.init(hex: "9CB7BF")
                self.buttonKeyword.alpha = 1.0
                self.buttonPerson.alpha = 1.0
                self.buttonCompany.alpha = 1.0
            }else if self.selectedSearchOption == 2{
//                if self.arrayOfProvidersNotified.count > 0{
//                    self.objGoogleMap.clear()
//                    self.hideColllectionViewandShowSlider()
//                }else{
//                    self.containerViewSlideCollection.isHidden = true
//                    self.containerViewSlideShowButton.isHidden = true
//                }
                self.floatingView.isHidden = false
                self.txtSearch.text = ""
                self.buttonClearKeyword.isHidden = true
                self.buttonKeyword.backgroundColor = UIColor.init(hex: "9CB7BF")
                self.buttonPerson.backgroundColor = UIColor.init(hex: "9CB7BF")
                self.buttonCompany.backgroundColor = UIColor.init(hex: "08405D")
                self.buttonKeyword.alpha = 1.0
                self.buttonPerson.alpha = 1.0
                self.buttonCompany.alpha = 1.0
            }else{
//                if self.arrayOfProvidersNotified.count > 0{
//                    self.objGoogleMap.clear()
//                    self.hideColllectionViewandShowSlider()
//                }else{
//                    self.containerViewSlideCollection.isHidden = true
//                    self.containerViewSlideShowButton.isHidden = true
//                }
                self.floatingView.isHidden = false
                self.txtSearch.text = ""
                self.buttonClearKeyword.isHidden = true
                self.buttonKeyword.backgroundColor = UIColor.init(hex: "08405D")
                self.buttonPerson.backgroundColor = UIColor.init(hex: "9CB7BF")
                self.buttonCompany.backgroundColor = UIColor.init(hex: "9CB7BF")
                self.buttonKeyword.alpha = 1.0
                self.buttonPerson.alpha = 1.0
                self.buttonCompany.alpha = 1.0
            }
        }
    }
    
    func blinkAnimation(){
        let changeColor = CATransition()
        changeColor.duration = 1
        changeColor.type = .fade
        changeColor.repeatCount = Float.infinity
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.lblTitle.layer.add(changeColor, forKey: nil)
            self.lblTitle.textColor = .green
        }
        self.lblTitle.textColor = .yellow
        CATransaction.commit()
    }
    @objc func methodOfJOBBookdNotification(notification: Notification) {
        self.jobBookingdelegate()
    }
    @objc func methodOfReceivedNotification(notification: Notification) {

        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.isFromAddJOB = false
            if self.currentSearchKeyword.count > 0{
                self.callAPIRequestToGetListOfJOB(searchKeyword: self.currentSearchKeyword,isFirstTime: true)
            }else{
                self.callAPIRequestToGetListOfJOB(searchKeyword: "",isFirstTime: true)
            }
        }
        
    }
    @objc func methodOfReceivedNotificationPayOut(notification: Notification) {
        //present bank list
        
    }
    @objc func methodOfNewProviderAvailableNotification(notification: Notification) {
        if let userInfo = notification.userInfo as? [String:Any]{
            print(userInfo)
            if let providerID = userInfo["provider_id"]{
                self.pushToProviderDetailScreenWithProviderId(providerID: "\(providerID)")
            }
        }
    }
    @objc func methodOfNewMessageReceiveNotification(notification:Notification){
        if let userInfo = notification.userInfo as? [String:Any]{
            print(userInfo)
            self.callAPIRequestToGetChatUnreadCount()
        }
    }
    @objc func methodOfProviderJOBBookNotification(notification: Notification) {
        if let userInfo = notification.userInfo as? [String:Any]{
            print(userInfo)
            
            self.apiRequestValidationForDirectBookProvider(requestParameters: userInfo,isFromLocalNotification: true)
        }
        
    }
    
    func reviewOfCustomerNotification() {
        
        self.manageUserDetailState = true
        if let objCustomerReviewController = UIStoryboard.profile.instantiateViewController(withIdentifier: "CustomerReviewViewController") as? CustomerReviewViewController{
            self.navigationController?.pushViewController(objCustomerReviewController, animated: true)
        }
    }
    
    func refreshFromBackgroundNotification(){
        self.objGoogleMap.clear()
        self.isFromAddJOB = false
        
        //Fetch List of offer
        self.callAPIRequestToGetListOfJOB(searchKeyword: "")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        self.floatingView.isHidden =  self.selectedSearchOption == 0 ? false : true
        self.floatingView.translatesAutoresizingMaskIntoConstraints = true
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.floatingView.center = self.lastCenter
            }
        }
        //  self.txtSearch.text = ""
        DispatchQueue.main.async {
            if let objTabView = self.navigationController?.tabBarController as? MyTabController{
                if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first{
                    self.bottomConstaintTile.constant = window.safeAreaInsets.bottom + 44.0 + 15.0
                }
            }
            self.floatingView.isHidden = false
            //            self.addtimerWith60SecondsForFloatingOptionShow()
            
            
            
            self.view.layoutIfNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.objGoogleMap.delegate = self
        }
        
        DispatchQueue.main.async {
            //configure card without created job
            self.viewProviderContainerView.clipsToBounds = true
            //                   self.viewProviderContainerView.layer.cornerRadius = 30.0
            //self.txtSearch.setPlaceHolderColor()
            
            self.viewProviderImage1.clipsToBounds = true
            self.viewProviderImage1.layer.cornerRadius = 12.5
            self.viewProviderImage1.layer.borderWidth = 0.5
            self.viewProviderImage1.layer.borderColor = UIColor.white.cgColor
            
            self.viewProviderImage2.isHidden = true
            self.viewProviderImage2.clipsToBounds = true
            self.viewProviderImage2.layer.cornerRadius = 12.5
            self.viewProviderImage2.layer.borderWidth = 0.5
            self.viewProviderImage2.layer.borderColor = UIColor.white.cgColor
            
            self.viewProviderImage3.isHidden = true
            self.viewProviderImage3.clipsToBounds = true
            self.viewProviderImage3.layer.cornerRadius = 12.5
            self.viewProviderImage3.layer.borderWidth = 0.5
            self.viewProviderImage3.layer.borderColor = UIColor.white.cgColor
            
            self.viewProviderImage4.isHidden = true
            self.viewProviderImage4.clipsToBounds = true
            self.viewProviderImage4.layer.cornerRadius = 12.5
            self.viewProviderImage4.layer.borderWidth = 0.5
            self.viewProviderImage4.layer.borderColor = UIColor.white.cgColor
            
            self.viewProviderImage5.isHidden = true
            self.viewProviderImage5.clipsToBounds = true
            self.viewProviderImage5.layer.cornerRadius = 12.5
            self.viewProviderImage5.layer.borderWidth = 0.5
            self.viewProviderImage5.layer.borderColor = UIColor.white.cgColor
            
            self.viewProviderImage6.isHidden = true
            self.viewProviderImage6.clipsToBounds = true
            self.viewProviderImage6.layer.cornerRadius = 12.5
            self.viewProviderImage6.layer.borderWidth = 0.5
            self.viewProviderImage6.layer.borderColor = UIColor.white.cgColor
            
            
            
            self.containerView1.clipsToBounds = true
            self.containerView1.layer.cornerRadius = 20.0
            
            self.containerView2.clipsToBounds = true
            self.containerView2.layer.cornerRadius = 20.0
            
            self.containerShadowView.rounding = 20.0
            self.containerShadowView.layer.cornerRadius = 20.0
            self.containerShadowView.layoutIfNeeded()
        }
        if self.manageUserDetailState{
            self.manageUserDetailState = false
        }else{
            if let currentUser = UserDetail.getUserFromUserDefault(){
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        var delayTime = 0.0
                        if let lat = self.currentUserdefault.value(forKey: KcurrentUserLocationLatitude) as? Double, let lng = self.currentUserdefault.value(forKey: KcurrentUserLocationLongitude) as? Double{
                        if lat != 0.0 && lng != 0.0{
                            delayTime = 0.0
                        }else{
                            delayTime = appDelegate.currentLocationDelay
                        }
                        }else{
                            delayTime = appDelegate.currentLocationDelay
                        }

                    DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                        if currentUser.userRoleType == .customer{
                        if self.isFromDidselectSearchKeyword{
                            self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: self.currentSearchKeyword,isFirstTime: false)
                        }else{
                            if self.currentSearchKeyword.count > 0{
                                self.callAPIRequestToGetListOfJOB(searchKeyword: self.currentSearchKeyword,isFirstTime: true)
                            }else{
                                self.callAPIRequestToGetListOfJOB(searchKeyword: "",isFirstTime: true)
                            }
                          }
                        }
                    }
                }
            }


        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.selectedSearchOption = 0
        DispatchQueue.main.async {
            ExternalClass.ShowProgress()
        }
        if let lat = currentUserdefault.value(forKey: KcurrentUserLocationLatitude) as? Double, let lng = currentUserdefault.value(forKey: KcurrentUserLocationLongitude) as? Double{
            self.currentLat = lat
            self.currentLong = lng
        }


        if let appdelegate = UIApplication.shared.delegate as? AppDelegate{
            self.currentSearchKeyword = "\(appdelegate.searchKeyword)"
        }
        if !self.isFromDidselectSearchKeyword{
            self.buttonCloseCollectionView.isHidden = false//(self.arrayOfKeywordSearchProvider.count == 0)
            self.containerViewSlideShowButton.isHidden = true//(self.arrayOfProvidersNotified.count == 0)
        }else{
            self.buttonCloseCollectionView.isHidden = true //(self.arrayOfKeywordSearchProvider.count == 0)
            self.containerViewSlideShowButton.isHidden = (self.arrayOfProvidersNotified.count == 0)
        }


        self.locationManager.delegate = self
        self.objGoogleMap.settings.allowScrollGesturesDuringRotateOrZoom = false
        self.objGoogleMap.settings.zoomGestures = true
        self.locationManager.requestWhenInUseAuthorization()
        self.objGoogleMap.isMyLocationEnabled = true
        self.objGoogleMap.settings.myLocationButton = false
        self.mylocation()

        if self.currentLat != 0.0 && self.currentLong != 0.0 && !self.manageUserDetailState{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.8) {
               let location = CLLocation(latitude: self.currentLat, longitude: self.currentLong)
               let locationObj =  CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
               self.objGoogleMap.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: self.objGoogleMap.camera.zoom))
            }
        }
//        self.objGoogleMap.animate(toZoom: Float(self.calculateZoomLevelBasedOnMiles(miles: 20.0)))
        
        
        self.callAPIRequestToGetChatUnreadCount()
        self.tabBarController?.tabBar.isHidden = false
        //self.containerViewSlideShowButton.isHidden = true
        //"1000".add2DecimalWithCommaString
        if let currentUser = UserDetail.getUserFromUserDefault(){
            let fname = currentUser.firstname
            let lname =  currentUser.lastname
            var username = currentUser.username.removeWhiteSpaces()
            let userID = currentUser.id
            //DEVELOPER
            username = "staging_\(username)"
            //No need to add prefix on production
            
            //            self.signUp(fullName: fname + " " + lname , email: currentUser.email, login: username, password: "quickblox", userId: userID)
        }
        
        self.configureGeasture()
//        self.configureSelectedSearchOption()
        


        self.isFromAddJOB = false
        if let strCode = UserDefaults.standard.object(forKey: "GroupReferralCode") as? String,strCode != ""{
            self.calladdgroupmemberAPI(ReferralCode: strCode)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        self.floatingView.addGestureRecognizer(tap)
        DispatchQueue.main.async {
            self.viewLableFloatViewContainer.alpha = 0.0
        }
    }
    @objc func doubleTapped() {
        // your desired behaviour.
        self.pushToPostJOBViewController(jobTitle: self.currentSearchKeyword)
    }
    func calculateZoomLevelBasedOnMiles(miles:Double)->Double{
        let mtr = miles * 1609.344
        let  equatorLength:Double = 40075004 // in meters
        let  widthInPixels:Double = Double(UIScreen.main.bounds.width)
        var  metersPerPixel:Double = equatorLength / 256
        var  zoomLevel:Int = 1
        while ((metersPerPixel * widthInPixels) > mtr) {
            metersPerPixel =  metersPerPixel/2
            zoomLevel += 1
        }
        return Double(zoomLevel)
    }
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
//        self.currentLat = Double()
//        self.currentLong = Double()

        self.lastSearchLatForKeyword = ""
        self.lastSearchLngForKeyword = ""
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.searchKeyword = self.txtSearch.text ?? ""
            appDelegate.homelat = "\(self.currentMapCenterlat)"
            appDelegate.homelng = "\(self.currentMapCenterlng)"
        }

        
        
        if self.manageUserDetailState{
            
        }else{
            self.isFromDidselectSearchKeyword = false
            self.searchMapPinSelectedTag = nil
            locationManager.stopUpdatingLocation()
            if let container = self.so_containerViewController {
                container.isSideViewControllerPresented = false
            }
//            self.arrayOfProvidersNotified.removeAll()
            
            DispatchQueue.main.async {
                self.selectedTag = nil
                self.currentSearchKeyword = ""
                self.floatingView.isHidden = false
                self.timer?.invalidate()
                self.objGoogleMap.clear()
                self.removeTimer()
            }
        }
        
    }
    
    //MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            var strLocation_debug = "Customer - step_1     -       \(self.currentLat)    -     \(self.currentLong)   -   \n"
            if locations.count > 0{
                strLocation_debug += "step_2     -       \(locations.count)     -      \n"
                let latestLocation: AnyObject = locations.last!
                let mystartLocation = latestLocation as! CLLocation
                print(self.currentLat)
                print(self.currentLong)
                if self.currentLat == 0.0 && self.currentLong == 0.0 {
                        strLocation_debug += "step_3     -       \n"
                        self.mylocation()
                        strLocation_debug += "step_4     -      \(mystartLocation.coordinate.latitude)     -   \(mystartLocation.coordinate.longitude)      - \n"
                        let locationObj =  CLLocationCoordinate2DMake(mystartLocation.coordinate.latitude, mystartLocation.coordinate.longitude)
                        self.objGoogleMap.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: Float(self.calculateZoomLevelBasedOnMiles(miles: 20.0))))
                }
                if mystartLocation.coordinate.latitude == 0.0 && mystartLocation.coordinate.longitude == 0.0 {
                    strLocation_debug += "step_5     -       \n"
                    self.mylocation()
                }else{
                    strLocation_debug += "step_6     -       \(mystartLocation.coordinate.latitude)      -        \(mystartLocation.coordinate.longitude)    - \n"

                    self.currentLat = mystartLocation.coordinate.latitude
                    self.currentLong = mystartLocation.coordinate.longitude
                    self.currentUserdefault.setValue(self.currentLat, forKey: KcurrentUserLocationLatitude)
                    self.currentUserdefault.setValue(self.currentLong, forKey: KcurrentUserLocationLongitude)
                    self.currentUserdefault.synchronize()
                }
            }else{
                strLocation_debug += "step_7     -       \n"

            }
            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                return
            }
            let dict = [
                       "user_id": "\(currentUser.id)",
                       "log_module" : "location",
                       "log_description" : "\(strLocation_debug)",
                       "log_platform" : "ios"
                ]
            /*
            APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSaveLog , parameter: dict as [String:AnyObject], isHudeShow: false, success: { (responseSuccess) in

            }) { (responseFail) in

            }*/
        }


    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
            return
        }
        let dict = [
                   "user_id": "\(currentUser.id)",
                   "log_module" : "location",
            "log_description" : "Step 3 Fail Issue with location \(error.localizedDescription)",
                   "log_platform" : "ios"
            ]
        /*
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSaveLog , parameter: dict as [String:AnyObject], isHudeShow: false, success: { (responseSuccess) in

        }) { (responseFail) in

        }*/

    }

        


    
    //MARK: - User Defined Methods
    func configurePageForKeywordSearchOrOffer(){
        DispatchQueue.main.async {
            if self.arrayOfKeywordSearchProvider.count > 0{
                self.keywordSearchColllectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredHorizontally, animated: true)
            }
            if self.arrayOfProvidersNotified.count > 0{
                self.collectionObj.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredHorizontally, animated: true)
            }

            if self.isForKeywordSearch{
                if self.arrayOfKeywordSearchProvider.count > 0{
                    //self.configureProviderImageViewStackView()
                   // self.setLocationOfKeywordSearchProviderOnMap()
                }
                self.hideColllectionViewandShowSlider()
                self.zoomOutMapTo3PinByDefault()
            }else{
                if self.arrayOfProvidersNotified.count > 0{
                    self.setLocationMakerOnGoogleMap()
                }else{
                    
                }
                self.showCollectionViewHideCollectionSlider()
                self.zoomOutMapToOfferByDefault()
            }
            //            self.collectionObj.reloadData()

            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                if self.isFromDidselectSearchKeyword{
                    self.buttonCloseCollectionView.isHidden = true//(self.arrayOfKeywordSearchProvider.count == 0)
                    self.containerViewSlideShowButton.isHidden = (self.arrayOfProvidersNotified.count == 0)
                }else{
                    self.buttonCloseCollectionView.isHidden = false //(self.arrayOfKeywordSearchProvider.count == 0)
                    self.containerViewSlideShowButton.isHidden = true //(self.arrayOfProvidersNotified.count == 0)
                }
            }
        }
        
    }
    
    
    //Hide CollectionView and Show Slider
    func hideColllectionViewandShowSlider(){
        DispatchQueue.main.async {
            
            UIView.transition(with: self.viewProviderContainerView, duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: {
                DispatchQueue.main.async {
                    self.viewLeft.isHidden = true
                    self.viewRight.isHidden = true
                    self.viewProviderContainerView.isHidden = false
                }
            })
            if self.arrayOfProvidersNotified.count > 0{
                UIView.animate(withDuration: 0.2, animations: {
                    self.leftContraintCollectionView.constant = UIScreen.main.bounds.width
                    self.view.layoutIfNeeded()
                }) { (_) in
                    
                }
                UIView.transition(with: self.containerViewSlideCollection, duration: 0.2,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.leadingContraintProviderContainer.constant = 5.0
                        self.containerViewSlideCollection.isHidden = false
                        self.containerViewSlideShowButton.isHidden = false
                    }
                })
                
                
            }else{
                UIView.transition(with: self.containerViewSlideCollection, duration: 0.2,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.leadingContraintProviderContainer.constant = 5.0
                        self.containerViewSlideCollection.isHidden = true
                        self.containerViewSlideShowButton.isHidden = true
                    }
                })
                
                self.collectionObj.isHidden = true
            }
        }
    }
    func showCollectionViewHideCollectionSlider(){
        DispatchQueue.main.async {
            UIView.transition(with: self.viewProviderContainerView, duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: {
                DispatchQueue.main.async {
                    self.viewProviderContainerView.isHidden = true
                }
            })
            if self.arrayOfProvidersNotified.count > 0{
                
                UIView.animate(withDuration: 0.0, animations: {
                    
                    UIView.transition(with: self.containerViewSlideCollection, duration: 0.2,
                                      options: .transitionCrossDissolve,
                                      animations: {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            self.leadingContraintProviderContainer.constant = -20.0
                            self.containerViewSlideCollection.isHidden = true
                            self.containerViewSlideShowButton.isHidden = true
                        }
                    })
                    
                    self.collectionObj.isHidden = false
                    self.collectionObj.reloadData()
                    DispatchQueue.main.async {
                        self.view.layoutIfNeeded()
                        self.collectionObj.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                    }
                    /*
                     if self.arrayOfProvidersNotified.count == 1 {
                     self.leftContraintCollectionView.constant = (UIScreen.main.bounds.width - 200.0)
                     }else{
                     self.leftContraintCollectionView.constant = 0
                     }*/
                    self.leftContraintCollectionView.constant = 0
                    // self.leftContraintCollectionView.constant = 0
                    
                }) { (_) in
                    
                }
            }else{
                UIView.transition(with: self.containerViewSlideCollection, duration: 0.2,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        
                        self.leadingContraintProviderContainer.constant = -20.0
                        self.containerViewSlideCollection.isHidden = true
                        self.containerViewSlideShowButton.isHidden = true
                    }
                })
                self.collectionObj.isHidden = true
            }
        }
    }
    
    
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        //21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
            if (error != nil)
            {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            let pm = placemarks! as [CLPlacemark]
            
            if pm.count > 0 {
                let pm = placemarks![0]
                var addressString : String = ""
                if pm.subLocality != nil {
                    addressString = addressString + pm.subLocality! + ", "
                }
                if pm.thoroughfare != nil {
                    addressString = addressString + pm.thoroughfare! + ", "
                }
                if pm.locality != nil {
                    addressString = addressString + pm.locality! + ", "
                }
                if pm.country != nil {
                    addressString = addressString + pm.country! + ", "
                }
                if pm.postalCode != nil {
                    addressString = addressString + pm.postalCode! + " "
                }
                
                self.txtFldLocation.text = addressString
            }
        })
    }
    
    @objc func reloadMapData() {
        
        self.isWebserviceCalled = false
        mylocation()
    }
    
    @objc func goToChat() {
        self.manageUserDetailState = false
        UserDefaults.standard.set(false, forKey: "forNotification")
        
        let storyboard = UIStoryboard.init(name: "Messages", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        
        chatVC.toId = UserDefaults.standard.value(forKeyPath: "toId") as! String
        chatVC.jobId = UserDefaults.standard.value(forKeyPath: "jobId") as! String
        chatVC.fromId = UserSettings.userID
        // chatVC.senderID =
        chatVC.userName = UserDefaults.standard.value(forKeyPath: "userName") as! String
        chatVC.userProfilePath = UserDefaults.standard.value(forKeyPath: "userProfilePic") as! String
        chatVC.isFromNotification = true
        
        if (UserDefaults.standard.value(forKeyPath: "jobId") as! String) == "" {
            chatVC.isForJobChat = false
        }
        else {
            chatVC.isForJobChat = true
        }
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc func goToNotificationJobProfile() {
        UserDefaults.standard.set(false, forKey: "forJobNotification")
        let jobID = UserDefaults.standard.value(forKeyPath: "jobId") as! String
        //let jobID = "278"
        
        let dict = [
            APIManager.Parameter.jobID : jobID
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_JobDetails, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                let userData = dataDict["data"] as! NSArray
                let myDict = userData.object(at: 0) as! NSDictionary
                
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "JobProfileVC") as! JobProfileVC
                vc.dictJobDetails = myDict as! NSDictionary
                vc.userDict = (myDict as AnyObject).value(forKey: "user") as! NSDictionary
                vc.isFromMessages = true
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        }
    }
    
    @objc func goToCommentsNotificationJobProfile() {
        //UserDefaults.standard.set(false, forKey: "forCommentNotification")
        let jobID = UserDefaults.standard.value(forKeyPath: "jobId") as! String
        //let jobID = "278"
        
        let dict = [
            APIManager.Parameter.jobID : jobID
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_JobDetails, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                let userData = dataDict["data"] as! NSArray
                let myDict = userData.object(at: 0) as! NSDictionary
                
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "JobProfileVC") as! JobProfileVC
                vc.dictJobDetails = myDict as! NSDictionary
                vc.userDict = (myDict as AnyObject).value(forKey: "user") as! NSDictionary
                vc.isFromMessages = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        }
    }
    
    func mylocation()   {
        DispatchQueue.main.async {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()

            // Ask for Authorisation from the User.

            // For use in foreground

            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
            }
        }

    }
    
    func centerMapOnLocation(location: CLLocation) {
        
        //        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15.0)
        //        self.objGoogleMap.camera = camera
        //        self.objGoogleMap.animate(to: camera)
        //Map Animation
        let locationObj =  CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //CATransaction.begin()
        //CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
        DispatchQueue.main.async {
            //self.objGoogleMap.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: 15))
        }
        
        //CATransaction.commit()
        /*let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
         latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
         mapView.setRegion(coordinateRegion, animated: true)
         mapView.setCenter(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), animated: true)*/
    }
    
    @objc func btnBookNowClicked(_sender : UIButton) {
        
        self.selectedTag = _sender.tag
        self.performSegue(withIdentifier: "showJobProfile", sender: self)
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    func configureProviderImageViewStackView(){
        /*
         self.viewProviderImage2.isHidden = true
         self.viewProviderImage3.isHidden = true
         self.viewProviderImage4.isHidden = true
         self.viewProviderImage5.isHidden = true
         self.viewProviderImage6.isHidden = true
         
         if self.arrayOfKeywordSearchProvider.count > 0{
         self.viewProviderImage2.isHidden = false
         let objprovider = self.arrayOfKeywordSearchProvider[0]
         if let businessLogo = objprovider.customerDetail["profile_pic"]{
         if let imageURL = URL.init(string: "\(businessLogo)"){
         self.viewProviderImage2.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "Logo_Loading"), options: .refreshCached, context: nil)
         }
         }
         
         if self.arrayOfKeywordSearchProvider.count > 1{
         self.viewProviderImage3.isHidden = false
         let objprovider = self.arrayOfKeywordSearchProvider[1]
         if let businessLogo = objprovider.customerDetail["profile_pic"]{
         if let imageURL = URL.init(string: "\(businessLogo)"){
         self.viewProviderImage3.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "Logo_Loading"), options: .refreshCached, context: nil)
         }
         }
         
         }
         
         if self.arrayOfKeywordSearchProvider.count > 2{
         self.viewProviderImage4.isHidden = false
         let objprovider = self.arrayOfKeywordSearchProvider[2]
         if let businessLogo = objprovider.customerDetail["profile_pic"]{
         if let imageURL = URL.init(string: "\(businessLogo)"){
         self.viewProviderImage4.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "Logo_Loading"), options: .refreshCached, context: nil)
         }
         }
         
         }
         
         if self.arrayOfKeywordSearchProvider.count > 3{
         self.viewProviderImage5.isHidden = false
         let objprovider = self.arrayOfKeywordSearchProvider[3]
         if let businessLogo = objprovider.customerDetail["profile_pic"]{
         if let imageURL = URL.init(string: "\(businessLogo)"){
         self.viewProviderImage5.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "Logo_Loading"), options: .refreshCached, context: nil)
         }
         }
         
         }
         if self.arrayOfKeywordSearchProvider.count > 4{
         self.viewProviderImage6.isHidden = false
         let objprovider = self.arrayOfKeywordSearchProvider[4]
         if let businessLogo = objprovider.customerDetail["profile_pic"]{
         if let imageURL = URL.init(string: "\(businessLogo)"){
         self.viewProviderImage6.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "Logo_Loading"), options: .refreshCached, context: nil)
         }
         }
         
         }else{
         
         }
         }
         */
    }
    //MARK: - API Calls
    func callAPIRequestToGetChatUnreadCount(){
        if let currentUser = UserDetail.getUserFromUserDefault(){
            guard currentUser.userRoleType == .customer else {
                return
            }
        }
        APIRequestClient.shared.sendAPIRequest(requestType: .GET, queryString:kGETChatUnreadCount, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["success_data"] as? Int{
                DispatchQueue.main.async {
                   // ExternalClass.ShowProgress()
                    self.totalUnreadMessage = successData
                }
            }else{
                DispatchQueue.main.async {
                    //                             SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
                    APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kGETChatUnreadCount)")
                    //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
    }
    func callAPIRequestToGetProviderBasedOnSearchKeyword(keyword:String,latitude:String = "",longitude:String = "",isFirstTime:Bool = false){
        if let currentUser = UserDetail.getUserFromUserDefault(){
            guard currentUser.userRoleType == .customer else {
                return
            }
        }
        DispatchQueue.main.async {
            ExternalClass.ShowProgress()
        }
        APIRequestClient.shared.cancelTaskWithUrl { (completed) in
            DispatchQueue.main.async {
                ExternalClass.ShowProgress()
            }
            self.callAPIRequestToGetChatUnreadCount()
            
            var dict:[String:Any] = [
                "keyword" : self.txtSearch.text ?? "",
                "lat" : "\(latitude)",
                "lng" : "\(longitude)",
                "left_topcorner" : "\(self.objGoogleMap.projection.visibleRegion().farLeft.getCommaSeperatedLatLongString())",
                "right_topcorner": "\(self.objGoogleMap.projection.visibleRegion().farRight.getCommaSeperatedLatLongString())",
                "left_bottomcorner": "\(self.objGoogleMap.projection.visibleRegion().nearLeft.getCommaSeperatedLatLongString())",
                "right_bottomcorner": "\(self.objGoogleMap.projection.visibleRegion().nearRight.getCommaSeperatedLatLongString())",
                "is_first_time" : isFirstTime
            ]
            self.isFirstTimeKeywordSearch = isFirstTime
            if latitude.count > 0 && longitude.count > 0{
                self.lastSearchLatForKeyword = "\(latitude)"
                self.lastSearchLngForKeyword = "\(longitude)"
            }else{
                dict["lat"] = "\(self.currentLat)"
                dict["lng"] =  "\(self.currentLong)"

                self.lastSearchLatForKeyword = "\(self.currentLat)"
                self.lastSearchLngForKeyword = "\(self.currentLong)"
            }
//            guard self.currentLat == 0.0 && self.currentLong == 0.0 else {
//                DispatchQueue.main.async {
//                    SAAlertBar.show(.error, message: "Your Location is disable please enable it from settings.")
//                }
//                return
//            }
            self.currentMapScale = "\(self.objGoogleMap.camera.zoom)"
            
            APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kListOfProviderOnKeywordSearch , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [[String:Any]]{
                    if let searchKeyword = success["search_keyword"]{
                        self.currentSearchKeyword = keyword.count  >  0 ? "\(searchKeyword)" : ""//"\(searchKeyword)"
                    }else{
                        self.currentSearchKeyword = ""
                    }
                    DispatchQueue.main.async {
                        if isFirstTime{
                            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                    var delayTime = 1.0
                                    if let lat = self.currentUserdefault.value(forKey: KcurrentUserLocationLatitude) as? Double, let lng = self.currentUserdefault.value(forKey: KcurrentUserLocationLongitude) as? Double{
                                        if lat != 0.0 && lng != 0.0{
                                            delayTime = 1.0
                                        }else{
                                            delayTime = appDelegate.currentLocationDelay
                                        }
                                    }else{
                                        delayTime = appDelegate.currentLocationDelay
                                    }
                                DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                                    if self.currentLat != 0.0 && self.currentLong != 0.0{
                                        let userLocation = CLLocationCoordinate2D.init(latitude: self.currentLat, longitude: self.currentLong)
                                        if let mileScale = success["mile_scale"],let doubleMileScale = Double("\(mileScale)"){
                                            let cirlce = GMSCircle(position: userLocation, radius: doubleMileScale*1609.344)
                                            cirlce.fillColor = UIColor.clear
                                            cirlce.strokeWidth = 0
                                            cirlce.map = self.objGoogleMap
                                            let update = GMSCameraUpdate.fit(cirlce.bounds())
                                            self.objGoogleMap.animate(with: update)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                // Put your code which should be executed with a delay here
                                                self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: self.txtSearch.text ?? "",isFirstTime: false)
                                            }
                                        }
                                    }
                                }
                            }
                        }else{
                            if arrayOfJOB.count > 0 {
//                                self.objGoogleMap.clear()
                                self.arrayOfKeywordSearchProvider.removeAll()
                                
                                for objJOb in arrayOfJOB{
                                    let notifyProvider = NotifiedProviderOffer.init(providersDetail: objJOb)
                                    //if self.objGoogleMap.projection.contains(location){
                                    self.arrayOfKeywordSearchProvider.append(notifyProvider)
                                    //}
                                }
                                if self.isFromDidselectSearchKeyword{ //for keyword search
                                    if (self.arrayOfProvidersNotified.count > 0 || self.arrayOfProvidersNotified.count == 0) && self.arrayOfKeywordSearchProvider.count > 0{
                                        if isFirstTime{
                                            self.zoomOutMapTo3PinByDefault()
                                            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                                                //self.currentPage = 0
                                                if self.arrayOfKeywordSearchProvider.count > 0{
                                                    self.currentKeyWordSearchProvider = self.arrayOfKeywordSearchProvider[0]
                                                    self.setSelectedMarkerWithUpdatedColorIndex(index: 0,isFromMap: true)
                                                }
                                            }
                                        }else{
                                            if self.arrayOfKeywordSearchProvider.count > 0{
                                                self.currentKeyWordSearchProvider = self.arrayOfKeywordSearchProvider[0]
                                            }
                                            self.setSelectedMarkerWithUpdatedColorIndex(index: 0,isFromMap: true)
                                        }
                                        self.hideColllectionViewandShowSlider()
                                        self.keywordSearchColllectionView.reloadData()
                                        self.keywordSearchColllectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredHorizontally, animated: true)

                                    }else if self.arrayOfProvidersNotified.count > 0 && self.arrayOfKeywordSearchProvider.count == 0{
                                        self.showCollectionViewHideCollectionSlider()
                                    }
                                }else{
                                    if self.arrayOfProvidersNotified.count > 0{
                                        self.showCollectionViewHideCollectionSlider()
                                    }else{
                                        if self.arrayOfKeywordSearchProvider.count > 0{
                                            if isFirstTime{
                                                self.zoomOutMapTo3PinByDefault()
                                                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                                                    //self.currentPage = 0
                                                    if self.arrayOfKeywordSearchProvider.count > 0{
                                                        self.currentKeyWordSearchProvider = self.arrayOfKeywordSearchProvider[0]
                                                        self.setSelectedMarkerWithUpdatedColorIndex(index: 0,isFromMap: true)
                                                    }
                                                }
                                            }else{
                                                if self.arrayOfKeywordSearchProvider.count > 0{
                                                    self.currentKeyWordSearchProvider = self.arrayOfKeywordSearchProvider[0]
                                                }
                                                self.setSelectedMarkerWithUpdatedColorIndex(index: 0,isFromMap: true)
                                            }
                                            self.hideColllectionViewandShowSlider()
                                            self.keywordSearchColllectionView.reloadData()
                                            self.keywordSearchColllectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredHorizontally, animated: true)


                                        }
                                    }
                                    DispatchQueue.main.async {
                                        UIView.performWithoutAnimation {
                                            self.keywordSearchColllectionView.reloadData()
                                            self.collectionObj.reloadData()
                                        }
                                    }
                                }
                            }else{
                                
                                self.arrayOfKeywordSearchProvider.removeAll()
                                self.keywordSearchColllectionView.reloadData()
                                self.collectionObj.reloadData()
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
                        APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kListOfProviderOnKeywordSearch)")
                        //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                    }
                }
            }
        }
    }
    func callAPIRequestToGetListOfJOB(searchKeyword:String,isFirstTime:Bool = false){
        //kListOfJOBCustomerHome
        if let currentUser = UserDetail.getUserFromUserDefault(){
            guard currentUser.userRoleType == .customer else {
                return
            }
        }
        let dict:[String:Any] = [
            "status" : "pending",
        ]
        DispatchQueue.main.async {
            ExternalClass.ShowProgress()
        }
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kListOfJOBCustomerHome , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                ExternalClass.ShowProgress()
            }
            if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [[String:Any]]{
                self.arrayOfProvidersNotified.removeAll()
                if arrayOfJOB.count > 0 {
                    
                    for objJOb in arrayOfJOB{
                        
                        let notifyProvider = NotifiedProviderOffer.init(providersDetail: objJOb)
                        self.arrayOfProvidersNotified.append(notifyProvider)
                        
                    }
                    
                }
                
                DispatchQueue.main.async {
                    if let objTabView = self.navigationController?.tabBarController as? MyTabController{
                        if let numberOfItem = objTabView.tabBar.items, numberOfItem.count > 0{
                            let objTabBarItem = numberOfItem[2]
                            if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first{
                                print("\(window.safeAreaInsets.bottom)----")
                                //objTabBarItem.imageInsets = UIEdgeInsets.init(top: 0, left: -50, bottom: -(window.safeAreaInsets.bottom), right: -50)
                                
                            }
                            
                        }
                        
                        if self.arrayOfProvidersNotified.count > 0{
                            self.selectedTag = 0
//                            self.checkforcustomerOfferMarkerWithInScreen()
                            objTabView.addAnimatedCustomView()
                        }else{
                            objTabView.removeCustomView()
                        }
                    }
                    
                    self.viewLeft.isHidden = true
                    self.viewRight.isHidden = true//(self.arrayOfProvidersNotified.count > 2) ? false : true
                    //add marker on google map
                    self.setLocationMakerOnGoogleMap()
                    
                    if self.arrayOfProvidersNotified.count > 0 && self.arrayOfKeywordSearchProvider.count == 0{
                        self.showCollectionViewHideCollectionSlider()
                    }else if self.arrayOfProvidersNotified.count > 0 && self.arrayOfKeywordSearchProvider.count > 0{
                        self.showCollectionViewHideCollectionSlider()
                        //self.hideColllectionViewandShowSlider()
                    }
                    self.collectionObj.reloadData()
                    self.collectionObj.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                }
            }else{
                DispatchQueue.main.async {
                   // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
            
            self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(searchKeyword)",isFirstTime: isFirstTime)
            
        }) { (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String]{
                DispatchQueue.main.async {
                    if errorMessage.count > 0{
                        SAAlertBar.show(.error, message:"\(errorMessage.first!)".localizedLowercase)
                    }
                }
            }else{

                DispatchQueue.main.async {
                    APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kListOfJOBCustomerHome)")
                    //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
    }
    func setLocationMakerOnGoogleMap(){
        if self.arrayOfProvidersNotified.count > 0{
            self.objGoogleMap.clear()
        }

        
        for (index, obj) in self.arrayOfProvidersNotified.enumerated(){
            var latitudeString = "\(obj.lat)"
            var longitudeString = "\(obj.lng)"
            
            print(latitudeString)
            print(latitudeString)
            let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((latitudeString as NSString).doubleValue), longitude: Double((longitudeString as NSString).doubleValue))
            //                          let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15.0)
            //                          self.objGoogleMap.camera = camera
            //                          self.objGoogleMap.animate(to: camera)
            //Map Animation
            let locationObj =  CLLocationCoordinate2DMake(location.latitude, location.longitude)
            //CATransaction.begin()
            //CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
            DispatchQueue.main.async {
                //                self.objGoogleMap.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: 15))
            }
            
            //CATransaction.commit()
            
            let marker = GMSMarker(position: location)
            marker.userData = index
            let objView = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 100, height: 30.0)))
            objView.backgroundColor = .black
            var strRating = "\(obj.rating)"
            if let pi: Double = Double("\(obj.rating)"){
                let rating = String(format:"%.1f", pi)
                strRating = "\(rating)"
            }
            print(obj.isPreOffer)
            if let ispreoffer = obj.isPreOffer.bool{
                if ispreoffer{ //pre offer true and no offer price as pre offer available
                    marker.iconView = CustomMarker.instanceFromNib(withName: "\(obj.businessName)", rating: "\(strRating)")
                }else{ //preoffer done and now use offer price
                    if obj.promotion.count > 0{
                        marker.iconView = CustomMarker.instanceFromNib(withName: "\(obj.finalPrice)".add2DecimalString, rating: "\(strRating)")
                    }else{
                        marker.iconView = CustomMarker.instanceFromNib(withName: "\(obj.offerPrice)".add2DecimalString, rating: "\(strRating)")

                    }
                }
            }
            //                            if self.isFromAddJOB{
            //                                marker.iconView = CustomMarker.instanceFromNib(withName: "\(obj.businessName)", rating: "\(strRating)")
            //                            }else{
            //                                marker.iconView = CustomMarker.instanceFromNib(withName: "$ \(obj.offerPrice)", rating: "\(strRating)")
            //                            }
            marker.map = self.objGoogleMap
        }
        
        defer{
            if let _ = self.selectedTag{
                self.setProviderSelectedMarkerWithUpdatedColorIndex(index:self.selectedTag!,isFromMap: true)
            }
            //            self.setCenterToCurrentLocation()
        }
        
    }
    func setLocationOfKeywordSearchProviderOnMap(){
        if self.arrayOfKeywordSearchProvider.count > 0{
            self.objGoogleMap.clear()
        }

        
        for (index, obj) in self.arrayOfKeywordSearchProvider.enumerated(){
            var latitudeString = "\(obj.lat)"
            var longitudeString = "\(obj.lng)"
            
            print(latitudeString)
            print(latitudeString)
            let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((latitudeString as NSString).doubleValue), longitude: Double((longitudeString as NSString).doubleValue))
            //                    let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: self.objGoogleMap.camera.zoom)
            //                                  self.objGoogleMap.camera = camera
            //                                  self.objGoogleMap.animate(to: camera)
            //Map Animation
            let locationObj =  CLLocationCoordinate2DMake(location.latitude, location.longitude)
            ///CATransaction.begin()
            //CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
            DispatchQueue.main.async {
                //                        self.objGoogleMap.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: 15))
            }
            
            //CATransaction.commit()
            let marker = GMSMarker(position: location)
            marker.userData = index
            let objView = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 100, height: 30.0)))
            objView.backgroundColor = .black
            var strRating = "\(obj.rating)"
            if let pi: Double = Double("\(obj.rating)"){
                let rating = String(format:"%.1f", pi)
                strRating = "\(rating)"
            }
            
            marker.iconView = CustomMarker.instanceFromNib(withName: "\(obj.businessName)", rating: "\(strRating)")
            marker.map = self.objGoogleMap
        }
        
        
        defer{
            //self.setCenterToCurrentLocation()
        }
    }
    //MARK: CALL book job api
    func callbookjobapireqest(dict:[String:Any]){
        
        
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kBookJOB , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            self.callAPIRequestToGetListOfJOB(searchKeyword: "")
            if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [String:Any]{
                DispatchQueue.main.async {
                    if let objTabView = self.navigationController?.tabBarController{
                        print(objTabView.viewControllers)
                        if let objHomeNavigation:UINavigationController = objTabView.viewControllers?[1] as? UINavigationController{
                            if let objMyPost:MessagesVC = objHomeNavigation.viewControllers.first as? MessagesVC{
                                objTabView.selectedIndex = 1
                                objMyPost.selectedIndexFromNotification = 1
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
                    APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kBookJOB)")
                    //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
        
        
    }
    func callAPIToGetMyNetworkUsers() {
        
        let dict = [
            APIManager.Parameter.fromID : UserSettings.userID,
            APIManager.Parameter.limit : "50",
            APIManager.Parameter.page : "1"
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_NetworkList, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as? Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                if (dataDict["data"] as! NSArray).count != 0 {
                    
                    self.arrMyNetworkUsers = dataDict["data"] as! NSArray
                    
                    var networkData = [NetworkModel]()
                    
                    if NetworkModel.Shared.arrUsers.count > 0 {
                        NetworkModel.Shared.arrUsers.removeAll()
                    }
                    
                    for user in self.arrMyNetworkUsers {
                        
                        let dict = user as! NSDictionary
                        let dataDict = dict.value(forKey: "to_user") as! NSDictionary
                        let DataObject = NetworkModel()
                        DataObject.JsonParseFromDict(dataDict as! JSONDICTIONARY)
                        networkData.append(DataObject)
                        NetworkModel.Shared.arrUsers.append(DataObject)
                    }
                }
            }
        }
    }
    
    func callAPIToGetJobList() {
        
        if !isKeyPresentInUserDefaults(key: "userID") {
            UserDefaults.standard.set("0", forKey: "userID")
            UserSettings.userID = "0"
        }
        
        let userID = UserSettings.userID
        
        let dict = [
            APIManager.Parameter.latitude : String(self.currentLat),
            APIManager.Parameter.longitude : String(self.currentLong),
            APIManager.Parameter.radius : rangeLimit,
            APIManager.Parameter.userID : userID,
            APIManager.Parameter.limit : "50",
            APIManager.Parameter.page : "1",
            APIManager.Parameter.filterDescription : self.filterDescription,
            APIManager.Parameter.categoryIds : self.categoryIDS
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_JobList, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                if self.mapView.annotations.count > 0 {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                }
                
                let location = CLLocation(latitude: self.currentLat, longitude: self.currentLong)
                self.centerMapOnLocation(location: location)
                
                if (dataDict["data"] as! NSArray).count == 0 {
                    
                    self.collectionObj.isHidden = true
                    self.lblNoJobExists.isHidden = false
                }
                else {
                    self.collectionObj.isHidden = false
                    self.lblNoJobExists.isHidden = true
                    
                    let jobs = dataDict["data"] as! NSArray
                    
                    var jobsData = [JobsModel]()
                    
                    if JobsModel.Shared.arrJobs.count > 0 {
                        JobsModel.Shared.arrJobs.removeAll()
                    }
                    
                    for job in jobs {
                        let DataObject = JobsModel()
                        DataObject.JsonParseFromDict(job as! JSONDICTIONARY)
                        jobsData.append(DataObject)
                        JobsModel.Shared.arrJobs.append(DataObject)
                    }
                    
                    self.addannotation()
                    
                    self.collectionObj.reloadData()
                }
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        }
    }
    
    func callLoginAPI() {
        
        var deviceToken = String()
        if isKeyPresentInUserDefaults(key: "fcmToken") {
            deviceToken = UserDefaults.standard.object(forKey: "fcmToken") as! String
        }
        else{
            deviceToken = "Sujal"
        }
        
        
        let dict = [
            APIManager.Parameter.email : UserSettings.emailText,
            APIManager.Parameter.password : UserSettings.PasswordText,
            APIManager.Parameter.deviceToken : deviceToken,
            APIManager.Parameter.platform : "ios"
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_Login, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                self.loginWSCalled = true
                
                let userData = dataDict["data"] as! JSONDICTIONARY
                
                let userIDNumber = userData["id"] as! NSNumber
                
                let userId:String = String(format:"%d", userIDNumber.intValue)
                
                UserSettings.userID = userId
                UserSettings.isUserLogin = true
                
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
                
                self.mylocation()
                
                DispatchQueue.main.async {
                    let vc = self.so_containerViewController?.sideViewController as! SettingsVC
                    vc.reloadTableData()
                }
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                if message == "We can`t find an account with this credentials." {
                    
                    UserSettings.isUserLogin = false
                    UserDefaults.standard.set("0", forKey: "userID")
                    UserSettings.userID = "0"
                    UserDefaults.standard.set(false, forKey: "LocationUpdated")
                    self.clearModelData()
                    self.mylocation()
                    self.isWebserviceCalled = true
                }
                else {
                    //                    SAAlertBar.show(.error, message:message.capitalized)
                }
            }
        }
    }
    
    func updateLocationAPI() {
        
        UserDefaults.standard.set(true, forKey: "LocationUpdated")
        
        UserRegister.Shared.mediaArray = NSMutableArray.init()
        UserRegister.Shared.userId = UserSettings.userID
        UserRegister.Shared.email = CurrentUserModel.Shared.email
        
        APIManager.sharedInstance.CallAPIRegisterUser(parameter: UserRegister.Shared, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY!)
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    
    func clearModelData() {
        
        UserRegister.Shared.deviceToken = ""
        UserRegister.Shared.vProfilepic = nil
        UserRegister.Shared.vfileKey = ""
        UserRegister.Shared.vchunkedMode = ""
        UserRegister.Shared.vmimeType = ""
        UserRegister.Shared.vTimestamp = ""
        UserRegister.Shared.userType = ""
        
        UserRegister.Shared.firstName = ""
        UserRegister.Shared.lastName = ""
        UserRegister.Shared.companyName = ""
        
        if UserSettings.isUserLogin == true {
            UserRegister.Shared.userId = UserSettings.userID
        }
        else {
            UserRegister.Shared.userId = ""
        }
        
        UserSettings.isUserLogin = false
        UserSettings.PasswordText = ""
        UserDefaults.standard.set("0", forKey: "userID")
        UserSettings.userID = "0"
        
        UserRegister.Shared.phone = ""
        UserRegister.Shared.password = ""
        UserRegister.Shared.EIN = ""
        UserRegister.Shared.companyAddress = ""
        UserRegister.Shared.insurance = ""
        
        UserRegister.Shared.tagline = ""
        UserRegister.Shared.companyDescription = ""
        UserRegister.Shared.mediaArray = NSMutableArray.init()
        
        NotificationCenter.default.post(name: Notification.Name("UserSignOutNotification"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("UserSignInOutNotification"), object: nil)
    }
    
    //MARK:- Register Cell
    
    func RegisterCell()  {
        self.collectionObj.register(UINib.init(nibName: "UpdateCustomerHomeProviderTableViewCell", bundle: nil), forCellWithReuseIdentifier: "UpdateCustomerHomeProviderTableViewCell")
        self.collectionObj.register(UINib.init(nibName: "JobCell", bundle: nil), forCellWithReuseIdentifier: "JobCell")
        self.keywordSearchColllectionView.register(UINib.init(nibName: "KeywordResultCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "KeywordResultCollectionViewCell")
        
        self.keywordSearchColllectionView.tag = 300
        let floawLayout = UPCarouselFlowLayout()
        floawLayout.itemSize = CGSize(width: self.keywordSearchColllectionView.bounds.width - 40.0, height: self.keywordSearchColllectionView.bounds.height - 10.0)
        floawLayout.scrollDirection = .horizontal
        floawLayout.sideItemScale = 0.95
        floawLayout.sideItemAlpha = 1.0
        floawLayout.spacingMode = .fixed(spacing: 10.0)
        floawLayout.sideItemShift = 6.0
        self.keywordSearchColllectionView.collectionViewLayout = floawLayout
        self.keywordSearchColllectionView.delegate = self
        self.keywordSearchColllectionView.dataSource = self
        self.keywordSearchColllectionView.reloadData()
        self.keywordSearchColllectionView.backgroundColor = UIColor.clear
        
        let floawLayoutOffer = UPCarouselFlowLayout()
        floawLayoutOffer.itemSize = CGSize(width: self.collectionObj.bounds.width - 40.0, height: self.collectionObj.bounds.height - 10.0)
        floawLayoutOffer.scrollDirection = .horizontal
        floawLayoutOffer.sideItemScale = 0.95
        floawLayoutOffer.sideItemAlpha = 1.0
        floawLayoutOffer.spacingMode = .fixed(spacing: 10.0)
        floawLayoutOffer.sideItemShift = 6.0
        self.collectionObj.collectionViewLayout = floawLayoutOffer
        self.collectionObj.reloadData()
        
        //        self.collectionObj.collectionViewLayout = floawLayout
    }
    
    //MARK:- uicollectionView DataSource Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.tag != 300 else {
            return
        }
        DispatchQueue.main.async {
            //            self.viewRight.isHidden = true
            //            self.viewLeft.isHidden = true
            //            self.checkForHideShowRightLeftScrollButton()
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView.tag != 300 else {
            return
        }
        DispatchQueue.main.async {
            self.viewLeft.isHidden =  true
            self.viewRight.isHidden = true
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.tag != 300 else {
            return
        }
        //        self.checkForHideShowRightLeftScrollButton()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView.tag != 300 else {
            /*if let layout = self.keywordSearchColllectionView.collectionViewLayout as? UPCarouselFlowLayout{
             let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
             let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
             self.currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
             }*/
            let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
            if let ip = self.keywordSearchColllectionView.indexPathForItem(at: center) {
                self.currentPage = ip.row
            }
            return
        }
        let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
        if let ip = self.collectionObj.indexPathForItem(at: center) {
            self.selectedTag = ip.row
            if let _ = self.selectedTag{
                self.collectionObj.scrollToItem(at: IndexPath(item: self.selectedTag!, section: 0), at: .centeredHorizontally, animated: true)
                self.setProviderSelectedMarkerWithUpdatedColorIndex(index:self.selectedTag!,isFromMap: true)
                self.collectionObj.reloadData()
                self.checkforcustomerOfferMarkerWithInScreen()
            }
        }
        
        
        
        
        //        self.checkForHideShowRightLeftScrollButton()
        /*
         if scrollView.contentOffset.x + 180 >= (scrollView.contentSize.width - scrollView.frame.size.width){
         
         print("riched right")
         DispatchQueue.main.async {
         self.viewRight.isHidden = true
         self.viewLeft.isHidden = (self.arrayOfProvidersNotified.count > 2) ?  false : true
         }
         }else if scrollView.contentOffset.x == 0{
         DispatchQueue.main.async {
         self.viewLeft.isHidden = true
         self.viewRight.isHidden = (self.arrayOfProvidersNotified.count > 2) ?  false : true
         }
         print("riched left")
         
         }else{
         
         DispatchQueue.main.async {
         self.viewLeft.isHidden = (self.arrayOfProvidersNotified.count > 2) ?  false : true
         self.viewRight.isHidden = (self.arrayOfProvidersNotified.count > 2) ?  false : true
         }
         }*/
    }
    fileprivate var currentPage: Int = 0 {
        didSet {
            print("page at centre = \(currentPage)")
            
            if self.arrayOfKeywordSearchProvider.count > currentPage{
                self.currentKeyWordSearchProvider = self.arrayOfKeywordSearchProvider[currentPage]
            }
            
            self.setSelectedMarkerWithUpdatedColorIndex(index: currentPage,isFromMap: true)
            
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                let lat = Double("\(self.currentKeyWordSearchProvider.lat)") ?? 0.0
                let lng = Double("\(self.currentKeyWordSearchProvider.lng)") ?? 0.0
                let markerPosition: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:lat, longitude:lng)
                print("------- \(self.isMarkerWithinScreen(markerPosition: markerPosition))")
                if self.isMarkerWithinScreen(markerPosition: markerPosition){
                    
                }else{
                    //let camera = GMSCameraPosition.init(latitude: lat, longitude: lng, zoom: self.objGoogleMap.camera.zoom)
                    //                    self.objGoogleMap.camera = camera
                    //                    self.objGoogleMap.animate(to: camera)
                    
                    let markerpoint = self.objGoogleMap.projection.point(for: markerPosition)
                    print("------ \(markerpoint.x)")
                    print("------ \(markerpoint.y)")
                    var scrollX:CGFloat = 0
                    var scrollY:CGFloat = 0
                    if markerpoint.x > 0 && markerpoint.x < UIScreen.main.bounds.width{
                        if markerpoint.x > 0{
                            scrollX = 50
                        }else{
                            scrollX = -50
                        }
                    }else{
                        if markerpoint.x > 0{
                            if markerpoint.x > UIScreen.main.bounds.width{
                                scrollX =  markerpoint.x - UIScreen.main.bounds.width
                                scrollX += 50
                            }else{
                                scrollX =  markerpoint.x + 50
                            }
                        }else{
                            scrollX = markerpoint.x + -50
                        }
                    }
                    let miniMumY = self.searchViewContainer.frame.maxY
                    let maxMumY = self.viewProviderContainerView.frame.minY - 88.0
                    if markerpoint.y > miniMumY && markerpoint.y < maxMumY{
                        if markerpoint.y > miniMumY{
                            scrollY = 10
                        }else{
                            scrollY = -10
                        }
                    }else{
                        if markerpoint.y > miniMumY{
                            if markerpoint.y > maxMumY{
                                scrollY =  markerpoint.y - maxMumY
                                scrollY += 10
                            }else{
                                scrollY =  markerpoint.y + 10
                            }
                        }else{
                            scrollY = markerpoint.y + -miniMumY + -10
                        }
                        
                    }
                    let downwards = GMSCameraUpdate.scrollBy(x: scrollX, y: scrollY)
                    self.objGoogleMap.animate(with: downwards)
                    self.lastSearchLatForKeyword = "\(self.objGoogleMap.camera.target.latitude)"
                    self.lastSearchLngForKeyword = "\(self.objGoogleMap.camera.target.longitude)"
                }
                //                self.floatingView.center = self.lastCenter
            }
            
        }
    }
    fileprivate func checkforcustomerOfferMarkerWithInScreen(){
        if let currentOfferTag = self.selectedTag{
            if self.arrayOfProvidersNotified.count > currentOfferTag{
                let offerNotifiedProvider = self.arrayOfProvidersNotified[currentOfferTag]
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    let lat = Double("\(offerNotifiedProvider.lat)") ?? 0.0
                    let lng = Double("\(offerNotifiedProvider.lng)") ?? 0.0
                    let markerPosition: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:lat, longitude:lng)
                    print("------- \(self.isMarkerWithinScreen(markerPosition: markerPosition))")
                    if self.isMarkerWithinScreen(markerPosition: markerPosition){
                        
                    }else{
                        let markerpoint = self.objGoogleMap.projection.point(for: markerPosition)
                        print("------ \(markerpoint.x)")
                        print("------ \(markerpoint.y)")
                        var scrollX:CGFloat = 0
                        var scrollY:CGFloat = 0
                        if markerpoint.x > 0 && markerpoint.x < UIScreen.main.bounds.width{
                            if markerpoint.x > 0{
                                scrollX = 50
                            }else{
                                scrollX = -50
                            }
                        }else{
                            if markerpoint.x > 0{
                                if markerpoint.x > UIScreen.main.bounds.width{
                                    scrollX =  markerpoint.x - UIScreen.main.bounds.width
                                    scrollX += 50
                                }else{
                                    scrollX =  markerpoint.x + 50
                                }
                            }else{
                                scrollX = markerpoint.x + -50
                            }
                        }
                        let miniMumY = self.searchViewContainer.frame.maxY
                        let maxMumY = self.viewProviderContainerView.frame.minY - 88.0
                        if markerpoint.y > miniMumY && markerpoint.y < maxMumY{
                            if markerpoint.y > miniMumY{
                                scrollY = 10
                            }else{
                                scrollY = -10
                            }
                        }else{
                            if markerpoint.y > miniMumY{
                                if markerpoint.y > maxMumY{
                                    scrollY =  markerpoint.y - maxMumY
                                    scrollY += 10
                                }else{
                                    scrollY =  markerpoint.y + 10
                                }
                            }else{
                                scrollY = markerpoint.y + -miniMumY + -10
                            }
                            
                        }
                        let downwards = GMSCameraUpdate.scrollBy(x: scrollX, y: scrollY)
                        self.objGoogleMap.animate(with: downwards)
                    }
                    
                }
            }
        }
    }
    fileprivate func isMarkerWithinScreen(markerPosition: CLLocationCoordinate2D) -> Bool {
        let markerpoint = self.objGoogleMap.projection.point(for: markerPosition)
        print(markerpoint.x)
        print(markerpoint.y)
        print(self.searchViewContainer.frame)
        print(self.viewProviderContainerView.frame)
        let miniMumY = self.searchViewContainer.frame.maxY
        let maxMumY = self.viewProviderContainerView.frame.minY - 44.0
        
        let region = self.objGoogleMap.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: region)
        if bounds.contains(markerPosition){
            return (markerpoint.y > miniMumY && markerpoint.y < maxMumY)
        }else{
            return false
        }
        
    }
    fileprivate func zoomOutMapTo3PinByDefault(){
        /*
        var bounds = GMSCoordinateBounds()
        for objprovider in self.arrayOfKeywordSearchProvider{
            bounds =  bounds.includingCoordinate(CLLocationCoordinate2D(latitude: Double("\(objprovider.lat)") ?? 0.0, longitude: Double("\(objprovider.lng)") ?? 0.0))
        }
        DispatchQueue.main.async {
            let update = GMSCameraUpdate.fit(bounds)//(bounds, withPadding: 200.0)
            self.objGoogleMap.animate(with: update)
        }*/
    }
    fileprivate func zoomOutMapToOfferByDefault(){
        /*var bounds = GMSCoordinateBounds()
        for objprovider in self.arrayOfProvidersNotified{
            bounds =  bounds.includingCoordinate(CLLocationCoordinate2D(latitude: Double("\(objprovider.lat)") ?? 0.0, longitude: Double("\(objprovider.lng)") ?? 0.0))
        }
        DispatchQueue.main.async {
            let update = GMSCameraUpdate.fit(bounds)//(bounds, withPadding: 200.0)
//            self.objGoogleMap.animate(with: update)
        }*/
    }
    
    /*
     fileprivate var pageSize: CGSize {
     if let layout = self.keywordSearchColllectionView.collectionViewLayout as? UPCarouselFlowLayout{
     var pageSize = layout.itemSize
     if layout.scrollDirection == .horizontal {
     pageSize.width += layout.minimumLineSpacing
     } else {
     pageSize.height += layout.minimumLineSpacing
     }
     return pageSize
     }
     return CGSize(width: self.keywordSearchColllectionView.bounds.width - 60.0, height: self.keywordSearchColllectionView.bounds.height - 10.0)
     
     }*/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.collectionObj.isHidden = (self.arrayOfProvidersNotified.count == 0)
        self.viewCollectionViewContainer.isHidden = (self.arrayOfProvidersNotified.count == 0)
        
        self.checkForCollectionHideButtonHideShow()
        
        //self.buttonCloseCollectionView.isHidden = (self.arrayOfProvidersNotified.count == 0)
        guard self.collectionObj == collectionView else {
            self.viewProviderContainerView.isHidden = (self.arrayOfKeywordSearchProvider.count == 0)
            return self.arrayOfKeywordSearchProvider.count
        }
        return self.arrayOfProvidersNotified.count//JobsModel.Shared.arrJobs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard self.collectionObj == collectionView else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KeywordResultCollectionViewCell", for: indexPath) as! KeywordResultCollectionViewCell
            if self.arrayOfKeywordSearchProvider.count > indexPath.row{
                cell.currentSearchKeyword = self.currentSearchKeyword
                cell.provider = self.arrayOfKeywordSearchProvider[indexPath.row]
                
            }
            cell.tag = indexPath.row
            cell.delegate  = self
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpdateCustomerHomeProviderTableViewCell", for: indexPath) as! UpdateCustomerHomeProviderTableViewCell
        
        if self.arrayOfProvidersNotified.count > indexPath.row{
            let objProvider = self.arrayOfProvidersNotified[indexPath.row]
            if objProvider.promotion.count > 0{
                cell.lblOfferPrice.text = "Offer : $\(objProvider.finalPrice)"
            }else{
                cell.lblOfferPrice.text = "Offer : $\(objProvider.offerPrice)"
            }

            let businessLogo = objProvider.businessLogo
            if let imageURL = URL.init(string: "\(businessLogo)"){
                autoreleasepool {
                    cell.imageBusinessLogo!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                }
            }
            let underlineBusinessName = NSAttributedString(string: "\(objProvider.businessName)",
                                                           attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
            cell.lblProviderBusinessName.attributedText = underlineBusinessName
            if let profileImage = objProvider.customerDetail["profile_pic"]{
                if let imageURL = URL.init(string: "\(profileImage)"){
                    autoreleasepool {
                        cell.imageUserProfile!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                    }
                }
            }
            cell.lblKeyword.text = "\(objProvider.title)"
            if let pi: Double = Double("\(objProvider.rating)"){
                let rating = String(format:"%.1f", pi)
                let underlinerating = NSAttributedString(string: "\(rating)",
                                                         attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
                cell.lblReview.attributedText = underlinerating
            }
            cell.lblAllReview.text = "(\(objProvider.review) Reviews)"
            DispatchQueue.main.async {
                cell.buttonMore.isSelected = objProvider.isMoreOption
                cell.viewMore.isHidden = !objProvider.isMoreOption
            }
        }
        
        
        cell.delegate = self
        cell.tag = indexPath.row
        return cell
        /*
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JobCell", for: indexPath) as! JobCell
         cell.delegate = self
         cell.tag = indexPath.row
         
         if self.arrayOfProvidersNotified.count > indexPath.row{
         let objProvider = self.arrayOfProvidersNotified[indexPath.row]
         UIView.performWithoutAnimation {
         cell.viewAttachmentContainer.isHidden = (objProvider.offerAttachment.count == 0)
         }
         cell.lblJobTitle.text = "\(objProvider.title)"
         let dateformatter = DateFormatter()
         dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
         if let date = dateformatter.date(from: objProvider.offerDate){
         dateformatter.dateFormat = "MM/dd/yyyy\nhh:mm a"
         let timeStr = self.getTime(time: String(objProvider.offerDate.suffix(8)))
         //"\(objProvider.offerDate)" + "\(timeStr)"//
         print(timeStr)
         cell.lblDate.text = dateformatter.string(from: date.toLocalTime())//"\(objProvider.offerDate)" + "\(timeStr)"//
         }
         
         print(cell.lblDate.text)
         
         cell.lblProviderBusinessName.text = "\(objProvider.businessName)"
         
         let businessLogo = objProvider.businessLogo
         if let imageURL = URL.init(string: "\(businessLogo)"){
         autoreleasepool {
         cell.providerBusinessImage!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
         }
         }
         var selectedColor = UIColor.black
         var selectedOfferPriceAfterStripe  = UIColor.init(hex: "38B5A3")
         
         if let tag = self.selectedTag, tag == indexPath.row{
         selectedColor = UIColor.white
         selectedOfferPriceAfterStripe = UIColor.init(hex: "00bfff")
         }else{
         selectedColor = UIColor.black
         selectedOfferPriceAfterStripe = UIColor.init(hex: "38B5A3")
         }
         let offerString = NSMutableAttributedString()
         if objProvider.offerPrice.count > 0{
         //cell.lblOfferPrice.attributedText = "$\(objProvider.offerPrice)".strikeThrough()
         
         if objProvider.promotion.count > 0{
         if let pi: Double = Double("\(objProvider.offerPrice)"){
         print(pi.withCommas())
         let updatedvalue = String(format:"%.2f", pi)
         let newUpdatedValue = "\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))".strikeThrough()
         offerString.append("\((CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)))\n".strikeThrough())
         offerString.addAttribute(NSAttributedString.Key.foregroundColor, value: selectedColor , range: NSMakeRange(0, newUpdatedValue.length))
         
         
         }
         if let pi: Double = Double("\(objProvider.finalPrice)"){
         let updatedvalue = String(format:"%.2f", pi)
         let newUpdatedValue = NSAttributedString(string: "\((CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)))",attributes: [NSAttributedString.Key.foregroundColor: selectedOfferPriceAfterStripe])
         
         offerString.append(newUpdatedValue)//(NSAttributedString.init(string: "$\(updatedvalue)"))
         }
         }else{
         if let pi: Double = Double("\(objProvider.offerPrice)"){
         let updatedvalue = String(format:"%.2f", pi)
         let newUpdatedValue = NSAttributedString(string: "\((CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)))",attributes: [NSAttributedString.Key.foregroundColor: selectedColor])
         
         offerString.append(newUpdatedValue)//(NSAttributedString.init(string:"$\(updatedvalue)"))
         }
         }
         
         }else{
         //cell.lblOfferPrice.attributedText = "none".strikeThrough()
         //offerString.append("none".strikeThrough())
         offerString.append(NSAttributedString.init(string: " none"))
         }
         if objProvider.promotion.count > 0{
         if let value =  objProvider.promotion.first!["customer_discount"]{
         if let type = objProvider.promotion.first!["type"]{
         if "\(type)" == "amount"{
         if let pi: Double = Double("\(value)"){
         let updatedvalue = String(format:"%.2f", pi)
         cell.lblPromotionOfferAmount.text = CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)//"$\(updatedvalue)"
         }
         }else{
         cell.lblPromotionOfferAmount.text = "\(value)%"
         }
         }
         
         }
         UIView.performWithoutAnimation {
         cell.viewPromotionPriceContainer.isHidden = false
         }
         
         }else{
         cell.lblPromotionOfferAmount.text = "none"
         UIView.performWithoutAnimation {
         cell.viewPromotionPriceContainer.isHidden = true
         }
         
         }
         cell.lblOfferPrice.attributedText = offerString
         
         if objProvider.estimateBudget.count > 0{
         if let pi: Double = Double("\(objProvider.estimateBudget)"){
         print(pi.withCommas())
         let value = String(format:"%.2f", pi)
         let updatedValue = Double("\(value)")?.withCommas()
         
         cell.lblAskingPrice.text = CurrencyFormate.Currency(value: Double(value) ?? 0)//"$\(value)"
         }
         }else{
         cell.lblAskingPrice.text = "none"
         }
         
         
         if let pi: Double = Double("\(objProvider.rating)"){
         let rating = String(format:"%.1f", pi)
         cell.lblRatings.text = "\(rating)"
         }
         if let ispreoffer = objProvider.isPreOffer.bool{
         
         
         
         if !ispreoffer{
         cell.viewDeleteOffer.isHidden = false
         DispatchQueue.main.async {
         cell.heightOfferGreen.constant = 20.0
         }
         cell.offerGreenView.isHidden = false
         cell.viewOfferPriceContainer.isHidden = false
         
         /*UIView.transition(with: cell.viewMore, duration: 0.5,
          options: .transitionCrossDissolve,
          animations: {
          DispatchQueue.main.async {
          cell.buttonmore.isSelected = objProvider.isMoreOption
          cell.viewMore.isHidden = !objProvider.isMoreOption
          }
          }) */
         DispatchQueue.main.async {
         cell.buttonmore.isSelected = objProvider.isMoreOption
         cell.viewMore.isHidden = !objProvider.isMoreOption
         }
         
         }else{
         cell.viewDeleteOffer.isHidden = true
         cell.offerGreenView.isHidden = true
         DispatchQueue.main.async {
         
         cell.heightOfferGreen.constant = 20.0
         }
         /*UIView.transition(with: cell.viewMore, duration: 0.5,
          options: .transitionCrossDissolve,
          animations: {
          DispatchQueue.main.async {
          cell.buttonmore.isSelected = objProvider.isMoreOption
          cell.viewMore.isHidden = !objProvider.isMoreOption
          }
          })*/
         DispatchQueue.main.async {
         cell.buttonmore.isSelected = objProvider.isMoreOption
         cell.viewMore.isHidden = !objProvider.isMoreOption
         }
         
         cell.viewOfferPriceContainer.isHidden = false
         }
         }
         /*
          if self.isFromAddJOB{
          cell.viewOfferPriceContainer.isHidden = true
          cell.viewAttachmentContainer.isHidden = true
          }else{
          cell.viewOfferPriceContainer.isHidden = false
          cell.viewAttachmentContainer.isHidden = (objProvider.offerAttachment.count == 0)
          }*/
         }
         
         
         if let tag = self.selectedTag, tag == indexPath.row{
         cell.configureSelectedStatus(isCurrent: true)
         }else{
         cell.configureSelectedStatus(isCurrent: false)
         }
         //cell.configureSelectedStatus(isCurrent: false)
         return cell*/
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.collectionObj == collectionView else {
            return
        }
        DispatchQueue.main.async {
            self.selectedTag = indexPath.item
            self.collectionObj.reloadData()
        }

    }
    func getTime(time:String) -> String{
        
        let actualTime = time.prefix(5)
        let hours = time.prefix(2)
        let actualHours = Int(hours)
        var ampm : String = ""
        ampm = (actualHours! % 12 >= 12) ? "PM" : "AM"
        let timestr = actualTime + " " + ampm
        return timestr
    }
    // MARK: - CollectionView Layout Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard self.collectionObj == collectionView else {
            return 0
        }
        return 0
        //return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard self.collectionObj == collectionView else {
            return 0
        }
        return 0
        //return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard collectionView.bounds.width > 40.0 && collectionView.bounds.height > 10 else{
            return collectionView.bounds.size
        }
        guard self.collectionObj == collectionView else {
            return CGSize(width: self.keywordSearchColllectionView.bounds.width - 40.0, height: self.keywordSearchColllectionView.bounds.height - 10.0)
        }
        
        return CGSize(width: collectionView.bounds.width-40 , height:collectionView.bounds.height-10)
        /*
         if self.isFromAddJOB{
         return CGSize(width: 185, height:collectionView.bounds.height - 60.0)
         }else{
         return CGSize(width: collectionView.bounds.width, height:collectionView.bounds.height)
         }*/
        
    }
    // MARK: - Segement Value Change Method
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            mapView.mapType = .standard
        }
        else {
            mapView.mapType = .satellite
        }
    }
    
    // MARK: - Actions
    @IBAction func buttonSearchThisArea(sender:UIButton){
        DispatchQueue.main.async {
            /*if self.arrayOfProvidersNotified.count > 0{
                self.isFromDidselectSearchKeyword = false
            }else{
                self.isFromDidselectSearchKeyword = true
            }*/
            self.isForKeywordSearch = true
            self.isFromDidselectSearchKeyword = true
            self.viewbuttonSearchThisArea.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.objGoogleMap.clear()
                self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: self.currentSearchKeyword, latitude: self.lastSearchLatForKeyword, longitude: self.lastSearchLatForKeyword, isFirstTime: false)
            }

        }
    }
    @IBAction func buttonLeftScrollSelector(sender:UIButton){
        
        DispatchQueue.main.async {
            if self.collectionObj.contentOffset.x == 0 || self.collectionObj.contentOffset.x - 360.0 <= 0.0{
                DispatchQueue.main.async {
                    self.viewLeft.isHidden = true
                    self.viewRight.isHidden = (self.arrayOfProvidersNotified.count > 2) ?  false : true
                    self.collectionObj.setContentOffset(CGPoint.zero, animated: true)
                }
            }else{
                self.collectionObj.setContentOffset(CGPoint(x: self.collectionObj.contentOffset.x-180.0, y: self.collectionObj.contentOffset.y), animated: true)
                self.checkForHideShowRightLeftScrollButton()
            }
            print(self.collectionObj.contentOffset.x)
        }
    }
    func checkForHideShowRightLeftScrollButton(){
        if self.collectionObj.contentOffset.x + 180.0 >= (self.collectionObj.contentSize.width - self.collectionObj.frame.size.width) ||
            self.collectionObj.contentOffset.x >= (self.collectionObj.contentSize.width - self.collectionObj.frame.size.width){
            
            print("riched right")
            DispatchQueue.main.async {
                self.viewRight.isHidden = true
                self.viewLeft.isHidden = (self.arrayOfProvidersNotified.count > 2) ?  false : true
            }
        }else if self.collectionObj.contentOffset.x == 0 || self.collectionObj.contentOffset.x - 180.0 < 0.0{
            DispatchQueue.main.async {
                self.viewLeft.isHidden = true
                self.viewRight.isHidden = (self.arrayOfProvidersNotified.count > 2) ?  false : true
            }
            print("riched left")
            
        }else{
            
            DispatchQueue.main.async {
                self.viewLeft.isHidden = (self.arrayOfProvidersNotified.count > 2) ?  false : true
                self.viewRight.isHidden = (self.arrayOfProvidersNotified.count > 2) ?  false : true
            }
        }
    }
    @IBAction func buttonRightScrollSelector(sender:UIButton){
        if self.collectionObj.contentOffset.x + 360.0 >= (self.collectionObj.contentSize.width - self.collectionObj.frame.size.width) || self.collectionObj.contentOffset.x >= (self.collectionObj.contentSize.width - self.collectionObj.frame.size.width){
            DispatchQueue.main.async {
                self.viewRight.isHidden = true
                self.viewLeft.isHidden = (self.arrayOfProvidersNotified.count > 2) ?  false : true
                self.collectionObj.setContentOffset(CGPoint(x: self.collectionObj.contentSize.width - self.collectionObj.frame.size.width, y: self.collectionObj.contentOffset.y), animated: true)
                
            }
        }else{
            DispatchQueue.main.async {
                print(self.collectionObj.contentOffset.x)
                self.collectionObj.setContentOffset(CGPoint(x: self.collectionObj.contentOffset.x+180.0, y: self.collectionObj.contentOffset.y), animated: true)
                self.checkForHideShowRightLeftScrollButton()
            }
        }
        
    }
    
    //Updated Action from
    @IBAction func buttonClearKeywordSelector(sender:UIButton){
        
        
        DispatchQueue.main.async {
            if let appdelegate = UIApplication.shared.delegate as? AppDelegate{
                appdelegate.searchKeyword = ""
            }
            self.txtSearch.text = ""
            self.currentSearchKeyword = ""

            self.objGoogleMap.clear()
            self.arrayOfKeywordSearchProvider.removeAll()
            self.keywordSearchColllectionView.reloadData()

            self.buttonClearKeyword.isHidden = true



            if self.currentLat != 0.0 && self.currentLong != 0.0 {
                 let location = CLLocation(latitude: self.currentLat, longitude: self.currentLong)
                let locationObj =  CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                self.objGoogleMap.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: self.objGoogleMap.camera.zoom))

            }
            DispatchQueue.main.asyncAfter(deadline:  .now()+0.5) {
                self.callClearKeywordAPIRequest()
            }
            
            //            if self.lastSearchLatForKeyword.count >  0 && self.lastSearchLngForKeyword.count > 0{
            //                self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "",latitude: "\(self.lastSearchLatForKeyword)", longitude:"\(self.lastSearchLngForKeyword)")
            //            }else{
            //                self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "",latitude: "\(self.currentLat)", longitude:"\(self.currentLong)")
            //            }
            
            
            
        }
    }
    
    @IBAction func buttonContactProviderCard(sender:UIButton){
        self.self.pushtoChatViewControllerWith(provider:self.currentKeyWordSearchProvider)
    }
    @IBAction func buttonProviderDetailProviderCard(sender:UIButton){
        
        self.pushtoProviderDetailFromProviderCard(provider: self.currentKeyWordSearchProvider, providerID: self.currentKeyWordSearchProvider.providerID)
    }
    @IBAction func buttonBookNowProviderCard(sender:UIButton){
        self.manageUserDetailState = true
        self.locationManager.requestWhenInUseAuthorization()
        if self.locationManager.authorizationStatus == .authorizedAlways || self.locationManager.authorizationStatus == .authorizedWhenInUse{
            /*if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
             CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){*/
            guard let currentLocation = self.locationManager.location else {
                return
            }
            
            var requestParameters:[String:Any] = [:]
            requestParameters["provider_id"] = "\(self.currentKeyWordSearchProvider.providerID)"
            requestParameters["lat"] = "\(currentLocation.coordinate.latitude)"
            requestParameters["lng"] = "\(currentLocation.coordinate.longitude)"
            self.apiRequestValidationForDirectBookProvider(requestParameters: requestParameters)
            
        }
    }
    
    //MARK:- API REQUEST
    func apiRequestToFetchUpdatedBusinessFeed(latitude:String,longitude:String){
        var dict:[String:Any]  = [:]
        dict["limit"] = "1"
        dict["page"] = "1"
        dict["keyword"] = self.currentSearchKeyword
        dict["lat"] = "\(latitude)"
        dict["lng"] = "\(longitude)"
        self.currentMapCenterlat = "\(latitude)"
        self.currentMapCenterlng = "\(longitude)"
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if self.currentSearchKeyword.count == 0 && appDelegate.searchKeyword.count > 0{
                dict["keyword"] = appDelegate.searchKeyword
            }
        }
        print("======= \(dict)")
        DispatchQueue.main.async {
            ExternalClass.ShowProgress()
        }
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGETProviderFeeds , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                ExternalClass.ShowProgress()
            }
            if let success = responseSuccess as? [String:Any],let arrayReview = success["success_data"] as? [[String:Any]]{
                var objBusinessLife:BusinessLife?
                for objReview in arrayReview{
                    objBusinessLife = BusinessLife.init(businessLifeDetail: objReview)
                }
                if let businesslife = objBusinessLife{
                    DispatchQueue.main.async {
                        self.configureBusinessLife(objBusinessLife: businesslife)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    //                               SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
                    APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kGETProviderFeeds)")
                    // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
    }
    func configureBusinessLife(objBusinessLife:BusinessLife){
        DispatchQueue.main.async {
            if let objTabView:MyTabController = self.navigationController?.tabBarController as? MyTabController{
                if "\(objBusinessLife.fileType)" == "image" || "\(objBusinessLife.fileType)" == "IMAGE"{
                    if objBusinessLife.file.count > 0 {
                        if let imgURL = URL.init(string: "\(objBusinessLife.file)"){
                            objTabView.imageViewFeed.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                        }
                    }
                }else if "\(objBusinessLife.fileType)" == "video" || "\(objBusinessLife.fileType)" == "VIDEO"{
                    if objBusinessLife.file.count > 0 {
                        if let imgURL = URL.init(string: "\(objBusinessLife.videoThumnail)"){
                            objTabView.imageViewFeed.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                        }
                    }
                }else{
                    
                }
                
            }
        }
    }
    func apiRequestValidationForDirectBookProvider(requestParameters:[String:Any],isFromLocalNotification:Bool = false){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kDirectBookValidation , parameter: requestParameters as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            self.manageUserDetailState = true
//            self.callAPIRequestToGetListOfJOB(searchKeyword: "")
            if let success = responseSuccess as? [String:Any],let responseSuccessData = success["success_data"] as? [String:Any]{
                DispatchQueue.main.async {
                    if let isvalid = responseSuccessData["is_direct_book"] as? Bool{
                        if isvalid{
                            if isFromLocalNotification{
                                self.pushToSingleProviderDirectBookwithIDandName(providerId: "\(requestParameters["provider_id"] ?? "")", name: "\(requestParameters["name"] ?? "")")
                            }else{
                                self.pushToSingleProviderDirectBookViewController()
                            }
                            
                        }else{
                            if let strMessage = responseSuccessData["message"]{

                                self.presentDirectBookProviderValidatioAlert(strMessage: "\(strMessage)")
                            }
                        }
                    }
                }
            }else{
                DispatchQueue.main.async {
                    //                                   SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
                    APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kDirectBookValidation)")
                    // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
    }
    func pushToSingleProviderDirectBookwithIDandName(providerId:String,name:String){
        self.manageUserDetailState = true
        if let PostJobVCViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "PostJobVC") as? PostJobVC{
            PostJobVCViewController.hidesBottomBarWhenPushed = true
            PostJobVCViewController.isForSingleProviderBook = true
            PostJobVCViewController.isForDirectBook = true
            PostJobVCViewController.providerID = providerId
            PostJobVCViewController.providerName = "\(name)"
            PostJobVCViewController.isFromHome = true
            self.navigationController?.pushViewController(PostJobVCViewController, animated: false)
        }
        
        
    }
    func pushToSingleProviderDirectBookViewController(){
        self.manageUserDetailState = true
        if let PostJobVCViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "PostJobVC") as? PostJobVC{
            PostJobVCViewController.hidesBottomBarWhenPushed = true
            PostJobVCViewController.strPrefilledTitle =  self.currentSearchKeyword
            PostJobVCViewController.isForSingleProviderBook = true
            PostJobVCViewController.singleProvider = self.currentKeyWordSearchProvider
            PostJobVCViewController.delegate = self
            PostJobVCViewController.isForDirectBook = true
            PostJobVCViewController.isFromHome = true
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
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
        /*
         // 1
         let translation = gesture.translation(in: view)
         
         // 2
         guard let gestureView = gesture.view else {
         return
         }
         
         gestureView.center = CGPoint(
         x: gestureView.center.x + translation.x,
         y: gestureView.center.y + translation.y
         )
         
         // 3
         gesture.setTranslation(.zero, in: view)
         
         guard gesture.state == .ended else {
         return
         }
         
         // 4
         let velocity = gesture.velocity(in: view)
         let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
         let slideMultiplier = magnitude / 200
         
         // 5
         let slideFactor = 0.1 * slideMultiplier
         // 6
         var finalPoint = CGPoint(
         x: gestureView.center.x + (velocity.x * slideFactor),
         y: gestureView.center.y + (velocity.y * slideFactor)
         )
         
         // 7
         finalPoint.x = min(max(finalPoint.x, 0), view.bounds.width)
         finalPoint.y = min(max(finalPoint.y, 0), view.bounds.height)
         
         print("------ \(finalPoint)")
         //gestureView.center = finalPoint
         */
        
        // 8
        /*UIView.animate(
         withDuration: Double(slideFactor * 2),
         delay: 0,
         // 9
         options: .curveEaseOut,
         animations: {
         gestureView.center = finalPoint
         })*/
    }
    @IBAction func buttonKeywordSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.selectedSearchOption = 0
        }
    }
    @IBAction func buttonPersonSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.selectedSearchOption = 1
        }
    }
    @IBAction func buttonCompanySelector(sender:UIButton){
        DispatchQueue.main.async {
            self.selectedSearchOption = 2
        }
    }
    
    @IBAction func buttonRecenterDirectionSelector(sender:UIButton){
        //if self.currentLat == 0.0 && self.currentLong == 0.0 {
            DispatchQueue.main.async {
                self.viewbuttonSearchThisArea.isHidden = true
                let lat = Double(self.currentLat)
                let long = Double(self.currentLong)
                let locationObj =  CLLocationCoordinate2DMake(lat,long)
                self.objGoogleMap.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: self.objGoogleMap.camera.zoom))
                self.objGoogleMap.clear()
                self.viewProviderContainerView.isHidden = true
                self.viewCollectionViewContainer.isHidden  = true
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.isFromDidselectSearchKeyword = false
                    self.isFirstTimeKeywordSearch = true
                    if self.currentSearchKeyword.count > 0{
                        self.callAPIRequestToGetListOfJOB(searchKeyword: self.currentSearchKeyword,isFirstTime: true)
                    }else{
                        self.callAPIRequestToGetListOfJOB(searchKeyword: "",isFirstTime: true)
                    }
//                    self.callAPIRequestToGetListOfJOB(searchKeyword: self.currentSearchKeyword,isFirstTime: true)
                }
                //self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: self.txtSearch.text ?? "",latitude: "\(self.currentLat)", longitude:"\(self.currentLong)", isFirstTime: true)
            }
        //}

        
        //self.setCenterToCurrentLocation()
        /*
         if self.currentLat != 0.0 && self.currentLong != 0.0 {
         let location = CLLocation(latitude: self.currentLat, longitude: self.currentLong)
         self.centerMapOnLocation(location: location)
         }*/
        
    }
    func setCenterToCurrentLocation(){
        if self.currentLat != 0.0 && self.currentLong != 0.0 {
            self.apiRequestToFetchUpdatedBusinessFeed(latitude: "\(self.currentLat)", longitude: "\(self.currentLong)")
            
            let location = CLLocation(latitude: self.currentLat, longitude: self.currentLong)
            self.centerMapOnLocation(location: location)
        }
    }
    /*
     @IBAction func buttonSearchSelector(sender:UIButton){
     if let objTabView = self.navigationController?.tabBarController{
     objTabView.selectedIndex = 1
     }
     }*/
    
    @IBAction func menuBtnClicked(_ sender: UIButton) {
        
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
        
    }
    
    @IBAction func btnRefreshClicked(_ sender: UIButton) {
        
        isWebserviceCalled = false
        UserDefaults.standard.removeObject(forKey: "selectedCategoriesForFilter")
        txtFldLocation.text = ""
        txtViewDescription.text = ""
        txtFldCategories.text = ""
        
        self.mapView.showsUserLocation = true
        
        mylocation()
    }
    
    
    
    @IBAction func btnFilterClicked(_ sender: UIButton) {
        
        //        UserDefaults.standard.removeObject(forKey: "selectedCategoriesForFilter")
        //        txtFldLocation.text = ""
        //        txtViewDescription.text = ""
        //        txtFldCategories.text = ""
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        viewFilter.layer.add(transition, forKey: nil)
        
        viewFilter.isHidden = false
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showJobProfile" {
            
            let vc = segue.destination as! JobProfileVC
            if let _ = self.selectedTag{
                vc.index = self.selectedTag!
            }
            
        }
    }
    func pushToJOBDetailViewController(withJOBID:String){
        self.manageUserDetailState = true
        if let jobDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailViewController") as? JobDetailViewController{
            jobDetailViewController.hidesBottomBarWhenPushed = true
            jobDetailViewController.jobId = "\(withJOBID)"
            self.navigationController?.pushViewController(jobDetailViewController, animated: true)
        }
    }
    // MARK: - Annotations
    
    func addannotation()  {
        
        for (index,job) in JobsModel.Shared.arrJobs.enumerated() {
            
            let carPin = MyPointAnnotation()
            carPin.identifier = index
            carPin.gpcode = ""
            
            let lat = Double(job.jobLatitude!)
            let long = Double(job.jobLongitude!)
            
            carPin.coordinate = CLLocationCoordinate2DMake(lat! , long! )
            
            let anView:MKAnnotationView = MKAnnotationView()
            anView.annotation = carPin
            
            self.mapView.addAnnotation(carPin)
            
            let annotationPoint = MKMapPoint(carPin.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
            self.zoomRect = zoomRect.union(pointRect)
        }
        
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func addannotationNew(memory : JobsModel)  {
        
        for (index,memory) in JobsModel.Shared.arrJobs.enumerated() {
            
            let carPin = MyPointAnnotation()
            carPin.identifier = index
            carPin.gpcode = ""
            
            let lat = Double(memory.jobLatitude!)
            let long = Double(memory.jobLongitude!)
            
            carPin.coordinate = CLLocationCoordinate2DMake(lat! , long! )
            
            let anView:MKAnnotationView = MKAnnotationView()
            anView.annotation = carPin
            
            self.mapView.addAnnotation(carPin)
            
            let annotationPoint = MKMapPoint(carPin.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
            self.zoomRect = zoomRect.union(pointRect)
            
        }
        
        mapView.showAnnotations(mapView.annotations, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if (annotation is MKUserLocation)
        {
            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            //return nil so map draws default view for it (eg. blue dot)...
            return nil
        }
        
        let reuseId = "test"
        
        guard let annotation = annotation as? MyPointAnnotation else {
            return nil
        }
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        anView!.canShowCallout = true
        anView!.image = UIImage(named:"New_Marker_Map")
        anView?.isEnabled = true
        anView?.detailCalloutAccessoryView?.isHidden = false
        anView?.tag = annotation.identifier!
        anView?.frame.size.width = 44
        //            anView?.frame.size.height = 28
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: (anView?.frame.size.width)!, height: (anView?.frame.size.height)!))
        label.font = UIFont.boldSystemFont(ofSize: 10.0)
        label.textColor = .white
        var text = (JobsModel.Shared.arrJobs[annotation.identifier!].estimatedBudget!)
        text = text.replacingOccurrences(of: "$", with: "")
        let myDouble = Double(text)
        label.text = "$" + self.formatPoints(num: myDouble ?? 0.0)
        anView!.addSubview(label)
        
        return anView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        self.selectedTag = view.tag
        if let _ = self.selectedTag{
            self.collectionObj.scrollToItem(at: IndexPath(item: self.selectedTag!, section: 0), at: .centeredHorizontally, animated: true)
        }
        
        self.collectionObj.reloadData()
    }
    
    func formatPoints(num: Double) ->String{
        var thousandNum = num/1000
        var millionNum = num/1000000
        if num >= 1000 && num < 1000000{
            if(floor(thousandNum) == thousandNum){
                return("\(Int(thousandNum))k")
            }
            return("\(thousandNum.roundToPlaces(places: 1))k")
        }
        
        if num >= 1000000{
            //            if(floor(millionNum) == millionNum){
            //                return("\(Int(thousandNum))k")
            //            }
            return ("\(millionNum.roundToPlaces(places: 1))M")
        }
        else{
            if(floor(num) == num){
                return ("\(Int(num))")
            }
            return ("\(num)")
        }
    }
    
    //MARK: -------------------------------------------------- Filter View
    
    //MARK: - UITextfield Delegate Methods
    func pushtoChatListViewController(){
        self.manageUserDetailState = true
        if let chatListViewController = UIStoryboard.messages.instantiateViewController(identifier: "ChatListViewController") as? ChatListViewController{
            chatListViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatListViewController, animated: true)
        }
        
    }
    func pushToPostJOBViewController(jobTitle:String){
        self.manageUserDetailState = false
        if let PostJobVCViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "PostJobVC") as? PostJobVC{
            PostJobVCViewController.hidesBottomBarWhenPushed = true
            PostJobVCViewController.strPrefilledTitle =  jobTitle
            PostJobVCViewController.isFromHome = true
            self.navigationController?.pushViewController(PostJobVCViewController, animated: false)
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtSearch{
            
            DispatchQueue.main.async {
                textField.resignFirstResponder()
                if self.selectedSearchOption == 0{
                    self.pushToSearchPersonCompanyViewController(isForCompany: false)
                }else if self.selectedSearchOption == 1{
                    self.pushToSearchPersonCompanyViewController(isForCompany: false)
                }else if self.selectedSearchOption == 2{
                    self.pushToSearchPersonCompanyViewController(isForCompany:  true)
                }
            }
            return false
            
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.txtSearch{
            
            if let objTabView = self.navigationController?.tabBarController{
                
                self.pushToPostJOBViewController(jobTitle: "\(textField.text ?? "")")
                DispatchQueue.main.async {
                    self.txtSearch.resignFirstResponder()
                    self.txtSearch.text = ""
                }
            }
        }
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txtSearch{
            if self.selectedSearchOption == 1 ||  self.selectedSearchOption == 2{
                DispatchQueue.main.async {
                    textField.resignFirstResponder()
                    //                    if self.selectedSearchOption == 1{
                    //                        self.pushToSearchPersonCompanyViewController(isForCompany: false)
                    //                    }else if self.selectedSearchOption == 2{
                    //                        self.pushToSearchPersonCompanyViewController(isForCompany:  true)
                    //                    }
                }
            }
        }else if textField == txtFldLocation {
            txtFldLocation.resignFirstResponder()
            let gmsAutoCompleteViewController = GMSAutocompleteViewController()
            gmsAutoCompleteViewController.delegate = self
            
            self.present(gmsAutoCompleteViewController, animated: true) {
            }
        }
        else if textField == txtFldCategories {
            
            self.callAPIToGetCategories()
        }
    }
    
    //MARK: - GMSAutocomplete ViewController Delegate Methods
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let location =  place.coordinate
        txtFldLocation.text = String(place.formattedAddress!)
        
//        self.currentLat = location.latitude
//        self.currentLong = location.longitude
        
        self.mapView.showsUserLocation = false
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Actions
    @IBAction func buttonChatListSelector(sender:UIButton){
        self.pushtoChatListViewController()
    }
    @IBAction func btnCloseClicked(_ sender: UIButton) {
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        viewFilter.layer.add(transition, forKey: nil)
        
        viewFilter.isHidden = true
        
        txtFldLocation.resignFirstResponder()
        txtViewDescription.resignFirstResponder()
    }
    
    @IBAction func btnSearchClicked(_ sender: UIButton) {
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        viewFilter.layer.add(transition, forKey: nil)
        
        viewFilter.isHidden = true
        txtFldLocation.resignFirstResponder()
        txtViewDescription.resignFirstResponder()
        
        self.filterDescription = txtViewDescription.text
        self.callAPIToGetJobList()
    }
    
    @IBAction func btnResetClicked(_ sender: UIButton) {
        
        UserDefaults.standard.removeObject(forKey: "selectedCategoriesForFilter")
        txtFldLocation.text = ""
        txtFldLocation.resignFirstResponder()
        txtViewDescription.resignFirstResponder()
        txtViewDescription.text = ""
        txtFldCategories.text = ""
        viewFilter.isHidden = true
        self.categoryIDS = ""
        isWebserviceCalled = false
        
        self.mapView.showsUserLocation = true
        
        mylocation()
        
        rangeLimit = "50"
        labelRange.text = "50 miles"
        rangeSlider.value = 50
        
    }
    
    @IBAction func rangeValueChanged(_ sender: UISlider) {
        
        let value = Int(sender.value)
        labelRange.text = "\(value)" + " miles"
        rangeLimit = "\(value)"
    }
    
    func callAPIToGetCategories() {
        
        APIManager.sharedInstance.CallAPIPost(url: Url_Categories, parameter: nil, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                self.arrCategories = dataDict["data"] as! NSArray
                
                let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
                
                let vc = storyboard.instantiateViewController(withIdentifier: "CategoriesVC") as! CategoriesVC
                vc.arrCategories = self.arrCategories.mutableCopy() as! NSMutableArray
                vc.isForFilter = true
                vc.isForProffesionals = false
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    
}
extension HomeVC:PostJOBSingleProviderDelegate{
    func postCreatedFromSingleProviderBook(){
        DispatchQueue.main.async {
            if let objTabView = self.navigationController?.tabBarController{
                print(objTabView.viewControllers)
                if let objHomeNavigation:UINavigationController = objTabView.viewControllers?[1] as? UINavigationController{
                    if let objMyPost:MessagesVC = objHomeNavigation.viewControllers.first as? MessagesVC{
                        objTabView.selectedIndex = 1
                        objMyPost.selectedIndexFromNotification = 1
                    }
                }
            }
        }
    }
}
extension HomeVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}

extension HomeVC:UpdateCustomerHomeDelegate{//JOBCellDelegate{
    func buttonMoreClick(index:Int){
        if self.arrayOfProvidersNotified.count > index{
            let objnotifiedProvider = self.arrayOfProvidersNotified[index]
            objnotifiedProvider.isMoreOption = !objnotifiedProvider.isMoreOption
            DispatchQueue.main.async {
                self.collectionObj.reloadData()
            }
            
        }
    }
    func buttonPostDetailClick(index:Int){
        if self.arrayOfProvidersNotified.count > index{
            let objnotifiedProvider = self.arrayOfProvidersNotified[index]
            self.pushToJOBDetailViewController(withJOBID: objnotifiedProvider.jobID)
        }
    }
    func buttonDeleteOfferClick(index:Int){
        if self.arrayOfProvidersNotified.count > index{
            let objnotifiedProvider = self.arrayOfProvidersNotified[index]
            
            let alert = UIAlertController(title: AppName, message: "Are you sure you want to delete this offer?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                
            }))
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                
                self.callDeletePostAPIRequest(jodId: objnotifiedProvider.jobID,providerID: objnotifiedProvider.providerID)
            }))
            alert.view.tintColor = UIColor.init(hex: "#38B5A3")
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    func callDeletePostAPIRequest(jodId:String,providerID:String){
        let dict:[String:Any] = [
            "job_id" : "\(jodId)",
            "provider_id" : "\(providerID)"
        ]
        
        APIRequestClient.shared.sendAPIRequest(requestType: .DELETE, queryString:kCustomerDeleteOffer , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [String]{
                DispatchQueue.main.async {
                    self.objGoogleMap.clear()
                    if arrayOfJOB.count > 0{
                        SAAlertBar.show(.error, message:"\(arrayOfJOB.first!)".localizedLowercase)
                    }
                    self.callAPIRequestToGetListOfJOB(searchKeyword: "")
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
                    APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kCustomerDeleteOffer)")
                    // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
    }
    func buttonCancelOfferClick(index:Int){
        if self.arrayOfProvidersNotified.count > index{
            let objnotifiedProvider = self.arrayOfProvidersNotified[index]
            let alert = UIAlertController(title: AppName, message: "Are you sure you want to cancel this post?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                
            }))
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.callCancelPostAPIRequest(jodId: objnotifiedProvider.jobID)
                
            }))
            alert.view.tintColor = UIColor.init(hex: "#38B5A3")
            self.present(alert, animated: true, completion: nil)
        }
    }
    func callCancelPostAPIRequest(jodId:String){
        let dict:[String:Any] = [
            "job_id" : "\(jodId)"
        ]
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCancelPost , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [String]{
                DispatchQueue.main.async {
                    self.objGoogleMap.clear()
                    if arrayOfJOB.count > 0{
                        SAAlertBar.show(.error, message:"\(arrayOfJOB.first!)".localizedLowercase)
                    }
                    self.callAPIRequestToGetListOfJOB(searchKeyword: "")
                }
                self.callAPIRequestToGetListOfJOB(searchKeyword: "")
                
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
                    APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kCancelPost)")

                    // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
    }
    func callClearKeywordAPIRequest(){
        
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kClearKeyword , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                if self.lastSearchLatForKeyword.count >  0 && self.lastSearchLngForKeyword.count > 0{
                    self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "",latitude: "\(self.lastSearchLatForKeyword)", longitude:"\(self.lastSearchLngForKeyword)",isFirstTime: true)
                }else{
                    self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "",latitude: "\(self.currentLat)", longitude:"\(self.currentLong)",isFirstTime: true)
                }
                //                        self.callAPIRequestToGetListOfJOB(searchKeyword: "")
            }
            if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [String]{
                DispatchQueue.main.async {
                    if arrayOfJOB.count > 0{
                        // SAAlertBar.show(.error, message:"\(arrayOfJOB.first!)".localizedLowercase)
                    }
                    //self.objGoogleMap.clear()
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
                    APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kClearKeyword)")
                    // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
    }
    func buttonContactDetailClick(index: Int) {
        if self.arrayOfProvidersNotified.count > index{
            let objnotifiedProvider = self.arrayOfProvidersNotified[index]
            self.pushtoChatViewControllerWith(provider:objnotifiedProvider)
        }
    }
    func pushToChatViewControllerOnNotification(receiverId:String, quickblox_id: String){
        if self.isFromChatNotificationReceive{
            self.manageUserDetailState = false
        }else{
            self.manageUserDetailState = true
        }
        
        if let chatViewConroller = UIStoryboard.messages.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC{
            chatViewConroller.hidesBottomBarWhenPushed = true
            chatViewConroller.receiverID = "\(receiverId)"
            chatViewConroller.strReceiverName = "\(self.chatNotificationreceiveName)"
            chatViewConroller.strReceiverProfileURL = "\(self.chatNotificationProfile)"
            chatViewConroller.senderID = "\(quickblox_id)"
            chatViewConroller.isForCustomerToProvider = true
            chatViewConroller.toUserTypeStr = "\(self.chatNotificationToUserType)"
            self.navigationController?.pushViewController(chatViewConroller, animated: false)
        }
    }
    func pushtoChatViewControllerWith(provider:NotifiedProviderOffer){
        self.manageUserDetailState = true
        if let chatViewConroller = UIStoryboard.messages.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC{
            chatViewConroller.hidesBottomBarWhenPushed = true
            chatViewConroller.strReceiverName = "\(provider.businessName)"
            chatViewConroller.strReceiverProfileURL = "\(provider.businessLogo)"
            if let id = provider.customerDetail["id"]{
                chatViewConroller.receiverID = "\(id)"
            }
            if let senderid = provider.customerDetail["quickblox_id"]{
                chatViewConroller.senderID = "\(senderid)"
            }
            chatViewConroller.toUserTypeStr = "provider"
            chatViewConroller.arrayOfProvidersNotified = self.arrayOfProvidersNotified
            chatViewConroller.isForCustomerToProvider = true
            self.navigationController?.pushViewController(chatViewConroller, animated: true)
        }
    }
    func buttonAttachmentClick(index: Int) {
        if self.arrayOfProvidersNotified.count > index{
            let objnotifiedProvider = self.arrayOfProvidersNotified[index]
            print(objnotifiedProvider.offerAttachment)
            if objnotifiedProvider.offerAttachment.count > 0{
                if let strImage = objnotifiedProvider.offerAttachment.first!["image"] as? String{
                    self.presentWebViewDetailPageWith(strTitle: "Attachment", strURL: "\(strImage)")
                    
                }
            }
            
        }
    }
    func presentWebViewDetailPageWith(strTitle:String,strURL:String){
        
        if let attachmentViewController = UIStoryboard.profile.instantiateViewController(withIdentifier: "ConditionPolicyVC") as? ConditionPolicyVC{
            attachmentViewController.strURL = strURL
            attachmentViewController.strTitle = strTitle
            attachmentViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.present(attachmentViewController, animated: true, completion: nil)
        }
    }
    func buttonProviderDetailClick(index: Int) {

        if self.arrayOfProvidersNotified.count > index{
            let objnotifiedProvider = self.arrayOfProvidersNotified[index]
            print(objnotifiedProvider.providerID)
            print(objnotifiedProvider.jobID)
            print(objnotifiedProvider.isPreOffer)
            var dictJOBBooking :[String:Any] = [:]
            dictJOBBooking["job_id"] = "\(objnotifiedProvider.jobID)"
            dictJOBBooking["provider_id"] = "\(objnotifiedProvider.providerID)"
            dictJOBBooking["is_pre_offer"] = "\(objnotifiedProvider.isPreOffer)"
            
            self.pushToProviderDetailScreenWithProviderId(provider:objnotifiedProvider,providerID: objnotifiedProvider.providerID,dictJOBBook:dictJOBBooking)
            
        }
    }
    func buttonBookJOBDetailClick(index: Int) {
        DispatchQueue.main.async {
            if self.arrayOfProvidersNotified.count > index{
                
                let objnotifiedProvider = self.arrayOfProvidersNotified[index]
                
                var dict:[String:Any] = [:]
                dict["job_id"] = "\(objnotifiedProvider.jobID)"
                dict["provider_id"] =  "\(objnotifiedProvider.providerID)"
                /*
                 if self.isFromAddJOB{
                 dict["is_pre_offer"] = 1 // 1 if and only while finding result on job post
                 }else{
                 dict["is_pre_offer"] = 0 // 1 if and only while finding result on job post
                 }*/
                if objnotifiedProvider.isPreOffer.count > 0{
                    dict["is_pre_offer"] = "\(objnotifiedProvider.isPreOffer)"
                }
                
                if let ispreoffer = objnotifiedProvider.isPreOffer.bool{
                    if ispreoffer{
                        self.presentUpdateAskingPricePopup(provider: objnotifiedProvider)
                    }else{
                        self.callbookjobapireqest(dict: dict)
                        
                    }
                }
            }
        }
    }
    func presentUpdateAskingPricePopup(provider:NotifiedProviderOffer){
        if let updateAskingPrice = UIStoryboard.main.instantiateViewController(withIdentifier: "UpdateAskingPricePopupViewController") as? UpdateAskingPricePopupViewController{
            updateAskingPrice.modalPresentationStyle = .overFullScreen
            updateAskingPrice.delegate = self
            updateAskingPrice.currentProvider = provider
            self.present(updateAskingPrice, animated: true, completion: nil)
        }
    }
    func pushToProviderDetailScreenWithProviderId(provider:NotifiedProviderOffer,providerID:String,dictJOBBook:[String:Any]){
        self.manageUserDetailState = true
        if let objProviderDetail = self.storyboard?.instantiateViewController(withIdentifier: "ProviderDetailViewController") as? ProviderDetailViewController{
            objProviderDetail.hidesBottomBarWhenPushed = true
            objProviderDetail.providerID = providerID
            objProviderDetail.arrayOfProvidersNotified = self.arrayOfProvidersNotified
            objProviderDetail.dictJOBBooking = dictJOBBook
            objProviderDetail.currentProvider = provider
            objProviderDetail.showBookNowButton = true
            self.navigationController?.pushViewController(objProviderDetail, animated: true)
        }
    }
    func pushToProviderDetailScreenWithProviderId(providerID: String){
        self.manageUserDetailState = true
        if let objProviderDetail = self.storyboard?.instantiateViewController(withIdentifier: "ProviderDetailViewController") as? ProviderDetailViewController{
            objProviderDetail.hidesBottomBarWhenPushed = true
            objProviderDetail.providerID = providerID
            objProviderDetail.showBookNowButton = true
            self.navigationController?.pushViewController(objProviderDetail, animated: true)
        }
    }
    func pushtoProviderDetailFromProviderCard(provider:NotifiedProviderOffer,providerID:String){
        self.manageUserDetailState = true
        if let objProviderDetail = self.storyboard?.instantiateViewController(withIdentifier: "ProviderDetailViewController") as? ProviderDetailViewController{
            objProviderDetail.hidesBottomBarWhenPushed = true
            objProviderDetail.providerID = providerID
            
            objProviderDetail.currentProvider = provider
            objProviderDetail.isFromSearchPersonCompany = true
            objProviderDetail.showBookNowButton = true
            self.navigationController?.pushViewController(objProviderDetail, animated: true)
        }
    }
    func pushToSearchPersonCompanyViewController(isForCompany:Bool){
        self.objGoogleMap.clear()
        self.manageUserDetailState = false
        if let searchViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "SearchPersonCompanyViewController") as? SearchPersonCompanyViewController{
            searchViewController.hidesBottomBarWhenPushed = true
            searchViewController.isForCompany =  isForCompany
            searchViewController.selectedSearchOption = self.selectedSearchOption
            searchViewController.delegate = self
            if let _ = self.selectedTag{
                searchViewController.selectedTag = self.selectedTag!
            }
            self.navigationController?.pushViewController(searchViewController, animated: false)
        }
    }
    
}
extension HomeVC{
    @IBAction func buttonShowCollectionView(sender:UIButton){
        
        DispatchQueue.main.async {
            if self.arrayOfProvidersNotified.count > 0{
                self.selectedTag = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.isFromDidselectSearchKeyword = false
                self.isForKeywordSearch = false
//                    self.checkforcustomerOfferMarkerWithInScreen()


            }
        }
        
    }
    @IBAction func buttonCloseCollectionAndShowSlider(sender:UIButton){
        self.isFromDidselectSearchKeyword = true
        self.isForKeywordSearch = true
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.6){
                        if self.arrayOfKeywordSearchProvider.count > 0{
                            //self.currentPage = 0
                            self.currentKeyWordSearchProvider = self.arrayOfKeywordSearchProvider[0]
                            self.setSelectedMarkerWithUpdatedColorIndex(index: 0,isFromMap: true)
                        }
//            self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(self.currentSearchKeyword)",isFirstTime: true)
        }
        
        //        self.callAPIRequestToGetListOfJOB(searchKeyword: "")
        //        self.hideColllectionViewandShowSlider()
        //        self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "")
        
        
    }
    
}

extension HomeVC:SearchKeywordDelegate{
    
    
    
    
    func didSelectKeywordWith(response: [String : Any]) {
        print(response)
        if let name = response["keywords_for_business"]{
            self.isForKeywordSearch = true
            self.isFromDidselectSearchKeyword = true
            if let appdelegate = UIApplication.shared.delegate as? AppDelegate{
                appdelegate.searchKeyword = "\(name)"
            }
            self.currentSearchKeyword = "\(name)"
            self.arrayOfKeywordSearchProvider.removeAll()
        }
        DispatchQueue.main.async {



            self.objGoogleMap.clear()
            self.keywordSearchColllectionView.reloadData()
//            self.keywordSearchColllectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredHorizontally, animated: true)

            //SAAlertBar.show(.error, message:"\(response)".localizedLowercase)
            
            self.floatingView.isHidden = false
            //                self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(name)", latitude: "\(self.currentLat)", longitude: "\(self.currentLong)")
            //self.callAPIRequestToGetListOfJOB(searchKeyword: "\(name)",latitude: "\(self.currentLat)", longitude: "\(self.currentLong)")
            self.apiRequestToFetchUpdatedBusinessFeed(latitude: "\(self.currentLat)", longitude: "\(self.currentLong)")
            //self.pushToPostJOBViewController(jobTitle: "\(name)")
            
            if let tag = response["selectedTag"] as? Int{
                self.selectedTag = tag
            }

        }
    }
}
extension HomeVC:UpdateAskingPriceDelegate{
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
            }
        }
    }
}
extension HomeVC:KeywordResultDelegate{
    func buttonContactSelector(index:Int){
        if self.arrayOfKeywordSearchProvider.count > index{
            let objnotifiedProvider = self.arrayOfKeywordSearchProvider[index]
            self.pushtoChatViewControllerWith(provider:objnotifiedProvider)
        }
    }
    func buttonBookSelector(index:Int){
        if self.arrayOfKeywordSearchProvider.count > index{
            self.currentKeyWordSearchProvider = self.arrayOfKeywordSearchProvider[index]
            self.locationManager.requestWhenInUseAuthorization()
            if self.locationManager.authorizationStatus == .authorizedAlways || self.locationManager.authorizationStatus == .authorizedWhenInUse{
                /*if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                 CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){*/
                guard let currentLocation = self.locationManager.location else {
                    return
                }
                
                var requestParameters:[String:Any] = [:]
                requestParameters["provider_id"] = "\(self.currentKeyWordSearchProvider.providerID)"
                requestParameters["lat"] = "\(currentLocation.coordinate.latitude)"
                requestParameters["lng"] = "\(currentLocation.coordinate.longitude)"
                self.apiRequestValidationForDirectBookProvider(requestParameters: requestParameters)
            }
        }
        
        
    }
    func buttonDetailSelector(index:Int){
        self.currentPage = index
    }
    func buttonProviderDetailSelector(index:Int){

        if self.arrayOfKeywordSearchProvider.count > index{
            let objnotifiedProvider = self.arrayOfKeywordSearchProvider[index]
            print(objnotifiedProvider.providerID)
            print(objnotifiedProvider.jobID)
            print(objnotifiedProvider.isPreOffer)
            var dictJOBBooking :[String:Any] = [:]
            dictJOBBooking["job_id"] = "\(objnotifiedProvider.jobID)"
            dictJOBBooking["provider_id"] = "\(objnotifiedProvider.providerID)"
            dictJOBBooking["is_pre_offer"] = "\(objnotifiedProvider.isPreOffer)"

            self.pushToProviderDetailScreenWithProviderId(provider:objnotifiedProvider,providerID: objnotifiedProvider.providerID,dictJOBBook:dictJOBBooking)

        }
        //self.pushtoProviderDetailFromProviderCard(provider: self.currentKeyWordSearchProvider, providerID: self.currentKeyWordSearchProvider.providerID)
    }
}
extension HomeVC:GMSMapViewDelegate {
    func showKeywordSearchProviderView(){
        DispatchQueue.main.async {
            self.viewProviderContainerProviderImage.contentMode = .scaleAspectFill
            self.viewProviderContainerProviderImage.clipsToBounds = true
            self.viewProviderContainerSearchKeyword.text = self.currentSearchKeyword
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateformatter.date(from: self.currentKeyWordSearchProvider.searchDate)
            dateformatter.dateFormat = "MM/dd/yyyy\nh:mm a"
            if let _ = date{
                self.viewProviderContainerDate.text = dateformatter.string(from: date!.toLocalTime())
                
            }
            self.viewProviderContainerProviderName.text = "\(self.currentKeyWordSearchProvider.businessName)"
            
            let businessLogo = self.currentKeyWordSearchProvider.businessLogo
            if let imageURL = URL.init(string: "\(businessLogo)"){
                autoreleasepool {
                    self.viewProviderContainerProviderImage!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                }
            }
            if let pi: Double = Double("\(self.currentKeyWordSearchProvider.rating)"){
                let rating = String(format:"%.1f", pi)
                self.viewProviderContainerReview.text = "\(rating)"
            }
            
            self.viewProviderContainerView.isHidden = false
            
            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                return
                
            }
            
            if currentUser.id == "\(self.currentKeyWordSearchProvider.customerDetail["id"] ?? "")"{
                self.buttonBookNowTile.isHidden  = true
                self.buttonContactTile.isHidden = true
            }else{
                self.buttonBookNowTile.isHidden  = false
                self.buttonContactTile.isHidden = false
            }
        }
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture == true {
            self.viewbuttonSearchThisArea.isHidden = false
        }
        
    }
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        
        
        print("======= \(self.viewProviderContainerView.isHidden) ======= ")
        print("======= \(self.lastSearchLatForKeyword)")
        print("======= \(self.lastSearchLngForKeyword)")
        print("======= \(cameraPosition.target.latitude)")
        print("======= \(cameraPosition.target.longitude)")
        if self.lastSearchLatForKeyword.count > 0 && self.lastSearchLngForKeyword.count > 0 && self.lastSearchLatForKeyword != "\(cameraPosition.target.latitude)" && self.lastSearchLngForKeyword != "\(cameraPosition.target.longitude)"{
            
            let location:CLLocation = CLLocation.init(latitude: (self.lastSearchLatForKeyword as NSString).doubleValue, longitude: (self.lastSearchLngForKeyword as NSString).doubleValue)
            let mapCenterLocationCoordinate = CLLocation.init(latitude: cameraPosition.target.latitude, longitude: cameraPosition.target.longitude)
            let distanceInMeters = location.distance(from: mapCenterLocationCoordinate)
            let miles = distanceInMeters / 1609.0
            print(miles)
            if !self.isFirstTimeKeywordSearch{
                //                if miles > 60 || "\(self.currentMapScale)" != "\(self.objGoogleMap.camera.zoom)"{
                DispatchQueue.main.async {
                    self.lastSearchLatForKeyword = "\(cameraPosition.target.latitude)"
                    self.lastSearchLngForKeyword = "\(cameraPosition.target.longitude)"
                    
                    
                }
                //self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(self.currentSearchKeyword)", latitude: "\(cameraPosition.target.latitude)", longitude: "\(cameraPosition.target.longitude)",isFirstTime: false)
                //                }
            }else{
                self.isFirstTimeKeywordSearch = false
            }
            
        }else if "\(self.currentMapScale)" != "\(self.objGoogleMap.camera.zoom)"{
            DispatchQueue.main.async {
                //self.viewbuttonSearchThisArea.isHidden = false
            }
            //self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(self.currentSearchKeyword)", latitude: "\(cameraPosition.target.latitude)", longitude: "\(cameraPosition.target.longitude)",isFirstTime: false)
        }
        /*
         DispatchQueue.main.asyncAfter(deadline: .now()) {
         if !self.viewProviderContainerView.isHidden{
         if self.lastSearchLatForKeyword.count > 0 && self.lastSearchLngForKeyword.count > 0 && self.lastSearchLatForKeyword != "\(cameraPosition.target.latitude)" && self.lastSearchLngForKeyword != "\(cameraPosition.target.longitude)"{
         let location:CLLocation = CLLocation.init(latitude: (self.lastSearchLatForKeyword as NSString).doubleValue, longitude: (self.lastSearchLngForKeyword as NSString).doubleValue)
         let mapCenterLocationCoordinate = CLLocation.init(latitude: cameraPosition.target.latitude, longitude: cameraPosition.target.longitude)
         let distanceInMeters = location.distance(from: mapCenterLocationCoordinate)
         let miles = distanceInMeters / 1609.0
         //if miles >= 60{
         if self.arrayOfKeywordSearchProvider.count > self.currentPage{
         let objprovider = self.arrayOfKeywordSearchProvider[self.currentPage]
         
         let locationUpdate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((objprovider.lat as NSString).doubleValue), longitude: Double((objprovider.lng as NSString).doubleValue))
         
         //if !self.objGoogleMap.projection.contains(locationUpdate){
         self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(self.currentSearchKeyword)", latitude: "\(cameraPosition.target.latitude)", longitude: "\(cameraPosition.target.longitude)")
         //}
         }else{
         //self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(self.currentSearchKeyword)", latitude: "\(cameraPosition.target.latitude)", longitude: "\(cameraPosition.target.longitude)")
         }
         
         //}
         }else{
         //self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(self.currentSearchKeyword)", latitude: "\(cameraPosition.target.latitude)", longitude: "\(cameraPosition.target.latitude)")
         }
         }else{
         if self.arrayOfKeywordSearchProvider.count == 0{
         self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(self.currentSearchKeyword)", latitude: "\(cameraPosition.target.latitude)", longitude: "\(cameraPosition.target.longitude)")
         }
         }
         }*/
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if !self.viewProviderContainerView.isHidden{//self.isForKeywordSearch{
            if let tag = marker.userData as? Int{
                self.searchMapPinSelectedTag = tag
                if let _ = self.keywordSearchColllectionView?.dataSource?.collectionView(self.keywordSearchColllectionView!, cellForItemAt: IndexPath(item: self.searchMapPinSelectedTag!, section: 0)){
                    self.setSelectedMarkerWithUpdatedColorIndex(index:tag,isFromMap:true)
                    self.keywordSearchColllectionView.scrollToItem(at: IndexPath(item: self.searchMapPinSelectedTag!, section: 0), at: .centeredHorizontally, animated: true)
                }

                
                /*
                 if self.arrayOfKeywordSearchProvider.count > tag{
                 let objProvider = self.arrayOfKeywordSearchProvider[tag]
                 self.currentKeyWordSearchProvider = objProvider
                 //ShowKeyword Search Provider detail
                 self.showKeywordSearchProviderView()
                 
                 // remove color from currently selected marker
                 if let selectedMarker = mapView.selectedMarker?.iconView as? CustomMarker{
                 selectedMarker.imageView.tintColor = UIColor.init(hex: "08405D")
                 }
                 
                 if let currentmarker = marker.iconView  as? CustomMarker{
                 currentmarker.imageView.tintColor = UIColor.init(hex: "00bfff")
                 mapView.selectedMarker = marker
                 }
                 
                 }*/
            }
        }else{
            if let tag = marker.userData as? Int{
                self.selectedTag = tag
            }
            if let _ = self.selectedTag{
                if let _ = self.collectionObj?.dataSource?.collectionView(self.collectionObj!, cellForItemAt: IndexPath(item: self.selectedTag!, section: 0)){
                    self.collectionObj.scrollToItem(at: IndexPath(item: self.selectedTag!, section: 0), at: .centeredHorizontally, animated: true)
                    self.setProviderSelectedMarkerWithUpdatedColorIndex(index:self.selectedTag!,isFromMap: true)
                }
            }
            
            self.collectionObj.reloadData()
            //            self.checkForHideShowRightLeftScrollButton()
        }
        
        return true
    }
    @IBAction func searchTileSelector(button:UIButton){
        let latitudeString = "\(self.currentKeyWordSearchProvider.lat)"
        let longitudeString = "\(self.currentKeyWordSearchProvider.lng)"
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((latitudeString as NSString).doubleValue), longitude: Double((longitudeString as NSString).doubleValue))
        //            let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 18)
        //           // UIView.animate(withDuration: 0.5) {
        //                self.objGoogleMap.camera = camera
        //                self.objGoogleMap.animate(to: camera)
        //           // }
        //Map Animation
        let locationObj =  CLLocationCoordinate2DMake(location.latitude, location.longitude)
        //CATransaction.begin()
        //CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)

        
        //CATransaction.commit()
    }
    func setSelectedMarkerWithUpdatedColorIndex(index:Int,isFromMap:Bool = false){
        if self.arrayOfKeywordSearchProvider.count > index{
            let objProvider = self.arrayOfKeywordSearchProvider[index]
            self.currentKeyWordSearchProvider = objProvider
            //ShowKeyword Search Provider detail
            self.showKeywordSearchProviderView()
            self.objGoogleMap.clear()
            
            for (newindex, obj) in self.arrayOfKeywordSearchProvider.enumerated(){
                let latitudeString = "\(obj.lat)"
                let longitudeString = "\(obj.lng)"
                
                print(latitudeString)
                print(latitudeString)
                let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((latitudeString as NSString).doubleValue), longitude: Double((longitudeString as NSString).doubleValue))
                let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: isFromMap ?  self.objGoogleMap.camera.zoom:18)
                
                
                let marker = GMSMarker(position: location)
                marker.zIndex = newindex == index ? 1 : 0
                marker.userData = newindex
                let objView = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 100, height: 30.0)))
                objView.backgroundColor = .black
                var strRating = "\(obj.rating)"
                if let pi: Double = Double("\(obj.rating)"){
                    let rating = String(format:"%.1f", pi)
                    strRating = "\(rating)"
                }
                let customerMarker = CustomMarker.instanceFromNibUpdate(withName: "", rating: "\(strRating)")
                
                if newindex == index{
                    if !isFromMap{
                        // UIView.animate(withDuration: 0.5) {
                        self.objGoogleMap.camera = camera
                        self.objGoogleMap.animate(to: camera)
                        //}
                    }else{
                        //                                            self.setCenterToCurrentLocation()
                    }
                    
                    customerMarker.imageView.tintColor = UIColor.init(hex: "244355")
                }else{
                    customerMarker.imageView.tintColor = UIColor.init(hex: "F21600")
                }
                marker.iconView = customerMarker//CustomMarker.instanceFromNib(withName: "\(self.currentSearchKeyword)", rating: "\(strRating)")
                marker.map = self.objGoogleMap
            }
        }
    }
    func setProviderSelectedMarkerWithUpdatedColorIndex(index:Int,isFromMap:Bool = false){
        if self.arrayOfProvidersNotified.count > index{
            //let objProvider = self.arrayOfProvidersNotified[index]
            
            
            self.objGoogleMap.clear()
            
            for (newindex, obj) in self.arrayOfProvidersNotified.enumerated(){
                let latitudeString = "\(obj.lat)"
                let longitudeString = "\(obj.lng)"
                
                print(latitudeString)
                print(latitudeString)
                let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((latitudeString as NSString).doubleValue), longitude: Double((longitudeString as NSString).doubleValue))
                let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: isFromMap ? self.objGoogleMap.camera.zoom:18)
                
                
                let marker = GMSMarker(position: location)
                marker.zIndex = newindex == index ? 1 : 0
                marker.userData = newindex
                let objView = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 100, height: 30.0)))
                objView.backgroundColor = .black
                var strRating = "\(obj.rating)"
                if let pi: Double = Double("\(obj.rating)"){
                    let rating = String(format:"%.1f", pi)
                    strRating = "\(rating)"
                }
                var customerMarker = CustomMarker.instanceFromNib(withName: "\(obj.businessName)", rating: "\(strRating)")
                if let ispreoffer = obj.isPreOffer.bool{
                    if ispreoffer{ //pre offer true and no offer price as pre offer available
                        customerMarker =  CustomMarker.instanceFromNib(withName: "\(obj.businessName)", rating: "\(strRating)")
                    }else{ //preoffer done and now use offer price
                        if obj.promotion.count > 0{
                        customerMarker = CustomMarker.instanceFromNib(withName: "\(CurrencyFormate.Currency(value: Double(obj.finalPrice) ?? 0 ))", rating: "\(strRating)")
                        }else{
                            customerMarker = CustomMarker.instanceFromNib(withName: "\(CurrencyFormate.Currency(value: Double(obj.offerPrice) ?? 0 ))", rating: "\(strRating)")
                        }
                    }
                }
                marker.iconView = customerMarker
                
                if newindex == index{
                    if !isFromMap{
                        //UIView.animate(withDuration: 0.5) {
                        self.objGoogleMap.camera = camera
                        self.objGoogleMap.animate(to: camera)
                        //}
                    }
                    
                    customerMarker.imageView.tintColor = UIColor.init(hex: "244355")
                }else{
                    customerMarker.imageView.tintColor = UIColor.init(hex: "F21600")
                }
                
                marker.iconView = customerMarker//CustomMarker.instanceFromNib(withName: "\(self.currentSearchKeyword)", rating: "\(strRating)")
                marker.map = self.objGoogleMap
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //do something
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways ||  manager.authorizationStatus == .authorizedWhenInUse{
            locationManager.startUpdatingLocation()
            self.objGoogleMap.isMyLocationEnabled = true
            self.objGoogleMap.settings.myLocationButton = false
            if self.currentSearchKeyword.count > 0{
                self.callAPIRequestToGetListOfJOB(searchKeyword: self.currentSearchKeyword,isFirstTime: true)
            }else{
                self.callAPIRequestToGetListOfJOB(searchKeyword: "",isFirstTime: true)
            }
        }
    }
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways{
            locationManager.startUpdatingLocation()
            self.objGoogleMap.isMyLocationEnabled = true
            self.objGoogleMap.settings.myLocationButton = false
            if self.currentSearchKeyword.count > 0{
                self.callAPIRequestToGetListOfJOB(searchKeyword: self.currentSearchKeyword,isFirstTime: true)
            }else{
                self.callAPIRequestToGetListOfJOB(searchKeyword: "",isFirstTime: true)
            }
        }
    }

}
extension Double {
    /// Rounds the double to decimal places value
    mutating func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}
class CustomMarker: UIView {
    
    @IBOutlet weak var lblServiceName:UILabel!
    @IBOutlet weak var lblServiceRating:UILabel!
    @IBOutlet weak var imageView:UIImageView!
    
    fileprivate func setupView(withName:String,rating:String) {
        // do your setup here
        self.lblServiceName.text = "\(withName)"
        self.lblServiceRating.text = "\(rating)"
    }
    
    class func instanceFromNib(withName:String,rating:String) -> CustomMarker {
        let view = UINib(nibName: "CustomMarker", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomMarker
        view.setupView(withName:withName,rating:rating)
        view.frame = CGRect(x: 0, y: 0, width:"\(withName)".size(withAttributes:[.font: UIFont.systemFont(ofSize: 17.0)]).width + 32, height: 15.0)
        return view
    }
    class func instanceFromNibUpdate(withName:String,rating:String) -> CustomMarker {
        let view = UINib(nibName: "CustomMarker", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomMarker
        view.setupView(withName:withName,rating:rating)
        
        view.frame = CGRect(x: 0, y: 0, width:40, height: 15.0)
        return view
    }
}
protocol CustomMarkerDelegate {
    func buttonDetailSelector(index:Int)
}
class CustomeMarkerDisplayJOB:UIView{
    
    @IBOutlet fileprivate weak var lblServiceName:UILabel!
    @IBOutlet fileprivate weak var lblServiceDate:UILabel!
    @IBOutlet fileprivate weak var lblAskingPrice:UILabel!
    
    var delegate:CustomMarkerDelegate?
    
    fileprivate func setupView(withName:String,date:String,price:String) {
        // do your setup here
        self.lblServiceName.text = "\(withName)"
        self.lblServiceDate.text = "\(date)"
        self.lblAskingPrice.text = "\(price)"
    }
    
    class func instanceFromNib(withName:String,date:String,price:String) -> CustomeMarkerDisplayJOB {
        let view = UINib(nibName: "CustomeMarkerDisplayJOB", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomeMarkerDisplayJOB
        view.setupView(withName: withName, date: date, price: price)
        return view
    }
    @IBAction func buttonDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonDetailSelector(index: self.tag)
        }
    }
}
extension CLLocationCoordinate2D{
    func getCommaSeperatedLatLongString() -> String {
        return "\(self.latitude),\(self.longitude)"
    }
}
extension Notification.Name {
    static let userLoginreferelcode = Notification.Name("UserReferelCode")
    static let customerHome = Notification.Name("CustomerHome")
    static let providerHome = Notification.Name("ProviderHome")
    static let chat = Notification.Name("CustomerProviderChat")
    static let jobBook = Notification.Name("CustomerJOBBook")
    static let updateMyJobTab =  Notification.Name("ProviderMyJOBTabChange")
    static let updateMyPostTab = Notification.Name("CustomerMyPostTabChange")
    static let customerHomeBankList = Notification.Name("customerHomePushtoBankList")
    static let providerHomeBankList = Notification.Name("providerHomePushtoBankList")
    static let stipeAccountAdded = Notification.Name("StripeAccountAdded")
    static let customerReview = Notification.Name("CustomerReview")
    static let providerReview = Notification.Name("ProviderReview")
    static let groupRefresh = Notification.Name("CustomerProviderGroup")
    static let providerBookJOB = Notification.Name("ProviderJOBBooking")
    static let newProviderAvailable = Notification.Name("NewProviderAvailable")
    static let newProviderAvailableProviderHome = Notification.Name("NewProviderAvailableProviderHome")
    static let chatUnreadCount = Notification.Name("chatUnreadCount")
    
    
    
}

extension GMSCircle {
    func bounds () -> GMSCoordinateBounds {
        func locationMinMax(_ positive : Bool) -> CLLocationCoordinate2D {
            let sign: Double = positive ? 1 : -1
            let dx = sign * self.radius  / 6378000 * (180 / .pi)
            let lat = position.latitude + dx
            let lon = position.longitude + dx / cos(position.latitude * .pi / 180)
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        return GMSCoordinateBounds(coordinate: locationMinMax(true),
                               coordinate: locationMinMax(false))
    }
    var updatebounds: GMSCoordinateBounds {
        return [0, 90, 180, 270].map {
            GMSGeometryOffset(position, radius, $0)
            }.reduce(GMSCoordinateBounds()) {
                $0.includingCoordinate($1)
        }
    }
}
