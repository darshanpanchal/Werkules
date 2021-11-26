//
//  UserJob.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 12/08/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class UserJob: NSObject {
    
    static let Shared = UserJob ()
    var arrCategory =  [UserJob]()
    
    var jobID : String? = ""
    var catId : String? = ""
    var userId : String? = ""
    var vTimestamp : String? = ""
    var img1 : UIImage?
    var img2 : UIImage?
    var img3 : UIImage?
    var img4 : UIImage?
    var jobTitle : String? = ""
    var estBudget : String? = ""
    var fairMarketValue : String? = ""
    var jobAddress : String? = ""
    var lat : String? = ""
    var long : String? = ""
    var jobDescription : String? = ""
    var platform : String? = "iOS"
    var isActivity : String? = ""
    var deleteFlag : String? = "1"
    var mediaArray = NSMutableArray()
    
    func toJsonDict() -> JSONDICTIONARY {
        
        var dict:JSONDICTIONARY = [:]
        
        if let jobID = jobID { dict["job_id"] = jobID }
        if let jobTitle = jobTitle { dict["title"] = jobTitle }
        if let userId = userId { dict["user_id"] = userId }
        if let catId = catId { dict["category_ids"] = catId }
        if let estBudget = estBudget { dict["estimate_budget"] = estBudget }
        if let fairMarketValue = fairMarketValue { dict["fair_market_value"] = fairMarketValue }
        if let lat = lat { dict["lat"] = lat }
        if let long = long { dict["lng"] = long }
        if let jobAddress = jobAddress { dict["address"] = jobAddress }
        if let jobDescription = jobDescription { dict["description"] = jobDescription }
        if let platform = platform { dict["platform"] = platform }
        if let isActivity = isActivity { dict["is_activity"] = isActivity }
        if let deleteFlag = deleteFlag { dict["delete_flag"] = deleteFlag }
        
        return dict
    }

}
