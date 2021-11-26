//
//  UpdatedBusinessLifeViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 14/05/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import FirebaseDynamicLinks
import Firebase

class UpdatedBusinessLifeViewController: UIViewController {

    @IBOutlet fileprivate weak var tableViewBusinessLife:UITableView!
    @IBOutlet fileprivate weak var lblTitle:UILabel!

    @IBOutlet fileprivate weak var buttonFollow:UIButton!

    @IBOutlet weak var titleLedingConst: NSLayoutConstraint!
    var arrayOfDetail:[BusinessLife] = []
    
    var isLoadMoreBusinessLife:Bool = false
    var currentPage:Int = 1
    var fetchPageLimit:Int = 10

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

        if let currentUser = UserDetail.getUserFromUserDefault(){
            if currentUser.userRoleType == .customer{
//                self.titleLedingConst.constant = 15
            }else{
//                self.titleLedingConst.constant = 80
            }
        }
        // Do any additional setup after loading the view.
        //Configure TableView
        self.setUpMethod()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfNewMessageReceiveNotification(notification:)), name: .chatUnreadCount, object: nil)

    }
    @objc func methodOfNewMessageReceiveNotification(notification:Notification){
        if let userInfo = notification.userInfo as? [String:Any]{
            print(userInfo)
            self.callAPIRequestToGetChatUnreadCount()
        }
    }
    //MARK:- SETUP
    func setUpMethod(){
        self.configureTableView()
    }
    func configureTableView(){
          self.tableViewBusinessLife.register(UINib.init(nibName: "BusinessLifeUpdatedTableViewCell", bundle: nil), forCellReuseIdentifier: "BusinessLifeUpdatedTableViewCell")

          self.tableViewBusinessLife.showsVerticalScrollIndicator = false
          self.tableViewBusinessLife.delegate = self
          self.tableViewBusinessLife.dataSource = self
          self.tableViewBusinessLife.rowHeight = UITableView.automaticDimension
          self.tableViewBusinessLife.estimatedRowHeight = 100.0
          self.tableViewBusinessLife.reloadData()
          self.tableViewBusinessLife.tableHeaderView = UIView()
          self.tableViewBusinessLife.tableFooterView = UIView()

      }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
              self.tabBarController?.tabBar.isHidden = true
        }
        self.callAPIRequestToGetChatUnreadCount()
        if let currentUser = UserDetail.getUserFromUserDefault(){
            self.buttonFollow.isHidden = (currentUser.userRoleType == .provider)
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
    @IBAction func buttonChatListSelector(sender:UIButton){
        self.pushtoChatListViewController()
    }
    func pushtoChatListViewController(){
        if let chatListViewController = UIStoryboard.messages.instantiateViewController(identifier: "ChatListViewController") as? ChatListViewController{
            chatListViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatListViewController, animated: true)
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //API
        DispatchQueue.main.async {
            self.currentPage = 1
            self.fetchBusinessLifeAPIRequest()
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    //MARK:- API Request Methods
    func fetchBusinessLifeAPIRequest(){

        var dict:[String:Any]  = [:]
        dict["limit"] = "\(self.fetchPageLimit)"
        dict["page"] = "\(self.currentPage)"
        if UserDetail.isUserLoggedIn,let currentUser = UserDetail.getUserFromUserDefault(){
            if currentUser.userRoleType == .customer{
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    dict["keyword"] = appDelegate.searchKeyword
                    dict["lat"] = appDelegate.homelat
                    dict["lng"] = appDelegate.homelng
                }
            }else{
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    dict["keyword"] = appDelegate.searchKeywordProvider
                    dict["lat"] = appDelegate.providerHomeLat
                    dict["lng"] = appDelegate.providerHomeLng
                }
            }
        }


        /*if let objTabView = self.navigationController?.tabBarController{
                   if let objHomeNavigation = objTabView.viewControllers?.first as? UINavigationController,let objHome = objHomeNavigation.viewControllers.first as? HomeVC{
                    dict["keyword"] = "\(objHome.currentSearchKeyword)"
                    dict["lat"] = "\(objHome.currentLat)"
                    dict["lng"] = "\(objHome.currentLong)"
                   }

               }*/

        if let currentKeyword = dict["keyword"]{
            if "\(currentKeyword)".count > 0{
                DispatchQueue.main.async {
                    self.lblTitle.text = "Business Life"// - \(currentKeyword)"
                }
            }else{
                DispatchQueue.main.async {
                    self.lblTitle.text = "Business Life"
                }

            }
        }
        print("======= \(dict)")
                APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGETProviderFeeds , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                        print(responseSuccess)
                            if let success = responseSuccess as? [String:Any],let arrayReview = success["success_data"] as? [[String:Any]]{

                                  if self.currentPage == 1{
                                         self.arrayOfDetail.removeAll()
                                   }
                                    self.isLoadMoreBusinessLife = arrayReview.count > 0

                                    for objReview in arrayReview{
                                       let review = BusinessLife.init(businessLifeDetail: objReview)
                                       self.arrayOfDetail.append(review)
                                    }

                                    DispatchQueue.main.async {
                                       self.tableViewBusinessLife.reloadData()
                                    }

                                
                                if let totalRating = success["total_page"] as? String{
                                    if let pi: Double = Double("\(totalRating)"){
                                        let rating = String(format:"%.1f", pi)
                                        print(rating)
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
 
    func followUnFollowAPIRequest(index:Int){
        var dict:[String:Any]  = [:]
        dict["from_user_type"] = "customer"
        if self.arrayOfDetail.count > index{
            var objBusinessLife = self.arrayOfDetail[index]
            dict["to_user_id"] = "\(objBusinessLife.userID)"
            if UserDetail.isUserLoggedIn,let currentUser = UserDetail.getUserFromUserDefault(){
                dict["from_user_id"] = "\(currentUser.id)"
            }
            var apiRequestURL = ""
            if let follow = objBusinessLife.follow.bool{
                apiRequestURL = follow ? kBusinessFeedUnFollow : kBusinessFeedFollow
            }else{
                apiRequestURL = kBusinessFeedFollow
            }
            APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:apiRequestURL , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                        if let success = responseSuccess as? [String:Any],let _ = success["success_data"] as? [[String:Any]]{

                            if let follow = objBusinessLife.follow.bool{
                                objBusinessLife.follow = follow ? "false" : "true"
                            }else{
                                objBusinessLife.follow = "false"
                            }
                            DispatchQueue.main.async {
                                let objIndexpath = IndexPath.init(row: index, section: 0)
                                self.tableViewBusinessLife.reloadRows(at: [objIndexpath], with: .none)
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
                                  // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                               }
                           }
                       }

        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonFollowIconSelector(sender:UIButton){
        //PushtoFollow screen
        if let followingViewController = UIStoryboard.businessFeed.instantiateViewController(identifier: "FollowingBusinessLifeViewController") as? FollowingBusinessLifeViewController{
            followingViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController( followingViewController, animated: true)
        }
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.tabBarController?.tabBar.isHidden = false
        }
          //self.navigationController?.popViewController(animated: true)
        if let objTabView = self.navigationController?.tabBarController{
                   
                   if let objHomeNavigation = objTabView.viewControllers?.first as? UINavigationController,let objHome = objHomeNavigation.viewControllers.first as? HomeVC{
                       objTabView.selectedIndex = 0
                   }else if let objHomeNavigation = objTabView.viewControllers?.first as? UINavigationController,let objHome = objHomeNavigation.viewControllers.first as? ProviderHomeViewController{
                    objTabView.selectedIndex = 0
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

}
extension UpdatedBusinessLifeViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DispatchQueue.main.async {
            self.tableViewBusinessLife.isHidden = self.arrayOfDetail.count == 0
        }
        return self.arrayOfDetail.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableViewBusinessLife.dequeueReusableCell(withIdentifier: "BusinessLifeUpdatedTableViewCell", for: indexPath) as! BusinessLifeUpdatedTableViewCell

        cell.delegate = self
        cell.tag = indexPath.row
        if self.arrayOfDetail.count > indexPath.row{
            let objBusinessLife = self.arrayOfDetail[indexPath.row]
            if objBusinessLife.businessLogo.count > 0{
                if let imgURL = URL.init(string: "\(objBusinessLife.businessLogo)"){
                    cell.imgBusinessLogo.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                }
            }
            cell.lblBusinessName.text = "\(objBusinessLife.businessName)"
            cell.lblProviderName.text = "\(objBusinessLife.name)"
            //cell.lblProviderName.text = "\(objBusinessLife.name)"
            cell.lblDate.text = self.getFormattedDate(string:"\(objBusinessLife.updatedAt)")
            cell.lblDescription.text = "\(objBusinessLife.businessLifeDescription)"
            if let pi: Double = Double("\(objBusinessLife.rating)"){
                let rating = String(format:"%.1f", pi)
                cell.lblReview.text = "\(rating)"
            }
            //Follow/Unfollow
            if let follow = objBusinessLife.follow.bool{
                cell.btnFollow.isSelected = follow
            }else{
                cell.btnFollow.isSelected = false
            }
            if "\(objBusinessLife.fileType)" == "image" || "\(objBusinessLife.fileType)" == "IMAGE"{
                    cell.videoPrevie.isHidden = true
                    if objBusinessLife.file.count > 0 {
                                if let imgURL = URL.init(string: "\(objBusinessLife.file)"){
                                    cell.imgBusinessLife.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                                }
                           }
                objBusinessLife.displayName = "businesslife-image-provider-\(objBusinessLife.id)"
            }else if "\(objBusinessLife.fileType)" == "video" || "\(objBusinessLife.fileType)" == "VIDEO"{
                objBusinessLife.displayName = "businesslife-video-provider-\(objBusinessLife.id)"
                          cell.videoPrevie.isHidden = false
                          if objBusinessLife.file.count > 0 {
                            if let imgURL = URL.init(string: "\(objBusinessLife.videoThumnail)"){
                                cell.imgBusinessLife.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                            }
                          }
                      }
        }
        if indexPath.row+1 == self.arrayOfDetail.count, self.isLoadMoreBusinessLife{ //last index
            DispatchQueue.global(qos: .background).async {
                self.currentPage += 1
                DispatchQueue.main.async {
                    self.fetchBusinessLifeAPIRequest()
                }
                
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func getFormattedDate(string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // This formate is input formated .

        let formateDate = dateFormatter.date(from:string)!
        dateFormatter.dateFormat = "MMM yyyy" // Output Formated

        print ("Print :\(dateFormatter.string(from: formateDate))")//Print :02-02-2018
        return dateFormatter.string(from: formateDate)
    }
}
extension UpdatedBusinessLifeViewController:BusinessLifeUpdatedCellDelegate{
    func pushtobusinesslifedetailView(businesslife:BusinessLife,providerImage:String){
        if let businesslifedetail = UIStoryboard.main.instantiateViewController(withIdentifier:"BusinessLifeDetailViewController") as? BusinessLifeDetailViewController{
             businesslifedetail.currentBusinessLife = businesslife
             businesslifedetail.providerProfileURL = providerImage
             businesslifedetail.hidesBottomBarWhenPushed = true
             self.navigationController?.pushViewController(businesslifedetail, animated: true)
         }
     }
    func buttonPlaySelectorWithIndex(index:Int){
        if self.arrayOfDetail.count > index{
            let objBusinessLife = self.arrayOfDetail[index]
            if let videoViewController:videoPlayVC = UIStoryboard.main.instantiateViewController(withIdentifier: "videoPlayVC") as? videoPlayVC{
                         videoViewController.hidesBottomBarWhenPushed = true
                         videoViewController.strMediaUrl = objBusinessLife.file
                         self.navigationController?.present(videoViewController, animated: true, completion: nil)

                       }
        }
    }
    func buttonImageSelectorWithIndex(index:Int){
        if self.arrayOfDetail.count > index{
            let objBusinessLife = self.arrayOfDetail[index]
            self.pushtobusinesslifedetailView(businesslife: objBusinessLife, providerImage: objBusinessLife.businessLogo)

        }
    }
    func buttonFollowSelectorWithIndex(index:Int){
        if self.arrayOfDetail.count > index{
            let objBusinessLife = self.arrayOfDetail[index]
            var strAlert = "Do you want to follow \(objBusinessLife.businessName) ?"
            if let follow = objBusinessLife.follow.bool{
                if follow{
                    strAlert = "Do you want to unfollow \(objBusinessLife.businessName) ?"
                }else{
                    strAlert = "Do you want to follow \(objBusinessLife.businessName) ?"
                }
            }else{
                strAlert = "Do you want to follow \(objBusinessLife.businessName) ?"
            }
            let alert = UIAlertController(title: AppName, message: "\(strAlert)", preferredStyle: .alert)

                   alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                   }))
                   alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in

                            self.followUnFollowAPIRequest(index: index)

                   }))
            alert.view.tintColor = UIColor.init(hex: "#38B5A3")
            self.present(alert, animated: true, completion: nil)
        }
    }
    func buttonShareSelectorWithIndex(index:Int){
        if self.arrayOfDetail.count > index{
            let objBusinessLife = self.arrayOfDetail[index]
            self.shareApplicatioSelector(objBusinessLife: objBusinessLife)
        }
    }
    func shareApplicatioSelector(objBusinessLife:BusinessLife){
        
        var strtext = "Hi, check out this post from \(objBusinessLife.businessName)"

         var link =  "https://werkules.com/?post_id="

         link.append("\(objBusinessLife.id)")

         guard let objLink = URL(string: "\(link)") else {
             return

         }
         let dynamicLinksDomainURIPrefix = "https://werkules.page.link"

         if let linkBuilder = DynamicLinkComponents(link: objLink, domainURIPrefix: dynamicLinksDomainURIPrefix){
             linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID:"com.Werkules.EntreprenetworkApp")
                  linkBuilder.androidParameters = DynamicLinkAndroidParameters(packageName: "com.app.werkules")

                  guard let longDynamicLink = linkBuilder.url else { return }

                  print("The long URL is: \(longDynamicLink)")


                    var urlString = String()

                  urlString = "\(longDynamicLink)"//"https://apps.apple.com/us/app/werkules/id1488572477"//"https://apps.apple.com/ng/app/werkules/id1488572477?ign-mpt=uo%3D2"

                  strtext.append("\n\n\(longDynamicLink)")
                print(strtext)
                   let items = [strtext] as [Any]
                  let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                  activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

                  // present the view controller
                  self.present(activityViewController, animated: true, completion: nil)
        }}
    func buttonFullScreenSelectorWithIndex(index:Int){
        if self.arrayOfDetail.count > index{
            let objBusinessLife = self.arrayOfDetail[index]
            self.pushtobusinesslifedetailView(businesslife: objBusinessLife, providerImage: objBusinessLife.businessLogo)

        }
    }
    func buttonProviderDetailSelectorWithIndex(index: Int) {
        if self.arrayOfDetail.count > index{
            let objBusinessLife = self.arrayOfDetail[index]
            self.pushToProviderDetailScreenWithProviderId(providerID: objBusinessLife.providerID)
        }
    }
}
