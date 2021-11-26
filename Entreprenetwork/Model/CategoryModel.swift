//
//  CategoryModel.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 13/08/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class CategoryModel: NSObject {
    
    static let Shared = CategoryModel ()
    var arrCategories =  [CategoryModel]()

    var categoryId : String? = ""
    var categoryName : String? = ""
    
    func JsonParseFromDict(_ Dictionary:JSONDICTIONARY) {
        
        if let val = Dictionary["id"] as? String{self.categoryId = val}
        if let val = Dictionary["name"] as? String{self.categoryName = val}
    }

}

