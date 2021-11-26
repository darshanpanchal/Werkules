//
//  ProviderPaymentHistoryViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 04/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class ProviderPaymentHistoryViewController: UIViewController {

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
        self.tableViewHistory.register(UINib.init(nibName: "ProviderPaymentHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "ProviderPaymentHistoryTableViewCell")
        
        //self.tableViewHistory.register(UINib.init(nibName: "PayementHistoryDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "PayementHistoryDetailTableViewCell")
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
        print(dict)
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kProviderGeneralPaymentHistory , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
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
        print(dict)
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kProviderJOBPaymentHistory , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
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
    func pushToFileDisputeViewController(response:[String:Any]){
           DispatchQueue.main.async {
               if let filedisputeviewcontroller = UIStoryboard.profile.instantiateViewController(withIdentifier: "FileDisputeViewController") as? FileDisputeViewController{
                   self.view.endEditing(true)
                if let customerDetail  = response["customer"] as? [String:Any],let firstname = customerDetail["firstname"],!(firstname is NSNull),let lastname = customerDetail["lastname"],!(lastname is NSNull){
                                   filedisputeviewcontroller.name = "\(firstname) \(lastname)"
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
extension ProviderPaymentHistoryViewController:UITableViewDelegate, UITableViewDataSource,ProviderPaymentHistoryDelegate{
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isForJOBSpecific{
            self.lblNoPaymentHistoryFound.isHidden = self.arrayofjobpaymentHistory.count > 0
            return self.arrayofjobpaymentHistory.count
        }else{
            self.lblNoPaymentHistoryFound.isHidden = self.arrayofgeneralpaymentHistory.count > 0
            return self.arrayofgeneralpaymentHistory.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderPaymentHistoryTableViewCell", for: indexPath) as! ProviderPaymentHistoryTableViewCell
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "PayementHistoryDetailTableViewCell", for: indexPath) as! PayementHistoryDetailTableViewCell
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
                if let str = objJOBHistory["is_promocode_apply"],let bool = "\(str)".bool{
                    cell.viewPromotion.isHidden = !bool
                    cell.viewPromotion1.isHidden = !bool
                    cell.viewPromotion2.isHidden = !bool
                    
                    if let objpromotion = objJOBHistory["promotion"] as? [String:Any]{
                      if let type = objpromotion["type"]{
                            var promotiondetail = "Werkules Promotion Fee"
                            if "\(type)" == "percentage"{
                                if let amount = objpromotion["customer_price"],let fees = objpromotion["werkules_fee"]{
                                    
                                  cell.lblPromotionDiscountDetail.text = "Promotion Discount Applied -\(amount)%:"
                                    
                                  promotiondetail = "Werkules Promotion Fee \(fees)%:"
                                }
                            }else{
                                if let amount = objpromotion["customer_price"],let fees = objpromotion["werkules_fee"]{
                                    
                                    cell.lblPromotionDiscountDetail.text = "Promotion Discount Applied -\(CurrencyFormate.Currency(value: amount  as! Double)):"
                                    promotiondetail = "Werkules Promotion Fee \((CurrencyFormate.Currency(value: fees as! Double))):"
                                }
                            }
                        if let jobdetail = objJOBHistory["job"] as? [String:Any]{
                            if let amount = jobdetail["price"]{
                                if let pi: Double = Double("\(amount)"){
                                let updateValue = String(format:"%.2f", pi)
                                    cell.lblFullAmountOnPromotion.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                                }}
                        if let amount = jobdetail["saving_price"]{
                            if let pi: Double = Double("\(amount)"){
                                let updateValue = String(format:"%.2f", pi)
                                cell.lblDiscountAmountOnPromotion.text = "-\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                        }
                        }
                            }
                            cell.lblPromotionName.text = "\(promotiondetail)"
                        }
                        
                    }
                }
                    if let jobdetail  = objJOBHistory["job"] as? [String:Any],let jobtitle = jobdetail["title"],!(jobtitle is NSNull){
                       cell.lblJOBTitle.text = "\(jobtitle)"
                    }else{
                       cell.lblJOBTitle.text = ""
                    }
                    if let price  = objJOBHistory["final_price"],!(price is NSNull){
                        if let pi: Double = Double("\(price)"){
                            let updateValue = String(format:"%.2f", pi)
                            cell.lblJOBPrice.text = "\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                        }
                    }else{
                       cell.lblJOBPrice.text = "$0.0"
                    }
                    if let price  = objJOBHistory["provider_amount"],!(price is NSNull){
                        if let pi: Double = Double("\(price)"){
                            let updateValue = String(format:"%.2f", pi)
                            cell.lblAmountAvailable.text = "\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                        }
                    }else{
                       cell.lblAmountAvailable.text = "$0.0"
                    } //deduction_amount
                    /*if let price  = objJOBHistory["deduction_amount"],!(price is NSNull){
                       cell.lblDeductionAmountAvailable.text = "$ \(price)"
                    }else{
                       cell.lblDeductionAmountAvailable.text = "$ 0.0"
                    }*/
                        if let price  = objJOBHistory["transaction_fee"],!(price is NSNull){
                            if let pi: Double = Double("\(price)"){
                                let updateValue = String(format:"%.2f", pi)
                               cell.lblTransactionFees.text = "-\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                            }
                            }else{
                               cell.lblTransactionFees.text = "-$0.0"
                            }
                if let price  = objJOBHistory["affiliate_fee"],!(price is NSNull){
                    if let pi: Double = Double("\(price)"){
                                                   let updateValue = String(format:"%.2f", pi)
                              cell.lblAffilliateAmount.text = "-\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                    }
                           }else{
                              cell.lblAffilliateAmount.text = "-$0.0"
                           }
                        if let price  = objJOBHistory["promotion_fee"],!(price is NSNull){
                            if let pi: Double = Double("\(price)"){
                            let updateValue = String(format:"%.2f", pi)
                            cell.lblPromotionAmount.text = "-\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                            }
                        }else{
                         cell.lblPromotionAmount.text = "-$0.0"
                        }
                             if let price  = objJOBHistory["werkules_fee"],!(price is NSNull){
                                if let pi: Double = Double("\(price)"){
                                            let updateValue = String(format:"%.2f", pi)
                                               cell.lblWerkulesFees.text = "-\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                                }
                                            }else{
                                               cell.lblWerkulesFees.text = "-$0.0"
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
                    if let customerDetail  = objJOBHistory["customer"] as? [String:Any],let firstname = customerDetail["firstname"],!(firstname is NSNull),let lastname = customerDetail["lastname"],!(lastname is NSNull){
                       cell.lblJOBFromToPaid.text = "\(firstname) \(lastname)"
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
                            if let str = objGeneralHistory["is_promocode_apply"],let bool = "\(str)".bool{
                                   cell.viewPromotion.isHidden = !bool
                                cell.viewPromotion1.isHidden = !bool
                                cell.viewPromotion2.isHidden = !bool
                                if let objpromotion = objGeneralHistory["promotion"] as? [String:Any]{
                                                 if let type = objpromotion["type"]{
                                                         var promotiondetail = "Werkules Promotion Fee"
                                                         if "\(type)" == "percentage"{
                                                             if let amount = objpromotion["customer_price"],let fees = objpromotion["werkules_fee"]{
                                                               cell.lblPromotionDiscountDetail.text = "Promotion Discount Applied -\(amount)%:"
                                                                 
                                                               promotiondetail = "Werkules Promotion Fee \(fees)%:"
                                                             }
                                                         }else{
                                                             if let amount = objpromotion["customer_price"],let fees = objpromotion["werkules_fee"]{
                                                                cell.lblPromotionDiscountDetail.text = "Promotion Discount Applied -$\(amount):"
                                                                promotiondetail = "Werkules Promotion Fee \(CurrencyFormate.Currency(value:fees as! Double)):"
                                                             }
                                                         }
                                                        if let jobdetail = objGeneralHistory["job"] as? [String:Any]{
                                                             if let amount = jobdetail["price"]{
                                                                 if let pi: Double = Double("\(amount)"){
                                                                 let updateValue = String(format:"%.2f", pi)
                                                                 cell.lblFullAmountOnPromotion.text = "\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                                                                 }}
                                                         if let amount = jobdetail["saving_price"]{
                                                             if let pi: Double = Double("\(amount)"){
                                                                 let updateValue = String(format:"%.2f", pi)
                                                                 cell.lblDiscountAmountOnPromotion.text = "-\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                                                         }
                                                         }
                                                             }
                                                         cell.lblPromotionName.text = "\(promotiondetail)"
                                                     }
                                                     
                                                 }
                                
                               }
                           if let price  = objGeneralHistory["final_price"],!(price is NSNull){
                            if let pi: Double = Double("\(price)"){
                                                let updateValue = String(format:"%.2f", pi)
                              cell.lblJOBPrice.text = "\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                            }
                           }else{
                              cell.lblJOBPrice.text = "$0.0"
                           }
                if let price  = objGeneralHistory["promotion_fee"],!(price is NSNull){
                    if let pi: Double = Double("\(price)"){
                                                    let updateValue = String(format:"%.2f", pi)
                            cell.lblPromotionAmount.text = "-\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                    }
                }else{
                 cell.lblPromotionAmount.text = "-$0.0"
                }
                if let price  = objGeneralHistory["affiliate_fee"],!(price is NSNull){
                    if let pi: Double = Double("\(price)"){
                    let updateValue = String(format:"%.2f", pi)
                   cell.lblAffilliateAmount.text = "-\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                    }
                }else{
                   cell.lblAffilliateAmount.text = "-$0.0"
                }
                            if let price  = objGeneralHistory["provider_amount"],!(price is NSNull){
                                if let pi: Double = Double("\(price)"){
                                                   let updateValue = String(format:"%.2f", pi)
                               cell.lblAmountAvailable.text = "\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                                }
                            }else{
                               cell.lblAmountAvailable.text = "$0.0"
                            }
                /*if let price  = objGeneralHistory["deduction_amount"],!(price is NSNull){
                   cell.lblDeductionAmountAvailable.text = "$ \(price)"
                }else{
                   cell.lblDeductionAmountAvailable.text = "$ 0.0"
                } */
                        if let price  = objGeneralHistory["transaction_fee"],!(price is NSNull){
                            if let pi: Double = Double("\(price)"){
                                        let updateValue = String(format:"%.2f", pi)
                                       cell.lblTransactionFees.text = "-\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                            }
                                    }else{
                                       cell.lblTransactionFees.text = "-$0.0"
                                    }
                        if let price  = objGeneralHistory["werkules_fee"],!(price is NSNull){
                            if let pi: Double = Double("\(price)"){
                                        let updateValue = String(format:"%.2f", pi)
                                       cell.lblWerkulesFees.text = "-\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                            }
                                    }else{
                                       cell.lblWerkulesFees.text = "-$0.0"
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
                           if let customerDetail  = objGeneralHistory["customer"] as? [String:Any],let firstname = customerDetail["firstname"],!(firstname is NSNull),let lastname = customerDetail["lastname"],!(lastname is NSNull){
                              cell.lblJOBFromToPaid.text = "\(firstname) \(lastname)"
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
}
