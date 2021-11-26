//
//  UpdatedSearchTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS on 14/05/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class UpdatedSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var imageUser:UIImageView!
    @IBOutlet weak var viewImageView:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.imageUser.contentMode = .scaleAspectFill
            self.imageUser.clipsToBounds = true
            self.imageUser.layer.cornerRadius = 20.0
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        /*DispatchQueue.main.async {
            self.viewImageView.isHidden = false
            self.imageUser.isHidden = false
        }*/
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
