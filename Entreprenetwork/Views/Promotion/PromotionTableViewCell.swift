//
//  PromotionTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS on 04/02/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

protocol PromotionCellDelegate {
    func buttonEditWithIndex(index:Int)
    func buttonDeleteWithIndex(index:Int)
    func buttonSeeDetailWithIndex(index:Int)
    func buttonradioSelectionWithIndex(index:Int)
}

class PromotionTableViewCell: UITableViewCell {

    @IBOutlet weak var lblPromotionTitle:UILabel!
    @IBOutlet weak var lblPromotionDescription:UILabel!
    @IBOutlet weak var btnEdit:UIButton!
    @IBOutlet weak var btnRemove:UIButton!
    @IBOutlet weak var btnSeedetail:UIButton!
    @IBOutlet weak var viewRadioButton:UIView!
    @IBOutlet weak var buttonradio:UIButton!
    
    @IBOutlet weak var objStackViewEditRemove:UIStackView!
    
    var delegate:PromotionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnEdit.imageView?.contentMode = .scaleAspectFit
        self.btnRemove.imageView?.contentMode = .scaleAspectFit
        
        let underlineSeeDetail = NSAttributedString(string: "See Details",
                                                                  attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnSeedetail.setAttributedTitle(underlineSeeDetail, for: .normal)
        //self.btnSeedetail.titleLabel?.attributedText = underlineSeeDetail
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonEditSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonEditWithIndex(index: self.tag)
        }
    }
    @IBAction func buttonRemoveSelector(sender:UIButton){
           if let _ = self.delegate{
                 self.delegate!.buttonDeleteWithIndex(index: self.tag)
           }
       }
    @IBAction func buttonSeeDetailSelector(sender:UIButton){
           if let _ = self.delegate{
                 self.delegate!.buttonSeeDetailWithIndex(index: self.tag)
           }
       }
    @IBAction func buttonRadioSelection(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonradioSelectionWithIndex(index: self.tag)
                  }
    }
}
