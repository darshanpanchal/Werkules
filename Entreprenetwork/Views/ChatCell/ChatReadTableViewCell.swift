//
//  ChatReadTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 06/10/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol ChatReadTableViewDelegate {
    func buttonDeleteSelectedWith(index:Int)
    func buttonChatReadUserProfileDetail(index:Int)
}

class ChatReadTableViewCell: UITableViewCell {

    @IBOutlet weak var imageUser:UIImageView!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var lblUserMessage:UILabel!
    @IBOutlet weak var viewUserPhotoorAttachment:UIView!
    @IBOutlet weak var preViewImageAttachemnt:UIImageView!
    @IBOutlet weak var lblPreviewFile:UILabel!
    @IBOutlet weak var lblDate:UILabel!


    var delegate:ChatReadTableViewDelegate?

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
    private func configureAttachmentAndText(){

    }
    @IBAction func buttonDeleteChat(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonDeleteSelectedWith(index: self.tag)
        }
    }
    @IBAction func buttonProfileDetail(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonChatReadUserProfileDetail(index: self.tag)
        }
    }
}
class ChatMessage : Codable {
    var chatMessage:String = ""
    enum CodingKeys:String, CodingKey {
        case chatMessage
    }
    init(chatDetail:[String:Any]) {
        if let value = chatDetail[CodingKeys.chatMessage.rawValue],!(value is NSNull){
            self.chatMessage = "\(value)"
        }
    }

}
