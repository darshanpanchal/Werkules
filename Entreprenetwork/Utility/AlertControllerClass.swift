//
//  AlertControllerClass.swift
//  SolApp
//
//  Created by Apple on 12/07/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController
{
    /**
     Display an Alert / Actionsheet
     
     - parameter controller:     Object of controller on which you need to display Alert/Actionsheet
     - parameter aStrMessage:    Message to display in Alert / Actionsheet
     - parameter style:          .Alert / .Actionshhet
     - parameter aCancelBtn:     Cancel button title
     - parameter aDistrutiveBtn: Distructive button title
     - parameter otherButtonArr: Array of other button title
     - parameter completion:     Completion block. Other Button Index Starting From - 0 | Destructive Index - (Last / 2nd Last Index) | Cancel Index - (Last / 2nd Last Index)
     */
    class func showAlert(_ controller : AnyObject ,
                         position : CGRect,
                         aStrMessage :String? ,
                         style : UIAlertController.Style ,
                         aCancelBtn :String? ,
                         aDistrutiveBtn : String?,
                         otherButtonArr : Array<String>?,
                         completion : ((Int, String) -> Void)?) -> Void {
        
        let strTitle = ""
        
        let alert = UIAlertController.init(title: strTitle, message: aStrMessage, preferredStyle: style)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let Vc =  controller as? UIViewController
            if Vc != nil{
                
                alert.popoverPresentationController?.sourceView = Vc!.view!
                alert.popoverPresentationController?.sourceRect = position
            }
        }
        
        if let strDistrutiveBtn = aDistrutiveBtn {
            
            let aStrDistrutiveBtn = strDistrutiveBtn
            
            alert.addAction(UIAlertAction.init(title: aStrDistrutiveBtn, style: .destructive, handler: { (UIAlertAction) in
                
                completion?(otherButtonArr != nil ? otherButtonArr!.count : 0, strDistrutiveBtn)
                
            }))
        }
        
        if let strCancelBtn = aCancelBtn {
            
            let aStrCancelBtn = strCancelBtn
            
            alert.addAction(UIAlertAction.init(title: aStrCancelBtn, style: .cancel, handler: { (UIAlertAction) in
                
                if ( aDistrutiveBtn != nil ) {
                    completion?(otherButtonArr != nil ? otherButtonArr!.count + 1 : 1, strCancelBtn)
                } else {
                    completion?(otherButtonArr != nil ? otherButtonArr!.count : 0, strCancelBtn)
                }
                
            }))
        }
        
        if let arr = otherButtonArr {
            
            for (index, value) in arr.enumerated() {
                
                let aValue = value
                
                alert.addAction(UIAlertAction.init(title: aValue, style: .default, handler: { (UIAlertAction) in
                    
                    completion?(index, value)
                    
                }))
            }
        }
        
        controller.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    class func showAlert(_ controller : AnyObject ,
                         aStrTitle :String? ,
                         aStrMessage :String? ,
                         style : UIAlertController.Style ,
                         aCancelBtn :String? ,
                         aDistrutiveBtn : String?,
                         otherButtonArr : Array<String>?,
                         completion : ((Int, String) -> Void)?) -> Void {
        
        
        let alert = UIAlertController.init(title: aStrTitle, message: aStrMessage, preferredStyle: style)
        
        alert.view.tintColor = UIColor.init(hex: "#38B5A3")
        if let strDistrutiveBtn = aDistrutiveBtn {
            
            let aStrDistrutiveBtn = strDistrutiveBtn
            
            alert.addAction(UIAlertAction.init(title: aStrDistrutiveBtn, style: .destructive, handler: { (UIAlertAction) in
                
                completion?(otherButtonArr != nil ? otherButtonArr!.count : 0, strDistrutiveBtn)
                
            }))
        }
        
        if let strCancelBtn = aCancelBtn {
            
            let aStrCancelBtn = strCancelBtn
            
            alert.addAction(UIAlertAction.init(title: aStrCancelBtn, style: .cancel, handler: { (UIAlertAction) in
                
                if ( aDistrutiveBtn != nil ) {
                    completion?(otherButtonArr != nil ? otherButtonArr!.count + 1 : 1, strCancelBtn)
                } else {
                    completion?(otherButtonArr != nil ? otherButtonArr!.count : 0, strCancelBtn)
                }
                
            }))
        }
        
        if let arr = otherButtonArr {
            
            for (index, value) in arr.enumerated() {
                
                let aValue = value
                
                alert.addAction(UIAlertAction.init(title: aValue, style: .default, handler: { (UIAlertAction) in
                    
                    completion?(index, value)
                    
                }))
            }
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            
            
            alert.popoverPresentationController?.sourceView = controller.view// works for both iPhone & iPad
            
            controller.present(alert, animated: true, completion: nil)

        }
        else{
            
            controller.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    
    /**
     Display an Alert / Actionsheet
     
     - parameter controller:     Object of controller on which you need to display Alert/Actionsheet
     - parameter aStrMessage:    Message to display in Alert / Actionsheet
     - parameter style:          .Alert / .Actionshhet
     - parameter aCancelBtn:     Cancel button title
     - parameter aDistrutiveBtn: Distructive button title
     - parameter otherButtonArr: Array of other button title
     - parameter completion:     Completion block. Other Button Index Starting From - 0 | Destructive Index - (Last / 2nd Last Index) | Cancel Index - (Last / 2nd Last Index)
     */
    
    
    class func showAlert(_ controller : AnyObject ,
                         aStrMessage :String? ,
                         style : UIAlertController.Style ,
                         aCancelBtn :String? ,
                         aDistrutiveBtn : String?,
                         otherButtonArr : Array<String>?,
                         completion : ((Int, String) -> Void)?) -> Void {
        
        let strTitle = AppName
        
        let alert = UIAlertController.init(title: strTitle, message: aStrMessage, preferredStyle: style)
        
        alert.view.tintColor = UIColor.init(hex: "#38B5A3")
        
        if let strDistrutiveBtn = aDistrutiveBtn {
            
            let aStrDistrutiveBtn = strDistrutiveBtn
            
            alert.addAction(UIAlertAction.init(title: aStrDistrutiveBtn, style: .destructive, handler: { (UIAlertAction) in
                
                completion?(otherButtonArr != nil ? otherButtonArr!.count : 0, strDistrutiveBtn)
                
            }))
        }
        
        if let strCancelBtn = aCancelBtn {
            
            let aStrCancelBtn = strCancelBtn
            
            alert.addAction(UIAlertAction.init(title: aStrCancelBtn, style: .cancel, handler: { (UIAlertAction) in
                
                if ( aDistrutiveBtn != nil ) {
                    completion?(otherButtonArr != nil ? otherButtonArr!.count + 1 : 1, strCancelBtn)
                } else {
                    completion?(otherButtonArr != nil ? otherButtonArr!.count : 0, strCancelBtn)
                }
                
            }))
        }
        
        if let arr = otherButtonArr {
            
            for (index, value) in arr.enumerated() {
                
                let aValue = value
                
                alert.addAction(UIAlertAction.init(title: aValue, style: .default, handler: { (UIAlertAction) in
                    
                    completion?(index, value)
                    
                }))
            }
        }
       
        
        controller.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    /**
     Display an Alert With "Ok" Button
     
     - parameter controller:  Object of controller on which you need to display Alert
     - parameter aStrMessage: Message to display in Alert
     - parameter completion:  Completion block. Ok Index - 0
     */
    
    class func showAlertWithOkButton(_ controller : AnyObject ,
                                     aStrTitle :String?,
                                     aStrMessage :String? ,
                                     completion : ((Int, String) -> Void)?) -> Void {
        
        self.showAlert(controller, aStrTitle: aStrTitle, aStrMessage: aStrMessage, style: .alert, aCancelBtn: nil, aDistrutiveBtn: nil, otherButtonArr: ["OK"], completion: completion)
        
    }
    
    
    /**
     Display an Alert With "Cancel" Button
     
     - parameter controller:  Object of controller on which you need to display Alert
     - parameter aStrMessage: Message to display in Alert
     - parameter completion:  Completion block. Cancel Index - 0
     */
    class func showAlertWithCancelButton(_ controller : AnyObject ,
                                         aStrMessage :String? ,
                                         
                                         completion : ((Int, String) -> Void)?) -> Void {
        DispatchQueue.main.async(execute: {
            self.showAlert(controller, aStrMessage: aStrMessage, style: .alert, aCancelBtn: "Cancel", aDistrutiveBtn: nil, otherButtonArr: ["OK"], completion: completion)
        })
    }
    class func showAlertWithYesNoButton(_ controller : AnyObject ,
                                         aStrMessage :String? ,

                                         completion : ((Int, String) -> Void)?) -> Void {
        DispatchQueue.main.async(execute: {
            self.showAlert(controller, aStrMessage: aStrMessage, style: .alert, aCancelBtn: "No", aDistrutiveBtn: nil, otherButtonArr: ["Yes"], completion: completion)
        })
    }
    
    
    
    /**
     Display an Alert For Delete Confirmation
     
     - parameter controller:  Object of controller on which you need to display Alert
     - parameter aStrMessage: Message to display in Alert
     - parameter completion:  Completion block. Use Gallery Index - 0 | Use Camera Index - 1 | Cancel Index - 2
     */
    class func showDeleteAlert(_ controller : AnyObject ,
                               aStrMessage :String? ,
                               aStrDeleteTitle:String,
                               completion : ((Int, String) -> Void)?) -> Void {
        DispatchQueue.main.async(execute: {
            self.showAlert(controller, aStrMessage: aStrMessage, style: .alert, aCancelBtn: "Cancel", aDistrutiveBtn: aStrDeleteTitle, otherButtonArr: nil, completion: completion)
        })
    }
    
    class func showOkAlert(_ controller : AnyObject ,
                           aStrMessage :String? ,
                           completion : ((Int, String) -> Void)?) -> Void {
        DispatchQueue.main.async(execute: {
            self.showAlert(controller, aStrMessage: aStrMessage, style: .alert, aCancelBtn: "OK", aDistrutiveBtn: nil, otherButtonArr: nil, completion: completion)
        })
    }
    
    
    /**
     Display an Actionsheet For ImagePicker
     
     - parameter controller:  Object of controller on which you need to display Alert
     - parameter aStrMessage: Message to display in Actionsheet
     - parameter completion:  Completion block. Delete Button Index - 0 | Cancel Button Index - 1
     */
    class func showActionsheetForImagePicker(_ controller : AnyObject ,
                                             aStrTilte : String? = nil,
                                             aStrMessage :String? ,aOptionsArr : Array<String>?,
                                             completion : ((Int, String) -> Void)?) -> Void {
        DispatchQueue.main.async(execute: {
            self.showAlert(controller, aStrTitle: aStrTilte, aStrMessage: aStrMessage, style: .actionSheet, aCancelBtn: "Cancel", aDistrutiveBtn: nil, otherButtonArr: aOptionsArr, completion: completion)
        })
    }
    
    
    
    /**
     Display an Actionsheet For ImagePicker
     
     - parameter controller:  Object of controller on which you need to display Alert
     - parameter aStrMessage: Message to display in Actionsheet
     - parameter completion:  Completion block. Delete Button Index - 0 | Cancel Button Index - 1
     */
    class func showActionsheet(_ controller : AnyObject ,
                               position : CGRect,
                               aStrMessage :String? ,
                               completion : ((Int, String) -> Void)?) -> Void {
        DispatchQueue.main.async(execute: {
            
            self.showAlert(controller, position : position ,aStrMessage: aStrMessage, style: .actionSheet, aCancelBtn: "Cancel", aDistrutiveBtn: nil, otherButtonArr: ["Gallery", "Camera"], completion: completion)
        })
    }
    
    
    class func showAlertWithTextField(_ controller : AnyObject ,
                                      aStrTitle :String? ,
                                      aStrMessage :String? ,
                                      style : UIAlertController.Style ,
                                      aCancelBtn :String? ,
                                      aDistrutiveBtn : String?,
                                      completion : ((Int, String) -> Void)?) -> Void {
        
        
        let alert = UIAlertController.init(title: aStrTitle, message: aStrMessage, preferredStyle: style)
        
        let btnREPORT  = UIAlertAction.init(title: aDistrutiveBtn, style: .destructive, handler: { (UIAlertAction) in
            
            let reportTextField = alert.textFields![0]
            if !(reportTextField.text?.isEmpty)!{
                completion?( 1 , reportTextField.text!)
            }
        })
        
        btnREPORT.isEnabled = false
        alert.addAction(btnREPORT)
        
        if let strCancelBtn = aCancelBtn {
            
            let aStrCancelBtn = strCancelBtn
            
            alert.addAction(UIAlertAction.init(title: aStrCancelBtn, style: .cancel, handler: { (UIAlertAction) in
                
                if ( aDistrutiveBtn != nil ) {
                    completion?( 0, strCancelBtn)
                } else {
                    completion?(0, strCancelBtn)
                }
                
            }))
        }
        
        alert.addTextField { (textField) in
            
            textField.placeholder = "Reason to report "
            textField.superview?.backgroundColor = UIColor.clear
            
//            NotificationCenter.default.addObserver(forName: .UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
//                {_ in
//                    // Being in this block means that something fired the UITextFieldTextDidChange notification.
//                    
//                    // Access the textField object from alertController.addTextField(configurationHandler:) above and get the character count of its non whitespace characters
//                    let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
//                    let textIsNotEmpty = textCount > 0
//                    // If the text contains non whitespace characters, enable the OK Button
//                    btnREPORT.isEnabled = textIsNotEmpty
//            })
        }
        controller.present(alert, animated: true, completion: nil)
        
    }
    
    
    /*
     Display Action Sheet wih Destructive buttin
     */
    /*
     Display ActionSheetForLogOut
     */
    
    class func showActionsheetForLogOut(_ controller : AnyObject ,
                                        completion : ((Int, String) -> Void)?) -> Void {
        DispatchQueue.main.async(execute: {
            
            self.showAlert(controller, aStrTitle: AppName, aStrMessage: "Are you sure you want to logout?" , style: .actionSheet, aCancelBtn: "Cancel", aDistrutiveBtn: "Logout", otherButtonArr: nil, completion: completion)
        })
    }
    
    class func showActionsheetForDeleteAccount(_ controller : AnyObject ,
                                        completion : ((Int, String) -> Void)?) -> Void {
        DispatchQueue.main.async(execute: {
            
            self.showAlert(controller, aStrTitle: AppName, aStrMessage: "Are you sure you want to delete account?" , style: .actionSheet, aCancelBtn: "Cancel", aDistrutiveBtn: "delete account", otherButtonArr: nil, completion: completion)
        })
    }
    
    class func showActionsheetForDeleteMemory(_ controller : AnyObject ,
                                        completion : ((Int, String) -> Void)?) -> Void {
        DispatchQueue.main.async(execute: {
            
            self.showAlert(controller, aStrTitle: AppName, aStrMessage: "Are you sure you want delete memory?" , style: .actionSheet, aCancelBtn: "Cancel", aDistrutiveBtn: "Delete", otherButtonArr: nil, completion: completion)
        })
    }
    
    class func showActionsheetForDeleteJar(_ controller : AnyObject ,
                                              completion : ((Int, String) -> Void)?) -> Void {
        DispatchQueue.main.async(execute: {
            
            self.showAlert(controller, aStrTitle: AppName, aStrMessage: "Are you sure you want delete Jar?" , style: .actionSheet, aCancelBtn: "Cancel", aDistrutiveBtn: "Delete", otherButtonArr: nil, completion: completion)
        })
    }
    
    class func showActionsheetForRemoveJarMember(_ controller : AnyObject ,
                                           completion : ((Int, String) -> Void)?) -> Void {
        DispatchQueue.main.async(execute: {
            
            self.showAlert(controller, aStrTitle: AppName, aStrMessage: "Are you sure you want remove?" , style: .actionSheet, aCancelBtn: "Cancel", aDistrutiveBtn: "Delete", otherButtonArr: nil, completion: completion)
        })
    }
}
