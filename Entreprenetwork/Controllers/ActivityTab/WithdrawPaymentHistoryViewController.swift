//
//  WithdrawPaymentHistoryViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 07/04/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class WithdrawPaymentHistoryViewController: UIViewController {

    
    //Navigation
    @IBOutlet fileprivate weak var lblTitle:UILabel!
    @IBOutlet fileprivate weak var buttonBack:UIButton!
    
    @IBOutlet fileprivate weak var lblEarningToDate:UILabel!
    @IBOutlet fileprivate weak var lblEarningAvailable:UILabel!
    @IBOutlet fileprivate weak var lblEarningWithDrawToDate:UILabel!
    
    @IBOutlet fileprivate weak var lblEarningToDateAmount:UILabel!
    @IBOutlet fileprivate weak var lblEarningAvailableAmount:UILabel!
    @IBOutlet fileprivate weak var lblEarningWithDrawToDateAmount:UILabel!
    
    //TableView
    @IBOutlet fileprivate weak var tableViewHistory:UITableView!
    @IBOutlet fileprivate weak var lblnowithdraval:UILabel!
    
    //
    var isForBusinessEarningHistory:Bool = false
    
    fileprivate var arrayOfWithDraw:[[String:Any]] = []
    
    var strBusinessEarningToDate = "Total Business Earnings to Date"
    var strBusinessEarningAvailable = "Total Business Earnings Available"
    var strBusinessEarningWithDrawToDate = "Total Business Earnings Withdrawn to Date"
    
    var strGroupEarningToDate = "Total Group Earnings to Date"
    var strGroupEarningAvailable = "Total Group Earnings Available"
    var strGroupEarningWithDrawToDate = "Total Group Earnings Withdrawn to Date"
    
    
    var isLoadMore:Bool = false
    var currentPage:Int = 1
    var fetchPageLimit:Int = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          self.currentPage = 1
          self.isLoadMore = false
      }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fetchMyBusinessEarningDetailAPIRequest()

    }
    // MARK: - Custom Methods
    func setup(){
        if self.isForBusinessEarningHistory{
            self.lblEarningToDate.text = "\(self.strBusinessEarningToDate)"
            self.lblEarningAvailable.text = "\(self.strBusinessEarningAvailable)"
            self.lblEarningWithDrawToDate.text = "\(self.strBusinessEarningWithDrawToDate)"
        }else{
            self.lblEarningToDate.text = "\(self.strGroupEarningToDate)"
            self.lblEarningAvailable.text = "\(self.strGroupEarningAvailable)"
            self.lblEarningWithDrawToDate.text = "\(self.strGroupEarningWithDrawToDate)"
        }
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
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    // MARK: - API Methods
    func fetchMyBusinessEarningDetailAPIRequest(){
        var dict:[String:Any] = [:]
        dict["limit"] = "\(self.fetchPageLimit)"
        dict["page"] = "\(self.currentPage)"
                var apiQuery = ""
              if self.isForBusinessEarningHistory{
                  apiQuery = kGETMYBusinessEarning
              }else{
                  apiQuery = kWithDrawGroupEarningHistory
              }
        
               
                      APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:"\(apiQuery)" , parameter:dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                              
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
                                    if self.isForBusinessEarningHistory{
                                        if let value = successData["total_business_earnings_available"],!(value is NSNull){
                                            if let pi: Double = Double("\(value)"){
                                                let updateValue = String(format:"%.2f", pi)
                                                self.lblEarningAvailableAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0.00)//"$\(updateValue)"
                                            }
                                             
                                           }
                                           if let value = successData["total_business_earnings_to_date"],!(value is NSNull){
                                            if let pi: Double = Double("\(value)"){
                                              let updateValue = String(format:"%.2f", pi)
                                                self.lblEarningToDateAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0.00)//"$\(updateValue)"
                                            }
                                             
                                           }
                                           if let value = successData["total_business_earnings_withdrawn_to_date"],!(value is NSNull){
                                            if let pi: Double = Double("\(value)"){
                                                let updateValue = String(format:"%.2f", pi)
                                                self.lblEarningWithDrawToDateAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0.00)//"$\(updateValue)"
                                            }
                                           }
                                    }else{
                                        if let value = successData["total_group_earnings_available"],!(value is NSNull){
                                            if let pi: Double = Double("\(value)"){
                                                let updateValue = String(format:"%.2f", pi)
                                                self.lblEarningAvailableAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0.00)//"$\(updateValue)"
                                            }
                                        }
                                        if let value = successData["total_group_earnings_to_date"],!(value is NSNull){
                                            if let pi: Double = Double("\(value)"){
                                                let updateValue = String(format:"%.2f", pi)
                                                self.lblEarningToDateAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0.00)//"$\(updateValue)"
                                            }
                                          
                                        }
                                        if let value = successData["total_group_earnings_withdrawn_to_date"],!(value is NSNull){
                                            if let pi: Double = Double("\(value)"){
                                              let updateValue = String(format:"%.2f", pi)
                                                self.lblEarningWithDrawToDateAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0.00)
                                            }
                                        }
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
                                              //   SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
}
extension WithdrawPaymentHistoryViewController:UITableViewDelegate, UITableViewDataSource{
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
class WithdrawPaymentHistoryTableViewCell:UITableViewCell{
    
    @IBOutlet weak var containerView:UIView!
    @IBOutlet weak var shadowBackground:ShadowBackgroundView!
    
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblAmount:UILabel!
    @IBOutlet weak var lblTransactionFees:UILabel!
    @IBOutlet weak var lblWithdrawalAmount:UILabel!
    @IBOutlet weak var lblWithdrawalStatus:UILabel!
    @IBOutlet weak var lblWithdrawaltxt:UILabel!
    
    @IBOutlet weak var stackViewTransactionFees:UIStackView!
    @IBOutlet weak var stackViewWerkulesAmount:UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.containerView.layer.cornerRadius = 15.0
            self.containerView.clipsToBounds = true
            self.shadowBackground.layer.cornerRadius = 15.0
            self.shadowBackground.rounding = 15.0
            self.shadowBackground.layoutIfNeeded()
            //self.shadowBackground.clipsToBounds = false
        }
    }
    
}
