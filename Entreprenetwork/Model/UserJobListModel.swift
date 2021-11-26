//
//  UserJobListModel.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 04/02/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit

class UserJobListModel: NSObject {
    
    static let Shared = UserJobListModel ()
        var arrUserJobs =  [UserJobListModel]()

        var userDict : NSDictionary?

    //    var likes : NSArray?
    //    var commentModel : CommentModel?
        
        var likesArrayNew = [LikeModel]()
        var likesArray : NSArray?
        
        var commentsArrayNew = [CommentModel]()
        var commentsArray : NSArray?

        var jobId : Int? = 0
        var activityType : String? = ""
        var isActivity : String? = ""
        
        var jobUserId : Int? = 0
        var jobTitle : String? = ""
        var jobAddress : String? = ""
        var jobCreationDate : String? = ""
        var jobCategoryIds : String? = ""
        var jobDescription : String? = ""
        var jobStatus : String? = ""
        var estimatedBudget : String? = ""
        var fairMarketValue : String? = ""
        var averageRatings : Int? = 0
        
        var jobImg1Path : String? = ""
        var jobImg2Path : String? = ""
        var jobImg3Path : String? = ""
        var jobImg4Path : String? = ""
        
        var jobLatitude : String? = ""
        var jobLongitude : String? = ""
    
    var activityArr : NSArray?
    var activityDict : NSDictionary?
            
        func toJsonDict() -> JSONDICTIONARY {
            
            var dict:JSONDICTIONARY = [:]
            
            if let jobId = jobId { dict["id"] = jobId }
            if let activityType = activityType { dict["activity_type"] = activityType }
            if let isActivity = isActivity { dict["is_activity"] = isActivity }
            if let jobUserId = jobUserId { dict["user_id"] = jobUserId }
            if let jobLatitude = jobLatitude { dict["lat"] = jobLatitude }
            if let jobLongitude = jobLongitude { dict["lng"] = jobLongitude }
            if let userDict = userDict { dict["user"] = userDict }
            
            if let jobTitle = jobTitle { dict["title"] = jobTitle }
            if let jobAddress = jobAddress { dict["address"] = jobAddress }
            if let jobCreationDate = jobCreationDate { dict["created_at"] = jobCreationDate }
            if let jobCategoryIds = jobCategoryIds { dict["platform"] = jobCategoryIds }
            if let averageRatings = averageRatings { dict["avg_review"] = averageRatings }
            
            if let jobDescription = jobDescription { dict["description"] = jobDescription }
            if let estimatedBudget = estimatedBudget { dict["estimate_budget"] = estimatedBudget }
            if let fairMarketValue = fairMarketValue { dict["fair_market_value"] = fairMarketValue }
            if let jobLatitude = jobLatitude { dict["lat"] = jobLatitude }
            if let jobLongitude = jobLongitude { dict["lng"] = jobLongitude }
            if let jobUserId = jobUserId { dict["user_id"] = jobUserId }
            
            if let jobImg1Path = jobImg1Path { dict["file1"] = jobImg1Path }
            if let jobImg2Path = jobImg2Path { dict["file2"] = jobImg2Path }
            if let jobImg3Path = jobImg3Path { dict["file3"] = jobImg3Path }
            if let jobImg4Path = jobImg4Path { dict["file4"] = jobImg4Path }

            return dict
        }
        
        func JsonParseFromDict(_ Dictionary:JSONDICTIONARY) {
            
            if let val = Dictionary["id"] as? Int { self.jobId = Int(val) }
            if let val = Dictionary["user_id"] as? Int { self.jobUserId = Int(val) }
            if let val = Dictionary["activity_type"] as? String{self.activityType = val }
            if let val = Dictionary["is_activity"] as? String{self.isActivity = val }
            if let val = Dictionary["lat"] as? String { self.jobLatitude = val }
            if let val = Dictionary["lng"] as? String { self.jobLongitude = val }
            if let val = Dictionary["user"] as? NSDictionary { self.userDict = val }
            
            if let val = Dictionary["activity"] as? NSArray { self.activityArr = val }
            
            if self.activityArr!.count > 0 {
                self.activityDict = (self.activityArr![0] as! NSDictionary)
            
                if let val = activityDict!["like"] as? NSArray { self.likesArray = val }
                if let val = activityDict!["comment"] as? NSArray { self.commentsArray = val }
                
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
            
            if let val = Dictionary["title"] as? String{self.jobTitle = val}
            if let val = Dictionary["description"] as? String { self.jobDescription = val}
            if let val = Dictionary["status"] as? String { self.jobStatus = val}
            if let val = Dictionary["address"] as? String { self.jobAddress = val}
            if let val = Dictionary["created_at"] as? String { self.jobCreationDate = val}
            if let val = Dictionary["category_ids"] as? String { self.jobCategoryIds = val}
            if let val = Dictionary["estimate_budget"] as? String { self.estimatedBudget = val}
            if let val = Dictionary["fair_market_value"] as? String { self.fairMarketValue = val}
            if let val = Dictionary["avg_review"] as? Int { self.averageRatings = Int(val)}
            if let val = Dictionary["file1"] as? String { self.jobImg1Path = val}
            if let val = Dictionary["file2"] as? String { self.jobImg2Path = val}
            if let val = Dictionary["file3"] as? String { self.jobImg3Path = val}
            if let val = Dictionary["file4"] as? String { self.jobImg4Path = val}
            
            
        }

}
