//
//  ReportBugViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 19/01/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift



class ReportBugViewController: UIViewController {

    @IBOutlet weak var lblTitle:UILabel!
    
    @IBOutlet weak var txtTextView:UITextView!
    var placeholderLabel : UILabel!
    var providerId:String = ""
    var customerID:String = ""
    
    @IBOutlet weak var lblProviderCustomername:UILabel!
    @IBOutlet weak var providerNameContainer:UIView!
    @IBOutlet weak var heightOfProviderNameHeihght:NSLayoutConstraint!
    
    var addReportParameters:[String:Any] = [:]
    var isForFileDispute:Bool = false // file dispute if job is there otherwise report problem
    var isForGroupFileDispute:Bool = false // report a problem from group screen
    var providerDetail:ProviderDetail?
    var customerDetail:CustomerDetail?
    
    
    
    //Customer to provider report file dipute while job is in progress
    //job/provider-job-report
    //provder to customer file dispute while job is in progress
    //job/customer-job-report
    
    //direct report problem to provider as customer
    //general-report
    //direct report problem to customer as provider
    //general-report
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
        
        // Do any additional setup after loading the view.
        txtTextView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Write something...."
        placeholderLabel.font = UIFont(name: "Avenir Medium", size: 17)
        placeholderLabel.sizeToFit()
        txtTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (txtTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !txtTextView.text.isEmpty
        
        if self.isForFileDispute{ //show name of proivider or customer
            self.lblTitle.text = "File a Dispute" //if from job detail
            self.heightOfProviderNameHeihght.constant = 70.0
            self.providerNameContainer.isHidden = false
            if let _  = self.providerDetail{ //customer report issue against provider for job
                self.addReportParameters["provider_id"] = "\(self.providerDetail!.id)"
                self.lblProviderCustomername.text = "\(self.providerDetail!.businessName)"
            }else if let _ = self.customerDetail{ //provider report issue against customer for job
                 self.addReportParameters["user_id"] = "\(self.customerDetail!.id)"
                self.lblProviderCustomername.text = "\(self.customerDetail!.firstname) \(self.customerDetail!.lastname)"
            }
            
        }else{
            
            self.lblTitle.text = "Report a Problem" // its from general report customer to provider and provider to customer
            self.heightOfProviderNameHeihght.constant = 0.0
            self.providerNameContainer.isHidden = true
            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                              return
                   }
            if self.isForGroupFileDispute{
                self.addReportParameters = [:]
            }else{
                self.addReportParameters["from_user_type"] = "\(currentUser.userType)"
                
                if let _ = self.providerDetail{ //customer report issue against provider for general
                     self.addReportParameters["to_user_type"] = "provider"
                    self.addReportParameters["to_user_id"] = "\(self.providerDetail!.userID)"
                }else if let _ = self.customerDetail{//provider report issue against customer for general
                   self.addReportParameters["to_user_type"] = "customer"
                    self.addReportParameters["to_user_id"] = "\(self.customerDetail!.id)"
                }
            }
           
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
       IQKeyboardManager.shared.enableAutoToolbar = true
       IQKeyboardManager.shared.enable = true
   }

    // MARK: - Action Methods
    @IBAction func buttonBackSelector(selector:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonAddReportSelector(sender:UIButton){
        if self.isValidData(){
            if self.isForFileDispute{
                if let _ = self.providerDetail{
                    self.addProviderReportAPIRequest()
                }else if let _ = self.customerDetail{
                    self.addCustomerReportAPIRequest()
                }
            }else {
                if self.isForGroupFileDispute{
                    self.addMyGroupReportAPIRequest()
                }else{
                    self.addCustomerProviderGenralReportAPIRequest()
                }
                
            }
            
        }
    }
    // MARK: - API request methods
    func addMyGroupReportAPIRequest(){
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString: kAddMyGroupReport, parameter: self.addReportParameters as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
                         DispatchQueue.main.async {
                             ExternalClass.HideProgress()
                         }
                         if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                                 DispatchQueue.main.async {
                                      SAAlertBar.show(.error, message:"Report added successfully.".localizedLowercase)
                                     self.navigationController?.popViewController(animated: true)
                                 }
                             
                         }
                     }) { (responseFail) in
                             DispatchQueue.main.async {
                                 ExternalClass.HideProgress()
                             }
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
    func addProviderReportAPIRequest(){ //job/provider-job-report
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString: kAddProviderReport, parameter: self.addReportParameters as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
                         DispatchQueue.main.async {
                             ExternalClass.HideProgress()
                         }
                         if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                                 DispatchQueue.main.async {
                                      SAAlertBar.show(.error, message:"Report added successfully.".localizedLowercase)
                                     self.navigationController?.popViewController(animated: true)
                                 }
                             
                         }
                     }) { (responseFail) in
                             DispatchQueue.main.async {
                                 ExternalClass.HideProgress()
                             }
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
    func addCustomerReportAPIRequest(){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString: kAddCustomerReport, parameter: self.addReportParameters as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
        
                     DispatchQueue.main.async {
                         ExternalClass.HideProgress()
                     }
                     if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                             DispatchQueue.main.async {
                                  SAAlertBar.show(.error, message:"Report added successfully.".localizedLowercase)
                                 self.navigationController?.popViewController(animated: true)
                             }
                         
                     }
                 }) { (responseFail) in
                         DispatchQueue.main.async {
                             ExternalClass.HideProgress()
                         }
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
    func addCustomerProviderGenralReportAPIRequest(){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString: kAddGenralreport, parameter: self.addReportParameters as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
        
                     DispatchQueue.main.async {
                         ExternalClass.HideProgress()
                     }
                     if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                             DispatchQueue.main.async {
                                  SAAlertBar.show(.error, message:"Report added successfully.".localizedLowercase)
                                 self.navigationController?.popViewController(animated: true)
                             }
                         
                     }
                 }) { (responseFail) in
                         DispatchQueue.main.async {
                             ExternalClass.HideProgress()
                         }
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
    // MARK: - User Define methods
    func isValidData()->Bool{
        guard let businessName = self.txtTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),businessName.count > 0 else{
                   DispatchQueue.main.async {
                       SAAlertBar.show(.error, message:"Please enter description".localizedLowercase)
                   }
                          return false
                   }
               self.addReportParameters["description"] = "\(businessName)"
       
        return true
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
  

}
extension ReportBugViewController:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

