//
//  MessagesCell.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 27/07/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class MessagesCell: UITableViewCell {

    @IBOutlet weak var btnJobPic: UIButton!
    @IBOutlet weak var lblJobStatus: UILabel!
    @IBOutlet weak var lblJobTitle: UILabel!
    @IBOutlet weak var lblSeparator: UILabel!
    @IBOutlet weak var btnRatings: UIButton!
    @IBOutlet weak var btnJob: UIButton!
    @IBOutlet weak var imgViewDot : UIImageView!
    @IBOutlet weak var imgthreeDot : UIImageView!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
