//
//  ImageMessage.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 21/01/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit

class ImageMessage: NSObject {
    
    static let Shared = ImageMessage()
    
    var job_id : String? = ""
    var from_id : String? = ""
    var to_id : String? = ""
    var message: String? = ""
    var file : UIImage?
    var vmimeType : String? = ""
    var vTimestamp : String? = ""
   

    
    func toJsonDict() -> JSONDICTIONARY {
        
        var dict:JSONDICTIONARY = [:]
        
        if let job_id = job_id { dict["job_id"] = job_id }
        if let from_id = from_id { dict["from_id"] = from_id }
        if let to_id = to_id { dict["to_id"] = to_id }
        if let message = message { dict["message"] = message }

        return dict
    }
    
    func JsonFromDict(_ Dictionary:JSONDICTIONARY) {
        
        
        
    }
}
