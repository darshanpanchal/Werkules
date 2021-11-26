//
//  CustomerHelpViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 23/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class CustomerHelpViewController: UIViewController {

    
    @IBOutlet var buttonStart:UIButton!
    
    var isForVerifiedProvider:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if self.isForVerifiedProvider{
            self.buttonStart.setTitle("NEXT", for: .normal)
        }else{
            self.buttonStart.setTitle("GET STARTED", for: .normal)
        }
    }
    

    // MARK: - Selector Methods
    @IBAction fileprivate func buttonNextSelector(sender:UIButton){
        if self.isForVerifiedProvider{
            //Current user type provider
            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                       return
            }
            if currentUser.userRoleType == .customer{
                self.apiRequestToSwitchUserRole()
            }else if currentUser.userRoleType == .provider{
                self.pushToHelpViewController()
            }else{
                self.pushToHelpViewController()
            }
            
        }else{
            self.pushToCustomerHomeViewController()
        }
        
        
        
    }
    func apiRequestToSwitchUserRole(){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                   return
        }
        var dict:[String:Any]  = [:]
        if currentUser.userRoleType == .customer{
            dict["role"] = "provider"
        }else if currentUser.userRoleType == .provider{
          dict["role"] = "customer"
        }
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSwitchAccount , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                        if let success = responseSuccess as? [String:Any],let userInfoDetail = success["success_data"]{
                            if currentUser.userRoleType == .customer{
                              currentUser.userRoleType = .provider
                            }else if currentUser.userRoleType == .provider{
                              currentUser.userRoleType = .customer
                            }
                            currentUser.setuserDetailToUserDefault()
                            DispatchQueue.main.async {
                                self.pushToHelpViewController()
                                //self.pushToCustomerOrProviderHomeViewController()
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
    //PushToHome
     func pushToCustomerHomeViewController(){
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
         let navigationController = UINavigationController(rootViewController:VC)
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         appDelegate.window?.rootViewController = navigationController
     }
    func pushToHelpViewController(){
          if let helpViewController = self.storyboard?.instantiateViewController(withIdentifier: "HelpViewController") as? HelpViewController{
              self.navigationController?.pushViewController(helpViewController, animated: true)
          }
      }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
