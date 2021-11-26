//
//  ViewGroupEarningViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 09/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import FirebaseDynamicLinks
import Firebase

class ViewGroupEarningViewController: UIViewController {

   
    @IBOutlet weak var tableActivity: UITableView!

    let SectionHeaderViewIdentifier = "SectionHeaderViewIdentifier"
      
    var sectionInfoArray: NSMutableArray = []
    
    
    @IBOutlet weak var lblTotalTransaction:UILabel!
    @IBOutlet weak var lblTotalEarning:UILabel!
    @IBOutlet weak var containerViewforlevel:UIView!
    @IBOutlet weak var containerShare:UIView!
    
    var arrayOfLevelOne:NSMutableArray = []
    var arrayOfLevelSecond:NSMutableArray = []
    
    @IBOutlet weak var lblNoGroupData:UILabel!
    
    @IBOutlet weak var buttonWithdrawAmount:UIButton!
    
    @IBOutlet weak var moreview:UIView!
    
    var strShareText = "Refer Werkules to your friends and business contacts to build your group and start earning referral fees"

    var bankAccountStatus:[String:Any] = [:]
    
    var groupEarningHelpStr:String = ""
    var referralCodeHelpStr:String = ""
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //configure tableview
        self.configureTableView()
        self.moreview.layer.borderColor = UIColor.lightGray.cgColor
        self.moreview.layer.borderWidth = 0.5
        self.moreview.layer.cornerRadius = 6.0
        self.moreview.clipsToBounds = true
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
        self.getMyGroupListAPIRequestMethods()
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
        func configureTableView(){
            let sectionHeaderNib: UINib = UINib(nibName: "SectionHeaderView", bundle: nil)
            self.tableActivity.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: SectionHeaderViewIdentifier)

            
            //GroupTableViewCell
//            self.tableActivity.register(UINib(nibName: "GroupTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupTableViewCell")
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
        
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                                                     return
                                             }
                     let count = arrayLevelOne.count+arrayLevelTwo.count
                      var strGroupMembers = "Group Members: Affiliate Earnings (\(count))"
                      /*if currentUser.referalCode.count > 0 {
                          strGroupMembers = "Group Members (Ref Code:\(currentUser.referalCode))"
                        }*/
        
        // You should set up your SectionInfo here
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
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
           self.navigationController?.popViewController(animated: true)
      }
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                                  return
                          }
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
    @IBAction func buttonAddToNetworkSelector(sender:UIButton){
           DispatchQueue.main.async {
            self.showAddToYourGroupAlert()
            //self.shareApplicatioReferrelCodeSelector()
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
                print(strtext)
                   let items = [strtext] as [Any]
                  let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                  activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                  
                  // present the view controller
                  self.present(activityViewController, animated: true, completion: nil)
        }}
    //MARK: - API Request Methods
    func getMyGroupListAPIRequestMethods(){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCustomerProviderGroupList , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                  if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                    //111 NewUI
                    DispatchQueue.main.async {
                        if let total_transactions = userInfo["total_transactions"],!(total_transactions is NSNull){
                            if let pi: Double = Double("\(total_transactions)"){
                            let updateValue = String(format:"%.2f", pi)
                                self.lblTotalTransactionUpdate.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0.00)
                            self.lblTotalTransaction.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0.00 )//"$\(updateValue)"
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
                                 let updateValue = String(format:"%.2f", pi)
                                self.lblTotalEarningUpdate.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0.00)
                                self.lblTotalEarning.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0.00 )//"$\(updateValue)"
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
        }}
    // MARK: - Selector Methods
    //111 NewUI
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
                //UIAlertController.showOkAlert(self, aStrMessage: "A transaction fee of $1 will be deducted from your withdrawal total. Earned funds in your wallet will display as a payment method option and can be used without fees", completion: nil)
                
               
               
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
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
            self.navigationController?.pushViewController(withdrawearningscreen, animated: true)
        }
    }
  }
}
extension ViewGroupEarningViewController:AddBankAccountWithdrawalDelegate{
    func pushToWithDrawalScreenDelegate() {
           self.pushtoWithdrawEarningScreenViewController()
       }
}
extension ViewGroupEarningViewController:UITableViewDataSource,UITableViewDelegate,SectionHeaderViewDelegate,GroupCellDelegate{
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
          
       }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//          let cell = tableActivity.dequeueReusableCell(withIdentifier: "GroupTableViewCell") as! GroupTableViewCell
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
                 let updateValue = String(format:"%.2f", pi)
                  cell.lblTotalTransaction.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                }
              }
              if let available_earning = item.userDetail["available_earning"]{
                if let pi: Double = Double("\(available_earning)"){
                 let updateValue = String(format:"%.2f", pi)
                  cell.lblAvailableEarning.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                }
              }
              if let transactions_earning = item.userDetail["transactions_earning"]{
                if let pi: Double = Double("\(transactions_earning)"){
                  let updateValue = String(format:"%.2f", pi)
                  cell.lblTransactionEarning.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                }
              }
              if let promotion_earning = item.userDetail["promotion_earning"]{
                if let pi: Double = Double("\(promotion_earning)"){
                        let updateValue = String(format:"%.2f", pi)
                  cell.lblPromotionEarning.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                }
              }
              if let hold_earning = item.userDetail["hold_earning"]{
                if let pi: Double = Double("\(hold_earning)"){
                    let updateValue = String(format:"%.2f", pi)
                  cell.lblHoldAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                }
              }
              
              //total_transactions
              //available_earning
              //transactions_earning
              //promotion_earning
              //hold_earning
              
          }
         return cell
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
    //MARK: - GroupCell Delegate
    func buttondetailselector(row: Int, section: Int) {
        let sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
        if let item:GroupCellInfo = sectionInfo.itemsInSection[row] as? GroupCellInfo{
            //pushto detail screen
            //pushto detail screen
            if let userID = item.userDetail["user_id"],"\(userID)".count > 0{
                self.pushtoViewGroupEarningDetailViewController(userid:"\(userID)")
            }
        }
    }
    func pushtoViewGroupEarningDetailViewController(userid:String){
          if let viewgroupDetailViewcontroller  = UIStoryboard.activity.instantiateViewController(withIdentifier: "ViewGroupEarningDetailViewController") as? ViewGroupEarningDetailViewController{
              viewgroupDetailViewcontroller.hidesBottomBarWhenPushed = true
              viewgroupDetailViewcontroller.userID = userid
              self.navigationController?.pushViewController(viewgroupDetailViewcontroller, animated: true)
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
}
