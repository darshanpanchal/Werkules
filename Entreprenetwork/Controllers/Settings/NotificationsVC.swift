//
//  NotificationsVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 11/02/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController {
    
    @IBOutlet weak var switchNotifications: UISwitch!
    
    //MARK: - UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if CurrentUserModel.Shared.isNotification == "on" {
            switchNotifications.setOn(true, animated: false)
        }
        else {
            switchNotifications.setOn(false, animated: false)
        }
    }
    
    //MARK: - Action
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UISwitch Delegate Methods
    
    @IBAction func allowNotifications(_ sender: UISwitch) {
        
        let userId = UserSettings.userID
        var isNotification = String()
        
        if switchNotifications.isOn {
            isNotification = "on"
        }
        else {
            isNotification = "off"
        }
        
        let dict = [
            APIManager.Parameter.userID : userId,
            APIManager.Parameter.isNotification : isNotification
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_NotificationOnOff, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                let userData = dataDict["data"] as! JSONDICTIONARY
                CurrentUserModel.Shared.JsonParseFromDict(userData)
                
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
