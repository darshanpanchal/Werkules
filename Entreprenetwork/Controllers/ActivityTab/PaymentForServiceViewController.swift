//
//  PaymentForServiceViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 03/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class PaymentForServiceViewController: UIViewController {
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var backButtton:UIButton!
    
    @IBOutlet weak var lblPaymentTitle:UILabel!
    
    @IBOutlet weak var viewAmountContainer:UIView!
    @IBOutlet weak var shadowAmountView:ShadowBackgroundView!
    
    @IBOutlet weak var viewCardContainer:UIView!
    @IBOutlet weak var shadowCardView:ShadowBackgroundView!
       
    @IBOutlet weak var imageCard:UIImageView!
    @IBOutlet weak var lblCardNumber:UILabel!
    
    
    
    @IBOutlet weak var txtAmounttextfield:UITextField!
    @IBOutlet weak var lblRemainingAmount:UILabel!
    @IBOutlet weak var lblTotalAmount:UILabel!
    @IBOutlet weak var tableViewPaymentService:UITableView!
    
    
    @IBOutlet weak var lblWerkulesFeesAmount:UILabel!
    @IBOutlet weak var lblTransactionFeesAmount:UILabel!
    @IBOutlet weak var lblFinalAmountToPay:UILabel!
    
    @IBOutlet weak var buttonpay:UIButton!
    
    
    @IBOutlet weak var lblJOBName:UILabel!
    @IBOutlet weak var lblJOBCompletionDate:UILabel!
    @IBOutlet weak var viewTotalAmount:UIView!
    @IBOutlet weak var viewPromotionAmount:UIView!
    @IBOutlet weak var lblPromotionDetail:UILabel! //Promotion Applied - 20%
    @IBOutlet weak var lblPromotionAmount:UILabel! // Amount
    
    @IBOutlet weak var viewRemainingAmount:UIView!
    @IBOutlet weak var viewPaymentHistory:UIView!
    
    
    
    
    var strBusinessName = ""
    var jobid = ""
    var arrayOfPaymentHistroy:[[String:Any]] = []
    var strPaymenthistorydate:String = ""
    var strPaymentAmount:String = ""
    
    var werkulesfeesPercentage = ""
    var transactionamountPercentage = ""
    
    var remainingamount = ""
    var werkulesFeesAmount = ""
    var transactionFeesAmount = ""
    
    var amountToPay = ""
    
    var  dictPayment:[String:Any] = [:]
    
    var selectedPayment:[String:Any] = [:]
    var currentSelectedPaymentMethods:[String:Any]{
        get{
            return self.selectedPayment
        }
        set{
            print(newValue)
            self.selectedPayment = newValue
            //configure selected payment methods
            DispatchQueue.main.async {
                self.configureSelectedPaymentMethod()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.currentSelectedPaymentMethods = [:]
        self.imageCard.image = UIImage.init(named: "payment_credit_card") 
        self.lblCardNumber.text = "Credit/Debit Card/Earning"
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            
            self.viewTotalAmount.layer.cornerRadius = 0.0
            self.viewTotalAmount.layer.borderColor = UIColor.black.cgColor
            self.viewTotalAmount.layer.borderWidth = 0.7
            self.viewTotalAmount.clipsToBounds = true
            
            
            self.viewPromotionAmount.layer.cornerRadius = 0.0
            self.viewPromotionAmount.layer.borderColor = UIColor.black.cgColor
            self.viewPromotionAmount.layer.borderWidth = 0.7
            self.viewPromotionAmount.clipsToBounds = true


            self.viewRemainingAmount.layer.cornerRadius = 0.0
            self.viewRemainingAmount.layer.borderColor = UIColor.black.cgColor
            self.viewRemainingAmount.layer.borderWidth = 0.7
            self.viewRemainingAmount.clipsToBounds = true
          
            
            
            self.viewPaymentHistory.layer.cornerRadius = 0.0
            self.viewPaymentHistory.layer.borderColor = UIColor.black.cgColor
            self.viewPaymentHistory.layer.borderWidth = 0.7
            self.viewPaymentHistory.clipsToBounds = true
            
            self.viewCardContainer.layer.cornerRadius = 0.0
            self.viewCardContainer.layer.borderColor = UIColor.black.cgColor
            self.viewCardContainer.layer.borderWidth = 0.7
            self.viewCardContainer.clipsToBounds = true
            
            self.viewAmountContainer.layer.cornerRadius = 0.0
            self.viewAmountContainer.layer.borderColor = UIColor.black.cgColor
            self.viewAmountContainer.layer.borderWidth = 0.7
            self.viewAmountContainer.clipsToBounds = true
            
            
            self.shadowAmountView.rounding = 10.0
            self.shadowAmountView.layoutSubviews()
            
            self.shadowCardView.rounding = 10.0
            self.shadowCardView.layoutSubviews()
            
            //fetch remaining payment
            if self.jobid.count > 0{
               self.getRemainingPaymentAPIRequestWith(jobID: self.jobid)
            }
            
        }
    }
    func configureSelectedPaymentMethod(){
        
        if let value = self.currentSelectedPaymentMethods["payment_method"],"\(value)" == "card"{
            if let number = self.currentSelectedPaymentMethods["last4"]{
                      self.lblCardNumber.text = "xxxx xxxx xxxx \(number)"
                }
                  if let brandImage = self.currentSelectedPaymentMethods["brand_img"],let imgURL = URL.init(string: "\(brandImage)"){
                      self.imageCard.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "payment_credit_card"), options: .refreshCached, context: nil)
                  }
        }else if let value = self.currentSelectedPaymentMethods["payment_method"],"\(value)" == "group_earning"{
            if let value = self.currentSelectedPaymentMethods["amount"]{
                self.lblCardNumber.text = "Group Earning \(value)"
            }
            self.imageCard.image = UIImage.init(named: "group")
            
        }else if let value = self.currentSelectedPaymentMethods["payment_method"],"\(value)" == "business_earning"{
            if let value = self.currentSelectedPaymentMethods["amount"]{
                   self.lblCardNumber.text = "Business Earning \(value)"
               }
            self.imageCard.image = UIImage.init(named: "group")
        }else{
            if let value = self.currentSelectedPaymentMethods["amount"]{
               self.lblCardNumber.text = "Group Earning \(value)"
                self.imageCard.image = UIImage.init(named: "group")
           }
            
        }
        
      
    }
    
    // MARK: - User Methods
    func setup(){
        
        
        
        
        
        self.lblPaymentTitle.text = "\(strBusinessName)"
        //self.viewAmountContainer.addBordorRadiusWithColor(radius: 10.0, borderWidth: 0.3, color: UIColor.lightGray.cgColor)
        //self.viewCardContainer.addBordorRadiusWithColor(radius: 10.0, borderWidth: 0.3, color: UIColor.lightGray.cgColor)
        self.txtAmounttextfield.delegate = self
        self.txtAmounttextfield.keyboardType = .decimalPad
        
//        self.tableViewPaymentService.delegate = self
//        self.tableViewPaymentService.dataSource = self
//        self.tableViewPaymentService.rowHeight = UITableView.automaticDimension
//        self.tableViewPaymentService.estimatedRowHeight = 90.0
//        self.tableViewPaymentService.reloadData()
        
//        if let footer = self.tableViewPaymentService.tableFooterView{
//            print(footer.frame)
//        }
//        if let header = self.tableViewPaymentService.tableHeaderView{
//            print(header.frame)
//        }
        //self.tableViewPaymentService.tableHeaderView?.frame.size = CGSize(width:  self.tableViewPaymentService.frame.width, height: CGFloat(60.0))

        //self.tableViewPaymentService.tableFooterView?.frame.size = CGSize(width:  self.tableViewPaymentService.frame.width, height: CGFloat(400.0))
        
    }
    func calculateWerkulesFeesAndTransactionFees(amount:String){
        if let remainng = Double(self.remainingamount) ,let objamount = Double(amount){
            
            guard remainng >= objamount else {
                DispatchQueue.main.async {
                    SAAlertBar.show(.error, message: "Amount should be less than remaining amount.")
                    self.clearAllCalculatedAmount()
                }
                return
            }
            
        
        print(amount)
        print(werkulesfeesPercentage)
        print(transactionamountPercentage)
        if amount.count > 0,self.werkulesfeesPercentage.count > 0{
            if let floatPer = Float(amount),let werkulesfeespercentage = Float(self.werkulesfeesPercentage){
                let value = floatPer * werkulesfeespercentage
                let werkulesvalue = value/100.0
                self.werkulesFeesAmount = String(format: "%.2f", werkulesvalue)
                //self.lblWerkulesFeesAmount.text = "$\(werkulesFeesAmount)"
                print(self.werkulesFeesAmount)
            }
        }
        if amount.count > 0,self.transactionamountPercentage.count > 0{
            if let floatPer = Float(amount),let transactionfeespercentage = Float(self.transactionamountPercentage){
                let value = floatPer * transactionfeespercentage
                let transactionvalue = value/100.0
                self.transactionFeesAmount = String(format: "%.2f", transactionvalue)
                //self.lblTransactionFeesAmount.text = "$\(transactionFeesAmount)"
                print(self.transactionFeesAmount)
            }
        }
        
        if self.werkulesFeesAmount.count > 0, self.transactionFeesAmount.count > 0,let amountvalue = Double("\(amount)"),let valuewerkules = Double("\(self.werkulesFeesAmount)"),let valuetransaction = Double("\(self.transactionFeesAmount)"){
            let value =  amountvalue - valuewerkules - valuetransaction
            print(value)
            self.amountToPay = String(format: "%.2f", value)
            //self.lblFinalAmountToPay.text = "$\(self.amountToPay)"
            
            self.dictPayment["job_id"] = "\(self.jobid)"
            //self.dictPayment["amount"] = "\(amount)"
            self.dictPayment["final_amount"] = "\(amount)"//\(self.amountToPay)"
            self.dictPayment["provider_amount"] = "\(self.amountToPay)"
            self.dictPayment["werkules_fee"] = "\(self.werkulesFeesAmount)"
            self.dictPayment["transaction_fee"] = "\(self.transactionFeesAmount)"
            //Push to select Payment methods
            
//            self.buttonpay.setTitle("Pay $ \(self.amountToPay)", for: .normal)
        }
      }
        
        
        
    }
  
    func configureRemainingAmountWithDetail(dict:[String:Any]){
        if let remaing = dict["remaining_amount"],!(remaing is NSNull){
            self.lblRemainingAmount.text = "\(CurrencyFormate.Currency(value: remaing as! Double))"
            self.remainingamount = "\(remaing)"
        }
        if let werkulesfees = dict["werkules_fee"]{
            self.werkulesfeesPercentage = "\(werkulesfees)"
        }
        if let transactionfees = dict["transaction_fee"]{
            self.transactionamountPercentage = "\(transactionfees)"
        }
       
        DispatchQueue.main.async {
            if let name = dict["job_name"]{
                       self.lblJOBName.text = "\(name)"
                          }
            if let amount =  dict["saving_price"]{
                self.lblPromotionAmount.text = "-"+"\(amount)"//.add2DecimalString
            }
            if let date =  dict["last_payment_date"],!(date is NSNull){
                self.lblJOBCompletionDate.text = "\(date)".changeDateFormat
            }else{
                self.lblJOBCompletionDate.text = "none"
            }
            if let value = dict["promotion"] as? [String:Any],!(value is NSNull){
                self.viewPromotionAmount.isHidden = false
                if let price = value["customer_price"]{
                    if let type = value["type"]{
                        if "\(type)" == "amount"{
                            let promotion = "\(price)".add2DecimalString
                            self.lblPromotionDetail.text = "Promotion Applied -\(promotion)"
                        }else{
                            self.lblPromotionDetail.text = "Promotion Applied -\(price)%"
                        }
                    }
                    
                 }
            }else{
                self.viewPromotionAmount.isHidden = true
            }
        }
        if let arrayOfPaymentHistory = dict["payment_history"] as? [[String:Any]]{
            
            DispatchQueue.main.async {
                self.viewPaymentHistory.isHidden = (arrayOfPaymentHistory.count == 0)
            }
            print(arrayOfPaymentHistory)
            self.strPaymenthistorydate = ""
            self.strPaymentAmount = ""
            for objPayment in arrayOfPaymentHistory{
                if let date = objPayment["payment_date"]{
                    let objDate = "\(date)".changeDateFormat
                    self.strPaymenthistorydate += "\(objDate) \n"
                }
               
                
                if let price = objPayment["final_price"]{
                    self.strPaymentAmount += "\(CurrencyFormate.Currency(value: price as! Double))) \n"
                }
                
            }
            if self.strPaymenthistorydate.count > 0,self.strPaymentAmount.count > 0{
               // self.strPaymenthistorydate.removeLast()
                //self.strPaymentAmount.removeLast()

            }
             
//            self.arrayOfPaymentHistroy = arrayOfPaymentHistory
            
            DispatchQueue.main.async {
                //self.tableViewPaymentService.reloadData()
            }
        }
        if let remaing = dict["total_amount"],!(remaing is NSNull){
            self.lblTotalAmount.text = "\(CurrencyFormate.Currency(value: remaing as! Double))"//.add2DecimalString
        }
        
        if let selectedCardDetail = dict["selected_card_detail"] as? [String:Any]{
            print("======== \(dict["selected_card_detail"])")
            print(self.currentSelectedPaymentMethods)
            if selectedCardDetail.count > 0 && self.currentSelectedPaymentMethods.count == 0{
                self.currentSelectedPaymentMethods = selectedCardDetail
            }
            
            //self.configureSelectedPaymentMethod()
        }
        
    }
    // MARK: - API Request Methods
    //GET REMAINING PAYMENT
    func getRemainingPaymentAPIRequestWith(jobID:String){
        var dict:[String:Any] = [:]
        dict["job_id"] = "\(jobID)"
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kPaymentRemainingDetail , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
        if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                      DispatchQueue.main.async {
                         print(userInfo)
                        self.configureRemainingAmountWithDetail(dict: userInfo)
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
    //POST PAYMENT API
    func postJOBPaymentAPIRequestWith(dict:[String:Any]){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kPaymentJOBPayment , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
              if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                            DispatchQueue.main.async {
                               print(userInfo)
                                var isForPartialPayment = false
                                if let remaining = userInfo["remaining_amount"]{
                                    if let pi: Double = Double("\(remaining)"){
                                        print("\(pi) ===== ")
                                        isForPartialPayment = pi > 0.0
                                    }
                                }
                                self.presentSuccessPaymentPOPUPAlert(isForpartialpayment: isForPartialPayment)
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
                                UIAlertController.showOkAlert(self, aStrMessage: "\(errorMessage.first!)") { _,_  in
                                    DispatchQueue.main.async {
                                        self.txtAmounttextfield.becomeFirstResponder()
                                    }
                                }
                                  //SAAlertBar.show(.error, message:"\(errorMessage.first!)".localizedLowercase)
                              }
                          }
                      }else{
                             DispatchQueue.main.async {
                                 SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                             }
                         }
                     }
    }
    // MARK: - Selector Methods
        @IBAction func buttonBackSelector(sender:UIButton){
            self.navigationController?.popViewController(animated: true)
        }
    @IBAction func buttonSelectPaymentMethod(sender:UIButton){
        self.pushtoselectPaymentMethodViewController()
    }
    func isValidPayment()->Bool{
        
        return false
    }
    @IBAction func buttonPaymentHistorySelector(sender:UIButton){
        if self.jobid.count > 0{
            self.pushtoPaymentHistoryViewController(jobID: self.jobid)

                   }
    }
    @IBAction func buttonPaymentSelector(sender:UIButton){
//        self.presentSuccessPaymentPOPUPAlert()
        guard let amount = self.txtAmounttextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines),amount.count > 0 else{
            SAAlertBar.show(.error, message:"Please enter amount to pay".localizedLowercase)
            return
        }
        guard self.currentSelectedPaymentMethods.count > 0 else{
            SAAlertBar.show(.error, message:"Please select payment method".localizedLowercase)
            return
        }
        if let value = self.currentSelectedPaymentMethods["payment_method"]{
            self.dictPayment["payment_method"] = "\(value)"
        }
        if let cardid = self.currentSelectedPaymentMethods["card_id"]{
            self.dictPayment["card_id"] = "\(cardid)"
        }else{
             self.dictPayment["card_id"] = ""
        }
        self.postJOBPaymentAPIRequestWith(dict: self.dictPayment)
        //
        /*
        if let text = self.txtAmounttextfield.text, text.count > 0{
            var updatedtext =  text.replacingOccurrences(of: "$", with: "")
            updatedtext = updatedtext.trimmingCharacters(in: .whitespaces)
            
            print(updatedtext)
            print(self.dictPayment)
            DispatchQueue.main.async {
//                self.clearAllCalculatedAmount()
                self.pushtoselectPaymentMethodViewController()
                
                
            }
        }else{
            DispatchQueue.main.async {
                SAAlertBar.show(.error, message: "Please enter amount to pay")
            }
        }*/
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushtoPaymentHistoryViewController(jobID:String){
          if let paymentHistory = UIStoryboard.activity.instantiateViewController(withIdentifier: "CustommerPaymentHistoryViewController") as? CustommerPaymentHistoryViewController{
              paymentHistory.isForJOBSpecific = true
              paymentHistory.jobId = jobID
              paymentHistory.hidesBottomBarWhenPushed = true
              self.navigationController?.pushViewController(paymentHistory, animated: true)
          }
      }
    func pushtoselectPaymentMethodViewController(){
        if let paymentmethodviewcontroller = UIStoryboard.activity.instantiateViewController(withIdentifier: "PaymentMethodViewController") as? PaymentMethodViewController{
            paymentmethodviewcontroller.delegate = self
            paymentmethodviewcontroller.dictPaymentDetail = self.dictPayment
            self.navigationController?.pushViewController(paymentmethodviewcontroller, animated: true)
        }
    }
    func presentSuccessPaymentPOPUPAlert(isForpartialpayment:Bool){
            if let sendOfferPopup = UIStoryboard.main.instantiateViewController(withIdentifier: "PaymentSuccessAlertViewController") as? PaymentSuccessAlertViewController{
                sendOfferPopup.modalPresentationStyle = .overFullScreen
                sendOfferPopup.delegate = self
                sendOfferPopup.isForPartialPayment = isForpartialpayment
                 self.present(sendOfferPopup, animated: true, completion: nil)
            }
    }

}
extension PaymentForServiceViewController:PaymentMethodSelectionDeleagte{
    func didSelectedCardDetail(dict: [String : Any]) {
        print(dict)
        self.currentSelectedPaymentMethods = dict
    }
    func didSelectedWalletDetail(dict: [String : Any]) {
        print(dict)
        self.currentSelectedPaymentMethods = dict
        
    }
    func didSelectedPaymentMethod(dict: [String : Any]) {
        self.currentSelectedPaymentMethods = dict
        
        print(dict)
//        self.postJOBPaymentAPIRequestWith(dict: dict)
        
    }
}
extension PaymentForServiceViewController:PaymentSuccessPopupDeledate{
    func buttonHomeselector(isForPartialPayment:Bool) {
        DispatchQueue.main.async {
            if let objTabView = self.navigationController?.tabBarController{
                   objTabView.selectedIndex = 1
                if let objMyPostNavigation:UINavigationController = objTabView.viewControllers?[1] as? UINavigationController{
                   if let objMyPost:MessagesVC = objMyPostNavigation.viewControllers.first as? MessagesVC{
                    if isForPartialPayment{
                        objMyPost.selectedIndexFromNotification = 2
                    }else{
                        objMyPost.selectedIndexFromNotification = 3
                    }
                   }
                   self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
extension PaymentForServiceViewController:UITableViewDelegate, UITableViewDataSource{
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1//self.arrayOfPaymentHistroy.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableViewPaymentService.dequeueReusableCell(withIdentifier: "PaymentHistoryTableViewCell", for: indexPath) as! PaymentHistoryTableViewCell
      
        if self.strPaymenthistorydate.count > 0, self.strPaymentAmount.count > 0{
        //if self.arrayOfPaymentHistroy.count > indexPath.row{
            //payment_date
//            let objPayment:[String:Any] = self.arrayOfPaymentHistroy[indexPath.row]
//            if let date = objPayment["payment_date"]{
                cell.lblDateOfPayment.text = "\(self.strPaymenthistorydate)"
            print(self.strPaymenthistorydate)
//            }
//            if let price = objPayment["paid_price"]{
                cell.lblPaymentAmount.text = "\(self.strPaymentAmount)"
//            }
            print(self.strPaymentAmount)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension PaymentForServiceViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
                return true
             }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtAmounttextfield{
                   DispatchQueue.main.async {
                     if let text = self.txtAmounttextfield.text{
                         var updatedtext =  text.replacingOccurrences(of: "$", with: "")
                            updatedtext = updatedtext.trimmingCharacters(in: .whitespaces)
                         self.txtAmounttextfield.text = "\(updatedtext)"
                     }
                   }
               }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtAmounttextfield{
                          DispatchQueue.main.async {
                           if let text = self.txtAmounttextfield.text,text.count > 0{
                               let updatedtext =  text.replacingOccurrences(of: "$", with: "")
                               //calculate werkules fees and transaction fees for payment
                               self.calculateWerkulesFeesAndTransactionFees(amount: updatedtext)
                               self.txtAmounttextfield.text = "$\(updatedtext)"
                              
                           }else{
                                self.clearAllCalculatedAmount()
                            
                            }
                        }
               }
    }
    func clearAllCalculatedAmount(){
        self.txtAmounttextfield.text = ""
        //self.lblWerkulesFeesAmount.text = "$0.0"
        //self.lblTransactionFeesAmount.text = "$0.0"
        //self.lblFinalAmountToPay.text = "$0.0"
        self.buttonpay.setTitle("Pay", for: .normal)
    }
}
class PaymentHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewContainer:UIView!
    @IBOutlet weak var lblDateOfPayment:UILabel!
    @IBOutlet weak var lblPaymentAmount:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewContainer.addBordorRadiusWithColor(radius: 15.0, borderWidth: 0.0, color: UIColor.clear.cgColor)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
