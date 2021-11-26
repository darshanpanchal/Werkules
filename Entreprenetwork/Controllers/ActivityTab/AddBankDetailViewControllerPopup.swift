//
//  AddBankDetailViewControllerPopup.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 24/06/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol AddBankAccountPopupDelegate {
    func addBankAddedSuccessfully()
}
class AddBankDetailViewControllerPopup: UIViewController {

    @IBOutlet weak var txtAccountNumber:UITextField!
    
    @IBOutlet weak var txtRoutingNumber:UITextField!
    
    var addBankdetail:[String:Any] = [:]
    
    var delegate:AddBankAccountPopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func isValidOfferData()->Bool{
        guard let account_number = self.txtAccountNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines),account_number.count > 0 else{
                  SAAlertBar.show(.error, message:"Please enter Bank Number".localizedLowercase)
                  return false
              }
        self.addBankdetail["account_number"] = "\(account_number)"
        guard let routing_number = self.txtRoutingNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines),routing_number.count > 0 else{
                  SAAlertBar.show(.error, message:"Please enter Routing Number".localizedLowercase)
                  return false
              }
        self.addBankdetail["routing_number"] = "\(routing_number)"
        return true
    }
    @IBAction func buttonbackselector(sender:UIButton){
        DispatchQueue.main.async {
          self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func buttonAddbankAccountselector(sender:UIButton){
        if self.isValidOfferData(){
            self.AddBankdetailAPIRequest()
        }
    }
    func AddBankdetailAPIRequest(){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kAddBankAccount , parameter: self.addBankdetail as? [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [String]{
                                  DispatchQueue.main.async {
                                    if arrayOfJOB.count > 0{
                                        SAAlertBar.show(.error, message:"\(arrayOfJOB.first!)".localizedLowercase)
                                    }
                                    if let _ = self.delegate{
                                        self.delegate!.addBankAddedSuccessfully()
                                    }
                                    self.dismiss(animated: true, completion: nil)
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
