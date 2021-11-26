//
//  ForgotPasswordVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 20/09/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class ForgotPasswordOTPVC: UIViewController {
    
    
    @IBOutlet weak var txtFldEmail: UITextField!
    
    // MARK: - UIView Life Cycle̦
     var email = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.txtFldEmail.text = "\(email)"
        self.txtFldEmail.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
           // self.txtFldEmail.setPlaceHolderColor()
            
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        UserDefaults.standard.set(true, forKey: "fromForgotPassword")
        
        if isModal == true {
            self.dismiss(animated: true, completion: nil)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnSendOtpClicked(_ sender: UIButton) {
        
        
        if validateData() == true {
            let dict = [
                APIManager.Parameter.email : txtFldEmail.text!
            ]
            APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kForgotPassword , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                           if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [Any]{
                            if userInfo.count > 0 {
                                DispatchQueue.main.async {
                                    SAAlertBar.show(.error, message:"\(userInfo[0])".localizedLowercase)
                                }
                            }
                            
                               DispatchQueue.main.async {
                                  self.navigationController?.popViewController(animated: true)
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
                                  // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                               }
                           }
                       }

        }
    }
    
    // MARK:- User Defined Methods
    
    private func validateData() -> Bool {
        guard let email = self.txtFldEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines),email.count > 0 else{
                           SAAlertBar.show(.error, message:"Please enter email to recover password")
                           return false
                       }
        if !self.isValidEmail(testStr: txtFldEmail.text!){
            SAAlertBar.show(.error, message:"Please enter valid email".localizedLowercase)
            return false
        }
        
        return true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z]+([._%+-]{1}[A-Z0-9a-z]+)*@[A-Za-z0-9]+\\.([A-Za-z])*([A-Za-z0-9]+\\.[A-Za-z]{2,4})*"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "forgotPasswordSegue" {
            let vc = segue.destination as! ForgotPasswordVC
            vc.email = txtFldEmail.text!
        }
    }
    
}
extension ForgotPasswordOTPVC:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
                    
        if textField == self.txtFldEmail{
            guard !typpedString.isContainWhiteSpace() else{
                        return false
            }
            return typpedString.count < 255
        }
        return true
}
}

