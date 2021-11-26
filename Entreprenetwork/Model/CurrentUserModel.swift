//
//  CurrentUserModel.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 23/08/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class CurrentUserModel: NSObject {
    
    static let Shared = CurrentUserModel()
    
    var catId : String? = ""
    var vCoverPic: String?
    var vProfilepic: String?
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
    var userId : String? = ""
    var userType : String? = ""
    var EIN : String? = ""
    var companyAddress : String? = ""
    var insurance : String? = ""
    var tagline : String? = ""
    var companyDescription: String? = ""
    var joinedOn : String? = ""
    var isNotification : String? = ""
    
    var isUserLogin : Bool = false

    var mediaArray = NSMutableArray()
    
    
//    func toJsonDict() -> JSONDICTIONARY {
//
//        var dict:JSONDICTIONARY = [:]
//
//        if let vchunkedMode = vchunkedMode { dict["false"] = vchunkedMode }
//        if let userId = userId { dict["user_id"] = userId }
//        if let firstName = firstName { dict["firstname"] = firstName }
//        if let lastName = lastName { dict["lastname"] = lastName }
//        if let email = email { dict["email"] = email }
//        if let companyName = companyName { dict["company"] = companyName }
//        if let phone = phone { dict["phone"] = phone }
//        if let deviceToken = deviceToken { dict["device_token"] = deviceToken }
//        if let platform = platform { dict["platform"] = platform }
//        if let password = password { dict["password"] = password }
//        if let userType = userType { dict["user_type"] = userType }
//        if let EIN = EIN { dict["ein"] = EIN }
//        if let companyAddress = companyAddress { dict["address"] = companyAddress }
//        if let insurance = insurance { dict["insurance"] = insurance }
//        if let tagline = tagline { dict["tagline"] = tagline }
//        if let companyDescription = companyDescription { dict["description"] = companyDescription }
//
//        if let vProfilepic = vProfilepic { dict ["profile_pic"] = vProfilepic }
//
//        return dict
//    }
    
    func JsonParseFromDict(_ Dictionary:JSONDICTIONARY) {
        
        if let val = Dictionary["user_id"] as? String{self.userId = val}
        if let val = Dictionary["firstname"] as? String{self.firstName = val}
        if let val = Dictionary["lastname"] as? String { self.lastName = val}
        if let val = Dictionary["email"] as? String { self.email = val}
        if let val = Dictionary["company"] as? String { self.companyName = val}
        if let val = Dictionary["phone"] as? String { self.phone = val}
        if let val = Dictionary["device_token"] as? String { self.deviceToken = val}
        if let val = Dictionary["platform"] as? String { self.platform = val}
        if let val = Dictionary["user_type"] as? String { self.userType = val}
        if let val = Dictionary["ein"] as? String { self.EIN = val}
        if let val = Dictionary["address"] as? String { self.companyAddress = val}
        if let val = Dictionary["insurance"] as? String { self.insurance = val}
        if let val = Dictionary["created_at"] as? String { self.joinedOn = val}
        if let val = Dictionary["tagline"] as? String { self.tagline = val}
        if let val = Dictionary["description"] as? String { self.companyDescription = val}
        if let val = Dictionary["cover_pic"] as? String { self.vCoverPic = val }
        if let val = Dictionary["profile_pic"] as? String { self.vProfilepic = val }
        if let val = Dictionary["category_ids"] as? String { self.catId = val }
        if let val = Dictionary["is_notification"] as? String { self.isNotification = val }
    }

}
