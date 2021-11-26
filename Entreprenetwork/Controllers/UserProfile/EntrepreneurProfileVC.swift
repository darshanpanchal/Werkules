//
//  EntrepreneurProfileVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 16/09/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import SimpleImageViewer
import AVKit
import TaggerKit
import Firebase
import SDWebImage

class EntrepreneurProfileVC: UIViewController,UITableViewDataSource,UITableViewDelegate,imageDelegate {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var btnCoverPic: UIButton!
    @IBOutlet weak var btnUserProfile: UIButton!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var btnAddToNetwork: UIButton!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var lblRatings: UILabel!
    @IBOutlet weak var lblTagline: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblJoinedOn: UILabel!
    @IBOutlet weak var tblJobList: UITableView!
    @IBOutlet weak var lblNoJobExists: UILabel!
    @IBOutlet weak var headerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    var isOtherUser = Bool()
    var dictEntrpreneur = NSDictionary()
    var otherUserId = String()
    //    var arrJobList = NSArray()
    var selectedIndex = Int()
    var status = String()
    var fromID = String()
    
    @IBOutlet weak var imgProfile:UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblMobileNumber: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblAccountSuspended: UILabel!
    @IBOutlet weak var objCollectionView:UICollectionView!
    @IBOutlet weak var imgViewBackground:UIImageView!
    @IBOutlet weak var btnMore:UIButton!
    
    var arrayOfReview:[Review] = []
    
    var isSuspended:Bool = false
    var isUserAccountSuspended:Bool {
        get{
            return self.isSuspended
        }
        set{
            self.isSuspended = newValue
            //Configure new value
            self.configureSelectedResumeAccount()
        }
    }
    
    //MARK: - UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isUserAccountSuspended = false 
        // Do any additional setup after loading the view.
        
//        getRatings()
//        setUpView()
        RegisterCell()
        
        self.imgProfile.contentMode = .scaleAspectFill
        self.imgProfile.clipsToBounds = true
        self.imgProfile.layer.borderWidth = 2.0
        self.imgProfile.layer.borderColor = UIColor.white.cgColor
        self.imgProfile.layer.cornerRadius = 115.0/2.0
        
       
        if let currentUser = UserDetail.getUserFromUserDefault(){
            self.getCurrentUserDetailAPIRequest(userID: currentUser.id)
            //GET User Rating
            self.getUserReviewAPIRequest()
            
        }
        
        let underlineAttriString = NSAttributedString(string: "More",
                                                  attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnMore.titleLabel?.attributedText = underlineAttriString
    }
    func configureSelectedResumeAccount(){
        DispatchQueue.main.async {

            if self.isSuspended{
                self.imgViewBackground.image = UIImage.init(named: "background_red")
                self.lblAccountSuspended.text = "Resume Account"
            }else{
                self.imgViewBackground.image = UIImage.init(named: "background_update")
                self.lblAccountSuspended.text = "Temporarily Suspend Account"
            }
            self.view.layoutIfNeeded()
        }
    }
    func RegisterCell()  {
        
        self.objCollectionView.register(UINib.init(nibName: "ReviewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ReviewCollectionViewCell")
        self.objCollectionView.delegate = self
        self.objCollectionView.dataSource = self
        self.objCollectionView.reloadData()
    }
    func configureCurrentUserData(){
            if let currentUser = UserDetail.getUserFromUserDefault(){
                DispatchQueue.main.async {
                    self.lblUserName.text = "\(currentUser.firstname) \(currentUser.lastname)"//currentUser.username
                    self.lblEmail.text = currentUser.email
                    self.lblMobileNumber.text = " \(currentUser.phone)".applyPatternOnNumbers(pattern: "###-###-####", replacmentCharacter: "#")
                    self.lblAddress.text = "\(currentUser.address) \(currentUser.city) \(currentUser.state) \(currentUser.zipcode)"
                    if let imgURL = URL.init(string:  currentUser.profilePic){
                        self.imgProfile.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                    }
                    
                    
                }
            }
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.configureCurrentUserData()
//        if self.navigationController?.parent != nil {
//            let tabbar = self.navigationController?.parent as! UITabBarController
//            tabbar.tabBar.isHidden = true
//        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.tblJobList.isScrollEnabled = (self.tblJobList.contentSize.height > self.tblJobList.bounds.height)
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
//        if self.navigationController?.parent != nil {
//            let tabbar = self.navigationController?.parent as! UITabBarController
//            tabbar.tabBar.isHidden = false
//        }
    }
    //MARK: - API RequestMethods
    func getCurrentUserDetailAPIRequest(userID:String){
        let dict = [
            "user_id":"\(userID)"
        ]
     
             APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCustomerDetails , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],var userInfo = success["success_data"] as? [String:Any]{
                    if let customerData = userInfo["customer_data"] as? [String:Any]{
                        if let currentUser = UserDetail.getUserFromUserDefault(){
                                                      userInfo["remember_token"] = currentUser.rememberToken
                                                      let objUser = UserDetail.init(userDetail: customerData)
                                                      objUser.setuserDetailToUserDefault()
                                                      self.configureCurrentUserData()
                                                  }
                                              }else{
                                                  DispatchQueue.main.async {
                                                      SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                                  }
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
    }
    //GET User review request
    func getUserReviewAPIRequest(){
           guard let currentUser = UserDetail.getUserFromUserDefault() else {
                           return
                }
           var dict:[String:Any]  = [:]
           dict["user_id"] = currentUser.id
           dict["limit"] = "3"
           dict["page"] = "1"
           
                   APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGETUserReview , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                               if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                                
                                if let arrayReview = userInfo["data"] as? [[String:Any]]{
                                    self.arrayOfReview.removeAll()
                                    for objReview in arrayReview{
                                        let review = Review.init(reviewDetail: objReview)
                                        self.arrayOfReview.append(review)
                                    }
                                    DispatchQueue.main.async {
                                        self.objCollectionView.reloadData()
                                    }
                                }
                                   if let totalRating = userInfo["total_rating"]{
                                       if let pi: Double = Double("\(totalRating)"){
                                           let rating = String(format:"%.1f", pi)
                                           print(rating)
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
       }
    //MARK: - User Defined Methods
    
    func setUpView() {
        
        headerViewWidthConstraint.constant = self.view.frame.size.width
        
        if otherUserId == UserSettings.userID {
            isOtherUser = false
            
            btnEditProfile.isHidden = false
            btnMessage.isHidden = true
            btnAddToNetwork.isHidden = true
        }
        else {
            isOtherUser = true
            btnEditProfile.isHidden = true
            btnMessage.isHidden = false
            btnAddToNetwork.isHidden = false
        }
        
        if isOtherUser == true {
            
            var coverUrl = dictEntrpreneur["cover_pic"] as! String
            coverUrl = coverUrl.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
            btnCoverPic!.sd_setImage(with: URL(string: coverUrl), for: UIControl.State.normal, placeholderImage: UIImage(named: "user_placeholder"), options: [], context: nil)
            
            var profileUrl = dictEntrpreneur["profile_pic"] as! String
            profileUrl = profileUrl.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
            btnUserProfile!.sd_setImage(with: URL(string: profileUrl), for: UIControl.State.normal, placeholderImage: UIImage(named: "user_placeholder"), options: [], context: nil)
            
            let userName = (dictEntrpreneur["firstname"] as! String) + " " + (dictEntrpreneur["lastname"] as! String)
            lblUserName.text = userName
            
            let userId = otherUserId
            let isUseradded = self.isUserAdded(userID: Int(userId)!)
            if isUseradded == true {
                btnAddToNetwork.setImage(UIImage(named: "user_added"), for: .normal)
            }
            else {
                btnAddToNetwork.setImage(UIImage(named: "addToNetwork"), for: .normal)
            }
            
            Analytics.logEvent(NSLocalizedString("user_profile_view", comment: ""), parameters: [NSLocalizedString("user_name", comment: ""): userName])
            
            if (dictEntrpreneur["tagline"] as! String) == "" {
                lblTagline.text = "No tagline available"
            }
            else {
                lblTagline.text = (dictEntrpreneur["tagline"] as! String)
            }
            if (dictEntrpreneur["description"] as! String) == "" {
                lblDescription.text = "No description available"
            }
            else {
                lblDescription.text = (dictEntrpreneur["description"] as! String)
            }
            
            let joinedOn = (dictEntrpreneur["created_at"] as! String)
            lblJoinedOn.text = Date.getFormattedDateForJob(string: joinedOn)
        }
        else {
            
            var coverUrl = CurrentUserModel.Shared.vCoverPic
            coverUrl = coverUrl!.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
            btnCoverPic!.sd_setImage(with: URL(string: coverUrl!), for: UIControl.State.normal, placeholderImage: UIImage(named: "user_placeholder"), options: [], context: nil)
            
            var profileUrl = CurrentUserModel.Shared.vProfilepic
            profileUrl = profileUrl!.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
            btnUserProfile!.sd_setImage(with: URL(string: profileUrl!), for: UIControl.State.normal, placeholderImage: UIImage(named: "user_placeholder"), options: [], context: nil)
            
            let userName = (CurrentUserModel.Shared.firstName!) + " " + (CurrentUserModel.Shared.lastName!)
            lblUserName.text = userName
            
            Analytics.logEvent(NSLocalizedString("user_profile_view", comment: ""), parameters: [NSLocalizedString("user_name", comment: ""): userName])
            
            if CurrentUserModel.Shared.tagline == "" {
                lblTagline.text = "No tagline available"
            }
            else {
                lblTagline.text = CurrentUserModel.Shared.tagline
            }
            if CurrentUserModel.Shared.companyDescription == "" {
                lblDescription.text = "No description available"
            }
            else {
                lblDescription.text = CurrentUserModel.Shared.companyDescription
            }
            
            let joinedOn = CurrentUserModel.Shared.joinedOn
            lblJoinedOn.text = Date.getFormattedDateForJob(string: joinedOn!)
        }
        
        var height = CGFloat ()
        height = 280
        
        let taglineHeight = lblTagline.text?.height(withConstrainedWidth: self.view.frame.size.width - 80 , font: lblTagline.font)
        
        height = height + taglineHeight!
        
        let descriptionHeight = lblDescription.text?.height(withConstrainedWidth: self.view.frame.size.width - 112 , font: lblDescription.font)
        
        height = height + descriptionHeight!
        
        headerViewHeightConstraint.constant = height
        tblJobList.tableHeaderView = headerView
        
        callAPIToGetJobs()
    }
    
    func isUserAdded(userID : Int) -> Bool {
        
        for user in NetworkModel.Shared.arrUsers {
            
            let networkUserId = user.userId
            
            if networkUserId == userID {
                return true
            }
        }
        
        return false
    }
    
    func getRatings() {
        
        var userID = String()
        
        if self.isOtherUser == true {
            userID = otherUserId
        }
        else {
            userID = UserSettings.userID
        }
        
        let dict = [
            APIManager.Parameter.limit : "100",
            APIManager.Parameter.page : "1",
            APIManager.Parameter.userID : userID
        ]
        
        APIManager.sharedInstance.CallAPIPost(url: Url_getReview, parameter: dict, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                let arr = dataDict["data"] as! NSArray
                
                if arr.count > 0 {
                    
                    if arr.count == 1 {
                        let dict = arr[0] as! NSDictionary
                        let ratings = dict["rating"] as! Int
                        self.lblRatings.text = "\(ratings)"
                    }
                    else {
                        var totalRatings : Float = 0.0
                        
                        for i in 0..<arr.count {
                            let dict = arr[i] as! NSDictionary
                            let ratings = dict["rating"] as! Int
                            
                            totalRatings = totalRatings + Float(ratings)
                        }
                        let fltRating = Float(totalRatings / Float(arr.count))
                        self.lblRatings.text = String(format: "%.1f", arguments:[fltRating])
                    }
                }
                else {
                    
                    self.lblRatings.text = "0"
                }
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    @objc func showUserLikesList(_ sender : UIButton) {
        
        self.selectedIndex = sender.tag
        
        let storyboard = UIStoryboard.init(name: "Activity", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserLikesVC") as! UserLikesVC
        vc.arrUsers = UserJobListModel.Shared.arrUserJobs[self.selectedIndex].likesArrayNew as NSArray
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func likePost(_ sender:UIButton) {
        
        if UserSettings.isUserLogin == true {
            if sender.isSelected == true {
                sender.isSelected = false
                status = "dislike"
            }
            else {
                sender.isSelected = true
                status = "like"
            }
            selectedIndex = sender.tag
            
            self.callWebserviceToAddLike()
        }
        else {
            let alert = UIAlertController(title: AppName, message: "Please login to like post.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func commentPost(_ sender:UIButton) {
        
        if UserSettings.isUserLogin == true {
            selectedIndex = sender.tag
            
            let storyboard = UIStoryboard.init(name: "Activity", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
            vc.arrComments = NSMutableArray.init(array: UserJobListModel.Shared.arrUserJobs[self.selectedIndex].commentsArrayNew as NSArray)
            let dict = UserJobListModel.Shared.arrUserJobs[self.selectedIndex].activityDict!
            vc.activityID = String(dict["id"] as! Int)
            vc.index = selectedIndex
            vc.isForActivity = false
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        else {
            let alert = UIAlertController(title: AppName, message: "Please login to comment on post.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func goToJobProfile(_ sender:UIButton) {
        
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "JobProfileVC") as! JobProfileVC
//        vc.dictJobDetails = ActivityModel.Shared.arrActivities[sender.tag].jobDict! //dataDict
//        vc.userDict = ActivityModel.Shared.arrActivities[sender.tag].userDict!
//        vc.isFromMessages = true
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func btnMoreClicked(_ sender:UIButton) {
        
        if UserSettings.isUserLogin == true {
            
            selectedIndex = sender.tag
            
            if isOtherUser == true {
                
                let actionSheet: UIAlertController = UIAlertController(title: AppName, message: "", preferredStyle: .actionSheet)
                
                let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    print("Cancel")
                }
                actionSheet.addAction(cancelActionButton)
                
                let reportActionButton = UIAlertAction(title: "Report this post", style: .default)
                { _ in
                    self.callAPIToReportJob()
                }
                actionSheet.addAction(reportActionButton)
                self.present(actionSheet, animated: true, completion: nil)
            }
            else {
                
                let actionSheet: UIAlertController = UIAlertController(title: AppName, message: "", preferredStyle: .actionSheet)
                
                let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    print("Cancel")
                }
                actionSheet.addAction(cancelActionButton)
                
                let editActionButton = UIAlertAction(title: "Edit", style: .default)
                { _ in
                    
                    let dataDict = UserJobListModel.Shared.arrUserJobs[self.selectedIndex]
                    
//                    if dataDict.isActivity == "1" {
//
//                        let storyboard = UIStoryboard.init(name: "Activity", bundle: nil)
//                        let vc = storyboard.instantiateViewController(withIdentifier: "PostActivityVC") as! PostActivityVC
//                        vc.isJobEditing = true
//                        vc.jobDictModel = dataDict
//                        vc.isFromActivity = false
//                        vc.modalPresentationStyle = .fullScreen
//                        self.present(vc, animated: true, completion: nil)
//                    }
//                    else {
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "PostJobVC") as! PostJobVC
                    vc.isJobEditing = true
                    vc.isFromActivity = false
                    vc.isFromProfile = true
                    vc.jobDictModel = dataDict
                    if dataDict.isActivity == "1" {
                        vc.isactivity = true
                    }
                    else {
                        vc.isactivity = false
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                    //                    }
                }
                actionSheet.addAction(editActionButton)
                
                let deleteActionButton = UIAlertAction(title: "Delete", style: .default)
                { _ in
                    
                    let alert = UIAlertController(title: AppName, message: "Are you sure you want to delete this job?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
                        let jobID = UserJobListModel.Shared.arrUserJobs[self.selectedIndex].jobId!
                        
                        let dict = [
                            APIManager.Parameter.jobID : String(jobID)
                        ]
                        
                        APIManager.sharedInstance.CallAPIPost(url: Url_deleteJob, parameter: dict, complition: { (error, JSONDICTIONARY) in
                            
                            let isError = JSONDICTIONARY!["isError"] as! Bool
                            
                            if  isError == false{
                                print(JSONDICTIONARY as Any)
                                
                                UserJobListModel.Shared.arrUserJobs.remove(at: self.selectedIndex)
                                self.tblJobList.reloadData()
                            }
                            else{
                                let message = JSONDICTIONARY!["response"] as! String
                                
                                SAAlertBar.show(.error, message:message.capitalized)
                            }
                        })
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                actionSheet.addAction(deleteActionButton)
                self.present(actionSheet, animated: true, completion: nil)
            }
        }
        else {
            let alert = UIAlertController(title: AppName, message: "Please login to continue.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didPressButton(button:UIButton) {
        
        let cell = button.superview?.superview as! ActivityImageCell
        
        let imgViewJob = cell.btnJobPic.imageView
        let configuration = ImageViewerConfiguration { config in
            config.imageView = imgViewJob
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        
        present(imageViewerController, animated: true)
    }
    
    func showFullVideo(url: String) {
        
        let videoURL = URL(string: url)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func formatPoints(num: Double) ->String{
        var thousandNum = num/1000
        var millionNum = num/1000000
        if num >= 1000 && num < 1000000{
            if(floor(thousandNum) == thousandNum){
                return("\(Int(thousandNum))k")
            }
            return("\(thousandNum.roundToPlaces(places: 1))k")
        }
        
        if num >= 1000000{
            //            if(floor(millionNum) == millionNum){
            //                return("\(Int(thousandNum))k")
            //            }
            return ("\(millionNum.roundToPlaces(places: 1))M")
        }
        else{
            if(floor(num) == num){
                return ("\(Int(num))")
            }
            return ("\(num)")
        }
    }
    
    //MARK: - Actions
    @IBAction func btnMoreSelectorClick(sender:UIButton){
        print("btnMoreSelectorClick")
        //psuh to customer review screen
        self.pushToCustomerReviewScreen(hightlightedIndex: nil)
//        self.pushToMyReviewScreen()
    }
    
    @IBAction func btnAccountSuspendClick(sender:UIButton){
        self.isUserAccountSuspended = !self.isUserAccountSuspended
    }
    @IBAction func btnReportBugClicked(_ sender: UIButton) {
       
        if let reportBug = self.storyboard?.instantiateViewController(withIdentifier: "ReportBugViewController") as? ReportBugViewController{
            self.navigationController?.pushViewController(reportBug, animated: true)
        }
    }
    @IBAction func btnCoverPicClicked(_ sender: UIButton) {
        
        let configuration = ImageViewerConfiguration { config in
            config.imageView = btnCoverPic.imageView
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        
        present(imageViewerController, animated: true)
    }
    
    @IBAction func btnUserProfileClicked(_ sender: UIButton) {
        
        let configuration = ImageViewerConfiguration { config in
            config.imageView = btnUserProfile.imageView
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        
        present(imageViewerController, animated: true)
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        if self.isModal == true {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnreviewClicked(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "reviewSegue", sender: self)
    }
    
    @IBAction func btnEditClicked(_ sender: UIButton) {
//        DispatchQueue.main.async {
//             SAAlertBar.show(.error, message:"Under Development".capitalized)
//        }
        //self.performSegue(withIdentifier: "EditProfileSegue", sender: self)
        self.pushToEditCustomerProfileViewController()
    }
    
    @IBAction func btnMessageClicked(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.init(name: "Messages", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        
        let dict = dictEntrpreneur
        
        chatVC.fromId = UserSettings.userID
        
        chatVC.profileDict = dict
        chatVC.toId = self.otherUserId//"\(userID)"
        chatVC.userName = (dictEntrpreneur["firstname"] as! String) + " " + (dictEntrpreneur["lastname"] as! String)//(dict["firstname"] as! String) + " " + (dict["lastname"] as! String)
        var profileUrl = dictEntrpreneur["profile_pic"] as! String
        profileUrl = profileUrl.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
        chatVC.userProfilePath = profileUrl
        chatVC.isForJobChat = false
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @IBAction func btnAddToNetworkClicked(_ sender: UIButton) {
        
        let userDict = self.dictEntrpreneur
        //            let userId = userDict.value(forKey: "id") as! Int
        self.fromID = self.otherUserId//"\(userId)"
        self.callAPIToAddUserToNetwork()
    }

    
    // MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserJobListModel.Shared.arrUserJobs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height = CGFloat()
        
        height = 51
        
        let jobDict = UserJobListModel.Shared.arrUserJobs[indexPath.row]
        let title = jobDict.jobTitle
        
        if title != "" {
            let titleHeight = title!.height(withConstrainedWidth: self.view.frame.size.width - 20, font: .systemFont(ofSize: 16))
            height = height + 10 + titleHeight
        }
        
        if jobDict.jobImg1Path != "" ||
            jobDict.jobImg2Path != "" ||
            jobDict.jobImg3Path != "" ||
            jobDict.jobImg4Path != ""  {
            
            height = height + 30 + self.view.frame.size.width
        }
        
        return height + 75.5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblJobList.dequeueReusableCell(withIdentifier: "ActivityCell") as! ActivityCell
        
        cell.contentView.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.delegate = self
        
        let jobDict = UserJobListModel.Shared.arrUserJobs[indexPath.row]
        let userDict = UserJobListModel.Shared.arrUserJobs[indexPath.row].userDict
        
        var url = userDict!["profile_pic"] as! String
        url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
        
        cell.btnProfilePic.sd_setImage(with: URL(string: url), for: .normal, completed: nil)
        
        cell.btnUserName.setTitle((userDict!["firstname"] as! String) + " " + (userDict!["lastname"] as! String) , for: .normal)
        
        cell.lblLocation.text = jobDict.jobAddress
        
        cell.lblPostTitle.text = jobDict.jobTitle
        
        cell.pageControl.isHidden = true
        
        if jobDict.isActivity == "1" {
            cell.viewRibbon.isHidden = true
        }
        else {
            cell.viewRibbon.isHidden = false
            
            cell.btnRibbon.tag = indexPath.row
            cell.btnRibbon.addTarget(self, action: #selector(goToJobProfile(_:)), for: .touchUpInside)
            
            var text = jobDict.estimatedBudget
            text = text!.replacingOccurrences(of: "$", with: "")
            let myDouble = Double(text!)
            
            cell.lblEstimatedPrize.text = "$" + self.formatPoints(num: myDouble!)
        }
        
        let likes = UserJobListModel.Shared.arrUserJobs[indexPath.row].likesArrayNew
        let likesCount = likes.count
        if likesCount == 0 {
            cell.btnLikeCounts.setTitle("", for: .normal)
        }
        else {
            cell.btnLikeCounts.setTitle("\(likesCount)", for: .normal)
        }
        
        cell.btnLike.isSelected = false
        for item in likes {
            let like = item
            let userId = like.userId
            if Int(UserSettings.userID) == userId {
                cell.btnLike.isSelected = true
            }
        }
        
        cell.btnLikeCounts.tag = indexPath.row
        cell.btnLikeCounts.addTarget(self, action: #selector(showUserLikesList), for: .touchUpInside)
        
        let comments = UserJobListModel.Shared.arrUserJobs[indexPath.row].commentsArrayNew
        let commentsCount = comments.count
        if commentsCount == 0 {
            cell.lblCommentsCount.text = ""
        }
        else {
            cell.lblCommentsCount.text = "\(commentsCount)"
        }
        
        let pastDate = jobDict.jobCreationDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var date = dateFormatter.date(from: pastDate!)
        date = date?.toLocalTime()
        cell.lblTime.text =  date?.timeAgoDisplay()
        
        let imagesArray = NSMutableArray.init()
        if jobDict.jobImg1Path != "" {
            imagesArray.add(jobDict.jobImg1Path!)
        }
        if jobDict.jobImg2Path != "" {
            imagesArray.add(jobDict.jobImg2Path!)
        }
        if jobDict.jobImg3Path != "" {
            imagesArray.add(jobDict.jobImg3Path!)
        }
        if jobDict.jobImg4Path != "" {
            imagesArray.add(jobDict.jobImg4Path!)
        }
        
        if imagesArray.count > 1 {
            cell.pageControl.isHidden = false
            cell.pageControl.numberOfPages = imagesArray.count
        }
        
        cell.jobPhotosArray = imagesArray
        
        cell.btnProfilePic.tag = indexPath.row
        cell.btnUserName.tag = indexPath.row
        cell.btnLike.tag = indexPath.row
        cell.btnComment.tag = indexPath.row
        cell.btnMore.tag = indexPath.row
        
        cell.btnLike.addTarget(self, action: #selector(likePost), for: .touchUpInside)
        cell.btnComment.addTarget(self, action: #selector(commentPost), for: .touchUpInside)
        cell.btnMore.addTarget(self, action: #selector(btnMoreClicked), for: .touchUpInside)
        
        cell.imageCollectionView.reloadData()
        
        return cell
    }
    
    //MARK: - API
    
    func callAPIToGetJobs() {
        
        if UserJobListModel.Shared.arrUserJobs.count > 0 {
            UserJobListModel.Shared.arrUserJobs.removeAll()
        }
        
        var dict = JSONDICTIONARY()
        
        if isOtherUser == true {
            dict = [
                APIManager.Parameter.userID : self.otherUserId
            ]
        }
        else {
            dict = [
                APIManager.Parameter.userID : UserSettings.userID
            ]
        }
        
        APIManager.sharedInstance.CallAPIPost(url: Url_JobListOfUser, parameter: dict, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                if (dataDict["data"] as! NSArray).count == 0 {
                    
//                    self.lblNoJobExists.isHidden = false
                    
//                    self.lblNoJobExists.text = (dataDict["message"] as! String)
                }
                else {
                    
                    self.tblJobList.isHidden = false
//                    self.lblNoJobExists.isHidden = true
                    
                    var jobs = dataDict["data"] as! NSArray
                    jobs = jobs.reversed() as NSArray
                    
                    if UserJobListModel.Shared.arrUserJobs.count > 0 {
                        UserJobListModel.Shared.arrUserJobs.removeAll()
                    }
                    
                    var jobModel = [UserJobListModel]()
                    
                    for job in jobs {
                        let DataObject = UserJobListModel()
                        DataObject.JsonParseFromDict(job as! JSONDICTIONARY)
                        jobModel.append(DataObject)
                        UserJobListModel.Shared.arrUserJobs.append(DataObject)
                    }
                    
//                    self.lblNoJobExists.isHidden = true
                    self.tblJobList.reloadData()
                }
            }
            else {
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    
    func callAPIToReportJob() {
        
        let userID = UserSettings.userID
        let status = "1"
        let jobId = UserJobListModel.Shared.arrUserJobs[self.selectedIndex].jobId!
        var jobIdString = String()
        
        jobIdString = "\(jobId)"
        
        let dict = [
            APIManager.Parameter.userID : userID,
            APIManager.Parameter.jobID : jobIdString,
            APIManager.Parameter.status : status
        ]
        
        APIManager.sharedInstance.CallAPIPost(url: Url_reportJob, parameter: dict, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                let alert: UIAlertController = UIAlertController(title: AppName, message: "Thank you for your report. We will take necessary action within 24 hours", preferredStyle: .alert)
                
                let OkActionButton = UIAlertAction(title: "Ok", style: .cancel) { _ in
                    print("Cancel")
                }
                alert.addAction(OkActionButton)
                
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                if message == "Report job already exists!" {
                    
                    let alert: UIAlertController = UIAlertController(title: AppName, message: "You have already reported this post.", preferredStyle: .alert)
                    
                    let OkActionButton = UIAlertAction(title: "Ok", style: .cancel) { _ in
                        print("Cancel")
                    }
                    alert.addAction(OkActionButton)
                    
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    SAAlertBar.show(.error, message:message.capitalized)
                }
            }
        })
    }
    
    func callWebserviceToAddLike() {
        
        let userId = UserSettings.userID
        
        let activityDict = UserJobListModel.Shared.arrUserJobs[self.selectedIndex].activityDict!
        let activityId = activityDict["id"] as! Int
        
        let dict = [
            APIManager.Parameter.activityId : "\(activityId)",
            APIManager.Parameter.userID : userId,
            APIManager.Parameter.status : self.status
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_SaveUpdateLike, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                let like = dataDict["data"] as! NSDictionary
                
                let likes = UserJobListModel.Shared.arrUserJobs[self.selectedIndex].likesArrayNew
                let indexPath = IndexPath.init(row: self.selectedIndex, section: 0)
                let cell = self.tblJobList.cellForRow(at: indexPath) as! ActivityCell
                
                var likesCount = likes.count
                
                if self.status == "like" {
                    likesCount += 1
                    
                    let DataObject = LikeModel()
                    DataObject.JsonParseFromDict(like as! JSONDICTIONARY)
                    UserJobListModel.Shared.arrUserJobs[self.selectedIndex].likesArrayNew.append(DataObject)
                }
                else {
                    likesCount -= 1
                    
                    for (index,item) in likes.enumerated() {
                        let like = item
                        let userId = like.userId
                        if Int(UserSettings.userID) == userId {
                            UserJobListModel.Shared.arrUserJobs[self.selectedIndex].likesArrayNew.remove(at: index)
                        }
                    }
                }
                
                if likesCount == 0 {
                    cell.btnLikeCounts.setTitle("", for: .normal)
                }
                else {
                    cell.btnLikeCounts.setTitle("\(likesCount)", for: .normal)
                }
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        }
    }
    
    func callAPIToAddUserToNetwork() {
        
        let dict = [
            APIManager.Parameter.fromID : UserSettings.userID,
            APIManager.Parameter.toID : self.fromID
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_AddToNetwork, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                let response = JSONDICTIONARY!["response"] as! NSDictionary
                let dataDict = response.value(forKey: "data") as! NSDictionary
                
                var networkData = [NetworkModel]()
                
                let DataObject = NetworkModel()
                let id = dataDict.value(forKey: "to_id") as! String
                DataObject.userId = Int(id)!
                networkData.append(DataObject)
                NetworkModel.Shared.arrUsers.append(DataObject)
                
                self.btnAddToNetwork.setImage(UIImage(named: "user_added"), for: .normal)
                
                self.tblJobList.reloadData()
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                if message != "Already added in your network!" {
                    SAAlertBar.show(.error, message:message.capitalized)
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "reviewSegue" {
            
            let vc = segue.destination as! ReviewsVC
            
            if self.isOtherUser == true {
                vc.userID = self.otherUserId
            }
            else {
                vc.userID = UserSettings.userID
            }
        }
    }
    //Push to Customer review screen
    func pushToCustomerReviewScreen(isForSecondReviewDetail:Bool = false,hightlightedIndex:Int?){
        if let objCustomerReviewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomerReviewViewController") as? CustomerReviewViewController{
            objCustomerReviewController.isFromSecondReviewDetail = isForSecondReviewDetail
            if let value = hightlightedIndex{
                objCustomerReviewController.highLightedIndex = value
            }
            self.navigationController?.pushViewController(objCustomerReviewController, animated: true)
        }
    }
    func pushToMyReviewScreen(){
        if let objMyReviewViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyReviewViewController") as? MyReviewViewController{
            self.navigationController?.pushViewController(objMyReviewViewController, animated: true)
        }
    }
    func pushToEditCustomerProfileViewController(){
        
        if let objUpdateCustomerProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "UpdateCustomerProfileVC") as? UpdateCustomerProfileVC{
                   self.navigationController?.pushViewController(objUpdateCustomerProfileVC, animated: true)
               }
    }
    
}
extension EntrepreneurProfileVC:UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        DispatchQueue.main.async {
            self.objCollectionView.isHidden = (self.arrayOfReview.count == 0)
            self.btnMore.isHidden =  (self.arrayOfReview.count <= 2)
        }
        return self.arrayOfReview.count
      }
      
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewCollectionViewCell", for: indexPath) as! ReviewCollectionViewCell
        if self.arrayOfReview.count > indexPath.item{
            let objReview = self.arrayOfReview[indexPath.item]
                cell.lblUserName.text = "\(objReview.name)"
                if let imgURL = URL.init(string:  objReview.profilePic){
                    cell.imgUser.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                }
            let dateformatter = DateFormatter()
                              dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                              if let date = dateformatter.date(from: objReview.updatedAt){
                                  dateformatter.dateFormat = "MM/dd/yyyy"
                                 cell.lblDate.text = dateformatter.string(from: date)
                              }
            
            /*"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum"*/
            cell.lblReview.text = "\(objReview.review)"
            let readmoreFont = UIFont(name: "Avenir-Heavy", size: 15.0)
            let readmoreFontColor = UIColor.init(hex: "#38B5A3")
            DispatchQueue.main.async {
                cell.lblReview.addTrailing(with: "... ", moreText: "Read More", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor)
            }
            if let rating = Double(objReview.rating){
                cell.objReview.rating = rating
            }
            
        }
         return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
          return 0
      }
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
          return 0
      }
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2.0, height:collectionView.bounds.height)
      }
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("----- \(indexPath.row)")
        if indexPath.row == 1{
            self.pushToCustomerReviewScreen(isForSecondReviewDetail: true,hightlightedIndex: 1)
        }else{
            self.pushToCustomerReviewScreen(hightlightedIndex: 0)
        }
        
     }
}
extension UIViewController {
    
    var isModal: Bool {
        
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
}
extension String {
    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(encodedOffset: index)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
}
extension UILabel {
    func estimatedHeight(forWidth: CGFloat, text: String, ofSize: CGFloat) -> CGFloat {

        let size = CGSize(width: forWidth, height: CGFloat(MAXFLOAT))

        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)

        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: ofSize)]

        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height

        return ceil(rectangleHeight)
    }
    var isTruncated: Bool {

        guard let labelText = text else {
            return false
        }

        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil).size

        return labelTextSize.height > bounds.size.height
    }
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        guard self.isTruncated else {
            return
        }
        let readMoreText: String = trailingText + moreText

        let lengthForVisibleString: Int = self.vissibleTextLength
        let mutableString: String = self.text!
        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
        let readMoreLength: Int = (readMoreText.count)
        let trimmedForReadMore: String = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
    }

    var vissibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)

        let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)

        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }
}
