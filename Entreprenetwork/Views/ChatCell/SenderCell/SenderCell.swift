//
//  SenderCell.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 10/09/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class SenderCell: UITableViewCell {
    
    
//    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgVwProfilePic: UIImageView!
    @IBOutlet weak var lblChatText: PaddingLabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewwidth : NSLayoutConstraint!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lblChatText.backgroundColor = UIColor.init(hex: "99CCFF")
        self.imgVwProfilePic.contentMode = .scaleAspectFill
                      self.imgVwProfilePic.clipsToBounds = true
              self.imgVwProfilePic.layer.cornerRadius = 25
              self.imgVwProfilePic.clipsToBounds = true
              self.imgVwProfilePic.layer.borderWidth = 0.5
              self.imgVwProfilePic.layer.borderColor = UIColor.lightGray.cgColor
            
             
        
        
    }
    func updateChatContentCornor(){
        DispatchQueue.main.async {
            self.lblChatText.clipsToBounds = true
            self.lblChatText.roundCorners(corners: [.topLeft,.topRight,.bottomRight], radius: 20.0)
        }
    }
    
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        viewBG.roundCorners(corners: [.topRight,.bottomLeft], radius: 5.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
