//
//  FollowTableViewCell.swift
//  Entreprenetwork
//
//  Created by Darshan on 16/09/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

protocol FollowTableViewCellDelegate {
    func buttonDetailSelector(isShow:Bool,row:Int,viewcontroller:UIViewController)
    func buttonproviderdetailselector(row:Int)
    func buttoncontactdetailselector(row:Int)
    func buttonUnfollowselector(row:Int)
}
class FollowTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageProvider:UIImageView!
    @IBOutlet weak var lblProviderName:UILabel!
    
    
    @IBOutlet weak var buttonmore:UIButton!
    @IBOutlet weak var moreview:UIView!
    var isShowdetail:Bool = false
    
    var delegate:FollowTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.buttonmore.tintColor = UIColor.darkGray
        self.buttonmore.setImage(UIImage(named: "ellipsis"), for: UIControl.State.selected)
        self.buttonmore.setImage(UIImage(named: "ellipsis_selected"), for: UIControl.State.normal)
        
        // Initialization code
        self.moreview.layer.borderColor = UIColor.lightGray.cgColor
        self.moreview.layer.borderWidth = 0.5
        self.moreview.layer.cornerRadius = 6.0
        self.moreview.clipsToBounds = true
        self.clipsToBounds = false
        self.contentView.superview?.clipsToBounds =  false


        self.imageProvider.layer.cornerRadius = 36.0
        self.imageProvider.clipsToBounds = true
        self.selectionStyle = .none
        DispatchQueue.main.async {
            let handleTap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapGesture))
            self.imageProvider.addGestureRecognizer(handleTap)
            self.lblProviderName.addGestureRecognizer(handleTap)
        }
       
        
    }
    @objc func handleTapGesture(){
        
        self.delegate!.buttonproviderdetailselector(row: self.tag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonMoreSelector(sender:UIButton){
        if let _ = self.delegate{

//              popoverVC.popoverPresentationController?.delegate = self
            self.delegate!.buttonDetailSelector(isShow: self.isShowdetail , row: self.tag,viewcontroller:UIViewController())
        }
    }
    @IBAction func buttonproviderdetailselector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonproviderdetailselector(row:self.tag)
        }
    }
    @IBAction func buttoncontactdetailselector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttoncontactdetailselector(row:self.tag)
        }
    }
    @IBAction func buttonUnfollowselector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonUnfollowselector(row: self.tag)
        }
    }
    
}
