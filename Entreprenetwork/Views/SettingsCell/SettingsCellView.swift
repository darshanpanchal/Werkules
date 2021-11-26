//
//  SettingsCellView.swift
//  Bloqdrop
//
//  Created by Sujal Adhia on 19/06/19.
//  Copyright © 2019 Bloqdrop. All rights reserved.
//

import UIKit

class SettingsCellView: UITableViewCell {
    
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var imgDetail:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgDetail.contentMode = .scaleAspectFill
                      self.imgDetail.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
