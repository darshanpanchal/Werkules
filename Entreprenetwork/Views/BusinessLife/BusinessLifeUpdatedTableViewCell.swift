//
//  BusinessLifeUpdatedTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 02/09/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

protocol BusinessLifeUpdatedCellDelegate {
    func buttonPlaySelectorWithIndex(index:Int)
    func buttonImageSelectorWithIndex(index:Int)
    func buttonFollowSelectorWithIndex(index:Int)
    func buttonShareSelectorWithIndex(index:Int)
    func buttonFullScreenSelectorWithIndex(index:Int)
    func buttonProviderDetailSelectorWithIndex(index:Int)

}
class BusinessLifeUpdatedTableViewCell: UITableViewCell {

    @IBOutlet weak var imgBusinessLogo:UIImageView!

    @IBOutlet weak var lblBusinessName:UILabel!
    @IBOutlet weak var lblProviderName:UILabel!
    @IBOutlet weak var lblReview:UILabel!
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var btnFollow:UIButton!



    @IBOutlet weak var imgBusinessLife:UIImageView!
    @IBOutlet weak var videoPrevie:PlayerView!

    @IBOutlet weak var lblDescription:UILabel!

    var delegate:BusinessLifeUpdatedCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.imgBusinessLogo.clipsToBounds = true
            self.imgBusinessLogo.layer.cornerRadius = 30.0
            self.imgBusinessLife.contentMode = .scaleAspectFill
            self.imgBusinessLife.clipsToBounds = true
//            self.btnFollow.isHidden = true 
        }
        

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonProviderDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonProviderDetailSelectorWithIndex(index: self.tag)
        }
    }
    @IBAction func buttonPlaySelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonPlaySelectorWithIndex(index: self.tag)
        }
    }
    @IBAction func buttonImageSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonImageSelectorWithIndex(index: self.tag)
        }
    }
    @IBAction func buttonFollowSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonFollowSelectorWithIndex(index: self.tag)
        }
    }
    @IBAction func buttonShareSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonShareSelectorWithIndex(index: self.tag)
        }
    }
    @IBAction func buttonFullScreenSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonFullScreenSelectorWithIndex(index: self.tag)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgBusinessLife.image = nil

    }
    
}
