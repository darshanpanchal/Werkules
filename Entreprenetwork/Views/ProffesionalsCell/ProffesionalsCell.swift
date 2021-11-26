//
//  ProffesionalsCell.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 27/12/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class ProffesionalsCell: UITableViewCell {
    
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var lblCompanyName: UILabel!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var btnAddToNetwork: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
