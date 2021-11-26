//
//  UserRegister.swift
//  Lumha
//
//  Created by Sujal Adhia on 08/02/19.
//  Copyright © 2019 LumhaaLLC. All rights reserved.
//

import UIKit

class UserRegister: NSObject {
    
    static let Shared = UserRegister ()
    var arrImageDetails =  [UserRegister]()
    
    var lat : String? = ""
    var long : String? = ""
    var catId : String? = ""
    var vCoverpic: UIImage?
    var vProfilepic: UIImage?
    var vchunkedMode : String? = ""
    var vfileKey : String? = ""
    var vmimeType : String? = ""
    var vTimestamp : String? = ""
    var firstName : String? = ""
    var lastName : String? = ""
    var email : String? = ""
    var companyName : String? = ""
    var phone : String? = ""
    var address : String? = ""
    var deviceToken : String? = ""
    var platform : String? = "iOS"
    var password : String? = ""
    var userId : String? = ""
    var userType : String? = ""
    var EIN : String? = ""
    var companyAddress : String? = ""
    var insurance : String? = ""
    var tagline : String? = ""
    var companyDescription: String? = ""
    var img1 : UIImage?
    var img2 : UIImage?
    var img3 : UIImage?
    var img4 : UIImage?
    var img5 : UIImage?
    var img6 : UIImage?
    var mediaArray = NSMutableArray()
    var deleteflag : String? = ""

    
    func toJsonDict() -> JSONDICTIONARY {
        
        var dict:JSONDICTIONARY = [:]
        
        if let vchunkedMode = vchunkedMode { dict["false"] = vchunkedMode }
        if let firstName = firstName { dict["firstname"] = firstName }
        if let lastName = lastName { dict["lastname"] = lastName }
        if let email = email { dict["email"] = email }
        if let companyName = companyName { dict["company"] = companyName }
        if let phone = phone { dict["phone"] = phone }
        if let deviceToken = deviceToken { dict["device_token"] = deviceToken }
        if let platform = platform { dict["platform"] = platform }
        if let password = password { dict["password"] = password }
        if let userType = userType { dict["user_type"] = userType }
        if let EIN = EIN { dict["ein"] = EIN }
        if let companyAddress = companyAddress { dict["address"] = companyAddress }
        if let insurance = insurance { dict["insurance"] = insurance }
        if let tagline = tagline { dict["tagline"] = tagline }
        if let companyDescription = companyDescription { dict["description"] = companyDescription }
        if let userId = userId { dict["user_id"] = userId }
        if let catId = catId { dict["category_ids"] = catId }
        if let lat = lat { dict["lat"] = lat }
        if let long = long { dict["lng"] = long }
        if let deleteflag = deleteflag { dict["delete_flag"] = deleteflag }

        return dict
    }
    
    func JsonFromDict(_ Dictionary:JSONDICTIONARY) {
        
        
        
    }
}
