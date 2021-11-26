//
//  MyNetworkVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 13/03/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit

class MyNetworkVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tblMyNetwork: UITableView!
    @IBOutlet weak var lblNoRecord: UILabel!
    
    var arrMyNetworkUsers = NSArray()
    var networkIDToRemove = String()
    var userIDToRemove = Int()
    
    //MARK: - UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        RegisterCell()
        self.callAPIToGetMyNetworkUsers()
    }
    
    //MARK: - Action
    
    @IBAction func btnCancelClicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Register Cell
    
    func RegisterCell() {
        tblMyNetwork.register(UINib(nibName: "MessageFromListcell", bundle: nil), forCellReuseIdentifier: "MessageFromListcell")
    }
    
    //MARK: - UITableView Datasource & Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMyNetworkUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblMyNetwork.dequeueReusableCell(withIdentifier: "MessageFromListcell") as! MessageFromListcell
        cell.selectionStyle = .none
        
        let dataDict = arrMyNetworkUsers.object(at: indexPath.row) as! NSDictionary
        let userDict = dataDict.value(forKey: "to_user") as! NSDictionary
        
        var url = userDict["profile_pic"] as! String
        url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
        
        cell.btnProfilePic.tag = indexPath.row
        cell.btnProfilePic.sd_setImage(with: URL(string: url), for: .normal, completed: nil)
        cell.btnProfilePic.addTarget(self, action: #selector(goToUserProfile), for: .touchUpInside)
        
        let userName = (userDict["firstname"] as! String) + " " + (userDict["lastname"] as! String)
        
        cell.btnUserName.tag = indexPath.row
        cell.btnUserName.setTitle(userName, for: .normal)
        cell.btnUserName.addTarget(self, action: #selector(goToUserProfile), for: .touchUpInside)
        
        cell.btnRemove.isHidden = false
        cell.btnRemove.tag = indexPath.row
        cell.btnRemove.addTarget(self, action: #selector(removeFromNetwork), for: .touchUpInside)
        
        cell.imgViewarrow.isHidden = true
        
        return cell
    }
    
    //MARK: - User defined Methods
    
    @objc func goToUserProfile(_ sender : UIButton) {
        
        let dict = arrMyNetworkUsers.object(at: sender.tag) as! NSDictionary
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
    
    @objc func removeFromNetwork(_ sender: UIButton) {
        
        let alert = UIAlertController(title: AppName, message: "Are you sure you want to remove this user from your network?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            let dict = self.arrMyNetworkUsers.object(at: sender.tag) as! NSDictionary
            
            let networkId = dict.value(forKey: "id") as! Int
            self.networkIDToRemove = "\(networkId)"
            
            let userDict = dict.value(forKey: "to_user") as! NSDictionary
            self.userIDToRemove = userDict.value(forKey: "id") as! Int
            
            self.callAPIToRemoveFromNetwork()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - API
    
    func callAPIToGetMyNetworkUsers() {
        
        let dict = [
            APIManager.Parameter.fromID : UserSettings.userID,
            APIManager.Parameter.limit : "50",
            APIManager.Parameter.page : "1"
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_NetworkList, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                if (dataDict["data"] as! NSArray).count != 0 {
                    
                    self.arrMyNetworkUsers = dataDict["data"] as! NSArray
                    self.lblNoRecord.isHidden = true
                    self.tblMyNetwork.reloadData()
                }
                else {
                    self.tblMyNetwork.isHidden = true
                    self.lblNoRecord.isHidden = false
                }
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        }
    }
    
    func callAPIToRemoveFromNetwork() {
        
        let dict = [
            APIManager.Parameter.networkId : self.networkIDToRemove
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_RemoveFromNetwork, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                for (index,user) in NetworkModel.Shared.arrUsers.enumerated() {
                    
                    let userId = user.userId
                    if self.userIDToRemove == userId {
                        NetworkModel.Shared.arrUsers.remove(at: index)
                    }
                }
                
                self.callAPIToGetMyNetworkUsers()
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
