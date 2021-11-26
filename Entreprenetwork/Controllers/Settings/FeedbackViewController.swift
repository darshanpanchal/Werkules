//
//  FeedbackViewController.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 21/04/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController,UITextViewDelegate {
    
    @IBOutlet weak var textviewFeedback: UITextView!
    
    //MARK: - UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textviewFeedback.text = "Please enter your feedback....."
        textviewFeedback.textColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.3)
    }
    
    // MARK: - UITexyView Delegate Method
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Please enter your feedback....." {
            textView.text = ""
            textviewFeedback.textColor = UIColor(red: 9/255, green: 64/255, blue: 94/255, alpha: 1.0)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Please enter your feedback....."
            
            textviewFeedback.textColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.3)
        }
    }
    
    //MARK: - Actions
    
    @IBAction func btnSendClicked(_ sender: UIButton) {
        
        if textviewFeedback.text != "" && textviewFeedback.text != "Please enter your feedback....." {
            self.callAPIToSendFeedback()
        }
        else {
            SAAlertBar.show(.info, message: "Enter valid feedback")
        }
    }
    
    @IBAction func btnCancelclicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - API
    
    func callAPIToSendFeedback() {
        let dict = [
            APIManager.Parameter.feedback : textviewFeedback.text!
        ]
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kApplicationFeedback , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
              if let success = responseSuccess as? [String:Any],let array = success["success_data"] as? [String:Any]{
                           
                            DispatchQueue.main.async {
                               print(array)
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
        /*
        let userId = UserSettings.userID
        let email = UserSettings.emailText
        
        let dict = [
            APIManager.Parameter.userID : userId,
            APIManager.Parameter.email : email,
            APIManager.Parameter.feedback : textviewFeedback.text!
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_sendFeedback, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                SAAlertBar.show(.info, message: "Feedback has been sent successfully.")
                self.navigationController?.popViewController(animated: true)
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                SAAlertBar.show(.error, message:message.capitalized)
            }
        }*/
    }
}
