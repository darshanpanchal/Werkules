//
//  PaymentMethodViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 02/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

protocol PaymentMethodSelectionDeleagte {
    //func didSelectedPaymentMethod(dict:[String:Any])
    func didSelectedCardDetail(dict:[String:Any])
    func didSelectedWalletDetail(dict:[String:Any])
}
class PaymentMethodViewController: UIViewController {
    
    
    var delegate:PaymentMethodSelectionDeleagte?
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var backButtton:UIButton!
    
    @IBOutlet weak var lblSelectPayment:UILabel!
    
    //stripe container view
    @IBOutlet fileprivate weak var stripeContainerView:UIView!
    @IBOutlet fileprivate weak var stripeShadowView:ShadowBackgroundView!
    @IBOutlet fileprivate weak var stipeSubContainer:UIView!
    @IBOutlet fileprivate weak var lblStripeVerificatioStatus:UILabel!
    @IBOutlet fileprivate weak var buttonStipeSelect:UIButton!
    @IBOutlet fileprivate weak var buttonStropeVerified:UIButton!
    
    
    
    
    
    //Debit card container
    @IBOutlet weak var viewMainDebitCardContainer:UIView!
    @IBOutlet weak var viewDebitContainer:UIView!
    @IBOutlet weak var shadowDebitContainer:ShadowBackgroundView!
    @IBOutlet weak var imageDebitCard:UIImageView!
    @IBOutlet weak var lblDebitCardNumber:UILabel!
    @IBOutlet weak var buttonAddDebitCard:UIButton!
    @IBOutlet weak var buttonSelectDebitCard:UIButton!
    
    @IBOutlet fileprivate weak var buttonDebitcardDetailSelector:UIButton!
    
    //Credit card container
    @IBOutlet weak var viewMainCreditContainer:UIView!
    @IBOutlet weak var viewCreditContainer:UIView!
    @IBOutlet weak var shadowCreditContainer:ShadowBackgroundView!
    @IBOutlet weak var imageCreditCard:UIImageView!
    @IBOutlet weak var lblCreditCardNumber:UILabel!
    @IBOutlet weak var buttonAddCreditCard:UIButton!
    @IBOutlet weak var buttonSelectCreditCard:UIButton!
    
    @IBOutlet weak var buttonDeleteDebitCard:UIButton!
    @IBOutlet weak var buttonDeleteCreditCard:UIButton!
    
    var dictPaymentDetail:[String:Any] = [:]
    
    //Group Earning
    @IBOutlet weak var viewMainGroupEarningContainer:UIView!
    @IBOutlet weak var viewGroupEarningContainer:UIView!
    @IBOutlet weak var shadowGroupEarningContainer:ShadowBackgroundView!
    @IBOutlet weak var lblWalletAmount:UILabel!

    //Business Earning
    @IBOutlet weak var viewMainBusinessEarningContainer:UIView!
    @IBOutlet weak var viewBusinessEarningContainer:UIView!
    @IBOutlet weak var shadowBusinessEarningContainer:ShadowBackgroundView!
    @IBOutlet weak var lblBusinessEarning:UILabel!
    
    var debitCardDetail:[String:Any] = [:]{
        didSet{
            //Configure debit card details
            DispatchQueue.main.async {
                self.configureDebitCardDetails()
            }
        }
    }
    var creditCardDetail:[String:Any] = [:]{
        didSet{
            //Configure credit card details
            DispatchQueue.main.async {
                self.configureCreditCardDetails()
            }
        }
    }
    //Wallet card container
    let strSelectPayment = "Select Payment"
    let strAcceptPayment = "To accept payments, you need to setup bank account to accept deposits, via your debit card."
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //fetch card list API
        self.getCardListAPIRequestMethod()
    }
    func setup(){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                           return
                }
        if currentUser.userRoleType == .provider{
            self.viewMainBusinessEarningContainer.isHidden = false
            self.lblSelectPayment.text = "\(strAcceptPayment)"
            self.viewMainCreditContainer.isHidden = true
            self.stripeContainerView.isHidden = true
            
        }else if currentUser.userRoleType == .customer{
            self.viewMainBusinessEarningContainer.isHidden = false
            self.lblSelectPayment.text = "\(strSelectPayment)"
            self.viewMainCreditContainer.isHidden = false
            self.stripeContainerView.isHidden = true
        }else{
            self.viewMainBusinessEarningContainer.isHidden = true
            self.lblSelectPayment.text = "\(strSelectPayment)"
            self.viewMainCreditContainer.isHidden = false
            self.stripeContainerView.isHidden = true
        }
        
        
        
        
        self.stripeShadowView.rounding = 15.0
        self.stripeShadowView.layer.cornerRadius = 15.0
        self.stripeShadowView.layoutIfNeeded()
        
        self.stipeSubContainer.layer.cornerRadius = 15.0
        self.stipeSubContainer.layoutIfNeeded()
        
        
        self.shadowGroupEarningContainer.rounding = 15.0
        self.shadowGroupEarningContainer.layer.cornerRadius = 15.0
        self.shadowGroupEarningContainer.layoutIfNeeded()
        
        self.viewGroupEarningContainer.layer.cornerRadius = 15.0
        self.viewGroupEarningContainer.clipsToBounds = true
        
        self.shadowBusinessEarningContainer.rounding = 15.0
        self.shadowBusinessEarningContainer.layer.cornerRadius = 15.0
        self.shadowBusinessEarningContainer.layoutIfNeeded()
        
        self.viewBusinessEarningContainer.layer.cornerRadius = 15.0
        self.viewBusinessEarningContainer.clipsToBounds = true
        
        self.shadowDebitContainer.rounding = 15.0
        self.shadowDebitContainer.layer.cornerRadius = 15.0
        self.shadowDebitContainer.layoutIfNeeded()
        
        self.viewDebitContainer.layer.cornerRadius = 15.0
        self.viewDebitContainer.clipsToBounds = true
        
        self.shadowCreditContainer.rounding = 15.0
        self.shadowCreditContainer.layer.cornerRadius = 15.0
        self.shadowCreditContainer.layoutIfNeeded()
        
        self.viewCreditContainer.layer.cornerRadius = 15.0
        self.viewCreditContainer.clipsToBounds = true
        
    }
    func configureStipeVerificationContainer(isVerified:Bool){
        /*
        DispatchQueue.main.async {
            //if for customer hide stripe container
                  if isVerified{
                    self.lblStripeVerificatioStatus.text = "Verified"
                    self.buttonStipeSelect.isHidden = true
                    self.buttonStropeVerified.isHidden = false
                    self.viewMainDebitCardContainer.alpha = 1.0
                    self.buttonDebitcardDetailSelector.isEnabled = true
                  }else{
                    self.lblStripeVerificatioStatus.text = "Verify Stripe"
                    self.buttonStipeSelect.isHidden = false
                    self.buttonStropeVerified.isHidden = true
                    self.viewMainDebitCardContainer.alpha = 0.5
                    self.buttonDebitcardDetailSelector.isEnabled = false
                  }
        }
      */
        
    }
    // MARK: - Selector Methods
      @IBAction func buttonBackSelector(sender:UIButton){
          self.navigationController?.popViewController(animated: true)
      }
    @IBAction func buttonAddNewDebitCardSelector(sender:UIButton){
        self.pushToAddNewCreditDebitCardViewController()
    }
    @IBAction func buttonSelectDebitCardSelector(sender:UIButton){
        
        if self.debitCardDetail.count > 0{
            print(debitCardDetail)
            print(self.dictPaymentDetail)
            self.dictPaymentDetail["payment_method"] = "card"
            if let cardid = debitCardDetail["card_id"]{
                   self.dictPaymentDetail["card_id"] = "\(cardid)"
               }
            if let _ = self.delegate{
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.debitCardDetail["payment_method"] = "card"
                    self.delegate!.didSelectedCardDetail(dict: self.debitCardDetail)
                    //self.delegate!.didSelectedPaymentMethod(dict: self.dictPaymentDetail)

                }
            }
        }else{
             self.pushToAddNewCreditDebitCardViewController()
        }
       }
    @IBAction func buttonDeleteDebitCardSelector(sender:UIButton){
         let strdelete = "Are you sure you want to delete this card?"
        
        UIAlertController.showAlertWithCancelButton(self, aStrMessage: "\(strdelete)") { (objInt, strString) in
                      if objInt == 0{
                          if self.debitCardDetail.count > 0{
                            print(self.debitCardDetail)
                            if let id = self.debitCardDetail["card_id"]{
                                self.deleteCardAPIRequesttMethod(cardID: "\(id)",isCredit: false)
                            }
                            
                        }
                      }
                  }
    }
    @IBAction func buttonAddNewCreditCardSelector(sender:UIButton){
        self.pushToAddNewCreditDebitCardViewController()
    }
    @IBAction func buttonSelectCreditCardSelector(sender:UIButton){
            if self.creditCardDetail.count > 0{
                print(creditCardDetail)
                print(self.dictPaymentDetail)
                self.dictPaymentDetail["payment_method"] = "card"
                if let cardid = creditCardDetail["card_id"]{
                    self.dictPaymentDetail["card_id"] = "\(cardid)"
                }
                if let _ = self.delegate{
                DispatchQueue.main.async {
                      self.navigationController?.popViewController(animated: true)
                        self.creditCardDetail["payment_method"] = "card"
                       self.delegate!.didSelectedCardDetail(dict: self.creditCardDetail)
                      //self.delegate!.didSelectedPaymentMethod(dict: self.dictPaymentDetail)

                   }
                }
            }else{
                 self.pushToAddNewCreditDebitCardViewController()
            }
        }
    @IBAction func buttonSelectWalletPayment(sender:UIButton){
        //print(self.dictPaymentDetail)
        if let _ = self.delegate{
            print("test")
            DispatchQueue.main.async {
                if let text = self.lblWalletAmount.text,text.count > 0{
                    var dollarTotal = "\(text)".replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    dollarTotal = "\(dollarTotal)".replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    print(dollarTotal)
                    if let myNumber = NumberFormatter().number(from: dollarTotal) {
                        if myNumber.intValue > 0{
                            self.navigationController?.popViewController(animated: true)
                            var dict:[String:Any] = [:]
                            dict["payment_method"] = "group_earning"
                            dict["amount"] = "\(text)"
                            self.delegate!.didSelectedWalletDetail(dict: dict)
                        }else{
                            DispatchQueue.main.async {
                                SAAlertBar.show(.error, message:"You don't have enough funds available for payment".localizedLowercase)
                            }
                        }
                    } else {
                      DispatchQueue.main.async {
                          SAAlertBar.show(.error, message:"You don't have enough funds available for payment".localizedLowercase)
                      }
                    }
                }else{
                    DispatchQueue.main.async {
                        SAAlertBar.show(.error, message:"You don't have enough funds available for payment".localizedLowercase)
                    }
                }
               
            }
        }
        
    }
    @IBAction func buttonBusinessEarning(sender:UIButton){
        if let _ = self.delegate{
            DispatchQueue.main.async {
                if let text = self.lblBusinessEarning.text,text.count > 0{
                    var dollarTotal = "\(text)".replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    dollarTotal = "\(dollarTotal)".replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                       print(dollarTotal)
                       if let myNumber = NumberFormatter().number(from: dollarTotal) {
                        print(myNumber)
                               if myNumber.intValue > 0{
                                   self.navigationController?.popViewController(animated: true)
                                   var dict:[String:Any] = [:]
                                   dict["payment_method"] = "business_earning"
                                   dict["amount"] = "\(text)"
                                   self.delegate!.didSelectedWalletDetail(dict: dict)
                               }else{
                                   DispatchQueue.main.async {
                                       SAAlertBar.show(.error, message:"You don't have enough funds available for payment".localizedLowercase)
                                   }
                               }
                           } else {
                             DispatchQueue.main.async {
                                 SAAlertBar.show(.error, message:"You don't have enough funds available for payment".localizedLowercase)
                             }
                           }
                   }else{
                       DispatchQueue.main.async {
                           SAAlertBar.show(.error, message:"You don't have enough funds available for payment".localizedLowercase)
                       }
                   }
//                self.navigationController?.popViewController(animated: true)
//                var dict:[String:Any] = [:]
//                dict["payment_method"] = "business_earning"
//                self.delegate!.didSelectedWalletDetail(dict: dict)
            }
        }
    }
    @IBAction func buttonDeleteCreditCardSelector(sender:UIButton){
        
        let strdelete = "Are you sure you want to delete this card?"
              
              UIAlertController.showAlertWithCancelButton(self, aStrMessage: "\(strdelete)") { (objInt, strString) in
                            if objInt == 0{
                                if self.creditCardDetail.count > 0{
                                    print(self.creditCardDetail)
                                    if let id = self.creditCardDetail["card_id"]{
                                        self.deleteCardAPIRequesttMethod(cardID: "\(id)",isCredit: true)
                                    }
                                    
                                }
                            }
                        }
    }
    @IBAction func buttonStripeVerificationSelector(sender:UIButton){
        self.pushtoStripeVerificationViewController()
    }
    @IBAction func buttonInfoStripeSelector(sender:UIButton){
        let strInfo = "To receive payout you have to verify your stripe account."
        UIAlertController.showOkAlert(self, aStrMessage: "\(strInfo)") { (objInt, strString) in
            
        }
     
    }
    // MARK: - Users Methods
    func configureCreditCardDetails(){
        if let number = self.creditCardDetail["last4"]{
            self.lblCreditCardNumber.text = "xxxx xxxx xxxx \(number)"
        }
        self.buttonAddCreditCard.isHidden = true
        self.buttonSelectCreditCard.isHidden = false
        self.buttonDeleteCreditCard.isHidden = false
        
        if let brandImage = self.creditCardDetail["brand_img"],let imgURL = URL.init(string: "\(brandImage)"){
            self.imageCreditCard.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "payment_credit_card"), options: .refreshCached, context: nil)
        }
    }
    func clearCreditCardDetails (){
        self.imageCreditCard.image = UIImage.init(named: "payment_credit_card")
        self.buttonDeleteCreditCard.isHidden = true
        self.buttonAddCreditCard.isHidden = false
        self.buttonSelectCreditCard.isHidden = true
        self.lblCreditCardNumber.text = "Add credit card"
    }
    func configureDebitCardDetails(){
        if let number = self.debitCardDetail["last4"]{
            self.lblDebitCardNumber.text = "xxxx xxxx xxxx \(number)"
        }
        self.buttonAddDebitCard.isHidden = true
        self.buttonSelectDebitCard.isHidden = false
         self.buttonDeleteDebitCard.isHidden = false
        
        if let brandImage = self.debitCardDetail["brand_img"],let imgURL = URL.init(string: "\(brandImage)"){
            self.imageDebitCard.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "payment_credit_card"), options: .refreshCached, context: nil)
        }
    }
    func clearDebitCardDetails (){
        self.imageDebitCard.image = UIImage.init(named: "payment_credit_card")
        self.buttonDeleteDebitCard.isHidden = true
        self.buttonAddDebitCard.isHidden = false
        self.buttonSelectDebitCard.isHidden = true
        self.lblDebitCardNumber.text = "Add debit card"
    }
    // MARK: - API Request Methods
    func getCardListAPIRequestMethod(){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kPaymentCardList , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                             
                             if let success = responseSuccess as? [String:Any],let objresponseSuccess = success["success_data"] as? [String:Any],let arrayOfcards = objresponseSuccess["card"] as? [[String:Any]]{
                                        for cardJSON in arrayOfcards{
                                            print(cardJSON)
                                            if let card_type = cardJSON["card_type"]{
                                                if ("\(card_type)".caseInsensitiveCompare("credit") == .orderedSame){
                                                    self.creditCardDetail = cardJSON
                                                }else if ("\(card_type)".caseInsensitiveCompare("debit") == .orderedSame){
                                                    self.debitCardDetail = cardJSON
                                                }else{
                                                    self.clearDebitCardDetails()
                                                    self.clearCreditCardDetails()
                                                }
                                            }
                                        }
                                if let stipeValidationStatus = objresponseSuccess["stripe_account_status"]{
                                    if "\(stipeValidationStatus)" == "in_active"{
                                        self.configureStipeVerificationContainer(isVerified: false)
                                    }else if "\(stipeValidationStatus)" == "active"{
                                        self.configureStipeVerificationContainer(isVerified: true)
                                    }else{
                                        self.configureStipeVerificationContainer(isVerified: false)
                                    }
                                }
                                if let wallet = objresponseSuccess["wallet"]{
                                    print("===== \(wallet) amount")
                                    DispatchQueue.main.async {
                                        if let pi: Double = Double("\(wallet)"){
                                            let walletAmount = String(format:"%.2f", pi)
                                            self.lblWalletAmount.text = CurrencyFormate.Currency(value: Double(walletAmount) ?? 0)//"$\(walletAmount)"
                                        }
                                    }
                                }
                                if let businessAmount = objresponseSuccess["business_earning"]{
                                    print("===== \(businessAmount) amount")
                                    DispatchQueue.main.async {
                                        if let pi: Double = Double("\(businessAmount)"){
                                            let businessAmount = String(format:"%.2f", pi)
                                            self.lblBusinessEarning.text = CurrencyFormate.Currency(value: Double(businessAmount) ?? 0)//"$\(businessAmount)"
                                        }
                                    }
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
                                    }
    }
    func deleteCardAPIRequesttMethod(cardID:String,isCredit:Bool){
        var dict:[String:Any] = [:]
        dict["card_id"] = "\(cardID)"
        
        
        APIRequestClient.shared.sendAPIRequest(requestType: .DELETE, queryString:kPaymentDeleteCard , parameter: dict as? [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any]{
                DispatchQueue.main.async {
                     SAAlertBar.show(.error, message:"Your card has been deleted.".localizedLowercase)
                    if isCredit{
                        self.clearCreditCardDetails()
                    }else{
                        self.clearDebitCardDetails()
                    }
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
                }
        
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushToAddNewCreditDebitCardViewController(){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            if let addNewCardViewController = UIStoryboard.activity.instantiateViewController(withIdentifier: "AddNewCardViewController") as? AddNewCardViewController{
                     self.navigationController?.pushViewController(addNewCardViewController, animated: true)
                 }
        }
     
    }
    func pushtoStripeVerificationViewController(){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            if let addNewCardViewController = UIStoryboard.activity.instantiateViewController(withIdentifier: "StripeValidationViewController") as? StripeValidationViewController{
                     self.navigationController?.pushViewController(addNewCardViewController, animated: true)
                 }
        }
    }

}
