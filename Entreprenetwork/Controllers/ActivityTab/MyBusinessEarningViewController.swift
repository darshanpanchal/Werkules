//
//  MyBusinessEarningViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 12/04/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class MyBusinessEarningViewController: UIViewController {
    //Navigation
    @IBOutlet fileprivate weak var lblTitle:UILabel!
    @IBOutlet fileprivate weak var buttonBack:UIButton!

    //TableView
    @IBOutlet fileprivate weak var tableViewHistory:UITableView!

    fileprivate var arrayOfWithDraw:[[String:Any]] = []
    
    @IBOutlet fileprivate weak var buttonBusinessEarning:UIButton!
    @IBOutlet weak var lblTotalEarningOn2DaysHold:UILabel!

    @IBOutlet weak var lblTotalBusinessEarning:UILabel!
    @IBOutlet weak var lblTotalBusinessEarningAvailable:UILabel!
    @IBOutlet weak var lblTotalBusinessEarningWithDraw:UILabel!
    
     @IBOutlet fileprivate weak var lblnowithdraval:UILabel!
    
    var isLoadMore:Bool = false
    var currentPage:Int = 1
    var fetchPageLimit:Int = 50
    
    var bankAccountStatus:[String:Any] = [:]
    var businessEarningHelpStr: String = ""
    var totalBusinessEarningHelpStr: String = ""
    var totalEarningOn2DaysHoldStr:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
        
        let underlineSeeDetail = NSAttributedString(string: "Withdraw Earnings",
                                                                              attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.buttonBusinessEarning.setAttributedTitle(underlineSeeDetail, for: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          self.currentPage = 1
          self.isLoadMore = false
      }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fetchMyBusinessEarningDetailAPIRequest()
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
    // MARK: - Custom Methods
    func setup(){
        
        //TableView
        self.configureTableView()
        
    }
    
    //configure tableview
    func configureTableView(){
        self.tableViewHistory.delegate = self
        self.tableViewHistory.dataSource = self
        self.tableViewHistory.estimatedRowHeight = 100.0
        self.tableViewHistory.rowHeight = UITableView.automaticDimension
        self.tableViewHistory.tableFooterView = UIView()
        self.tableViewHistory.reloadData()
    }
    // MARK: - API Methods
    func fetchMyBusinessEarningDetailAPIRequest(){
        var dict:[String:Any] = [:]
                             
                             dict["limit"] = "\(self.fetchPageLimit)"
                             dict["page"] = "\(self.currentPage)"
               
                      APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGETMYBusinessEarning , parameter:dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                              
                              if let success = responseSuccess as? [String:Any],let successData = success["success_data"] as? [String:Any]{
                                if let arrayWithdraw = successData["withdraw_list"] as? [[String:Any]]{
                                    if self.currentPage == 1{
                                        self.arrayOfWithDraw.removeAll()
                                    }
                                    self.isLoadMore = arrayWithdraw.count > 0
                                    if arrayWithdraw.count > 0 {
                                        for objWithDraw in arrayWithdraw{
                                           self.arrayOfWithDraw.append(objWithDraw)
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        self.tableViewHistory.reloadData()
                                    }
                                }
                                        //configure other details
                                        /*
                                 "total_business_earnings_to_date": 0,
                                 "total_business_earnings_available": 0,
                                 "total_business_earnings_withdrawn_to_date": 0
                                        */
                                DispatchQueue.main.async {
                                    if let value = successData["total_business_earnings_available"],!(value is NSNull){
                                        if let pi: Double = Double("\(value)"){
                                          let updateValue = String(format:"%.2f", pi)
                                            self.lblTotalBusinessEarningAvailable.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                                        }
                                    }
                                    if let value = successData["total_business_earnings_to_date"],!(value is NSNull){
                                        if let pi: Double = Double("\(value)"){
                                          let updateValue = String(format:"%.2f", pi)
                                          self.lblTotalBusinessEarning.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                                        }
                                        
                                    }
                                    if let value = successData["total_business_earnings_2_day_hold_available"],!(value is NSNull){
                                        if let pi: Double = Double("\(value)"){
                                          let updateValue = String(format:"%.2f", pi)
                                          self.lblTotalEarningOn2DaysHold.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                                        }
                                        
                                    }
                                  
                                    if let value = successData["total_business_earnings_withdrawn_to_date"],!(value is NSNull){
                                        if let pi: Double = Double("\(value)"){
                                         let updateValue = String(format:"%.2f", pi)
                                         self.lblTotalBusinessEarningWithDraw.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                                        }
                                    }
                                    if let businessearning = successData["business_earning_help"] as? String{
                                        self.businessEarningHelpStr = businessearning
                                    }
                                    if let totalbusinessearning = successData["total_business_earning_help"] as? String{
                                        self.totalBusinessEarningHelpStr = totalbusinessearning
                                    }
                                    if let totalbusinessearning = successData["total_business_earnings_2_day_hold_help"] as? String{
                                        self.totalEarningOn2DaysHoldStr = totalbusinessearning
                                    }
                                    
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
                                              //   SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                             }
                                         }
                                     }
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func infoWithdrawEarningHoldSelector(sender:UIButton){
        DispatchQueue.main.async {
            UIAlertController.showAlertWithOkButton(self, aStrTitle: "Earnings in 2 day hold Help", aStrMessage: "\(self.totalEarningOn2DaysHoldStr)", completion: nil)
        }
    }
    @IBAction func infoTotalBusinesssEarningsSelector(sender:UIButton){
        DispatchQueue.main.async {
            UIAlertController.showAlertWithOkButton(self, aStrTitle: "My Business Earnings Help", aStrMessage: "\(self.totalBusinessEarningHelpStr)", completion: nil)
        }
    }
    @IBAction func infoBusinesssEarningsSelector(sender:UIButton){
        DispatchQueue.main.async {
            var strMessage = ""
            strMessage = self.businessEarningHelpStr
            UIAlertController.showAlertWithOkButton(self, aStrTitle: "Withdraw Earnings Help", aStrMessage: "\(strMessage)", completion: nil)
        }
        /*
        DispatchQueue.main.async {
                    UIAlertController.showOkAlert(self, aStrMessage: "A transaction fee of $1 will be deducted from your withdrawal total. Earned funds in your wallet will display as a payment method option and can be used without fees", completion: nil)
               }*/
    }
    @IBAction func buttonWithDrawEarningViewController(sender:UIButton){
        
        self.pushToBusinesEarningScreen()
        /*
        DispatchQueue.main.async {
            if let accountCreated = self.bankAccountStatus["is_account_created"],let accuntVerify = self.bankAccountStatus["is_account_verify"]{
                                       if let created = "\(accountCreated)".bool{
                                           if let verify = "\(accuntVerify)".bool{
                                               if created && verify{
                                                self.pushToBusinesEarningScreen()
                                                
                                               }else{
                                                 self.pushToAddBackDetailWebView()
                                             }
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
                addBankAccount.isFromBussiness = true
                   self.navigationController?.pushViewController(addBankAccount, animated: true)
             }
         }
        
     }
    //push to business earning screen
    func pushToBusinesEarningScreen(){
        if let withdrawearning = UIStoryboard.activity.instantiateViewController(withIdentifier: "WithdrawEarningViewController") as? WithdrawEarningViewController{
            DispatchQueue.main.async {
                self.view.endEditing(true)
                self.hidesBottomBarWhenPushed = true
                withdrawearning.isForBusinessEarningWithdraw = true
                if let amount = self.lblTotalBusinessEarningAvailable.text{
                    withdrawearning.earningAvailable = "\(amount)"
                }
                withdrawearning.earningHelpStr = "\(self.businessEarningHelpStr)"
                self.navigationController?.pushViewController(withdrawearning, animated: true)
            }
        }
    }
    

}
extension MyBusinessEarningViewController:AddBankAccountWithdrawalDelegate{
    func pushToWithDrawalScreenDelegate() {
        self.pushToBusinesEarningScreen()
    }
}
extension MyBusinessEarningViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DispatchQueue.main.async {
            self.lblnowithdraval.isHidden = (self.arrayOfWithDraw.count != 0)
        }
        return self.arrayOfWithDraw.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableViewHistory.dequeueReusableCell(withIdentifier: "WithdrawPaymentHistoryTableViewCell", for: indexPath) as! WithdrawPaymentHistoryTableViewCell
        
        var isForJOBPayment = false
        
        if self.arrayOfWithDraw.count > indexPath.row{
            let objHistory = self.arrayOfWithDraw[indexPath.row]
            if let value = objHistory["amount"],!(value is NSNull){
                if let pi: Double = Double("\(value)"){
                  let updateValue = String(format:"%.2f", pi)
                    cell.lblAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                }
                
                
                if let value = objHistory["transaction_fee"],!(value is NSNull){
                    if let pi: Double = Double("\(value)"){
                        let updateValue = String(format:"%.2f", pi)
                        cell.lblTransactionFees.text = "- \(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                    }
                    
                }
                if let value = objHistory["withdrawal_amount"],!(value is NSNull){
                    if let pi: Double = Double("\(value)"){
                      let updateValue = String(format:"%.2f", pi)
                      cell.lblWithdrawalAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                    }
                }
                if let value = objHistory["payment_status"],!(value is NSNull){
                    cell.lblWithdrawalStatus.text = "\(value)".uppercased()
                }
                
              let myFloat = ("\(value)" as NSString).floatValue
                if let werkulesamount = Int.init(myFloat) as? Int{
                    if werkulesamount > 1{
                        //cell.lblWithdrawalAmount.text = "$ \(werkulesamount - 1)"
                    }
                }
            }
            if let value = objHistory["created_at"],!(value is NSNull){
                let dateformatter = DateFormatter()
                  dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                  if let date = dateformatter.date(from: "\(value)"){
                      dateformatter.dateFormat = "MM/dd/yyyy"
                    var strDate = dateformatter.string(from: date)
                    
                    
                    if let name = objHistory["business_name"],!(name is NSNull){
                        if "\(name)".count > 0{
                            strDate.append(" (\(name))")
                            isForJOBPayment = true
                        }else{
                            strDate.append(" (User Withdrawal)")
                            isForJOBPayment = false
                        }
                    }else{
                        strDate.append(" (User Withdrawal)")
                        isForJOBPayment = false
                    }
                    cell.lblDate.text = "\(strDate)"
                   //  cell.lblDate.text = dateformatter.string(from: date)
                  }
            }
        }
        
        if indexPath.row+1 == self.arrayOfWithDraw.count, self.isLoadMore{ //last index
        DispatchQueue.global(qos: .background).async {
            self.currentPage += 1
            self.fetchMyBusinessEarningDetailAPIRequest()
            }
        }
        if isForJOBPayment{
            cell.lblWithdrawaltxt.text = "Payment made"
            cell.stackViewTransactionFees.isHidden = true
            cell.stackViewWerkulesAmount.isHidden = true
        }else{
            cell.lblWithdrawaltxt.text = "Withdrawal"
            cell.stackViewTransactionFees.isHidden = false
            cell.stackViewWerkulesAmount.isHidden = false
        }
        return cell//UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.arrayOfWithDraw.count > indexPath.row{
            let objHistory = self.arrayOfWithDraw[indexPath.row]
            if let isforjob = objHistory["is_job_payment"] as? Bool{
                if isforjob{
                    return 90.0
                }else{
                    return 150.0
                }
            }else{
                return 150.0
            }
        }
        return 150.0//UITableView.automaticDimension
    }
    
}
