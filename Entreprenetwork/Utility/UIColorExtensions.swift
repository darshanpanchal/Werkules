//
//  UIColorExtensions.swift
//
//  
//  


import Foundation
import UIKit

// MARK: - Application colors
public extension UIColor {
    
    public struct app {
        
        
        
        
        
        
        /// Primary Color of the Application
        /// ````
        /// UIColor.app.primary
        /// ````
        public static let primary                        = UIColor(hex: "000000")
        
        public static let navigationBG                        = UIColor(hex: "121119")

        
        
         public static let darkBg                        = UIColor(hex: "19161E")
        
        
         public static let blackBg                        = UIColor(hex: "000000")
        
        
        /// Secondary Color of the Application
        /// ````
        /// UIColor.app.secondary
        /// ````
        public static let secondary                      = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        
        
        
        /// Primary Color for Title. - Hex - 1F2124
        /// ````
        /// UIColor.app.titlePrimary
        /// ````
        public static let titlePrimary                   = secondary
        
        /// Secondary Color for Title. - Hex - A2A5AA
        /// ````
        /// UIColor.app.titleSecondary
        /// ````
        public static let titleSecondary                 = UIColor(red: 158.0/255.0, green: 158.0/255.0, blue: 158.0/255.0, alpha: 1.0)
        
        
        
        /// Primary Color for Header.
        /// ````
        /// UIColor.app.headerPrimary
        /// ````
        public static let headerPrimary                  = primary
        
        
        
        /// Primary Color for Background.
        /// ````
        /// UIColor.app.primaryBGColor
        /// ````
        public static let primaryBGColor                 = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        
        /// Secondary Color for Background.
        /// ````
        /// UIColor.app.secondaryBGColor
        /// ````
        public static let secondaryBGColor               = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        
    }
    
    
}


public extension UIColor {
    
    /// This method will get the Color from the Hex string
    ///
    /// ````
    /// UIColor.hexString("95A5A6")
    /// ````
    /// - Parameter hex: Hex String of the color
    /// - Returns: UIColor from the hex string
    public class func hexString(_ hex: String) -> UIColor {
        
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
        
    }
    
    /// This method will get the Color from the Hex string
    ///
    /// ````
    /// UIColor(hex: "95A5A6")
    /// ````
    ///
    /// - Parameters:
    ///   - hex: Hex String of the color. example: "95A5A6"
    public convenience init(hex: String) {
        
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            let start = cString.index(cString.startIndex, offsetBy: 1)
            cString = String(cString[start...])
        }
        
        let r, g, b, a: CGFloat
        
        if cString.count == 6 {
            let scanner = Scanner(string: cString)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x0000ff) / 255
                a = 1.0
                
                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
        }
        
        self.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        return
        
    }
    
}

extension UITextField {
    func disableAutoFill() {
        if #available(iOS 12, *) {
            textContentType = .oneTimeCode
        } else {
            textContentType = .init(rawValue: "")
        }
    }
}
