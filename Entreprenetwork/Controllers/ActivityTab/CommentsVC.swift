//
//  CommentsVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 26/12/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import GrowingTextView
import Firebase

class CommentsVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate {
    
    @IBOutlet weak var tblComments: UITableView!
    @IBOutlet weak var txtFieldComment: UITextField!
    @IBOutlet weak var lblNoComments:UILabel!
    @IBOutlet weak var btnSend: UIButton!
    
    var index = Int()
    var activityID = String()
    var isForActivity = Bool()
    var arrComments = NSArray()
    
    var isEditingRow = Bool()
    var editingRowIndex = Int()
    
    private var inputToolbar: UIView!
    private var growingTextView: GrowingTextView!
    private var textViewBottomConstraint: NSLayoutConstraint!
    
    //MARK: - UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        RegisterCell()
        
        // *** Create Toolbar
        inputToolbar = UIView()
        inputToolbar.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        inputToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputToolbar)
        
        // *** Create GrowingTextView ***
        growingTextView = GrowingTextView()
        growingTextView.delegate = self
        growingTextView.layer.cornerRadius = 4.0
        growingTextView.maxLength = 200
        growingTextView.maxHeight = 70
        growingTextView.trimWhiteSpaceWhenEndEditing = true
        growingTextView.placeholder = "Say something..."
        growingTextView.placeholderColor = UIColor(white: 0.8, alpha: 1.0)
        growingTextView.minHeight = 30
        growingTextView.maxLength = 100
        growingTextView.font = UIFont.systemFont(ofSize: 15)
        growingTextView.translatesAutoresizingMaskIntoConstraints = false
        inputToolbar.addSubview(growingTextView)
        
        inputToolbar.addSubview(btnSend)
        
        // *** Autolayout ***
        let topConstraint = growingTextView.topAnchor.constraint(equalTo: inputToolbar.topAnchor, constant: 8)
        topConstraint.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            inputToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            topConstraint
        ])
        
        if #available(iOS 11, *) {
            textViewBottomConstraint = growingTextView.bottomAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.bottomAnchor, constant: -8)
            NSLayoutConstraint.activate([
                growingTextView.leadingAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.leadingAnchor, constant: 8),
                growingTextView.trailingAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.trailingAnchor, constant: -40),
                textViewBottomConstraint
            ])
            
            btnSend.topAnchor.constraint(equalTo: growingTextView.topAnchor).isActive = true
            btnSend.leadingAnchor.constraint(equalTo: growingTextView.trailingAnchor, constant: 10).isActive = true
            btnSend.widthAnchor.constraint(equalToConstant: 25).isActive = true
            btnSend.heightAnchor.constraint(equalToConstant: 25).isActive = true
            
            
        } else {
            textViewBottomConstraint = growingTextView.bottomAnchor.constraint(equalTo: inputToolbar.bottomAnchor, constant: -8)
            NSLayoutConstraint.activate([
                growingTextView.leadingAnchor.constraint(equalTo: inputToolbar.leadingAnchor, constant: 8),
                growingTextView.trailingAnchor.constraint(equalTo: inputToolbar.trailingAnchor, constant: -8),
                textViewBottomConstraint
            ])
        }
        
        //        // *** Listen to keyboard show / hide ***
        //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        //
        //        // *** Hide keyboard when tapping outside ***
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        //        view.addGestureRecognizer(tapGesture)
        
        
        
        
        if self.arrComments.count == 0 {
            tblComments.isHidden = true
            lblNoComments.isHidden = false
        }
        else {
            tblComments.isHidden = false
            lblNoComments.isHidden = true
            
            tblComments.scrollToRow(at: IndexPath(row: arrComments.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.navigationController?.parent != nil {
            let tabbar = self.navigationController?.parent as! UITabBarController
            tabbar.tabBar.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserDefaults.standard.set(false, forKey: "forCommentNotification")
        
        if self.navigationController?.parent != nil {
            let tabbar = self.navigationController?.parent as! UITabBarController
            tabbar.tabBar.isHidden = false
        }
    }
    
    //MARK: - Register Cell
    
    func RegisterCell() {
        tblComments.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
    }
    
    //MARK: - UITableView Datasource & Delegate MEthods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrComments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var myChatString = String()
        
        let comment = self.arrComments[indexPath.row] as! CommentModel
        let commentText = comment.commentString
        let userDict = comment.userDict
        
        let username = (userDict!["firstname"] as! String) + " " + (userDict!["lastname"] as! String)
        
        myChatString = String(format: "%@\t%@", username,commentText!)
        
        let width = myChatString.width(withConstrainedHeight: 21, font: .systemFont(ofSize: 13))
        let intWidth = Int(width)
        
        let height = myChatString.height(withConstrainedWidth: CGFloat(intWidth), font: .systemFont(ofSize: 13))
        let intHeight = Int(height)
        
        if intWidth > 300 {
            
            let numberofLines = Double(width/300).rounded(.up)
            let height = 21 * numberofLines
            return CGFloat(height + 5)
        }
        else if intHeight > 30 {
            
            let height = CGFloat(intHeight + 30)
            return CGFloat(height)
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblComments.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        cell.selectionStyle = .none
        
        let comment = self.arrComments[indexPath.row] as! CommentModel
        let commentText = comment.commentString
        let userDict = comment.userDict
        
        let username = (userDict!["firstname"] as! String) + " " + (userDict!["lastname"] as! String)
        
        let attributes = [ NSAttributedString.Key.font: UIFont(name: "AvenirNext-Bold", size: 13.0)!]
        let stringName = NSMutableAttributedString(string: username, attributes: attributes )
        
        let commentAttributes = [ NSAttributedString.Key.font: UIFont(name: "AvenirNext-Regular", size: 13.0)!, NSAttributedString.Key.foregroundColor: UIColor.gray ]
        let stringComment = NSMutableAttributedString(string: String(format: "\t%@", commentText!), attributes: commentAttributes )
        
        stringName.append(stringComment)
        cell.lblComments.attributedText = stringName
        
        cell.lblComments.isUserInteractionEnabled = true
        cell.lblComments.tag = indexPath.row
        cell.lblComments.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(nameLabelTapped(gesture:))))
        
        var profilePicUrl = userDict!["profile_pic"] as! String
        profilePicUrl = profilePicUrl.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
        
        cell.btnProfilePic.sd_setImage(with: URL(string: profilePicUrl), for: .normal, completed: nil)
        cell.btnProfilePic.tag = indexPath.row
        cell.btnProfilePic.addTarget(self, action: #selector(goToUserProfile), for: .touchUpInside)
        
        if isEditingRow == true && indexPath.row == editingRowIndex {
            cell.txtFldEditComment.isHidden = false
            cell.txtFldEditComment.text = commentText
            cell.txtFldEditComment.delegate = self
            cell.txtFldEditComment.becomeFirstResponder()
        }
        else {
            cell.txtFldEditComment.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let commentsbool = UserDefaults.standard.bool(forKey: "forCommentNotification")
        if commentsbool == true{
            return false
        }
        
        let comment = self.arrComments[indexPath.row] as! CommentModel
        let userId = comment.commentUserId
        
        var jobUserId = Int()
        if self.isForActivity == true {
            jobUserId = ActivityModel.Shared.arrActivities[self.index].jobUserId!
        }
        else {
            jobUserId = UserJobListModel.Shared.arrUserJobs[self.index].jobUserId!
        }
        
        if userId == Int(UserSettings.userID) || jobUserId == Int(UserSettings.userID) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            let alert = UIAlertController(title: AppName, message: "Are you sure you want to delete this comment?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                
            }))
            
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
                
                let commentId = (self.arrComments.object(at: indexPath.row) as! CommentModel).commentId
                let commentIDString = "\(commentId!)"
                
                let dict = [
                    APIManager.Parameter.commentId : commentIDString
                ]
                
                APIManager.sharedInstance.CallAPIPost(url: Url_DeleteComment, parameter: dict, complition: { (error, JSONDICTIONARY) in
                    
                    let isError = JSONDICTIONARY!["isError"] as! Bool
                    
                    if  isError == false{
                        print(JSONDICTIONARY as Any)
                        
                        if self.isForActivity == true {
                            ActivityModel.Shared.arrActivities[self.index].commentsArrayNew.remove(at: indexPath.row)
                            self.arrComments = ActivityModel.Shared.arrActivities[self.index].commentsArrayNew as NSArray
                        }
                        else {
                            UserJobListModel.Shared.arrUserJobs[self.index].commentsArrayNew.remove(at: indexPath.row)
                            self.arrComments = UserJobListModel.Shared.arrUserJobs[self.index].commentsArrayNew as NSArray
                        }
                        
                        if self.arrComments.count == 0 {
                            self.tblComments.isHidden = true
                            self.lblNoComments.isHidden = false
                        }
                        else {
                            self.tblComments.isHidden = false
                            self.lblNoComments.isHidden = true
                            
                            self.tblComments.scrollToRow(at: IndexPath(row: self.arrComments.count - 1, section: 0), at: .bottom, animated: true)
                        }
                        self.tblComments.reloadData()
                    }
                    else{
                        let message = JSONDICTIONARY!["response"] as! String
                        
                        SAAlertBar.show(.error, message:message.capitalized)
                    }
                })
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            
            self.isEditingRow = true
            self.editingRowIndex = indexPath.row
            self.tblComments.beginUpdates()
            self.tblComments.reloadRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
            self.tblComments.endUpdates()
        }
        
        edit.backgroundColor = UIColor.lightGray
        
        let comment = self.arrComments[indexPath.row] as! CommentModel
        let userId = comment.commentUserId
        
        var jobUserId = Int()
        if self.isForActivity == true {
            jobUserId = ActivityModel.Shared.arrActivities[self.index].jobUserId!
        }
        else {
            jobUserId = UserJobListModel.Shared.arrUserJobs[self.index].jobUserId!
        }
        
        if  jobUserId == Int(UserSettings.userID) {
            if userId == Int(UserSettings.userID) {
                return [delete,edit]
            }
            return [delete]
        }
        else if userId == Int(UserSettings.userID) {
            return [delete,edit]
        }
        return [delete]
    }
    
    //MARK: - User Defined Methods
    
    @objc func goToUserProfile(_ sender : UIButton) {
        
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EntrepreneurProfileVC") as! EntrepreneurProfileVC
        vc.isOtherUser = true
        vc.dictEntrpreneur = (self.arrComments[sender.tag] as! CommentModel).userDict!
        vc.otherUserId = String((self.arrComments[sender.tag] as! CommentModel).commentUserId!)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func nameLabelTapped(gesture: UITapGestureRecognizer) {
        
        let tappedLabel = gesture.view as! UILabel
        let comment = self.arrComments[tappedLabel.tag] as! CommentModel
        let commentText = comment.commentString
        let userDict = comment.userDict
        let username = (userDict!["firstname"] as! String) + " " + (userDict!["lastname"] as! String)
        let stringComment = String(format: "%@ %@",username ,commentText!)
        let nameRange = NSString(string: stringComment).range(of: username, options: String.CompareOptions.caseInsensitive)
        
        
        if gesture.didTapAttributedTextInLabel(label: tappedLabel, inRange: nameRange) {
            let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "EntrepreneurProfileVC") as! EntrepreneurProfileVC
            vc.isOtherUser = true
            vc.dictEntrpreneur = userDict!
            vc.otherUserId = String(userDict!["id"] as! Int)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: - UITextfield Delegate MEthod
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField != txtFieldComment {
            
            print("update comment WS")
            
            let userId = UserSettings.userID
            let activityID = self.activityID
            let commentID = (self.arrComments.object(at: self.editingRowIndex) as! CommentModel).commentId
            let commentIDString = "\(commentID!)"
            
            let dict = [
                APIManager.Parameter.activityId : activityID,
                APIManager.Parameter.userID : userId,
                APIManager.Parameter.comment : textField.text!,
                APIManager.Parameter.commentId : commentIDString
            ]
            
            APIManager.sharedInstance.CallAPI(url: Url_SaveUpdateComment, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
                
                let isError = JSONDICTIONARY!["isError"] as! Bool
                
                if  isError == false {
                    print(JSONDICTIONARY as Any)
                    let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                    let comment = dataDict["data"] as! NSDictionary
                    
                    let DataObject = CommentModel()
                    DataObject.JsonParseFromDict(comment as! JSONDICTIONARY)
                    
                    if self.isForActivity == true {
                        let modelObject = ActivityModel.Shared.arrActivities[self.index].commentsArrayNew[self.editingRowIndex]
                        modelObject.commentString = textField.text!
                        
                        self.arrComments = ActivityModel.Shared.arrActivities[self.index].commentsArrayNew as NSArray
                    }
                    else {
                        
                        let modelObject = UserJobListModel.Shared.arrUserJobs[self.index].commentsArrayNew[self.editingRowIndex]
                        modelObject.commentString = textField.text!
                        self.arrComments = UserJobListModel.Shared.arrUserJobs[self.index].commentsArrayNew as NSArray
                    }
                    
                    self.isEditingRow = false
                    
                    self.tblComments.reloadData()
                    self.txtFieldComment.text = ""
                    self.btnSend.isUserInteractionEnabled = true
                }
                else{
                    let message = JSONDICTIONARY!["response"] as! String
                    
                    SAAlertBar.show(.error, message:message.capitalized)
                }
            }
        }
    }
    
    //MARK: - Action
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendClicked(_ sender: UIButton) {
        
        btnSend.isUserInteractionEnabled = false
        growingTextView.resignFirstResponder()
        self.callAPIToAddComment()
    }
    
    //MARK: - API
    
    func callAPIToAddComment() {
        
        let userId = UserSettings.userID
        let activityID = self.activityID
        
        let dict = [
            APIManager.Parameter.activityId : activityID,
            APIManager.Parameter.userID : userId,
            APIManager.Parameter.comment : growingTextView.text!
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_SaveUpdateComment, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                let comment = dataDict["data"] as! NSDictionary
                
                let DataObject = CommentModel()
                DataObject.JsonParseFromDict(comment as! JSONDICTIONARY)
                
                let commentsbool = UserDefaults.standard.bool(forKey: "forCommentNotification")
                
                if commentsbool == true{
                    let myArray = self.arrComments.mutableCopy() as! NSMutableArray
                    myArray.add(DataObject)
                    self.arrComments = myArray as! NSArray
                }
                else if self.isForActivity == true {
                    ActivityModel.Shared.arrActivities[self.index].commentsArrayNew.append(DataObject)
                    self.arrComments = ActivityModel.Shared.arrActivities[self.index].commentsArrayNew as NSArray
                    
                    Analytics.logEvent(NSLocalizedString("comment_added", comment: ""), parameters: [NSLocalizedString("job_title", comment: ""): (ActivityModel.Shared.arrActivities[self.index].jobDict!).value(forKey: "title")!])
                }
                else {
                    UserJobListModel.Shared.arrUserJobs[self.index].commentsArrayNew.append(DataObject)
                    self.arrComments = UserJobListModel.Shared.arrUserJobs[self.index].commentsArrayNew as NSArray
                    
                    Analytics.logEvent(NSLocalizedString("comment_added", comment: ""), parameters: [NSLocalizedString("job_title", comment: ""): (UserJobListModel.Shared.arrUserJobs[self.index].jobTitle)!])
                }
                
                self.lblNoComments.isHidden = true
                self.tblComments.isHidden = false
                self.tblComments.reloadData()
                self.tblComments.scrollToRow(at: IndexPath(row: self.arrComments.count - 1, section: 0), at: .bottom, animated: true)
                self.growingTextView.text = ""
                self.btnSend.isUserInteractionEnabled = true
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        }
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        //let textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
        //(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        //let locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
        // locationOfTouchInLabel.y - textContainerOffset.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
