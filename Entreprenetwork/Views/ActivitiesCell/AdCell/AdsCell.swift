//
//  AdsCell.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 01/05/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdsCell: UITableViewCell {

    @IBOutlet weak var bannerView: GADBannerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
