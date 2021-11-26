//
//  WalletViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 01/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class WalletViewController: UIViewController {

    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var backButtton:UIButton!
    
    @IBOutlet weak var imageGroup:UIImageView!
    @IBOutlet weak var lblGroupEarning:UILabel!
    @IBOutlet weak var viewShadow:ShadowBackgroundView!
    @IBOutlet weak var viewMyGroup:UIView!
    
    @IBOutlet fileprivate weak var imageBusinessEarning:UIImageView!
    @IBOutlet fileprivate weak var lblBusinessEarning:UILabel!
    @IBOutlet fileprivate weak var viewBusinessEarningShadow:ShadowBackgroundView!
    @IBOutlet fileprivate weak var viewMyBusinessEarning:UIView!
    //Main container for business earning hide for customer
    @IBOutlet fileprivate weak var mainContainerviewMyBusinessEarning:UIView!
    @IBOutlet fileprivate weak var mainContainerviewPaymentMethod:UIView!
    
    
    
    @IBOutlet weak var imagePaymentMethod:UIImageView!
    @IBOutlet weak var lblPaymentMethod:UILabel!
    @IBOutlet weak var viewPaymentMethodShadow:ShadowBackgroundView!
    @IBOutlet weak var viewaymentMethod:UIView!
    
    @IBOutlet weak var imagePaymentHistory:UIImageView!
    @IBOutlet weak var lblPaymentHistory:UILabel!
    
    @IBOutlet weak var viewPaymentHistoryShadow:ShadowBackgroundView!
    @IBOutlet weak var viewPaymentHistory:UIView!
    
    @IBOutlet weak var viewWithdrawPaymentShadow:ShadowBackgroundView!
    @IBOutlet weak var viewWithdrawPaymentMethod:UIView!
    
    var bankAccountStatus:[String:Any] = [:]
    
    var arrayOfBank:[[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //hide business earning for customer
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
          return
        }
        if currentUser.userRoleType == .provider{
        self.mainContainerviewMyBusinessEarning.isHidden = false
        self.mainContainerviewPaymentMethod.isHidden = true
        }else if currentUser.userRoleType == .customer{
        self.mainContainerviewMyBusinessEarning.isHidden = true
        self.mainContainerviewPaymentMethod.isHidden = false
        }
        
        self.setup()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.getBankAccontStatusAPIRequest()
        self.getBankAccountdetailrequestAPI()
    }
    func getBankAccountdetailrequestAPI(){
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGETBankAccountList , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [[String:Any]]{
                                  DispatchQueue.main.async {
                                    self.arrayOfBank = arrayOfJOB
                                    
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
    func getBankAccontStatusAPIRequest(){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .GET, queryString:kGETPaymentReceiptAccountStatus, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["success_data"] as? [String:Any]{
                    DispatchQueue.main.async {
                            self.bankAccountStatus = successData
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
                          //   SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                         }
                     }
                 }
    }
    func setup(){
        self.viewShadow.rounding = 15.0
        self.viewShadow.layer.cornerRadius = 15.0
        self.viewShadow.layoutIfNeeded()
        self.viewMyGroup.layer.cornerRadius = 15.0
        self.viewMyGroup.clipsToBounds = true
        
        self.viewBusinessEarningShadow.rounding = 15.0
        self.viewBusinessEarningShadow.layer.cornerRadius = 15.0
        self.viewBusinessEarningShadow.layoutIfNeeded()
        self.viewMyBusinessEarning.layer.cornerRadius = 15.0
        self.viewMyBusinessEarning.clipsToBounds = true
        
        
        self.viewPaymentMethodShadow.rounding = 15.0
        self.viewPaymentMethodShadow.layer.cornerRadius = 15.0
        self.viewPaymentMethodShadow.layoutIfNeeded()
        
        self.viewaymentMethod.layer.cornerRadius = 15.0
        self.viewaymentMethod.clipsToBounds = true


        self.viewPaymentHistoryShadow.rounding = 15.0
        self.viewPaymentHistoryShadow.layer.cornerRadius = 15.0
        self.viewPaymentHistoryShadow.layoutIfNeeded()
        self.viewPaymentHistory.layer.cornerRadius = 15.0
        self.viewPaymentHistory.clipsToBounds = true
        
        self.viewWithdrawPaymentShadow.rounding = 15.0
        self.viewWithdrawPaymentShadow.layer.cornerRadius = 15.0
        self.viewWithdrawPaymentShadow.layoutIfNeeded()
        self.viewWithdrawPaymentMethod.layer.cornerRadius = 15.0
        self.viewWithdrawPaymentMethod.clipsToBounds = true
        
        
        if let _ = self.imageGroup{
            self.imageGroup.image = self.imageGroup.image?.withRenderingMode(.alwaysTemplate)
            self.imageGroup.tintColor = UIColor.init(hex: "38B5A3")
        }
        if let _ = self.imageBusinessEarning{
            self.imageBusinessEarning.image = self.imageBusinessEarning.image?.withRenderingMode(.alwaysTemplate)
            self.imageBusinessEarning.tintColor = UIColor.init(hex: "38B5A3")
        }
        if let _ = self.imagePaymentMethod{
                   self.imagePaymentMethod.image = self.imagePaymentMethod.image?.withRenderingMode(.alwaysTemplate)
                   self.imagePaymentMethod.tintColor = UIColor.init(hex: "38B5A3")
               }
        if let _ = self.imagePaymentHistory{
                   self.imagePaymentHistory.image = self.imagePaymentHistory.image?.withRenderingMode(.alwaysTemplate)
                   self.imagePaymentHistory.tintColor = UIColor.init(hex: "38B5A3")
               }

        
    }

    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonMygroupSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.pushtoviewgroupviewcontroller()
        }
    }
    @IBAction func buttonMyBusinessearningSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.pushtoMyBusinessEarningViewController()
        }
    }
    @IBAction func buttonPaymentMethodSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.pushToPaymentMethodViewController()
        }
    }
    @IBAction func buttonPaymentHistorySelector(sender:UIButton){
        DispatchQueue.main.async {
            self.pushtoPaymentHistoryViewController()
        }
    }
    @IBAction func buttonWithDrawalMethodSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.pushToWithDrawalMethodViewController()
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    //Withdrawal Methods
    func pushToWithDrawalMethodViewController(){
        if self.arrayOfBank.count > 0{
            self.pushToBankListViewController()
        }else{
            if let viewAddBankdetailViewController  = UIStoryboard.activity.instantiateViewController(withIdentifier: "AddBankdetailViewController") as? AddBankdetailViewController{
                viewAddBankdetailViewController.hidesBottomBarWhenPushed = true
                self.view.endEditing(true)
                if let url = self.bankAccountStatus["web_hook_url"]{
                    viewAddBankdetailViewController.strwebURL = "\(url)"
                }
                self.navigationController?.pushViewController(viewAddBankdetailViewController, animated: true)
            }
        }
      
    }
    func pushToBankListViewController(){
        DispatchQueue.main.async {
            if let bankListViewCoontroller = UIStoryboard.activity.instantiateViewController(withIdentifier: "BankListViewController") as? BankListViewController{
                self.view.endEditing(true)
                bankListViewCoontroller.isWithdrawalMethod = true
                self.navigationController?.pushViewController(bankListViewCoontroller, animated: true)
            }
        }
    }
    //MyBusinessEarningViewController
    func pushtoMyBusinessEarningViewController(){
           //
           if let viewMyBusinessEarningViewController  = UIStoryboard.activity.instantiateViewController(withIdentifier: "MyBusinessEarningViewController") as? MyBusinessEarningViewController{
               self.navigationController?.pushViewController(viewMyBusinessEarningViewController, animated: true)
           }
       }
    func pushtoviewgroupviewcontroller(){
        //
        if let viewGroupEarningViewController  = UIStoryboard.activity.instantiateViewController(withIdentifier: "ViewGroupEarningViewController") as? ViewGroupEarningViewController{
            self.navigationController?.pushViewController(viewGroupEarningViewController, animated: true)
        }
    }
    func pushToPaymentMethodViewController(){
        if let paymentMethodViewController  = UIStoryboard.activity.instantiateViewController(withIdentifier: "PaymentMethodViewController") as? PaymentMethodViewController{
            self.navigationController?.pushViewController(paymentMethodViewController, animated: true)
        }
    }
    func pushtoPaymentHistoryViewController(){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
            return
        }
        
         if currentUser.userRoleType == .provider{
            
                  if let paymentHistory = UIStoryboard.activity.instantiateViewController(withIdentifier: "ProviderPaymentHistoryViewController") as? ProviderPaymentHistoryViewController{
                      paymentHistory.isForJOBSpecific = false
                      self.navigationController?.pushViewController(paymentHistory, animated: true)
                  }
         }else if currentUser.userRoleType == .customer{
            
                  if let paymentHistory = UIStoryboard.activity.instantiateViewController(withIdentifier: "CustommerPaymentHistoryViewController") as? CustommerPaymentHistoryViewController{
                      paymentHistory.isForJOBSpecific = false
                      self.navigationController?.pushViewController(paymentHistory, animated: true)
                  }
         }
      
    }
    

}
