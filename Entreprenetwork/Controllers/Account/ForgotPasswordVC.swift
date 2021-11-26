//
//  ForgotPasswordVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 20/09/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFldOTP: UITextField!
    @IBOutlet weak var txtFldNewPassword: UITextField!
    @IBOutlet weak var txtFldReEnterNewPassword: UITextField!
    
    var email = String()
    
    // MARK: - UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.txtFieldEmail.text = self.email
        self.txtFieldEmail.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
//            self.txtFieldEmail.setPlaceHolderColor()
//            self.txtFldOTP.setPlaceHolderColor()
//            self.txtFldNewPassword.setPlaceHolderColor()
//            self.txtFldReEnterNewPassword.setPlaceHolderColor()
            
        }
    }
    
    // MARK: - Actions
    
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        if isModal == true {
            self.dismiss(animated: true, completion: nil)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnUpdateClicked(_ sender: UIButton) {
        
        if validateData() == true {
            
            let dict = [
                APIManager.Parameter.email : self.email,
                //APIManager.Parameter.otp : txtFldOTP.text!,
                //APIManager.Parameter.password : txtFldNewPassword.text!
            ]
            
                  
             
             APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kForgotPassword , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                 if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                     DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                     }
                 }else{
                     DispatchQueue.main.async {
                        // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                     }
                 }
             }) { (responseFail) in
                 if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                     DispatchQueue.main.async {
                         SAAlertBar.show(.error, message:"\(errorMessage)".localizedLowercase)
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
        
        if (txtFldOTP.text?.isEmpty)!{
            SAAlertBar.show(.error, message:"Please enter OTP sent on your registered mobile number".localizedLowercase)
            return false
        }
        
        if (txtFldNewPassword.text?.isEmpty)!{
            SAAlertBar.show(.error, message:"Please enter new password".localizedLowercase)
            return false
        }
        
        if (txtFldReEnterNewPassword.text?.isEmpty)!{
            SAAlertBar.show(.error, message:"Please re-enter new password".localizedLowercase)
            return false
        }
        
        if txtFldNewPassword.text != txtFldReEnterNewPassword.text {
            SAAlertBar.show(.error, message:"Please renter valid password".localizedLowercase)
            return false
        }
        
        return true
    }
}
extension ForgotPasswordVC:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
                    
        if textField == self.txtFieldEmail{
            guard !typpedString.isContainWhiteSpace() else{
                        return false
            }
            return typpedString.count < 255
        }
        return true
}
}
