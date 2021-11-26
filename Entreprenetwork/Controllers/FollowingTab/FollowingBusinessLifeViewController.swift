//
//  FollowingBusinessLifeViewController.swift
//  Entreprenetwork
//
//  Created by Darshan on 16/09/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class FollowingBusinessLifeViewController: UIViewController {

    @IBOutlet weak var searchViewContainer:MyBorderView!
    @IBOutlet weak var lblNumberOfFollowed:UILabel!
    @IBOutlet weak var tableViewFollowing:UITableView!

    @IBOutlet weak var buttonSort:UIButton!

    @IBOutlet weak var sortMoreview:UIView!
    @IBOutlet weak var sortNewestview:UIView!
    @IBOutlet weak var sortOlderview:UIView!
    
    @IBOutlet weak var txtSearch:UITextField!
    
    var arrayOfDetail:[[String:Any]] = []
    var arrayOfFilterDetail:[[String:Any]] = []
    
    var isNewest:Bool = true
    var isNewestSelected:Bool {
        get{
            return isNewest
        }
        set{
            isNewest = newValue
            self.configureNewestSelection()
            DispatchQueue.main.async {
                self.resetToDefalt()
                self.apiRequestForSearchWithTyppedString(string: "")
            }
        }
    }
    var isLoadMoreSearch:Bool = false
    var currentPage:Int = 1
    var fetchPageLimit:Int = 10

    var numberOfFollower = 0


    @IBOutlet weak var buttonBadgeCount:UIButton!

    var unreadMessage:Int = 0
    var totalUnreadMessage:Int{
        get{
            return unreadMessage
        }
        set{
            unreadMessage = newValue
            DispatchQueue.main.async {
                self.buttonBadgeCount.setTitle("\(newValue)", for: .normal)
                self.buttonBadgeCount.isHidden = newValue == 0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfNewMessageReceiveNotification(notification:)), name: .chatUnreadCount, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.callAPIRequestToGetChatUnreadCount()
        }

    }
    @objc func methodOfNewMessageReceiveNotification(notification:Notification){
        if let userInfo = notification.userInfo as? [String:Any]{
            print(userInfo)
            self.callAPIRequestToGetChatUnreadCount()
        }
    }
    func callAPIRequestToGetChatUnreadCount(){
        APIRequestClient.shared.sendAPIRequest(requestType: .GET, queryString:kGETChatUnreadCount, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["success_data"] as? Int{
                    DispatchQueue.main.async {
                                self.totalUnreadMessage = successData
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.apiRequestForSearchWithTyppedString(string: "")
        }
    }
    func setup(){
        self.searchViewContainer.layer.cornerRadius = 26.0
        self.searchViewContainer.clipsToBounds = true
        self.sortMoreview.layer.borderColor = UIColor.lightGray.cgColor
        self.sortMoreview.layer.borderWidth = 0.5
        self.sortMoreview.layer.cornerRadius = 6.0
        self.sortMoreview.clipsToBounds = true
        self.sortNewestview.backgroundColor = UIColor.white
        self.sortOlderview.backgroundColor = UIColor.init(hex: "F3F3F3")
        self.sortMoreview.isHidden = true
        self.txtSearch.delegate = self
        self.txtSearch.keyboardType = .namePhonePad
        self.configureTableView()
        
    }
    func configureTableView(){
          self.tableViewFollowing.register(UINib.init(nibName: "FollowTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowTableViewCell")
          self.tableViewFollowing.showsVerticalScrollIndicator = false
          self.tableViewFollowing.delegate = self
          self.tableViewFollowing.dataSource = self
          self.tableViewFollowing.rowHeight = UITableView.automaticDimension
          self.tableViewFollowing.estimatedRowHeight = 100.0
          self.tableViewFollowing.reloadData()
          self.tableViewFollowing.tableHeaderView = UIView()
        self.tableViewFollowing.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100.0))

      }
    func resetToDefalt(){
        DispatchQueue.main.async {
            self.currentPage = 1
            self.isLoadMoreSearch = false
            self.arrayOfFilterDetail.removeAll()
            self.arrayOfDetail.removeAll()
            self.tableViewFollowing.reloadData()
        }
    }
    @IBAction func buttonChatListSelector(sender:UIButton){
        self.pushtoChatListViewController()
    }
    func pushtoChatListViewController(){
        if let chatListViewController = UIStoryboard.messages.instantiateViewController(identifier: "ChatListViewController") as? ChatListViewController{
            chatListViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatListViewController, animated: true)
        }

    }
    // MARK: - API Request Methods
    func apiRequestForSearchWithTyppedString(string:String){
        
        var strAPIEndPoint  = kFollowingList
      
        APIRequestClient.shared.cancelTaskWithUrl { (true) in
            var dict:[String:Any]  = [:]
              dict["keyword"] = "\(string)"
            dict["limit"] = "\(self.fetchPageLimit)"
            dict["page"] = "\(self.currentPage)"
            dict["sort_by"] = self.isNewestSelected ? "desc" : "asc"
                  APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:strAPIEndPoint , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                                DispatchQueue.main.async {
                                    var typpedText = ""
                                     if let typped = self.txtSearch.text{
                                        typpedText = typped
                                    }
                                    if self.currentPage == 1{
                                        self.arrayOfDetail.removeAll()
                                        self.arrayOfFilterDetail.removeAll()
                                        self.tableViewFollowing.reloadData()
//                                        if typpedText.count == 0{
//                                            return
//                                        }
                                    }
                                    if let success = responseSuccess as? [String:Any],let objnumberOfFollower = success["total_follower"] as? Int{
                                        DispatchQueue.main.async {
                                            self.numberOfFollower  = objnumberOfFollower
                                            self.lblNumberOfFollowed.text = "\(self.numberOfFollower) followed"
                                        }
                                    }
                                    if let success = responseSuccess as? [String:Any],let arrayReview = success["success_data"] as? [[String:Any]]{
                                    self.isLoadMoreSearch = (arrayReview.count == self.fetchPageLimit)
                                          DispatchQueue.main.async {
                                            
                                            var newArray:[[String:Any]] = []
                                            for var objArray in arrayReview {
                                                objArray["isshowmore"] = false
                                                newArray.append(objArray)
                                            }
                                            print("===== \(newArray)")
                                            self.arrayOfDetail.append(contentsOf: newArray)// = arrayReview
                                            self.arrayOfFilterDetail.append(contentsOf: newArray) //= arrayReview
                                            
                                            self.tableViewFollowing.reloadData()
                                          }
                                  }
                                }
                                 }) { (responseFail) in
                                        DispatchQueue.main.async {
                                            self.resetToDefalt()
                               if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String]{
                                      
                                          if errorMessage.count > 0{
                                              SAAlertBar.show(.error, message:"\(errorMessage.first!)".localizedLowercase)
                                          }
                                      
                                  }else{
                                         DispatchQueue.main.async {
                                            // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                         }
                                     }
                                        }
                                 }
        }
    }
    func followUnFollowAPIRequest(index:Int){
        var dict:[String:Any]  = [:]
        dict["from_user_type"] = "customer"
        if self.arrayOfFilterDetail.count > index{
            var objBusinessLife = self.arrayOfFilterDetail[index]
            if let userID = objBusinessLife["user_id"]{
                dict["to_user_id"] = "\(userID)"
            }
            if UserDetail.isUserLoggedIn,let currentUser = UserDetail.getUserFromUserDefault(){
                dict["from_user_id"] = "\(currentUser.id)"
            }
            var apiRequestURL = kBusinessFeedUnFollow

            APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:apiRequestURL , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                        if let success = responseSuccess as? [String:Any],let _ = success["success_data"] as? [[String:Any]]{


                            DispatchQueue.main.async {
                                self.arrayOfFilterDetail.remove(at: index)
                                self.numberOfFollower -= 1
                                self.lblNumberOfFollowed.text = "\(self.numberOfFollower) followed"
                                self.tableViewFollowing.reloadData()
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
                                 //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                               }
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
    func pushToProviderDetailScreenWithProviderId(providerID:String){
          let objStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
          if let objProviderDetail = objStoryboard.instantiateViewController(withIdentifier: "ProviderDetailViewController") as? ProviderDetailViewController{
              objProviderDetail.hidesBottomBarWhenPushed = true
              objProviderDetail.providerID = providerID
              objProviderDetail.showBookNowButton = true
              self.navigationController?.pushViewController(objProviderDetail, animated: true)
          }
      }
    func pushtoChatViewControllerWith(dict:[String:Any]){
        if let chatViewConroller = UIStoryboard.messages.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC{
            chatViewConroller.hidesBottomBarWhenPushed = true
            if let user_id = dict["user_id"]{
                 chatViewConroller.receiverID = "\(user_id)"
             }
             if let profile_pic = dict["profile_pic"]{
                 chatViewConroller.strReceiverProfileURL = "\(profile_pic)"
             }
             if let firstname = dict["name"]{
                 chatViewConroller.strReceiverName = "\(firstname)"
             }
            if let senderid = dict["quickblox_id"]{
                chatViewConroller.senderID = "\(senderid)"
            }
            chatViewConroller.toUserTypeStr = "customer"
            chatViewConroller.isForCustomerToProvider = false
            chatViewConroller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatViewConroller, animated: true)
        }
    }

}
extension FollowingBusinessLifeViewController{
    @IBAction func buttonSidemenuSelector(sender:UIButton){

        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
            /*
            if let container = self.so_containerViewController {
                container.isSideViewControllerPresented = true
            }*/
        }
    }
    @IBAction func buttonSortOptionShowSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.sortMoreview.isHidden = !self.sortMoreview.isHidden
        }
    }
    @IBAction func buttonNewestSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.isNewestSelected = true
        }
    }
    fileprivate func configureNewestSelection() {
        self.sortMoreview.isHidden = true
        if self.isNewestSelected{
            self.sortNewestview.backgroundColor = UIColor.white
            self.sortOlderview.backgroundColor = UIColor.init(hex: "F3F3F3")
        }else{
            self.sortNewestview.backgroundColor = UIColor.init(hex: "F3F3F3")
            self.sortOlderview.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func buttonOldestSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.isNewestSelected = false
        }
    }
    
}
extension FollowingBusinessLifeViewController:UITableViewDelegate,UITableViewDataSource,FollowTableViewCellDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  self.arrayOfFilterDetail.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableViewFollowing.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath) as! FollowTableViewCell
        DispatchQueue.main.async {
            let objFilterData = self.arrayOfFilterDetail[indexPath.row]
            cell.lblProviderName.text =  "\(objFilterData["name"] ?? "")"
            if let showMore = objFilterData["isshowmore"] as? Bool{
                cell.moreview.isHidden = !showMore
                cell.isShowdetail = showMore
                cell.buttonmore.isSelected = !showMore
            }
            if let profileImage = objFilterData["profile_pic"],"\(profileImage)".count > 0{
                if let imgURL = URL.init(string: "\(profileImage)"){
                    cell.imageProvider.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                }
            }
            
        }
        
        if indexPath.row+1 == self.arrayOfFilterDetail.count, self.isLoadMoreSearch{ //last index
              DispatchQueue.global(qos: .background).async {
                 self.currentPage += 1
                DispatchQueue.main.async {
                    if let currenttext = self.txtSearch.text,currenttext.count > 0{
                        self.apiRequestForSearchWithTyppedString(string: self.txtSearch.text ?? "")
                    }else{
                        self.resetToDefalt()
                    }
                }
              }
        }
        cell.delegate = self
        cell.tag = indexPath.row
        cell.contentView.superview?.clipsToBounds =  false

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.hideMoreOptionOnRow(indexPath: indexPath)


    }
    func hideMoreOptionOnRow(indexPath: IndexPath){
        var objFilterData = self.arrayOfFilterDetail[indexPath.row]
        if let showMore = objFilterData["isshowmore"] as? Bool,showMore{
            objFilterData["isshowmore"] = false
            self.arrayOfFilterDetail[indexPath.row] = objFilterData
            self.tableViewFollowing.reloadRows(at: [indexPath], with: .none)
        }
    }
    func buttonDetailSelector(isShow:Bool,row:Int,viewcontroller:UIViewController){
        var objFilterData = self.arrayOfFilterDetail[row]
        if let showMore = objFilterData["isshowmore"] as? Bool{
            objFilterData["isshowmore"] = !showMore
        }
        self.arrayOfFilterDetail[row] = objFilterData
        if row+1 == self.arrayOfFilterDetail.count{
            self.tableViewFollowing.reloadRows(at: [IndexPath.init(row: row, section: 0)], with: .none)
        }else{
            self.tableViewFollowing.reloadRows(at: [IndexPath.init(row: row, section: 0),IndexPath.init(row: row+1, section: 0)], with: .none)
        }
    }
    func buttonproviderdetailselector(row:Int){
        self.hideMoreOptionOnRow(indexPath: IndexPath.init(row: row, section: 0))
        //provider_id
        let objFilterData = self.arrayOfFilterDetail[row]
        if let providerID = objFilterData["provider_id"]{
            self.pushToProviderDetailScreenWithProviderId(providerID: "\(providerID)")
        }
    }
    func buttoncontactdetailselector(row:Int){
        self.hideMoreOptionOnRow(indexPath: IndexPath.init(row: row, section: 0))
        let objFilterData = self.arrayOfFilterDetail[row]
        self.pushtoChatViewControllerWith(dict: objFilterData)
    }
    func buttonUnfollowselector(row:Int){
        self.hideMoreOptionOnRow(indexPath: IndexPath.init(row: row, section: 0))
        if self.arrayOfFilterDetail.count > row{
            let objBusinessLife = self.arrayOfFilterDetail[row]
            if let userName = objBusinessLife["name"]{
                var strAlert = "Do you want to unfollow \(userName) ?"
                let alert = UIAlertController(title: AppName, message: "\(strAlert)", preferredStyle: .alert)
                       alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                       }))
                       alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                                self.followUnFollowAPIRequest(index: row)
                       }))
                alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
extension FollowingBusinessLifeViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        guard typpedString.count > 0 else {
            DispatchQueue.main.async {
                APIRequestClient.shared.cancelTaskWithUrl { (true) in
                    DispatchQueue.main.async {
                        self.resetToDefalt()
                        self.apiRequestForSearchWithTyppedString(string: "")
                    }
                }
            }
            return true
        }
        DispatchQueue.main.async {
            self.resetToDefalt()
            APIRequestClient.shared.cancelTaskWithUrl { (true) in
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                    self.apiRequestForSearchWithTyppedString(string: typpedString)
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
                    self.apiRequestForSearchWithTyppedString(string: "")
                    textField.resignFirstResponder()
                }
            }
        }
        return true
    }
}
