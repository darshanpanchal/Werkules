//
//  UserLikesVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 30/01/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit

class UserLikesVC: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    
    @IBOutlet weak var tableUserLikes: UITableView!
    
    var arrUsers = NSArray()
    var toID = String()
    
    // MARK: - UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        RegisterCell()
    }
    
    // MARK: - Action
    
    @IBAction func btnBackclicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Register Cell
    
    func RegisterCell() {
        tableUserLikes.register(UINib(nibName: "ProffesionalsCell", bundle: nil), forCellReuseIdentifier: "ProffesionalsCell")
    }
    
    //MARK: - UITableView Datasource & Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableUserLikes.dequeueReusableCell(withIdentifier: "ProffesionalsCell") as! ProffesionalsCell
        cell.selectionStyle = .none
        
        let likemodel = arrUsers.object(at: indexPath.row) as! LikeModel
        let userDict = likemodel.userDict
        
        var url = userDict["profile_pic"] as! String
        url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
        
        cell.btnProfilePic.tag = indexPath.row
        cell.btnProfilePic.sd_setImage(with: URL(string: url), for: .normal, completed: nil)
        cell.btnProfilePic.addTarget(self, action: #selector(goToUserProfile), for: .touchUpInside)
        
        let userName = (userDict["firstname"] as! String) + " " + (userDict["lastname"] as! String)
        
        let userId = userDict.value(forKey: "id") as! Int
        let isUseradded = self.isUserAdded(userID: userId)
        if isUseradded == true {
            cell.btnAddToNetwork.setImage(UIImage(named: "user_added"), for: .normal)
        }
        else {
            cell.btnAddToNetwork.setImage(UIImage(named: "addToNetwork"), for: .normal)
        }
        
        cell.btnUserName.tag = indexPath.row
        cell.btnUserName.setTitle(userName, for: .normal)
        cell.btnUserName.addTarget(self, action: #selector(goToUserProfile), for: .touchUpInside)
        
        cell.lblCompanyName.text = (userDict["company"] as! String)
        
        cell.btnMessage.tag = indexPath.row
        cell.btnMessage.addTarget(self, action: #selector(goToChat), for: .touchUpInside)
        
        cell.btnAddToNetwork.tag = indexPath.row
        cell.btnAddToNetwork.addTarget(self, action: #selector(addToMyNetwork), for: .touchUpInside)
        
        let userID = likemodel.userId
        if "\(userID)" == UserSettings.userID {
            cell.btnMessage.isHidden = true
            cell.btnAddToNetwork.isHidden = true
        }
        else {
            cell.btnMessage.isHidden = false
            cell.btnAddToNetwork.isHidden = false
        }
        
        return cell
    }
    
    // MARK: - User Defined Methods
    
    @objc func goToUserProfile(_ sender: UIButton ) {
        
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EntrepreneurProfileVC") as! EntrepreneurProfileVC
        vc.isOtherUser = true
        vc.dictEntrpreneur = (arrUsers[sender.tag] as! LikeModel).userDict
        vc.otherUserId = String((arrUsers[sender.tag] as! LikeModel).userId!)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func goToChat(_ sender : UIButton) {
        
        let storyboard = UIStoryboard.init(name: "Messages", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        
        let dict = (arrUsers.object(at: sender.tag) as! LikeModel).userDict
        
        chatVC.fromId = UserSettings.userID
        
        let userID = dict.value(forKey: "id") as! Int
        chatVC.profileDict = dict
        chatVC.toId = "\(userID)"
        chatVC.userName = (dict["firstname"] as! String) + " " + (dict["lastname"] as! String)
        chatVC.userProfilePath = dict["profile_pic"] as! String
        chatVC.isForJobChat = false
        
        self.navigationController?.pushViewController(chatVC, animated: true)
            }
    
    @objc func addToMyNetwork(_ sender : UIButton) {
        
        let userDict = (arrUsers.object(at: sender.tag) as! LikeModel).userDict
        let userId = userDict.value(forKey: "id") as! Int
        self.toID = "\(userId)"
        self.callAPIToAddUserToNetwork()
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
    
    //MARK: - API
    
    func callAPIToAddUserToNetwork() {
        
        let dict = [
            APIManager.Parameter.fromID : UserSettings.userID,
            APIManager.Parameter.toID : self.toID
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
                
                self.tableUserLikes.reloadData()
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                if message != "Already added in your network!" {
                    SAAlertBar.show(.error, message:message.capitalized)
                }
            }
        }
    }
}
