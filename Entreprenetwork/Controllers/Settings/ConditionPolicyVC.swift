//
//  ConditionPolicyVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 09/09/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD

class ConditionPolicyVC: UIViewController {
    
    //DEVELOPMENT
//    let appTermsURL = "http://werkulesdev.project-demo.info/terms-conditions"
//    let appPrivacyURL = "http://werkulesdev.project-demo.info/privacy-policy"
    //PRODUCTION
//    let appTermsURL = "https://prodapiv2.werkules.com/privacy-policy"
//    let appPrivacyURL = "https://prodapiv2.werkules.com/terms-conditions"
//    AWS
    let appTermsURL = "http://apiv2.werkules.com/terms-conditions"
    let appPrivacyURL = "http://apiv2.werkules.com/privacy-policy"

    let appFAQ = "https://werkules.com/frequently-asked-questions/"
    //Old
    //let appURL = "https://app.termly.io/document/privacy-policy/68fa1922-c441-497b-86b0-403ba7f3e791"
    
    var strTitle = String()
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtViewTerms: UITextView!
    
    var strURL = ""
    @IBOutlet weak var objWebView:WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.objWebView.navigationDelegate = self
        self.objWebView.uiDelegate = self

        // Do any additional setup after loading the view.
        
        self.lblTitle.text = self.strTitle
        
        txtViewTerms.isHidden = true
        if self.strTitle == "Terms & Conditions" || self.strTitle.contains("Terms"){
            self.objWebView.isHidden = false
           self.txtViewTerms.isHidden = true
            self.objWebView.load((URLRequest(url: URL(string: "\(self.appTermsURL)")!)))
        }else if self.strTitle == "Privacy Policy" || self.strTitle.contains("Privacy") {
            self.txtViewTerms.isHidden = true
            self.objWebView.isHidden = false
            self.objWebView.load((URLRequest(url: URL(string: "\(self.appPrivacyURL)")!)))
            //objWebView.loadRequest(URLRequest(url: URL(string: "https://app.termly.io/document/privacy-policy/68fa1922-c441-497b-86b0-403ba7f3e791")!))
        }else if self.strTitle == "Facts" || self.strTitle.contains("Facts") {
            self.txtViewTerms.isHidden = true
            self.objWebView.isHidden = false
            self.objWebView.load((URLRequest(url: URL(string: "\(self.appFAQ)")!)))
        }else{
            if strURL.count > 0{
                self.objWebView.isHidden = false
                if let objURL =  URL.init(string: strURL){
                    self.objWebView.load(URLRequest(url: objURL))
                    //self.objWebView.loadRequest(URLRequest(url: objURL))
                }
                
            }
        }
    }
    
    @IBAction func btnCloseClicked(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
}
extension ConditionPolicyVC:WKNavigationDelegate, WKUIDelegate{
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

