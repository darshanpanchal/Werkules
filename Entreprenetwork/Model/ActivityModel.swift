//
//  ActivityModel.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 09/01/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit

class ActivityModel: NSObject {
    
    static let Shared = ActivityModel ()
    var arrActivities =  [ActivityModel]()

    var jobDict : NSDictionary?
    var userDict : NSDictionary?

//    var likes : NSArray?
//    var commentModel : CommentModel?
    
    var likesArrayNew = [LikeModel]()
    var likesArray : NSArray?
    
    var commentsArrayNew = [CommentModel]()
    var commentsArray : NSArray?

    var activityId : Int? = 0
    var activityType : String? = ""
    var isActivity : String? = ""
    var jobId : Int? = 0
    var jobUserId : Int? = 0
    var activityLatitude : String? = ""
    var activityLongitude : String? = ""
        
    func toJsonDict() -> JSONDICTIONARY {
        
        var dict:JSONDICTIONARY = [:]
        
        if let activityId = activityId { dict["id"] = activityId }
        if let activityType = activityType { dict["activity_type"] = activityType }
        if let isActivity = isActivity { dict["is_activity"] = isActivity }
        if let jobId = jobId { dict["job_id"] = jobId }
        if let jobUserId = jobUserId { dict["user_id"] = jobUserId }
        if let activityLatitude = activityLatitude { dict["lat"] = activityLatitude }
        if let activityLongitude = activityLongitude { dict["lng"] = activityLongitude }
        if let jobDict = jobDict { dict["job"] = jobDict }
        if let userDict = userDict { dict["user"] = userDict }

        return dict
    }
    
    func JsonParseFromDict(_ Dictionary:JSONDICTIONARY) {
        
        if let val = Dictionary["id"] as? Int { self.activityId = Int(val) }
        if let val = Dictionary["job_id"] as? Int { self.jobId = Int(val) }
        if let val = Dictionary["user_id"] as? Int { self.jobUserId = Int(val) }
        if let val = Dictionary["activity_type"] as? String{self.activityType = val }
        if let val = Dictionary["is_activity"] as? String{self.isActivity = val }
        if let val = Dictionary["lat"] as? String { self.activityLatitude = val }
        if let val = Dictionary["lng"] as? String { self.activityLongitude = val }
        if let val = Dictionary["job"] as? NSDictionary { self.jobDict = val }
        if let val = Dictionary["user"] as? NSDictionary { self.userDict = val }
        if let val = Dictionary["like"] as? NSArray { self.likesArray = val }
        if let val = Dictionary["comment"] as? NSArray { self.commentsArray = val }
        
        var commentModel = [CommentModel]()

        if commentsArray != nil {
            for comment in self.commentsArray! {
                let DataObject = CommentModel()
                DataObject.JsonParseFromDict(comment as! JSONDICTIONARY)
                commentModel.append(DataObject)
                commentsArrayNew.append(DataObject)
            }
        }
        
        var likeModel = [LikeModel]()

        if likesArray != nil {
            for comment in self.likesArray! {
                let DataObject = LikeModel()
                DataObject.JsonParseFromDict(comment as! JSONDICTIONARY)
                likeModel.append(DataObject)
                likesArrayNew.append(DataObject)
            }
        }
    }

}
