//
//  AddBankdetailViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 13/04/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import WebKit
protocol AddBankAccountWithdrawalDelegate {
    func pushToWithDrawalScreenDelegate()
}

class AddBankdetailViewController: UIViewController {

    @IBOutlet weak var buttonBack:UIButton!
    @IBOutlet weak var objWebView:WKWebView!
    
    var strwebURL:String = ""
    
    @IBOutlet weak var viewWithDrawEarning:UIView!
    @IBOutlet weak var buttotnWithdrawEarning:UIButton!
    
    var isFromBussiness:Bool? //is from business earnign or group earning
    
    var bankAccountStatus:[String:Any] = [:]
    var delegate:AddBankAccountWithdrawalDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Load WebURL
        self.objWebView.navigationDelegate = self
        self.objWebView.uiDelegate = self
        if strwebURL.count > 0{
            self.objWebView.isHidden = false
            if let objURL =  URL.init(string: strwebURL){
                self.objWebView.load(URLRequest(url: objURL))
                //self.objWebView.loadRequest(URLRequest(url: objURL))
            }
            
        }
        self.viewWithDrawEarning.isHidden = true
        /*
        if let _ = self.isFromBussiness{
            self.viewWithDrawEarning.isHidden = false
        }else{
            self.viewWithDrawEarning.isHidden = true
        }*/
        let underlineSeeDetail = NSAttributedString(string: "Withdraw Earnings",
                                                                                     attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        //self.buttotnWithdrawEarning.titleLabel?.attributedText = underlineSeeDetail
        self.buttotnWithdrawEarning.clipsToBounds = true
        self.buttotnWithdrawEarning.layer.cornerRadius = 25.0
        
        
        //Notification for stripe account added
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: .stipeAccountAdded, object: nil)
    }
    @objc func methodOfReceivedNotification(notification: Notification) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    // MARK: - Selector Methods
    @IBAction func buttonbackselector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonWithdrawEarningSelector(sender:UIButton){
        self.getBankAccontStatusAPIRequest()
        
    }
    
    func getBankAccontStatusAPIRequest(){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .GET, queryString:kGETPaymentReceiptAccountStatus, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["success_data"] as? [String:Any]{
                    DispatchQueue.main.async {
                            self.bankAccountStatus = successData
                             if let accountCreated = self.bankAccountStatus["is_account_created"],let accuntVerify = self.bankAccountStatus["is_account_verify"]{
                                                        if let created = "\(accountCreated)".bool{
                                                            if let verify = "\(accuntVerify)".bool{
                                                                if created && verify{
                                                                    self.navigationController?.popViewController(animated: false)
                                                                    if let _ = self.delegate{
                                                                        self.delegate!.pushToWithDrawalScreenDelegate()
                                                                    }
                                                                   
                                                                }else{
                                                                    if let message = successData["message"]{
                                                                        DispatchQueue.main.async {
                                                                            SAAlertBar.show(.error, message:"\(message)".localizedLowercase)
                                                                        }
                                                                    }
                                                                 // self.pushToAddBackDetailWebView()
                                                              }
                                                            }
                                                        }
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
                          //   SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
extension AddBankdetailViewController:WKNavigationDelegate, WKUIDelegate{
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
           DispatchQueue.main.async {
               ExternalClass.ShowProgress()
           }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            ExternalClass.HideProgress()
        }
        //Activity.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            ExternalClass.HideProgress()
        }
        //Activity.stopAnimating()
    }
}
