//
//  ActivityVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 25/12/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import SimpleImageViewer
import CoreLocation
import Firebase
import AVKit
import GoogleMobileAds

//@available(iOS 13.0, *)
class ActivityVC: UIViewController,UITableViewDataSource,UITableViewDelegate,imageDelegate,CLLocationManagerDelegate,GADBannerViewDelegate,SectionHeaderViewDelegate,GroupCellDelegate {
    
    @IBOutlet weak var tableActivity: UITableView!
    @IBOutlet weak var lblNoRecord:UILabel!
    @IBOutlet weak var buttonWallet:UIButton!
    
    @IBOutlet weak var lblNoGroupData:UILabel!
    
    @IBOutlet weak var buttonWithdrawAmount:UIButton!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLat = Double()
    var currentLong = Double()
    
    var isWebserviceCalled = Bool()
    
    var activityArray = NSArray()
    var selectedIndex = Int()
    var status = String()
    
    var refreshControl = UIRefreshControl()
    
    let SectionHeaderViewIdentifier = "SectionHeaderViewIdentifier"
      
    var sectionInfoArray: NSMutableArray = []
    
    
    @IBOutlet weak var lblTotalTransaction:UILabel!
    @IBOutlet weak var lblTotalEarning:UILabel!
    @IBOutlet weak var containerViewforlevel:UIView!
    @IBOutlet weak var containerShare:UIView!
    
    @IBOutlet weak var moreview:UIView!
    
    @IBOutlet weak var buttonBadgeCount:UIButton!

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
    var arrayOfLevelOne:NSMutableArray = []
    var arrayOfLevelSecond:NSMutableArray = []
       var bankAccountStatus:[String:Any] = [:]
    
    var strShareText = "Refer Werkules to your friends and business contacts to build your group and start earning referral fees"
    
    var groupEarningHelpStr: String = ""
    var referralCodeHelpStr: String = ""
    
    //111 NewUI
    @IBOutlet weak var btnReferralCode:UIButton!
    @IBOutlet weak var viewDetails:UIView!
    @IBOutlet weak var btnExpand:UIButton!
    
    var isExpanded:Bool = true
    var isDetailExpanded:Bool{
        get{
            return isExpanded
        }
        set{
            self.isExpanded = newValue
            //ConfigureUpdate value
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.btnExpand.isSelected = newValue
                    self.viewDetails.isHidden = !newValue
                }
            }
        }
        
    }
    @IBOutlet weak var lblTotalEarningUpdate:UILabel!
    @IBOutlet weak var lblTotalTransactionUpdate:UILabel!
    @IBOutlet weak var lblTotalWithdrawUpdate:UILabel!
    @IBOutlet weak var btnWithdrawEarningUpdate:UIButton!
    @IBOutlet weak var lblTotalEarningHoldUpdate:UILabel!
    
    //MARK: - UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.moreview.layer.borderColor = UIColor.lightGray.cgColor
        self.moreview.layer.borderWidth = 0.5
        self.moreview.layer.cornerRadius = 6.0
        self.moreview.clipsToBounds = true
        //configure tableview
        self.configureTableView()
        
        let underlineSeeDetail = NSAttributedString(string: "Withdraw Earnings",
                                                                              attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
              self.buttonWithdrawAmount.titleLabel?.attributedText = underlineSeeDetail
        //111 NewUI
        self.btnWithdrawEarningUpdate.setAttributedTitle(underlineSeeDetail, for:.normal)
        //self.buttonWithdrawAmount.titleLabel?.attributedText = underlineSeeDetail
        //self.btnWithdrawEarningUpdate.titleLabel?.attributedText = underlineSeeDetail
        
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                             return
                     }
        print(currentUser.referalCode)
        let strCode = "Referral Code:\(currentUser.referalCode)"
        let underlineReferralCode = NSAttributedString(string: "\(strCode)",
                                                                        attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnReferralCode.setAttributedTitle(underlineReferralCode, for: .normal)
        

        self.btnExpand.adjustsImageWhenHighlighted = false
        self.btnExpand.tintColor = UIColor.black
        self.btnExpand.setImage(UIImage(named: "up_arrow"), for: UIControl.State.selected)
        self.btnExpand.setImage(UIImage(named: "down_arrow"), for: UIControl.State.normal)
     
        
        self.isDetailExpanded = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshGroupFromNotification(notification:)), name: .groupRefresh, object: nil)

        var strGroupMembers = "Group Members Affiliate Earnings (0)"
        let firstSection: SectionInfo = SectionInfo(itemsInSection: ["1"], sectionTitle: "\(strGroupMembers)")
        self.sectionInfoArray.removeAllObjects()
        self.sectionInfoArray.add(firstSection)
        self.tableActivity.reloadData()

        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfNewMessageReceiveNotification(notification:)), name: .chatUnreadCount, object: nil)
        self.getMyGroupListAPIRequestMethods()
        
    }
    @objc func methodOfNewMessageReceiveNotification(notification:Notification){
        if let userInfo = notification.userInfo as? [String:Any]{
            print(userInfo)
            self.callAPIRequestToGetChatUnreadCount()
        }
    }
    @objc func refreshGroupFromNotification(notification: Notification) {
        DispatchQueue.main.async {
            var strGroupMembers = "Group Members Affiliate Earnings (0)"
            let firstSection: SectionInfo = SectionInfo(itemsInSection: ["1"], sectionTitle: "\(strGroupMembers)")
            self.sectionInfoArray.removeAllObjects()
            self.sectionInfoArray.add(firstSection)
            self.tableActivity.reloadData()
            self.getMyGroupListAPIRequestMethods()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.moreview.isHidden = true

        self.getBankAccontStatusAPIRequest()


        
    }
    func getBankAccontStatusAPIRequest(){
         
         APIRequestClient.shared.sendAPIRequest(requestType: .GET, queryString:kGETPaymentReceiptAccountStatus, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
             if let success = responseSuccess as? [String:Any],let successData = success["success_data"] as? [String:Any]{
                     DispatchQueue.main.async {
                             self.bankAccountStatus = successData
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
                             // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                          }
                      }
                  }
     }
    func configureTableView(){
        let sectionHeaderNib: UINib = UINib(nibName: "SectionHeaderView", bundle: nil)
        self.tableActivity.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: SectionHeaderViewIdentifier)

        
        //GroupTableViewCell
//        self.tableActivity.register(UINib(nibName: "GroupTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupTableViewCell")
        self.tableActivity.register(UINib(nibName: "GroupUpdateTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupUpdateTableViewCell")

        
        // you can change section height based on your needs
        self.tableActivity.delegate = self
        self.tableActivity.dataSource = self
        self.tableActivity.rowHeight = UITableView.automaticDimension
        self.tableActivity.estimatedRowHeight = 314.0
        self.tableActivity.sectionHeaderHeight = 30
        self.tableActivity.hideHeader()
//        self.tableActivity.scrollEnableIfTableViewContentIsLarger()
        self.tableActivity.reloadData()
        
        
      
    }
    func addMenuItems(arrayLevelOne:[[String:Any]],arrayLevelTwo:[[String:Any]]) {
        // You should set up your SectionInfo here
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                                              return
                                      }
              let count = arrayLevelOne.count+arrayLevelTwo.count
               var strGroupMembers = "Group Members: Affiliate Earnings (\(count))"
               /*if currentUser.referalCode.count > 0 {
                   strGroupMembers = "Group Members (Ref Code:\(currentUser.referalCode))"
               }*/
            
              let firstSection: SectionInfo = SectionInfo(itemsInSection: ["1"], sectionTitle: "\(strGroupMembers)")
        
               self.arrayOfLevelOne.removeAllObjects()
        
                for objUserLevelOne in arrayLevelOne{

                    let objcellinfo = GroupCellInfo.init(isExpanded: false, isOptionsDetailShown: false)
                    objcellinfo.userDetail = objUserLevelOne
                    self.arrayOfLevelOne.add(objcellinfo)
                 }
              
              
              
              firstSection.itemsInSection = self.arrayOfLevelOne
              
              let secondSection: SectionInfo = SectionInfo(itemsInSection: ["2"], sectionTitle: "Level 2")
              
              self.arrayOfLevelSecond.removeAllObjects()
        
                for objUserLevelTwo in arrayLevelTwo{
                   let objsecondcellinfo = GroupCellInfo.init(isExpanded: false, isOptionsDetailShown: false)
                   objsecondcellinfo.userDetail = objUserLevelTwo
                   self.arrayOfLevelSecond.add(objsecondcellinfo)
                }
              secondSection.itemsInSection = self.arrayOfLevelSecond
        if self.arrayOfLevelOne.count > 0{
                //111 NewUI
                self.sectionInfoArray.removeAllObjects()
                self.sectionInfoArray.add(firstSection)
            }
        if self.arrayOfLevelSecond.count > 0{
                self.sectionInfoArray.add(secondSection)
            }
            //self.sectionInfoArray.addObjects(from: [firstSection, secondSection])
            self.tableActivity.reloadData()
        
        if self.sectionInfoArray.count > 0{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.sectionHeaderView(status: .open, sectionOpened: 0)
                //self.sectionHeaderView(status: .open, sectionClosed: 0)
            }
        }
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.callAPIRequestToGetChatUnreadCount()
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                                   return
                           }
              //strShareText += "\n\nReferral Code: \(currentUser.referalCode)"
              DispatchQueue.main.async {
                  self.lblNoGroupData.text = "\(self.strShareText)"//"\n\nReferral Code: \(currentUser.referalCode)"
              }
        //111 NewUI
        //self.sectionInfoArray.removeAllObjects()

//        UserDefaults.standard.set(false, forKey: "ActivityAdded")
//
//        let bool = UserDefaults.standard.bool(forKey: "forJobProfile")
//
//        if bool == true {
//
//            UserDefaults.standard.set(false, forKey: "forJobProfile")
//
//            isWebserviceCalled = false
//            self.mylocation()
//        }
//        else{
//            UserDefaults.standard.set(false, forKey: "forJobProfile")
//        }

    }
    func callAPIRequestToGetChatUnreadCount(){
        APIRequestClient.shared.sendAPIRequest(requestType: .GET, queryString:kGETChatUnreadCount, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["success_data"] as? Int{
                    DispatchQueue.main.async {
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
                             //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                         }
                     }
                 }
    }
    @objc func refreshScreen() {
        
        self.callAPIToGetActivityList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.isWebserviceCalled = false
        self.locationManager.stopUpdatingLocation()

    }
    
    // MARK: - GADBannerViewDelegate
    // Called when an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called when an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(#function): \(error.localizedDescription)")
    }
    
    // Called just before presenting the user a full screen view, such as a browser, in response to
    // clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just before dismissing a full screen view.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just after dismissing a full screen view.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just before the application will background or terminate because the user clicked on an
    // ad that will launch another application (such as the App Store).
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print(#function)
    }
    
//    // MARK: - GADAdLoaderDelegate
//
//    func adLoader(_ adLoader: GADAdLoader,
//                  didFailToReceiveAdWithError error: GADRequestError) {
//      print("\(adLoader) failed with error: \(error.localizedDescription)")
//
//    }
//
//    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
//      print("Received native ad: \(nativeAd)")
//
//      // Add the native ad to the list of native ads.
//      nativeAds.append(nativeAd)
//    }
//
//    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
////      enableMenuButton()
//
//        let recordCount = ActivityModel.Shared.arrActivities.count
//
//        tableActivity.reloadData()
//    }
    
    //MARK: - Selector Methods Cell
    //111 NewUI
    @IBAction func buttonChatListSelector(sender:UIButton){
        self.pushtoChatListViewController()
    }
    func pushtoChatListViewController(){
        if let chatListViewController = UIStoryboard.messages.instantiateViewController(identifier: "ChatListViewController") as? ChatListViewController{
            chatListViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatListViewController, animated: true)
        }

    }
    @IBAction func buttonFileReportSelector(sender:UIButton){
        self.pushtoReportProblemViewController()
    }
    func pushtoReportProblemViewController(){
        let profileStroyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        if let reportBugViewController = profileStroyboard.instantiateViewController(withIdentifier: "ReportBugViewController") as? ReportBugViewController{
             reportBugViewController.isForFileDispute = false
            reportBugViewController.isForGroupFileDispute = true
            reportBugViewController.hidesBottomBarWhenPushed = true
            reportBugViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(reportBugViewController, animated: true)
        }
    }
    @IBAction func buttonExpandSelector(sender:UIButton){
        self.isDetailExpanded = !self.isDetailExpanded
    }
    @IBAction func buttonAddtoyourGroupSelector(sender:UIButton){
        self.sectionHeaderView(status: .open, sectionOpened: 0)
        self.showAddToYourGroupAlert()
    }
    @IBAction func buttonShareyourReferralNumberSelector(sender:UIButton){
        self.sectionHeaderView(status: .open, sectionOpened: 0)
        self.showShareYourReferralNumberAlert()
    }
    func showAddToYourGroupAlert(){
        
        let alert = UIAlertController(title: "Add to your Group", message: "You can invite anyone to your group, however, they can only join if they don’t already belong to a group.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.shareApplicatioReferrelCodeSelector()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        alert.view.tintColor = UIColor.init(hex: "#38B5A3")
        self.present(alert, animated: true, completion: nil)
    }
    func showShareYourReferralNumberAlert(){
        
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                return
         }
        if currentUser.referalCode.count > 0 {
            UIPasteboard.general.string = "\(currentUser.referalCode)"
        }
        let alert = UIAlertController(title: "Share your Referral Number", message: "Your referral code has been copied. A Werkules user – who does not currently belong to a group – can add themselves to your group by entering your referral code into their customer profile.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            
        }))
        alert.view.tintColor = UIColor.init(hex: "#38B5A3")
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func buttonHelpSelector(sender:UIButton){
                DispatchQueue.main.async {
                    var strMessage = ""
                    strMessage = self.groupEarningHelpStr
                    UIAlertController.showAlertWithOkButton(self, aStrTitle: "Withdraw Earnings Help", aStrMessage: "\(strMessage)", completion: nil)
                }
                
            }
    @IBAction func buttonReferralCodeHelp(sender:UIButton){
        DispatchQueue.main.async {
            var strMessage = ""
            strMessage = self.referralCodeHelpStr
            UIAlertController.showAlertWithOkButton(self, aStrTitle: "Referral Code Help", aStrMessage: "\(strMessage)", completion: nil)
        }
    }
    @IBAction func buttonReferralCodeSelector(sender:UIButton){
        DispatchQueue.main.async {
            let strMessage = "Your referral code has been copied."
            UIAlertController.showAlertWithOkButton(self, aStrTitle: AppName, aStrMessage: "\(strMessage)", completion: nil)
        }
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                return
         }
        if currentUser.referalCode.count > 0 {
            UIPasteboard.general.string = "\(currentUser.referalCode)"
        }
    }
    @IBAction func buttonWithdrawEarning(sender:UIButton){
        self.pushtoWithdrawEarningScreenViewController()
        /*
        if let accountCreated = self.bankAccountStatus["is_account_created"],let accuntVerify = self.bankAccountStatus["is_account_verify"]{
                                   if let created = "\(accountCreated)".bool{
                                       if let verify = "\(accuntVerify)".bool{
                                           if created && verify{
                                            self.pushtoWithdrawEarningScreenViewController()
                                            
                                           }else{
                                             self.pushToAddBackDetailWebView()
                                         }
                                       }
                                   }
                                 }*/
        
    }
     func pushToAddBackDetailWebView(){
           DispatchQueue.main.async {
               if let addBankAccount = UIStoryboard.activity.instantiateViewController(withIdentifier: "AddBankdetailViewController") as? AddBankdetailViewController{
                   self.view.endEditing(true)
                   if let url = self.bankAccountStatus["web_hook_url"]{
                       addBankAccount.strwebURL = "\(url)"
                   }
                   addBankAccount.delegate = self
                   addBankAccount.isFromBussiness = false
                addBankAccount.hidesBottomBarWhenPushed = true
                     self.navigationController?.pushViewController(addBankAccount, animated: true)
               }
           }
          
       }
      //push to withdraw earning screen
      func pushtoWithdrawEarningScreenViewController(){
          DispatchQueue.main.async {
          if let withdrawearningscreen = UIStoryboard.activity.instantiateViewController(withIdentifier: "WithdrawEarningViewController") as? WithdrawEarningViewController{
              self.view.endEditing(true)
              if let amount = self.lblTotalEarning.text{
                  withdrawearningscreen.earningAvailable = "\(amount)"
              }
            withdrawearningscreen.earningHelpStr = "\(self.groupEarningHelpStr)"
            withdrawearningscreen.hidesBottomBarWhenPushed = true
              self.navigationController?.pushViewController(withdrawearningscreen, animated: true)
          }
      }
    }
    @IBAction func buttonWalletSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.pushToWalletViewController()
        }
        
    }
    @IBAction func buttonAddToNetworkSelector(sender:UIButton){
           DispatchQueue.main.async {
            //self.shareApplicatioReferrelCodeSelector()
            self.showAddToYourGroupAlert()
           }
           
       }
    func shareApplicatioReferrelCodeSelector(){
        self.shareApplicatioSelector()
        /*
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                      
                      return
                  }
        var urlString = String()
        urlString = "\(currentUser.referalCode)"
        
        let items = [URL(string: urlString)!]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)*/
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
                  strtext.append("\n\n\(longDynamicLink)")

                   let items = [strtext] as [Any]
                  let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                  activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                  
                  // present the view controller
                  self.present(activityViewController, animated: true, completion: nil)
        }}
    //MARK: - API Request Methods
    func getMyGroupListAPIRequestMethods(){

        var strMyGroup_debug = "Customer My Group - Start \(Date())  - Seconds \(Date().dateInMiliSeconds) -"

        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCustomerProviderGroupList , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                  if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                    //111 NewUI
                    DispatchQueue.main.async {
                        strMyGroup_debug += "Customer My Group - End \(Date())  - Seconds \(Date().dateInMiliSeconds)"
                        self.saveLogAPIRequest(title: "MyGroup", message: "\(strMyGroup_debug)")
                        if let total_transactions = userInfo["total_transactions"],!(total_transactions is NSNull){
                            if let pi: Double = Double("\(total_transactions)"){
                                let updatedValue = String(format:"%.2f", pi)
                                self.lblTotalTransactionUpdate.text = CurrencyFormate.Currency(value: Double(updatedValue) ?? 0.00)
                                self.lblTotalTransaction.text = CurrencyFormate.Currency(value: Double(updatedValue) ?? 0.00 )//"$\(updatedValue)"
                            }
                        }else{
                            self.lblTotalTransactionUpdate.text = "$0.00"
                            self.lblTotalTransaction.text = "$0.00"
                        }
                         /*if let total_earnings = userInfo["total_earnings"]{
                            self.lblTotalEarning.text = "$ \(total_earnings)"
                         }*/
                        if let total_earnings = userInfo["total_earnings_available"],!(total_earnings is NSNull){
                            if let pi: Double = Double("\(total_earnings)"){
                                let updatedValue = String(format:"%.2f", pi)
                                self.lblTotalEarningUpdate.text = CurrencyFormate.Currency(value: Double(updatedValue) ?? 0.00)

                                self.lblTotalEarning.text = CurrencyFormate.Currency(value: Double(updatedValue) ?? 0.00 )//"$\(updatedValue)"
                            }
                        }else{
                            self.lblTotalEarningUpdate.text = "$0.00"
                            self.lblTotalEarning.text = "$0.00"
                        }
                        if let total_earnings = userInfo["total_withdrawn"],!(total_earnings is NSNull){
                            if let pi: Double = Double("\(total_earnings)"){
                            let updateValue = String(format:"%.2f", pi)
                                self.lblTotalWithdrawUpdate.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0.00)
                            }
                           
                        }else{
                            self.lblTotalWithdrawUpdate.text = "$0.00"
                        }
                        
                        if let total_earnings = userInfo["total_earnings_30_days_hold"],!(total_earnings is NSNull){
                            if let pi: Double = Double("\(total_earnings)"){
                            let updateValue = String(format:"%.2f", pi)
                                self.lblTotalEarningHoldUpdate.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0.00)
                            }
                           
                        }else{
                            self.lblTotalEarningHoldUpdate.text = "$0.00"
                        }
                        if let msgStr = userInfo["group_earning_help"] as? String{
                            self.groupEarningHelpStr = msgStr
                        }
                        if let msgStr = userInfo["referral_code_help"] as? String{
                            self.referralCodeHelpStr = msgStr
                        }
                    }
                 
                    if let arraylevelone:[[String:Any]] = userInfo["level_one"] as? [[String:Any]],arraylevelone.count > 0{
                        DispatchQueue.main.async {
                            self.containerShare.isHidden = true
                            self.containerViewforlevel.isHidden = false
                        }
                        self.arrayOfLevelOne.removeAllObjects()
                        self.arrayOfLevelSecond.removeAllObjects()

                        var levelone:[[String:Any]] = arraylevelone
                        var leveltwo :[[String:Any]] = []
                        if let arraylevel_two:[[String:Any]] = userInfo["level_two"] as? [[String:Any]],arraylevel_two.count > 0{
                            
                            leveltwo = arraylevel_two
                           
                            
                        }
                        DispatchQueue.main.async {
                            self.addMenuItems(arrayLevelOne: levelone, arrayLevelTwo: leveltwo)
                            self.tableActivity.reloadData()

                        }
                        //show tableview
                        //self.tableActivity.isHidden = false
                    }else{
                        DispatchQueue.main.async {
                            self.containerShare.isHidden = false
                            //111 NewUI
                            self.containerViewforlevel.isHidden = false
                        }
                        //hide tableview
                       // self.tableActivity.isHidden = true
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
//                                     SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)

                                 }
                            
                            }
        }}
    func saveLogAPIRequest(title:String = "",message:String = ""){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
            return
        }
        let dict = [
                   "user_id": "\(currentUser.id)",
                   "log_module" : "\(title)",
                   "log_description" : "\(message)",
                   "log_platform" : "ios"
            ]
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSaveLog , parameter: dict as [String:AnyObject], isHudeShow: false, success: { (responseSuccess) in

        }) { (responseFail) in

        }
    }
    //MARK: - Register Cell
    
    func RegisterCell() {
        self.tableActivity.register(UINib(nibName: "ActivityCell", bundle: nil), forCellReuseIdentifier: "ActivityCell")
        //self.tableActivity.register(UINib(nibName: "ActivityReviewCell", bundle: nil), forCellReuseIdentifier: "ActivityReviewCell")
        //self.tableActivity.register(UINib(nibName: "AdsCell", bundle: nil), forCellReuseIdentifier: "AdsCell")
    }
    
    //MARK: - UITableView Datasource & Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionInfoArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if self.sectionInfoArray.count > 0 {
             
            var sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
         DispatchQueue.main.async {
             if sectionInfo.open {
              self.moreview.isHidden = false
                 //return sectionInfo.open ? sectionInfo.itemsInSection.count : 0
             }else{
              self.moreview.isHidden = true
                 //return 0
             }
         }
         return sectionInfo.itemsInSection.count
        }else{
         return 0
        }
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView: SectionHeaderView! = self.tableActivity.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderViewIdentifier) as! SectionHeaderView
        var sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
        sectionHeaderView.titleLabel.text = sectionInfo.sectionTitle
        sectionHeaderView.delegate = self
        sectionHeaderView.tag = section
        sectionHeaderView.disclosureButton.isSelected = sectionInfo.open
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        //detail shown
        
        //return 265
        //return 100.0 // 65 200
    }
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % 5 == 0  && indexPath.row != 0 {
            return tableView.frame.size.width
        }
        
        var index = self.getIndex(indexPath: indexPath.row)
        index = indexPath.row - index
        print(index)
    
        var height = CGFloat()
        
        let dataDict = ActivityModel.Shared.arrActivities[index]
        let jobDict = ActivityModel.Shared.arrActivities[index].jobDict
        let jobUserDict = jobDict?.value(forKey: "user") as! NSDictionary
        let userDict = ActivityModel.Shared.arrActivities[index].userDict
        
        if dataDict.activityType == "review" {
            
            height = 30
            if userDict != nil {
                let title = String(format: "%@ gave review to %@ for : %@", (userDict!["firstname"] as! String) + " " + (userDict!["lastname"] as! String),(jobUserDict["firstname"] as! String) + " " + (jobUserDict["lastname"] as! String), (jobDict?.value(forKey: "title") as! String))
                
                let titleHeight = title.height(withConstrainedWidth: self.view.frame.size.width - 116, font: .systemFont(ofSize: 16))
                height = height + titleHeight + 20
            }
            
            return height
        }
        else {
            height = 51
            
            let title = (jobDict?.value(forKey: "title") as! String)
            
            if title != "" {
                let titleHeight = title.height(withConstrainedWidth: self.view.frame.size.width - 20, font: .systemFont(ofSize: 16))
                height = height + 10 + titleHeight
            }
            
            if (jobDict!.value(forKey: "file1") as! String) != "" ||
                (jobDict!.value(forKey: "file2") as! String) != "" ||
                (jobDict!.value(forKey: "file3") as! String) != "" ||
                (jobDict!.value(forKey: "file4") as! String) != ""  {
                
                height = height + 30 + self.view.frame.size.width//self.view.window!.frame.size.width
            }
            
            return height + 75.5
        }
        
        return height
    }
    */
    func getIndex( indexPath : Int) -> Int {
        
        if indexPath < 4 {
            return 0
        }
        var count = Int()
        count = 0
        for i in 0...indexPath {
            if i % 5 == 0 {
                count += 1
            }
        }
        return count
    }
    func sectionHeaderView(status: SectioStatus, sectionClosed: Int) {
        var sectionInfo: SectionInfo = sectionInfoArray[sectionClosed] as! SectionInfo
        sectionInfo.open = true
        DispatchQueue.main.async {
            self.tableActivity.reloadSections(IndexSet(integer: sectionClosed), with: .automatic)
        }
    }
    func sectionHeaderView(status: SectioStatus, sectionOpened: Int) {
        var sectionInfo: SectionInfo = sectionInfoArray[sectionOpened] as! SectionInfo
         sectionInfo.open = false
        DispatchQueue.main.async {
            self.tableActivity.reloadSections(IndexSet(integer: sectionOpened), with: .automatic)
        }
    }
    /*
    func sectionHeaderView(sectionHeaderView: SectionHeaderView, sectionOpened: Int) {
        var sectionInfo: SectionInfo = sectionInfoArray[sectionOpened] as! SectionInfo
        sectionInfo.open = true
        
        DispatchQueue.main.async {
            
            self.tableActivity.reloadData()
        }
     
        
    }
    
    func sectionHeaderView(sectionHeaderView: SectionHeaderView, sectionClosed: Int) {
        var sectionInfo: SectionInfo = sectionInfoArray[sectionClosed] as! SectionInfo
        var countOfRowsToDelete = sectionInfo.itemsInSection.count
        sectionInfo.open = false
       DispatchQueue.main.async {
                  self.tableActivity.reloadData()
              }
    }*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableActivity.dequeueReusableCell(withIdentifier: "GroupTableViewCell") as! GroupTableViewCell
        let cell = tableActivity.dequeueReusableCell(withIdentifier: "GroupUpdateTableViewCell") as! GroupUpdateTableViewCell
        cell.delegate = self
        cell.tag = indexPath.row
        cell.section = indexPath.section
        //cell.detailview.isHidden = true
        let sectionInfo: SectionInfo = sectionInfoArray[indexPath.section] as! SectionInfo
        
        if let item:GroupCellInfo = sectionInfo.itemsInSection[indexPath.row] as? GroupCellInfo{
                   cell.detailview.isHidden = !item.isExpanded
                    cell.buttonExpand.isSelected = item.isExpanded
                   cell.buttonmore.isSelected = item.isOptionsDetailShown
                   cell.moreview.isHidden = !item.isOptionsDetailShown

            if let totalTransaction = item.userDetail["total_transactions"],let transactionEarning = item.userDetail["transactions_earning"],let promotionEarning = item.userDetail["promotion_earning"],let holdEarning = item.userDetail["hold_earning"],let availableEarning = item.userDetail["available_earning"]{
                if let intTotalTransaction = Int("\(totalTransaction)"),intTotalTransaction == 0,let intTransactionEarning = Int("\(transactionEarning)"),intTransactionEarning == 0,let intpromotionEarning = Int("\(promotionEarning)"),intpromotionEarning == 0,
                   let intholdEarning = Int("\(holdEarning)"),intholdEarning == 0,let intavailableEarning = Int("\(availableEarning)"), intavailableEarning == 0{
//                    cell.buttonExpand.isHidden = item.isExpanded ? false : true
                }else{
//                    cell.buttonExpand.isHidden = false
                }
            }else{
//                cell.buttonExpand.isHidden = false
            }

            print(item.userDetail)
           if let imageURL = URL.init(string: "\(item.userDetail["profile_pic"] ?? "")"){
               cell.imageProfile!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
           }
            if let firstname = item.userDetail["firstname"],let lastname = item.userDetail["lastname"]{
                cell.lblUserName.text  = "\(firstname) \(lastname)"
            }
            if let rating = item.userDetail["rating"]{
                if let pi: Double = Double("\(rating)"){
                 let rating = String(format:"%.1f", pi)
                    cell.lblUserRating.text = "\(rating)"
             }
            }
            if let total_transactions = item.userDetail["total_transactions"]{
                if let pi: Double = Double("\(total_transactions)"){
                        let updatedValue = String(format:"%.2f", pi)
                     cell.lblTotalTransaction.text = CurrencyFormate.Currency(value: Double(updatedValue) ?? 0)//"$\(updatedValue)"
                }
            }
            if let available_earning = item.userDetail["available_earning"]{
                if let pi: Double = Double("\(available_earning)"){
                let updatedValue = String(format:"%.2f", pi)
                cell.lblAvailableEarning.text = CurrencyFormate.Currency(value: Double(updatedValue) ?? 0)//"$\(updatedValue)"
                }
            }
            if let transactions_earning = item.userDetail["transactions_earning"]{
                if let pi: Double = Double("\(transactions_earning)"){
                               let updatedValue = String(format:"%.2f", pi)
                cell.lblTransactionEarning.text =  CurrencyFormate.Currency(value: Double(updatedValue) ?? 0)//"$\(updatedValue)"
                }
            }
            if let promotion_earning = item.userDetail["promotion_earning"]{
                if let pi: Double = Double("\(promotion_earning)"){
                let updatedValue = String(format:"%.2f", pi)
                cell.lblPromotionEarning.text =  CurrencyFormate.Currency(value: Double(updatedValue) ?? 0)//"$\(updatedValue)"
                }
            }
            if let hold_earning = item.userDetail["hold_earning"]{
                if let pi: Double = Double("\(hold_earning)"){
                let updatedValue = String(format:"%.2f", pi)
                    cell.lblHoldAmount.text = CurrencyFormate.Currency(value: Double(updatedValue) ?? 0)//"$\(updatedValue)"
                }
            }
            
            //total_transactions
            //available_earning
            //transactions_earning
            //promotion_earning
            //hold_earning
            
        }
      
        return cell
        /*
        if indexPath.row % 5 == 0 && indexPath.row != 0 {
            
            let cell = tableActivity.dequeueReusableCell(withIdentifier: "AdsCell") as! AdsCell
            cell.selectionStyle = .none
            
            cell.bannerView.delegate = self
            cell.bannerView.adUnitID = "ca-app-pub-2506968306282138/1974689087" // werkules ID
//            cell.bannerView.adUnitID = "ca-app-pub-7983624777979755/9143070076" // test working ID
            cell.bannerView.rootViewController = self
            cell.bannerView.load(GADRequest())
            
            return cell
        }
        else {
            var index = self.getIndex(indexPath: indexPath.row)
                index = indexPath.row - index
                print(index)
            
                
                var jobProgressUserDict = NSDictionary()
                var progressUserID = Int()
                
                let dataDict = ActivityModel.Shared.arrActivities[index]
                let jobDict = ActivityModel.Shared.arrActivities[index].jobDict
                if jobDict?.value(forKey: "user_progress_by") is String == false {
                    jobProgressUserDict = jobDict?.value(forKey: "user_progress_by") as! NSDictionary
                    progressUserID = jobProgressUserDict.value(forKey: "id") as! Int
                }
                let jobUserDict = jobDict?.value(forKey: "user") as! NSDictionary
                let userDict = ActivityModel.Shared.arrActivities[index].userDict
                
                let userID = userDict?.value(forKey: "id") as! Int
                let toUserID = jobUserDict.value(forKey: "id") as! Int
                
                var toUserDict = NSDictionary()
                
                if toUserID == userID {
                    toUserDict = jobProgressUserDict
                }
                else if progressUserID == userID {
                    toUserDict = jobUserDict
                }
                
                if dataDict.activityType == "review" {
                    
                    let cell = tableActivity.dequeueReusableCell(withIdentifier: "ActivityReviewCell") as! ActivityReviewCell
                    cell.selectionStyle = .none
                    
                    var url = userDict!["profile_pic"] as! String
                    url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                    
                    cell.btnProfilePic.sd_setImage(with: URL(string: url), for: .normal, completed: nil)
                    
                    let username = (userDict!["firstname"] as! String) + " " + (userDict!["lastname"] as! String)
                    
                    let attributes = [ NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 16.0)!]
                    let stringName = NSMutableAttributedString(string: username, attributes: attributes )
                    
                    let reviewText = " gave review to "
                    let reviewAttributes = [ NSAttributedString.Key.font: UIFont(name: "AvenirNext-Regular", size: 16.0)!, NSAttributedString.Key.foregroundColor: UIColor.gray ]
                    let stringComment = NSMutableAttributedString(string: String(format: "%@", reviewText), attributes: reviewAttributes )
                    
                    stringName.append(stringComment)
                    
                    let toUserName = (toUserDict.value(forKey: "firstname") as! String) + " " + (toUserDict.value(forKey: "lastname") as! String)
                    let toUserattributes = [ NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 16.0)!]
                    let toUserAttString = NSMutableAttributedString(string: String(format: "%@", toUserName), attributes: toUserattributes )
                    stringName.append(toUserAttString)
                    
                    let reviewText2 = " for : "
                    let reviewAttributes2 = [ NSAttributedString.Key.font: UIFont(name: "AvenirNext-Regular", size: 16.0)!, NSAttributedString.Key.foregroundColor: UIColor.gray ]
                    let stringComment2 = NSMutableAttributedString(string: String(format: "%@", reviewText2), attributes: reviewAttributes2 )
                    stringName.append(stringComment2)
                    
                    let jobName = (jobDict?.value(forKey: "title") as! String)
                    let jobAtt = [ NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 16.0)!]
                    let jobAttString = NSMutableAttributedString(string: String(format: "%@", jobName), attributes:jobAtt )
                    stringName.append(jobAttString)
                    
                    cell.lblReviewText.tag = index
                    cell.lblReviewText.attributedText = stringName
                    
                    cell.lblReviewText.isUserInteractionEnabled = true
                    cell.lblReviewText.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(nameLabelTapped(gesture:))))
                    
                    let pastDate = (jobDict!.value(forKey: "created_at") as! String)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    var date = dateFormatter.date(from: pastDate)
                    date = date?.toLocalTime()
                    cell.lblTime.text =  date?.timeAgoDisplay()
                    
                    cell.btnProfilePic.tag = index
                    cell.btnProfilePic.addTarget(self, action: #selector(goToUserProfile), for: .touchUpInside)
                    
                    
                    if (jobDict!.value(forKey: "file1") as! String) != "" {
                        var url = (jobDict!.value(forKey: "file1") as! String)
                        url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                        
                        cell.btnJobPic.sd_setImage(with: URL(string: url), for: .normal, completed: nil)
                    }
                    
                    cell.btnJobPic.tag = index
                    cell.btnJobPic.addTarget(self, action: #selector(goToJobProfile), for: .touchUpInside)
                    
                    return cell
                }
                else {
                    
                    let cell = tableActivity.dequeueReusableCell(withIdentifier: "ActivityCell") as! ActivityCell
                    cell.selectionStyle = .none
                    cell.delegate = self
                    
                    var url = userDict!["profile_pic"] as! String
                    url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                    
                    cell.btnProfilePic.sd_setImage(with: URL(string: url), for: .normal, completed: nil)
                    
                    cell.btnUserName.setTitle((userDict!["firstname"] as! String) + " " + (userDict!["lastname"] as! String) , for: .normal)
                    
                    cell.lblLocation.text = (jobDict!.value(forKey: "address") as! String)
                    
                    let title = (jobDict?.value(forKey: "title") as! String)
                    cell.lblPostTitle.text = title
                    
                    if title == "Werkules were there is no middle man in your way of profit." {
                        print(index)
                    }
                    
                    if (jobDict?.value(forKey: "is_activity") as! String) == "1" {
                        cell.viewRibbon.isHidden = true
                    }
                    else {
                        cell.viewRibbon.isHidden = false
                        
                        cell.btnRibbon.tag = index
                        cell.btnRibbon.addTarget(self, action: #selector(goToJobProfile(_:)), for: .touchUpInside)
                        
                        var text = (jobDict?.value(forKey: "estimate_budget") as! String)
                        text = text.replacingOccurrences(of: "$", with: "")
                        let myDouble = Double(text)
                        
                        cell.lblEstimatedPrize.text = "$" + self.formatPoints(num: myDouble!)
                    }
                    
                    cell.pageControl.isHidden = true
                    
                    let likes = ActivityModel.Shared.arrActivities[index].likesArrayNew
                    let likesCount = likes.count
                    if likesCount == 0 {
                        cell.btnLikeCounts.setTitle("", for: .normal)
                    }
                    else {
                        cell.btnLikeCounts.setTitle("\(likesCount)", for: .normal)
                    }
                    
                    cell.btnLike.isSelected = false
                    for item in likes {
                        let like = item
                        let userId = like.userId
                        if Int(UserSettings.userID) == userId {
                            cell.btnLike.isSelected = true
                        }
                    }
                    
                    cell.btnLikeCounts.tag = index
                    cell.btnLikeCounts.addTarget(self, action: #selector(showUserLikesList), for: .touchUpInside)
                    
                    let comments = ActivityModel.Shared.arrActivities[index].commentsArrayNew
                    let commentsCount = comments.count
                    if commentsCount == 0 {
                        cell.lblCommentsCount.text = ""
                    }
                    else {
                        cell.lblCommentsCount.text = "\(commentsCount)"
                    }
                    
                    let pastDate = (jobDict!.value(forKey: "created_at") as! String)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    var date = dateFormatter.date(from: pastDate)
                    date = date?.toLocalTime()
                    cell.lblTime.text =  date?.timeAgoDisplay()
                    
                    let imagesArray = NSMutableArray.init()
                    if (jobDict!.value(forKey: "file1") as! String) != "" {
                        imagesArray.add((jobDict!.value(forKey: "file1") as! String))
                    }
                    if (jobDict!.value(forKey: "file2") as! String) != "" {
                        imagesArray.add((jobDict!.value(forKey: "file2") as! String))
                    }
                    if (jobDict!.value(forKey: "file3") as! String) != "" {
                        imagesArray.add((jobDict!.value(forKey: "file3") as! String))
                    }
                    if (jobDict!.value(forKey: "file4") as! String) != "" {
                        imagesArray.add((jobDict!.value(forKey: "file4") as! String))
                    }
                    
                    if imagesArray.count > 1 {
                        cell.pageControl.isHidden = false
                        cell.pageControl.numberOfPages = imagesArray.count
                    }
                    
                    cell.jobPhotosArray = imagesArray
                    
                    cell.btnProfilePic.tag = index
                    cell.btnUserName.tag = index
                    cell.lblPostTitle.tag = index
                    cell.btnLike.tag = index
                    cell.btnComment.tag = index
                    cell.btnMore.tag = index
                    
                    cell.btnProfilePic.addTarget(self, action: #selector(goToUserProfile), for: .touchUpInside)
                    cell.btnUserName.addTarget(self, action: #selector(goToUserProfile), for: .touchUpInside)
                    cell.btnLike.addTarget(self, action: #selector(likePost), for: .touchUpInside)
                    cell.btnComment.addTarget(self, action: #selector(commentPost), for: .touchUpInside)
                    cell.btnMore.addTarget(self, action: #selector(btnMoreClicked), for: .touchUpInside)
                    
                    cell.imageCollectionView.reloadData()
                    
                    return cell
                }
        }
        
        
        
        return aCell*/
    }
    //MARK: - GroupCell Delegate
    func buttondetailselector(row: Int, section: Int) {
        let sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
        if let item:GroupCellInfo = sectionInfo.itemsInSection[row] as? GroupCellInfo{
            //pushto detail screen
            if let userID = item.userDetail["user_id"],"\(userID)".count > 0{
                self.pushtoViewGroupEarningDetailViewController(userid:"\(userID)")
            }
            
        }
    }
    func buttoncustomerdetailselector(row: Int, section: Int) {
        let sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
               if let item:GroupCellInfo = sectionInfo.itemsInSection[row] as? GroupCellInfo{
                    self.pushtocustomerdetailViewcontroller(dict: item.userDetail)
               }
    }
    func buttonproviderdetailselector(row: Int, section: Int) {
        let sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
               if let item:GroupCellInfo = sectionInfo.itemsInSection[row] as? GroupCellInfo{
                   if let providerid = item.userDetail["provider_id"],"\(providerid)".count > 0{
                       self.pushToProviderDetailScreenWithProviderId(providerID: "\(providerid)")
                   }else{
                       self.presentAlertForOnlyCustomer()
                   }
               }
    }
    func buttoncontactdetailselector(row: Int, section: Int) {
        let sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
               if let item:GroupCellInfo = sectionInfo.itemsInSection[row] as? GroupCellInfo{
                    self.pushtoChatViewControllerWith(dict: item.userDetail)
            
                   //
                
               }
    }
    func presentAlertForOnlyCustomer(){
        let alert = UIAlertController(title: AppName, message: "Help bring out the Entrepreneur in your friend! Werkules is the perfect platform to start a business.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            
        }))
        alert.view.tintColor = UIColor.init(hex: "#38B5A3")
        self.present(alert, animated: true, completion: nil)
    }
    func buttonDetailSelector(isShow: Bool, row: Int, section: Int) {
        var sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
        if var item:GroupCellInfo = sectionInfo.itemsInSection[row] as? GroupCellInfo{
            item.isOptionsDetailShown = !item.isOptionsDetailShown
            if item.isOptionsDetailShown{
                item.isExpanded = true
            }
            DispatchQueue.main.async {
                self.tableActivity.reloadRows(at: [IndexPath.init(row: row, section: section)], with: .none)
                //self.tableActivity.reloadSections( IndexSet(integer: section), with: .none)
            }
        }
    }
    func buttonExpandselector(isExpand: Bool, row: Int, section: Int) {
        var sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
               if var item:GroupCellInfo = sectionInfo.itemsInSection[row] as? GroupCellInfo{
                   //item.isExpanded = isExpand
                   item.isExpanded = !item.isExpanded
                        if !item.isExpanded{
                               item.isOptionsDetailShown = false
                           }
                   DispatchQueue.main.async {
                       self.tableActivity.reloadRows(at: [IndexPath.init(row: row, section: section)], with: .none)
                       //self.tableActivity.reloadSections( IndexSet(integer: section), with: .none)
                   }
               }
    }
    
    //MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latestLocation: AnyObject = locations[locations.count - 1]
        let mystartLocation = latestLocation as! CLLocation;
        
        self.currentLat = mystartLocation.coordinate.latitude
        self.currentLong = mystartLocation.coordinate.longitude
        
        UserRegister.Shared.lat = String(self.currentLat)
        UserRegister.Shared.long = String(self.currentLong)
        
        if isWebserviceCalled == false {
            callAPIToGetActivityList()
            locationManager.stopUpdatingLocation()
        }
    }
    
    private func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        self.callAPIToGetActivityList()
    }
    
    //MARK: - User Defined Methods
    
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
    
    @objc func goToChat() {
        
        let storyboard = UIStoryboard.init(name: "Messages", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        
        chatVC.toId = UserDefaults.standard.value(forKeyPath: "toId") as! String
        chatVC.jobId = UserDefaults.standard.value(forKeyPath: "jobId") as! String
        chatVC.fromId = UserSettings.userID
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
    
    @objc func goToUserProfile(_ sender:UIButton) {
        
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EntrepreneurProfileVC") as! EntrepreneurProfileVC
        vc.otherUserId = "\(ActivityModel.Shared.arrActivities[sender.tag].jobUserId!)"
        vc.dictEntrpreneur = ActivityModel.Shared.arrActivities[sender.tag].userDict!
        vc.isOtherUser = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goToJobProfile(_ sender:UIButton) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "JobProfileVC") as! JobProfileVC
        vc.dictJobDetails = ActivityModel.Shared.arrActivities[sender.tag].jobDict! //dataDict
        vc.userDict = ActivityModel.Shared.arrActivities[sender.tag].userDict!
        vc.isFromMessages = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func likePost(_ sender:UIButton) {
        
        self.tableActivity.isUserInteractionEnabled = false
        if UserSettings.isUserLogin == true {
            if sender.isSelected == true {
                sender.isSelected = false
                status = "dislike"
            }
            else {
                sender.isSelected = true
                status = "like"
            }
            selectedIndex = sender.tag
            
            self.callWebserviceToAddLike()
        }
        else {
            let alert = UIAlertController(title: AppName, message: "Please login to like post.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func commentPost(_ sender:UIButton) {
        
        if UserSettings.isUserLogin == true {
            selectedIndex = sender.tag
            self.performSegue(withIdentifier: "commentSegue", sender: self)
        }
        else {
            let alert = UIAlertController(title: AppName, message: "Please login to comment on post.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func btnMoreClicked(_ sender:UIButton) {
        
        if UserSettings.isUserLogin == true {
            
            selectedIndex = sender.tag
            
            let dataDict = ActivityModel.Shared.arrActivities[self.selectedIndex]
            let userDict = dataDict.userDict!
            let jobDict = dataDict.jobDict!
            let userId = userDict["id"] as! Int
            let userIDString = "\(userId)"
            print(dataDict)
            
            if userIDString == UserSettings.userID {
                
                let actionSheet: UIAlertController = UIAlertController(title: AppName, message: "", preferredStyle: .actionSheet)
                
                let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    print("Cancel")
                }
                actionSheet.addAction(cancelActionButton)
                
                let editActionButton = UIAlertAction(title: "Edit", style: .default)
                { _ in
                    
//                    if jobDict["is_activity"] as! String == "1" {
//
//                        let storyboard = UIStoryboard.init(name: "Activity", bundle: nil)
//                        let vc = storyboard.instantiateViewController(withIdentifier: "PostActivityVC") as! PostActivityVC
//                        vc.isJobEditing = true
//                        vc.isFromActivity = true
//                        vc.dictJobModel = jobDict
//                        vc.modalPresentationStyle = .fullScreen
//                        self.present(vc, animated: true, completion: nil)
//                    }
//                    else {
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "PostJobVC") as! PostJobVC
                        vc.isJobEditing = true
                        vc.isFromProfile = false
                        vc.isFromActivity = true
                        vc.dictJobModel = dataDict.jobDict!
                    if jobDict["is_activity"] as! String == "1" {
                        vc.isactivity = true
                    }
                    else {
                        vc.isactivity = false
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
//                    }
                }
                actionSheet.addAction(editActionButton)
                
                let deleteActionButton = UIAlertAction(title: "Delete", style: .default)
                { _ in
                    
                    let alert = UIAlertController(title: AppName, message: "Are you sure you want to delete this job?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
                        let jobID = ActivityModel.Shared.arrActivities[self.selectedIndex].jobId!
                        
                        let dict = [
                            APIManager.Parameter.jobID : String(jobID)
                        ]
                        
                        APIManager.sharedInstance.CallAPIPost(url: Url_deleteJob, parameter: dict, complition: { (error, JSONDICTIONARY) in
                            
                            let isError = JSONDICTIONARY!["isError"] as! Bool
                            
                            if  isError == false{
                                print(JSONDICTIONARY as Any)
                                
                                ActivityModel.Shared.arrActivities.remove(at: self.selectedIndex)
                                self.tableActivity.reloadData()
                            }
                            else{
                                let message = JSONDICTIONARY!["response"] as! String
                                
                                SAAlertBar.show(.error, message:message.capitalized)
                            }
                        })
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                actionSheet.addAction(deleteActionButton)
                self.present(actionSheet, animated: true, completion: nil)
            }
            else {
                
                let actionSheet: UIAlertController = UIAlertController(title: AppName, message: "", preferredStyle: .actionSheet)
                
                let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    print("Cancel")
                }
                actionSheet.addAction(cancelActionButton)
                
                let reportActionButton = UIAlertAction(title: "Report this post", style: .default)
                { _ in
                    self.callAPIToReportJob()
                }
                actionSheet.addAction(reportActionButton)
                self.present(actionSheet, animated: true, completion: nil)
                
            }
            
        }
            
        else {
            let alert = UIAlertController(title: AppName, message: "Please login to continue.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didPressButton(button:UIButton) {
        
        let cell = button.superview?.superview as! ActivityImageCell
        
        let imgViewJob = cell.btnJobPic.imageView
        let configuration = ImageViewerConfiguration { config in
            config.imageView = imgViewJob
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        
        present(imageViewerController, animated: true)
    }
    
    func showFullVideo(url: String) {
        
        let videoURL = URL(string: url)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    @objc func refresh() {
        
        self.callAPIToGetActivityList()
        refreshControl.endRefreshing()
    }
    
    @objc func showUserLikesList(_ sender : UIButton) {
        
        self.selectedIndex = sender.tag
        self.performSegue(withIdentifier: "UserLikesSegue", sender: self)
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
    
    @objc func nameLabelTapped(gesture: UITapGestureRecognizer) {
        
        let tappedLabel = gesture.view as! UILabel
        
        var jobProgressUserDict = NSDictionary()
        var progressUserID = Int()
        let dataDict = ActivityModel.Shared.arrActivities[tappedLabel.tag]
        let jobDict = ActivityModel.Shared.arrActivities[tappedLabel.tag].jobDict
        let jobUserDict = jobDict?.value(forKey: "user") as! NSDictionary
        if jobDict?.value(forKey: "user_progress_by") is String == false {
            jobProgressUserDict = jobDict?.value(forKey: "user_progress_by") as! NSDictionary
            progressUserID = jobProgressUserDict.value(forKey: "id") as! Int
        }
        let userDict = ActivityModel.Shared.arrActivities[tappedLabel.tag].userDict
        
        let userID = userDict?.value(forKey: "id") as! Int
        let toUserID = jobUserDict.value(forKey: "id") as! Int
        
        var toUserDict = NSDictionary()
        
        if toUserID == userID {
            toUserDict = jobProgressUserDict
        }
        else if progressUserID == userID {
            toUserDict = jobUserDict
        }
        
        let username = (userDict!["firstname"] as! String) + " " + (userDict!["lastname"] as! String)
        let reviewText1 = " gave review to "
        let otherUserName = (toUserDict.value(forKey: "firstname") as! String) + " " + (toUserDict.value(forKey: "lastname") as! String)
        let reviewText2 = " for : "
        let jobName = (jobDict?.value(forKey: "title") as! String)
        
        let reviewString = String(format: "%@%@%@%@%@", username,reviewText1,otherUserName,reviewText2,jobName)
        
        let userNameRange = NSString(string: reviewString).range(of: username, options: String.CompareOptions.caseInsensitive)
        
        let otherUserNameRange = NSString(string: reviewString).range(of: otherUserName, options: String.CompareOptions.caseInsensitive)
        
        let jobNameRange = NSString(string: reviewString).range(of: jobName, options: String.CompareOptions.caseInsensitive)
        
        if gesture.didTapAttributedTextInLabel(label: tappedLabel, inRange: userNameRange) {
            
            let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "EntrepreneurProfileVC") as! EntrepreneurProfileVC
            vc.isOtherUser = true
            vc.dictEntrpreneur = userDict!
            vc.otherUserId = String(userDict!["id"] as! Int)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if gesture.didTapAttributedTextInLabel(label: tappedLabel, inRange: otherUserNameRange) {
            
            let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "EntrepreneurProfileVC") as! EntrepreneurProfileVC
            vc.isOtherUser = true
            vc.dictEntrpreneur = toUserDict
            vc.otherUserId = String(toUserDict["id"] as! Int)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if gesture.didTapAttributedTextInLabel(label: tappedLabel, inRange: jobNameRange) {
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "JobProfileVC") as! JobProfileVC
            vc.dictJobDetails = jobDict!
            vc.userDict = jobUserDict
            vc.isFromMessages = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func scrollToTop()  {
        
        if tableActivity != nil{
            tableActivity.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
        }
    }
    
    //MARK: - Action
    
    @IBAction func btnshareSomethingClicked(_ sender: UIButton) {
        
        if UserSettings.isUserLogin == true {
            
            self.performSegue(withIdentifier: "ShareSomethingSegue", sender: self)
        }
        else {
            SAAlertBar.show(.info, message: "Please login to continue")
        }
    }
    
    @IBAction func menuBtnClicked(_ sender: UIButton) {
        
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    //MARK: - API
    
    func callAPIToReportJob() {
        
        let userID = UserSettings.userID//String()
        let status = "1"
        let jobId = ActivityModel.Shared.arrActivities[self.selectedIndex].jobId!
        var jobIdString = String()
        
        jobIdString = "\(jobId)"
        
        let dict = [
            APIManager.Parameter.userID : userID,
            APIManager.Parameter.jobID : jobIdString,
            APIManager.Parameter.status : status
        ]
        
        APIManager.sharedInstance.CallAPIPost(url: Url_reportJob, parameter: dict, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                let alert: UIAlertController = UIAlertController(title: AppName, message: "Thank you for your report. We will take necessary action within 24 hours", preferredStyle: .alert)
                
                let OkActionButton = UIAlertAction(title: "Ok", style: .cancel) { _ in
                    print("Cancel")
                }
                alert.addAction(OkActionButton)
                
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                if message == "Report job already exists!" {
                    
                    let alert: UIAlertController = UIAlertController(title: AppName, message: "You have already reported this post.", preferredStyle: .alert)
                    
                    let OkActionButton = UIAlertAction(title: "Ok", style: .cancel) { _ in
                        print("Cancel")
                    }
                    alert.addAction(OkActionButton)
                    
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    SAAlertBar.show(.error, message:message.capitalized)
                }
            }
        })
    }
    
    func callAPIToGetActivityList() {
        
        let dict = [
            APIManager.Parameter.latitude : String(self.currentLat),//"41.1115487",//String(self.currentLat),
            APIManager.Parameter.longitude : String(self.currentLong),//"-78.725749",//String(self.currentLong),
            APIManager.Parameter.radius : "500000000000",
            APIManager.Parameter.limit : "50",
            APIManager.Parameter.page : "1"
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_ActivityList, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                self.isWebserviceCalled = true
                
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                if (dataDict["data"] as! NSArray).count != 0 {
                    
                    let activities = dataDict["data"] as! NSArray
                    
                    var activityModel = [ActivityModel]()
                    
                    if ActivityModel.Shared.arrActivities.count > 0 {
                        ActivityModel.Shared.arrActivities.removeAll()
                    }
                    
                    for activity in activities {
                        
                        let myDict = activity as! JSONDICTIONARY
                        if myDict["job"] is NSDictionary {
                            let DataObject = ActivityModel()
                            DataObject.JsonParseFromDict(activity as! JSONDICTIONARY)
                            activityModel.append(DataObject)
                            ActivityModel.Shared.arrActivities.append(DataObject)
                        }
                    }
                    
                    self.tableActivity.reloadData()
                    self.tableActivity.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
                else {
                    self.tableActivity.isHidden = true
                    self.lblNoRecord.isHidden = false
                }
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        }
    }
    
    func callWebserviceToAddLike() {
        
        let userId = UserSettings.userID
        
        let actID = ActivityModel.Shared.arrActivities[selectedIndex].activityId!  //activityDict.value(forKey: "id") as! Int
        
        let dict = [
            APIManager.Parameter.activityId : "\(actID)",
            APIManager.Parameter.userID : userId,
            APIManager.Parameter.status : self.status
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_SaveUpdateLike, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                let like = dataDict["data"] as! NSDictionary
                
                let likes = ActivityModel.Shared.arrActivities[self.selectedIndex].likesArrayNew
                let indexPath = IndexPath.init(row: self.selectedIndex, section: 0)
//                let cell = self.tableActivity.cellForRow(at: indexPath) as! ActivityCell
                
                var likesCount = likes.count
                
                if self.status == "like" {
                    likesCount += 1
                    
                    let DataObject = LikeModel()
                    DataObject.JsonParseFromDict(like as! JSONDICTIONARY)
                    ActivityModel.Shared.arrActivities[self.selectedIndex].likesArrayNew.append(DataObject)
                    
                    Analytics.logEvent(NSLocalizedString("like_added", comment: ""), parameters: [NSLocalizedString("post_name", comment: ""): (ActivityModel.Shared.arrActivities[self.selectedIndex].jobDict!).value(forKey: "title")!])
                }
                else {
                    likesCount -= 1
                    
                    for (index,item) in likes.enumerated() {
                        let like = item
                        let userId = like.userId
                        if Int(UserSettings.userID) == userId {
                            ActivityModel.Shared.arrActivities[self.selectedIndex].likesArrayNew.remove(at: index)
                        }
                    }
                }
                
//                if likesCount == 0 {
//                    cell.btnLikeCounts.setTitle("", for: .normal)
//                }
//                else {
//                    cell.btnLikeCounts.setTitle("\(likesCount)", for: .normal)
//                }
                
                self.tableActivity.reloadRows(at: [indexPath], with: .automatic)
                self.tableActivity.isUserInteractionEnabled = true
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "commentSegue" {
            
            let vc = segue.destination as! CommentsVC
            vc.index = selectedIndex
            vc.activityID = String(ActivityModel.Shared.arrActivities[self.selectedIndex].activityId!)
            vc.arrComments = NSMutableArray.init(array: ActivityModel.Shared.arrActivities[self.selectedIndex].commentsArrayNew as NSArray)
            vc.isForActivity = true
        }
        else if segue.identifier == "UserLikesSegue" {
            
            let vc = segue.destination as! UserLikesVC
            vc.arrUsers = ActivityModel.Shared.arrActivities[self.selectedIndex].likesArrayNew as NSArray
        }
    }
    //Push to wallet
    func pushToWalletViewController(){
        if let walletViewController = UIStoryboard.activity.instantiateViewController(withIdentifier: "WalletViewController") as? WalletViewController{
            walletViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(walletViewController, animated: true)
        }
    }
    func pushtocustomerdetailViewcontroller(dict:[String:Any]){
             
                let profilestoryboard  = UIStoryboard.init(name: "Profile", bundle: nil)
                if let profileViewcontroller = profilestoryboard.instantiateViewController(withIdentifier: "CustomerProfileAsProviderVC") as? CustomerProfileAsProviderVC{
               
                    if let user_id = dict["user_id"]{
                        profileViewcontroller.userId = "\(user_id)"
                    }
                    if let profile_pic = dict["profile_pic"]{
                        profileViewcontroller.userProfile = "\(profile_pic)"
                    }
                    if let firstname = dict["firstname"],let lastname = dict["lastname"]{
                        profileViewcontroller.userName = "\(firstname) \(lastname)"
                    }
                    profileViewcontroller.isFromMyGroupScreen = true
                    profileViewcontroller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(profileViewcontroller, animated: true)
                }
    }
    func pushToProviderDetailScreenWithProviderId(providerID:String){
          let objStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
          if let objProviderDetail = objStoryboard.instantiateViewController(withIdentifier: "ProviderDetailViewController") as? ProviderDetailViewController{
              objProviderDetail.hidesBottomBarWhenPushed = true
              objProviderDetail.providerID = providerID
            objProviderDetail.showBookNowButton = true 
              self.navigationController?.pushViewController(objProviderDetail, animated: true)
          }
      }
    func pushtoChatViewControllerWith(dict:[String:Any]){
        if let chatViewConroller = UIStoryboard.messages.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC{
            chatViewConroller.hidesBottomBarWhenPushed = true
            if let user_id = dict["user_id"]{
                 chatViewConroller.receiverID = "\(user_id)"
             }
             if let profile_pic = dict["profile_pic"]{
                 chatViewConroller.strReceiverProfileURL = "\(profile_pic)"
             }
             if let firstname = dict["firstname"],let lastname = dict["lastname"]{
                 chatViewConroller.strReceiverName = "\(firstname) \(lastname)"
             }
            if let senderid = dict["quickblox_id"]{
                chatViewConroller.senderID = "\(senderid)"
            }
            chatViewConroller.toUserTypeStr = "customer"
            chatViewConroller.isForCustomerToProvider = false
            chatViewConroller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatViewConroller, animated: true)
        }
    }
    func pushtoViewGroupEarningDetailViewController(userid:String){
        if let viewgroupDetailViewcontroller  = UIStoryboard.activity.instantiateViewController(withIdentifier: "ViewGroupEarningDetailViewController") as? ViewGroupEarningDetailViewController{
            viewgroupDetailViewcontroller.hidesBottomBarWhenPushed = true
            viewgroupDetailViewcontroller.userID = userid
            self.navigationController?.pushViewController(viewgroupDetailViewcontroller, animated: true)
        }
    }
    
}

extension UIButton {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension Date {
    var dateInMiliSeconds:String{
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd H:mm:ss.SSSS"
        return df.string(from: self) ?? "\(Date())"
    }
    func timeAgoDisplay() -> String {
        
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return "1 min ago"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff) mins ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff) hrs ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff) days ago"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff) weeks ago"
    }
    
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}
extension ActivityVC:AddBankAccountWithdrawalDelegate{
    func pushToWithDrawalScreenDelegate() {
           self.pushtoWithdrawEarningScreenViewController()
       }
}
