//
//  ViewController.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 24/07/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import SidebarOverlay

class ViewController: SOContainerViewController {
    
    @IBOutlet weak var lblTimer:UILabel!
    
    var timer = Timer()
    var counter = Int()

    var isForNotificationRedirection = false
    
    var notificatioType = ""
    var userRole = ""
    var chatreceiveID = ""
    var chatreceiveName = ""
    var chatreceiveProfile = ""
    var chatsenderID = ""
    var toUserType = ""

    var providerId = ""

    // MARK: - UIView Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBar.isHidden = true
        
        self.menuSide = .left
        if self.isForNotificationRedirection{
            self.configureNotificationredirection()
            /*
            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                return
            }
            if currentUser.userRoleType == .customer{
                if self.userRole == "customer"{
                    //configure Notification redirection
                    self.configureNotificationredirection()
                }else{
                    self.checkForUserCurrentRoleAndUpdateForNotificationRedirection()
                }
            }else if currentUser.userRoleType == .provider{
                if self.userRole == "provider"{
                    //configure Notification redirection
                    self.configureNotificationredirection()
                }else{
                    self.checkForUserCurrentRoleAndUpdateForNotificationRedirection()
                }
            }*/
        }else{
            self.defaultRootScreenConfiguration()
        }
   
    }
    func checkForUserCurrentRoleAndUpdateForNotificationRedirection(){
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
                                       self.configureNotificationredirection()
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
    
    
    func defaultRootScreenConfiguration(){
        let homeStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
           let profileStoryboard = UIStoryboard.init(name: "Profile", bundle: nil)
            
           let providerHome = homeStoryboard.instantiateViewController(withIdentifier: "ProviderTabController")
           let customerHome = homeStoryboard.instantiateViewController(withIdentifier: "MyTabController")
            if let currentUser = UserDetail.getUserFromUserDefault(){
                if currentUser.userRoleType == .customer{
                    self.topViewController = customerHome//homeStoryboard.instantiateViewController(withIdentifier: "MyTabController")
                }else if currentUser.userRoleType == .provider{
                    self.topViewController = providerHome//homeStoryboard.instantiateViewController(withIdentifier: "MyTabController")
                }
            }
           if let sidemenu =  profileStoryboard.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC{
                sidemenu.delegate = self
                self.sideMenuWidth = 312.0
                self.sideViewController = sidemenu//profileStoryboard.instantiateViewController(withIdentifier: "SettingsVC")
            }
    }
    func configureNotificationredirection(){
        let homeStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let profileStoryboard = UIStoryboard.init(name: "Profile", bundle: nil)
         
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
          
          return
        }
        
        if currentUser.userRoleType == .provider{
            if let providerHome:ProviderTabController = homeStoryboard.instantiateViewController(withIdentifier: "ProviderTabController") as? ProviderTabController{
                       //provider home
                        if let objMyJobNavigation:UINavigationController = providerHome.viewControllers?[1] as? UINavigationController{
                            if let objMyPost:MyJobViewController = objMyJobNavigation.viewControllers.first as? MyJobViewController{
                                
                                if self.notificatioType == "new_job"{
                                    providerHome.selectedIndex = 0 //bottom tab
                                    providerHome.addAnimatedCustomView()
                                    NotificationCenter.default.post(name: .providerHome, object: nil)

                                    //objMyPost.selectedIndexFromNotification = 0 //Offer //segment tab
                                }else if self.notificatioType == "job_booked"{
                                    providerHome.selectedIndex = 1 //bottom tab
                                    objMyPost.selectedIndexFromNotification = 1 //Accept //segment tab
                                    providerHome.addGreenAnimatedCustomView()
                                }else if self.notificatioType == "offer_rejected"{
                                    providerHome.selectedIndex = 1 //bottom tab
                                    objMyPost.selectedIndexFromNotification = 4 //Unsuccessfull //segment tab
                                }else if self.notificatioType == "job_payment"{
                                    providerHome.selectedIndex = 1 //bottom tab
                                    objMyPost.selectedIndexFromNotification = 2 //Inprogress //segment tab
                                }else if self.notificatioType == "job_full_payment"{
                                    providerHome.selectedIndex = 1 //bottom tab
                                    objMyPost.selectedIndexFromNotification = 3 //Completed //segment tab
                                }else if self.notificatioType == "chat"{
                                     providerHome.selectedIndex = 0 //bottom tab
                                    if let providerHomeNavigation = providerHome.viewControllers?.first as? UINavigationController{
                                        if let objProviderHome:ProviderHomeViewController = providerHomeNavigation.viewControllers.first as? ProviderHomeViewController{
                                            objProviderHome.isFromChatNotificationReceive = true
                                            objProviderHome.chatNotificationreceiveID = "\(self.chatreceiveID)"
                                            objProviderHome.chatNotificationsenderID = "\(self.chatsenderID)"
                                            objProviderHome.chatNotificationreceiveName = "\(self.chatreceiveName)"
                                            objProviderHome.chatNotificationProfile = "\(self.chatreceiveProfile)"
                                            objProviderHome.chatNotificationToUserType = "\(self.toUserType)"
                                            NotificationCenter.default.post(name: .chat, object: nil)
                                            
                                            
                                        }
                                    }
                                }else if self.notificatioType == "new_provider"{
                                    var requestParameters:[String:Any] = [:]
                                    requestParameters["provider_id"] = "\(self.providerId)"
                                    NotificationCenter.default.post(name: .newProviderAvailableProviderHome, object: nil, userInfo: requestParameters)
                                }else if self.notificatioType == "payout_status"{
                                    //providerHome.selectedIndex = 0 //bottom tab
                                    //Local notification push to bank list
                                    NotificationCenter.default.post(name: .providerHomeBankList, object: nil)
                                    //
                                }else if self.notificatioType == "stripe_account_created"{
                                    //Local notification push
                                    NotificationCenter.default.post(name: .stipeAccountAdded, object: nil)
                               } else if self.notificatioType == "add_review"{
                                //Local notification push
                                providerHome.selectedIndex = 0 //bottom tab
                                if let providerHomeNavigation = providerHome.viewControllers?.first as? UINavigationController{
                                    if let objProviderHome:ProviderHomeViewController = providerHomeNavigation.viewControllers.first as? ProviderHomeViewController{
                                        objProviderHome.isFromReviewNotificationReceive = true
                                        NotificationCenter.default.post(name: .providerReview, object: nil)
                                        
                                        
                                    }
                                }
                               
                                }else{
                                     providerHome.selectedIndex = 0 //bottom tab
                                }
                            }
                        }
                        self.topViewController = providerHome
                   }
        }else if currentUser.userRoleType == .customer{
            if let customerHome:MyTabController = homeStoryboard.instantiateViewController(withIdentifier: "MyTabController") as? MyTabController{
                        if let objMyPostNavigation:UINavigationController = customerHome.viewControllers?[1] as? UINavigationController{
                           if let objMyPost:MessagesVC = objMyPostNavigation.viewControllers.first as? MessagesVC{
                                if self.notificatioType == "job_offer"{
                                    if let customerHomeNavigation = customerHome.viewControllers?[0] as? UINavigationController{
                                        //if let objCustomerHome:HomeVC = customerHomeNavigation.viewControllers.first as? HomeVC{
                                            //objCustomerHome.refreshFromBackgroundNotification()
                                            customerHome.selectedIndex = 0 //bottom tab
                                            customerHome.addAnimatedCustomView()
                                            NotificationCenter.default.post(name: .customerHome, object: nil)

                                        //}
                                    }
                                    
                                    //objMyPost.selectedIndexFromNotification = 0 //Offer segment tab
                                }else if self.notificatioType == "job_accept" {//|| self.notificatioType == "job_payment"{
                                    customerHome.selectedIndex = 1 //bottom tab
                                    objMyPost.selectedIndexFromNotification = 2 //In progress segment tab
                                /*}else if self.notificatioType == "job_full_payment"{
                                        customerHome.selectedIndex = 1 //bottom tab
                                        objMyPost.selectedIndexFromNotification = 3 //Completed segment tab*/
                                }else if self.notificatioType == "chat"{
                                    customerHome.selectedIndex = 0 //bottom tab
                                    if let customerHomeNavigation = customerHome.viewControllers?.first as? UINavigationController{
                                        if let objCustomerHome:HomeVC = customerHomeNavigation.viewControllers.first as? HomeVC{
                                            objCustomerHome.isFromChatNotificationReceive = true
                                            objCustomerHome.chatNotificationreceiveID = "\(self.chatreceiveID)"
                                            objCustomerHome.chatNotificationsenderID = "\(self.chatsenderID)"
                                            objCustomerHome.chatNotificationreceiveName = "\(self.chatreceiveName)"
                                            objCustomerHome.chatNotificationProfile = "\(self.chatreceiveProfile)"
                                            objCustomerHome.chatNotificationToUserType = "\(self.toUserType)"
                                            NotificationCenter.default.post(name: .chat, object: nil)
                                        }
                                    }
                                }else if self.notificatioType == "job_not_started"{
                                    customerHome.selectedIndex = 1 //bottom tab
                                    objMyPost.selectedIndexFromNotification = 1//Not started segment tab
                                }else if self.notificatioType == "new_provider"{
                                        var requestParameters:[String:Any] = [:]
                                        requestParameters["provider_id"] = "\(self.providerId)"
                                        NotificationCenter.default.post(name: .newProviderAvailable, object: nil, userInfo: requestParameters)
                                }else if self.notificatioType == "payout_status"{
                                     //customerHome.selectedIndex = 0 //bottom tab
                                        //Local notification push to bank list
                                    NotificationCenter.default.post(name: .customerHomeBankList, object: nil)
                                }else if self.notificatioType == "stripe_account_created"{
                                    //Local notification push
                                    NotificationCenter.default.post(name: .stipeAccountAdded, object: nil)
                                }
                                else if self.notificatioType == "add_review"{
                                    customerHome.selectedIndex = 0 //bottom tab
                                    if let customerHomeNavigation = customerHome.viewControllers?.first as? UINavigationController{
                                        if let objCustomerHome:HomeVC = customerHomeNavigation.viewControllers.first as? HomeVC{
                                            objCustomerHome.isFromReviewNotificationReceive = true
                                            NotificationCenter.default.post(name: .customerReview, object: nil)
                                        }
                                    }
                                    
                                }
                                else{
                                    customerHome.selectedIndex = 0 //bottom tab
                                }
                            
                            
                            
                              
                           }
                       }
                        //customer home
                        self.topViewController = customerHome
                
                   }
        }

        
       
       
                   
                    
                    
                   /*if let currentUser = UserDetail.getUserFromUserDefault(){
                       if currentUser.userRoleType == .customer{
                           self.topViewController = customerHome//homeStoryboard.instantiateViewController(withIdentifier: "MyTabController")
                       }else if currentUser.userRoleType == .provider{
                           self.topViewController = providerHome//homeStoryboard.instantiateViewController(withIdentifier: "MyTabController")
                       }
                   }*/
                  if let sidemenu =  profileStoryboard.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC{
                       sidemenu.delegate = self
                       self.sideMenuWidth = 312.0
                       self.sideViewController = sidemenu//profileStoryboard.instantiateViewController(withIdentifier: "SettingsVC")
                   }
    }
    // MARK: - User Defined Methods
    
    @objc func update() {
        
        counter = counter - 1
        if counter != 0 {
            lblTimer.text = String(counter)
        }
        else{
            timer.invalidate()
            self.performSegue(withIdentifier: "goToHomeScreen", sender: self)
        }
    }
    
    // MARK: - Actions
    @IBAction func buttonCloseSelector(sender:UIButton){
        
        self.isSideViewControllerPresented = false
    }
    @IBAction func btnSkipPressed(_ sender: UIButton) {
        
        timer.invalidate()
        self.performSegue(withIdentifier: "goToHomeScreen", sender: self)
    }
    
}
extension ViewController:SettingViewDelegate{
    @objc func buttonClose() {
        DispatchQueue.main.async {
            self.isSideViewControllerPresented = false
        }
    }
}
