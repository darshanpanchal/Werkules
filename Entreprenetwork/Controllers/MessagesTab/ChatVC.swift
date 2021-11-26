//
//  ChatVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 10/09/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SimpleImageViewer
import GrowingTextView
import Firebase
import Quickblox
import QuickbloxWebRTC
import PushKit
import Reachability
import SDWebImage
import YPImagePicker
import MobileCoreServices
import Photos
import UniformTypeIdentifiers


struct UsersConstant {
    static let answerInterval: TimeInterval = 10.0
    static let pageSize: UInt = 50
    static let aps = "aps"
    static let alert = "alert"
    static let voipEvent = "VOIPCall"
}
struct UsersSegueConstant {
    static let call = "CallViewController"
}
let kReceiverID = "ChatScreenReceiverID"


class ChatVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate {
    
    @IBOutlet weak var btnAudioCall: UIButton!
    @IBOutlet weak var btnVideoCall: UIButton!
    
    @IBOutlet weak var sendMessageContainerView:MyBorderView!
    
    @IBOutlet weak var imgVieReciever:UIImageView!
    @IBOutlet weak var lblReceiverName:UILabel!
    
    
    @IBOutlet weak var btnSenderName: UIButton!
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var txtFldMessage: UITextField!
    @IBOutlet  var tableViewBottomConstraint : NSLayoutConstraint!
    @IBOutlet  var chatViewBottomConstraint : NSLayoutConstraint!
    @IBOutlet weak var lblNoMessageExists: UILabel!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnCamera: UIButton!
    
    private var inputToolbar: UIView!
    private var growingTextView: GrowingTextView!
    private var textViewBottomConstraint: NSLayoutConstraint!
    
    var arrayOfProvidersNotified:[NotifiedProviderOffer] = []
    
    var chatArr = NSMutableArray()
    var jobId = String()
    var fromId = String()
    var toId = String()
    var userName = String()
    var userProfilePath = String()
    var tapGestureRecognizer = UITapGestureRecognizer()
    var longPressRecognizer = UILongPressGestureRecognizer()
    
    var timer = Timer()
    var pickedImage = UIImage()
    var profileDict = NSDictionary()
    var isFromNotification = Bool()
    var isForJobChat = Bool()
    
    var objImagePickerController = UIImagePickerController()
    var isVideo: Bool = false
   
    lazy private var navViewController: UINavigationController = {
        let navViewController = UINavigationController()
        return navViewController
        
    }()
    
    private var answerTimer: Timer?
    private var sessionID: String?
    private weak var session: QBRTCSession?
    
    private var callUUID: UUID?
    var remoteUser:QBUUser?
    lazy private var dataSource: UsersDataSource = {
        let dataSource = UsersDataSource()
        return dataSource
    }()
    
    private var isUpdatedPayload = true

    private var voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    
    lazy private var backgroundTask: UIBackgroundTaskIdentifier = {
        let backgroundTask = UIBackgroundTaskIdentifier.invalid
        return backgroundTask
    }()
    
    
    var strReceiverProfileURL:String = ""
    var strReceiverName:String = ""
    var receiverID:String = ""
    var senderID:String = ""
    
    var isLoadMore:Bool = false
    var currentPage:Int = 1
    var fetchPageLimit:Int = 50
    
    var isForCustomerToProvider:Bool = false // 2 possiblity customer to provider and provider to customer
    
    
//    var arrayOfChat:[[String:Any]] = []
    var addnewMessage:[String:Any] = [:]

    var dictionaryChat:[String:Any] = [:]
    var dataString:[String] = []

    var toUserTypeStr:String = ""
    // we will store receiver id to user default to check it for background push notification
    // if receiver id match with background push notification from_id then refresh the page
    // if does not contain that means no chat screen does open than just show banner notification

    var localTimeZoneIdentifier: String { return TimeZone.current.identifier }

    //MARK: - UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendMessageContainerView.clipsToBounds = true
        self.sendMessageContainerView.layer.cornerRadius = 25.0
        self.txtFldMessage.inputAccessoryView = UIView()
        self.imgVieReciever.layer.cornerRadius = 17.5
        self.imgVieReciever.clipsToBounds = true
        self.imgVieReciever.layer.borderWidth = 0.5
        self.imgVieReciever.layer.borderColor = UIColor.lightGray.cgColor
        self.imgVieReciever.contentMode = .scaleAspectFill
        self.txtFldMessage.delegate = self
        
        
//        if let imgurl = URL.init(string: self.strReceiverProfileURL){
//             self.imgVieReciever.sd_setImage(with: imgurl, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
//        }
//        self.lblReceiverName.text = "\(strReceiverName)"
        
        kUserDefault.setValue(self.receiverID, forKey:  kReceiverID)
        kUserDefault.synchronize()
        
        
        /*if self.isForCustomerToProvider{
            //fetch customer to provider chat list
            self.customerToProviderChatListFetchRequest()
        }else{
            //fetch provider to customer chat list
            self.providerToCustomerChatListFetchRequest()
        }*/
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            self.customerToPrviderAndProviderToCustomerListFetchRequest()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshChatAPIRequestFromNotification(notification:)), name: .chat, object: nil)

        RegisterCell()
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
       
       NotificationCenter.default.addObserver(self,
                                              selector: #selector(keyboardWillShow(notification:)),
                                              name: UIResponder.keyboardWillShowNotification, object: nil)
       NotificationCenter.default.addObserver(self,
                                              selector: #selector(keyboardWillHide(notification:)),
                                              name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        self.callChatHeaderDetailAPI()
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self)
        UserDefaults.standard.removeObject(forKey: kReceiverID)
        kUserDefault.synchronize()
        self.isUpdatedPayload = true
        /*
        CallPermissions.check(with: .video) { granted in
            if granted {
                debugPrint("[ChatVC] granted!")
            } else {
                debugPrint("[ChatVC] granted canceled!")
            }
        }*/
    }
    
    //MARK: - User Defined Methods
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            textViewBottomConstraint.constant = -keyboardHeight - 8
            view.layoutIfNeeded()
        }
    }
    
    @objc private func tapGestureHandler() {
        view.endEditing(true)
    }
    
    func resize(_ image: UIImage) -> Data? {
        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxHeight: Float = 900
        let maxWidth: Float = 900
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        //50 percent compression
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        //let imageData = UIImageJPEGRepresentation(img!, CGFloat(compressionQuality))
        // let imageData = image.jpeg(UIImage.JPEGQuality(rawValue: CGFloat(compressionQuality))!)
        let imageData = img!.jpegData(compressionQuality: 0.3)
    
        UIGraphicsEndImageContext()
        return imageData
        //return UIImage(data: imageData!) ?? UIImage()
    }
    func presentDocumentAndImagePickerActionSheet(){
        let actionSheet: UIAlertController = UIAlertController(title: "Select Attachment", message: "", preferredStyle: .actionSheet)
               
               let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                   print("Cancel")
               }
               actionSheet.addAction(cancelActionButton)
               
//               let cameraActionButton = UIAlertAction(title: "Image", style: .default)
//               { _ in
//                self.presentImagePickerForChatUplaod()
//                //self.presentImagePickerForLicenceUplaod(isBusinessLicence: isBusinessLicence)
//               }
        let photosSelector = UIAlertAction.init(title: "Photos", style: .default) { (_) in
            DispatchQueue.main.async {
                self.objImagePickerController = UIImagePickerController()
                self.objImagePickerController.sourceType = .savedPhotosAlbum
                self.objImagePickerController.delegate = self
                self.objImagePickerController.allowsEditing = false
                self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                self.view.endEditing(true)
                self.presentImagePickerController()
            }
        }
               actionSheet.addAction(photosSelector)
               
        let cameraSelector = UIAlertAction.init(title: "Camera", style: .default) { (_) in
            if CommonClass.isSimulator{
                DispatchQueue.main.async {
                    let noCamera = UIAlertController.init(title:"Cameranotsupported", message: "", preferredStyle: .alert)
                    noCamera.addAction(UIAlertAction.init(title:"ok", style: .cancel, handler: nil))
                    self.present(noCamera, animated: true, completion: nil)
                }
            }else{
                DispatchQueue.main.async {
                    self.objImagePickerController = UIImagePickerController()
                    self.objImagePickerController.delegate = self
                    self.objImagePickerController.allowsEditing = false
                    self.objImagePickerController.sourceType = .camera
                    self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                    self.presentImagePickerController()
                }
            }
        }
        actionSheet.addAction(cameraSelector)
        
               let galleryActionButton = UIAlertAction(title: "Document", style: .default)
               { _ in
                self.presentDocumentPickerForChatUpload()
                /*
                if isBusinessLicence{
                    self.presentDocumentPickerForBusinessLicence()
                }else{
                   self.presentDocumentPickerForDriverLicence()
                }*/
               }
               actionSheet.addAction(galleryActionButton)
               
               self.present(actionSheet, animated: true, completion: nil)

    }
    func presentImagePickerController(){
           self.view.endEditing(true)
           self.objImagePickerController.modalPresentationStyle = .fullScreen
           self.present(self.objImagePickerController, animated: true, completion: nil)
          
       }
    func presentImagePickerForChatUplaod(){
        var config = YPImagePickerConfiguration()
         config.showsPhotoFilters = false
         config.library.maxNumberOfItems = 1
         config.isScrollToChangeModesEnabled = false
         config.startOnScreen = .library
         
         let picker = YPImagePicker(configuration: config)
         
         picker.didFinishPicking { [unowned picker] items, _ in
             if let photo = items.singlePhoto {
                 let aImg = photo.image
                 
                if let resizedImage = self.resize(aImg){
                    var imageName = "image.png"
                    if let strImageName = photo.asset?.value(forKey: "filename"){
                        imageName = "\(strImageName)"
                        print("\(strImageName)")
                        self.uploadAttachmentAPIRequestWith(data: resizedImage,name:"\(strImageName)")
                    }
                    
                }
                
                /*
                if isBusinessLicence{
                    self.businessLicenceData = resizedImage
                   //Upload business licence api request
                   self.uploadBusinessLogoAPIRequest(imageData: resizedImage,index:1)
                }else{
                    self.driverLicenceData = resizedImage
                   //Upload driver licence api request
                   self.uploadBusinessLogoAPIRequest(imageData: resizedImage,index:2)
                }*/
             }
             picker.dismiss(animated: true, completion: nil)
         }
        self.present(picker, animated: true, completion: nil)
        
        
    }
    func presentDocumentPickerForChatUpload(){
        let types: [UTType] = [UTType.pdf, UTType.text, UTType.rtf, UTType.spreadsheet]
        let importMenu = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        /*
        let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet]
        let importMenu = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)*/

            importMenu.allowsMultipleSelection = false
        

        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        importMenu.accessibilityValue = "2"
        self.present(importMenu, animated: true)
    }
    private func cancelCallAlert() {
        let alert = UIAlertController(title: UsersAlertConstant.checkInternet, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            
            CallKitManager.instance.endCall(with: self.callUUID) {
                debugPrint("[UsersViewController] endCall cancelCallAlert")
                
            }
            self.prepareCloseCall()
        }
        alert.addAction(cancelAction)
        present(alert, animated: false) {
        }
    }
    
    func getDateTimeDiff(dateStr:String) -> String {

        let formatter : DateFormatter = DateFormatter()
        formatter.timeZone = NSTimeZone.local
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let now = formatter.string(from: NSDate() as Date)
        let startDate = formatter.date(from: dateStr)
        let endDate = formatter.date(from: now)

        // *** create calendar object ***
        var calendar = NSCalendar.current

        // *** Get components using current Local & Timezone ***
        print(calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startDate!))

        // *** define calendar components to use as well Timezone to UTC ***
        let unitFlags = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second])
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let dateComponents = calendar.dateComponents(unitFlags, from: startDate!, to: endDate!)

        // *** Get Individual components from date ***
        let years = dateComponents.year!
        let months = dateComponents.month!
        let days = dateComponents.day!
        let hours = dateComponents.hour!
        let minutes = dateComponents.minute!
        let seconds = dateComponents.second!

        var timeAgo = ""

        if (seconds > 0){
            if seconds < 2 {
                timeAgo = "Second Ago"
            }
            else{
                timeAgo = "\(seconds) Second Ago"
            }
        }

        if (minutes > 0){
            if minutes < 2 {
                timeAgo = "Minute Ago"
            }
            else{
                timeAgo = "\(minutes) Minutes Ago"
            }
        }

        if(hours > 0){
            if minutes < 2 {
                timeAgo = "Hour Ago"
            }
            else{
                timeAgo = "\(hours) Hours Ago"
            }
        }

        if (days > 0) {
            if minutes < 2 {
                timeAgo = "Day Ago"
            }
            else{
                timeAgo = "\(days) Days Ago"
            }
        }

        if(months > 0){
            if minutes < 2 {
                timeAgo = "Month Ago"
            }
            else{
                timeAgo = "\(months) Months Ago"
            }
        }

        if(years > 0){
            if minutes < 2 {
                timeAgo = "Year Ago"
            }
            else{
                timeAgo = "\(years) Years Ago"
            }
        }

//        DLog("timeAgo is ===> \(timeAgo)")
        return timeAgo;
    }
    
    //MARK: - UITextview Delegate Methods
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    //MARK: - Register Cell
    
    func RegisterCell()  {
        self.tblChat.estimatedRowHeight = 120.0

        self.tblChat.register(UINib.init(nibName: "SenderCell", bundle: nil), forCellReuseIdentifier: "SenderCell")
        self.tblChat.register(UINib.init(nibName: "ReceiverCell", bundle: nil), forCellReuseIdentifier: "ReceiverCell")
        self.tblChat.register(UINib.init(nibName: "SenderImageCell", bundle: nil), forCellReuseIdentifier: "SenderImageCell")
        self.tblChat.register(UINib.init(nibName: "ReceiverImageCell", bundle: nil), forCellReuseIdentifier: "ReceiverImageCell")
    }
    
    //MARK: - UITableViewDatasource & Delegate MEthods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let objKeyvalue = self.dataString[indexPath.section]
        guard let objchatArray = self.dictionaryChat["\(objKeyvalue)"] as? [[String:Any]],let dataDict =  objchatArray[indexPath.row] as? [String:Any] else {
            return UITableView.automaticDimension
        }
        if (dataDict["message_type"] as! String) == "file" {
            return UITableView.automaticDimension//120 + 20
        }else {
            let myChatString = (dataDict["message"] as! String)
            let width = myChatString.width(withConstrainedHeight: 34, font: .systemFont(ofSize: 15.5))
                let intWidth = Int(width)
                
            let height = myChatString.height(withConstrainedWidth: CGFloat(intWidth), font: .systemFont(ofSize: 15.5))
                let intHeight = Int(height)
                
                if intWidth > 270 {
                    let numberofLines = Double(width/270).rounded(.up)
                    let height = 30 * numberofLines + 60
                    return CGFloat(height + 30) + 30
                }
                else if intHeight > 34 {
                    print("int height \(intHeight)")
                    return CGFloat(height + 30) + 50
                }
            }
        
       return 60 + 30
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataString.count//Array(self.dictionaryChat.keys).count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lblDate = UILabel.init(frame: CGRect.init(origin: CGPoint.init(x: 0, y: 10), size: CGSize.init(width: tableView.bounds.width, height: 30)))
        lblDate.text = self.dataString[section]//"\(Array(self.dictionaryChat.keys)[section])"
        lblDate.font = UIFont.init(name: "Avenir-Heavy", size: 17.0)!
        lblDate.textColor = UIColor.black
        lblDate.textAlignment = .center

        return  lblDate
     }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(self.arrayOfChat.count)
        if self.dataString.count > section{
            let objKeyvalue = self.dataString[section]
            if let chatArray = self.dictionaryChat["\(objKeyvalue)"] as? [[String:Any]]{
                return chatArray.count
            }
        }
        return 0//self.arrayOfChat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        let aCell = UITableViewCell()
        
        var cellIdentifier = String()
        if self.dataString.count > indexPath.section{
            let objKeyvalue = self.dataString[indexPath.section]
            if let chatArray = self.dictionaryChat["\(objKeyvalue)"] as? [[String:Any]]{
                let dataDict =  chatArray[indexPath.row]

//        let dataDict = self.arrayOfChat[indexPath.row]//self.arrayOfChat.object(at: indexPath.row) as! JSONDICTIONARY
        print( "------ \(dataDict) --------- ")
        var fromIdString = ""
        if let fromID = dataDict["from_id"]{
            print("======= \(fromID) ====== ")
            fromIdString = "\(fromID)"

        }
        
        
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
           return aCell
        }
        
        aCell.tag = indexPath.row
        
        if fromIdString == currentUser.id { // my chat
            
            if (dataDict["message_type"] as! String) == "file" {
                
                cellIdentifier = "ReceiverImageCell"
                let cell = tblChat.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ReceiverImageCell
                print("====== \(dataDict) ReceiverImageCell ")
                let chatImageUrl = (dataDict["file"] as! String)
                print( "\(chatImageUrl) =======Image ReceiverImageCell ")
               // chatImageUrl = chatImageUrl.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                if chatImageUrl.isImageType(){
                    if let imageURL = URL.init(string: chatImageUrl){
                        cell.chatImage.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "image_placeholder"), options: [], completed: nil)
                    }
                }else if chatImageUrl.isDocumentType(){
                    cell.chatImage.image = UIImage.init(named: "pdf")
                }else{
                    if let imageURL = URL.init(string: chatImageUrl){
                        cell.chatImage.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "image_placeholder"), options: [], completed: nil)
                    }
                }
                cell.selectionStyle = .none
                cell.chatImage.isUserInteractionEnabled = true
                tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showFullImage))
                cell.chatImage.tag = indexPath.row
                cell.chatImage.accessibilityValue = "\(indexPath.section)"
                cell.chatImage.addGestureRecognizer(tapGestureRecognizer)
                
                //longPressRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(deleteMyChat))
                cell.addGestureRecognizer(longPressRecognizer)
                
                if currentUser.userRoleType == .customer{
                    if let imageURL = URL.init(string: currentUser.profilePic){
                        cell.imgVwProfilePic.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "user_placeholder"), options: [], completed: nil)

                    }
                }else if currentUser.userRoleType == .provider{
                    if let businessdetail = currentUser.businessDetail,let img =  businessdetail.businessLogo as? String{
                        if let imageURL = URL.init(string: img){
                            cell.imgVwProfilePic.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "user_placeholder"), options: [], completed: nil)
                        }
                    }
                }else{
                    if let imageURL = URL.init(string: currentUser.profilePic){
                        cell.imgVwProfilePic.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "user_placeholder"), options: [], completed: nil)

                    }
                }
                
                let time = (dataDict["created_at"] as! String)
                
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateformatter.date(from: time)
                dateformatter.dateFormat = "MM/dd/yyyy hh:mm a"
                let newDate = dateformatter.string(from: date!.toLocalTime())
                if let globaldate = date{
                    let localdate = globaldate.toLocalTime()
                    let newDate = dateformatter.string(from: localdate)
                    cell.lblTime.text = newDate
                }
                if indexPath.row+1 == chatArray.count, self.isLoadMore{ //last index
                            DispatchQueue.global(qos: .background).async {
                                self.currentPage += 1
                                if self.isForCustomerToProvider{
                                    //fetch customer to provider chat list
                                    self.customerToProviderChatListFetchRequest()
                                }else{
                                    //fetch provider to customer chat list
                                    self.providerToCustomerChatListFetchRequest()
                                }
                            }
                        }
                return cell
            }else {
                
                cellIdentifier = "ReceiverCell"
                
                let cell = tblChat.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ReceiverCell
                
                cell.selectionStyle = .none
                
                let time = (dataDict["created_at"] as! String)
                
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateformatter.date(from: time)
                dateformatter.dateFormat = "MM/dd/yyyy hh:mm a"
                let newDate = dateformatter.string(from: date!)
                if let globaldate = date{
                    let localdate = globaldate.toLocalTime()
                    let newDate = dateformatter.string(from: localdate)
                    cell.lblTime.text = newDate
                }
                if let strMessage = dataDict["message"]{
                    cell.lblChatText.text = "\(strMessage)"
                }
             if currentUser.userRoleType == .customer{
                    if let imageURL = URL.init(string: currentUser.profilePic){
                        cell.imgVwProfilePic.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "user_placeholder"), options: [], completed: nil)

                    }
                }else if currentUser.userRoleType == .provider{
                    if let businessdetail = currentUser.businessDetail,let img =  businessdetail.businessLogo as? String{
                        if let imageURL = URL.init(string: img){
                            cell.imgVwProfilePic.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "user_placeholder"), options: [], completed: nil)
                        }
                    }
                }else{
                    if let imageURL = URL.init(string: currentUser.profilePic){
                        cell.imgVwProfilePic.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "user_placeholder"), options: [], completed: nil)

                    }
                }
            if indexPath.row+1 == chatArray.count, self.isLoadMore{ //last index
                       DispatchQueue.global(qos: .background).async {
                           self.currentPage += 1
                           if self.isForCustomerToProvider{
                               //fetch customer to provider chat list
                               self.customerToProviderChatListFetchRequest()
                           }else{
                               //fetch provider to customer chat list
                               self.providerToCustomerChatListFetchRequest()
                           }
                       }
                   }
                return cell
            }
        }else {
            if (dataDict["message_type"] as! String) == "file" {
                
                cellIdentifier = "SenderImageCell"
                let cell = tblChat.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SenderImageCell
                
                var chatImageUrl = (dataDict["file"] as! String)
                print("====== \(chatImageUrl) =======Image SenderImageCell")
                if chatImageUrl.isImageType(){
                       if let imageURL = URL.init(string: chatImageUrl){
                           cell.chatImage.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "image_placeholder"), options: [], completed: nil)
                       }
                }else if chatImageUrl.isDocumentType(){
                       cell.chatImage.image = UIImage.init(named: "pdf")
                }else{
                    if let imageURL = URL.init(string: chatImageUrl){
                        cell.chatImage.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "image_placeholder"), options: [], completed: nil)
                    }
                }
                if let imageURL = URL.init(string: self.strReceiverProfileURL){
                        cell.imgVwProfilePic.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "user_placeholder"), options: [], completed: nil)
                }
                cell.chatImage.isUserInteractionEnabled = true
                tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showFullImage))
                cell.chatImage.tag = indexPath.row
                cell.chatImage.accessibilityValue = "\(indexPath.section)"
                cell.chatImage.addGestureRecognizer(tapGestureRecognizer)
                cell.selectionStyle = .none
                let time = (dataDict["created_at"] as! String)
                
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateformatter.date(from: time)
                dateformatter.dateFormat = "MM/dd/yyyy hh:mm a"
                let newDate = dateformatter.string(from: date!)
                if let globaldate = date{
                    let localdate = globaldate.toLocalTime()
                    let newDate = dateformatter.string(from: localdate)
                    cell.lblTime.text = newDate
                }
                if indexPath.row+1 == chatArray.count, self.isLoadMore{ //last index
                                           DispatchQueue.global(qos: .background).async {
                                               self.currentPage += 1
                                               if self.isForCustomerToProvider{
                                                   //fetch customer to provider chat list
                                                   self.customerToProviderChatListFetchRequest()
                                               }else{
                                                   //fetch provider to customer chat list
                                                   self.providerToCustomerChatListFetchRequest()
                                               }
                                           }
                                       }
                return cell
            }
            else {
                cellIdentifier = "SenderCell"
                let cell = tblChat.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SenderCell
                cell.selectionStyle = .none
                
                let time = (dataDict["created_at"] as! String)
                
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateformatter.date(from: time)
                dateformatter.dateFormat = "MM/dd/yyyy hh:mm a"
                if let globaldate = date{
                    let localdate = globaldate.toLocalTime()
                    let newDate = dateformatter.string(from: localdate)
                    cell.lblTime.text = newDate
                }
                if let strMessage = dataDict["message"]{
                    cell.lblChatText.text = "\(strMessage)"
                }
                cell.updateChatContentCornor()
                if let imageURL = URL.init(string: self.strReceiverProfileURL){
                                                 cell.imgVwProfilePic.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "user_placeholder"), options: [], completed: nil)
                  }
                if indexPath.row+1 == chatArray.count, self.isLoadMore{ //last index
                                           DispatchQueue.global(qos: .background).async {
                                               self.currentPage += 1
                                               if self.isForCustomerToProvider{
                                                   //fetch customer to provider chat list
                                                   self.customerToProviderChatListFetchRequest()
                                               }else{
                                                   //fetch provider to customer chat list
                                                   self.providerToCustomerChatListFetchRequest()
                                               }
                                           }
                                       }
                return cell
            }
        }
            }
        }
        return aCell
    }
       @objc func refreshChatAPIRequestFromNotification(notification: Notification) {
        self.currentPage = 1
        self.getNewMesssageFromBackgroundPushNotification   ()
        /*
            if self.isForCustomerToProvider{
                //fetch customer to provider chat list
                self.customerToProviderChatListFetchRequest(isRefreshFromNotification: true)
            }else{
                //fetch provider to customer chat list
                self.providerToCustomerChatListFetchRequest(isRefreshFromNotification: true)
            }*/
    }
    // MARK: - Actions
    @IBAction func didPressAudioCall(_ sender: UIButton?) {
        DispatchQueue.main.async {
            self.call(with: QBRTCConferenceType.audio, isVideo: false)
        }
      }
    @IBAction func didPressVideoCall(_ sender: UIButton?) {
      DispatchQueue.main.async {
        
        self.call(with: QBRTCConferenceType.video, isVideo: true)
      }
    }
    @IBAction func btnBackClicked(_ sender: UIButton) {
        if let objTabView = self.navigationController?.tabBarController{
                          if let objHomeNavigation = objTabView.viewControllers?.first as? UINavigationController,let objHome = objHomeNavigation.viewControllers.first as? HomeVC{
                            objHome.arrayOfProvidersNotified = self.arrayOfProvidersNotified
                          }
               }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCameraClicked(_ sender: UIButton) {
        self.presentDocumentAndImagePickerActionSheet()
        /*
        let actionSheet: UIAlertController = UIAlertController(title: AppName, message: "", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheet.addAction(cancelActionButton)
        
        let cameraActionButton = UIAlertAction(title: "Open camera", style: .default)
        { _ in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
            else {
                SAAlertBar.show(.info, message: "camera is not available")
            }
        }
        actionSheet.addAction(cameraActionButton)
        
        let galleryActionButton = UIAlertAction(title: "Open gallery", style: .default)
        { _ in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        actionSheet.addAction(galleryActionButton)
        
        self.present(actionSheet, animated: true, completion: nil)
        */
    }
    
    @IBAction func btnSendClicked(_ sender: UIButton) {
        if self.isValidData(){
            self.postNewMessageAPIRequest()
        }
        /*
        var mesage = growingTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if mesage.isEmpty == true {
            SAAlertBar.show(.info, message: "Please enter text")
            return
        }
        
        sender.isUserInteractionEnabled = false
        
        
        var dict = JSONDICTIONARY()
        var urlstring = String()
        
        if self.isForJobChat == true {
            
            dict = [
                APIManager.Parameter.jobID : self.jobId,
                APIManager.Parameter.fromID : self.fromId,
                APIManager.Parameter.toID : self.toId,
                APIManager.Parameter.message :mesage
            ]
            
            urlstring = Url_sendMessage
        }
        else {
            
            dict = [
                APIManager.Parameter.fromID : self.fromId,
                APIManager.Parameter.toID : self.toId,
                APIManager.Parameter.message : mesage
            ]
            urlstring = Url_SendChat
        }
        
        APIManager.sharedInstance.CallAPIPost(url: urlstring, parameter: dict, complition: { (error, JSONDICTIONARY) in
            
            sender.isUserInteractionEnabled = true
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                self.growingTextView.text = ""
                
                self.getChat()
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })*/
    }
    
    @IBAction func btnSenderNameClicked(_ sender: UIButton) {
        if self.isFromNotification == true {
            return
        }
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EntrepreneurProfileVC") as! EntrepreneurProfileVC
        vc.isOtherUser = true
        vc.otherUserId = self.toId
        vc.dictEntrpreneur = profileDict
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Internal Methods
    private func hasConnectivity() -> Bool {
        let status = Reachability.instance.networkConnectionStatus()
        guard status != NetworkConnectionStatus.notConnection else {
           // showAlertView(message: UsersAlertConstant.checkInternet)
            if CallKitManager.instance.isCallStarted() == false {
                CallKitManager.instance.endCall(with: callUUID) {
                    debugPrint("[ChatVC] endCall func hasConnectivity")
                }
            }
            return false
        }
        return true
    }

    // initial Call setUp
    private func call(with conferenceType: QBRTCConferenceType, isVideo: Bool) {
        if hasConnectivity() {
            CallPermissions.check(with: conferenceType) { [self] granted in
                if granted {
                    let userIntId = Int(self.senderID)
                    let opponentsIDs:[NSNumber] = [NSNumber(value: userIntId ?? 0)]
                    let opponentsNames = [self.lblReceiverName.text]
                    if self.senderID == "<null>" || self.senderID == ""{
                        SAAlertBar.show(.info, message:"Cannot connect with this user".localizedLowercase)
                        return
                    }
                    //Create new session
                    let session = QBRTCClient.instance().createNewSession(withOpponents: opponentsIDs, with: conferenceType)
                    if session.id.isEmpty == false {
                        self.session = session
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                    appDelegate.session = session
                        }
                        self.sessionID = session.id
                        guard let uuid = UUID(uuidString: session.id) else {
                            return
                        }
                        self.callUUID = uuid
                        let profile = Profile()
                        print(profile)
                        guard profile.isFull == true else {
                            return
                        }

                        CallKitManager.instance.startCall(withUserIDs: opponentsIDs, session: session, uuid: uuid)

                        if let callViewController = UIStoryboard(name: "Call", bundle: nil).instantiateViewController(withIdentifier: "CallViewController") as? CallViewController {
                            callViewController.session = self.session
                            callViewController.usersDataSource = self.dataSource
                            callViewController.callUUID = uuid
                            callViewController.sessionConferenceType = conferenceType
                            let nav = UINavigationController(rootViewController: callViewController)
                            nav.modalTransitionStyle = .crossDissolve
                            nav.modalPresentationStyle = .overCurrentContext
                            self.present(nav , animated: false)
                            self.btnAudioCall.isEnabled = true
                            self.btnVideoCall.isEnabled = true
                            self.navViewController = nav
                        }

                        let opponentsNamesString = self.lblReceiverName.text
                        let allUsersNamesString = "\(profile.fullName),\(opponentsNamesString ?? "")"
                        let arrayUserIDs = opponentsIDs.map({"\($0)"})
                        let usersIDsString = arrayUserIDs.joined(separator: ",")
                        let allUsersIDsString = "\(profile.ID)," + usersIDsString
                       // SAAlertBar.show(.info, message:"\(allUsersIDsString)".localizedLowercase)
                        let opponentName = profile.fullName
                        let conferenceTypeString = conferenceType == .video ? "1" : "2"
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let timeStamp = formatter.string(from: Date())
                        let payload = ["message": "\(opponentName) is calling you.",
                            "ios_voip": "1",
                            UsersConstant.voipEvent: "1",
                            "sessionID": session.id,
                            "opponentsIDs": allUsersIDsString,
                            "contactIdentifier": allUsersNamesString,
                            "conferenceType" : conferenceTypeString,
                            "timestamp" : timeStamp,
                            "notification_type": isVideo ? "Videocall" : "Audiocall"
                        ]
                        let data = try? JSONSerialization.data(withJSONObject: payload,
                                                               options: .prettyPrinted)
                        var message = ""
                        if let data = data {
                            message = String(data: data, encoding: .utf8) ?? ""
                        }
                        let event = QBMEvent()
                        event.notificationType = QBMNotificationType.push
                        event.usersIDs = usersIDsString
                        event.type = QBMEventType.oneShot
                        event.message = message
                        QBRequest.createEvent(event, successBlock: { response, events in
                            debugPrint("[ChatVC] Send voip push - Success")
                        }, errorBlock: { response in
                            debugPrint("[ChatVC] Send voip push - Error")
                        })
                    } else {
                        //SVProgressHUD.showError(withStatus:"Should Login First")
                    
                    }
                }
            }
        }
    }
    
    
    //MARK: - ImagePicker Delegate Method
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        pickedImage = image!
        
        var imageName = "Image"
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
                if let fileName = (asset.value(forKey: "filename")) as? String {
                    imageName = "\(fileName)"
                }
            }
    
        
        if picker.allowsEditing {
            pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage ?? image!
        }
        if let imageData = self.resize(pickedImage){
           pickedImage = UIImage(data: imageData) ?? UIImage()
            self.uploadAttachmentAPIRequestWith(data:imageData, name: imageName,isForFileUpload: true)
        }

        
        self.dismiss(animated:true, completion: nil)
        
        
        /*
        var urlstring = String()
        if self.isForJobChat == true {
            ImageMessage.Shared.job_id = self.jobId
            urlstring = Url_sendMessage
        }
        else {
            urlstring = Url_SendChat
        }
        ImageMessage.Shared.from_id = self.fromId
        ImageMessage.Shared.to_id = self.toId
        ImageMessage.Shared.file = pickedImage
        ImageMessage.Shared.message = "Test"
        ImageMessage.Shared.vmimeType = "image/png"
        ImageMessage.Shared.vTimestamp = "profile.png"
        
        
        APIManager.sharedInstance.CallAPIToSendImageMessage(url:urlstring, parameter: ImageMessage.Shared, complition: { (error, JSONDICTIONARY) in
            
            if  let isError = JSONDICTIONARY!["isError"] as? Bool{
                
                if  isError == false{
                    print(JSONDICTIONARY as Any)
                    
                    //                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                    
                    self.growingTextView.text = ""
                    
                    self.getChat()
                    
                }
                else{
                    let message = JSONDICTIONARY!["response"] as! String
                    
                    SAAlertBar.show(.error, message:message.capitalized)
                }
            }
            
        }) */
    }
    
    @objc func refreshChat() {
//        getChat()
        
    }
    
    //MARK: - API Calls
    func customerToPrviderAndProviderToCustomerListFetchRequest(){
        //v2/chat/list
        var dict:[String:Any] = [:]
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
           return
        }
        dict["from_id"] = "\(currentUser.id)"
        dict["to_id"] = "\(self.receiverID)"
        dict["limit"] = "\(self.fetchPageLimit)"
        dict["page"] = "\(self.currentPage)"
        dict["from_user_type"] = "\(currentUser.userRoleType)"
        dict["to_user_type"] = "\(self.toUserTypeStr)"
        dict["timezone"] = "\(self.localTimeZoneIdentifier)"
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kUserToUserUpdatedChat , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in

        if let success = responseSuccess as? [String:Any],let objarrayOfChat = success["success_data"] as? [String:Any]{
           if self.currentPage == 1{
             self.dictionaryChat = [:]
           }
            if let stringArray = success["date_group_list"] as? [String]{
                self.dataString = stringArray//Array.init(objarrayOfChat.keys)
            }else{
                self.dataString = Array.init(objarrayOfChat.keys)
            }

          print(Array.init(objarrayOfChat.keys))
           self.isLoadMore = objarrayOfChat.count > 0
           if objarrayOfChat.count > 0 {
               for objChat in objarrayOfChat{
                self.dictionaryChat["\(objChat.key)"] = objChat.value
                //let offer =  OfferDetail.init(offerDetail: objOffer)//NotifiedProviderOffer.init(providersDetail: objOffer)
                  //self.arrayOfChat.append(objChat)
               }

            DispatchQueue.main.async {
                print(Array(objarrayOfChat.keys))
                print(self.dictionaryChat)
                self.tblChat.reloadData()
                self.reloadTableView()
            }
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
                // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
             }
         }
        }
    }
    func customerToProviderChatListFetchRequest(isRefreshFromNotification:Bool = false){
        self.customerToPrviderAndProviderToCustomerListFetchRequest()
        /*
        //chat/customer-provider-chat
        var dict:[String:Any] = [:]
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
           return
        }
        dict["from_id"] = "\(currentUser.id)"
        dict["to_id"] = "\(self.receiverID)"
        dict["limit"] = "\(self.fetchPageLimit)"
        dict["page"] = "\(self.currentPage)"
        dict["from_user_type"] = "\(currentUser.userRoleType)"
        dict["to_user_type"] = "\(self.toUserTypeStr)"
         
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kUsertoUserChat , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
        if let success = responseSuccess as? [String:Any],let objarrayOfChat = success["success_data"] as? [[String:Any]]{
           if self.currentPage == 1{
               self.arrayOfChat.removeAll()
           }
           self.isLoadMore = objarrayOfChat.count > 0
           if objarrayOfChat.count > 0 {
               for objChat in objarrayOfChat{
                //let offer =  OfferDetail.init(offerDetail: objOffer)//NotifiedProviderOffer.init(providersDetail: objOffer)
                  self.arrayOfChat.append(objChat)
               }
           
            DispatchQueue.main.async {
                self.tblChat.reloadData()
                self.reloadTableView()
            }
           }
          }else{
              DispatchQueue.main.async {
                  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
                 SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
             }
         }
        }*/

    }
    //fetch provider to customer chat
    func providerToCustomerChatListFetchRequest(isRefreshFromNotification:Bool = false){
        self.customerToPrviderAndProviderToCustomerListFetchRequest()
        /*
        //chat/provider-customer-chat
        var dict:[String:Any] = [:]
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
           return
        }
        dict["from_id"] = "\(currentUser.id)"
        dict["to_id"] = "\(self.receiverID)"
        dict["limit"] = "\(self.fetchPageLimit)"
        dict["page"] = "\(self.currentPage)"
        dict["from_user_type"] = "\(currentUser.userRoleType)"
        dict["to_user_type"] = "\(self.toUserTypeStr)"
        print(dict)
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kUsertoUserChat , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in

               if let success = responseSuccess as? [String:Any],let objarrayOfChat = success["success_data"] as? [[String:Any]]{
                  if self.currentPage == 1{
                      self.arrayOfChat.removeAll()
                  }

                  self.isLoadMore = objarrayOfChat.count > 0
                  if objarrayOfChat.count > 0 {
                      for objChat in objarrayOfChat{
                       //let offer =  OfferDetail.init(offerDetail: objOffer)//NotifiedProviderOffer.init(providersDetail: objOffer)
                         self.arrayOfChat.append(objChat)
                      }
                    DispatchQueue.main.async {
                        self.tblChat.reloadData()
                        self.reloadTableView()
                    }
                  }
                 }else{
                     DispatchQueue.main.async {
                         SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
                        SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                    }
                }
               }
        */
    }
    
    //post new message API request
    func postNewMessageAPIRequest(){
        DispatchQueue.main.async {
            self.txtFldMessage.text = ""
            self.txtFldMessage.resignFirstResponder()
        }
        //chat/save
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                 return
              }
        self.addnewMessage["from_id"] = "\(currentUser.id)"
        
        self.addnewMessage["to_id"] = "\(self.receiverID)"
        
        self.addnewMessage["from_user_type"] = "\(currentUser.userRoleType)"
            
        self.addnewMessage["to_user_type"] = "\(self.toUserTypeStr)"
        
        print( "---------- \(self.addnewMessage) ------ ")
        
        APIRequestClient.shared.uploadImage(requestType: .POST, queryString:kPostNewMessage , parameter: self.addnewMessage as [String:AnyObject], imageData:nil ,isFileUpload : true, isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                    print(responseSuccess)
                    ExternalClass.HideProgress()
            }
            if let success = responseSuccess as? [String:Any],let arrayOfChat = success["success_data"] as? [[String:Any]]{
//                print(self.arrayOfChat.count)
                if arrayOfChat.count > 0{
//                    for objChat in arrayOfChat{
                     //let offer =  OfferDetail.init(offerDetail: objOffer)//NotifiedProviderOffer.init(providersDetail: objOffer)
                    if self.dictionaryChat.count > 0{
                        if var updated = self.dictionaryChat["\(self.dataString.last!)"] as? [[String:Any]]{
                            updated.append(arrayOfChat.first!)
                            self.dictionaryChat["\(self.dataString.last!)"] = updated
                        }
                        DispatchQueue.main.async {
                            self.tblChat.reloadData()
                            if let updated = self.dictionaryChat["\(self.dataString.last!)"] as? [[String:Any]],updated.count > 0{
                                let indexPath = NSIndexPath(row: updated.count - 1, section: self.dataString.count - 1)
                                self.tblChat.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                            }
                        }
                    }else{
                        self.customerToPrviderAndProviderToCustomerListFetchRequest()
                    }

                        //self.arrayOfChat.append(arrayOfChat.first!)
//                    }

                }

                
                    
            }else{
                DispatchQueue.main.async {
                   // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }) { (responseFail) in
                DispatchQueue.main.async {
                    ExternalClass.HideProgress()
                }
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"]{
                DispatchQueue.main.async {
                    SAAlertBar.show(.error, message:"\(errorMessage)".localizedLowercase)
        //                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                  //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
    }
    //receive New message from background push notification
    func getNewMesssageFromBackgroundPushNotification(){
        
        self.customerToPrviderAndProviderToCustomerListFetchRequest()
        /*
        //chat/provider-customer-chat
          var dict:[String:Any] = [:]
          guard let currentUser = UserDetail.getUserFromUserDefault() else {
             return
          }
        if self.arrayOfChat.count > 0{
            var lastpage  = self.arrayOfChat.count / self.fetchPageLimit
            lastpage += 1
            self.currentPage =  lastpage
        }else{
            self.currentPage = 1
        }
     
        
          dict["from_id"] = "\(currentUser.id)"
          dict["to_id"] = "\(self.receiverID)"
          dict["limit"] = "\(self.fetchPageLimit)"
          dict["page"] = "1"//"\(self.currentPage)"
          dict["from_user_type"] = "\(currentUser.userRoleType)"
          dict["to_user_type"] = "\(self.toUserTypeStr)"
        
          print(dict)
          APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kUsertoUserChat , parameter: dict as [String:AnyObject], isHudeShow: false, success: { (responseSuccess) in

                 if let success = responseSuccess as? [String:Any],let arrayOfChat = success["success_data"] as? [[String:Any]]{
                    self.isLoadMore = arrayOfChat.count > 0
                    if arrayOfChat.count > 0 {
                        //for objChat in arrayOfChat{
                        if let objChat = arrayOfChat.last{
                            self.arrayOfChat.append(objChat)
                        }

                    }
                    DispatchQueue.main.async {
                      self.tblChat.reloadData()
                     if self.arrayOfChat.count > 0 {
                         let indexPath = NSIndexPath(row: self.arrayOfChat.count - 1, section: 0)
//                        self.tblChat.reloadRows(at: [(indexPath as IndexPath)], with: .none)
                         self.tblChat.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)
                     }
                    }
                   }else{
                       DispatchQueue.main.async {
                           SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
                          SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                      }
                  }
                 }
            */
    }
    
    
    func reloadTableView(){

            UIView.performWithoutAnimation {
                if self.dictionaryChat.keys.count > 0{
                    let indexSet: IndexSet = [0]
                   self.tblChat.reloadSections(indexSet, with: .none)
                      UIView.animate(withDuration: 0.5) {
                          self.tblChat.scrollTableViewToBottom(animated: false)
                      }
                }

              }

    }
    //Call Chat Header Detail API
    func callChatHeaderDetailAPI(){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                 return
              }
        var dict:[String:Any] = [:]
        dict["user_id"] = "\(self.receiverID)"
        
        dict["user_type"] = "\(self.toUserTypeStr)"
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kChatHeaderDetails , parameter: dict as [String:AnyObject], isHudeShow: false, success: { (responseSuccess) in

               if let success = responseSuccess as? [String:Any],let objSuccess = success["success_data"] as? [String:Any]{
                DispatchQueue.main.async {
                    if let nameStr = objSuccess["display_name"] as? String{
                        self.lblReceiverName.text = nameStr
                    }
                    if let imgurl = URL.init(string: (objSuccess["display_profile_pic"] as? String)!){
                        self.imgVieReciever.sd_setImage(with: imgurl, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                    }
                    if let quickbloxId = objSuccess["quickblox_id"] as? String{
                        self.senderID = quickbloxId
                    }
                }
                 }else{
                     DispatchQueue.main.async {
                        // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                     }
                 }
               }) { (responseFail) in
               if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String]{
                 DispatchQueue.main.async {
                     if errorMessage.count > 0{
                       //  SAAlertBar.show(.error, message:"\(errorMessage.first!)".localizedLowercase)
                     }
                 }
               }else{
                    DispatchQueue.main.async {
                      //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                    }
                }
               }
    }
    //AddNewAttachment API Request
    func uploadAttachmentAPIRequestWith(data:Data,name:String,isForFileUpload:Bool = true){
        var dict:[String:Any] = [:]
        
        DispatchQueue.main.async {
           self.txtFldMessage.text = ""
           self.txtFldMessage.resignFirstResponder()
        }
       //chat/save
       guard let currentUser = UserDetail.getUserFromUserDefault() else {
                return
             }
       dict["from_id"] = "\(currentUser.id)"
       
       dict["to_id"] = "\(self.receiverID)"
        
       dict["from_user_type"] = "\(currentUser.userRoleType)"
            
       dict["to_user_type"] = "\(self.toUserTypeStr)"
        
        
       print( "---------- \(dict) ------ ")
        APIRequestClient.shared.uploadImage(requestType: .POST, queryString:kPostNewMessage , parameter: dict as [String:AnyObject], imageData:data ,isFileUpload : true,fileName:"\(name)", isHudeShow: true, success: { (responseSuccess) in
                    DispatchQueue.main.async {
                            print(responseSuccess)
                            ExternalClass.HideProgress()
                    }
                    if let success = responseSuccess as? [String:Any],let arrayOfChat = success["success_data"] as? [[String:Any]]{
//                        print(self.arrayOfChat.count)
                        /*if arrayOfChat.count > 0{
                                self.arrayOfChat.append(arrayOfChat.first!)
                        }*/
                        if var updated = self.dictionaryChat["\(self.dataString.last!)"] as? [[String:Any]]{
                            updated.append(arrayOfChat.first!)
                            self.dictionaryChat["\(self.dataString.last!)"] = updated

                            DispatchQueue.main.async {
                                self.tblChat.reloadData()
                                if let updated = self.dictionaryChat["\(self.dataString.last!)"] as? [[String:Any]],updated.count > 0{
                                    let indexPath = NSIndexPath(row: updated.count - 1, section: self.dataString.count - 1)
                                    self.tblChat.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                                }
                            }
                        }
                        /*DispatchQueue.main.async {
                            print(self.arrayOfChat.count)
                            self.tblChat.reloadData()
                            if self.arrayOfChat.count > 0 {
                                let indexPath = NSIndexPath(row: self.arrayOfChat.count - 1, section: 0)
                                self.tblChat.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                            }
                            /*NotificationCenter.default.addObserver(self,
                                                                   selector: #selector(self.keyboardWillShow(notification:)),
                                                                   name: UIResponder.keyboardWillShowNotification, object: nil)
                            NotificationCenter.default.addObserver(self,
                                                                   selector: #selector(self.keyboardWillHide(notification:)),
                                                                   name: UIResponder.keyboardWillHideNotification, object: nil)*/
                        }*/
                        
                            
                    }else{
                        DispatchQueue.main.async {
                           // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                        }
                    }
                }) { (responseFail) in
                        DispatchQueue.main.async {
                            ExternalClass.HideProgress()
                        }
                    if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"]{
                        DispatchQueue.main.async {
                            SAAlertBar.show(.error, message:"\(errorMessage)".localizedLowercase)
                        }
                    }else{
                        DispatchQueue.main.async {
                          //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                        }
                    }
                }
    }
    
    func isValidData()->Bool{
        guard let newmessage = self.txtFldMessage.text?.trimmingCharacters(in: .whitespacesAndNewlines),newmessage.count > 0 else{
                   SAAlertBar.show(.error, message:"Please enter message".localizedLowercase)
                   return false
        }
        self.addnewMessage["message"] = "\(newmessage)"
        
        return true
    }
    func getChat() {
        
        var dict = JSONDICTIONARY()
        var urlstring = String()
        
        if self.isForJobChat == true {
            dict = [
                APIManager.Parameter.limit : "100",
                APIManager.Parameter.page : "1",
                APIManager.Parameter.jobID : self.jobId,
                APIManager.Parameter.fromID : self.fromId,
                APIManager.Parameter.toID : self.toId
            ]
            
            urlstring = Url_messageList
        }
        else {
            dict = [
                APIManager.Parameter.limit : "100",
                APIManager.Parameter.page : "1",
                APIManager.Parameter.fromID : self.fromId,
                APIManager.Parameter.toID : self.toId
            ]
            
            urlstring = Url_ChatList
        }
        
        APIManager.sharedInstance.CallAPIPost(url: urlstring, parameter: dict, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                UserDefaults.standard.set(true, forKey: "hideActivity")
                
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                if (dataDict["data"] as! NSArray).count == 0 {
                    
                    self.tblChat.isHidden = true
                    self.lblNoMessageExists.isHidden = false
                }
                else {
                    self.tblChat.isHidden = false
                    self.lblNoMessageExists.isHidden = true
                    
                    self.chatArr = (dataDict["data"] as! NSArray).mutableCopy() as! NSMutableArray
                    
                    self.tblChat.reloadData()
                    
                    if self.chatArr.count > 0 {
                        let indexPath = NSIndexPath(row: self.chatArr.count - 1, section: 0)
                        self.tblChat.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                    }
                }
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    
    @objc func showFullImage (sender : UITapGestureRecognizer ) {
        print(sender.view?.tag)
        print(sender.view?.accessibilityValue)

        let tappedView = sender.view as! UIImageView
        print(tappedView.tag)
        if let sectionValue = tappedView.accessibilityValue{
            if let section = Int("\(sectionValue)"){
                if self.dataString.count > section{
                    if let chat = self.dictionaryChat["\(self.dataString[section])"] as? [[String:Any]] {
                        let dataDict = chat[tappedView.tag]
                        var chatImageUrl = (dataDict["file"] as! String)
                        self.presentWebViewDetailPageWith(strTitle: "Attachment", strURL: "\(chatImageUrl)")
                    }
                }
            }

        }
        

        /*
        
         
        let configuration = ImageViewerConfiguration { config in
            config.imageView = tappedView
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        
        present(imageViewerController, animated: true)
         */
    }
    func presentWebViewDetailPageWith(strTitle:String,strURL:String){
               
               if let attachmentViewController = UIStoryboard.profile.instantiateViewController(withIdentifier: "ConditionPolicyVC") as? ConditionPolicyVC{
                   attachmentViewController.strURL = strURL
                   attachmentViewController.strTitle = strTitle
                   attachmentViewController.modalPresentationStyle = .fullScreen
                   self.navigationController?.present(attachmentViewController, animated: true, completion: nil)
               }
           }
    @objc func deleteMyChat(sender : UILongPressGestureRecognizer) {
        
        let touchPoint = sender.location(in: tblChat)
        var selectedRow = Int()
        
        if let indexPath = tblChat.indexPathForRow(at: touchPoint) {
            
            selectedRow = indexPath.row
            
            tblChat.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        
        let alert = UIAlertController(title: AppName, message: "Are you sure you want to delete this message?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
            self.tblChat.deselectRow(at: NSIndexPath(row: selectedRow, section: 0) as IndexPath, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
            
            self.tblChat.deselectRow(at: NSIndexPath(row: selectedRow, section: 0) as IndexPath, animated: true)
            
            if let indexPath = self.tblChat.indexPathForRow(at: touchPoint) {
                
                let dataDict = self.chatArr.object(at: indexPath.row) as! NSDictionary
                let messageID = dataDict["id"] as! Int
                
                let dict = [
                    APIManager.Parameter.messageID : String(messageID)
                ]
                
                APIManager.sharedInstance.CallAPIPost(url: Url_deleteMyChat, parameter: dict, complition: { (error, JSONDICTIONARY) in
                    
                    let isError = JSONDICTIONARY!["isError"] as! Bool
                    
                    if  isError == false{
                        print(JSONDICTIONARY as Any)
                        
                        self.chatArr.removeObject(at: indexPath.row)
                        self.tblChat.reloadData()
                    }
                    else{
                        let message = JSONDICTIONARY!["response"] as! String
                        
                        SAAlertBar.show(.error, message:message.capitalized)
                    }
                })
            }
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Keyboard notification
    
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
                    self.view.layoutIfNeeded()
                      }
                
                        self.reloadTableView()
                        /*if self.arrayOfChat.count > 0 {
//                        self.tblChat.setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: false)
                        
                          let indexPath = NSIndexPath(row: self.arrayOfChat.count - 1, section: 0)
                          self.tblChat.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                      }*/
                
            }
        }
      
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.chatViewBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func layoutTableView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.tblChat.superview?.layoutIfNeeded()
        }, completion: nil)
    }
}

extension String {
    public func isImageType() -> Bool {
        // image formats which you want to check
        let imageFormats = ["jpg","JPG","PNG", "png", "gif","jpeg","JPEG"]

        if URL(string: self) != nil  {

            let extensi = (self as NSString).pathExtension

            return imageFormats.contains(extensi)
        }
        return false
    }
    public func isDocumentType() -> Bool {
        // image formats which you want to check
        let imageFormats = ["pdf","PDF","DOC","doc"]

        if URL(string: self) != nil  {

            let extensi = (self as NSString).pathExtension

            return imageFormats.contains(extensi)
        }
        return false
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        
        return ceil(boundingBox.width)
    }
}


// MARK: - QBRTCClientDelegate
extension ChatVC: QBRTCClientDelegate {
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if CallKitManager.instance.isCallStarted() == false,
            let sessionID = self.sessionID,
            sessionID == session.id,
            session.initiatorID == userID || isUpdatedPayload == false {
            CallKitManager.instance.endCall(with: callUUID)
            prepareCloseCall()
        }
    }
    func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        
    }
    private func invalidateAnswerTimer() {
        if self.answerTimer != nil {
            self.answerTimer?.invalidate()
            self.answerTimer = nil
        }
    }
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        if self.session != nil {
            session.rejectCall(["reject": "busy"])
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.session?.rejectCall(["reject": "busy"])
            }
            return
        }
        invalidateAnswerTimer()
        
        self.session = session
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.session = session
                }
        if let currentCall = CallKitManager.instance.currentCall() {
            //open by VOIP Push

            CallKitManager.instance.setupSession(session)
            if currentCall.status == .ended {
                CallKitManager.instance.setupSession(session)
                CallKitManager.instance.endCall(with: currentCall.uuid)
                session.rejectCall(["reject": "busy"])
                prepareCloseCall()
                } else {
                var opponentIDs = [session.initiatorID]
                let profile = Profile()
                guard profile.isFull == true else {
                    return
                }
                for userID in session.opponentsIDs {
                    if userID.uintValue != profile.ID {
                        opponentIDs.append(userID)
                    }
                }
                
                prepareCallerNameForOpponentIDs(opponentIDs) { (callerName) in
                    CallKitManager.instance.updateIncomingCall(withUserIDs: session.opponentsIDs,
                                                               outCallerName: callerName,
                                                               session: session,
                                                               uuid: currentCall.uuid)
                }
            }
        } else {
            //open by call
            
            if let uuid = UUID(uuidString: session.id) {
                callUUID = uuid
                sessionID = session.id
                
                var opponentIDs = [session.initiatorID]
                let profile = Profile()
                guard profile.isFull == true else {
                    return
                }
                for userID in session.opponentsIDs {
                    if userID.uintValue != profile.ID {
                        opponentIDs.append(userID)
                    }
                }
                
                prepareCallerNameForOpponentIDs(opponentIDs) { [weak self] (callerName) in
                    self?.reportIncomingCall(withUserIDs: opponentIDs,
                                             outCallerName: callerName,
                                             session: session,
                                             uuid: uuid)
                }
            }
        }
    }
    
    private func setupAnswerTimerWithTimeInterval(_ timeInterval: TimeInterval) {
        if self.answerTimer != nil {
            self.answerTimer?.invalidate()
            self.answerTimer = nil
        }
        
        self.answerTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                target: self,
                                                selector: #selector(endCallByTimer),
                                                userInfo: nil,
                                                repeats: false)
    }
    

    
    @objc private func endCallByTimer() {
        invalidateAnswerTimer()
        
        if let endCall = CallKitManager.instance.currentCall() {
            CallKitManager.instance.endCall(with: endCall.uuid) {
                debugPrint("[ChatVC] endCall sessionDidClose")
            }
        }
        prepareCloseCall()
    }
    private func prepareCallerNameForOpponentIDs(_ opponentIDs: [NSNumber], completion: @escaping (String) -> Void)  {
        var callerName = ""
        var opponentNames = [String]()
        var newUsers = [String]()
        for userID in opponentIDs {
            
            // Getting recipient from users.
            if let user = dataSource.user(withID: userID.uintValue),
                let fullName = user.fullName {
                opponentNames.append(fullName)
            } else {
                newUsers.append(userID.stringValue)
            }
           
        }
        
        if newUsers.isEmpty == false {
            
            QBRequest.users(withIDs: newUsers, page: nil, successBlock: { [weak self] (respose, page, users) in
                if users.isEmpty == false {
                    self?.dataSource.update(users: users)
                    for user in users {
                        opponentNames.append(user.fullName ?? user.login ?? "")
                    }
                    callerName = opponentNames.joined(separator: ", ")
                    completion(callerName)
                }
            }) { (respose) in
                for userID in newUsers {
                    opponentNames.append(userID)
                }
                callerName = opponentNames.joined(separator: ", ")
                completion(callerName)
            }
        } else {
            callerName = opponentNames.joined(separator: ", ")
            completion(callerName)
        }
    }
    
    private func reportIncomingCall(withUserIDs userIDs: [NSNumber], outCallerName: String, session: QBRTCSession, uuid: UUID) {
        if hasConnectivity() {
            CallKitManager.instance.reportIncomingCall(withUserIDs: userIDs,
                                                       outCallerName: outCallerName,
                                                       session: session,
                                                       sessionID: session.id,
                                                       sessionConferenceType: session.conferenceType,
                                                       uuid: uuid,
                                                       onAcceptAction: { [weak self] (isAccept) in
                                                        guard let self = self else {
                                                            return
                                                        }
                                                        if isAccept == true {
                                                            self.openCall(withSession: session, uuid: uuid, sessionConferenceType: session.conferenceType)
                                                        } else {
                                                            debugPrint("[ChatVC] endCall reportIncomingCall")
                                                        }
                                                        
                }, completion: { (isOpen) in
                    debugPrint("[ChatVC] callKit did presented")
            })
        } else {
            
        }
    }
    
    private func openCall(withSession session: QBRTCSession?, uuid: UUID, sessionConferenceType: QBRTCConferenceType) {
        if hasConnectivity() {
            if let callViewController = UIStoryboard(name: "Call", bundle: nil).instantiateViewController(withIdentifier: "CallViewController") as? CallViewController{
                if let qbSession = session {
                    callViewController.session = qbSession
                }
                callViewController.usersDataSource = self.dataSource
                callViewController.callUUID = uuid
                callViewController.sessionConferenceType = sessionConferenceType
                self.navViewController = UINavigationController(rootViewController: callViewController)
                self.navViewController.modalPresentationStyle = .fullScreen
                self.navViewController.modalTransitionStyle = .crossDissolve
                self.present(self.navViewController, animated: false)
            } else {
                return
            }
        } else {
            return
        }
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        if let sessionID = self.session?.id,
            sessionID == session.id {
            if let endedCall = CallKitManager.instance.currentCall() {
                CallKitManager.instance.endCall(with: endedCall.uuid) {
                    debugPrint("[ChatVC] endCall sessionDidClose")
                }
            }
            prepareCloseCall()
        }
    }
    // MARK: - Helpers
    private func setupToolbarButtonsEnabled(_ enabled: Bool) {
        guard let toolbarItems = toolbarItems, toolbarItems.isEmpty == false else {
            return
        }
        for item in toolbarItems {
            item.isEnabled = enabled
        }
    }
    
    
    private func setupToolbarButtons() {
        setupToolbarButtonsEnabled(dataSource.selectedUsers.count > 0)
        if dataSource.selectedUsers.count > 4 {
            btnVideoCall.isEnabled = true
        }
    }
    
    private func prepareCloseCall() {
        if self.navViewController.presentingViewController?.presentedViewController == self.navViewController {
            self.navViewController.view.isUserInteractionEnabled = false
            self.navViewController.dismiss(animated: false)
        }
        self.callUUID = nil
        self.session = nil
        self.sessionID = nil
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.session = nil
        }
        if QBChat.instance.isConnected == false {
            self.connectToChat()
        }
        self.setupToolbarButtons()
       self.dismiss(animated:true, completion:nil)
    }
    
    private func connectToChat(success:QBChatCompletionBlock? = nil) {
        let profile = Profile()
        guard profile.isFull == true else {
            return
        }
        
        QBChat.instance.connect(withUserID: profile.ID,
                                password:  profile.password,
                                completion: { [weak self] error in
                                    guard let self = self else { return }
                                    if let error = error {
                                        if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                            self.logoutAction()
                                        } else {
                                            debugPrint("[ChatVC] login error response:\n \(error.localizedDescription)")
                                        }
                                        success?(error)
                                    } else {
                                        success?(nil)
                                        //did Login action
                                        //SVProgressHUD.dismiss()
                                    }
        })
    }
}

extension ChatVC: PKPushRegistryDelegate {
    // MARK: - PKPushRegistryDelegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
    
        guard let voipToken = registry.pushToken(for: .voIP) else {
            return
        }
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNSVOIP
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = voipToken
        
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
            debugPrint("[ChatVC] Create Subscription request - Success")
        }, errorBlock: { response in
            debugPrint("[ChatVC] Create Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: deviceIdentifier, successBlock: { response in
            UIApplication.shared.unregisterForRemoteNotifications()
            debugPrint("[ChatVC] Unregister Subscription request - Success")
        }, errorBlock: { error in
            debugPrint("[ChatVC] Unregister Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {
        
        
        //in case of bad internet we check how long the VOIP Push was delivered for call(1-1)
        //if time delivery is more than “answerTimeInterval” - return
        if type == .voIP,
            payload.dictionaryPayload[UsersConstant.voipEvent] != nil {
            if let timeStampString = payload.dictionaryPayload["timestamp"] as? String,
                let opponentsIDsString = payload.dictionaryPayload["opponentsIDs"] as? String {
                let opponentsIDsArray = opponentsIDsString.components(separatedBy: ",")
                if opponentsIDsArray.count == 2 {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    if let startCallDate = formatter.date(from: timeStampString) {
                        if Date().timeIntervalSince(startCallDate) > QBRTCConfig.answerTimeInterval() {
                            debugPrint("[ChatVC] timeIntervalSinceStartCall > QBRTCConfig.answerTimeInterval")
                            return
                        }
                    }
                }
            }
        }

        let application = UIApplication.shared
        if type == .voIP,
            payload.dictionaryPayload[UsersConstant.voipEvent] != nil,
            application.applicationState == .background {
            var opponentsIDs: [String]? = nil
            var opponentsNumberIDs: [NSNumber] = []
            var opponentsNamesString = "incoming call. Connecting..."
            var sessionID: String? = nil
            var callUUID = UUID()
            var sessionConferenceType = QBRTCConferenceType.audio
            self.isUpdatedPayload = false
            
            if let opponentsIDsString = payload.dictionaryPayload["opponentsIDs"] as? String,
                let allOpponentsNamesString = payload.dictionaryPayload["contactIdentifier"] as? String,
                let sessionIDString = payload.dictionaryPayload["sessionID"] as? String,
                let callUUIDPayload = UUID(uuidString: sessionIDString) {
                self.isUpdatedPayload = true
                self.sessionID = sessionIDString
                sessionID = sessionIDString
                callUUID = callUUIDPayload
                if let conferenceTypeString = payload.dictionaryPayload["conferenceType"] as? String {
                    sessionConferenceType = conferenceTypeString == "1" ? QBRTCConferenceType.video : QBRTCConferenceType.audio
                }
                
                let profile = Profile()
                guard profile.isFull == true else {
                    return
                }
                let opponentsIDsArray = opponentsIDsString.components(separatedBy: ",")
                
                var opponentsNumberIDsArray = opponentsIDsArray.compactMap({NSNumber(value: Int($0)!)})
                var allOpponentsNamesArray = allOpponentsNamesString.components(separatedBy: ",")
                for i in 0...opponentsNumberIDsArray.count - 1 {
                    if opponentsNumberIDsArray[i].uintValue == profile.ID {
                        opponentsNumberIDsArray.remove(at: i)
                        allOpponentsNamesArray.remove(at: i)
                        break
                    }
                }
                opponentsNumberIDs = opponentsNumberIDsArray
                opponentsIDs = opponentsNumberIDs.compactMap({ $0.stringValue })
                opponentsNamesString = allOpponentsNamesArray.joined(separator: ", ")
            }
            
            let fetchUsersCompletion = { [weak self] (usersIDs: [String]?) -> Void in
                if let opponentsIDs = usersIDs {
                    QBRequest.users(withIDs: opponentsIDs, page: nil, successBlock: { [weak self] (respose, page, users) in
                        if users.isEmpty == false {
                            self?.dataSource.update(users: users)
                        }
                    }) { (response) in
                        debugPrint("[ChatVC] error fetch usersWithIDs")
                    }
                }
            }

            self.setupAnswerTimerWithTimeInterval(QBRTCConfig.answerTimeInterval())
            CallKitManager.instance.reportIncomingCall(withUserIDs: opponentsNumberIDs,
                                                       outCallerName: opponentsNamesString,
                                                       session: nil,
                                                       sessionID: sessionID,
                                                       sessionConferenceType: sessionConferenceType,
                                                       uuid: callUUID,
                                                       onAcceptAction: { [weak self] (isAccept) in
                                                        guard let self = self else {
                                                            return
                                                        }
                                                        
                                                        if let session = self.session {
                                                            if isAccept == true {
                                                                self.openCall(withSession: session,
                                                                              uuid: callUUID,
                                                                              sessionConferenceType: sessionConferenceType)
                                                                debugPrint("[ChatVC]  onAcceptAction")
                                                            } else {
                                                                session.rejectCall(["reject": "busy"])
                                                                debugPrint("[ChatVC] endCallAction")
                                                            }
                                                        } else {
                                                            if isAccept == true {
                                                                self.openCall(withSession: nil,
                                                                              uuid: callUUID,
                                                                              sessionConferenceType: sessionConferenceType)
                                                                debugPrint("[ChatVC]  onAcceptAction")
                                                            } else {
                                                                
                                                                debugPrint("[ChatVC] endCallAction")
                                                            }
                                                            self.setupAnswerTimerWithTimeInterval(UsersConstant.answerInterval)
                                                            self.prepareBackgroundTask()
                                                        }
                                                        completion()
                                                        
                }, completion: { (isOpen) in
                    self.prepareBackgroundTask()
                    self.setupAnswerTimerWithTimeInterval(QBRTCConfig.answerTimeInterval())
                    if QBChat.instance.isConnected == false {
                        self.connectToChat { (error) in
                            if error == nil {
                                fetchUsersCompletion(opponentsIDs)
                            }
                        }
                    } else {
                        fetchUsersCompletion(opponentsIDs)
                    }
                    debugPrint("[ChatVC] callKit did presented")
            })
        }
    }
    
    private func prepareBackgroundTask() {
        let application = UIApplication.shared
        if application.applicationState == .background && self.backgroundTask == .invalid {
            self.backgroundTask = application.beginBackgroundTask(expirationHandler: {
                application.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = UIBackgroundTaskIdentifier.invalid
            })
        }
    }
}

// MARK: - SettingsViewControllerDelegate
extension ChatVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.isValidData(){
            self.postNewMessageAPIRequest()
        }
        return true
    }
}
extension ChatVC:UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
           print(urls)
            if urls.count > 0,let fileURL = urls.first{
                if FileManager.default.fileExists(atPath: fileURL.path){
                    print("yes")
                    if let data = self.loadFileFromLocalPath(fileURL.path){
                        
                        var fileName = "file.pdf"
                        print("\(fileURL.lastPathComponent)")
                        self.uploadAttachmentAPIRequestWith(data: data,name: "\(fileURL.lastPathComponent)")
                        /*
                        if controller.accessibilityValue == "1"{
                            self.businessLicenceData = data
                            //Upload Business Licenece document
                            self.uploadBusinessLicenceAPIRequest(fileData: data)
                        }else if controller.accessibilityValue == "2"{
                            self.driverLicenceData = data
                            //Upload Driver Licenece document
                            self.uploadDriverLicenceAPIRequest(fileData: data)
                        } */
                    }
                }else{
                    print("false")
                }
            }
        }

         func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true, completion: nil)
        }
    func loadFileFromLocalPath(_ localFilePath: String) ->Data? {
       return try? Data(contentsOf: URL(fileURLWithPath: localFilePath))
    }
    
    
}
extension ChatVC {
    private func logoutAction() {
        if QBChat.instance.isConnected == false {
           // SVProgressHUD.showError(withStatus: "Error")
            return
        }
//        SVProgressHUD.show(withStatus: UsersAlertConstant.logout)
//        SVProgressHUD.setDefaultMaskType(.clear)

        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }
        let uuidString = identifierForVendor.uuidString
        #if targetEnvironment(simulator)
        disconnectUser()
        #else
        QBRequest.subscriptions(successBlock: { (response, subscriptions) in

            if let subscriptions = subscriptions {
                for subscription in subscriptions {
                    if let subscriptionsUIUD = subscriptions.first?.deviceUDID,
                        subscriptionsUIUD == uuidString,
                        subscription.notificationChannel == .APNSVOIP {
                        self.unregisterSubscription(forUniqueDeviceIdentifier: uuidString)
                        return
                    }
                }
            }
            self.disconnectUser()

        }) { response in
            if response.status.rawValue == 404 {
                self.disconnectUser()
            }
        }
        #endif
    }

    private func disconnectUser() {
        QBChat.instance.disconnect(completionBlock: { error in
            if let error = error {
              //  SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            self.logOut()
        })
    }

    private func unregisterSubscription(forUniqueDeviceIdentifier uuidString: String) {
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: uuidString, successBlock: { response in
            UIApplication.shared.unregisterForRemoteNotifications()
            self.disconnectUser()
        }, errorBlock: { error in
            if let error = error.error {
               // SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
           // SVProgressHUD.dismiss()
        })
    }

    private func logOut() {
        QBRequest.logOut(successBlock: { [weak self] response in
            //ClearProfile
            Profile.clearProfile()
            //SVProgressHUD.dismiss()
            //Dismiss Settings view controller
            self?.dismiss(animated: false)

            DispatchQueue.main.async(execute: {
                self?.navigationController?.popToRootViewController(animated: false)
            })
        }) { response in
            debugPrint("QBRequest.logOut error\(response)")
        }
    }
}
class PaddingLabel: UILabel {

   @IBInspectable var topInset: CGFloat = 5.0
   @IBInspectable var bottomInset: CGFloat = 5.0
   @IBInspectable var leftInset: CGFloat = 5.0
   @IBInspectable var rightInset: CGFloat = 5.0

   override func drawText(in rect: CGRect) {
      let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
   }

   override var intrinsicContentSize: CGSize {
      get {
         var contentSize = super.intrinsicContentSize
         contentSize.height += topInset + bottomInset
         contentSize.width += leftInset + rightInset
         return contentSize
      }
   }
}
extension UITableView {
    func scrollTableViewToBottom(animated: Bool) {
        guard let dataSource = dataSource else { return }

        var lastSectionWithAtLeasOneElements = (dataSource.numberOfSections?(in: self) ?? 1) - 1

        while dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeasOneElements) < 1 {
            lastSectionWithAtLeasOneElements -= 1
        }

        let lastRow = dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeasOneElements) - 1

        guard lastSectionWithAtLeasOneElements > -1 && lastRow > -1 else { return }

        let bottomIndex = IndexPath(item: lastRow, section: lastSectionWithAtLeasOneElements)
        scrollToRow(at: bottomIndex, at: .bottom, animated: animated)
    }
}

