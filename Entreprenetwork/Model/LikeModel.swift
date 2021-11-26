//
//  LikeModel.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 09/01/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit

class LikeModel: NSObject {
    
    static let Shared = LikeModel ()
    
    var arrLikes = [CommentModel]()
    
    var likeId : Int? = 0
    var activityId : Int? = 0
    var likeStatus : String? = ""
    var userId : Int? = 0
    var userDict = NSDictionary()
    
    func JsonParseFromDict(_ Dictionary:JSONDICTIONARY) {
    
        if let val = Dictionary["id"] as? Int { self.likeId = Int(val) }
        if let val = Dictionary["activity_id"] as? Int { self.activityId = Int(val) }
        if let val = Dictionary["user_id"] as? Int { self.userId = Int(val) }
        if let val = Dictionary["status"] as? String { self.likeStatus = val }
        if let val = Dictionary["user"] as? NSDictionary { self.userDict = val }
    }
}
