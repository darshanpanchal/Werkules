//
//  UserModel.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 13/08/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class UserModel: NSObject {
    
    static let Shared = UserModel ()
    
    var userId : String? = ""
    var userFirstName : String? = ""
    var userLastName : String? = ""

}
