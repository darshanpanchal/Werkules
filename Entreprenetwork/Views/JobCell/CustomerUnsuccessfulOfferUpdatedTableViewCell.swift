//
//  CustomerUnsuccessfulOfferUpdatedTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 01/09/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol CustomerUnsuccessfulOfferDelegate {
    func buttonPostDetailCellClick(inde:Int)
    func buttonPromotionDetailSelector(index:Int)
    func buttonAttachmentSelectorWith(index:Int)
}
class CustomerUnsuccessfulOfferUpdatedTableViewCell: UITableViewCell {

    var delegate:CustomerUnsuccessfulOfferDelegate?

    @IBOutlet weak var containerView:UIView!
    @IBOutlet weak var objshadowview:ShadowBackgroundView!

    @IBOutlet weak var lblJOBNote:UILabel!
    @IBOutlet weak var lblJobcanceldate:UILabel!
    @IBOutlet weak var lbltitle:UILabel!

    @IBOutlet weak var viewAcceptedPrice:UIView!
    @IBOutlet weak var lblAcceptedPriceName:UILabel!
    @IBOutlet weak var lblAcceptedPrice:UILabel!

    @IBOutlet weak var viewPromotionContainer:UIView!
    @IBOutlet weak var lblPromotionOfferAmount:UILabel!
    @IBOutlet weak var lblPromotionOffer:UILabel!
    @IBOutlet weak var btnPromotionDetail:UIButton!

    @IBOutlet weak var viewAskingPrice:UIView!
    @IBOutlet weak var lblAskingPriceName:UILabel!
    @IBOutlet weak var lblAskingPrice:UILabel!

    @IBOutlet weak var viewDocument:UIView!
    @IBOutlet weak var btnAttachment:UIButton!
    @IBOutlet weak var btnNoAttachment:UIButton!

    @IBOutlet weak var viewDateOfPost:UIView!
    @IBOutlet weak var lblDateOfPost:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Initialization code
        self.objshadowview.rounding = 15.0
        self.objshadowview.layer.cornerRadius = 15.0
        self.objshadowview.layoutIfNeeded()

        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 15.0

        let underlineSeeDetail = NSAttributedString(string: "Attachment",
                                                                         attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnAttachment.setAttributedTitle(underlineSeeDetail, for: .normal)
        //self.btnAttachment.titleLabel?.attributedText = underlineSeeDetail

        let underlineSeeDetail1 = NSAttributedString(string: "See Details",
                                                                              attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnPromotionDetail.setAttributedTitle(underlineSeeDetail1, for: .normal)
        //self.btnPromotionDetail.titleLabel?.attributedText = underlineSeeDetail
        self.lblPromotionOfferAmount.textColor = UIColor.init(hex: "F21600")

        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonPostDetailSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonPostDetailCellClick(inde: self.tag)
        }
    }
    @IBAction func buttonPromotionDetailselector(sender:UIButton){
        if let _  = self.delegate{
            self.delegate!.buttonPromotionDetailSelector(index: self.tag)
        }
    }
    @IBAction func buttonAttachmentSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonAttachmentSelectorWith(index: self.tag)
        }
    }
}
