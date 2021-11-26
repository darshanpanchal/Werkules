//
//  EntrepreneursListVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 27/07/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

//@available(iOS 13.0, *)
class EntrepreneursListVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tblViewEntrepreneurs: UITableView!
    @IBOutlet weak var lblNoEntrpreneur: UILabel!
    
    var arrEntrpreneurList = NSArray()
    var jobID = String()
    var jobTitle = String()
    var jobStatus = String()
    var selectedIndex = Int()
    var assignedToId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        RegisterCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getEntrpreneurList()
    }
    
    // MARK: - Register Cell
    
    func RegisterCell()  {
        
        self.tblViewEntrepreneurs.register(UINib.init(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
    }
    
    // MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrEntrpreneurList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblViewEntrepreneurs.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        
        cell.contentView.backgroundColor = UIColor.clear
        
        cell.selectionStyle = .none
        
        let dict = arrEntrpreneurList.object(at: indexPath.row) as! NSDictionary
        
        let dataDict = dict["from_user"] as! NSDictionary
        
        cell.lblUserName.text = (dataDict["firstname"] as! String) + " " + (dataDict["lastname"] as! String)
        
        cell.btnUserProfile.tag = indexPath.row
        
        var url = dataDict["profile_pic"] as! String
        url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
        
        cell.btnUserProfile!.sd_setImage(with: URL(string: url), for: UIControl.State.normal, placeholderImage: UIImage(named: "user_placeholder"), options: [], context: nil)
        
        cell.btnUserProfile.addTarget(self, action: #selector(userProfileClicked), for: .touchUpInside)
        
        if indexPath.row == arrEntrpreneurList.count - 1 {
            
            cell.lblSeparator.isHidden = true
        }
        
        let userID = dataDict["id"] as! Int
        let userIDString = "\(userID)"
        
        cell.contentView.alpha = 1.0
        cell.btnReview.isHidden = true
        
        let isReviewGiven = dict["review"] as! Bool
        
        if self.jobStatus == "progress" || self.jobStatus == "completed" {
            
            if self.assignedToId == userIDString {
                cell.contentView.alpha = 1.0
                
                if self.jobStatus == "completed" && isReviewGiven == false {
                    cell.btnReview.isHidden = false
                }
            }
            else {
                cell.contentView.alpha = 0.5
            }
        }
        
        if self.jobStatus == "progress" || self.jobStatus == "completed" {
            cell.imgviewThreeDots.isHidden = false
        }
        else{
             cell.imgviewThreeDots.isHidden = true
        }
        
        cell.lblMsgCount.isHidden = true
        cell.imgViewDot.isHidden = true
        let msgCount = dict["msg_count"] as! Int
        if msgCount > 0 {
            cell.imgViewDot.isHidden = false
        }
        else {
            cell.imgViewDot.isHidden = true
        }
        
        cell.btnReview.tag = indexPath.row
        cell.btnReview.addTarget(self, action: #selector(reviewBtnClicked), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "goToChatSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let dict = arrEntrpreneurList.object(at: indexPath.row) as! NSDictionary
        
        if dict["from_user"] is String {
            return false
        }
        
        if self.jobStatus == "completed" {
            return false
        }
        return true
    }
    /*
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var btnTitle = String()
        var status = String()
        var alertTitle = String()
        
        if self.jobStatus == "pending" {
            status = "progress"
            btnTitle = "Assign"
            alertTitle = "Are you sure you want to assign this job to this entrepreneur?"
            
        }
        else if self.jobStatus == "progress" {
            status = "completed"
            btnTitle = "Complete"
            alertTitle = "Are you sure you want to complete this job?"
        }
        
        let assign = UITableViewRowAction(style: .default, title: btnTitle) { (action, indexPath) in
            
            let alert = UIAlertController(title: AppName, message: alertTitle, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                
            }))
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                
                let dictUser = self.arrEntrpreneurList.object(at: indexPath.row) as! NSDictionary
                let dataDict = dictUser["from_user"] as! NSDictionary
                let userID = dataDict["id"] as! Int
                
                let dict = [
                    APIManager.Parameter.jobID : String(self.jobID),
                    APIManager.Parameter.status : status,
                    APIManager.Parameter.progressBy : "\(userID)"
                ]
                
                APIManager.sharedInstance.CallAPIPost(url: Url_jobStatusChange, parameter: dict, complition: { (error, JSONDICTIONARY) in
                    
                    let isError = JSONDICTIONARY!["isError"] as! Bool
                    
                    if  isError == false {
                        print(JSONDICTIONARY as Any)
                        
                        self.jobStatus = status
                        
                        if status == "completed" {
                            self.performSegue(withIdentifier: "showReviewSegue", sender: self)
                        }
                    }
                    else{
                        let message = JSONDICTIONARY!["response"] as! String
                        
                        SAAlertBar.show(.error, message:message.capitalized)
                    }
                })
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        assign.backgroundColor = UIColor.lightGray
        
        return [assign]
    }
    */
    // MARK: - User Defined Methods
    
    @objc func userProfileClicked(_ sender : UIButton) {
        
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EntrepreneurProfileVC") as! EntrepreneurProfileVC
        vc.isOtherUser = true
        vc.dictEntrpreneur = (self.arrEntrpreneurList.object(at: sender.tag) as! NSDictionary)["from_user"] as! NSDictionary
        vc.otherUserId = String((self.arrEntrpreneurList.object(at: sender.tag) as! NSDictionary)["from_id"] as! Int)
        self.show(vc, sender: self)
    }
    
    @objc func reviewBtnClicked(_ sender : UIButton) {
        
        selectedIndex = sender.tag
        self.performSegue(withIdentifier: "showReviewSegue", sender: self)
    }
    
    // MARK: - Actions
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - API Calls
    
    func getEntrpreneurList() {
        
        let dict = [
            APIManager.Parameter.limit : "100",
            APIManager.Parameter.page : "1",
            APIManager.Parameter.jobID : self.jobID,
            APIManager.Parameter.fromID : UserSettings.userID
        ]
        
        APIManager.sharedInstance.CallAPIPost(url: Url_messageBeforeList, parameter: dict, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                if (dataDict["data"] as! NSArray).count == 0 {
                    self.lblNoEntrpreneur.isHidden = false
                    self.tblViewEntrepreneurs.isHidden = true
                }
                else {
                    self.lblNoEntrpreneur.isHidden = true
                    self.tblViewEntrepreneurs.isHidden = false
                    
                    let mutArr = (dataDict["data"] as! NSArray).mutableCopy() as! NSMutableArray
                    
                    for item in mutArr {
                        let dict = item as! NSDictionary
                        if dict["from_user"] is String {
                            mutArr.remove(item)
                        }
                    }
                    
                    self.arrEntrpreneurList = NSArray.init(array: mutArr)//dataDict["data"] as! NSArray
                    
                    self.tblViewEntrepreneurs.reloadData()
                }
                
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                if message == "No member exist." {
                    self.lblNoEntrpreneur.isHidden = false
                    self.tblViewEntrepreneurs.isHidden = true
                }
                else {
                    self.lblNoEntrpreneur.isHidden = true
                    self.tblViewEntrepreneurs.isHidden = false
                }
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let dict = arrEntrpreneurList.object(at: selectedIndex) as! NSDictionary
        let dataDict = dict["from_user"] as! JSONDICTIONARY
        
        if segue.identifier == "goToChatSegue" {
            
            let vc = segue.destination as! ChatVC
            vc.jobId = self.jobID
            
            var toIDString = String()
            if let toid = dataDict["id"] as? NSNumber
            {
                toIDString = "\(toid)"
            }
            vc.toId = toIDString
            vc.fromId = UserSettings.userID
            vc.userName = (dataDict["firstname"] as! String) + " " + (dataDict["lastname"] as! String)
            vc.userProfilePath = dataDict["profile_pic"] as! String
            vc.profileDict = dataDict as NSDictionary
            vc.isFromNotification = false
            vc.isForJobChat = true
        }
        else if segue.identifier == "showReviewSegue" {
            
            let vc = segue.destination as! RatingReviewVC
            
            vc.jobId = self.jobID
            vc.jobTitle = self.jobTitle
            
            var toIDString = String()
            if let toid = dataDict["id"] as? NSNumber
            {
                toIDString = "\(toid)"
            }
            vc.toId = toIDString
            vc.fromId = UserSettings.userID
            
            vc.userNameToReview = (dataDict["firstname"] as! String) + " " + (dataDict["lastname"] as! String)
        }
    }
}
