//
//  APIManager.swift
//  Lumha
//
//  Created by Sujal Adhia on 03/10/18.
//  Copyright © 2018 LumhaaLLC. All rights reserved.
//

import UIKit
import Alamofire


class APIManager : NSObject {
    
    struct Parameter {
        
        static let RESULT                   = "result"
        static let RESOPONSE_STATUS         = "response_status"
        static let MESSAGE                  = "msg"
        
        
        /*  https://lumhaa.com:1443/lumhaaApp/saveOrUpdateLoginInfo?userId=214&firstName=Ranjith&lastName=Kumar&email=ranjith.brainak@gmail.com&password=ranjith&phone=&address=%20%20%20%20%20Coimbatore%20%20%20
         */
        
        //Sign Up Sign In
        static let firstname = "firstname"
        static let lastname = "lastname"
        static let password = "password"
        static let email = "email"
        static let deviceToken = "device_token"
        static let platform = "platform"
        static let userID = "user_id"
        static let oldPassword = "old_password"
        static let newPassword = "new_password"
        static let otp = "otp"
        static let status = "status"
        static let mobileNumber = "mobile"
        static let authId = "auth_id"
        static let loginType = "login_type"
        
        static let latitude = "lat"
        static let longitude = "lng"
        static let radius = "radius"
        static let limit = "limit"
        static let page = "page"
        static let categoryName = "name"
        static let categoryIds = "category_ids"
        static let filterDescription = "description"
        static let name = "name"
        
        static let jobID = "job_id"
        static let toID = "to_id"
        static let fromID = "from_id"
        static let message = "message"
        static let file = "file"
        static let messageID = "message_id"
        static let progressBy = "progress_by"
        
        static let activityId = "activity_id"
        static let comment = "comment"
        static let commentId = "comment_id"
        
        static let networkId = "network_id"
        
        static let review = "review"
        static let rating = "rating"
        static let title = "title"
        static let isNotification = "is_notification"
        static let feedback = "feedback"
       
    }
    
    static let sharedInstance = APIManager()

    func CallAPIWithGet(url:String,parameter:[String:String]?,complition: @escaping(_ error : Error?,_ json:JSONDICTIONARY?)->())  {
        
//
        
        ExternalClass.ShowProgress()
        
        let header : HTTPHeaders = [
            "Content-Type":"application/x-www-form-urlencoded"
        ]
        
        print("API :: ------------------------------------------------------------\n\(url)")
        
        Alamofire.request(url, method: .get, parameters: parameter,headers: header).responseJSON { (jsonResponse) in
            ExternalClass.HideProgress()
            switch jsonResponse.result {
            case .success:
                if let json = jsonResponse.result.value as? JSONDICTIONARY {
                    print("THIS IS A SUCCESS")
                    print(json)
                    print("\n------------------------------------------------------------\n")
                    complition(nil, json)
                }
                break
            case .failure(let responseError):
                
                if responseError != nil{
                    SAAlertBar.show(.error, message:(responseError.localizedDescription))
                    return
                }
                
                complition(responseError, nil)
                break
            }
        }
    }
    
    func CallAPI(url:String,parameter:JSONDICTIONARY?,complition: @escaping(_ error : Error?,_ json:JSONDICTIONARY?)->())  {        
        
        if Reachability.instance == .none {
            //BaseVc.ShowAlert(message:AppConstant.AppValidationMsg.Msg_InternetConnection)
            return
        }

        ExternalClass.ShowProgress()
//
        let header : HTTPHeaders = [
            "Content-Type":"application/json"
//            "Content-Type":"application/x-www-form-urlencoded"

        ]
        
//        var request        = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        do {
//            request.httpBody   = try JSONSerialization.data(withJSONObject: your_parameter_aaray)
//        } catch let error {
//            print("Error : \(error.localizedDescription)")
//        }
        
    
        print("API :: ------------------------------------------------------------\n\(url)")
                
        Alamofire.request(url, method: .post, parameters: parameter,headers: header).responseJSON { (jsonResponse) in
            ExternalClass.HideProgress()
            print(jsonResponse.result)
            print(jsonResponse.result.value)
            switch jsonResponse.result {
            case .success:
                if let json = jsonResponse.result.value as? JSONDICTIONARY {
                    print("THIS IS A SUCCESS")
                    print(json)
                    print("\n------------------------------------------------------------\n")
                    complition(nil, json)
                }
                break
            case .failure(let responseError):
                
                if responseError != nil{
                    SAAlertBar.show(.error, message:(responseError.localizedDescription))
                    return
                }
                
                complition(responseError, nil)
                break
            }
        }
    }
    
    func CallAPIRegisterUser(parameter:UserRegister?, complition: @escaping(_ error : Error?,_ json:JSONDICTIONARY?)->()) {
        
        let profileURL = kCustomerRegister//Url_Register
        
        ExternalClass.ShowProgress()
        
        let header : HTTPHeaders = [
            "Content-Type":"application/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            if let img = parameter?.vProfilepic {
                let data = img.pngData()
                multipartFormData.append(data!, withName: "profile_pic[]", fileName: (parameter?.vTimestamp)! + "_profile.png" ,mimeType: "image/png")
            }
            
            if let img = parameter?.vCoverpic {
                let data = img.pngData()
                multipartFormData.append(data!, withName: "cover_pic[]", fileName: (parameter?.vTimestamp)! + "_cover.png" ,mimeType: "image/png")
            }
            
            if parameter?.userType != "normal"{
                
                for (index, dataDict) in (parameter?.mediaArray)!.enumerated() {
                    let mediaDict = dataDict as! NSMutableDictionary
                    let typekey = mediaDict.object(forKey: "type") as! String
                    let mediadata =  mediaDict.object(forKey: "data") as! Data
                    let fileName = "file" + String(index+1) + "[]"
                    if typekey == "Image"{
                        multipartFormData.append(mediadata, withName: fileName, fileName: ((parameter?.vTimestamp)! + String(index+1) + ".png") ,mimeType: "image/png")
                    }
                    else{
                        multipartFormData.append(mediadata, withName: fileName, fileName: ((parameter?.vTimestamp)! + String(index+1) + ".mp4") ,mimeType: "mp4")
                    }
                }
            }
            for (key,value) in parameter!.toJsonDict() {
                multipartFormData.append((String(describing:value)).data(using: .utf8)!, withName: key)
            }
            
        }, to: profileURL, method: .post, headers:header ,encodingCompletion: { (encodingResult) in
            //ExternalClass.HideProgress()
            
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.uploadProgress { progress in
                    print("Upload Progress \(progress.fractionCompleted)")
                }
                
                upload.responseJSON { response in
                    
                    ExternalClass.HideProgress()
                    
                    switch response.result {
                    case .success(let value):
                        print("THIS IS A SUCCESS")
                        if let json = value as? JSONDICTIONARY {
                            complition(nil, json)
                        }
                        break
                    case .failure(let error):
                        complition(error, nil)
                        break
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    func CallAPISaveUpdatePost(parameter:UserJob?, complition: @escaping(_ error : Error?,_ json:JSONDICTIONARY?)->()) {
        
        let profileURL = Url_jobSaveUpdate
        
        ExternalClass.ShowProgress()
        
        let header : HTTPHeaders = [
            "Content-Type":"application/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
                        
//            if let img = parameter?.img1 {
//                let data = img.pngData()
//                multipartFormData.append(data!, withName: "file1[]", fileName: ((parameter?.vTimestamp)! + "1" + ".png") ,mimeType: "image/png")
//            }
//
//            if let img = parameter?.img2 {
//                let data = img.pngData()
//                multipartFormData.append(data!, withName: "file2[]", fileName: ((parameter?.vTimestamp)! + "2"  + ".png" ) ,mimeType: "image/png")
//            }
//
//            if let img = parameter?.img3 {
//                let data = img.pngData()
//                multipartFormData.append(data!, withName: "file3[]", fileName: ((parameter?.vTimestamp)! + "3"  + ".png") ,mimeType: "image/png")
//            }
//
//            if let img = parameter?.img4 {
//                let data = img.pngData()
//                multipartFormData.append(data!, withName: "file4[]", fileName: ((parameter?.vTimestamp)! + "4"  + ".png") ,mimeType: "image/png")
//            }
//
//            for (key,value) in parameter!.toJsonDict() {
//                multipartFormData.append((String(describing:value)).data(using: .utf8)!, withName: key)
//            }
            
            for (index, dataDict) in (parameter?.mediaArray)!.enumerated() {
                let mediaDict = dataDict as! NSMutableDictionary
                let typekey = mediaDict.object(forKey: "type") as! String
                let mediadata =  mediaDict.object(forKey: "data") as! Data
                let fileName = "file" + String(index+1) + "[]"
                if typekey == "Image"{
                    multipartFormData.append(mediadata, withName: fileName, fileName: ((parameter?.vTimestamp)! + String(index+1) + ".png") ,mimeType: "image/png")
                }
                else{
                    multipartFormData.append(mediadata, withName: fileName, fileName: ((parameter?.vTimestamp)! + String(index+1) + ".mp4") ,mimeType: "mp4")
                }
            }
            
            for (key,value) in parameter!.toJsonDict() {
                multipartFormData.append((String(describing:value)).data(using: .utf8)!, withName: key)
            }
            
        }, to: profileURL, method: .post, headers:header ,encodingCompletion: { (encodingResult) in
            //ExternalClass.HideProgress()
            
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.uploadProgress { progress in
                    print("Upload Progress \(progress.fractionCompleted)")
                }
                
                upload.responseJSON { response in

                    switch response.result {
                    case .success(let value):
                        print("THIS IS A SUCCESS")
                        
                         ExternalClass.HideProgress()
                        if let json = value as? JSONDICTIONARY {
                            complition(nil, json)
                        }
                        break
                    case .failure(let error):
                        
                         ExternalClass.HideProgress()
                        complition(error, nil)
                        break
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }

    func CallAPIToSendImageMessage(url:String, parameter:ImageMessage?, complition: @escaping(_ error : Error?,_ json:JSONDICTIONARY?)->()) {
        
        let profileURL = url
        
        ExternalClass.ShowProgress()
        
        let header : HTTPHeaders = [
            "Content-Type":"application/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            if let img = parameter?.file {
                let data = img.pngData()
                multipartFormData.append(data!, withName: "file[]", fileName: (parameter?.vTimestamp)! + ".png" ,mimeType: "image/png")
            }

            for (key,value) in parameter!.toJsonDict() {
                multipartFormData.append((String(describing:value)).data(using: .utf8)!, withName: key)
            }
            
        }, to: profileURL, method: .post, headers:header ,encodingCompletion: { (encodingResult) in
            //ExternalClass.HideProgress()
            
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.uploadProgress { progress in
                    print("Upload Progress \(progress.fractionCompleted)")
                }
                
                upload.responseJSON { response in
                    
                    ExternalClass.HideProgress()
                    
                    switch response.result {
                    case .success(let value):
                        print("THIS IS A SUCCESS")
                        if let json = value as? JSONDICTIONARY {
                            complition(nil, json)
                        }
                        break
                    case .failure(let error):
                        complition(error, nil)
                        break
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    
    func CallAPIPost(url:String,parameter:JSONDICTIONARY?,complition: @escaping(_ error : Error?,_ json:JSONDICTIONARY?)->())  {
        
        if Reachability.instance == .none{
            SAAlertBar.show(.error, message: "Please check your internet connection.")
            return
        }
        
        if url.contains("api/message/list") == true || url.contains("api/chat/list") == true && UserDefaults.standard.bool(forKey: "hideActivity") == true {
        }
       else {
            ExternalClass.ShowProgress()
       }
        
        //
        let header : HTTPHeaders = [
            "Authorization":"\("Bearer ")\(UserData.Shared.vauthtoken!)"

        ]
        
        print("API :: ------------------------------------------------------------\n\(url)")
        
        Alamofire.request(url, method: .post, parameters: parameter,headers: header).responseJSON { (jsonResponse) in
            ExternalClass.HideProgress()
            switch jsonResponse.result {
            case .success:
                if let json = jsonResponse.result.value as? JSONDICTIONARY {
                    print("THIS IS A SUCCESS")
//                    print(json)
                    print("\n------------------------------------------------------------\n")
                    complition(nil, json)
                }
                break
            case .failure(let responseError):
                
                if responseError != nil{
                    SAAlertBar.show(.error, message:(responseError.localizedDescription))
                    return
                }
                
                complition(responseError, nil)
                break
            }
        }
    }
  
}
