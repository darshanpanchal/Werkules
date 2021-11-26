//
//  CustommerPaymentHistoryViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 04/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class CustommerPaymentHistoryViewController: UIViewController {

    var isForJOBSpecific:Bool = false
    
    var jobId = ""
    var isLoadMore:Bool = false
    var currentPage:Int = 1
    var fetchPageLimit:Int = 10
    
    
    @IBOutlet weak var tableViewHistory:UITableView!
    
    @IBOutlet weak var lblNoPaymentHistoryFound:UILabel!
    
    @IBOutlet weak var containerOne:UIView!
    @IBOutlet weak var containerTwo:UIView!
    
    
    @IBOutlet weak var lblTotalPaymentMadeAmount:UILabel!
       @IBOutlet weak var lblPendingPaymentAmount:UILabel!
       @IBOutlet weak var lblPendingPaymentCount:UILabel!
    
    var arrayofgeneralpaymentHistory:[[String:Any]] = []
    var arrayofjobpaymentHistory:[[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //setup
        self.setup()
        
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //fetch payment history
        if self.isForJOBSpecific{
            self.containerOne.isHidden = true
            self.containerTwo.isHidden = true
            self.getjobPaymentHistoryAPIRequestWith()
        }else{
            self.containerOne.isHidden = false
            self.containerTwo.isHidden = false
            self.getGeneralPaymentHistoryAPIRequestWith()
        }
    }
    // MARK: - User Methods
    func setup(){
        self.containerOne.layer.cornerRadius = 0.0
              self.containerOne.layer.borderColor = UIColor.black.cgColor
              self.containerOne.layer.borderWidth = 0.7
              self.containerOne.clipsToBounds = true
        
        self.containerTwo.layer.cornerRadius = 0.0
                    self.containerTwo.layer.borderColor = UIColor.black.cgColor
                    self.containerTwo.layer.borderWidth = 0.7
                    self.containerTwo.clipsToBounds = true
        
        self.configureTableView()
    }
    func configureTableView(){
         self.tableViewHistory.register(UINib.init(nibName: "PayementHistoryDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "PayementHistoryDetailTableViewCell")
         self.tableViewHistory.showsVerticalScrollIndicator = false
         self.tableViewHistory.delegate = self
         self.tableViewHistory.dataSource = self
         self.tableViewHistory.rowHeight = UITableView.automaticDimension
         self.tableViewHistory.estimatedRowHeight = 180.0
         self.tableViewHistory.tableFooterView = UIView()
         self.tableViewHistory.tableHeaderView = UIView()
         self.tableViewHistory.reloadData()
     }
     // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
              self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonPushToPendingPayment(sender:UIButton){
        self.pushToPaymentPendingHistroyController()
    }
    // MARK: - API Request
    //GET GENERAL PAYMENT HISTORY
    func getGeneralPaymentHistoryAPIRequestWith(){
        var dict:[String:Any] = [:]
        dict["limit"] = "\(fetchPageLimit)"
        dict["page"] = "\(self.currentPage)"
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCustomerGeneralPaymentHistory , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
              if let success = responseSuccess as? [String:Any],let array = success["success_data"] as? [[String:Any]]{
                            if self.currentPage == 1{
                                   self.arrayofgeneralpaymentHistory.removeAll()
                             }
                            self.isLoadMore = array.count > 0
                            for history in array{
                              self.arrayofgeneralpaymentHistory.append(history)
                            }
                            DispatchQueue.main.async {
                               print(array)
                                if let value = success["total_payment_made"]{
                                if let pi: Double = Double("\(value)"){
                                    let updateValue = String(format:"%.2f", pi)
                                    self.lblTotalPaymentMadeAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                                }
                                }
                                if let value = success["pending_amount"]{
                                    if let pi: Double = Double("\(value)"){
                                let updateValue = String(format:"%.2f", pi)
                                    self.lblPendingPaymentAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                                }
                                }
                                if let value = success["total_pending_count"]{
                                    self.lblPendingPaymentCount.text = "\(value)"
                                }
                                
                                
                                
                                 self.tableViewHistory.reloadData()
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
    //GET JOB PAYMENT HISTORY
    func getjobPaymentHistoryAPIRequestWith(){
            var dict:[String:Any] = [:]
            dict["limit"] = "\(fetchPageLimit)"
            dict["page"] = "\(self.currentPage)"
           dict["job_id"] = "\(self.jobId)"
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCustomerJOBPaymentHistory , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
              if let success = responseSuccess as? [String:Any],let array = success["success_data"] as? [[String:Any]]{
                           if self.currentPage == 1{
                                   self.arrayofjobpaymentHistory.removeAll()
                             }
                              self.isLoadMore = array.count > 0
                                for history in array{
                                     self.arrayofjobpaymentHistory.append(history)
                                   }
                            DispatchQueue.main.async {
                               print(array)
                                if let value = success["total_payment_made"]{
                                if let pi: Double = Double("\(value)"){
                                    let updateValue = String(format:"%.2f", pi)
                                    self.lblTotalPaymentMadeAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                                }
                                }
                                if let value = success["pending_amount"]{
                                    if let pi: Double = Double("\(value)"){
                                let updateValue = String(format:"%.2f", pi)
                                    self.lblPendingPaymentAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                                }
                                }
                                if let value = success["total_pending_count"]{
                                 self.lblPendingPaymentCount.text = "Pending Payments\n\(value)"
                                }
                                 self.tableViewHistory.reloadData()
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
    //Push to pending payment history
    func pushToPaymentPendingHistroyController(){
        DispatchQueue.main.async {
            if let pendingPaymentViewController = UIStoryboard.activity.instantiateViewController(withIdentifier: "CustomerPendingPaymentViewController") as? CustomerPendingPaymentViewController{
                if let amount =  self.lblPendingPaymentAmount.text{
                                   pendingPaymentViewController.paymentAmount = "\(amount)"
                               }
                               if let count =  self.lblPendingPaymentCount.text{
                                   pendingPaymentViewController.paymentCount = "\(count)"
                               }
                self.view.endEditing(true)
                self.navigationController?.pushViewController(pendingPaymentViewController, animated: true)
            }
        }
    }

}
extension CustommerPaymentHistoryViewController:UITableViewDelegate, UITableViewDataSource, CustomerPaymentHistoryDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isForJOBSpecific{
            self.lblNoPaymentHistoryFound.isHidden = self.arrayofjobpaymentHistory.count > 0
            return self.arrayofjobpaymentHistory.count
        }else{
            self.lblNoPaymentHistoryFound.isHidden = self.arrayofgeneralpaymentHistory.count > 0
            return self.arrayofgeneralpaymentHistory.count
        }
        
    }
    func buttonfileDisputeSelected(index: Int) {
        if self.isForJOBSpecific{
            if self.arrayofjobpaymentHistory.count > index{
                let objJOBHistory = self.arrayofjobpaymentHistory[index]
                self.pushToFileDisputeViewController(response: objJOBHistory)
            }
         
        }else{
            if self.arrayofgeneralpaymentHistory.count > index{
                let objJOBHistory = self.arrayofgeneralpaymentHistory[index]
                self.pushToFileDisputeViewController(response: objJOBHistory)
            }
            
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
        let cell = tableView.dequeueReusableCell(withIdentifier: "PayementHistoryDetailTableViewCell", for: indexPath) as! PayementHistoryDetailTableViewCell
        cell.tag = indexPath.row
        cell.viewTransactionFees.isHidden = true
        cell.viewWerkulesAmount.isHidden = true
        cell.viewAmountAvailable.isHidden = true
        cell.delegate = self
        cell.tag = indexPath.row
        
        if self.isForJOBSpecific{
            if self.arrayofjobpaymentHistory.count > indexPath.row{
                
                let objJOBHistory = self.arrayofjobpaymentHistory[indexPath.row]
               
                if let isreported = objJOBHistory["is_transaction_reported"],let isreportedbool = "\(isreported)".bool{
                    if isreportedbool{
                        cell.buttonFileDispute.tintColor = UIColor.init(hex: "#F21600")
                    }else{
                        cell.buttonFileDispute.tintColor = UIColor.init(hex: "#38B5A3")
                    }
                }else{
                    cell.buttonFileDispute.tintColor = UIColor.init(hex: "#38B5A3")
                }
                if let jobdetail  = objJOBHistory["job"] as? [String:Any],let jobtitle = jobdetail["title"],!(jobtitle is NSNull){
                   cell.lblJOBTitle.text = "\(jobtitle)"
                }else{
                   cell.lblJOBTitle.text = ""
                }
                if let price  = objJOBHistory["final_price"],!(price is NSNull){
                 if let pi: Double = Double("\(price)"){
                   let updateValue = String(format:"%.2f", pi)
                    cell.lblJOBPrice.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                 }
                }else{
                   cell.lblJOBPrice.text = "$0.0"
                }
                if let price  = objJOBHistory["provider_amount"],!(price is NSNull){
                    if let pi: Double = Double("\(price)"){
                    let updateValue = String(format:"%.2f", pi)
                   cell.lblAmountAvailable.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                    }
                }else{
                   cell.lblAmountAvailable.text = "$0.0"
                }
                if let value =  objJOBHistory["promotion"] as? [String:Any]{
                    if value.count > 0{
                        cell.viewPromotionPriceContainer.isHidden = false
                    }else{
                        cell.viewPromotionPriceContainer.isHidden = true
                    }
                    if let amountvalue =  value["customer_discount"]{
                    if let type = value["type"]{
                          if "\(type)" == "amount"{
                              if let pi: Double = Double("\(amountvalue)"){
                                  let updatedvalue = String(format:"%.2f", pi)
                                  cell.lblPromotionOfferAmount.text = CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)//"$\(updatedvalue)"
                              }
                          }else{
                              cell.lblPromotionOfferAmount.text = "\(amountvalue)%"
                          }
                     }
                    }
                }else{
                    cell.viewPromotionPriceContainer.isHidden = true
                }
                
                /*
                if let price  = objJOBHistory["deduction_amount"],!(price is NSNull){
                   cell.lblDeductionAmountAvailable.text = "$ \(price)"
                }else{
                   cell.lblDeductionAmountAvailable.text = "$ 0.0"
                }*/
                if let price  = objJOBHistory["transaction_fee"],!(price is NSNull){
                            if let pi: Double = Double("\(price)"){
                            let updateValue = String(format:"%.2f", pi)
                                cell.lblTransactionFees.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                            }
                               }else{
                                  cell.lblTransactionFees.text = "$0.0"
                               }
                if let price  = objJOBHistory["werkules_fee"],!(price is NSNull){
                            if let pi: Double = Double("\(price)"){
                                            let updateValue = String(format:"%.2f", pi)
                                  cell.lblWerkulesFees.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                            }
                            }else{
                                  cell.lblWerkulesFees.text = "$0.0"
                               }
                if let objId  = objJOBHistory["id"],!(objId is NSNull){
                   cell.lblJOBID.text = "\(objId)"
                }else{
                   cell.lblJOBID.text = ""
                }
                
                if let paymentDate  = objJOBHistory["payment_date"],!(paymentDate is NSNull){
                   cell.lblJOBDate.text = "\(paymentDate)".changeDateFormat
                }else{
                    cell.lblJOBDate.text = ""
                }
                if let providerDetail  = objJOBHistory["provider"] as? [String:Any],let name = providerDetail["business_name"],!(name is NSNull){
                   cell.lblJOBFromToPaid.text = "\(name)"
                }else{
                    cell.lblJOBFromToPaid.text = ""
                }
            }
            if indexPath.row+1 == self.arrayofjobpaymentHistory.count, self.isLoadMore{ //last index
                 DispatchQueue.global(qos: .background).async {
                     self.currentPage += 1
                     self.getjobPaymentHistoryAPIRequestWith()
                 }
             }
        }else{
            if self.arrayofgeneralpaymentHistory.count > indexPath.row{
                let objGeneralHistory = self.arrayofgeneralpaymentHistory[indexPath.row]
                    
                if let jobdetail  = objGeneralHistory["job"] as? [String:Any],let jobtitle = jobdetail["title"],!(jobtitle is NSNull){
                   cell.lblJOBTitle.text = "\(jobtitle)"
                }else{
                   cell.lblJOBTitle.text = ""
                }
                if let price  = objGeneralHistory["final_price"],!(price is NSNull){
                    if let pi: Double = Double("\(price)"){
                    let updateValue = String(format:"%.2f", pi)
                        cell.lblJOBPrice.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                    }
                }else{
                   cell.lblJOBPrice.text = "$0.0"
                }
                if let price  = objGeneralHistory["provider_amount"],!(price is NSNull){
                   cell.lblAmountAvailable.text = "$\(price)"
                }else{
                   cell.lblAmountAvailable.text = "$0.0"
                }
                /*if let price  = objGeneralHistory["deduction_amount"],!(price is NSNull){
                   cell.lblDeductionAmountAvailable.text = "$ \(price)"
                }else{
                   cell.lblDeductionAmountAvailable.text = "$ 0.0"
                }*/
                if let price  = objGeneralHistory["transaction_fee"],!(price is NSNull){
                                               cell.lblTransactionFees.text = "$\(price)"
                                            }else{
                                               cell.lblTransactionFees.text = "$0.0"
                                            }
                             if let price  = objGeneralHistory["werkules_fee"],!(price is NSNull){
                                               cell.lblWerkulesFees.text = "$\(price)"
                                            }else{
                                               cell.lblWerkulesFees.text = "$0.0"
                                            }
                if let objId  = objGeneralHistory["id"],!(objId is NSNull){
                   cell.lblJOBID.text = "\(objId)"
                }else{
                   cell.lblJOBID.text = ""
                }
                if let paymentDate  = objGeneralHistory["payment_date"],!(paymentDate is NSNull){
                   cell.lblJOBDate.text = "\(paymentDate)".changeDateFormat
                }else{
                    cell.lblJOBDate.text = ""
                }
                if let providerDetail  = objGeneralHistory["provider"] as? [String:Any],let name = providerDetail["business_name"],!(name is NSNull){
                   cell.lblJOBFromToPaid.text = "\(name)"
                }else{
                    cell.lblJOBFromToPaid.text = ""
                }
                
                // Logic for Flag color //PRIYAL
                if let isreported = objGeneralHistory["is_transaction_reported"],let isreportedbool = "\(isreported)".bool{
                    if isreportedbool{
                        cell.buttonFileDispute.tintColor = UIColor.init(hex: "#F21600")
                    }else{
                        cell.buttonFileDispute.tintColor = UIColor.init(hex: "#38B5A3")
                    }
                }else{
                    cell.buttonFileDispute.tintColor = UIColor.init(hex: "#38B5A3")
                }
                
            }
            if indexPath.row+1 == self.arrayofgeneralpaymentHistory.count, self.isLoadMore{ //last index
                    DispatchQueue.global(qos: .background).async {
                        self.currentPage += 1
                        self.getGeneralPaymentHistoryAPIRequestWith()
                    }
                }
        }
       
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
     }
    
    func pushToFileDisputeViewController(response:[String:Any]){
        DispatchQueue.main.async {
            if let filedisputeviewcontroller = UIStoryboard.profile.instantiateViewController(withIdentifier: "FileDisputeViewController") as? FileDisputeViewController{
                self.view.endEditing(true)
                if let providerDetail  = response["provider"] as? [String:Any],let name = providerDetail["business_name"],!(name is NSNull){
                    filedisputeviewcontroller.name = "\(name)"
                }
                if let id = response["id"]{
                                      filedisputeviewcontroller.id = "\(id)"
                                  }
                filedisputeviewcontroller.disputeRequest = response
                self.navigationController?.pushViewController(filedisputeviewcontroller, animated: true)
            }
        }
        
    }
}
