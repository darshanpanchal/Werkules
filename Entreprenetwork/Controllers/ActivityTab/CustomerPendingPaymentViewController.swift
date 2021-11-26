//
//  CustomerPendingPaymentViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 11/05/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class CustomerPendingPaymentViewController: UIViewController {

    var isLoadMore:Bool = false
    var currentPage:Int = 1
    var fetchPageLimit:Int = 10
    
    @IBOutlet weak var tableViewHistory:UITableView!
    
    @IBOutlet weak var lblNoPaymentHistoryFound:UILabel!

    var arrayofgeneralpaymentHistory:[[String:Any]] = []
    @IBOutlet weak var containerOne:UIView!
    
    @IBOutlet weak var lblPendingPaymentCount:UILabel!
    @IBOutlet weak var lblPendingPaymentAmount:UILabel!
    
    var paymentCount = ""
    var paymentAmount = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if paymentCount.count > 0{
            self.lblPendingPaymentCount.text = "\(paymentCount)"
        }
        if paymentAmount.count > 0{
            self.lblPendingPaymentAmount.text = CurrencyFormate.Currency(value: Double(paymentAmount) ?? 0)//"\(paymentAmount)"
               }
        // Do any additional setup after loading the view.
        self.configureTableView()
        self.containerOne.layer.cornerRadius = 0.0
                   self.containerOne.layer.borderColor = UIColor.black.cgColor
                   self.containerOne.layer.borderWidth = 0.7
                   self.containerOne.clipsToBounds = true
        
        self.getGeneralPaymentHistoryAPIRequestWith()
        
        
    }
    func configureTableView(){
         self.tableViewHistory.register(UINib.init(nibName: "CustomerPendingPaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomerPendingPaymentTableViewCell")
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

    //GET GENERAL PAYMENT HISTORY
    func getGeneralPaymentHistoryAPIRequestWith(){
        var dict:[String:Any] = [:]
        dict["limit"] = "\(fetchPageLimit)"
        dict["page"] = "\(self.currentPage)"
        
        var strSwitch = kCustomerPendingPaymentHistory
                  guard let currentUser = UserDetail.getUserFromUserDefault() else {
                      
                      return
                  }
                  if currentUser.userRoleType == .provider{
                      strSwitch = kProviderPendingPaymentHistory
                  }else if currentUser.userRoleType == .customer{
                      strSwitch = kCustomerPendingPaymentHistory
                  }
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:strSwitch , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
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

}
extension CustomerPendingPaymentViewController:UITableViewDelegate, UITableViewDataSource, CustomerPendingPaymentHistoryDelegate{
    func buttonfileDisputeSelected(index: Int) {
        if self.arrayofgeneralpaymentHistory.count > index{
            let objJOBHistory = self.arrayofgeneralpaymentHistory[index]
           // self.pushToFileDisputeViewController(response: objJOBHistory)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
             self.lblNoPaymentHistoryFound.isHidden = self.arrayofgeneralpaymentHistory.count > 0
             return self.arrayofgeneralpaymentHistory.count
         
     }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerPendingPaymentTableViewCell", for: indexPath) as! CustomerPendingPaymentTableViewCell
        cell.delegate = self
        cell.tag = indexPath.row
        
        
        if self.arrayofgeneralpaymentHistory.count > indexPath.row{
             let objJOBHistory = self.arrayofgeneralpaymentHistory[indexPath.row]
            
            if let paymentDate  = objJOBHistory["accepted_date"],!(paymentDate is NSNull){
                            cell.lblJOBDate.text = "\(paymentDate)".changeDateFormat
                         }else{
                             cell.lblJOBDate.text = ""
                         }
            if let title  = objJOBHistory["id"],!(title is NSNull){
                cell.lblJOBID.text = "\(title)"
            }
            if let title  = objJOBHistory["title"],!(title is NSNull){
                cell.lblJOBTitle.text = "\(title)"
            }
            if let title  = objJOBHistory["remaining_amount"],!(title is NSNull){
                if let pi: Double = Double("\(title)"){
                    let updateValue = String(format:"%.2f", pi)
                    cell.lblJOBPrice.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                       }
            }
            if let provider = objJOBHistory["provider"] as? [String:Any],let name = provider["business_name"]{
                cell.lblJOBFromToPaid.text = "\(name)"
            }
            if let customer = objJOBHistory["user"] as? [String:Any],let firstName = customer["firstname"], let lastName = customer["lastname"]{
                cell.lblJOBFromToPaid.text = "\(firstName) \(lastName)"
            }
            
        }
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
            
            return cell
        }
        if currentUser.userRoleType == .provider{
            cell.lblJOBFromTo.text = "Payment From:"
        }else if currentUser.userRoleType == .customer{
            cell.lblJOBFromTo.text = "Payment To:"
        }else{
            cell.lblJOBFromTo.text = "Payment To:"
        }
        
        if indexPath.row+1 == self.arrayofgeneralpaymentHistory.count, self.isLoadMore{ //last index
                         DispatchQueue.global(qos: .background).async {
                             self.currentPage += 1
                             self.getGeneralPaymentHistoryAPIRequestWith()
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
                filedisputeviewcontroller.disputeRequest = response
                self.navigationController?.pushViewController(filedisputeviewcontroller, animated: true)
            }
        }
        
    }
}
