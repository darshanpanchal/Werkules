//
//  UserReviewAddEditViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 18/02/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import FloatRatingView

class UserReviewAddEditViewController: UIViewController {

    @IBOutlet weak var imgUser:UIImageView!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var tableViewCustomerReview:UITableView!
    @IBOutlet weak var txtTextView:UITextView!
    @IBOutlet weak var buttonSubmitReview:UIButton!
    @IBOutlet weak var lblReviewHowExperience:UILabel!
    
    @IBOutlet weak var lblNoReview:UILabel!
    
    @IBOutlet weak var ratingView:FloatRatingView!
    
    @IBOutlet weak var tableViewHeader:UIView!
    @IBOutlet weak var buttonLeaveReview:UIButton!
    
    
    var isLoadMoreReview:Bool = false
    var currentPage:Int = 1
    var arrayOfReview:[Review] = []
    var fetchPageLimit:Int = 10
    var placeholderLabel : UILabel!
    
    var currentReview:Review?{
        didSet{
            DispatchQueue.main.async {
                if let _ = self.currentReview{
                    self.configureCurrentreview(review: self.currentReview!)
                }
                
            }
        }
    }
    
    private var isHide:Bool = true
    fileprivate var istableViewHeaderHide:Bool{
        get{
            return isHide
        }
        set{
            isHide = newValue
            DispatchQueue.main.async {
              
                UIView.animate(withDuration: 0.3) {
                    //Configure TableViewHeader
                    self.configureTableHeaderHideShow()
                    self.tableViewCustomerReview.reloadData()

                }
            }
        }
    }
    private var isEditReview:Bool = false
    fileprivate var isForEditReview:Bool{
        get{
            return isEditReview
        }
        set{
            isEditReview = newValue
            print(newValue)
            DispatchQueue.main.async {
                   UIView.animate(withDuration: 0.3) {
                      //Configure Edit Review
                       self.configureEditAndAddReview()
                   }
               }
        }
    }
    var userID:String = ""
    var userName:String = ""
    var userProfile:String = ""
    
    var heightOfTableViewHeader:CGFloat = 350.0
    var heightOfLeaveReview:CGFloat = 100.0
    
    var isForProvider:Bool =  false
    
    var isFromSecondReviewDetail:Bool = false
    
    var highLightedIndex:Int?


    var alreadySubmittedReview:[Review] = [] {
        didSet{
            //Configure Already Submited Review
            self.configureAlreadySubmittedReview()
        }
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUp()
        self.configureTableView()
        // Do any additional setup after loading the view.
        
        //GET request
        self.getUserReviewAPIRequest()
    }
    func configureAlreadySubmittedReview(){
        DispatchQueue.main.async {
            if self.alreadySubmittedReview.count >  0{
                self.buttonLeaveReview.setTitle("UPDATE REVIEW", for: .normal)
            }else{
                self.buttonLeaveReview.setTitle("LEAVE A REVIEW", for: .normal)
            }
        }
    }
    // MARK: - Setup Methods
    func setUp(){
        
        if let currentUser = UserDetail.getUserFromUserDefault(), let userid = currentUser.id as? String{
            if self.userID == userid{
                self.buttonLeaveReview.isHidden = true
            }
        }else{
            self.buttonLeaveReview.isHidden = false
        }
        
        self.imgUser.contentMode = .scaleAspectFill
        self.imgUser.clipsToBounds = true
        self.imgUser.layer.cornerRadius = 20.0
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                                  return
                       }
        if let imgURL = URL.init(string:  userProfile){
            self.imgUser.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
        }
        /*
        if currentUser.userRoleType == .customer{
            self.lblUserName.text = "My Reviews"
        }else{
            self.lblUserName.text = "My Business Reviews"
        }*/
        self.lblUserName.text = " Review for \(self.userName)"
      
        self.istableViewHeaderHide = true
        
        
        
        // Do any additional setup after loading the view.
        txtTextView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Write something...."
        placeholderLabel.font = UIFont(name: "Avenir Medium", size: 17)
        placeholderLabel.sizeToFit()
        txtTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (txtTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !txtTextView.text.isEmpty
    }
    func configureTableHeaderHideShow(){
        if self.istableViewHeaderHide{
            self.tableViewCustomerReview.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: self.tableViewCustomerReview.bounds.width, height: heightOfLeaveReview)
            self.tableViewHeader.isHidden = true
            if let headerView = self.tableViewCustomerReview.tableHeaderView{
                self.tableViewCustomerReview.tableHeaderView = headerView
            }
        }else{
            self.tableViewHeader.isHidden = false
            self.tableViewCustomerReview.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: self.tableViewCustomerReview.bounds.width, height: heightOfTableViewHeader)
            if let headerView = self.tableViewCustomerReview.tableHeaderView{
                self.tableViewCustomerReview.tableHeaderView = headerView
            }
        }
        
    }
    func configureEditAndAddReview(){
        if self.isForEditReview{
            self.buttonSubmitReview.setTitle("UPDATE REVIEW", for: .normal)
        }else{
            self.buttonSubmitReview.setTitle("SUBMIT REVIEW", for: .normal)
            self.lblReviewHowExperience.text = "How was your experience with \(userName)?"
        }
    }
    func configureCurrentreview(review:Review){
        self.lblReviewHowExperience.text = "How was your experience with \(review.name)?"
        self.placeholderLabel.isHidden = !"\(review.review)".isEmpty
        self.txtTextView.text = "\(review.review)"
        if let rating = Double(review.rating){
            self.ratingView.rating = rating
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
        dict["user_id"] = self.userID
        dict["limit"] = "\(fetchPageLimit)"
        dict["page"] = "\(self.currentPage)"
        print(dict)
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString: isForProvider ? kGETProviderReview:kGETCustomerReview , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                            if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                             
                             if let arrayReview = userInfo["data"] as? [[String:Any]]{
                                  if self.currentPage == 1{
                                    self.alreadySubmittedReview.removeAll()
                                    self.arrayOfReview.removeAll()
                                    if let arraySubmittedReview = userInfo["submitted_review_detail"] as? [[String:Any]]{
                                        for objReview in arraySubmittedReview{
                                           let review = Review.init(reviewDetail: objReview)
                                            self.alreadySubmittedReview.append(review)
                                        }
                                    }
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
            self.tableViewCustomerReview.scrollToRow(at: IndexPath(item: 1, section: 0), at: .top, animated: true)
            
        }
    }
    //Update Review API Request
    func updateReviewAPIRequest(id:String){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
            var dict:[String:Any]  = [:]
                dict["review_id"] = "\(id)"
                dict["rating"] = "\(self.ratingView.rating)"
            if let updatedReview = self.txtTextView?.text,updatedReview.count > 0{
                dict["review"] = "\(updatedReview)"
            }
                
                
                        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kUpdateReview , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                                    if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                                        
                                        DispatchQueue.main.async {
                                           self.isForEditReview = false
                                            self.txtTextView.text = ""
                                             self.ratingView.rating = 0.0
                                           self.currentPage = 1
                                           self.getUserReviewAPIRequest()
                                           self.tableViewCustomerReview.reloadData()
                                           DispatchQueue.main.asyncAfter(deadline: .now()) {
                                                self.istableViewHeaderHide = true
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
    //Add Review API Request
    func addUserReviewAPIRequest(){
        var dict:[String:Any] = [:]
        dict["user_id"] = self.userID
        if self.isForProvider{
            dict["to_user_type"] = "provider"
        }else{
            dict["to_user_type"] = "customer"
        }
        dict["rating"] = "\(self.ratingView.rating)"
        if let updatedReview = self.txtTextView?.text,updatedReview.count > 0{
            dict["review"] = "\(updatedReview)"
        }
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kAddReview , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                                        if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                                            
                                            DispatchQueue.main.async {
                                                self.txtTextView.text = ""
                                                self.ratingView.rating = 0.0
                                               self.isForEditReview = false
                                               self.currentPage = 1
                                               self.getUserReviewAPIRequest()
                                               self.tableViewCustomerReview.reloadData()
                                               DispatchQueue.main.asyncAfter(deadline: .now()) {
                                                    self.istableViewHeaderHide = true
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
    func isValideData()->Bool{
        guard  self.ratingView.rating > 0.0 else {
            SAAlertBar.show(.error, message:"Please enter Review")
            return false
        }
        guard let address = self.txtTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),address.count > 0 else{
            SAAlertBar.show(.error, message:"Please enter Review")
            return false
        }
        
        return true
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonSubmitReviewSelector(sender:UIButton){

        if self.isValideData(){
            if self.isForEditReview{
                if let _ = self.currentReview{
                    self.updateReviewAPIRequest(id:self.currentReview!.id)
                }
            }else{
                 self.addUserReviewAPIRequest()
                /*
                if let _ = self.currentReview{
                   
                    //self.updateReviewAPIRequest(id:self.currentReview!.id)
                }else{
                    DispatchQueue.main.async {
                        SAAlertBar.show(.error, message:"Please enter Review")
                    }
                }*/
            }
            
        }
    }
    @IBAction func addLeaveReviewSelector(sender:UIButton){
        if self.alreadySubmittedReview.count > 0{
            self.currentReview = self.alreadySubmittedReview[0]
            self.isForEditReview = true
            self.istableViewHeaderHide = false
        }else{
            self.isForEditReview = false
            self.istableViewHeaderHide = false
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
extension UserReviewAddEditViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrayOfReview.count > 0{
            self.lblNoReview.isHidden = true
        }else{
            
            self.lblNoReview.isHidden = !self.istableViewHeaderHide
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
//            cell.lblReview.text = "\(objReview.review)"
            if let rating = Double(objReview.rating){
                cell.objReview.rating = rating
            }
            cell.delegate = self
            cell.buttonEdit.isHidden = false
            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                                   return cell
                        }
            let dateformatter = DateFormatter()
                       dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                       if let date = dateformatter.date(from: objReview.updatedAt){
                           dateformatter.dateFormat = "MM/dd/yyyy"
                          cell.lblDate.text = dateformatter.string(from: date)
                       }
            cell.buttonEdit.isHidden = (objReview.fromID != currentUser.id)
            
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
        }
       
        
         if indexPath.row+1 == self.arrayOfReview.count, self.isLoadMoreReview{ //last index
             DispatchQueue.global(qos: .background).async {
                 self.currentPage += 1
                 self.getUserReviewAPIRequest()
             }
         }
        guard let currentuser = UserDetail.getUserFromUserDefault() else {
                  return  cell
               }
//         cell.lblUserName.text = "\(currentuser.username)"
        cell.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension UserReviewAddEditViewController: CustomerReviewTableViewCellDelegate{
    func buttonEditSelector(index: Int) {
        if self.arrayOfReview.count > index{
            self.currentReview = self.arrayOfReview[index]
            self.isForEditReview = true
            self.istableViewHeaderHide = false
            
        }
    }
    func buttonUserProfileClick(index:Int){
        if self.arrayOfReview.count > index{
            let review = self.arrayOfReview[index]
            guard let currentUser = UserDetail.getUserFromUserDefault() else {return}
            guard (review.fromID != currentUser.id) else{
                if review.fromUserType == "provider"{ //as provider gave review
                    if currentUser.userRoleType == .provider{
                        //provider profile
                        self.pushToMyProviderProfile()
                    }else{
                        //customer profile
                        self.pushToMyCustomerProfile()
                    }
                }else{ //as customer gave review
                    if currentUser.userRoleType == .provider{
                        //provider profile
                        self.pushToMyProviderProfile()
                    }else{
                        //customer profile
                        self.pushToMyCustomerProfile()
                    }
                }
                return
            }
            if review.toUserType == "provider"{ // user got review as provider
                if review.fromUserType == "provider"{
                    self.pushToProviderDetailScreenWithProviderId(providerID: review.providerId)
                }else{ //customer give review
                    self.pushtocustomerdetailViewcontroller(dict: review)
                }
            }else{ // user got review as customer
                if review.fromUserType == "provider"{
                    self.pushToProviderDetailScreenWithProviderId(providerID: review.providerId)
                }else{
                    self.pushtocustomerdetailViewcontroller(dict: review)
                }
            }
        }
    }
    func pushToMyCustomerProfile(){
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EntrepreneurProfileVC") as! EntrepreneurProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func pushToMyProviderProfile(){
        let objmainstoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let providerProfile = objmainstoryboard.instantiateViewController(withIdentifier: "ProviderProfileViewController") as? ProviderProfileViewController{
            self.navigationController?.pushViewController(providerProfile, animated: true)
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
extension UserReviewAddEditViewController:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
