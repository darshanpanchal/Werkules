//
//  ChangePasswordVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 20/08/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {
    
    @IBOutlet weak var txtFldOldPassword: UITextField!
    @IBOutlet weak var txtFldNewPassword: UITextField!
    @IBOutlet weak var txtFldReEnterNewPassword: UITextField!
    
    var changePasswordDict:[String:Any] = [:]
    
    // MARK: - UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.txtFldOldPassword.delegate = self
        self.txtFldNewPassword.delegate = self
        self.txtFldReEnterNewPassword.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func buttonPasswordHelpSelector(sender:UIButton){
           DispatchQueue.main.async {
               let noCamera = UIAlertController.init(title:"Password Help", message: "Password must have a minimum of 8 characters with at least one number and one special character.", preferredStyle: .alert)
               let  okaySelector = UIAlertAction.init(title:"Ok", style: .cancel, handler: nil)
               okaySelector.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
               noCamera.addAction(okaySelector)
               noCamera.view.tintColor = UIColor(hex:"38B5A3")
               self.present(noCamera, animated: true, completion: nil)
           }
       }
    @IBAction func btnUpdateClicked(_ sender: UIButton) {
        
        if isDataValid() {
            callAPIToChangePassword()
        }
    }
    @IBAction func btnShowPassword(_ sender: UIButton) {
        if sender.isSelected == true {
            sender.isSelected = false
            if sender.tag == 101 {
                self.txtFldOldPassword.isSecureTextEntry = true
            }else if sender.tag == 102 {
                self.txtFldNewPassword.isSecureTextEntry = true
            }else{
                self.txtFldReEnterNewPassword.isSecureTextEntry = true
            }
        }else {
            sender.isSelected = true
            if sender.tag == 101 {
               self.txtFldOldPassword.isSecureTextEntry = false
            }else if sender.tag == 102 {
               self.txtFldNewPassword.isSecureTextEntry = false
            }else{
               self.txtFldReEnterNewPassword.isSecureTextEntry = false
            }
        }
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - User Defined Methods
    
    private func isDataValid() -> Bool {
        
        guard let password = self.txtFldOldPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines),password.count > 0 else{
                SAAlertBar.show(.error, message:"Please enter current password")
                return false
            }
        self.changePasswordDict["current_password"] = "\(password)"
                 
        guard let newpassword = self.txtFldNewPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines),newpassword.count > 0 else{
                                                       SAAlertBar.show(.error, message:"Please enter new password")
                                                       return false
                                                   }
        if !self.isValidPassword(testStr: newpassword){
            SAAlertBar.show(.error, message:"Password must have a minimum of 8 characters with at least one number and one special character.".localizedLowercase)
                   return false
        }
        self.changePasswordDict["password"] = "\(newpassword)"
        
        if self.txtFldNewPassword.text != self.txtFldReEnterNewPassword.text {
            SAAlertBar.show(.error, message:"Your passwords do not match".localizedLowercase)
            return false
        }
        return true
    }
    func isValidPassword(testStr:String)->Bool{
         let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
         let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
         return passwordTest.evaluate(with: testStr)
     }
    func callAPIToChangePassword() {
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kUserChangePassword , parameter: self.changePasswordDict as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                  if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String]{
                                        if userInfo.count > 0 {
                                            
                                          
                                          DispatchQueue.main.async {
                                                SAAlertBar.show(.error, message:"\(userInfo.first!)".localizedLowercase)
                                              self.navigationController?.popViewController(animated: true)
                                          }
                                        }
                                       }else{
                                           DispatchQueue.main.async {
                                              // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
}
extension ChangePasswordVC:UITextFieldDelegate{
    
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
                        
                        guard !typpedString.isContainWhiteSpace() else{
                            return false
                        }
            
            if let password = self.txtFldNewPassword.text{
                if textField == self.txtFldReEnterNewPassword,typpedString.count >= password.count{
                    if string.isEmpty{
                        return true
                    }else if self.txtFldNewPassword.text != typpedString {
                     //Your passwords do not match
                     SAAlertBar.show(.error, message:"Your passwords do not match".localizedLowercase)
                        //SAAlertBar.show(.error, message:"Password and confirm password should be same".localizedLowercase)
                        return true
                    }
                }
            }
            return true
        }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text{
            if !self.isValidPassword(testStr: text){
                       SAAlertBar.show(.error, message:"Password must have a minimum of 8 characters with at least one number and one special character.".localizedLowercase)
                              return true
                   }
        }
        return true
    }
}
