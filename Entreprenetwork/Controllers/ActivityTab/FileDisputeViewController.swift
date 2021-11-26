//
//  FileDisputeViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 10/05/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class FileDisputeViewController: UIViewController {

    @IBOutlet weak var txtTextView:UITextView!
    
    @IBOutlet weak var lblBusinessName:UILabel!
    
    var addReportParameters:[String:Any] = [:]
    
    var placeholderLabel : UILabel!
    
    var disputeRequest:[String:Any] = [:]
    
    var name:String = ""
    var id:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.name.count > 0{
            self.lblBusinessName.text = "\(name)"
            self.addReportParameters["name"] = "\(self.name)"
            self.addReportParameters["transaction_id"] = "\(self.id)"
        }
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
        // Do any additional setup after loading the view.
        
        self.txtTextView.delegate = self
//        placeholderLabel = UILabel()
//        placeholderLabel.text = "Write something...."
//        placeholderLabel.font = UIFont(name: "Avenir Medium", size: 17)
//        placeholderLabel.sizeToFit()
//        txtTextView.addSubview(placeholderLabel)
//        placeholderLabel.frame.origin = CGPoint(x: 5, y: (txtTextView.font?.pointSize)! / 2)
//        placeholderLabel.textColor = UIColor.lightGray
//        placeholderLabel.isHidden = !txtTextView.text.isEmpty
    }
     override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
    }
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
    // MARK: - API Methods
    func addCustomerReportAPIRequest(){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString: kPaymentTransactionReport, parameter: self.addReportParameters as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
        
                     DispatchQueue.main.async {
                         ExternalClass.HideProgress()
                     }
                     if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String]{
                             DispatchQueue.main.async {
                                if userInfo.count > 0{
                                    SAAlertBar.show(.error, message:"\(userInfo.first!)".localizedLowercase)
                                }
                                  
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
    // MARK: - Action Methods
     @IBAction func buttonBackSelector(selector:UIButton){
         self.navigationController?.popViewController(animated: true)
     }
    @IBAction func buttonAddReportSelector(sender:UIButton){
        if self.isValidData(){
            DispatchQueue.main.async {
            //    SAAlertBar.show(.error, message:"Under Development".localizedLowercase)
            }
            self.addCustomerReportAPIRequest()
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
extension FileDisputeViewController:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
         if(text == "\n") {
             textView.resignFirstResponder()
            if self.isValidData(){
                self.addCustomerReportAPIRequest()
            }
             return false
         }
         return true
     }
    func textViewDidChange(_ textView: UITextView) {
//        self.placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
