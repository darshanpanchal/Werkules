//
//  MessagesFromListVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 13/03/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit

class MessagesFromListVC: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tblMessagefromList: UITableView!
    @IBOutlet weak var lblNoRecord: UILabel!
    
    var arrMessageFromUserList = NSArray()
    
    //MARK: - UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        RegisterCell()
        self.callAPIToGetMessageFromUserList()
    }
    
    //MARK: - Actions
    
    @IBAction func btnCancelClicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Register Cell
    
    func RegisterCell() {
        tblMessagefromList.register(UINib(nibName: "MessageFromListcell", bundle: nil), forCellReuseIdentifier: "MessageFromListcell")
    }
    
    //MARK: - UITableView Datasource & Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMessageFromUserList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblMessagefromList.dequeueReusableCell(withIdentifier: "MessageFromListcell") as! MessageFromListcell
        cell.selectionStyle = .none
        
        let dataDict = arrMessageFromUserList.object(at: indexPath.row) as! NSDictionary
        let tempUserDict = dataDict.value(forKey: "from_user") as! NSDictionary
        let id = tempUserDict["id"] as! Int
        
        var userDict = NSDictionary()
        if UserSettings.userID == "\(id)" {
            userDict = dataDict.value(forKey: "to_user") as! NSDictionary
        }
        else {
            userDict = dataDict.value(forKey: "from_user") as! NSDictionary
        }
        
        var url = userDict["profile_pic"] as! String
        url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
        
        cell.btnProfilePic.tag = indexPath.row
        autoreleasepool {
        cell.btnProfilePic.sd_setImage(with: URL(string: url), for: .normal, completed: nil)
        }
        cell.btnProfilePic.addTarget(self, action: #selector(goToUserProfile), for: .touchUpInside)
        
        let userName = (userDict["firstname"] as! String) + " " + (userDict["lastname"] as! String)
        
        cell.btnUserName.tag = indexPath.row
        cell.btnUserName.setTitle(userName, for: .normal)
        cell.btnUserName.addTarget(self, action: #selector(goToUserProfile), for: .touchUpInside)
        
        cell.btnRemove.isHidden = true
        cell.imgViewarrow.isHidden = false
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.init(name: "Messages", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        
        let dataDict = (arrMessageFromUserList.object(at: indexPath.row) as! NSDictionary)
        
        let tempUserDict = dataDict.value(forKey: "from_user") as! NSDictionary
        let id = tempUserDict["id"] as! Int
        
        var userDict = NSDictionary()
        if UserSettings.userID == "\(id)" {
            userDict = dataDict.value(forKey: "to_user") as! NSDictionary
        }
        else {
            userDict = dataDict.value(forKey: "from_user") as! NSDictionary
        }
        
        
        chatVC.fromId = UserSettings.userID
        
        let userID = userDict.value(forKey: "id") as! Int
        chatVC.profileDict = userDict
        chatVC.toId = "\(userID)"
        chatVC.userName = (userDict["firstname"] as! String) + " " + (userDict["lastname"] as! String)
        chatVC.userProfilePath = userDict["profile_pic"] as! String
        chatVC.isForJobChat = false
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    //MARK: - User defined Methods
    
    @objc func goToUserProfile(_ sender : UIButton) {
        
        let dict = arrMessageFromUserList.object(at: sender.tag) as! NSDictionary
        
        let userDict = dict.value(forKey: "to_user") as! NSDictionary
        
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EntrepreneurProfileVC") as! EntrepreneurProfileVC
        vc.isOtherUser = true
        let userID = userDict["id"] as! Int
        vc.otherUserId = "\(userID)"
        vc.dictEntrpreneur = userDict
        vc.modalPresentationStyle = .fullScreen
        self.show(vc, sender: self)
    }
    
    //MARK: - API
    
    func callAPIToGetMessageFromUserList() {
        
        let dict = [
            APIManager.Parameter.userID : UserSettings.userID
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_ChatBeforeList, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                if (dataDict["data"] as! NSArray).count != 0 {
                    
                    self.arrMessageFromUserList = dataDict["data"] as! NSArray
                    self.lblNoRecord.isHidden = true
                    self.tblMessagefromList.reloadData()
                }
                else {
                    self.tblMessagefromList.isHidden = true
                    self.lblNoRecord.isHidden = false
                }
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
