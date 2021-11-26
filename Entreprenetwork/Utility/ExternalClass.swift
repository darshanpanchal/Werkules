//
//  ExternalClass.swift
//  MyFoodFactory
//
//  Created by pimac006 on 23/12/17.
//  Copyright © 2017 pimac006. All rights reserved.
//

import UIKit
import SVProgressHUD
import IQKeyboardManagerSwift
import Reachability

class ExternalClass: NSObject {
  
    class func ShowProgress() {
        SVProgressHUD.show()
        
    }
    
    class func HideProgress() {
        SVProgressHUD.dismiss()
    }
    
    func getchangeDate(date:String) -> String  {
        // var newdate = "10-12-2018"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let date = dateFormatter.date(from: date as String)
        dateFormatter.dateFormat = "dd MMM, yyyy"
        return  dateFormatter.string(from: date!)
    }

}

class CurrencyFormate{
    class func Currency(value: Double)->String
    {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_US")
        let result = formatter.string(from: value as NSNumber) ?? "none"
        return result
    }
}
class CurrencyFormateString{
    class func Currency(value: String)->String
    {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_US")
        let val = Double(value)
        let result = formatter.string(from: val! as NSNumber) ?? "none"
        return result
    }
}
