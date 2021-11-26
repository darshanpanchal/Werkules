//
//  JobProfileVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 27/07/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import CoreLocation
import SimpleImageViewer
import Firebase
import AVKit

class JobProfileVC: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var scrollvwJobProfile: UIScrollView!
    @IBOutlet weak var imgViewJob: UIImageView!
    @IBOutlet weak var videoPlayerView: PlayerView!
    @IBOutlet weak var pageCntrl: UIPageControl!
    @IBOutlet weak var lblJobTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblEstBudget: UILabel!
    @IBOutlet weak var lblPostedBy: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblApproxDistance: UILabel!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnContactUser: UIButton!
    @IBOutlet weak var btnReportJob: UIButton!
    
    var index = Int()
    var currentJob = NSDictionary()
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLat = CLLocationDegrees()
    var currentLong = CLLocationDegrees()
    
    var swipeGestureLeft = UISwipeGestureRecognizer()
    var swipeGestureRight = UISwipeGestureRecognizer()
    var page = Int()
    
    var imagesArray = NSMutableArray()
    var arrOtherJobs = NSArray()
    var arrReviews = NSArray()
    var jobLocation = CLLocation()
    
    var isFromMessages = Bool()
    var dictJobDetails = NSDictionary()
    var userDict = NSDictionary()
    
    var isMyJob = Bool()
    
    @IBOutlet weak var indicator : UIActivityIndicatorView!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    //MARK:- UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        UserDefaults.standard.set(true, forKey: "forJobProfile")
        
        imagesArray = NSMutableArray.init()
        
        imgViewJob.isUserInteractionEnabled = true
        
        swipeGestureLeft = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeLeft))
        swipeGestureLeft.direction = .left
        imgViewJob.addGestureRecognizer(swipeGestureLeft)
        
        swipeGestureRight = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeRight))
        swipeGestureRight.direction = .right
        imgViewJob.addGestureRecognizer(swipeGestureRight)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showFullImage))
        imgViewJob.addGestureRecognizer(tap)
        
        pageCntrl.currentPage = 1
        
        page = 0
        
        self.lblPostedBy.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer.init()
        tapGesture.addTarget(self, action: #selector(userNameTapped))
        self.lblPostedBy.addGestureRecognizer(tapGesture)
        
        if self.isFromMessages == true {
            
            if ((dictJobDetails["file1"] as! String).count) > 0 {
                imagesArray.add(dictJobDetails["file1"] as! String)
            }
            
            if ((dictJobDetails["file2"] as! String).count) > 0 {
                imagesArray.add(dictJobDetails["file2"] as! String)
            }
            
            if ((dictJobDetails["file3"] as! String).count) > 0 {
                imagesArray.add(dictJobDetails["file3"] as! String)
            }
            
            if ((dictJobDetails["file4"] as! String).count) > 0 {
                imagesArray.add(dictJobDetails["file4"] as! String)
            }
            self.displayJobData()
        }
        else {
            
            if (JobsModel.Shared.arrJobs[self.index].jobImg1Path?.count)! > 0 {
                imagesArray.add(JobsModel.Shared.arrJobs[self.index].jobImg1Path!)
            }
            
            if (JobsModel.Shared.arrJobs[self.index].jobImg2Path?.count)! > 0 {
                imagesArray.add(JobsModel.Shared.arrJobs[self.index].jobImg2Path!)
            }
            
            if (JobsModel.Shared.arrJobs[self.index].jobImg3Path?.count)! > 0 {
                imagesArray.add(JobsModel.Shared.arrJobs[self.index].jobImg3Path!)
            }
            
            if (JobsModel.Shared.arrJobs[self.index].jobImg4Path?.count)! > 0 {
                imagesArray.add(JobsModel.Shared.arrJobs[self.index].jobImg4Path!)
            }
            self.update()
        }
        pageCntrl.isHidden = false
        if imagesArray.count == 1 {
            pageCntrl.isHidden = true
        }
        
        let commentsbool = UserDefaults.standard.bool(forKey: "forCommentNotification")
        
        if commentsbool == true{
            let storyBoard = UIStoryboard(name: "Activity", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
            let myArray = dictJobDetails.object(forKey: "activity") as! NSArray
            let mydict = myArray.object(at: 0) as! NSDictionary
            let myStr = mydict.value(forKey: "id") as! Int
            vc.activityID = "\(myStr)"
            vc.isForActivity = true
            vc.index = 0
            let commentsArray = NSMutableArray.init()
            var commentModel = [CommentModel]()
            
            let commentsArraynew = mydict.value(forKey: "comment") as! NSArray


            if myArray != nil {
                for comment in commentsArraynew {
                    let DataObject = CommentModel()
                    DataObject.JsonParseFromDict(comment as! JSONDICTIONARY)
                    commentModel.append(DataObject)
                    commentsArray.add(DataObject)
                }
            }
            
            vc.arrComments = commentsArray
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mylocation()
    }
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           self.locationManager.stopUpdatingLocation()
          
       }
    
    //MARK: - User Defined Methods
    
    @objc func showFullImage(sender : UITapGestureRecognizer) {
        
        let configuration = ImageViewerConfiguration { config in
            config.imageView = imgViewJob
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
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
    
    @objc func swipeLeft() {
        print("swipeLeft")
        
        if self.page < pageCntrl.numberOfPages - 1
        {
            let transition = CATransition()
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            self.imgViewJob.layer.add(transition, forKey: nil)
            
            self.page += 1
            if self.isFromMessages == true
            {
                self.displayJobData()
            }
            else {
                self.update()
            }
        }
    }
    
    @objc func swipeRight() {
        print("swipeRight")
        
        print(page)
        
        if self.page > 0
        {
            let transition = CATransition()
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            self.imgViewJob.layer.add(transition, forKey: nil)
            
            self.page -= 1
            if self.isFromMessages == true
            {
                self.displayJobData()
            }
            else {
                self.update()
            }
        }
    }
    func displayJobData() {
        
        pageCntrl.numberOfPages = imagesArray.count
        pageCntrl.currentPage = page
        
        if imagesArray.count > 0 {
            indicator.startAnimating()
            indicator.isHidden = false
            
            var url = imagesArray.object(at: page) as! String
            url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
            
            if url.contains(".mp4") == true {
                self.imgViewJob.isHidden = true
                self.videoPlayerView.isHidden = false
                
                
                let player = AVPlayer(url: URL(string: url)!)
                player.isMuted = true
                videoPlayerView.playerLayer.player = player
                videoPlayerView.player?.isMuted = true
                
                videoPlayerView.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                
                videoPlayerView.player!.play()
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showFullVideo))
                videoPlayerView.addGestureRecognizer(tapGesture)
                
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
            }
            else {
                self.imgViewJob.isHidden = false
                self.videoPlayerView.isHidden = true
                
                self.imgViewJob!.sd_setImage(with: URL(string:  url), placeholderImage: UIImage(named: "Icon_Add_Picture"), options:[], completed: { (image, error, cacheType, imageURL) in
                    // Perform operation.
                    if image != nil {
                        self.indicator.stopAnimating()
                        self.indicator.hidesWhenStopped = true
                    }
                })
            }
        }
        
        self.lblJobTitle.text = (dictJobDetails["title"] as! String)
        
        
        Analytics.logEvent(NSLocalizedString("job_profile_view", comment: ""), parameters: [NSLocalizedString("job_title", comment: ""): (dictJobDetails["title"] as! String)])
        
        if (dictJobDetails["description"] as! String).count > 0 {
            self.lblDescription.text = (dictJobDetails["description"] as! String)
        }
        else {
            self.lblDescription.text = "No description"
        }
        
        self.lblEstBudget.text = (dictJobDetails["estimate_budget"] as! String)
        
        let created = (dictJobDetails["created_at"] as! String)
        self.lblDate.text = Date.getFormattedDateForJob(string: created)
        
        let createdTime = (dictJobDetails["created_at"] as! String)
        self.lblTime.text = Date.getFormattedTimeForJob(string: createdTime)
        
        
        let titleHeight = heightForView(text:  self.lblJobTitle.text!, font: UIFont (name: "Helvetica", size: 13)!, width: 322.0)
        
        let descriptionHeight = heightForView(text:  self.lblDescription.text!, font: UIFont (name: "Helvetica", size: 13)!, width: 322.0)
        viewHeightConstraint.constant = titleHeight + descriptionHeight + 130
        
        //scrollViewHeightConstraint.constant = 580 + descriptionHeight
        
        let userDict = self.userDict//dictJobDetails["user"] as! NSDictionary
        let firstName = userDict["firstname"] as! String
        let lastName = userDict["lastname"] as! String
        self.lblPostedBy.text = firstName + " " + lastName
        
        let jobUserID = dictJobDetails["user_id"] as! Int
        let jobUserIdString = "\(jobUserID)"
        
        isMyJob = false
        if jobUserIdString == UserSettings.userID {
            isMyJob = true
        }
        
        if isMyJob == true {
            btnContactUser.isHidden = true
            btnReportJob.isHidden = true
        }
        else {
            btnContactUser.isHidden = false
            btnReportJob.isHidden = false
        }
    }
    
    func update() {
        
        pageCntrl.numberOfPages = imagesArray.count
        pageCntrl.currentPage = page
        
        if imagesArray.count > 0 {
            indicator.isHidden = false
            indicator.startAnimating()
            
            var url = imagesArray.object(at: page) as! String
            url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
            
            if url.contains(".mp4") == true {
                self.imgViewJob.isHidden = true
                self.videoPlayerView.isHidden = false
                                
                let player = AVPlayer(url: URL(string: url)!)
                player.isMuted = true
                videoPlayerView.playerLayer.player = player
                videoPlayerView.player?.isMuted = true
                
                videoPlayerView.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                
                videoPlayerView.player!.play()
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showFullVideo))
                videoPlayerView.addGestureRecognizer(tapGesture)
                
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
            }
            else {
                self.imgViewJob.isHidden = false
                self.videoPlayerView.isHidden = true
                
                self.imgViewJob!.sd_setImage(with: URL(string:  url), placeholderImage: UIImage(named: "Icon_Add_Picture"), options:[], completed: { (image, error, cacheType, imageURL) in
                    // Perform operation.
                    if image != nil {
                        self.indicator.stopAnimating()
                        self.indicator.hidesWhenStopped = true
                    }
                })
            }
        }
        
        self.lblJobTitle.text = JobsModel.Shared.arrJobs[self.index].jobTitle
        
        Analytics.logEvent(NSLocalizedString("job_profile_view", comment: ""), parameters: [NSLocalizedString("job_title", comment: ""): JobsModel.Shared.arrJobs[self.index].jobTitle!])
        
        if (JobsModel.Shared.arrJobs[self.index].jobDescription)!.count > 0 {
            self.lblDescription.text = JobsModel.Shared.arrJobs[self.index].jobDescription
        }
        else {
            self.lblDescription.text = "No description"
        }
        
        self.lblEstBudget.text = JobsModel.Shared.arrJobs[self.index].estimatedBudget
        
        let created = JobsModel.Shared.arrJobs[self.index].jobCreationDate
        self.lblDate.text = Date.getFormattedDateForJob(string: created!)
        
        let createdTime = JobsModel.Shared.arrJobs[self.index].jobCreationDate
        self.lblTime.text = Date.getFormattedTimeForJob(string: createdTime!)
        
        let titleHeight = heightForView(text:  self.lblJobTitle.text!, font: UIFont (name: "Helvetica", size: 13)!, width: 322.0)
        
        let descriptionHeight = heightForView(text:  self.lblDescription.text!, font: UIFont (name: "Helvetica", size: 13)!, width: 322.0)
        viewHeightConstraint.constant = titleHeight + descriptionHeight + 130
        
        //scrollViewHeightConstraint.constant = 580 + descriptionHeight
        
        let userDict = JobsModel.Shared.arrJobs[self.index].userDict!
        let firstName = userDict["firstname"] as! String
        let lastName = userDict["lastname"] as! String
        self.lblPostedBy.text = firstName + " " + lastName
    }
    
    @objc func showFullVideo() {
        
        var url = imagesArray.object(at: page) as! String
        url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
        
        let videoURL = URL(string: url)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    @objc func userNameTapped() {
        
        var userDict = NSDictionary()
        var userID = String()
        
        if self.isFromMessages == true {
            userDict = dictJobDetails["user"] as! NSDictionary
        }
        else {
            userDict = JobsModel.Shared.arrJobs[self.index].userDict!
        }
        userID = String(userDict["id"] as! Int)
        
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EntrepreneurProfileVC") as! EntrepreneurProfileVC
        vc.isOtherUser = true
        vc.dictEntrpreneur = userDict
        vc.otherUserId = userID
        self.show(vc, sender: self)
    }
    
    func updatelocationCurrentJobProfile() {
        
        let currentLocation = CLLocation(latitude: currentLat, longitude: currentLong)
        if self.isFromMessages == true {
            jobLocation = CLLocation(latitude: Double(dictJobDetails["lat"] as! String)!, longitude: Double(dictJobDetails["lng"] as! String)!)
        }
        else {
            jobLocation = CLLocation(latitude: Double(JobsModel.Shared.arrJobs[self.index].jobLatitude!)!, longitude: Double(JobsModel.Shared.arrJobs[self.index].jobLongitude!)!)
        }
        
        let distanceInMeters = currentLocation.distance(from: jobLocation)
        let s =   String(format: "%.1fmi", (distanceInMeters/1609.344))
        self.lblApproxDistance.text = s + " Miles"
    }
    
    func mylocation()   {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        // Ask for Authorisation from the User.
        
        // For use in foreground
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    //MARK: - API
    
    func callAPIToReportJob() {
        
        let userID = UserSettings.userID//String()
        let status = "1"
        let jobId = JobsModel.Shared.arrJobs[self.index].jobId!
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
                
                Analytics.logEvent(NSLocalizedString("click_report_job", comment: ""), parameters: [NSLocalizedString("job_title", comment: ""): JobsModel.Shared.arrJobs[self.index].jobTitle!])
                
                let actionSheet: UIAlertController = UIAlertController(title: AppName, message: "Thank you for your report. We will take necessary action within 24 hours", preferredStyle: .actionSheet)
                
                let OkActionButton = UIAlertAction(title: "Ok", style: .cancel) { _ in
                    print("Cancel")
                }
                actionSheet.addAction(OkActionButton)
                
                self.present(actionSheet, animated: true, completion: nil)
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    
    //MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latestLocation: AnyObject = locations[locations.count - 1]
        let mystartLocation = latestLocation as! CLLocation;
        
        currentLat = mystartLocation.coordinate.latitude
        currentLong =  mystartLocation.coordinate.longitude
        
        self.updatelocationCurrentJobProfile()
    }
    
    //MARK: - Actions
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnGetDirectionsClicked(_ sender: UIButton) {
        
        if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(jobLocation.coordinate.latitude),\(jobLocation.coordinate.longitude)&directionsmode=driving") {
            UIApplication.shared.open(url, options: [:])
        }
        else {
            NSLog("Can't use comgooglemaps://");
        }
    }
    
    @IBAction func btnContactUserClicked(_ sender: UIButton) {
        
        if UserSettings.isUserLogin == true {
            
            let storbrd = UIStoryboard.init(name: "Messages", bundle: nil)
            let vc = storbrd.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
            
            var jobID = String()
            var toId = String()
            var userDict = NSDictionary()
            
            if self.isFromMessages == true {
                print(dictJobDetails)
                
                if let jobid = dictJobDetails["id"] as? Int {
                    jobID = "\(jobid)"
                }
                
                userDict = dictJobDetails["user"] as! NSDictionary
                let userIDNumber = userDict["id"]
                
                if let id = userIDNumber as? NSNumber
                {
                    toId = "\(id)"
                }
                
                let uName = (userDict["firstname"] as! String) + " " + (userDict["lastname"] as! String)
                vc.userName = uName
                
                Analytics.logEvent(NSLocalizedString("click_contact_user", comment: ""), parameters: [NSLocalizedString("user_name", comment: ""): uName])
                
                vc.userProfilePath = userDict["profile_pic"] as! String
                vc.isFromNotification = false
            }
            else {
                if let jobid = JobsModel.Shared.arrJobs[self.index].jobId {
                    jobID = "\(jobid)"
                }
                
                userDict = JobsModel.Shared.arrJobs[self.index].userDict!
                
                let userIDNumber = userDict["id"]
                
                if let id = userIDNumber as? NSNumber
                {
                    toId = "\(id)"
                }
                
                let uName = (userDict["firstname"] as! String) + " " + (userDict["lastname"] as! String)
                vc.userName = uName
                
                Analytics.logEvent(NSLocalizedString("click_contact_user", comment: ""), parameters: [NSLocalizedString("user_name", comment: ""): uName])
                
                vc.userProfilePath = userDict["profile_pic"] as! String
            }
            
            vc.isForJobChat = true
            let fromId = UserSettings.userID
            
            vc.jobId = jobID
            vc.toId = toId
            vc.fromId = fromId
            vc.profileDict = userDict
            
            self.navigationController?.show(vc, sender: self)
        }
        else {
            SAAlertBar.show(.info, message: "login as entrepreneur to contact to user.")
        }
    }
    
    @IBAction func btnRepostJobClicked(_ sender: UIButton) {
        
        self.callAPIToReportJob()
    }
}

extension Date {
    static func getFormattedDate(string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // This formate is input formated .
        
        let formateDate = dateFormatter.date(from:string)!
        dateFormatter.dateFormat = "MMM yyyy" // Output Formated
        
        print ("Print :\(dateFormatter.string(from: formateDate))")//Print :02-02-2018
        return dateFormatter.string(from: formateDate)
    }
    
    static func getFormattedDateForJob(string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // This formate is input formated .
        
        let formateDate = dateFormatter.date(from:string)!
        dateFormatter.dateFormat = "dd MMM yyyy" // Output Formated
        
        print ("Print :\(dateFormatter.string(from: formateDate))")//Print :02-02-2018
        return dateFormatter.string(from: formateDate)
    }
    
    static func getFormattedTimeForJob(string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // This formate is input formated .
        
        var formateDate = dateFormatter.date(from:string)!
        formateDate = (formateDate.toLocalTime())
        dateFormatter.dateFormat = "hh:mm a" // Output Formated
        
        print ("Print :\(dateFormatter.string(from: formateDate))")//Print :02-02-2018
        return dateFormatter.string(from: formateDate)
    }
}


