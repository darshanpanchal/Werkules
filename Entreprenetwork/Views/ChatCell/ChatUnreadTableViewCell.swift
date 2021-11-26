//
//  ChatUnreadTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 06/10/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol ChatUnreadDelegate {
    func buttonChatUnreadUserDetail(index:Int)
}
class ChatUnreadTableViewCell: UITableViewCell {

    @IBOutlet weak var imageUser:UIImageView!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var lblUserMessage:UILabel!
    @IBOutlet weak var viewUserPhotoorAttachment:UIView!
    @IBOutlet weak var preViewImageAttachemnt:UIImageView!
    @IBOutlet weak var lblPreviewFile:UILabel!
    @IBOutlet weak var lblDate:UILabel!

    var delegate:ChatUnreadDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageUser.layoutIfNeeded()
        self.imageUser.layer.cornerRadius = 40//self.imageUser.bounds.width/2
        self.imageUser.clipsToBounds = true
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonProfileDetail(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonChatUnreadUserDetail(index: self.tag)
        }
    }
    
}
