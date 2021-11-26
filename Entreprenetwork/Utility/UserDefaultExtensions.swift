//
//  UserDefaultExtensions.swift
//  
//  


import Foundation
import UIKit




public extension UserDefaults {
    
    enum UserKeys {
        
        static let userUID                          = "UserUID"
        static let userEmail                        = "email"
        static let isUserLogin                      = "isUserLogin"
    }
    
    enum Keys {
        
        static let isUserLogin                          = "isUserLogin"
        static let isfirstTimeInstall                   = "isFirstTimeInstall"
        static let isArabic                             = "isArabic"
        static let appLanguage                          = "AppLanguage"
        static let token                                = "token"
        static let baseUrl                              = "baseUrl"
    }
    
    
    
    //Store String Value in UserDefault
    func setStringValue(forKey key: String, defaultValue: String) {
        
        set(defaultValue, forKey: key)
        synchronize()
    }
    
    //Fetch  String Value in UserDefault
    func getStringValue(forKey key: String) -> String{
        return   object(forKey: key) as! String
    }
    
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if value(forKey: key) == nil {
            set(defaultValue, forKey: key)
        }
        return bool(forKey: key)
    }
    
    func integer(forKey key: String, defaultValue: Int) -> Int {
        if value(forKey: key) == nil {
            set(defaultValue, forKey: key)
        }
        return integer(forKey: key)
    }
    
    func string(forKey key: String, defaultValue: String) -> String {
        if value(forKey: key) == nil {
            set(defaultValue, forKey: key)
        }
        return string(forKey: key) ?? defaultValue
    }
    
    
    
    func double(forKey key: String, defaultValue: Double) -> Double {
        if value(forKey: key) == nil {
            set(defaultValue, forKey: key)
        }
        return double(forKey: key)
    }
    
    
    func object(forKey key: String, defaultValue: AnyObject) -> Any? {
        if object(forKey: key) == nil {
            set(defaultValue, forKey: key)
        }
        return object(forKey: key)
    }
    
    
    
    // MARK: -
    
    func color(forKey key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            do{
                color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)//NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
            }catch{

            }
        }
        return color
    }
    
//    func setColor(_ color: UIColor?, forKey key: String) {
//        var colorData: Data?
//        if let color = color {
//            colorData = NSKeyedArchiver.archivedData(withRootObject: color)
//        }
//        set(colorData, forKey: key)
//    }
    
    
    
//    func setArchivedData(_ object: Any?, forKey key: String) {
//        var data: Data?
//        if let object = object {
//            data = NSKeyedArchiver.archivedData(withRootObject: object)
//        }
//        set(data, forKey: key)
//    }
//
//    func unarchiveObjectWithData(forKey key: String) -> Any? {
//        guard let object = object(forKey: key) else { return nil }
//        guard let data = object as? Data else { return nil }
//        return NSKeyedUnarchiver.unarchiveObject(with: data)
//    }
}






extension UserDefaults {
    
    subscript<T>(key: String) -> T? {
        get {
            return value(forKey: key) as? T
        }
        set {
            set(newValue, forKey: key)
        }
    }
    
    subscript<T: RawRepresentable>(key: String) -> T? {
        get {
            if let rawValue = value(forKey: key) as? T.RawValue {
                return T(rawValue: rawValue)
            }
            return nil
        }
        set {
            set(newValue?.rawValue, forKey: key)
        }
    }
    
}
