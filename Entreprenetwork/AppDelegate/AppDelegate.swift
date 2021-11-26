//
//  AppDelegate.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 24/07/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import UserNotifications
import SwiftyFeedback
import Quickblox
import QuickbloxWebRTC
import PushKit
import FacebookLogin
import FacebookCore
import GoogleSignIn
import GoogleMaps
import SVProgressHUD
import Stripe
import AppTrackingTransparency

struct CredentialsConstant {
    static let applicationID:UInt = 89484
    static let authKey = "JzbH79Mf-B2CwpW"
    static let authSecret = "zRv9OHSCbK6qXxw"
    static let accountKey = "-3KMLwH9SRZxQxUm77CQ"
}

struct TimeIntervalConstant {
    static let answerTimeInterval: TimeInterval = 60.0
    static let dialingTimeInterval: TimeInterval = 5.0
}
struct GeneralList {
    var id = "",name:String = ""
}

let kKeepPostActive = ("Keep post active Help","This is the maximum time you are willing to wait for offers. If you’re looking for a new deck, you might be willing to wait a week for offers, but if you’re waiting for a sandwich, an hour is probably more than enough.If you don’t receive any offers the first time, make a new post for the same item and new providers will be able to send offers.")
let kTravelTime = ("Travel Time Help","This is the maximum time you are willing to wait, or travel, for the item you’re looking for.If you’re looking for a great haircut, you might be willing to travel up to an hour. If you’re looking for a someone to build you a new deck, limiting companies to within 3 hours might be a good idea to receive the best service.You can always increase the travel time on the next post if you don’t find what you’re looking for the first time")
let kAskingPrice = ("Asking Price Help","If you have a specific price you would prefer to pay, enter it here.If you’re not sure how much the service or product you’re looking for generally goes for, you should leave this blank and let providers send you offers to select from. This will avoid accidently missing out on fantastic providers who offer a great value.")

let kAgreedPrice = ("Agreed Price Help","If you have a specific price you would prefer to pay, enter it here.If you’re not sure how much the service or product you’re looking for generally goes for, you should leave this blank and let providers send you offers to select from. This will avoid accidently missing out on fantastic providers who offer a great value.")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate,MessagingDelegate{
    
    
    var window: UIWindow?
    var token:Data?
    var arrayCategory:[GeneralList] = []
    var defaultCategory:GeneralList = GeneralList.init()
    var arrayTravelTime:[GeneralList] = []
    var defaultTravelTime:GeneralList = GeneralList.init()
    var arrayPostActive:[GeneralList] = []
    var defaultPostActive:GeneralList = GeneralList.init()
    var werkulesfees:String = ""
    var minMiles:String = ""
    var maxMiles:String = ""
    var jobMinPrice:String = ""
    var jobMaxPrice:String = ""
    var filesizelimitvalidationMessage = ""
    
    var strReferrelCode:String = ""
    private var answerTimer: Timer?
    private var sessionID: String?
    var session: QBRTCSession?
    private var callUUID: UUID?


    var searchKeyword : String = ""
    var homelat : String = ""
    var homelng : String = ""

    var searchKeywordProvider:String = ""
    var providerHomeLat:String = ""
    var providerHomeLng:String = ""

    var currentLocationDelay = 0.0

    struct AppDelegateConstant {
        static let enableStatsReports: UInt = 1
    }
    var isCalling = false {
        didSet {
            if UIApplication.shared.applicationState == .background,
                isCalling == false, CallKitManager.instance.isHasSession() {
                //disconnect()
            }
        }
    }
    lazy private var dataSource: UsersDataSource = {
        let dataSource = UsersDataSource()
        return dataSource
    }()
    
    lazy private var backgroundTask: UIBackgroundTaskIdentifier = {
        let backgroundTask = UIBackgroundTaskIdentifier.invalid
        return backgroundTask
    }()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.registerForRemoteNotifications()

//        self.pushToProviderProfileRedirectionFromPushNotificaition(providerId: "1083")

        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font:UIFont(name: "Avenir Medium", size: 14)]
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
        
        QBSettings.applicationID = CredentialsConstant.applicationID
        QBSettings.authKey = CredentialsConstant.authKey
        QBSettings.authSecret = CredentialsConstant.authSecret
        QBSettings.accountKey = CredentialsConstant.accountKey
        QBSettings.autoReconnectEnabled = true
        QBSettings.logLevel = QBLogLevel.nothing
        QBSettings.disableXMPPLogging()
        QBSettings.disableFileLogging()
        QBRTCConfig.setLogLevel(QBRTCLogLevel.nothing)
        QBRTCConfig.setAnswerTimeInterval(TimeIntervalConstant.answerTimeInterval)
        QBRTCConfig.setDialingTimeInterval(TimeIntervalConstant.dialingTimeInterval)
        if AppDelegateConstant.enableStatsReports == 1 {
            QBRTCConfig.setStatsReportTimeInterval(1.0)
        }
        QBRTCClient.initializeRTC()
        QBRTCClient.instance().add(self)
        
//        UIApplication.shared.statusBarStyle = .default
        FirebaseApp.configure()
        // Initialize the Google Mobile Ads SDK.
            
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        //GADMobileAds.configure(withApplicationID: "ca-app-pub-2506968306282138~5896251670") // werkules App ID
//        GADMobileAds.configure(withApplicationID: "ca-app-pub-7983624777979755~5395396754") // test working ID
        
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [kGADSimulatorID]
        
        Fabric.with([Crashlytics.self])
        
        Analytics.logEvent(NSLocalizedString("app_launch", comment: ""), parameters: [NSLocalizedString("app_name", comment: ""): NSLocalizedString("Werkules", comment: "") as NSObject])
        
        UserDefaults.standard.set(false, forKey: "LocationUpdated")
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in
                
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                        //you got permission to track
                        
                    })
            })
        
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        SwiftyFeedback.shared.recipients = ["werkules@netwerkinc.com"]
        handleAppFlow()
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        GIDSignIn.sharedInstance().clientID = "200571368938-afthgkn700d1th76krs3a9vt97co612q.apps.googleusercontent.com"//"433293029873-8qr22bjk3nn2tfldpphg2a8dcg33b5qo.apps.googleusercontent.com"
        
        GMSServices.provideAPIKey("AIzaSyCAffkTMj7zcHKAJ0f6tVs_Ex8egH0TTDk")
        
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setForegroundColor(UIColor.init(hex: "#38B5A3"))

        
        UILabel.appearance(whenContainedInInstancesOf:[UISegmentedControl.self]).numberOfLines = 0
        
        //STPPaymentConfiguration.shared.publishableKey = ""
        //DEVELOPMENT
//        STPAPIClient.shared.publishableKey = "pk_test_51IU3j5K61Qd7K6wMlbL7NxEPKQ4fhKTPwkGgWHxEFA8BlH6lUvMsVpRLrecfgQdJL7P3E5KrOPb6Ist3vWjP4bRO001HzDSd3d"//"pk_test_0a8rLUbtlCkhb29Mvoxnp9oS"
        
        //AWS sanboax key
        STPAPIClient.shared.publishableKey = "pk_test_51IU3j5K61Qd7K6wMlbL7NxEPKQ4fhKTPwkGgWHxEFA8BlH6lUvMsVpRLrecfgQdJL7P3E5KrOPb6Ist3vWjP4bRO001HzDSd3d"
        
        //PRODUCTION
//        STPAPIClient.shared.publishableKey =  "pk_live_51IU3j5K61Qd7K6wM7shPQ0TKYTHFTtZQaIm3AKY8vqgkYgnKofpdbJCPPReeIn0WepbUDvJdO9hJNiBQfTs0Zvkq00iZFip6bJ"
        
        if UserDetail.isUserLoggedIn{
            self.callClearKeywordAPIRequest()
        }
        
//        var offer:[String:Any] = [:]
//        offer["notification_type"] = "job_full_payment"
//        self.notificationRedirection(userInfo: offer as [String : AnyObject])
       
        
        
        return true
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
                                       //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                   }
                               }
                           }
    }
    func handleAppFlow (){
        if UserDetail.isUserLoggedIn {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            let navigationController = UINavigationController(rootViewController:VC)
            // Make the Tab Bar Controller the root view controller
            //connect()
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }else {
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let navigationController = UINavigationController(rootViewController:loginVC)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = navigationController
            
        }
        
        

        self.getGeneralListAPIRequest()
    }
    func pushtoLogInViewController(strReferealCode:String){
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        loginVC.strReferealCode = strReferealCode
        let navigationController = UINavigationController(rootViewController:loginVC)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }
    func pushToProviderProfileRedirectionFromPushNotificaition(providerId:String){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let VC  = storyboard.instantiateViewController(withIdentifier: "ProviderDetailViewController") as! ProviderDetailViewController
            let navigationController = UINavigationController(rootViewController:VC)
            navigationController.navigationBar.isHidden = true
            VC.providerID = providerId
            VC.isFromDynamicLink = true
            VC.showBookNowButton = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = navigationController

    }
    func notificationRedirection(userInfo:[String:AnyObject]){
        if UserDetail.isUserLoggedIn {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            VC.isForNotificationRedirection = true
            if let type = userInfo["notification_type"]{ //
                VC.notificatioType = "\(type)"
                if let currentUser = UserDetail.getUserFromUserDefault(){
                    if currentUser.userRoleType == .customer{
                        if  "\(type)" ==  "job_full_payment" || "\(type)" == "job_payment"{
                            return
                        }
                    }
                }
//                if "\(type)" == "new_provider",let providerId = userInfo["provider_id"]{
//                    self.pushToProviderProfileRedirectionFromPushNotificaition(providerId: "\(providerId)")
//                }
            }

            if let userType = userInfo["user_type"]{
                VC.userRole = "\(userType)"
            }
            if let receiverID = userInfo["from_id"]{
                VC.chatreceiveID = "\(receiverID)"
            }
            if let profile = userInfo["from_user_profile_pic"]{
                           VC.chatreceiveProfile = "\(profile)"
                       }
            if let username = userInfo["from_user_name"]{
                VC.chatreceiveName = "\(username)"
            }
            if let quickblox_id = userInfo["quickblox_id"]{
                VC.chatsenderID = "\(quickblox_id)"
            }
            if let toUserType = userInfo["to_user_type"]{
                VC.toUserType = "\(toUserType)"
            }
            if let providerId = userInfo["provider_id"]{
                VC.providerId = "\(providerId)"
            }
            
            let navigationController = UINavigationController(rootViewController:VC)
            // Make the Tab Bar Controller the root view controller
            //connect()
            
            
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }else {
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let navigationController = UINavigationController(rootViewController:loginVC)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = navigationController
            
        }
    }
    
    //MARK: - UNUserNotification
       func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
           
            UserDefaults.standard.set(deviceToken, forKey: "deviceToken")
        
           guard let identifierForVendor = UIDevice.current.identifierForVendor else {
               return
           }
           let deviceIdentifier = identifierForVendor.uuidString
           let subscription = QBMSubscription()
           subscription.notificationChannel = .APNS
           subscription.deviceUDID = deviceIdentifier
           subscription.deviceToken = deviceToken
           token = deviceToken
           QBRequest.createSubscription(subscription, successBlock: { (response, objects) in
           }, errorBlock: { (response) in
               debugPrint("[AppDelegate] createSubscription error: \(String(describing: response.error))")
           })
       }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
            debugPrint("Unable to register for remote notifications: \(error.localizedDescription)")
        }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL{
            let handled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamiclink, error) in
                if let url = userActivity.webpageURL {
                       var view = url.lastPathComponent
                       var parameters: [String: String] = [:]
                       URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                           parameters[$0.name] = $0.value
                        if let strreferralCode = self.getQueryStringParameter(url: $0.value!, param: "code"){
                            UserDefaults.standard.set(strreferralCode, forKey: "GroupReferralCode")
                        }
                        if UserDetail.isUserLoggedIn{
                            if let userId = self.getQueryStringParameter(url: $0.value!, param: "user_id"){
                                UserDefaults.standard.set(userId, forKey: "ProviderId")
                                if UserDetail.isUserLoggedIn, let providerId = UserDefaults.standard.object(forKey: "ProviderId") {
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let VC  = storyboard.instantiateViewController(withIdentifier: "ProviderDetailViewController") as! ProviderDetailViewController
                                    let navigationController = UINavigationController(rootViewController:VC)
                                    navigationController.navigationBar.isHidden = true
                                    VC.providerID = providerId as! String
                                    VC.isFromDynamicLink = true
                                    VC.showBookNowButton = true
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.window?.rootViewController = navigationController
                                }
                            }else if let  postID = self.getQueryStringParameter(url: $0.value!, param: "post_id"){
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let VC  = storyboard.instantiateViewController(withIdentifier: "BusinessLifeDetailViewController") as! BusinessLifeDetailViewController
                                let navigationController = UINavigationController(rootViewController:VC)
                                navigationController.navigationBar.isHidden = true
                                VC.postID = postID
                                VC.isFromDynamicLink = true
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                appDelegate.window?.rootViewController = navigationController
                            }
                        }else{
                            if let strCode = self.getQueryStringParameter(url: $0.value!, param: "code"){
                                //Only login screen redirection flow
                                /*
                                UserDefaults.standard.set(strCode, forKey: "GroupReferralCode")
                                self.pushtoLogInViewController(strReferealCode: strCode)*/
                                
                                if let value = kUserDefault.value(forKey: kisFirstTimeLoginInDevice){
                                    print(value)
                                    UserDefaults.standard.set(strCode, forKey: "GroupReferralCode")
                                    self.pushtoLogInViewController(strReferealCode: strCode)
                                }else{
                                    let storyboard = UIStoryboard(name: "Profile", bundle: nil)
                                    let RegisterVC  = storyboard.instantiateViewController(withIdentifier: "RegistrationVC") as! RegistrationVC
                                    UserDefaults.standard.set(strCode, forKey: "GroupReferralCode")
                                    let navigationController = UINavigationController(rootViewController:RegisterVC)
                                    navigationController.navigationBar.isHidden = true
                                    RegisterVC.strReferealCode = strCode as! String
                                    RegisterVC.isFromDynamicLink = true
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.window?.rootViewController = navigationController
                                }
                            }
                        }
                        return
                    }
                       
            }
        }
            return handled
        }else{
           // UserDefaults.standard.set(userId, forKey: "ProviderId")
            if UserDetail.isUserLoggedIn, let providerId = UserDefaults.standard.object(forKey: "ProviderId") {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let VC  = storyboard.instantiateViewController(withIdentifier: "ProviderDetailViewController") as! ProviderDetailViewController
                let navigationController = UINavigationController(rootViewController:VC)
                navigationController.navigationBar.isHidden = true
                VC.providerID = providerId as! String
                VC.isFromDynamicLink = true
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = navigationController
            }
        }
        return true
    }
    func getQueryStringParameter(url: String, param: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }
        func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
            
            return GIDSignIn.sharedInstance().handle(url)
        }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
      if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
        // Handle the deep link. For example, show the deep-linked content or
        // apply a promotional offer to the user's account.
        // ...
        if let strCode = dynamicLink.url?.queryParameters?["code"]{
            print("\(strCode)")
            self.strReferrelCode = "\(strCode)"
            if UserDetail.isUserLoggedIn{
                
            }else{
                //Push to Sign up screen
               // NotificationCenter.default.post(name: .userLoginreferelcode, object: nil)
            }
            
        }
        
        return true
      }
      return false
    }
    
       /*
       func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey : Any] = [:]
        ) -> Bool {

            ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )

        } */


    
   
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        if let userInfo = notification.request.content.userInfo as? [String:AnyObject]{
            print(kUserDefault.value(forKey: kReceiverID))
            if let type = userInfo["notification_type"]{
                if "\(type)" == "chat"{
                    NotificationCenter.default.post(name:.chatUnreadCount, object: nil, userInfo: userInfo)
                    if let receiverID = kUserDefault.value(forKey: kReceiverID){
                        if let fromID = userInfo["from_id"]{
                            if "\(receiverID)" == "\(fromID)"{ //in chat screen and same receiver notification
                                NotificationCenter.default.post(name: .chat, object: nil)
                                completionHandler([])
                            }else{
                                completionHandler([.list,.banner ,.badge, .sound])
                            }
                        }
                    }else{ //not in chat screen
                        completionHandler([.list, .banner,.badge, .sound])
                    }

                }else if "\(type)" == "my_group"{
                    NotificationCenter.default.post(name: .groupRefresh, object: nil)
                }else if "\(type)" == "new_provider"{

                }else{ // other notification apart from chat
                    let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                              if var topNavigationController = keyWindow?.rootViewController as? UINavigationController{
                                  print(topNavigationController.viewControllers)
                                  
                                  if let topController = topNavigationController.viewControllers.last as? ViewController{
                                      if let providerTab = topController.topViewController as? ProviderTabController{
                                          if providerTab.selectedIndex == 0 || providerTab.selectedIndex == 1{
                                              self.checkForCurrentUserRoleBeforeNotificationRedirection(userInfo: userInfo)
                                          }
                                          
                                      }
                                      if let custommertab = topController.topViewController as? MyTabController{
                                          if custommertab.selectedIndex == 0 || custommertab.selectedIndex == 1{
                                              self.checkForCurrentUserRoleBeforeNotificationRedirection(userInfo: userInfo)
                                          }
                                      }
                                  }
                              }
                }
            }
        }
        completionHandler([.list, .banner,.badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse,withCompletionHandler completionHandler: @escaping () -> Void) {
        if let userInfo = response.notification.request.content.userInfo as? [String:AnyObject]{
            self.checkForCurrentUserRoleBeforeNotificationRedirection(userInfo: userInfo)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.notificationRedirection(userInfo: userInfo)
            }

        }
        completionHandler()
    }
    func checkForCurrentUserRoleBeforeNotificationRedirection(userInfo:[String:AnyObject]){
        if UserDetail.isUserLoggedIn {
            var userRole:String = ""
            var notificationType: String = ""
            if let userType = userInfo["user_type"]{
                userRole = "\(userType)"
            }
            if let type = userInfo["notification_type"]{
                notificationType = "\(type)"
            }
            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                return
            }
            if currentUser.userRoleType == .customer{
                if userRole == "customer" && notificationType == "add_review" || notificationType == "new_provider"{
                    return
                }
                if userRole == "customer"{
                    //configure Notification redirection
                    self.notificationRedirection(userInfo: userInfo)
                }else{
                    self.showUserProfileSwitchAlert(userInfo: userInfo)
                }
            }else if currentUser.userRoleType == .provider{
                if userRole == "provider" && notificationType == "add_review" || notificationType == "new_provider"{
                    return
                }
                if userRole == "provider"{
                    //configure Notification redirection
                    self.notificationRedirection(userInfo: userInfo)
                }else{
                    self.showUserProfileSwitchAlert(userInfo: userInfo)
                }
            }
            
        }else{
            self.notificationRedirection(userInfo: userInfo)
        }
         
    }
    func showUserProfileSwitchAlert(userInfo:[String:AnyObject]){
          var strSwitch = "You got notification for Provider View do you want to switch to provider view?"
          guard let currentUser = UserDetail.getUserFromUserDefault() else {
              
              return
          }
          if currentUser.userRoleType == .provider{
              strSwitch = "You got notification for Customer View do you want to switch to customer view?"
          }else if currentUser.userRoleType == .customer{
              strSwitch = "You got notification for Provider View do you want to switch to provider view?"
          }
        if let rootViewController = self.window?.rootViewController{
            UIAlertController.showAlertWithCancelButton(rootViewController, aStrMessage: "\(strSwitch)") { (objInt, strString) in
                        if objInt == 0{
                            self.apiRequestForUserRoleSwitch(userInfo: userInfo)
                        }
                    }
        }
      
      }
    func apiRequestForUserRoleSwitch(userInfo:[String:AnyObject]){
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
                        if let success = responseSuccess as? [String:Any],let userInfoDetail = success["success_data"]{
                            if currentUser.userRoleType == .customer{
                              currentUser.userRoleType = .provider
                            }else if currentUser.userRoleType == .provider{
                              currentUser.userRoleType = .customer
                            }
                            currentUser.setuserDetailToUserDefault()
                            DispatchQueue.main.async {
                                self.notificationRedirection(userInfo: userInfo)
                                //self.pushToCustomerOrProviderHomeViewController()
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
    func pushToCustomerOrProviderHomeViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let navigationController = UINavigationController(rootViewController:VC)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        VC.isForNotificationRedirection = true
        appDelegate.window?.rootViewController = navigationController
    }
    func extractMessage(fromPushNotificationUserInfo userInfo:[AnyHashable: Any]) -> String? {
        var message: String?
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                if let alertMessage = alert["body"] as? String {
                    message = alertMessage
                }
            }
        }
        return message
    }
    func extractNotificationType(userInfo:[AnyHashable: Any])->String?{
        var notificationType:String?
        if let aps = userInfo["data"] as? NSDictionary {
                   if let alert = aps["notification_type"] as? String {
                           notificationType = alert
                   }
               }
        return notificationType
    }
    
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        print("Recived: \(userInfo)")
    }
    
    private func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        print("Recived: \(userInfo)")
        
        completionHandler(.newData)
        
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        print(fcmToken)
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
   
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.voipRegistration()
        QBRTCClient.initializeRTC()
        QBRTCClient.instance().add(self)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UIApplication.shared.applicationIconBadgeNumber = 0
        if QBChat.instance.isConnected == true {
            return
        }
        connect { (error) in
            if let error = error {

                return
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        QBRTCClient.initializeRTC()
        QBRTCClient.instance().add(self)
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.voipRegistration()
        QBRTCClient.initializeRTC()
        QBRTCClient.instance().add(self)
    }
    
    //MARK: Quickblox Connect
    func connect(completion: QBChatCompletionBlock? = nil) {
        let currentUser = Profile()
        
        guard currentUser.isFull == true else {
            completion?(NSError(domain: LoginConstant.chatServiceDomain,
                                code: LoginConstant.errorDomaimCode,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Please enter your login and username."
                ]))
            return
        }
        if QBChat.instance.isConnected == true {
            completion?(nil)
        } else {
            QBSettings.autoReconnectEnabled = true
            QBChat.instance.connect(withUserID: currentUser.ID, password: currentUser.password, completion: completion)
        }
    }
    //MARK: Quickblox Disconnect
    func disconnect(completion: QBChatCompletionBlock? = nil) {
        QBChat.instance.disconnect(completionBlock: completion)
        
    }
    
    //MARK: Register for VoIP notifications
       func voipRegistration() {
           let voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
           // Set the registry's delegate to self
           voipRegistry.delegate = self
           // Set the push type to VoIP
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
       }
    
}
extension UIApplication {
    var currentScene: UIWindowScene? {
        connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
    }
}

extension AppDelegate{
    func getImageWithColorPosition(color: UIColor, size: CGSize, lineSize: CGSize) -> UIImage {
            let rect = CGRect(x:0, y: 0, width: size.width, height: size.height)
            let rectLine = CGRect(x:0, y:size.height-lineSize.height,width: lineSize.width,height: lineSize.height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            UIColor.clear.setFill()
            UIRectFill(rect)
            color.setFill()
            UIRectFill(rectLine)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return image
        }
}
// MARK: - QBRTCClientDelegate
extension AppDelegate:QBRTCClientDelegate{
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        self.session = nil
        self.session = session
    
        if let currentCall = CallKitManager.instance.currentCall() {
            //open by VOIP Push

            CallKitManager.instance.setupSession(session)
            if currentCall.status == .ended {
                CallKitManager.instance.setupSession(session)
                CallKitManager.instance.endCall(with: currentCall.uuid)
                session.rejectCall(["reject": "busy"])
                //prepareCloseCall()
                } else {
                var opponentIDs = [session.initiatorID]
                let profile = Profile()
                guard profile.isFull == true else {
                    return
                }
                for userID in session.opponentsIDs {
                    if userID.uintValue != profile.ID {
                        opponentIDs.append(userID)
                    }
                }
                
                prepareCallerNameForOpponentIDs(opponentIDs) { (callerName) in
                    CallKitManager.instance.updateIncomingCall(withUserIDs: session.opponentsIDs,
                                                               outCallerName: callerName,
                                                               session: session,
                                                               uuid: currentCall.uuid)
                }
            }
        } else {
            //open by call
            
            if let uuid = UUID(uuidString: session.id) {
                callUUID = uuid
                sessionID = session.id
                
                var opponentIDs = [session.initiatorID]
                let profile = Profile()
                guard profile.isFull == true else {
                    return
                }
                for userID in session.opponentsIDs {
                    if userID.uintValue != profile.ID {
                        opponentIDs.append(userID)
                    }
                }
                
                prepareCallerNameForOpponentIDs(opponentIDs) { [weak self] (callerName) in
                    self?.reportIncomingCall(withUserIDs: opponentIDs,
                                             outCallerName: callerName,
                                             session: session,
                                             uuid: uuid)
                }
            }
        }
    }
    private func reportIncomingCall(withUserIDs userIDs: [NSNumber], outCallerName: String, session: QBRTCSession, uuid: UUID) {
        if hasConnectivity() {
            CallKitManager.instance.reportIncomingCall(withUserIDs: userIDs,
                                                       outCallerName: outCallerName,
                                                       session: session,
                                                       sessionID: session.id,
                                                       sessionConferenceType: session.conferenceType,
                                                       uuid: uuid,
                                                       onAcceptAction: { [weak self] (isAccept) in
                                                        guard let self = self else {
                                                            return
                                                        }
                                                        if isAccept == true {
                                                            self.openCall(withSession: session, uuid: uuid, sessionConferenceType: session.conferenceType)
                                                        } else {
                                                            debugPrint("[UsersViewController] endCall reportIncomingCall")
                                                        }
                                                        
                }, completion: { (isOpen) in
                    debugPrint("[UsersViewController] callKit did presented")
            })
        } else {
            
        }
    }
    private func openCall(withSession session: QBRTCSession?, uuid: UUID, sessionConferenceType: QBRTCConferenceType) {
        if hasConnectivity() {
            if let callViewController = UIStoryboard(name: "Call", bundle: nil).instantiateViewController(withIdentifier: "CallViewController") as? CallViewController{
                if let qbSession = session {
                    callViewController.session = qbSession
                }
                callViewController.usersDataSource = self.dataSource
                callViewController.callUUID = uuid
                callViewController.sessionConferenceType = sessionConferenceType
                let navViewController = UINavigationController(rootViewController: callViewController)
                navViewController.modalPresentationStyle = .fullScreen
                navViewController.modalTransitionStyle = .crossDissolve
                self.window?.rootViewController?.present(navViewController, animated: true, completion: nil)
            } else {
                return
            }
        } else {
            return
        }
    }
    private func hasConnectivity() -> Bool {
        let status = Reachability.instance.networkConnectionStatus()
        guard status != NetworkConnectionStatus.notConnection else {
           // showAlertView(message: UsersAlertConstant.checkInternet)
            if CallKitManager.instance.isCallStarted() == false {
                CallKitManager.instance.endCall(with: callUUID) {
                    debugPrint("[UsersViewController] endCall func hasConnectivity")
                }
            }
            return false
        }
        return true
    }
    private func prepareCallerNameForOpponentIDs(_ opponentIDs: [NSNumber], completion: @escaping (String) -> Void)  {
        var callerName = ""
        var opponentNames = [String]()
        var newUsers = [String]()
        for userID in opponentIDs {
           
            // Getting recipient from users.
            if let user = dataSource.user(withID: userID.uintValue),
                let fullName = user.fullName {
                opponentNames.append(fullName)
            } else {
                newUsers.append(userID.stringValue)
            }
        }
        
        if newUsers.isEmpty == false {
            
            QBRequest.users(withIDs: newUsers, page: nil, successBlock: { [weak self] (respose, page, users) in
                if users.isEmpty == false {
                    for user in users {
                        opponentNames.append(user.fullName ?? user.login ?? "")
                    }
                    callerName = opponentNames.joined(separator: ", ")
                    completion(callerName)
                }
            }) { (respose) in
                for userID in newUsers {
                    opponentNames.append(userID)
                }
                callerName = opponentNames.joined(separator: ", ")
                completion(callerName)
            }
        } else {
            callerName = opponentNames.joined(separator: ", ")
            completion(callerName)
        }
    }
}
// MARK: - PKPushRegistryDelegate
extension AppDelegate: PKPushRegistryDelegate {
    // MARK: - PKPushRegistryDelegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
    
        guard let voipToken = registry.pushToken(for: .voIP) else {
            return
        }
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNSVOIP
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = voipToken
        
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
            debugPrint("Create Subscription request - Success")
        }, errorBlock: { response in
            debugPrint("Create Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: deviceIdentifier, successBlock: { response in
            UIApplication.shared.unregisterForRemoteNotifications()
            debugPrint("Unregister Subscription request - Success")
        }, errorBlock: { error in
            debugPrint("Unregister Subscription request - Error")
        })
    }
    
 
    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {
        
        
        //in case of bad internet we check how long the VOIP Push was delivered for call(1-1)
        //if time delivery is more than “answerTimeInterval” - return
        if type == .voIP,
            payload.dictionaryPayload[UsersConstant.voipEvent] != nil {
            if let timeStampString = payload.dictionaryPayload["timestamp"] as? String,
                let opponentsIDsString = payload.dictionaryPayload["opponentsIDs"] as? String {
                let opponentsIDsArray = opponentsIDsString.components(separatedBy: ",")
                if opponentsIDsArray.count == 2 {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    if let startCallDate = formatter.date(from: timeStampString) {
                        if Date().timeIntervalSince(startCallDate) > QBRTCConfig.answerTimeInterval() {
                            debugPrint("timeIntervalSinceStartCall > QBRTCConfig.answerTimeInterval")
                            return
                        }
                    }
                }
            }
        }

        let application = UIApplication.shared
        if type == .voIP,
            payload.dictionaryPayload[UsersConstant.voipEvent] != nil,
            application.applicationState == .background {
            var opponentsIDs: [String]? = nil
            var opponentsNumberIDs: [NSNumber] = []
            var opponentsNamesString = "incoming call. Connecting..."
            var sessionID: String? = nil
            var callUUID = UUID()
            var sessionConferenceType = QBRTCConferenceType.audio
            
            if let opponentsIDsString = payload.dictionaryPayload["opponentsIDs"] as? String,
                let allOpponentsNamesString = payload.dictionaryPayload["contactIdentifier"] as? String,
                let sessionIDString = payload.dictionaryPayload["sessionID"] as? String,
                let callUUIDPayload = UUID(uuidString: sessionIDString) {
                self.sessionID = sessionIDString
                sessionID = sessionIDString
                callUUID = callUUIDPayload
                if let conferenceTypeString = payload.dictionaryPayload["conferenceType"] as? String {
                    sessionConferenceType = conferenceTypeString == "1" ? QBRTCConferenceType.video : QBRTCConferenceType.audio
                }
                
                let profile = Profile()
                guard profile.isFull == true else {
                    return
                }
                let opponentsIDsArray = opponentsIDsString.components(separatedBy: ",")
                
                var opponentsNumberIDsArray = opponentsIDsArray.compactMap({NSNumber(value: Int($0)!)})
                var allOpponentsNamesArray = allOpponentsNamesString.components(separatedBy: ",")
                for i in 0...opponentsNumberIDsArray.count - 1 {
                    if opponentsNumberIDsArray[i].uintValue == profile.ID {
                        opponentsNumberIDsArray.remove(at: i)
                        allOpponentsNamesArray.remove(at: i)
                        break
                    }
                }
                opponentsNumberIDs = opponentsNumberIDsArray
                opponentsIDs = opponentsNumberIDs.compactMap({ $0.stringValue })
                opponentsNamesString = allOpponentsNamesArray.joined(separator: ", ")
            }
            
            let fetchUsersCompletion = { [weak self] (usersIDs: [String]?) -> Void in
                if let opponentsIDs = usersIDs {
                    QBRequest.users(withIDs: opponentsIDs, page: nil, successBlock: { [weak self] (respose, page, users) in
                        if users.isEmpty == false {
                            self?.dataSource.update(users: users)
                        }
                    }) { (response) in
                        debugPrint("error fetch usersWithIDs")
                    }
                }
            }

            CallKitManager.instance.reportIncomingCall(withUserIDs: opponentsNumberIDs,
                                                       outCallerName: opponentsNamesString,
                                                       session: nil,
                                                       sessionID: sessionID,
                                                       sessionConferenceType: sessionConferenceType,
                                                       uuid: callUUID,
                                                       onAcceptAction: { [weak self] (isAccept) in
                                                        guard let self = self else {
                                                            return
                                                        }
                                                        
                                                        if let session = self.session {
                                                            if isAccept == true {
                                                                self.openCall(withSession: session,
                                                                              uuid: callUUID,
                                                                              sessionConferenceType: sessionConferenceType)
                                                                debugPrint("onAcceptAction")
                                                            } else {
                                                                session.rejectCall(["reject": "busy"])
                                                                debugPrint("endCallAction")
                                                            }
                                                        } else {
                                                            if isAccept == true {
                                                                self.openCall(withSession: nil,
                                                                              uuid: callUUID,
                                                                              sessionConferenceType: sessionConferenceType)
                                                                debugPrint("onAcceptAction")
                                                            } else {
                                                                
                                                                debugPrint("endCallAction")
                                                            }
                                                
                                                            self.prepareBackgroundTask()
                                                        }
                                                        completion()
                                                        
                }, completion: { (isOpen) in
                    self.prepareBackgroundTask()
                    if QBChat.instance.isConnected == true {
                        return
                    }
                    self.connect { (error) in
                        if let error = error {

                            return
                        }
                    }
                    debugPrint("callKit did presented")
            })
        }
    }
    
    private func prepareBackgroundTask() {
        let application = UIApplication.shared
        if application.applicationState == .background && self.backgroundTask == .invalid {
            self.backgroundTask = application.beginBackgroundTask(expirationHandler: {
                application.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = UIBackgroundTaskIdentifier.invalid
            })
        }
    }
}
//MARK: GET BUSINESS API
extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
extension AppDelegate{
    func getLogsAPI(userid: String, module: String, description: String){
        let dict = [
                   "user_id": "\(userid)",
                   "log_module" : module,
                   "log_description" : description,
                   "log_platform" : "ios"
            
               ]
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSaveLog , parameter: dict as [String:AnyObject], isHudeShow: false, success: { (responseSuccess) in
            print("Success")
        }) { (responseFail) in
            print("error")
            }
    }
    func getGeneralListAPIRequest(){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .GET, queryString:kGeneralList , parameter: nil, isHudeShow: false, success: { (responseSuccess) in
                 if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                     DispatchQueue.main.async {
                        if let delayMap = userInfo["delay_map_ios"] as? Double{
                            self.currentLocationDelay = delayMap
                        }

                        if let videoValidation = userInfo["max_video_validation_message"]{
                            self.filesizelimitvalidationMessage = "\(videoValidation)"
                        }
                        if let werkulesfees = userInfo["werkules_fee"]{
                            self.werkulesfees = "\(werkulesfees)"
                        }
                        if let value = userInfo["min_miles"]{
                            self.minMiles = "\(value)"
                        }
                        if let value = userInfo["max_miles"]{
                            self.maxMiles = "\(value)"
                        }
                        if let value = userInfo["job_max_price"]{
                            self.jobMaxPrice = "\(value)"
                        }
                        if let value = userInfo["job_min_price"]{
                           self.jobMinPrice = "\(value)"
                        }
                        
                        if let objCategory =  userInfo["default_category"] as? [String:Any]{
                            if let id = objCategory["id"],let name = objCategory["name"]{
                                self.defaultCategory = GeneralList.init(id: "\(id)", name: "\(name)")
                            }
                        }
                        if let arrayCategory:[[String:Any]] = userInfo["category"] as? [[String:Any]]{
                            self.arrayCategory = []
                            for objCategory in arrayCategory{
                                if let id = objCategory["id"],let name = objCategory["name"]{
                                    let obj = GeneralList.init(id: "\(id)", name: "\(name)")
                                    self.arrayCategory.append(obj)
                                }
                            }
                            print(self.arrayCategory.count)
                        }
                        if let objPostActive =  userInfo["default_keep_post_active"] as? [String:Any]{
                            if let id = objPostActive["id"],let name = objPostActive["name"]{
                                self.defaultPostActive = GeneralList.init(id: "\(id)", name: "\(name)")
                            }
                        }
                        if let arrayPostActive:[[String:Any]] = userInfo["keep_post_active"] as? [[String:Any]]{
                            self.arrayPostActive = []
                            for objPostActive in arrayPostActive{
                                if let id = objPostActive["id"],let name = objPostActive["name"]{
                                    let obj = GeneralList.init(id: "\(id)", name: "\(name)")
                                    self.arrayPostActive.append(obj)
                                }
                            }
                            print(self.arrayPostActive.count)
                        }
                        if let objTravelTime =  userInfo["default_travel_time"] as? [String:Any]{
                                                   if let id = objTravelTime["id"],let name = objTravelTime["name"]{
                                                       self.defaultTravelTime = GeneralList.init(id: "\(id)", name: "\(name)")
                                                   }
                                               }
                        if let arrayTravelTime:[[String:Any]] = userInfo["travel_time"] as? [[String:Any]]{
                            self.arrayTravelTime = []
                            for objTravelTime in arrayTravelTime{
                                if let id = objTravelTime["id"],let name = objTravelTime["name"]{
                                    let obj = GeneralList.init(id: "\(id)", name: "\(name)")
                                    self.arrayTravelTime.append(obj)
                                }
                            }
                            print(self.arrayTravelTime)
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
}


extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
