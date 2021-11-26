//
//  NetworkModel.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 14/04/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit

class NetworkModel: NSObject {

    static let Shared = NetworkModel ()
    var arrUsers =  [NetworkModel]()
    
    var userId = Int()
    var firstName : String? = ""
    var lastName : String? = ""
    
    func JsonParseFromDict(_ Dictionary:JSONDICTIONARY) {
    
        if let val = Dictionary["id"] as? Int { self.userId = Int(val) }
        if let val = Dictionary["firstname"] as? String {self.firstName = val }
        if let val = Dictionary["lastname"] as? String {self.lastName = val }
    }
}
