//
//  ChatListViewController.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 05/10/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
//Controller
class ChatListViewController: UIViewController {


    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var tableViewChat:UITableView!
    @IBOutlet weak var txtSearch:UITextField!
    @IBOutlet  var chatViewBottomConstraint : NSLayoutConstraint!

    @IBOutlet var viewSearchContainer:UIView!

    var isLoadMoreSearch:Bool = false
    var currentPage:Int = 1
    var fetchPageLimit:Int = 10
    var localTimeZoneIdentifier: String { return TimeZone.current.identifier }

    var arrayOfDetail:[ChatList] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.txtSearch.delegate = self
        self.txtSearch.keyboardType = .namePhonePad
        self.txtSearch.autocorrectionType = .no
        self.txtSearch.textColor = UIColor.black
        NotificationCenter.default.addObserver(self,
                                                     selector: #selector(keyboardWillShow(notification:)),
                                                     name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                                     selector: #selector(keyboardWillHide(notification:)),
                                                     name: UIResponder.keyboardWillHideNotification, object: nil)
        self.configureTableView()



        self.viewSearchContainer.clipsToBounds = true
        self.viewSearchContainer.layer.cornerRadius = 15.0
        self.viewSearchContainer.layer.borderColor = UIColor.init(hex: "AAAAAA").cgColor
        self.viewSearchContainer.layer.borderWidth = 0.7

        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfNewMessageReceiveNotification(notification:)), name: .chatUnreadCount, object: nil)

    }
    @objc func methodOfNewMessageReceiveNotification(notification:Notification){
        if let userInfo = notification.userInfo as? [String:Any]{
            print(userInfo)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.apiRequestToSearchChatList(strText: "")
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.resetToDefalt()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.apiRequestToSearchChatList(strText: "")
        }

    }
    func configureTableView(){
          self.tableViewChat.register(UINib.init(nibName: "ChatUnreadTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatUnreadTableViewCell")
        self.tableViewChat.register(UINib.init(nibName: "ChatReadTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatReadTableViewCell")
          self.tableViewChat.showsVerticalScrollIndicator = false
          self.tableViewChat.delegate = self
          self.tableViewChat.dataSource = self
          self.tableViewChat.rowHeight = UITableView.automaticDimension
          self.tableViewChat.estimatedRowHeight = 100.0
          self.tableViewChat.reloadData()
          self.tableViewChat.tableFooterView = UIView.init()
          self.tableViewChat.allowsSelection = true


      }
    func resetToDefalt(){
        DispatchQueue.main.async {
            self.currentPage = 1
            self.isLoadMoreSearch = true
            self.arrayOfDetail.removeAll()
            self.tableViewChat.reloadData()
        }
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                          let keyboardRectangle = keyboardFrame.cgRectValue
                          var keyboardHeight = keyboardRectangle.height

                          if keyboardHeight > 350{
                              keyboardHeight = keyboardHeight - 30
                          }
                        self.chatViewBottomConstraint.constant = CGFloat(keyboardHeight)
                      }
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.chatViewBottomConstraint.constant = 10
                self.view.layoutIfNeeded()
            }
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonbackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - APIRequest
    func apiRequestToSearchChatList(strText:String){
        var dict:[String:Any] = [:]
        dict["keyword"] = "\(strText)"
      dict["limit"] = "\(self.fetchPageLimit)"
      dict["page"] = "\(self.currentPage)"
        dict["timezone"] = "\(self.localTimeZoneIdentifier)"
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSearchChatList, parameter: dict as! [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["success_data"] as? [[String:Any]]{
                    DispatchQueue.main.async {
                        var typpedText = ""
                         if let typped = self.txtSearch.text{
                            typpedText = typped
                        }
                        if self.currentPage == 1 {
                            self.arrayOfDetail.removeAll()
                        }
                        self.isLoadMoreSearch = (successData.count == self.fetchPageLimit)
                        for chatJSON in successData{
                            let objChatlist  = ChatList.init(chatDetail: chatJSON)
                            self.arrayOfDetail.append(objChatlist)
                        }
                            self.tableViewChat.reloadData()
                        }
                     }else{
                         DispatchQueue.main.async {
                             //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                         }
                     }
                 }) { (responseFail) in

               if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String]{
                      DispatchQueue.main.async {
                          if errorMessage.count > 0{
                              SAAlertBar.show(.error, message:"\(errorMessage.first!)".localizedLowercase)
                          }
                      }
                  }else{
                         DispatchQueue.main.async {
                             //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                         }
                     }
                 }
    }
    func apiRequestToDeleteChat(id:String){
        let dict:[String:Any] = ["from_id":"\(id)"]
        APIRequestClient.shared.sendAPIRequest(requestType: .DELETE, queryString:kDeleteChat, parameter: dict as! [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["success_data"] as? [String]{
                    DispatchQueue.main.async {
                        SAAlertBar.show(.error, message:"\(successData.first!)".localizedLowercase)
                        self.txtSearch.text = ""
                        self.resetToDefalt()
                        self.apiRequestToSearchChatList(strText: "")

                        }
                     }else{
                         DispatchQueue.main.async {
                           //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                         }
                     }
                 }) { (responseFail) in

               if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String]{
                      DispatchQueue.main.async {
                          if errorMessage.count > 0{
                              SAAlertBar.show(.error, message:"\(errorMessage.first!)".localizedLowercase)
                          }
                      }
                  }else{
                         DispatchQueue.main.async {
                             //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                         }
                     }
                 }
    }


    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushtoChatViewControllerWith(chatDetail:ChatList){
        if let chatViewConroller = UIStoryboard.messages.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC{
            chatViewConroller.hidesBottomBarWhenPushed = true
            chatViewConroller.strReceiverName = "\(chatDetail.businessName)"//"\(chatDetail.firstname) \(chatDetail.lastname)"
                chatViewConroller.strReceiverProfileURL = "\(chatDetail.businessLogo)"
                if let currentUser = UserDetail.getUserFromUserDefault(){
                    if currentUser.id == "\(chatDetail.fromID)"{
                        chatViewConroller.receiverID = "\(chatDetail.toID)"
                        chatViewConroller.senderID = "\(chatDetail.fromID)"
                    }else{
                        chatViewConroller.receiverID = "\(chatDetail.fromID)"
                        chatViewConroller.senderID = "\(chatDetail.toID)"
                    }
                }

                chatViewConroller.toUserTypeStr = "provider"
              chatViewConroller.isForCustomerToProvider = false
            self.navigationController?.pushViewController(chatViewConroller, animated: true)
        }
    }

}
extension ChatListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfDetail.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objChat = self.arrayOfDetail[indexPath.row]

        if indexPath.row+1 == self.arrayOfDetail.count, self.isLoadMoreSearch{ //last index
              DispatchQueue.global(qos: .background).async {
                 self.currentPage += 1
                DispatchQueue.main.async {
                    if let currenttext = self.txtSearch.text,currenttext.count > 0{
                        self.apiRequestToSearchChatList(strText:self.txtSearch.text ?? "")
                    }else{
//                        self.resetToDefalt()
                    }
                }
              }
        }
        if objChat.status == "seen"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatReadTableViewCell") as! ChatReadTableViewCell
            cell.tag = indexPath.row
            cell.lblUserName.text =  objChat.isFullNameShow ? "\(objChat.firstname) \(objChat.lastname)" : "\(objChat.firstname)" //"\(objChat.firstname) \(objChat.lastname)"
            if let imageURL = URL.init(string: "\(objChat.profilePic)"){
                autoreleasepool {
                    cell.imageUser.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                }
            }
            cell.lblDate.text  = objChat.messageReceived
            if objChat.message.count > 0{
                cell.lblUserMessage.text = objChat.message
                cell.lblUserMessage.isHidden = false
                cell.viewUserPhotoorAttachment.isHidden = true
            }else{
                cell.lblUserMessage.isHidden = true
                cell.viewUserPhotoorAttachment.isHidden = false
                if !objChat.file.isDocumentType(){
                    cell.preViewImageAttachemnt.image = UIImage.init(systemName: "photo.fill")
                    cell.lblPreviewFile.text = "Photo"
                }else{
                    cell.preViewImageAttachemnt.image = UIImage.init(systemName: "doc")
                    cell.lblPreviewFile.text = "Document"
                }
            }
            cell.delegate = self
            return  cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUnreadTableViewCell") as! ChatUnreadTableViewCell
            cell.tag = indexPath.row
            cell.lblUserName.text =  objChat.isFullNameShow ? "\(objChat.firstname) \(objChat.lastname)" : "\(objChat.firstname)"
            //cell.lblUserName.text = "\(objChat.firstname) \(objChat.lastname)"
            if let imageURL = URL.init(string: "\(objChat.profilePic)"){
                autoreleasepool {
                    cell.imageUser.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                }
            }
            cell.lblDate.text  = objChat.messageReceived
            if objChat.message.count > 0{
                cell.lblUserMessage.text = objChat.message
                cell.lblUserMessage.isHidden = false
                cell.viewUserPhotoorAttachment.isHidden = true
            }else{
                cell.lblUserMessage.isHidden = true
                cell.viewUserPhotoorAttachment.isHidden = false
                if !objChat.file.isDocumentType(){
                    cell.preViewImageAttachemnt.image = UIImage.init(systemName: "photo.fill")
                    cell.lblPreviewFile.text = "Photo"
                }else{
                    cell.preViewImageAttachemnt.image = UIImage.init(systemName: "doc")
                    cell.lblPreviewFile.text = "Document"
                }
            }
            cell.delegate = self
            return  cell

        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Push to chat detail screen
        if self.arrayOfDetail.count > indexPath.row{
            self.pushtoChatViewControllerWith(chatDetail: self.arrayOfDetail[indexPath.row])
        }
    }
}
extension ChatListViewController:ChatReadTableViewDelegate,ChatUnreadDelegate{
    func buttonChatReadUserProfileDetail(index: Int) {
        if self.arrayOfDetail.count > index{
            let objChat = self.arrayOfDetail[index]
            if objChat.fromUserType == "provider"{
                self.pushToProviderDetailScreenWithProviderId(providerID: objChat.providerID)
            }else{
                self.pushtocustomerdetailViewcontroller(dict: objChat)
            }
        }
    }
    func buttonChatUnreadUserDetail(index: Int) {
        if self.arrayOfDetail.count > index{
            let objChat = self.arrayOfDetail[index]
            if objChat.fromUserType == "provider"{
                self.pushToProviderDetailScreenWithProviderId(providerID: objChat.providerID)
            }else{
                self.pushtocustomerdetailViewcontroller(dict: objChat)
            }
        }
    }
    func buttonDeleteSelectedWith(index: Int) {
        if self.arrayOfDetail.count > index{
            let objChat = self.arrayOfDetail[index]
            let alert = UIAlertController(title: AppName, message: "Are you sure you want delete \(objChat.firstname) \(objChat.lastname)'s chat.This will permanently delete the chat", preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in

                        }))

                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in

                            self.apiRequestToDeleteChat(id: "\(objChat.userID)")

                        }))
                      alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                    self.present(alert, animated: true, completion: nil)

        }
    }
    func pushToProviderDetailScreenWithProviderId(providerID: String){
        if let objProviderDetail = UIStoryboard.main.instantiateViewController(withIdentifier: "ProviderDetailViewController") as? ProviderDetailViewController{
                   objProviderDetail.hidesBottomBarWhenPushed = true
                   objProviderDetail.providerID = providerID
                  objProviderDetail.showBookNowButton = true
            self.navigationController?.pushViewController(objProviderDetail, animated: true)
        }
    }
    func pushtocustomerdetailViewcontroller(dict:ChatList){

                let profilestoryboard  = UIStoryboard.init(name: "Profile", bundle: nil)
                if let profileViewcontroller = profilestoryboard.instantiateViewController(withIdentifier: "CustomerProfileAsProviderVC") as? CustomerProfileAsProviderVC{


                        profileViewcontroller.userId =  dict.fromID


                        profileViewcontroller.userProfile = dict.fromID

                      profileViewcontroller.userName = dict.firstname

                    profileViewcontroller.isFromMyGroupScreen = false
                    profileViewcontroller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(profileViewcontroller, animated: true)
                }
    }
    
}
extension ChatListViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        guard typpedString.count > 0 else {
            DispatchQueue.main.async {
                APIRequestClient.shared.cancelTaskWithUrl { (true) in
                    DispatchQueue.main.async {
                        self.resetToDefalt()
                    }
                }
            }
            return true
        }
        DispatchQueue.main.async {
            self.resetToDefalt()
            APIRequestClient.shared.cancelTaskWithUrl { (true) in
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                    self.apiRequestToSearchChatList(strText: typpedString)
                }
            }
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {

        DispatchQueue.main.async {
            APIRequestClient.shared.cancelTaskWithUrl { (true) in
                DispatchQueue.main.async{
                    self.resetToDefalt()
                    textField.resignFirstResponder()
                    self.apiRequestToSearchChatList(strText: "")
                }
            }
        }
        return true
    }
}

//Model
class ChatList: Codable {
    var id = "", fromID = "", toID: String = ""
    var createdAt = "", updatedAt = "", message = "", status: String = ""
    var messageType = "", file = "", firstname = "", lastname: String = ""
    var profilePic: String = ""
    var providerID: String = ""
    var businessName: String = ""
    var businessLogo: String = ""
    var quickbloxID = "", messageReceived: String = ""
    var userID = ""
    var fromUserType = ""
    var isFullNameShow:Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case fromID = "from_id"
        case userID = "user_id"
        case toID = "to_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case message, status
        case messageType = "message_type"
        case file, firstname, lastname
        case profilePic = "profile_pic"
        case providerID = "provider_id"
        case businessName = "business_name"
        case businessLogo = "business_logo"
        case quickbloxID = "quickblox_id"
        case messageReceived = "message_received"
        case fromUserType = "from_user_type"
        case isFullNameShow = "is_full_name_show"
    }

    init(chatDetail:[String:Any]) {
        if let isfullnameshow = chatDetail[CodingKeys.isFullNameShow.rawValue] as? Bool{
            self.isFullNameShow = isfullnameshow
        }
        if let value = chatDetail[CodingKeys.fromUserType.rawValue],!(value is NSNull){
            self.fromUserType = "\(value)"
        }
        if let value = chatDetail[CodingKeys.id.rawValue],!(value is NSNull){
            self.id = "\(value)"
        }
        if let value = chatDetail[CodingKeys.fromID.rawValue],!(value is NSNull){
            self.fromID = "\(value)"
        }
        if let value = chatDetail[CodingKeys.userID.rawValue],!(value is NSNull){
            self.userID = "\(value)"
        }
        if let value = chatDetail[CodingKeys.toID.rawValue],!(value is NSNull){
            self.toID = "\(value)"
        }
        if let value = chatDetail[CodingKeys.createdAt.rawValue],!(value is NSNull){
            self.createdAt = "\(value)"
        }
        if let value = chatDetail[CodingKeys.updatedAt.rawValue],!(value is NSNull){
            self.updatedAt = "\(value)"
        }
        if let value = chatDetail[CodingKeys.message.rawValue],!(value is NSNull){
            self.message = "\(value)"
        }
        if let value = chatDetail[CodingKeys.status.rawValue],!(value is NSNull){
            self.status = "\(value)"
        }
        if let value = chatDetail[CodingKeys.messageType.rawValue],!(value is NSNull){
            self.messageType = "\(value)"
        }
        if let value = chatDetail[CodingKeys.file.rawValue],!(value is NSNull){
            self.file = "\(value)"
        }
        if let value = chatDetail[CodingKeys.firstname.rawValue],!(value is NSNull){
            self.firstname = "\(value)"
        }
        if let value = chatDetail[CodingKeys.lastname.rawValue],!(value is NSNull){
            self.lastname = "\(value)"
        }
        if let value = chatDetail[CodingKeys.profilePic.rawValue],!(value is NSNull){
            self.profilePic = "\(value)"
        }
        if let value = chatDetail[CodingKeys.providerID.rawValue],!(value is NSNull){
            self.providerID = "\(value)"
        }
        if let value = chatDetail[CodingKeys.businessName.rawValue],!(value is NSNull){
            self.businessName = "\(value)"
        }
        if let value = chatDetail[CodingKeys.businessLogo.rawValue],!(value is NSNull){
            self.businessLogo = "\(value)"
        }
        if let value = chatDetail[CodingKeys.quickbloxID.rawValue],!(value is NSNull){
            self.quickbloxID = "\(value)"
        }
        if let value = chatDetail[CodingKeys.messageReceived.rawValue],!(value is NSNull){
            self.messageReceived = "\(value)"
        }
    }
}

//ViewModel
class ChatListViewModel{
    static let shared = ChatListViewModel()
    private init(){}
    var arrayOfChatList = [ChatList]()
    fileprivate func getListOfChat(){
        APIRequestClient.shared.cancelTaskWithUrl { (isCancelled) in
            //All API Cancelled before calling new API Request
            //APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString: , parameter: <#T##[String : AnyObject]?#>, isHudeShow: <#T##Bool#>, success: <#T##SUCCESS##SUCCESS##(Any) -> ()#>, fail: <#T##FAIL##FAIL##(Any) -> ()#>)


        }
    }
}
