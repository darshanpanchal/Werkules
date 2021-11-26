//
//  ViewPaymentViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 05/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class ViewPaymentViewController: UIViewController {

    
    @IBOutlet weak var lblPaymentFor:UILabel!
    @IBOutlet weak var lblPaymentDate:UILabel!
    @IBOutlet weak var lblPaymentID:UILabel!
    @IBOutlet weak var lblPaymentPaidAmount:UILabel!
    @IBOutlet weak var lblPaymentRemaingAmount:UILabel!
    @IBOutlet weak var lblPaymentTotalAmount:UILabel!
    
    @IBOutlet weak var tableViewpaymenyHistory:UITableView!
    @IBOutlet weak var buttonBusinessEarning:UIButton!
    
    @IBOutlet weak var buttonProvideRefund:UIButton!
    @IBOutlet weak var shadowrovideRefund:ShadowBackgroundView!
    @IBOutlet weak var viewProvideRefund:UIView!
    @IBOutlet weak var lblCustomerName:UILabel!
    
    @IBOutlet weak var ViewPromotion:UIView!
    @IBOutlet weak var lblPromotionDetail:UILabel!
    @IBOutlet weak var lblPromotionAmount:UILabel!
    
    var job_id =  ""
    var isLoadMore:Bool = false
    var currentPage:Int = 1
    var fetchPageLimit:Int = 10
    var arrayofjobpaymentHistory:[[String:Any]] = []
    
    var totalPaidAmount = "0"
    
    var customerName:String = ""
    
    @IBOutlet weak var viewOrderSummary:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.viewOrderSummary.layer.cornerRadius = 0.0
                          self.viewOrderSummary.layer.borderColor = UIColor.black.cgColor
                          self.viewOrderSummary.layer.borderWidth = 0.7
                          self.viewOrderSummary.clipsToBounds = true
            
            self.viewProvideRefund.layer.cornerRadius = 5.0
            self.viewProvideRefund.clipsToBounds = true
            self.shadowrovideRefund.rounding = 5.0
            self.shadowrovideRefund.layoutSubviews()
        }
        
        let underlineSeeDetail = NSAttributedString(string: "Business Earnings",
                                                                        attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
              self.buttonBusinessEarning.titleLabel?.attributedText = underlineSeeDetail
        
        self.configureTableView()
        if self.customerName.count > 0{
            self.lblCustomerName.text = "\(self.customerName)"
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.
        self.getjobPaymentHistoryAPIRequestWith()
    }
    func configureTableView(){
        
        //self.tableViewpaymenyHistory.register(UINib.init(nibName: "PayementHistoryDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "PayementHistoryDetailTableViewCell")
        self.tableViewpaymenyHistory.register(UINib.init(nibName: "ProviderPaymentHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "ProviderPaymentHistoryTableViewCell")
        self.tableViewpaymenyHistory.showsVerticalScrollIndicator = false
        self.tableViewpaymenyHistory.delegate = self
        self.tableViewpaymenyHistory.dataSource = self
        self.tableViewpaymenyHistory.rowHeight = UITableView.automaticDimension
        self.tableViewpaymenyHistory.estimatedRowHeight = 180.0
        self.tableViewpaymenyHistory.tableFooterView = UIView()
        self.tableViewpaymenyHistory.tableHeaderView = UIView()
        self.tableViewpaymenyHistory.reloadData()
     }
    
    // MARK: - API Request
    //GET JOB PAYMENT HISTORY
       func getjobPaymentHistoryAPIRequestWith(){
               var dict:[String:Any] = [:]
        dict["limit"] = "\(self.fetchPageLimit)"
               dict["page"] = "\(self.currentPage)"
              dict["job_id"] = "\(self.job_id)"
           print(dict)
           APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kProviderJOBPaymentHistory , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            print(responseSuccess)
                                      
            DispatchQueue.main.async {
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
                                          self.tableViewpaymenyHistory.reloadData()
                                     }
                    
                    
                    
                                     if let job_name = success["job_name"],!(job_name is NSNull){
                                         self.lblPaymentFor.text = "\(job_name)"
                                     }else{
                                         self.lblPaymentFor.text = ""
                                     }
                                    /*if let paymentdate = success["last_payment_date"],!(paymentdate is NSNull){
                                        self.lblPaymentDate.text = "\(paymentdate)".changeDateFormat
                                    }else{
                                        self.lblPaymentDate.text = "none"
                                    }
                                    if let transactionid = success["last_transaction_id"],!(transactionid is NSNull){
                                      self.lblPaymentID.text = "\(transactionid)"
                                    }else{
                                       self.lblPaymentID.text = "none"
                                    }*/
                                    if let total_paid_amount = success["total_paid_amount"],!(total_paid_amount is NSNull){
                                        self.totalPaidAmount = "\(total_paid_amount)"
                                        if let pi: Double = Double("\(total_paid_amount)"){
                                            let updateValue = String(format:"%.2f", pi)
                                            self.lblPaymentPaidAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                                        }
                                    }else{
                                        self.totalPaidAmount = "0"
                                        self.lblPaymentPaidAmount.text = "$0.0"
                                    }
                                    if let total_remaining_amount = success["total_remaining_amount"],!(total_remaining_amount is NSNull){
                                        if let pi: Double = Double("\(total_remaining_amount)"){
                                            let updateValue = String(format:"%.2f", pi)
                                            self.lblPaymentRemaingAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                                        }
                                    }else{
                                        self.lblPaymentRemaingAmount.text = "$0.0"
                                    }
                                    if let total_amount = success["total_amount"],!(total_amount is NSNull){
                                        if let pi: Double = Double("\(total_amount)"){
                                            let updateValue = String(format:"%.2f", pi)
                                            self.lblPaymentTotalAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                                        }
                                    }else{
                                        self.lblPaymentTotalAmount.text = "$0.0"
                                    }
                                    if let objpromotion = success["promotion"] as? [String:Any]{
                                        self.ViewPromotion.isHidden = false
                                      if let type = objpromotion["type"]{
                                            if "\(type)" == "percentage"{
                                                if let amount = objpromotion["customer_price"]{
                                                    self.lblPromotionDetail.text = "Promotion Discount Applied -\(amount)%:"
                                                }
                                            }else{
                                                if let amount = objpromotion["customer_price"]{
                                                     self.lblPromotionDetail.text = "Promotion Discount Applied -$\(amount):"
                                                }
                                            }
                                        }
                                        if let amount =  success["saving_price"]{
                                            if let pi: Double = Double("\(amount)"){
                                              let updateValue = String(format:"%.2f", pi)
                                              self.lblPromotionAmount.text = "-\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"
                                          }
                                        }
                                        
                                    }else{
                                        self.ViewPromotion.isHidden = true
                                    }
                        
                            }else{
                                DispatchQueue.main.async {
                                    SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
    //Push to Business Earnings
    func pushToMyBusinessEarningViewController(){
        if let viewMyBusinessEarningViewController  = UIStoryboard.activity.instantiateViewController(withIdentifier: "MyBusinessEarningViewController") as? MyBusinessEarningViewController{
            self.navigationController?.pushViewController(viewMyBusinessEarningViewController, animated: true)
        }
    }
    //Push to provider refund screen
    func pushToProvideRefundViewController(){
        if let paidAmount = Int.init("\(self.totalPaidAmount)"){
            if paidAmount > 0{
                if let viewProvideRefundViewController  = UIStoryboard.activity.instantiateViewController(withIdentifier: "ProvideRefundViewController") as? ProvideRefundViewController{
                     viewProvideRefundViewController.earningAvailable = "\(self.totalPaidAmount)"
                    self.navigationController?.pushViewController(viewProvideRefundViewController, animated: true)
                }
            }else{
                DispatchQueue.main.async {
                    SAAlertBar.show(.error, message:"No Fund Available to refund.".localizedLowercase)
                }
            }
        }
           
       }
    func pushToFileDisputeViewController(response:[String:Any]){
           DispatchQueue.main.async {
               if let filedisputeviewcontroller = UIStoryboard.profile.instantiateViewController(withIdentifier: "FileDisputeViewController") as? FileDisputeViewController{
                   self.view.endEditing(true)
                if let customerDetail  = response["customer"] as? [String:Any],let firstname = customerDetail["firstname"],!(firstname is NSNull),let lastname = customerDetail["lastname"],!(lastname is NSNull){
                                   filedisputeviewcontroller.name = "\(firstname) \(lastname)"
                    if let id = response["id"]{
                        filedisputeviewcontroller.id = "\(id)"
                    }
                }
                   filedisputeviewcontroller.disputeRequest = response
                   self.navigationController?.pushViewController(filedisputeviewcontroller, animated: true)
               }
           }
           
       }
    
    // MARK: - Selector Methods
    @IBAction func buttonProviderRefundsSelector(sender:UIButton){
        self.pushToProvideRefundViewController()
    }
    @IBAction func buttonBusinessEarnigsSelector(sender:UIButton){
        self.pushToMyBusinessEarningViewController()
    }
    @IBAction func buttonbackSelector(sender:UIButton){
          self.navigationController?.popViewController(animated: true)
      }
    

}
extension ViewPaymentViewController:UITableViewDelegate, UITableViewDataSource,ProviderPaymentHistoryDelegate{
    
    func buttonfileDisputeSelected(index: Int) {
                if self.arrayofjobpaymentHistory.count > index{
                    let objJOBHistory = self.arrayofjobpaymentHistory[index]
                    self.pushToFileDisputeViewController(response: objJOBHistory)
                }
           
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.arrayofjobpaymentHistory.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderPaymentHistoryTableViewCell", for: indexPath) as! ProviderPaymentHistoryTableViewCell
        //let cell = tableView.dequeueReusableCell(withIdentifier: "PayementHistoryDetailTableViewCell", for: indexPath) as! PayementHistoryDetailTableViewCell
        cell.tag = indexPath.row
        cell.delegate = self
        
            
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
                                        cell.lblPromotionDiscountDetail.text = "Promotion Discount Applied -$\(amount):"
                                        promotiondetail = "Werkules Promotion Fee $\(fees):"
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
                                cell.lblAmountAvailable.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
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
                             if let price  = objJOBHistory["werkules_fee"],!(price is NSNull){
                                if let pi: Double = Double("\(price)"){
                                    let updateValue = String(format:"%.2f", pi)
                                    cell.lblWerkulesFees.text =  "-\(CurrencyFormate.Currency(value: Double(updateValue) ?? 0))"//"-$\(updateValue)"
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
       
       
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
     }
}
