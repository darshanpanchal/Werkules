//
//  SettingsVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 05/08/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import SwiftyFeedback
import MessageUI

import FloatRatingView
import StoreKit
import FirebaseDynamicLinks
import Firebase

@objc protocol SettingViewDelegate {
    @objc optional func buttonClose()
}
class SettingsVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tblVwSettings: UITableView!
    var titleString = String()
    var infoArray = NSArray()
    var delegate:SettingViewDelegate?
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var containerView:UIView!
    @IBOutlet weak var imgUser:UIImageView!
    @IBOutlet weak var lblUsername:UILabel!
    @IBOutlet weak var lblUserEmail:UILabel!
    
    @IBOutlet weak var ratingView:FloatRatingView!
    @IBOutlet weak var lblRating:UILabel!
    var rating:String = "0.0"
    var currentRating:String{
        get{
            return rating
        }
        set{
            rating = newValue
            //Configure New Value
            self.configureUpdatedRating()
        }
    }
     var bankAccountStatus:[String:Any] = [:]
    
    
    var isExpand:Bool = false
    var isReviewExpand:Bool{
        get{
            return isExpand
        }
        set{
            self.isExpand = newValue
            DispatchQueue.main.async {
                self.tblVwSettings.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                           self.tblVwSettings.isScrollEnabled = (self.tblVwSettings.contentSize.height > self.tblVwSettings.bounds.height)
                           
                       }
            }
        }
    }
    var isHelpExpand:Bool = false
    var isHelpOptionExpand:Bool{
        get{
            return isHelpExpand
        }
        set{
            self.isHelpExpand = newValue
            DispatchQueue.main.async {
                self.tblVwSettings.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                           self.tblVwSettings.isScrollEnabled = (self.tblVwSettings.contentSize.height > self.tblVwSettings.bounds.height)

                       }
            }
        }
    }

    // MARK: - UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
      
        RegisterCell()
        ratingView.imageContentMode = .scaleAspectFit
        
        self.containerView.layer.cornerRadius = 10.0
        self.containerView.clipsToBounds = true
        self.imgUser.contentMode = .scaleAspectFill
        self.imgUser.clipsToBounds = true
        self.imgUser.layer.cornerRadius = 43.0
        self.imgUser.layer.borderColor = UIColor.white.cgColor
        self.imgUser.layer.borderWidth = 2.0
        self.tblVwSettings.showsVerticalScrollIndicator = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //GET USER REVIEW
        self.getUserReviewAPIRequest()
        //GET Bank detail
        self.getBankAccontStatusAPIRequest()
        //Setup current user data
        self.configureCurrentUserData()
        self.reloadTableData()
    }
    
    // MARK: - User Defined Methods
    func configureCurrentUserData(){
        if let currentUser = UserDetail.getUserFromUserDefault(){
            DispatchQueue.main.async {
            
                
                if currentUser.userRoleType == .customer{
                      if let imgURL = URL.init(string:  currentUser.profilePic){
                                        self.imgUser.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                                    }
                    self.lblUsername.text = "\(currentUser.firstname) \(currentUser.lastname)"//currentUser.username
                                self.lblUserEmail.text = "" //currentUser.email
                }else{
                    if let businessdetail = currentUser.businessDetail,let imageURL = URL.init(string:  businessdetail.businessLogo){
                        self.imgUser.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                    }
                    if let businessdetail = currentUser.businessDetail{
                        self.lblUsername.text = "\(businessdetail.businessName)"
                        self.lblUserEmail.text = "" //"\(businessdetail.email)"
                    }
                    
                }
              
                
                
            }
        }
    }
    func configureUpdatedRating(){
        DispatchQueue.main.async {
            if let objRating = Double(self.currentRating){
                self.ratingView.rating = objRating
            }
        }
    }
    func reloadTableData() {
        var strSwitch = "Switch to Provider View"
        var strProviderSuspendResume = "Suspend Account"
        
        if let currentUser = UserDetail.getUserFromUserDefault(){
            if let businessdetail = currentUser.businessDetail,let deleted = businessdetail.isDeleted.bool{
                if !deleted{
                    strProviderSuspendResume = "Resume Account"
                }else{
                    strProviderSuspendResume = "Put Account on Hold"
                }
            }
            
            if currentUser.userRoleType == .customer{
                strSwitch = "Switch to Provider View"
                print(currentUser.loginType)
                if currentUser.loginType == "normal"{
                    infoArray = NSArray(objects: "\(strSwitch)","My Profile","Wallet","My Business Reviews","Change Password","Help","Terms & Conditions","Privacy Policy","Feedback","Rate App","Share App","Account Management","Close Account")
                }else{
                    infoArray = NSArray(objects: "\(strSwitch)","My Profile","Wallet","My Business Reviews","Help","Terms & Conditions","Privacy Policy","Feedback","Rate App","Share App","Account Management","Close Account")
                }
            }else if currentUser.userRoleType == .provider{
                strSwitch = "Switch to Customer View"
                infoArray = NSArray(objects: "\(strSwitch)","My Profile","My Customer Reviews","Market Research","Wallet","Help","Terms & Conditions","Privacy Policy","Feedback","Rate App","Share App","Account Management","\(strProviderSuspendResume)","Close Account")
                
            }
        }
        
 
        
        btnLogin.setTitle("Logout", for: .normal)
        
        
        self.tblVwSettings.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.tblVwSettings.isScrollEnabled = (self.tblVwSettings.contentSize.height > self.tblVwSettings.bounds.height)
            
        }
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
        UserRegister.Shared.phone = ""
        //        UserRegister.Shared.email = ""
        UserRegister.Shared.password = ""
        UserRegister.Shared.EIN = ""
        UserRegister.Shared.companyAddress = ""
        UserRegister.Shared.insurance = ""
        
        UserRegister.Shared.tagline = ""
        UserRegister.Shared.companyDescription = ""
        UserRegister.Shared.mediaArray = NSMutableArray.init()
        
        UserSettings.isUserLogin = false
        UserSettings.PasswordText = ""
        UserDefaults.standard.set("0", forKey: "userID")
        UserSettings.userID = "0"
        
        CurrentUserModel.Shared.deviceToken = ""
        CurrentUserModel.Shared.vProfilepic = nil
        CurrentUserModel.Shared.vfileKey = ""
        CurrentUserModel.Shared.vchunkedMode = ""
        CurrentUserModel.Shared.vmimeType = ""
        CurrentUserModel.Shared.vTimestamp = ""
        CurrentUserModel.Shared.userType = ""
        
        CurrentUserModel.Shared.firstName = ""
        CurrentUserModel.Shared.lastName = ""
        CurrentUserModel.Shared.companyName = ""
        
        if UserSettings.isUserLogin == true {
            CurrentUserModel.Shared.userId = UserSettings.userID
        }
        else {
            CurrentUserModel.Shared.userId = ""
        }
        CurrentUserModel.Shared.phone = ""
        CurrentUserModel.Shared.email = ""
        CurrentUserModel.Shared.EIN = ""
        CurrentUserModel.Shared.companyAddress = ""
        CurrentUserModel.Shared.insurance = ""
        
        CurrentUserModel.Shared.tagline = ""
        CurrentUserModel.Shared.companyDescription = ""
        CurrentUserModel.Shared.mediaArray = NSMutableArray.init()
        
        
        NotificationCenter.default.post(name: Notification.Name("UserSignOutNotification"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("UserSignInOutNotification"), object: nil)
    }
    
    // MARK: - Actions
    @IBAction func buttonProfileSelector(sender:UIButton){
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        DispatchQueue.main.async {
            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                                  return}
            if currentUser.userRoleType == .provider{
                          let objmainstoryboard = UIStoryboard.init(name: "Main", bundle: nil)
                          if let providerProfile = objmainstoryboard.instantiateViewController(withIdentifier: "ProviderProfileViewController") as? ProviderProfileViewController{
                              self.navigationController?.pushViewController(providerProfile, animated: true)
                          }
            }else{
                self.performSegue(withIdentifier: "MyAccountSegue", sender: self)
            }
        }
    }
    @IBAction func buttonMyReviewSelector(sender:UIButton){
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        self.pushToCustomerReviewScreen()
    }
    func pushToMyReviewScreen(){
           if let objMyReviewViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyReviewViewController") as? MyReviewViewController{
               self.navigationController?.pushViewController(objMyReviewViewController, animated: true)
           }
       }
    func pushToCustomerReviewScreen(){
        if let objCustomerReviewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomerReviewViewController") as? CustomerReviewViewController{
            self.navigationController?.pushViewController(objCustomerReviewController, animated: true)
        }
    }
    func pushToHelpViewControllerScreen(){
        self.presentCustomerAndProviderHelpViewController()
        /*
        if let objHelpViewController = self.storyboard?.instantiateViewController(withIdentifier: "HelpViewController") as? HelpViewController{
            objHelpViewController.isFromSideMenu  = true
            objHelpViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(objHelpViewController, animated: true)
        }*/
    }
    func presentCustomerOrProviderHelpViewController(isForCustomer:Bool){
        if let customerHelp = UIStoryboard.profile.instantiateViewController(withIdentifier: "CustomerProviderHelpVideoViewController") as? CustomerProviderHelpVideoViewController{
            customerHelp.modalPresentationStyle = .fullScreen
            customerHelp.isForCustomer = isForCustomer
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController?.present(customerHelp, animated: true, completion: nil)
        }
    }
    func presentCustomerAndProviderHelpViewController(){
        if let customerHelp = UIStoryboard.profile.instantiateViewController(withIdentifier: "CustomerProviderHelpVideoViewController") as? CustomerProviderHelpVideoViewController{
            customerHelp.modalPresentationStyle = .fullScreen
            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                return
            }
            if currentUser.userRoleType == .provider{
                customerHelp.isForCustomer = false
            }else{
                customerHelp.isForCustomer = true
            }
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController?.present(customerHelp, animated: true, completion: nil)
//            self.navigationController?.present(customerHelp, animated: true, completion: nil)
        }
    }
    
    @IBAction func buttonCloseSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonClose?()
        }
           
       }
    @IBAction func btnLoginClicked(_ sender: UIButton) {
        
        if btnLogin.title(for: .normal) == "Login" {
            
            UserDefaults.standard.set(true, forKey: "isFromSettings")
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        }
        else {
            
            UIAlertController.showActionsheetForLogOut(self) { (aInt, aStrMsg) in
                switch aInt{
                case 0 :
                    
                    self.callLogoutAPI()
                    
                default:
                    print("Cancel")
                }
            }
        }
    }
    
    // MARK: - Register Cell
    
    func RegisterCell()  {
        self.tblVwSettings.register(UINib.init(nibName: "ReviewUpdatedTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewUpdatedTableViewCell")
        self.tblVwSettings.register(UINib.init(nibName: "SettingsCellView", bundle: nil), forCellReuseIdentifier: "settingscellView")
        self.tblVwSettings.tableFooterView = UIView()
    }
    
    // MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
            return  40.0
        }
        if indexPath.row == 1{
            return 0
        }else if currentUser.userRoleType == .provider && indexPath.row == 2{
            if self.isReviewExpand{
                return 120.0
            }else{
                return 40.0
            }
        }else if currentUser.userRoleType == .provider && indexPath.row == 3{
            return 0.0
        }else if currentUser.userRoleType == .customer && indexPath.row == 3{
                if self.isReviewExpand{
                    return 120.0
                }else{
                    return 40.0
                }
        }else if currentUser.userRoleType == .provider && indexPath.row == 5{
            if self.isHelpOptionExpand{
                return 120.0//160.0
            }else{
                return 40.0
            }
        }else if currentUser.loginType == "normal" && currentUser.userRoleType == .customer && indexPath.row == 5{
            if let _ = currentUser.businessDetail{
                if self.isHelpOptionExpand{
                    return 120.0//160.0
                }else{
                    return 40.0
                }
            }else{
                if self.isHelpOptionExpand{
                    return 80//120.0
                }else{
                    return 40.0
                }
            }
        }else if currentUser.loginType != "normal" && currentUser.userRoleType == .customer && indexPath.row == 4{
            if let _ = currentUser.businessDetail{
                if self.isHelpOptionExpand{
                    return 120.0//160.0
                }else{
                    return 40.0
                }
            }else{
                if self.isHelpOptionExpand{
                    return 80//120.0
                }else{
                    return 40.0
                }
            }
         }else{
                return 40.0
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        
        
        
        
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
            return UITableViewCell()
        }
        if currentUser.userRoleType == .provider && indexPath.row == 2{
            let updatedTableViewCell = tblVwSettings.dequeueReusableCell(withIdentifier: "ReviewUpdatedTableViewCell", for: indexPath) as! ReviewUpdatedTableViewCell
            updatedTableViewCell.delegate = self
            updatedTableViewCell.lblReviewFirst.text = "Provider Reviews Received"
            updatedTableViewCell.lblReviewSecond.text = "Customer Reviews Given"
            updatedTableViewCell.viewThirdOption.isHidden = true
            updatedTableViewCell.isForHelp = false
            return updatedTableViewCell
        }else if currentUser.userRoleType == .customer && indexPath.row == 3{
            let updatedTableViewCell = tblVwSettings.dequeueReusableCell(withIdentifier: "ReviewUpdatedTableViewCell", for: indexPath) as! ReviewUpdatedTableViewCell
            updatedTableViewCell.delegate = self
            updatedTableViewCell.lblReviewFirst.text = "Customer Reviews Received"
            updatedTableViewCell.lblReviewSecond.text = "Provider Reviews Given"
            updatedTableViewCell.viewThirdOption.isHidden = true
            updatedTableViewCell.isForHelp = false
            return updatedTableViewCell
        }else if currentUser.userRoleType == .provider && indexPath.row == 5{
            let updatedTableViewCell = tblVwSettings.dequeueReusableCell(withIdentifier: "ReviewUpdatedTableViewCell", for: indexPath) as! ReviewUpdatedTableViewCell
            updatedTableViewCell.delegate = self
            updatedTableViewCell.lblTitle.text = "Help"
            updatedTableViewCell.lblReviewFirst.text = "Customer Help"
            updatedTableViewCell.lblReviewSecond.text = "Provider Help"
            updatedTableViewCell.lblReviewThird.text = "Facts"
            updatedTableViewCell.viewThirdOption.isHidden = false
            updatedTableViewCell.isForHelp = true
            return updatedTableViewCell
        }else if currentUser.loginType == "normal" && currentUser.userRoleType == .customer && indexPath.row == 5{
                let updatedTableViewCell = tblVwSettings.dequeueReusableCell(withIdentifier: "ReviewUpdatedTableViewCell", for: indexPath) as! ReviewUpdatedTableViewCell
                updatedTableViewCell.delegate = self
                updatedTableViewCell.lblTitle.text = "Help"
                if let _ = currentUser.businessDetail{
                    updatedTableViewCell.lblReviewFirst.text = "Customer Help"
                    updatedTableViewCell.lblReviewSecond.text = "Provider Help"
                    updatedTableViewCell.lblReviewThird.text = "Facts"
                    updatedTableViewCell.viewThirdOption.isHidden = false
                }else{
                    updatedTableViewCell.lblReviewFirst.text = "Customer Help"
                    updatedTableViewCell.lblReviewSecond.text = "Facts"
                    updatedTableViewCell.viewThirdOption.isHidden = true
                }
                updatedTableViewCell.isForHelp = true
                return updatedTableViewCell
        }else if currentUser.loginType != "normal" && currentUser.userRoleType == .customer && indexPath.row == 4{
            let updatedTableViewCell = tblVwSettings.dequeueReusableCell(withIdentifier: "ReviewUpdatedTableViewCell", for: indexPath) as! ReviewUpdatedTableViewCell
            updatedTableViewCell.delegate = self
            updatedTableViewCell.lblTitle.text = "Help"
            if let _ = currentUser.businessDetail{
                updatedTableViewCell.lblReviewFirst.text = "Customer Help"
                updatedTableViewCell.lblReviewSecond.text = "Provider Help"
                updatedTableViewCell.lblReviewThird.text = "Facts"
                updatedTableViewCell.viewThirdOption.isHidden = false
            }else{
                updatedTableViewCell.lblReviewFirst.text = "Customer Help"
                updatedTableViewCell.lblReviewSecond.text = "Facts"
                updatedTableViewCell.viewThirdOption.isHidden = true
            }
            updatedTableViewCell.isForHelp = true
            return updatedTableViewCell
        }else{
            let aObjCell = tblVwSettings.dequeueReusableCell(withIdentifier: "settingscellView", for: indexPath) as! SettingsCellView

        aObjCell.contentView.backgroundColor = UIColor.clear

        aObjCell.selectionStyle = .none

        aObjCell.lbltitle?.text = (infoArray.object(at: indexPath.row) as! String)


        if currentUser.userRoleType == .provider{
        if indexPath.row == self.infoArray.count - 3{
            aObjCell.imgDetail.isHidden = true
            aObjCell.lbltitle?.textColor = UIColor.init(hex: "#38B5A3")
        }else{
            aObjCell.imgDetail.isHidden = false
            aObjCell.lbltitle?.textColor = UIColor.init(hex: "#555555")
        }

        }else if currentUser.userRoleType == .customer{

        if indexPath.row == self.infoArray.count - 2{
            aObjCell.imgDetail.isHidden = true
            aObjCell.lbltitle?.textColor = UIColor.init(hex: "#38B5A3")
        }else{
            aObjCell.imgDetail.isHidden = false
            aObjCell.lbltitle?.textColor = UIColor.init(hex: "#555555")
        }
        }else{
        if indexPath.row == self.infoArray.count - 2{
            aObjCell.imgDetail.isHidden = true
            aObjCell.lbltitle?.textColor = UIColor.init(hex: "#38B5A3")
        }else{
            aObjCell.imgDetail.isHidden = false
            aObjCell.lbltitle?.textColor = UIColor.init(hex: "#555555")
        }
        }

        return aObjCell
                }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                              return}
        if currentUser.userRoleType == .provider{ //provider
            //NSArray(objects: "\(strSwitch)","My Profile","\(strProviderSuspendResume)","My Business Reviews","Market Research","Wallet","Help","Messages","Terms & Conditions","Privacy Policy","Feedback","Rate App","Share App")
            switch indexPath.row {
                   case 0:
                        self.showUserProfileSwitchAlert()
                        
                       print(indexPath.row)
                       break
                   case 1:
                    DispatchQueue.main.async {
                                      let objmainstoryboard = UIStoryboard.init(name: "Main", bundle: nil)
                                      if let providerProfile = objmainstoryboard.instantiateViewController(withIdentifier: "ProviderProfileViewController") as? ProviderProfileViewController{
                                          self.navigationController?.pushViewController(providerProfile, animated: true)
                                      }
                                             }
                       print(indexPath.row)
                   break
                   case 12:
                    if let businessdetail = currentUser.businessDetail,let deleted = businessdetail.isDeleted.bool{
                        
                        self.showsuspendresumeaccountalert(isdeleted: !deleted)
                    }
                       print(indexPath.row)
                   break
                   case 2:
                     //self.pushToMyReviewScreen()
                       print(indexPath.row)
                   break
                  case 3: //market research
                    self.pushToMarketResearchViewController()
                       print(indexPath.row)
                   break
                   case 4:
                       print(indexPath.row) 
                       self.pushToWalletViewController()
                   break
                   case 5:
                       print(indexPath.row)
                       self.pushToHelpViewControllerScreen()
                   break
                 /*
                   case 7:
                       print(indexPath.row)
                   break*/
                   case 6:
                    self.titleString = infoArray.object(at: indexPath.row) as! String
                    self.performSegue(withIdentifier: "ConditionPolicySegue", sender: self)
                       print(indexPath.row)
                   break
                   case 7:
                    self.titleString = infoArray.object(at: indexPath.row) as! String
                    self.performSegue(withIdentifier: "ConditionPolicySegue", sender: self)
                       print(indexPath.row)
                   break
                   case 8:
                       print(indexPath.row)
                       self.pushToFeedBackViewController()
                    break
                   case 9:
                    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                   print(indexPath.row)
                    break
                   case 10:
                      self.shareApplicatioSelector()
                   print(indexPath.row)
                   break
                    case 11:
                        print(indexPath.row)
                  
                break
                    case 13:
                    self.presentCloseAccountPopUp()
                    break
                       default:
                        DispatchQueue.main.async {
                            SAAlertBar.show(.error, message:"Under development".localizedLowercase)
                        }
                break
            }
        }else {
            // NSArray(objects: "\(strSwitch)","My Profile","My Reviews","Wallet","Help","Terms & Conditions","Privacy Policy","Feedback","Rate App","Share App")
            if currentUser.loginType == "normal"{
                switch indexPath.row {
                               case 0:
                                   if let _ = currentUser.businessDetail{
                                       self.showUserProfileSwitchAlert()
                                   }else{
                                       self.showSwitchProfileWithOutProviderSetup()
                                   }
                                   print(indexPath.row)
                                   break
                               case 1:
                                   self.performSegue(withIdentifier: "MyAccountSegue", sender: self)
                                   print(indexPath.row)
                               break
                               case 2:
                                   print(indexPath.row)
                                   self.pushToWalletViewController()
                               break
                               case 3:
                                   // self.pushToMyReviewScreen()
                               break
                            case 4:
                                
                                self.pushtoChangePasswordScreen()
                                break
                               case 5:
                                   print(indexPath.row)
                                   //change password
                                   self.pushToHelpViewControllerScreen()
                               break
                               case 6:
                                   self.titleString = infoArray.object(at: indexPath.row) as! String
                                   self.performSegue(withIdentifier: "ConditionPolicySegue", sender: self)
                                   print(indexPath.row)
                               break
                               case 7:
                                   self.titleString = infoArray.object(at: indexPath.row) as! String
                                   self.performSegue(withIdentifier: "ConditionPolicySegue", sender: self)
                                   print(indexPath.row)
                               break
                               case 8:
                                   print(indexPath.row)
                                   self.pushToFeedBackViewController()
                               break
                               case 9:
                                if let scene = UIApplication.shared.currentScene {
                                    SKStoreReviewController.requestReview(in: scene)
                                }
                                   print(indexPath.row)
                               break
                               case 10:
                                   self.shareApplicatioSelector()
                                   print(indexPath.row)
                               break
                               case 11:
                                print(indexPath.row)
                               break
                               case 12:
                                    self.presentCloseAccountPopUp()
                                break
                               
                           default:
                               DispatchQueue.main.async {
                                   SAAlertBar.show(.error, message:"Under development".localizedLowercase)
                               }
                               break
                           }
            }else{
                switch indexPath.row {
                               case 0:
                                   if let business = currentUser.businessDetail{
                                      //if account is on hold then resum it first then move to provider view
                                       print(business.isDeleted.bool)
                                       self.showUserProfileSwitchAlert()
                                   }else{
                                       self.showSwitchProfileWithOutProviderSetup()
                                   }
                                   print(indexPath.row)
                                   break
                               case 1:
                                   self.performSegue(withIdentifier: "MyAccountSegue", sender: self)
                                   print(indexPath.row)
                               break
                               case 2:
                                   print(indexPath.row)
                                   self.pushToWalletViewController()
                               break
                                /*
                               case 3:
                                   self.pushtoChangePasswordScreen()
                               break*/
                               case 4:
                                   print(indexPath.row)
                                   //change password
                                   self.pushToHelpViewControllerScreen()
                               break
                                case 3:
                                 self.pushToMyReviewScreen()
                                 break
                               case 5:
                                   self.titleString = infoArray.object(at: indexPath.row) as! String
                                   self.performSegue(withIdentifier: "ConditionPolicySegue", sender: self)
                                   print(indexPath.row)
                               break
                               case 6:
                                   self.titleString = infoArray.object(at: indexPath.row) as! String
                                   self.performSegue(withIdentifier: "ConditionPolicySegue", sender: self)
                                   print(indexPath.row)
                               break
                               case 7:
                                   print(indexPath.row)
                                   self.pushToFeedBackViewController()
                               break
                               case 8:
                                if let scene = UIApplication.shared.currentScene {
                                    SKStoreReviewController.requestReview(in: scene)
                                }
                                    
                                   print(indexPath.row)
                               break
                               case 9:
                                   self.shareApplicatioSelector()
                                   print(indexPath.row)
                               break
                                case 10:
                                   print(indexPath.row)
                                break
                            case 11:
                             self.presentCloseAccountPopUp()
                            break
                               
                           default:
                               DispatchQueue.main.async {
                                   SAAlertBar.show(.error, message:"Under development".localizedLowercase)
                               }
                               break
                           }
            }
           
        }

        /*
               //        infoArray = NSArray(objects: "My Profile","Messages","My Network","Professionals Around Me","Notifications","Terms & Condition","Privacy Policy","Share App","Rate App")
               
               if indexPath.row == 0 {
                   self.performSegue(withIdentifier: "MyAccountSegue", sender: self)
               }
               else if indexPath.row == 1 {
                   self.performSegue(withIdentifier: "messagesSegue", sender: self)
               }
               else if indexPath.row == 2 {
                   self.performSegue(withIdentifier: "myNetworkSegue", sender: self)
               }
               else if indexPath.row == 3 {
                   self.performSegue(withIdentifier: "proffesionalsSegue", sender: self)
               }
               else if indexPath.row == 4 {
                   self.performSegue(withIdentifier: "notificationsSegue", sender: self)
               }
                
    
        if indexPath.row == 0{ //switch user role provider customer
            if let _ = currentUser.businessDetail{
                self.showUserProfileSwitchAlert()
            }else{
                self.showSwitchProfileWithOutProviderSetup()
            }
            
        }else if indexPath.row == 1 { //profile
          
            if currentUser.userRoleType == .provider{
                DispatchQueue.main.async {
                    let objmainstoryboard = UIStoryboard.init(name: "Main", bundle: nil)
                    if let providerProfile = objmainstoryboard.instantiateViewController(withIdentifier: "ProviderProfileViewController") as? ProviderProfileViewController{
                        self.navigationController?.pushViewController(providerProfile, animated: true)
                    }
                           }
            }else{
                self.performSegue(withIdentifier: "MyAccountSegue", sender: self)
            }
            
        }else if indexPath.row == 2 { //my review provider customer
           self.pushToMyReviewScreen()
        }else if indexPath.row == 3{ // my wallet provider Market Research
            DispatchQueue.main.async {
                SAAlertBar.show(.error, message:"Under development".localizedLowercase)
            }
        }else if indexPath.row == 4{ //customer help provider wallet
            DispatchQueue.main.async {
                SAAlertBar.show(.error, message:"Under development".localizedLowercase)
            }
        }else if indexPath.row == 5 { //customer message provider help
            DispatchQueue.main.async {
                           SAAlertBar.show(.error, message:"Under development".localizedLowercase)
                       }
            if currentUser.userRoleType == .provider{
                
            }else{
                
            }
        }else if indexPath.row  == 6{ //customer terms provider message
            if currentUser.userRoleType == .provider{
                DispatchQueue.main.async {
                                         SAAlertBar.show(.error, message:"Under development".localizedLowercase)
                                     }
            }else{
                  self.titleString = infoArray.object(at: indexPath.row) as! String
                                self.performSegue(withIdentifier: "ConditionPolicySegue", sender: self)
            }
        }else if indexPath.row == 7 { //customer privacy provider terms
            if currentUser.userRoleType == .provider{
                DispatchQueue.main.async {
                                                        SAAlertBar.show(.error, message:"Under development".localizedLowercase)
                                                    }
            }else{
                self.titleString = infoArray.object(at: indexPath.row) as! String
                self.performSegue(withIdentifier: "ConditionPolicySegue", sender: self)
            }
        }
        else if indexPath.row == 8 { //customer feedback provider privacy
          
            if currentUser.userRoleType == .provider{
                self.titleString = infoArray.object(at: indexPath.row) as! String
                self.performSegue(withIdentifier: "ConditionPolicySegue", sender: self)
            }else{
                DispatchQueue.main.async {
                                                   SAAlertBar.show(.error, message:"Under development".localizedLowercase)
                                               }
            }
        }else if indexPath.row == 9 { //customer rate provider feedback
            if currentUser.userRoleType == .provider{
                DispatchQueue.main.async {
                                SAAlertBar.show(.error, message:"Under development".localizedLowercase)
                }
            }else{
                SKStoreReviewController.requestReview()

            }

        }else if indexPath.row == 10 { // customer share provider rate
            if currentUser.userRoleType == .provider{
                SKStoreReviewController.requestReview()
            }else{

            
            var urlString = String()
            
            urlString = "https://apps.apple.com/us/app/werkules/id1488572477"//"https://apps.apple.com/ng/app/werkules/id1488572477?ign-mpt=uo%3D2"
            
            let items = [URL(string: urlString)!]
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        
            }
            
           // UIApplication.shared.open(URL(string: "https://apps.apple.com/us/app/werkules/id1488572477")!, options: [:], completionHandler: nil)
        }else if indexPath.row == 11{ //provider share
            if currentUser.userRoleType == .provider{
                           
            }else{
                
            }
        }else{
            DispatchQueue.main.async {
                    SAAlertBar.show(.error, message:"Under development".localizedLowercase)
            }
        }
        */
        if currentUser.userRoleType == .provider && indexPath.row == 11{
             
        }else if currentUser.userRoleType == .customer && currentUser.loginType == "normal" && indexPath.row == 11{
            
        }else if currentUser.userRoleType == .customer && currentUser.loginType != "normal" && indexPath.row == 10{
            
        }else{
            if let container = self.so_containerViewController {
                container.isSideViewControllerPresented = false
            }
        }
        
        
    }
    func shareApplicatioSelector(){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                       return
                   
               }
        var strtext = "Hi, I would like to share the Werkules app with you. It provides a great way to find reliable businesses offering solid value, and a fantastic way to market your business. Use my Referral link below"
        
        var link =  "https://werkules.com/?code="
       
        link.append("\(currentUser.referalCode)")
        
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
                 strtext.append("\n\n\(longDynamicLink)\n\n")

                  let items = [strtext] as [Any]
                 let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                 activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                 
                 // present the view controller
                 self.present(activityViewController, animated: true, completion: nil)
        }
     
        
        
        
        
     
    }
    func showUserProfileSwitchAlert(){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
            return
        }
        if currentUser.userRoleType == .customer{
            if let business = currentUser.businessDetail{
                print(business.isDeleted.bool)
                if let isdeleted = business.isDeleted.bool{
                    //show alret for
                    if !isdeleted{
                        
                         let alert = UIAlertController(title: AppName, message: "In order to activate your provider account, you need to Resume account.\n\nDo you want to Resume account?", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
                                    
                                }))
                                
                                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                                    
                                    self.apiRequestForDeleteResumeAccount(isDeleted: true)
                                }))
                                 alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                                self.present(alert, animated: true, completion: nil)
                         
                        
                        /*
                        //Show Alert
                        UIAlertController.showAlertWithCancelButton(self, aStrMessage: "In order to activate your provider account, you need to Resume account.\nDo you want to Resume account?") { (objInt, strString) in
                                   if objInt == 0{ //resume account
                                       self.apiRequestForDeleteResumeAccount(isDeleted: true)
                                   }
                               }*/
                        return
                    }
                    
                }
            }
        }else{
            
        }
        //26/03/2021 as per client comment remove alert
        self.apiRequestForUserRoleSwitch()
        
        
    
    }
    func showSwitchProfileWithOutProviderSetup(){
        //Do you want to set up a business
        
        UIAlertController.showAlertWithCancelButton(self, aStrMessage: "Would you like to create a business profile?") { (objInt, strString) in
                   if objInt == 0{
                       self.pushToCreateBusinessScreen()
                   }
               }
    }
    func showsuspendresumeaccountalert(isdeleted:Bool){
        
        
        var strProviderSuspendResume = "Put Provider Account on Hold? You wont be able to receive any job requests if you do"
        if isdeleted{
            strProviderSuspendResume = "Resume Account?"
        }else{
            strProviderSuspendResume = "Put Provider Account on Hold? You wont be able to receive any job requests if you do"
        }
         let alert = UIAlertController(title: AppName, message: "Do you want to \(strProviderSuspendResume)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.apiRequestForDeleteResumeAccount(isDeleted: isdeleted)
        }))
       alert.view.tintColor = UIColor.init(hex: "#38B5A3")
        if isdeleted{
            self.present(alert, animated: true, completion: nil)
        }else{
            apiForAccountSuspendValidationMessage(isDeleted: isdeleted)
        }
    }
    func apiForAccountSuspendValidationMessage(isDeleted:Bool){
        var dict:[String:Any]  = [:]
            dict["is_suspended"] = !isDeleted
            APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kDeleteSuspendUser , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successMessage = success["success_data"] as? [String:Any] {
                            DispatchQueue.main.async {
                                if let boolvalue = successMessage["is_success"],let isSuccess = "\(boolvalue)".bool{
                                    if isSuccess{
                                        self.updateAccountOnHoldeSuccessAlert(response: successMessage,isDeleted:isDeleted)
                                    }else{
                                        self.updateFailHoldProviderPresentAccontAlert(response: successMessage)

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
//                            SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                        }
                    }
                }
    }
    func updateAccountOnHoldeSuccessAlert(response:[String:Any],isDeleted:Bool){
        var strProviderSuspendResume = "Put Provider Account on Hold? You wont be able to receive any job requests if you do"
             if isDeleted{
                 strProviderSuspendResume = "Resume Account?"
             }else{
                 strProviderSuspendResume = "Put Provider Account on Hold? You wont be able to receive any job requests if you do"
             }
              let alert = UIAlertController(title: AppName, message: "Do you want to \(strProviderSuspendResume)", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
             }))
             alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                 self.apiRequestForDeleteResumeAccount(isDeleted: isDeleted)
             }))
            alert.view.tintColor = UIColor.init(hex: "#38B5A3")
            self.present(alert, animated: true, completion: nil)
             
    }
    func updateFailHoldProviderPresentAccontAlert(response:[String:Any]){
        if let strtext = response["message"]{
            let alert = UIAlertController(title: "Werkules", message: "\n\(strtext)", preferredStyle: .alert)
          
          alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
            if let name = response["screen_name"]{
                 if "\(name)" == "provider_in_accept_job"{
                        self.pushToProviderAcceptJOB()
                }else if "\(name)" == "provider_in_progress_job"{
                        self.pushToProviderInprogress()
                }
            }
          }))
           alert.view.tintColor = UIColor.init(hex: "#38B5A3")
          self.present(alert, animated: true, completion: nil)
        }
     
    }
    func apiRequestForDeleteResumeAccount(isDeleted:Bool){
         var dict:[String:Any]  = [:]
         
            dict["is_suspended"] = !isDeleted
       print(dict)
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kDeleteSuspendUser , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successMessage = success["success_data"] as? [String:Any] {
                        DispatchQueue.main.async {
                                       if let message = successMessage["message"]{
                                           SAAlertBar.show(.error, message:"\(message)".localizedLowercase)
                                       }
                                   }
                
                guard let currentUser = UserDetail.getUserFromUserDefault() else {
                        return
                }
                if let businessdetail = currentUser.businessDetail{
                    if businessdetail.isDeleted == "1"{
                        businessdetail.isDeleted = "0"
                    }else if businessdetail.isDeleted == "0"{
                        businessdetail.isDeleted = "1"
                    }else{
                        businessdetail.isDeleted = "0"
                    }
                    currentUser.setuserDetailToUserDefault()
                    DispatchQueue.main.async {
                        //switch to customer home on account hold
                        if !isDeleted{ //move to customer home
                           self.apiRequestForUserRoleSwitch()
                        }else{
                            if currentUser.userRoleType == .customer{ //move to provider home if resume from customer home
                                self.apiRequestForUserRoleSwitch()
                            }
                        }
                            self.reloadTableData()
                    }
                    
                    }
                
                        //self.callLogoutAPI()
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
//                        SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                    }
                }
            }
}
    func apiRequestForUserRoleSwitch(){
        DispatchQueue.main.async {
            ExternalClass.ShowProgress()
        }
        APIRequestClient.shared.cancelAllPendingAPIRequest { response in
            DispatchQueue.main.async {
                ExternalClass.ShowProgress()
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {



        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                   return
        }
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            appDelegate.searchKeyword =  ""
//            appDelegate.searchKeywordProvider =  ""
        }
        var dict:[String:Any]  = [:]
        if currentUser.userRoleType == .customer{
            dict["role"] = "provider"
            //resume account if its on hold as per client CR 19/04/2021
            print(currentUser.businessDetail?.isDeleted.bool)
        }else if currentUser.userRoleType == .provider{
          dict["role"] = "customer"
        }
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSwitchAccount , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                ExternalClass.ShowProgress()
            }
                        if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"]{
                            
                            if let isApproved = success["is_approved"] as? Bool{
                                if isApproved{
                                        if currentUser.userRoleType == .customer{
                                         currentUser.userRoleType = .provider
                                        }else if currentUser.userRoleType == .provider{
                                         currentUser.userRoleType = .customer
                                        }
                                        currentUser.setuserDetailToUserDefault()
                                        DispatchQueue.main.async {
                                            if let isFirstTimeProvider = success["is_first_time_provider"],let isFirstTimeProviderProfile = "\(isFirstTimeProvider)".bool{
                                                if isFirstTimeProviderProfile{ //first time dynamic from backend
                                                    self.pushToCustomerOrProviderHomeViewController()
                                                    self.presentCustomerAndProviderHelpViewController()
                                                }else{//dynamic from backend
                                                    self.pushToCustomerOrProviderHomeViewController()
                                                }
                                            }else{ //current flow
                                                self.pushToCustomerOrProviderHomeViewController()
                                            }

                                        }
                                }else{
                                    if let strMessage = success["success_message"]{
                                        DispatchQueue.main.async {
                                            self.showAlertForSwitchingUser(strMessage: "\(strMessage)")
                                        }
                                    }
                                    
                                }
                            }else{
                                if currentUser.userRoleType == .customer{
                                                             currentUser.userRoleType = .provider
                                                           }else if currentUser.userRoleType == .provider{
                                                             currentUser.userRoleType = .customer
                                                           }
                                                           currentUser.setuserDetailToUserDefault()
                                                           DispatchQueue.main.async {
                                                               self.pushToCustomerOrProviderHomeViewController()
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
//                                     SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                 }
                             }
                         }
                        }
                       }
    }
    func showAlertForSwitchingUser(strMessage:String){
        let alert = UIAlertController(title: "Werkules", message: "\n\(strMessage)", preferredStyle: .alert)
               
               alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                    DispatchQueue.main.async {
                       // self.pushToCustomerOrProviderHomeViewController()
                    }
               }))
                alert.view.tintColor = UIColor.init(hex: "#38B5A3")
               self.present(alert, animated: true, completion: nil)
    }
    
    func pushtoCustomerInprogress(){
        //job_accept
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        VC.isForNotificationRedirection = true
        VC.notificatioType = "job_accept"
        let navigationController = UINavigationController(rootViewController:VC)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }
    func pushToCustomerNotStartedPage(){
        //job_not_started
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        VC.isForNotificationRedirection = true
        VC.notificatioType = "job_not_started"
        let navigationController = UINavigationController(rootViewController:VC)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }
    func pushToProviderInprogress(){
        //job_payment
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        VC.isForNotificationRedirection = true
        VC.notificatioType = "job_payment"
        let navigationController = UINavigationController(rootViewController:VC)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }
    func pushToProviderAcceptJOB(){
        //job_booked
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        VC.isForNotificationRedirection = true
        VC.notificatioType = "job_booked"
        let navigationController = UINavigationController(rootViewController:VC)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }
    
    func pushToCustomerOrProviderHomeViewController(){
        DispatchQueue.main.async {
            ExternalClass.ShowProgress()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
               
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController

                let navigationController = UINavigationController(rootViewController:VC)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = navigationController
        }
    }
    //MARK: - API
    func getBankAccontStatusAPIRequest(){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .GET, queryString:kGETPaymentReceiptAccountStatus, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["success_data"] as? [String:Any]{
                    DispatchQueue.main.async {
                            self.bankAccountStatus = successData
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
                            // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                         }
                     }
                 }
    }
    func getUserReviewAPIRequest(){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                        return
             }
        var dict:[String:Any]  = [:]
        dict["user_id"] = currentUser.id
        dict["limit"] = "1"
        dict["page"] = "1"
        
                APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGETUserReview , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                            if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                                if let totalRating = userInfo["total_rating"]{
                                    if let pi: Double = Double("\(totalRating)"){
                                        let rating = String(format:"%.1f", pi)
                                        self.currentRating = rating
                                    }
                                    if let totalReviewcount = userInfo["total_review"]{
                                        DispatchQueue.main.async {
                                            self.lblRating.text = "(\(totalReviewcount) Review)"
                                        }
                                        
                                    }
                                    
                                }
                               }else{
                                   DispatchQueue.main.async {
//                                       SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
    func callDeleteAccountAPI() {
        
        let dict = [
            APIManager.Parameter.userID : UserSettings.userID
        ]
        
        APIManager.sharedInstance.CallAPIPost(url: Url_deleteUser, parameter: dict, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                SAAlertBar.show(.success, message:dataDict["message"] as! String)
                
                self.clearModelData()
                self.reloadTableData()
                
                if let container = self.so_containerViewController {
                    container.isSideViewControllerPresented = false
                }
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    func popToLogInViewController(){
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let navigationController = UINavigationController(rootViewController:loginVC)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }
    func callLogoutAPI() {
        
        
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kProviderCustomerLogout , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                 if let success = responseSuccess as? [String:Any],let successMessage = success["success_data"] as? [String]{
                                   
                                       DispatchQueue.main.async {
                                            UserDefaults.standard.removeObject(forKey: "UserPassword")
                                        if successMessage.count > 0{
                                            SAAlertBar.show(.error, message:"\(successMessage.first!)".localizedLowercase)
                                        }
                                        DispatchQueue.main.async(execute: {
                                               UserDetail.removeUserFromUserDefault()
                                               self.popToLogInViewController()
                                               //self.navigationController?.popToRootViewController(animated: false)
                                           })
                                        
                                       }
                                        
                                      }else{
                                          DispatchQueue.main.async {
//                                              SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
//                                              SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                          }
                                      }
                                  }
        
        
        
        
   
        /*
        let dict = [
            APIManager.Parameter.userID : UserSettings.userID
        ]
        
        APIManager.sharedInstance.CallAPIPost(url: Url_logoutUser, parameter: dict, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false {
                print(JSONDICTIONARY as Any)
                
                UserSettings.userID = "0"
                UserSettings.isUserLogin = false
                UserDefaults.standard.set("0", forKey: "userID")
                UserDefaults.standard.set(false, forKey: "LocationUpdated")
                self.clearModelData()
                self.reloadTableData()
                
                if let container = self.so_containerViewController {
                    container.isSideViewControllerPresented = false
                    
                    let topVC = container.topViewController
                    container.topViewController = topVC
                    
                    let tabbar = topVC as! UITabBarController
                    tabbar.selectedIndex = 0
                    QBRequest.logOut(successBlock: { [weak self] response in
                        //ClearProfile
                        Profile.clearProfile()
                        //SVProgressHUD.dismiss()
                        //Dismiss Settings view controller
                        self?.dismiss(animated: false)

                        DispatchQueue.main.async(execute: {
                            self?.navigationController?.popToRootViewController(animated: false)
                        })
                    }) { response in
                        debugPrint("QBRequest.logOut error\(response)")
                    }
                
                    
                    UserDefaults.standard.set(true, forKey: "isFromSettings")
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })*/
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ConditionPolicySegue" {
            
            let vc = segue.destination as! ConditionPolicyVC
            vc.strTitle = self.titleString
        }else if segue.identifier == "MyAccountSegue" {
            let vc = segue.destination as! EntrepreneurProfileVC
//            vc.isOtherUser = false
//            vc.otherUserId = UserSettings.userID
        }else if segue.identifier == "MyAccountProviderSide" {
//                    let vc = segue.destination as! CustomerProfileAsProviderVC
            }
    }
    func pushtoChangePasswordScreen(){
        if let objChangePasssword = UIStoryboard.profile.instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC{
            objChangePasssword.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(objChangePasssword, animated: true)
            
        }
    }
    func pushToCreateBusinessScreen(){
        if let objBusinessprofile = self.storyboard?.instantiateViewController(withIdentifier: "CreateBusinssProfile") as? CreateBusinssProfile {
            objBusinessprofile.hidesBottomBarWhenPushed = true
            objBusinessprofile.isFromSidemenu = true
            objBusinessprofile.is_firsttimeregister = false
            objBusinessprofile.delegate = self
            self.navigationController?.pushViewController(objBusinessprofile, animated: true)
        }
    }
    
    func pushToWalletViewController(){
           if let walletViewController = UIStoryboard.activity.instantiateViewController(withIdentifier: "WalletViewController") as? WalletViewController{
               walletViewController.hidesBottomBarWhenPushed = true
               self.navigationController?.pushViewController(walletViewController, animated: true)
           }
       }
    func pushToMarketResearchViewController(){
        if let marketreseearchViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "MarketResearchViewController") as? MarketResearchViewController{
            marketreseearchViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(marketreseearchViewController, animated: true)
        }
    }
    func callCloseAccountValidationAPI(){
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kUserCloseAccountValidation, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["success_data"] as? [String:Any]{
                         DispatchQueue.main.async {
                            if let boolvalue = successData["is_success"],let isSuccess = "\(boolvalue)".bool{
                                
                                if !isSuccess{
                                    self.updateFailPresentCloseAccontAlert(response: successData)
                                }else{
                                    if let message = successData["message"]{
                                          self.updatePresentCloseAccountAlert(strtext: "\(message)")
                                      }
                                }
                            }
                            
                             }
                          }else{
                              DispatchQueue.main.async {
//                                  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
//                                  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                              }
                          }
                      }
    }
    func presentCloseAccountPopUp(){
        
        //Your available group earnings will be deposed to your bank account, minus the $1 transaction fee.
        self.callCloseAccountValidationAPI()
      
    }
    func updateFailPresentCloseAccontAlert(response:[String:Any]){
        if let strtext = response["message"]{
            let alert = UIAlertController(title: "We’re sad to see you go", message: "\n\(strtext)", preferredStyle: .alert)
          
          alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
            if let name = response["screen_name"]{
                guard let currentUser = UserDetail.getUserFromUserDefault() else {
                                       return
                            }
                if "\(name)" == "customer_not_started"{
                    if currentUser.userRoleType == .provider{
                        self.UpdateCurrentUserRoleSwitchOnCloseAccount(userresponse: response)
                    }else{
                        self.pushToCustomerNotStartedPage()
                    }
                }else if "\(name)" == "customer_in_progress_job"{
                    if currentUser.userRoleType == .provider{
                         self.UpdateCurrentUserRoleSwitchOnCloseAccount(userresponse: response)
                    }else{
                        self.pushtoCustomerInprogress()
                    }
                }else if "\(name)" == "provider_in_accept_job"{
                    if currentUser.userRoleType == .customer{
                        self.UpdateCurrentUserRoleSwitchOnCloseAccount(userresponse: response)
                    }else{
                        self.pushToProviderAcceptJOB()
                    }
                }else if "\(name)" == "provider_in_progress_job"{
                    if currentUser.userRoleType == .customer{
                        self.UpdateCurrentUserRoleSwitchOnCloseAccount(userresponse: response)
                    }else{
                        self.pushToProviderInprogress()
                    }
                }else if "\(name)" == "bank_account"{
                    self.pushToAddBackDetailWebView()
                }
            }
          }))
           alert.view.tintColor = UIColor.init(hex: "#38B5A3")
          self.present(alert, animated: true, completion: nil)
        }
     
    }
    func UpdateCurrentUserRoleSwitchOnCloseAccount(userresponse:[String:Any]){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                        return
             }
             var dict:[String:Any]  = [:]
             if currentUser.userRoleType == .customer{
                 dict["role"] = "provider"
                 //resume account if its on hold as per client CR 19/04/2021
                 print(currentUser.businessDetail?.isDeleted.bool)
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
                                     if let name = userresponse["screen_name"]{
                                         if "\(name)" == "customer_not_started"{
                                             self.pushToCustomerNotStartedPage()
                                         }else if "\(name)" == "customer_in_progress_job"{
                                             self.pushtoCustomerInprogress()
                                         }else if "\(name)" == "provider_in_accept_job"{
                                             self.pushToProviderAcceptJOB()
                                         }else if "\(name)" == "provider_in_progress_job"{
                                             self.pushToProviderInprogress()
                                         }else if "\(name)" == "bank_account"{
                                             self.pushToAddBackDetailWebView()
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
//                                          SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                      }
                                  }
                              }
    }
    func updatePresentCloseAccountAlert(strtext:String){
        let alert = UIAlertController(title: "We’re sad to see you go", message: "\n\(strtext)", preferredStyle: .alert)
                     
                     alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
                         
                     }))
                     
                     alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                        
                        self.callCloseAccountAPIRequest()
                        /*
                      if let accountCreated = self.bankAccountStatus["is_account_created"],let accuntVerify = self.bankAccountStatus["is_account_verify"]{
                                    if let created = "\(accountCreated)".bool{
                                        if let verify = "\(accuntVerify)".bool{
                                            if created && verify{
                                              self.callCloseAccountAPIRequest()
                                            }else{
                                              self.pushToAddBackDetailWebView()
                                          }
                                        }
                                    }
                      }else{
                          
                      }*/
                     }))
                      alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                     self.present(alert, animated: true, completion: nil)
    }
    
    func pushToAddBackDetailWebView(){
           DispatchQueue.main.async {
               if let addBankAccount = UIStoryboard.activity.instantiateViewController(withIdentifier: "AddBankdetailViewController") as? AddBankdetailViewController{
                   self.view.endEditing(true)
                   if let url = self.bankAccountStatus["web_hook_url"]{
                       addBankAccount.strwebURL = "\(url)"
                   }
                   
                     self.navigationController?.pushViewController(addBankAccount, animated: true)
               }
           }
          
       }
    func callCloseAccountAPIRequest(){
        /*{
            "status": "success",
            "success_data": [
                "Account closed successfully"
            ]
        }
         */
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kUserCloseAccount, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
             if let success = responseSuccess as? [String:Any],let successData = success["success_data"] as? [String]{
                     DispatchQueue.main.async {
                        if successData.count > 0{
                            SAAlertBar.show(.error, message:"\(successData.first!)".localizedLowercase)
                            self.popToLogInViewController()
                        }
                         }
                      }else{
                          DispatchQueue.main.async {
//                              SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                          }
                      }
                  }) { (responseFail) in
                   
                    if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String:Any]{
                       DispatchQueue.main.async {
                           if errorMessage.count > 0{
                            if let message = errorMessage["message"]{
                               SAAlertBar.show(.error, message:"\(message)".localizedLowercase)
                            }
                               
                           }
                       }
                   }else{
                          DispatchQueue.main.async {
//                              SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                          }
                      }
                  }
        
    }
    func pushToFeedBackViewController(){
        DispatchQueue.main.async {
            if let objFeedBackViewController = UIStoryboard.profile.instantiateViewController(withIdentifier: "FeedbackViewController") as? FeedbackViewController{
                       objFeedBackViewController.hidesBottomBarWhenPushed = true
                       self.navigationController?.pushViewController(objFeedBackViewController, animated: true)
                   }
        }
       
    }
}
extension SettingsVC:ReviewUpdatedCellDeletegate{
    func buttonFirstReviewSelector(isForHelp: Bool) {


        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        if isForHelp{
            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                return
            }
            if currentUser.userRoleType == .provider{
                self.presentCustomerOrProviderHelpViewController(isForCustomer: true)
            }else{
                self.presentCustomerOrProviderHelpViewController(isForCustomer: true)
            }
        }else{
            self.pushToCustomerReviewScreen()
        }
    }
    func buttonSecondReviewSelector(isForHelp: Bool){

        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        if isForHelp{
            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                return
            }
            if currentUser.userRoleType == .provider{
                self.presentCustomerOrProviderHelpViewController(isForCustomer: false)
            }else{
                if let _ = currentUser.businessDetail{
                    self.presentCustomerOrProviderHelpViewController(isForCustomer: false)
                }else{
                    //FAQ.
                    self.presentFAQViewController()
                }
            }
        }else{
            self.pushToMyReviewScreen()
        }
    }
    func buttonThirdReviewSelector() {

        self.presentFAQViewController()
    }
    func presentFAQViewController(){

        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        self.titleString = "Facts"
        self.performSegue(withIdentifier: "ConditionPolicySegue", sender: self)

    }
    func buttonExpandReviewSelector(isExpanded: Bool, isForHelp: Bool) {
        if isForHelp{
            self.isHelpOptionExpand = isExpanded
        }else{
            self.isReviewExpand = isExpanded
        }


    }
}
extension SettingsVC:CreateBusinessProfileDelegate{
    func redirectToProviderHome() {
        self.pushToCustomerOrProviderHomeViewController()
    }
}
