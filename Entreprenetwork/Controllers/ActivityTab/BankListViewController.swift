//
//  BankListViewController.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 24/06/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol BankListViewDelegate {
    func bankDetailBackDelegate()
}

class BankListViewController: UIViewController {

    @IBOutlet fileprivate weak var tableViewList:UITableView!
    
    @IBOutlet fileprivate weak var buttonAddBank:UIButton!
    
    var delegate:BankListViewDelegate?
    
    var arrayOfBank:[[String:Any]] = []
    
    var isWithdrawalMethod: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getBankAccountdetailrequestAPI()
        
        self.setUp()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getBankAccountdetailrequestAPI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    func setUp(){
        //BankDetailTableViewCell
        self.configureTableView()
        self.buttonAddBank.setTitle("Add Bank Details", for: .normal)
        self.buttonAddBank.clipsToBounds = true
        self.buttonAddBank.layer.cornerRadius = 25.0
    }
    func configureTableView(){
        //GroupTableViewCell
                self.tableViewList.register(UINib(nibName: "BankDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "BankDetailTableViewCell")
                // you can change section height based on your needs
                self.tableViewList.delegate = self
                self.tableViewList.dataSource = self
                self.tableViewList.rowHeight = UITableView.automaticDimension
                self.tableViewList.estimatedRowHeight = 250.0
                self.tableViewList.hideHeader()
                self.tableViewList.hideFooter()
                self.tableViewList.separatorStyle = .none
        
//                self.tableViewGroup.scrollEnableIfTableViewContentIsLarger()
                self.tableViewList.reloadData()
    }
    // MARK: - Selector Methods
    @IBAction func buttonbackselector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.bankDetailBackDelegate()
        }
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonAddBankAccountSelector(sender:UIButton){
        if let updateAskingPrice = self.storyboard?.instantiateViewController(withIdentifier: "AddBankDetailViewControllerPopup") as? AddBankDetailViewControllerPopup{
            updateAskingPrice.modalPresentationStyle = .overFullScreen
            updateAskingPrice.delegate = self
            self.present(updateAskingPrice, animated: true, completion: nil)
        }
    }
    // MARK: - API Methods
    func getBankAccountdetailrequestAPI(){
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGETBankAccountList , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [[String:Any]]{
                                  DispatchQueue.main.async {
                                    self.arrayOfBank = arrayOfJOB
                                    self.tableViewList.reloadData()
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
    func deleteBankDetailAPIRequest(id:String){
        var dict:[String:Any] = [:]
        dict["id"] = "\(id)"
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kDeleteBankAccount , parameter: dict as? [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [String]{
                                  DispatchQueue.main.async {
                                    if arrayOfJOB.count > 0{
                                        SAAlertBar.show(.error, message:"\(arrayOfJOB.first!)".localizedLowercase)
                                    }
                                    self.getBankAccountdetailrequestAPI()
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
    func updateCurrentSelectedBankDetail(id:String){
        var dict:[String:Any] = [:]
        dict["id"] = "\(id)"
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kUpdateCurrentSelectedBank , parameter: dict as? [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [String]{
                                  DispatchQueue.main.async {
                                    if arrayOfJOB.count > 0{
                                        //SAAlertBar.show(.error, message:"\(arrayOfJOB.first!)".localizedLowercase)
                                    }
                                    self.getBankAccountdetailrequestAPI()
                                    self.navigationController?.popViewController(animated: true)
                                    
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension BankListViewController:UITableViewDataSource,UITableViewDelegate,BankDetailTableViewCellDelegate,AddBankAccountPopupDelegate{
    func addBankAddedSuccessfully() {
        self.getBankAccountdetailrequestAPI()
    }
    func buttonDeleteBankAccount(index: Int) {
        
        
        if self.arrayOfBank.count > index{
            let alert = UIAlertController(title: AppName, message: "Are you sure you want to delete bank?", preferredStyle: .alert)
             
             alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                 
             }))
             
             alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                let bankdetail = self.arrayOfBank[index]
                if let bankID = bankdetail["id"]{
                    self.deleteBankDetailAPIRequest(id: "\(bankID)")
                }
             }))
           alert.view.tintColor = UIColor.init(hex: "#38B5A3")
             self.present(alert, animated: true, completion: nil)
        }
        
    }
    func buttonSelectBankAccount(index: Int) {
        if self.arrayOfBank.count > index{
            let bankdetail = self.arrayOfBank[index]
            if let bankID = bankdetail["id"]{
                self.updateCurrentSelectedBankDetail(id: "\(bankID)")
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
       
        return self.arrayOfBank.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableViewList.dequeueReusableCell(withIdentifier: "BankDetailTableViewCell") as! BankDetailTableViewCell
          cell.delegate = self
         cell.tag = indexPath.row
        if self.arrayOfBank.count > indexPath.row{
            let bankdetail = self.arrayOfBank[indexPath.row]
            if let name = bankdetail["bank_name"]{
                cell.lblBankName.text = "\(name)"
            }
            if let number = bankdetail["bank_account_last4"]{
                cell.lblBankNumber.text = "\(number)"
            }
            if let isdefault = bankdetail["default_for_currency"]{
                if "\(isdefault)" == "1"{
                    cell.buttonDelete.isHidden = true
                }else{
                    cell.buttonDelete.isHidden = false
                }
            }else{
                cell.buttonDelete.isHidden = false
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.arrayOfBank.count > indexPath.row{
            let bankdetail = self.arrayOfBank[indexPath.row]
            if self.isWithdrawalMethod == true{
                
            }else{
                if let bankID = bankdetail["id"]{
                    self.updateCurrentSelectedBankDetail(id: "\(bankID)")
                }
            }
        }
    }
}
