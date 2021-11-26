//
//  BusinessLifeTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS on 02/02/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol BusinessLifeCellDelegate {
    func buttonPlaySelectorWithIndex(index:Int)
    func buttonEditSelectorWithIndex(index:Int)
    func buttonDeleteSelectorWithIndex(index:Int)
    func buttonImageSelectorWithIndex(index:Int)
}

class BusinessLifeTableViewCell: UITableViewCell {
    
    
    var delegate:BusinessLifeCellDelegate?
    @IBOutlet weak var lblBusinesslifeDescription:UILabel!
    @IBOutlet weak var imgBusinessLife:UIImageView!
    @IBOutlet weak var lblSeperator:UILabel!
    @IBOutlet weak var videoPrevie:PlayerView!
    @IBOutlet weak var heightForFilePreview:NSLayoutConstraint!
    @IBOutlet weak var bottomVideoPreview:NSLayoutConstraint!
    @IBOutlet weak var stackViewEditDelete:UIStackView!
    
    @IBOutlet weak var buttonEdit:UIButton!
    @IBOutlet weak var buttonDelete:UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.imgBusinessLife.contentMode = .scaleAspectFill
            self.imgBusinessLife.clipsToBounds = true 
        }
        
        
    }

    @IBAction func buttonPlaySelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonPlaySelectorWithIndex(index: self.tag)
        }
    }
    @IBAction func buttonEditSelector(sender:UIButton){
        DispatchQueue.main.async {
            if let _ = self.delegate{
                self.delegate!.buttonEditSelectorWithIndex(index: self.tag)
            }
        }
        
    }
    @IBAction func buttonDeleteSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonDeleteSelectorWithIndex(index: self.tag)
        }
    }
    @IBAction func buttonImageSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonImageSelectorWithIndex(index: self.tag)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgBusinessLife.image = nil
        
    }
}
