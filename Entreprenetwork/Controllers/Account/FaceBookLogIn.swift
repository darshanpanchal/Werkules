//
//  FaceBookLogIn.swift
//  Live
//
//  Created by ITPATH on 4/4/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class FaceBookLogIn: NSObject {
    typealias LoginCompletionBlock = (Dictionary<String, AnyObject>?, NSError?) -> Void
    
    //MARK:- Public functions
    class func basicInfoWithCompletionHandler(_ fromViewController:AnyObject, onCompletion: @escaping LoginCompletionBlock) -> Void {
        
        //Check internet connection if no internet connection then return
        self.getBaicInfoWithCompletionHandler(fromViewController) { (dataDictionary:Dictionary<String, AnyObject>?, error: NSError?) -> Void in
            onCompletion(dataDictionary, error)
        }
    }
    
    class var loginManager:LoginManager{
        let manager = LoginManager()
         manager.authType = .reauthorize
//        manager.loginBehavior = .browser
        return manager
    }
    
    class func logoutFromFacebook() {
        loginManager.logOut()
        AccessToken.current = nil
        Profile.clearProfile()
    }
    
    //MARK:- Private functions
    class func getBaicInfoWithCompletionHandler(_ fromViewController:AnyObject, onCompletion: @escaping LoginCompletionBlock) -> Void {
        
        let permissionDictionary = [
            "fields" : "id,name,first_name,last_name,gender,email,birthday,picture.type(large)",
            //"locale" : "en_US"
        ]
        if AccessToken.current != nil {
            GraphRequest(graphPath: "/me", parameters: permissionDictionary).start(completionHandler:  { (connection, result, error) in
                if error == nil {
                    onCompletion(result as? Dictionary<String, AnyObject>, nil)
                } else {
                    onCompletion(nil, error as NSError?)
                }
            })
        } else {
      /*
            self.loginManager.logIn(permissions: [], from: fromViewController as? UIViewController) { (resuilt, error) in
                
            }*/
            
            self.loginManager.logIn(permissions: ["email", "public_profile"], from: fromViewController as? UIViewController, handler: { (result, error) -> Void in
                if error != nil {
                    self.loginManager.logOut()
                    if let error = error as NSError? {
                        let errorDetails = [NSLocalizedDescriptionKey : "Processing Error. Please try again!"]
                        let customError = NSError(domain: "Error!", code: error.code, userInfo: errorDetails)
                        onCompletion(nil, customError)
                    } else {
                        onCompletion(nil, error as NSError?)
                    }
                } else if (result?.isCancelled)! {
                    loginManager.logOut()
//                    let errorDetails = [NSLocalizedDescriptionKey : "Request cancelled!"]
//                    let customError = NSError(domain: "Request cancelled!", code: 1001, userInfo: errorDetails)
//                    onCompletion(nil, customError)
                } else {
                    let pictureRequest = GraphRequest(graphPath: "me", parameters: permissionDictionary)
                    let _ = pictureRequest.start(completionHandler: {(connection, result, error) -> Void in
                        if error == nil {
                            onCompletion(result as? Dictionary<String, AnyObject>, nil)
                        } else {
                            onCompletion(nil, error as NSError?)
                        }
                    })
                }
            })
        }
    }
}

