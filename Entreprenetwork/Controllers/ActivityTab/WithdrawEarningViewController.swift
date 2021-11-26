//
//  WithdrawEarningViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 07/04/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class WithdrawEarningViewController: UIViewController {

    
    @IBOutlet fileprivate weak var lblTitle:UILabel!
    @IBOutlet fileprivate weak var buttonBack:UIButton!
    
    @IBOutlet fileprivate weak var lblTotalGroupEarningAvailable:UILabel!
    @IBOutlet fileprivate weak var lblTotalGroupEarningAmount:UILabel!
    
    @IBOutlet fileprivate weak var buttonWithdrawHistory:UIButton!
    
    @IBOutlet fileprivate weak var txtAmount:UITextField!
    
    @IBOutlet fileprivate weak var buttonHelp:UIButton!
    @IBOutlet fileprivate weak var buttonSubmit:UIButton!
    
    @IBOutlet fileprivate weak var lblBankAccount:UILabel!
    @IBOutlet fileprivate weak var lblBankName:UILabel!
    
    var isEnable:Bool = false
    var isSubmitEnable:Bool{
        get{
            return isEnable
        }
        set{
            self.isEnable = newValue
            //configure Submit button
            self.configureSubmitButton()
        }
    }
    var withdrawpayment:[String:Any] = [:]
    
    var bankAccountStatus:[String:Any] = [:]
    
    
    var isForBusinessEarningWithdraw:Bool = false
    var earningAvailable:String = ""
    var earningHelpStr:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //fetch business earning detail
        self.getBankAccontStatusAPIRequest()
        
        //fetch List of Bank detail
        self.getBankAccountdetailrequestAPI()
    }
    // MARK: - Custom Methods
    func setup(){
        self.isSubmitEnable = false
        self.txtAmount.delegate = self
        self.txtAmount.placeholder = "minimum $20"
        let underlineSeeDetail = NSAttributedString(string: "Withdrawal History",
                                                                        attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.buttonWithdrawHistory.titleLabel?.attributedText = underlineSeeDetail
        if self.earningAvailable.count >  0{
            print(self.earningAvailable)
            self.lblTotalGroupEarningAmount.text = "\(self.earningAvailable)"
        }else{
            self.lblTotalGroupEarningAmount.text = "$0"
        }
        //self.txtAmount.setPlaceHolderColor()
    }
    func configureSubmitButton(){
        DispatchQueue.main.async {
            self.buttonSubmit.isEnabled = self.isSubmitEnable
            if self.isSubmitEnable{
                self.buttonSubmit.setBackgroundImage(UIImage.init(named: "background_update"), for: .normal)
            }else{
                self.buttonSubmit.setBackgroundImage(nil, for: .normal)
            }
        }
    }
    func showMinimumAmountAlert(){
        DispatchQueue.main.async {
                UIAlertController.showOkAlert(self, aStrMessage: "A minimum of $20 is required to make a withdrawal", completion: nil)
               }
    }
    func isValidData()->Bool{
        guard let offerPrice = self.txtAmount.text?.trimmingCharacters(in: .whitespacesAndNewlines),offerPrice.count > 0 else{
                        SAAlertBar.show(.error, message:"Please enter Withdrawal Amount".localizedLowercase)
                        return false
                    }
       
        
        let dollarTotal = "\(offerPrice)".replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let pi: Double = Double("\(dollarTotal)"){
            print("\(pi) ===== ")
            guard pi >= minWithDrawAmount else{
                SAAlertBar.show(.error, message:"A minimum of $20 is required to make a withdrawal".localizedLowercase)
                return false
            }
        }
        
        let myFloat = ("\(dollarTotal)" as NSString).floatValue
        if let amount = Int.init(myFloat) as? Int{
            if amount >= 10{
                self.withdrawpayment["amount"] = "\(dollarTotal)"
                return true
            }else{
                self.showMinimumAmountAlert()
                //SAAlertBar.show(.error, message:"Please enter Withdrawal Amoun".localizedLowercase)
                return false
            }
        }
        return true
    }
    // MARK: - API Request Methods
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
                            // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                         }
                     }
                 }
    }
    // MARK: - Selector Methods
    @IBAction func addBankAccountDetailSelector(sender:UIButton){
        if let accountCreated = self.bankAccountStatus["is_account_created"],let accuntVerify = self.bankAccountStatus["is_account_verify"]{
          if let created = "\(accountCreated)".bool{
              if let verify = "\(accuntVerify)".bool{
                  if created && verify{
                    //Push to bank list
                    self.pushToBankListViewController()
                    
                  }else{
                    self.pushToAddBackDetailWebView()
                }
              }
          }
        }
    }
    
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonWithdrawHistorySelector(sender:UIButton){
        self.pushtoWithdrawEarningHistoryScreenDetail()
    }
    @IBAction func buttonWithdrawHelpSelector(sender:UIButton){
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                var strMessage = ""
                strMessage = self.earningHelpStr
                UIAlertController.showAlertWithOkButton(self, aStrTitle: "Withdraw Earnings Help", aStrMessage: "\(strMessage)", completion: nil)
            }
         //UIAlertController.showOkAlert(self, aStrMessage: "A transaction fee of $1 will be deducted from your withdrawal total. Earned funds in your wallet will display as a payment method option and can be used without fees", completion: nil)
        }
    }
    @IBAction func buttonWithdrawSubmitSelector(sender:UIButton){
        if self.isValidData(){
            let alert = UIAlertController(title: "Withdrawal Earnings", message: "Do you want to proceed?", preferredStyle: .alert)
            let noalertAction = UIAlertAction.init(title: "No", style: .cancel, handler: { action in
                DispatchQueue.main.async {
                    //self.isSubmitEnable = false
                }
            })
            alert.addAction(noalertAction)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
               //Call API for withdrawpayment
                print(self.withdrawpayment)
                if let accountCreated = self.bankAccountStatus["is_account_created"],let accuntVerify = self.bankAccountStatus["is_account_verify"]{
                  if let created = "\(accountCreated)".bool{
                      if let verify = "\(accuntVerify)".bool{
                          if created && verify{
                             self.callAmountWithdrawAPIRequest()
                            
                          }else{
                            self.pushToAddBackDetailWebView()
                        }
                      }
                  }
                }
            }))
            alert.view.tintColor = UIColor.init(hex: "#38B5A3")
            self.present(alert, animated: true, completion: nil)
        
        }
    }
    // MARK: - APIRequest Methods
    //GET List Of Bank Details
    func getBankAccountdetailrequestAPI(){
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGETBankAccountList , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [[String:Any]]{
                                  DispatchQueue.main.async {
                                    for objBank in arrayOfJOB{
                                        if let isdefault = objBank["default_for_currency"] as? Int,isdefault == 1{
                                            DispatchQueue.main.async {
                                                var bankdetailname = ""
                                                if let name = objBank["bank_name"]{
                                                    self.lblBankName.text = "\(name)"
                                                }
                                                if let number = objBank["bank_account_last4"]{
                                                    self.lblBankAccount.text = ("\(number)")
                                                }
                                               // self.lblBankAccount.text = "\(bankdetailname)"
                                            }
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
                             //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                           }
                       }
                   }
    }
    func callAmountWithdrawAPIRequest(){
        
        var apiQuery = ""
        if self.isForBusinessEarningWithdraw{
            apiQuery = kWithDrawBusinessEarning
        }else{
            apiQuery = kWithDrawGroupEarning
        }
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:"\(apiQuery)" , parameter: self.withdrawpayment as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arraySuccess = success["success_data"] as? [String:Any]{
               DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
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
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    //push to Addd Bank details
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
    //push to withdraw history detail
    func pushtoWithdrawEarningHistoryScreenDetail(){
        DispatchQueue.main.async {
            if let withdrawPaymentHistory = UIStoryboard.activity.instantiateViewController(withIdentifier: "WithdrawPaymentHistoryViewController") as? WithdrawPaymentHistoryViewController{
                withdrawPaymentHistory.isForBusinessEarningHistory = self.isForBusinessEarningWithdraw
                self.view.endEditing(true)
                self.navigationController?.pushViewController(withdrawPaymentHistory, animated: true)
            }
        }
        
    }
    func pushToBankListViewController(){
        DispatchQueue.main.async {
            if let bankListViewCoontroller = UIStoryboard.activity.instantiateViewController(withIdentifier: "BankListViewController") as? BankListViewController{
                self.view.endEditing(true)
                bankListViewCoontroller.isWithdrawalMethod = false
                self.navigationController?.pushViewController(bankListViewCoontroller, animated: true)
            }
        }
    }
}
extension WithdrawEarningViewController:UITextFieldDelegate{
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
              let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
              
              guard !typpedString.isContainWhiteSpace() else{
                  return false
              }
             self.isSubmitEnable = typpedString.count > 0
              print("===== \(typpedString)")
            
            if textField == self.txtAmount{
                let dotString = "."
                if let text = textField.text {
                let isDeleteKey = string.isEmpty
                if !isDeleteKey {
                 if text.contains(dotString) {
                     if text.components(separatedBy: dotString)[1].count == 2 || string == dotString{
                                 return false
                     }
                 }
                }
                }
                
            }
              return true
          }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
           if textField == self.txtAmount{
                      DispatchQueue.main.async {
                        if let text = self.txtAmount.text{
                            var updatedtext =  text.replacingOccurrences(of: "$", with: "")
                               updatedtext = updatedtext.trimmingCharacters(in: .whitespaces)
                            if updatedtext.count > 0{
                                self.txtAmount.text = "\(updatedtext)"
                            }
                        }
                      }
           }
           return true
       }
       func textFieldDidEndEditing(_ textField: UITextField) {
           if textField == self.txtAmount{
                      DispatchQueue.main.async {
                        if let text = self.txtAmount.text{
                            var updatedtext =  text.replacingOccurrences(of: "$", with: "")
                               updatedtext = updatedtext.trimmingCharacters(in: .whitespaces)
                            if updatedtext.count > 0{
                                self.txtAmount.text = "$\(updatedtext)"
                            }else{
                                self.txtAmount.text = "\(updatedtext)"
                            }
                            
                        }
                      }
           }
       }
}
