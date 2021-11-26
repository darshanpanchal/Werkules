//
//  CategoryCell.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 12/08/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
    
    
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var btnCategorySelection: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
