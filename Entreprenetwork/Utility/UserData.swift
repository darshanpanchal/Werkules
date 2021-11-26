//
//  UserData.swift
//  Lumha
//
//  Created by Sujal Adhia on 25/10/18.
//  Copyright © 2018 LumhaaLLC. All rights reserved.
//

import UIKit

class UserData: NSObject {
    
    static let Shared = UserData()

    var vemail : String? = ""
    var vplatform : String? = ""
    var vuserID : Int? = 0
    var vdevicetoken : String? = ""
    var vpasscode : String? = ""
    var vauthtoken : String? = ""
    var vfirstname : String? = ""
    var vlastname : String? = ""


}
