//
//  UserSettings.swift
//  Lumha
//
//  Created by Sujal Adhia on 26/11/18.
//  Copyright © 2018 LumhaaLLC. All rights reserved.
//

import UIKit
import Foundation


enum AppTheme: Int {
    case light
    case dark
    case none
}


class UserSettings {
    
    /// This will store the application language which is selected by the User.
    class var appLanguage: String {
        get {
            return UserDefaults.standard[#function] ?? "en"
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    /// THis will store the DeviceToken for the Push notification
    class var deviceToken: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    /// THis will store the DeviceToken for the SESSION NUM
    class var coordinatorNum: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var userID: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var emailText: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var PasswordText: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    /// This will store the value in UD that if user is logged in or not.
    class var isWalkthroughDisplayed: Bool {
        get {
            return UserDefaults.standard[#function] ?? false
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    /// This will store the value in UD that if user is logged in or not.
    class var isUserLogin: Bool {
        get {
            return UserDefaults.standard[#function] ?? false
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    /// This will store the value in UD that user has enabled for the Notification or not.
    class var isNotificationsEnabled: Bool {
        get {
            return UserDefaults.standard[#function] ?? false
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    /// This will store the current app theme enum in the UD.
    class var appTheme: AppTheme {
        get {
            return UserDefaults.standard[#function] ?? .none
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var userCoordinatorNumber: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var userSessionNumber: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var userFirstName: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var userLastName: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    
    class var userToken: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var userPhone: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var userType: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var userProfilePath: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var companyName: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var companyAddress: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    class var companyDescription: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var EIN: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var insurance: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var companyTagline: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    class var companyImgVid1: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    class var companyImgVid2: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    class var companyImgVid3: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    class var companyImgVid4: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    class var companyImgVid5: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    class var companyImgVid6: String {
        get {
            return UserDefaults.standard[#function] ?? ""
        }
        set {
            UserDefaults.standard[#function] = newValue
        }
    }
    
    /// This how you can store the object of your own model. Currently it will store the object of the User.
    //    class var currentUser: UserModel? {
    //        get {
    //
    //            let decoded = UserDefaults.standard[#function] ?? Data()
    //            return (decoded.count > 0) ? NSKeyedUnarchiver.unarchiveObject(with: decoded) as? UserModel : nil
    //
    //        }
    //        set {
    //
    //            if newValue == nil {
    //                UserDefaults.standard.removeObject(forKey: #function)
    //            } else {
    //                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: newValue!)
    //                UserDefaults.standard[#function] = encodedData
    //            }
    //
    //        }
    //    }
    
}
