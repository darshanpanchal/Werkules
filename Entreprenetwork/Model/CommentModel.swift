//
//  CommentModel.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 09/01/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit

class CommentModel: NSObject {
    
    static let Shared = CommentModel ()
    
    var arrComments = [CommentModel]()
    
    var commentId : Int? = 0
    var activityId : Int? = 0
    var commentString : String? = ""
    var commentUserId : Int? = 0
    var userDict : NSDictionary?
    
    func JsonParseFromDict(_ Dictionary:JSONDICTIONARY) {
    
        if let val = Dictionary["id"] as? Int { self.commentId = Int(val) }
        if let val = Dictionary["activity_id"] as? Int { self.activityId = Int(val) }
        if let val = Dictionary["user_id"] as? Int { self.commentUserId = Int(val) }
        if let val = Dictionary["comment"] as? String {self.commentString = val }
        if let val = Dictionary["user"] as? NSDictionary {self.userDict = val }
    }

}
