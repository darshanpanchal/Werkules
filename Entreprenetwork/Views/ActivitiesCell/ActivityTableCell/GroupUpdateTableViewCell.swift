//
//  GroupUpdateTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 03/08/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit


class GroupUpdateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var buttonmore:UIButton!
    @IBOutlet weak var buttonExpand:UIButton!
    @IBOutlet weak var detailview:UIView!
    @IBOutlet weak var moreview:UIView!
    @IBOutlet weak var imageProfile:UIImageView!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var lblUserRating:UILabel!
    @IBOutlet weak var lblTotalTransaction:UILabel!
    @IBOutlet weak var lblAvailableEarning:UILabel!
    @IBOutlet weak var lblHoldAmount:UILabel!
    @IBOutlet weak var lblTransactionEarning:UILabel!
    @IBOutlet weak var lblPromotionEarning:UILabel!
    @IBOutlet weak var buttonDetail:UIButton!
    
    @IBOutlet weak var viewdetailcontainer:UIView!
    
    var section:Int?
    var isShowdetail:Bool = false
    var isExpaded:Bool = true
    
    var delegate:GroupCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.buttonExpand.adjustsImageWhenHighlighted = false 
        self.buttonExpand.tintColor = UIColor.black
        self.buttonExpand.setImage(UIImage(named: "up_arrow"), for: UIControl.State.selected)
        self.buttonExpand.setImage(UIImage(named: "down_arrow"), for: UIControl.State.normal)
        self.buttonmore.tintColor = UIColor.darkGray
        self.buttonmore.setImage(UIImage(named: "ellipsis_selected"), for: UIControl.State.selected)
        self.buttonmore.setImage(UIImage(named: "ellipsis"), for: UIControl.State.normal)
        
        DispatchQueue.main.async {
            self.viewdetailcontainer.layer.cornerRadius = 6.0
            self.moreview.layer.borderColor = UIColor.lightGray.cgColor
            self.moreview.layer.borderWidth = 0.5
            self.moreview.layer.cornerRadius = 6.0
            self.moreview.clipsToBounds = true
            
            self.imageProfile.layer.cornerRadius = 15.0
            self.imageProfile.clipsToBounds = true
            self.imageProfile.contentMode = .scaleAspectFill
            self.imageProfile.layer.borderWidth = 0.7
            self.imageProfile.layer.borderColor = UIColor.lightGray.cgColor
            
            let underlineSeeDetail = NSAttributedString(string: "Details",
                                                                      attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
            self.buttonDetail.setAttributedTitle(underlineSeeDetail, for: .normal)
            //self.buttonDetail.titleLabel?.attributedText = underlineSeeDetail
        }
        
    }
    @IBAction func buttonDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate?.buttondetailselector(row: self.tag, section: self.section!)
        }
    }
    @IBAction func buttonCustomerDetailSelector(sender:UIButton){
        if let _ = self.delegate{
                  self.delegate?.buttoncustomerdetailselector(row: self.tag, section: self.section!)
              }
    }
    @IBAction func buttonProviderDetailSelector(sender:UIButton){
        
        if let _ = self.delegate{
                  self.delegate?.buttonproviderdetailselector(row: self.tag, section: self.section!)
              }
    }
    @IBAction func buttonContactDetailSelector(sender:UIButton){
        if let _ = self.delegate{
                  self.delegate?.buttoncontactdetailselector(row: self.tag, section: self.section!)
              }
    }
    
    
    @IBAction func buttonMoreSelector(sender:UIButton){
//        self.isShowdetail = !self.isShowdetail
       // self.buttonmore.isSelected = !self.buttonmore.isSelected
//        self.detailview.isHidden = !self.buttonmore.isSelected
        if let _ = self.delegate,let _ = self.section{
            self.delegate!.buttonDetailSelector(isShow: self.isShowdetail , row: self.tag, section: self.section!)
        }
    }
    @IBAction func buttonExpandSelector(sender:UIButton){
//        self.isExpaded = !self.isExpaded
       // self.buttonExpand.isSelected = !self.buttonExpand.isSelected
//        self.isExpaded = !self.isExpaded
        
        if let _ = self.delegate,let _ = self.section{
            self.delegate!.buttonExpandselector(isExpand: self.isExpaded, row: self.tag, section: self.section!)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
