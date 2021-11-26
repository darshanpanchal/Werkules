//
//  CustomerReviewViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 22/01/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class CustomerReviewViewController: UIViewController {

    @IBOutlet weak var imgUser:UIImageView!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var tableViewCustomerReview:UITableView!
    
    var isLoadMoreReview:Bool = false
    var currentPage:Int = 1
    var arrayOfReview:[Review] = []
    var fetchPageLimit:Int = 10
    
    var highLightedIndex:Int?
    
    var isFromSecondReviewDetail:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
        self.configureTableView()
        // Do any additional setup after loading the view.
        
        //GET request
        self.getUserReviewAPIRequest()
    }
    
    // MARK: - Setup Methods
    func setUp(){
        self.imgUser.contentMode = .scaleAspectFill
        self.imgUser.clipsToBounds = true
        self.imgUser.layer.cornerRadius = 20.0
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                                  return
                       }
        
        if currentUser.userRoleType == .customer{
            if let imgURL = URL.init(string:  currentUser.profilePic){
                       self.imgUser.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                   }
                   self.lblUserName.text = "Reviews for \(currentUser.firstname) \(currentUser.lastname)"
        }else{
            if let businessDetail = currentUser.businessDetail, let imgURL = URL.init(string:  businessDetail.businessLogo){
                self.imgUser.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                self.lblUserName.text = "Reviews for \(businessDetail.businessName)"
            }
        }
       
      
    }
    func configureTableView(){
        self.tableViewCustomerReview.register(UINib.init(nibName: "CustomerReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomerReviewTableViewCell")
        self.tableViewCustomerReview.showsVerticalScrollIndicator = false
        self.tableViewCustomerReview.delegate = self
        self.tableViewCustomerReview.dataSource = self
        self.tableViewCustomerReview.rowHeight = UITableView.automaticDimension
        self.tableViewCustomerReview.estimatedRowHeight = 120.0
        self.tableViewCustomerReview.reloadData()
    }
    // MARK: - API Request Methods
    func getUserReviewAPIRequest(){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                        return
             }
        var dict:[String:Any]  = [:]
        dict["user_id"] = currentUser.id
        dict["limit"] = "\(fetchPageLimit)"
        dict["page"] = "\(self.currentPage)"
        
                APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGETUserReview , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                            if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                             
                             if let arrayReview = userInfo["data"] as? [[String:Any]]{
                                  if self.currentPage == 1{
                                         self.arrayOfReview.removeAll()
                                   }
                                   self.isLoadMoreReview = arrayReview.count > 0
                                    for objReview in arrayReview{
                                       let review = Review.init(reviewDetail: objReview)
                                       self.arrayOfReview.append(review)
                                    }
                                    DispatchQueue.main.async {
                                       self.tableViewCustomerReview.reloadData()
                                        if self.isFromSecondReviewDetail{
                                            self.checkForSecondReviewDetailScroll()
                                        }
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
    func checkForSecondReviewDetailScroll(){
         DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
             self.tableViewCustomerReview.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: true)
             
         }
     }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
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
extension CustomerReviewViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrayOfReview.count > 0{
            self.tableViewCustomerReview.isHidden = false
        }else{
            self.tableViewCustomerReview.isHidden = true
        }
        return self.arrayOfReview.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerReviewTableViewCell", for: indexPath) as! CustomerReviewTableViewCell
        
        if self.arrayOfReview.count > indexPath.row{
            let objReview = self.arrayOfReview[indexPath.row]
                cell.lblUserName.text = "\(objReview.name)"
                if let imgURL = URL.init(string:  objReview.profilePic){
                    cell.imgUser.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                }
            if let pi: Double = Double("\(objReview.rating)"){
                let rating = String(format:"%.1f", pi)
                cell.lblReview.text = "\(objReview.review)"
            }
            if let rating = Double(objReview.rating){
                cell.objReview.rating = rating
            }
            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                                   return cell
                        }
            let dateformatter = DateFormatter()
                       dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                       if let date = dateformatter.date(from: objReview.updatedAt){
                           dateformatter.dateFormat = "MM/dd/yyyy"
                          cell.lblDate.text = dateformatter.string(from: date)
                       }
//            cell.buttonEdit.isHidden = (objReview.fromID != currentUser.id)
        }
        
        if let value = self.highLightedIndex{
            if value == 0 && indexPath.item == 0 {
                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            }else if value == 1 && indexPath.item == 1 {
                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            }else{
                cell.backgroundColor = UIColor.white
            }
        }else{
            cell.backgroundColor = UIColor.white
        }
         if indexPath.row+1 == self.arrayOfReview.count, self.isLoadMoreReview{ //last index
             DispatchQueue.global(qos: .background).async {
                 self.currentPage += 1
                 self.getUserReviewAPIRequest()
             }
         }
        cell.delegate = self
        cell.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension CustomerReviewViewController :CustomerReviewTableViewCellDelegate{
    func buttonEditSelector(index: Int) {
        
    }
    func buttonUserProfileClick(index:Int){ //As customer or provider i got review
        if self.arrayOfReview.count > index{
            let review = self.arrayOfReview[index]
            guard let currentUser = UserDetail.getUserFromUserDefault() else {return}
            if review.toUserType == "provider"{ // i got review as provider
                if review.fromUserType == "provider"{
                    self.pushToProviderDetailScreenWithProviderId(providerID: review.providerId)
                }else{ //customer give review
                    self.pushtocustomerdetailViewcontroller(dict: review)
                }
            }else{ // i got review as customer
                if review.fromUserType == "provider"{
                    self.pushToProviderDetailScreenWithProviderId(providerID: review.providerId)
                }else{
                    self.pushtocustomerdetailViewcontroller(dict: review)
                }
            }
        }
    }
    func pushtocustomerdetailViewcontroller(dict:Review){
             
                let profilestoryboard  = UIStoryboard.init(name: "Profile", bundle: nil)
                if let profileViewcontroller = profilestoryboard.instantiateViewController(withIdentifier: "CustomerProfileAsProviderVC") as? CustomerProfileAsProviderVC{
                    guard let currentUser = UserDetail.getUserFromUserDefault() else {return}
                    if dict.toID == currentUser.id{
                        profileViewcontroller.userId = "\(dict.fromID)"
                    }else{
                        profileViewcontroller.userId = "\(dict.toID)"
                    }
                    
                    profileViewcontroller.userProfile = "\(dict.profilePic)"
                    profileViewcontroller.userName = "\(dict.name)"
                    
                    profileViewcontroller.isFromMyGroupScreen = true
                    profileViewcontroller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(profileViewcontroller, animated: true)
                }
    }
    func pushToProviderDetailScreenWithProviderId(providerID:String){
          let objStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
          if let objProviderDetail = objStoryboard.instantiateViewController(withIdentifier: "ProviderDetailViewController") as? ProviderDetailViewController{
              objProviderDetail.hidesBottomBarWhenPushed = true
              objProviderDetail.providerID = providerID
              self.navigationController?.pushViewController(objProviderDetail, animated: true)
          }
      }
}
