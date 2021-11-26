//
//  CustomerProfileAsProviderVC.swift
//  Entreprenetwork
//
//  Created by IPS on 25/01/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import FloatRatingView

class CustomerProfileAsProviderVC: UIViewController {

    @IBOutlet weak var imgProfile:UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblMobileNumber: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblAccountSuspended: UILabel!
    @IBOutlet weak var objCollectionView:UICollectionView!
    @IBOutlet weak var imgViewBackground:UIImageView!
    @IBOutlet weak var btnMore:UIButton!
    @IBOutlet weak var btnDirection:UIButton!
    @IBOutlet weak var objShadow:ShadowBackgroundView!
    @IBOutlet weak var tableViewOtherCustomer:UITableView!
    
    @IBOutlet weak var lblnoreview:UILabel!
    
    @IBOutlet weak var viewSendOfferContainer:UIView!
    @IBOutlet weak var widthOfSendOffer:NSLayoutConstraint!
    @IBOutlet weak var widthOfContact:NSLayoutConstraint!
    
    var arrayOfReview:[Review] = []
    @IBOutlet weak var ratingView:FloatRatingView!
    @IBOutlet weak var lblRating:UILabel!
    var rating:String = "0.0"
    var currentRating:String{
        get{
            return rating
        }
        set{
            rating = newValue
            //Configure New Value
            self.configureUpdatedRating()
        }
    }
    var isForOffer:Bool = false
    
    var isFromCompleted:Bool = false
    
    var userId:String = ""
    var userName:String = ""
    var userProfile:String = ""
    var otherUserdetail:CustomerDetail?
    var offerdetail:OfferDetail?
    
    var isFromMyGroupScreen:Bool = false
    @IBOutlet weak var viewContact:UIView!
    @IBOutlet weak var buttonFlag:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        RegisterCell()
        self.imgProfile.contentMode = .scaleAspectFill
         self.imgProfile.clipsToBounds = true
         self.imgProfile.layer.borderWidth = 1.0
         self.imgProfile.layer.borderColor = UIColor.white.cgColor
         self.imgProfile.layer.cornerRadius = 115.0/2.0
         
//         self.configureCurrentUserData()
//         if let currentUser = UserDetail.getUserFromUserDefault(){
      
             
        
//         }
         
        self.btnMore.titleLabel?.attributedText = self.getAttributedUnderlineString(str: "More")
        self.btnDirection.titleLabel?.attributedText = self.getAttributedUnderlineString(str: "Direction")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getCurrentUserDetailAPIRequest(userID: self.userId)
        //GET User Rating
        self.getUserReviewAPIRequest(userid: self.userId)
    }
    func getAttributedUnderlineString(str:String)->NSAttributedString {
        return NSAttributedString(string: "\(str)",
        attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
    }
    func configureCurrentUserData(currentUser:CustomerDetail){
            DispatchQueue.main.async {
                
                self.lblUserName.text = currentUser.isFullNameShow ? "\(currentUser.firstname) \(currentUser.lastname)" : "\(currentUser.firstname)"
                self.btnDirection.isHidden = currentUser.isGetDirectionLinkShow ? false : true
                self.buttonFlag.isHidden = currentUser.isReportFlagShow ? false : true
                
                if currentUser.isContactButtonShow == false {
                    self.widthOfContact.constant = 0.0
                    self.viewContact.isHidden = true
                }else {
                    self.widthOfContact.constant = 125.0
                    self.viewContact.isHidden = false
                }
                
//                if currentUser.inprogressJOB.count > 0{
//                    if let value = currentUser.inprogressJOB["status"],!(value is NSNull){
//                        if "\(value)" == "progress" || "\(value)" == "booked" || "\(value)" == "completed"{
//                            self.lblUserName.text = "\(currentUser.firstname) \(currentUser.lastname)"//currentUser.username
//                            self.btnDirection.isHidden = false
////                            self.viewContact.isHidden = false
////                            self.buttonFlag.isHidden = false
//                        }else{
//                            self.lblUserName.text = "\(currentUser.firstname)"//currentUser.username
//                            self.btnDirection.isHidden = true
////                            self.viewContact.isHidden = true
////                            self.buttonFlag.isHidden = true
//                        }
//                    }else{
//                        self.lblUserName.text = "\(currentUser.firstname)"//currentUser.username
//                        self.btnDirection.isHidden = true
////                        self.viewContact.isHidden = true
////                        self.buttonFlag.isHidden = true
//                    }
//
//                }else{
//                    self.lblUserName.text = "\(currentUser.firstname)"//currentUser.username
//                    self.btnDirection.isHidden = true
////                    self.viewContact.isHidden = true
////                    self.buttonFlag.isHidden = true
//                }
                
                

//                self.lblEmail.text = currentUser.email
//                self.lblMobileNumber.text = "\(currentUser.countryCode) \(currentUser.phone)"
//                self.lblAddress.text = "\(currentUser.address) \(currentUser.city) \(currentUser.state) \(currentUser.zipcode)"
                if let imgURL = URL.init(string:  currentUser.profilePic){
                    self.imgProfile.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                }
                  /* if let customer = self.otherUserdetail{
                    UIView.animate(withDuration: 0.3) {
                        if customer.job.count > 0{
                            self.viewSendOfferContainer.isHidden = false
                            self.widthOfSendOffer.constant = 140.0
                        }else{
                            self.viewSendOfferContainer.isHidden = true
                            self.widthOfSendOffer.constant = 0.0
                        }
                    }
                }*/
                
                
                if self.isForOffer{
                    self.viewSendOfferContainer.isHidden = false
                    self.widthOfSendOffer.constant = 140.0
                }else{
                    self.viewSendOfferContainer.isHidden = true
                    self.widthOfSendOffer.constant = 0.0
                }
                
//                //Client Update 09/07/2021 on completed tab hide contact and direction should be hide
//                self.viewContact.isHidden = false
//                self.widthOfContact.constant = 125.0
//                self.buttonFlag.isHidden = false
//
//                if currentUser.inprogressJOB.count > 0{
//                    if let value = currentUser.inprogressJOB["status"],!(value is NSNull){
//                        if "\(value)" == "completed"{
//                            self.btnDirection.isHidden = true
//                            self.widthOfContact.constant = 0.0
//                            self.viewContact.isHidden = true
//
//                        }
//                    }
//                }
                
                
                
                
            }
       
        
    }
    func configureUpdatedRating(){
        DispatchQueue.main.async {
            if let objRating = Double(self.currentRating){
                self.ratingView.rating = objRating
            }
            
        }
    }
    func RegisterCell()  {
        
        self.objCollectionView.register(UINib.init(nibName: "ReviewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ReviewCollectionViewCell")
        self.objCollectionView.delegate = self
        self.objCollectionView.dataSource = self
        self.objCollectionView.reloadData()
    }
    // MARK: - SELECTOR METHODS
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
     @IBAction func btnMoreSelectorClick(sender:UIButton){
            print("btnMoreSelectorClick")
            //psuh to customer review screen
            self.pushToCustomerReviewScreen(hightlightedIndex: nil)
    //        self.pushToMyReviewScreen()
        }
    @IBAction func btnReportBugClicked(_ sender: UIButton) {
       
        if let reportBug = self.storyboard?.instantiateViewController(withIdentifier: "ReportBugViewController") as? ReportBugViewController{
            
            if let customer = self.otherUserdetail{
                        if customer.inprogressJOB.count > 0{
                               reportBug.isForFileDispute = true
                        }else{
                               reportBug.isForFileDispute = false
                            }
//                reportBug.isForFileDispute = true
                reportBug.customerDetail = self.otherUserdetail!
            }
            
            self.navigationController?.pushViewController(reportBug, animated: true)
        }
    }
    @IBAction func buttonContactSelector(sender:UIButton){
        if let _ = self.otherUserdetail{
            self.pushtoChatViewControllerWith(customer: self.otherUserdetail!)
        }
    }
    func pushtoChatViewControllerWith(customer:CustomerDetail){
           if let chatViewConroller = UIStoryboard.messages.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC{
               chatViewConroller.hidesBottomBarWhenPushed = true
            if let userName = self.lblUserName.text{
                chatViewConroller.strReceiverName = "\(userName)"
            }else{
                chatViewConroller.strReceiverName = "\(customer.firstname) \(customer.lastname)"
            }
            
            chatViewConroller.strReceiverProfileURL = "\(customer.profilePic)"
            chatViewConroller.receiverID = customer.id
            chatViewConroller.isForCustomerToProvider = false
            chatViewConroller.senderID = "\(customer.quickblox_id)"
            chatViewConroller.toUserTypeStr = "customer"
            
            self.navigationController?.pushViewController(chatViewConroller, animated: true)
           }
       }
    @IBAction func buttonSendOfferSelector(sender:UIButton){
        if let _ = self.offerdetail{
            self.pushtosendofferviewcontrollewith(offerdetail: self.offerdetail!)
        }
    }
    @IBAction func buttonGetDirectionSelector(sender:UIButton){
        if let _ = self.otherUserdetail{
            let lat = self.otherUserdetail!.lat
            let long = self.otherUserdetail!.lng
            if let imgURL = URL.init(string: "https://maps.google.com/?q=\(lat),\(long)"){
                UIApplication.shared.open(imgURL, options: [:], completionHandler: nil)
            }
           

        }
    }
    // MARK: - API Request
    
    func getCurrentUserDetailAPIRequest(userID:String){
        var dict:[String:Any] = [
             "user_id":"\(userID)"
         ]
            if self.isFromMyGroupScreen{
              dict["is_from_group"] = true
            }
      
              APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCustomerDetails , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                 if let success = responseSuccess as? [String:Any],var userInfo = success["success_data"] as? [String:Any]{
                       if let customerData = userInfo["customer_data"] as? [String:Any]{
                        self.otherUserdetail = CustomerDetail.init(customerDetail: customerData)//UserDetail.init(userDetail: customerData)
                        if let _ = self.otherUserdetail{
                            if let bookedJOBDetail = userInfo["in_progress_job"] as? [String:Any]{
                                self.otherUserdetail?.inprogressJOB = bookedJOBDetail
                            }
                            self.configureCurrentUserData(currentUser: self.otherUserdetail!)
                        }else{
                            
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
    func getUserReviewAPIRequest(userid:String){
            /*guard let currentUser = UserDetail.getUserFromUserDefault() else {
                            return
                 }*/
            var dict:[String:Any]  = [:]
            dict["user_id"] = userid
            dict["limit"] = "3"
            dict["page"] = "1"
            
                    APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGETCustomerReview , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
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
                                             self.currentRating = rating
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        if let totalReview = userInfo["total_review"]{
                                            self.lblRating.text = "(\(totalReview) Review)"
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushToCustomerReviewScreen(isFromSecondReviewDetail:Bool = false,hightlightedIndex:Int?){
           if let objCustomerReviewController = self.storyboard?.instantiateViewController(withIdentifier: "UserReviewAddEditViewController") as? UserReviewAddEditViewController{
              objCustomerReviewController.userID = self.userId
            objCustomerReviewController.userName = self.userName
            objCustomerReviewController.userProfile = self.userProfile
            objCustomerReviewController.isFromSecondReviewDetail = isFromSecondReviewDetail
                
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
    func pushtosendofferviewcontrollewith(offerdetail:OfferDetail){
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
           if let sendofferviewcontroller = mainStoryboard.instantiateViewController(withIdentifier: "SendOfferViewController") as? SendOfferViewController{
               sendofferviewcontroller.objOfferDetail = offerdetail
               sendofferviewcontroller.hidesBottomBarWhenPushed = true
               
               self.navigationController?.pushViewController(sendofferviewcontroller, animated: true)
           }
       }

}
extension CustomerProfileAsProviderVC:UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.btnMore.isHidden =  (self.arrayOfReview.count <= 2)
        self.objCollectionView.isHidden = (self.arrayOfReview.count == 0)
        self.lblnoreview.isHidden = (self.arrayOfReview.count  != 0)
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
        return CGSize(width: UIScreen.main.bounds.width / 2.0, height:collectionView.bounds.height)
      }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       print("----- \(indexPath.row)")
        if indexPath.row == 1{
            self.pushToCustomerReviewScreen(isFromSecondReviewDetail: true,hightlightedIndex: 1)
        }else{
            self.pushToCustomerReviewScreen(isFromSecondReviewDetail: false,hightlightedIndex: 0)
        }
       
    }
}
