//
//  ViewGroupEarningDetailViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 09/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import SDWebImage

class ViewGroupEarningDetailViewController: UIViewController {

    
    @IBOutlet weak var shadowView:ShadowBackgroundView!
    @IBOutlet weak var containerView:UIView!
    @IBOutlet weak var tableViewGroup:UITableView!
    @IBOutlet weak var lblAvailableAmount:UILabel!
    @IBOutlet weak var lblPendingAmount:UILabel!
    
    var arrayofgroupearning:[GroupEarningDetail] = []
    
    var userID = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureTableView()
        //fetch Group Earning details
        self.getViewGroupEarningDetailAPIRequest()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.containerView.layer.cornerRadius = 6.0
            self.shadowView.rounding = 6.0
        }
    }
    
    // MARK: - Selector Methods
    @IBAction func btnBackClicked(_ sender: UIButton) {
              self.navigationController?.popViewController(animated: true)
         }
    // MARK: - Setup Methods
    func configureTableView(){
        let sectionHeaderNib: UINib = UINib(nibName: "GroupPromotionDetailHeaderView", bundle: nil)
        self.tableViewGroup.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: "GroupPromotionDetailHeaderView")
        //GroupTableViewCell
                self.tableViewGroup.register(UINib(nibName: "GroupEarningTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupEarningTableViewCell")
        self.tableViewGroup.register(UINib(nibName: "GroupEarningUpdateTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupEarningUpdateTableViewCell")
        
                // you can change section height based on your needs
                self.tableViewGroup.delegate = self
                self.tableViewGroup.dataSource = self
                self.tableViewGroup.rowHeight = UITableView.automaticDimension
                self.tableViewGroup.estimatedRowHeight = 250.0
                self.tableViewGroup.hideHeader()
//                self.tableViewGroup.scrollEnableIfTableViewContentIsLarger()
                self.tableViewGroup.reloadData()
    }
    // MARK: - API Request Methods
    func getViewGroupEarningDetailAPIRequest(){
        var dict:[String:Any] = [:]
        if self.userID.count > 0{
            dict["user_id"] = "\(self.userID)"
        }
               
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGroupEarningDetail , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                         if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                           
                           DispatchQueue.main.async {
                               if let total_transactions = userInfo["available_now"]{
                                    if let pi: Double = Double("\(total_transactions)"){
                                    let updateValue = String(format:"%.2f", pi)
                                        self.lblAvailableAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                                    }
                                }
                                if let total_earnings = userInfo["pending"]{
                                    if let pi: Double = Double("\(total_earnings)"){
                                     let updateValue = String(format:"%.2f", pi)
                                      self.lblPendingAmount.text = CurrencyFormate.Currency(value: Double(updateValue) ?? 0)//"$\(updateValue)"
                                    }
                                }
                           }
                        
                           if let arrayofEarning:[[String:Any]] = userInfo["earning_data"] as? [[String:Any]],arrayofEarning.count > 0{
                            
                              self.arrayofgroupearning.removeAll()
                            for obj in arrayofEarning{
                                let detail = GroupEarningDetail.init(detail: obj)
                                self.arrayofgroupearning.append(detail)
                                
                            }
                               DispatchQueue.main.async {
                                
                                   self.tableViewGroup.reloadData()
                               }
                            }else{
                              
                               
                           }
                           
                                    }else{
                                        DispatchQueue.main.async {
                                        //    SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
                                        //    SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                        }
                                   
                                   }
               }}
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }


}
extension ViewGroupEarningDetailViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView: GroupPromotionDetailHeaderView! = self.tableViewGroup.dequeueReusableHeaderFooterView(withIdentifier: "GroupPromotionDetailHeaderView") as? GroupPromotionDetailHeaderView

        if self.arrayofgroupearning.count > section{
            let objearning = self.arrayofgroupearning[section]
            sectionHeaderView.lblCompanyName.text = "\(objearning.name)"
            if let imageURL = URL.init(string: "\(objearning.businessLogo)"){
                sectionHeaderView.imageViewBusinessness!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
            }
        }
           return sectionHeaderView
       }
       
       func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           return 50.0
       }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrayofgroupearning.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrayofgroupearning.count > section{
            let groupEarning = self.arrayofgroupearning[section]
            return groupEarning.arrayBusiness.count
        }else{
            return 0
        }
        }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = self.tableViewGroup.dequeueReusableCell(withIdentifier: "GroupEarningTableViewCell") as! GroupEarningTableViewCell
        let cell = self.tableViewGroup.dequeueReusableCell(withIdentifier: "GroupEarningUpdateTableViewCell") as! GroupEarningUpdateTableViewCell
        
        
        if self.arrayofgroupearning.count > indexPath.section{
            
            let objearning = self.arrayofgroupearning[indexPath.section]
            let businessPromtion = objearning.arrayBusiness[indexPath.row]

//            cell.lblCompanyName.text = "\(objearning.name)"
            var strPromtion = "\(businessPromtion.promotionName)"
            
            if businessPromtion.promotionDescription.count > 0{
                strPromtion += "\n\(businessPromtion.promotionDescription)"
            }
            cell.lblPromotionName.text = "\(strPromtion)"
//            cell.lblPromotionAmount.text = ""//"\(objearning.strPaymentAmount)"
            /*
            if let imageURL = URL.init(string: "\(objearning.businessLogo)"){
                cell.imageViewBusinessness!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
            }*/
            
        }
        cell.tag = indexPath.row
        cell.delegate = self
        cell.currentIndexPath = indexPath
        return cell
    }
}
extension ViewGroupEarningDetailViewController:GroupEarningUpdateTableViewCellDelegate{
    func buttonSeeDetailSelector(senderIndex: IndexPath) {
        if self.arrayofgroupearning.count > senderIndex.section{
            
            let objearning = self.arrayofgroupearning[senderIndex.section]
            let businessPromotion = objearning.arrayBusiness[senderIndex.row]
            var promotionDetailJSON:[String:Any] = [:]
            /*
             case id, name
             case promotionDescription = "description"
             case image
             case expiryDate = "expiry_date"
             case useOnce = "use_once"
             case code
             case isCurrent = "is_current"
             case createdAt = "created_at"
             case updatedAt = "updated_at"
             case deletedAt = "deleted_at"
             case createdBy = "created_by"
             case updatedBy = "updated_by"
             case deletedBy = "deleted_by"
             case type, amount
             case savingprice = "saving_price"
             case isDeleted = "is_deleted"
             case isExpired = "is_expiry"
             case customerDiscount = "customer_discount"
             case werkulesFees = "werkules_fee"
             */
            promotionDetailJSON["name"] = "\(businessPromotion.promotionName)"
            promotionDetailJSON["description"] = "\(businessPromotion.promotionDescription)"
            promotionDetailJSON["expiry_date"] = "\(businessPromotion.promotionExpiry)"
            promotionDetailJSON["use_once"] = "\(businessPromotion.promotionUseOnce)"
            promotionDetailJSON["image"] = "\(businessPromotion.promotionImage)"
            promotionDetailJSON["type"] = "\(businessPromotion.promotionType)"
            promotionDetailJSON["amount"] = "\(businessPromotion.promotionValue)"
            promotionDetailJSON["saving_price"] = "\(businessPromotion.promotionSavingPrice)"
            
            
            let objPromotion = Promotion.init(promotionDetail: promotionDetailJSON)
            self.presentPromotionDetailPopUpViewController(objPromotion: objPromotion)
            
        }
    }
    
    //Present Group Earning Details
    func presentPromotionDetailPopUpViewController(objPromotion:Promotion){
        
        if let objStory = UIStoryboard.main.instantiateViewController(withIdentifier: "PromotionAlertViewController") as? PromotionAlertViewController{
            objStory.modalPresentationStyle = .overFullScreen
            objStory.objPromotion = objPromotion
            self.present(objStory, animated: true, completion: nil)
        }
    }
}
class GroupEarningDetail:NSObject{
    var attributesBold: [NSAttributedString.Key: Any] = [
     .font: UIFont.init(name: "Avenir Heavy", size: 14.0)!,
     .foregroundColor: UIColor.init(hex: "#38B5A3"),
     NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
        ]
     var attributesNormal: [NSAttributedString.Key: Any] = [
        .font:  UIFont.init(name: "Avenir Medium", size: 14.0)!,
        .foregroundColor: UIColor.init(hex: "#707070"),
        ]
     
    var name = ""
    var arrayBusiness :[BusinessEarningDetail] = []
    var strPromotionName:String = ""
    var strPaymentAmount:String = ""
    var businessLogo = ""
    
    enum CodingKeys: String, CodingKey {
             case name = "business_name"
             case arrayBusiness = "business_earning"
             case businessLogo = "business_logo"
        }
    init(detail:[String:Any]) {
        if let objName = detail[CodingKeys.name.rawValue],!(objName is NSNull){
            self.name = "\(detail[CodingKeys.name.rawValue]!)"
        }
        if let objbusinessLogo = detail[CodingKeys.businessLogo.rawValue],!(objbusinessLogo is NSNull){
            self.businessLogo = "\(detail[CodingKeys.businessLogo.rawValue]!)"
        }
        if let objArray = detail[CodingKeys.arrayBusiness.rawValue] as? [[String:Any]],objArray.count > 0{
            
            for (idx,objbusiness) in  objArray.enumerated(){
                
                    let objBusinessEarning = BusinessEarningDetail.init(detail: objbusiness)
                
                    if objBusinessEarning.earnStatus == "remain"{
                         self.strPromotionName += "\(objBusinessEarning.promotionName) (\(objBusinessEarning.remainingDay) days remain)\n"
                         self.strPaymentAmount += "$\(objBusinessEarning.earnAmount)\n"
                     }else{ //available
                         self.strPromotionName += "\(objBusinessEarning.promotionName) (Amount Available)\n"
                         self.strPaymentAmount += "$\(objBusinessEarning.earnAmount)\n"
                     }
                if self.strPaymentAmount.count > 0, self.strPromotionName.count > 0{
//                    self.strPaymentAmount.removeLast()
//                    self.strPromotionName.removeLast()
                }
                
                self.arrayBusiness.append(objBusinessEarning)
            }
            
        }
    }
    
}
class BusinessEarningDetail:NSObject{
    
    var id = "", earnAmount: String = ""
    var earnStatus = "", remainingDay: String = ""
    var promotionName = "",promotionType = "",promotionValue:String = ""
    var promotionDescription = ""
    var promotionSavingPrice = "",promotionUseOnce:String = ""
    var promotionImage = "",promotionExpiry = ""
    enum CodingKeys: String, CodingKey {
               case id
               case earnAmount = "earn_amount"
               case earnStatus = "earn_status"
               case remainingDay = "remain_day"
               case promotionName = "promotion_name"
               case promotionType = "promotion_type"
               case promotionValue = "promotion_value"
               case promotionDescription = "description"
               case promotionSavingPrice = "saving_price"
               case promotionUseOnce = "use_once"
               case promotionImage = "image"
               case promotionExpiry = "expiry_date"
               
           }
    init(detail:[String:Any]) {
        
        if let objpromtionDescription = detail[CodingKeys.promotionDescription.rawValue],!(objpromtionDescription is NSNull){
            self.promotionDescription = "\(detail[CodingKeys.promotionDescription.rawValue]!)"
        }
        if let objpromotionSavingPrice = detail[CodingKeys.promotionSavingPrice.rawValue],!(objpromotionSavingPrice is NSNull){
            self.promotionSavingPrice = "\(detail[CodingKeys.promotionSavingPrice.rawValue]!)"
        }
        if let objpromotionUseOnce = detail[CodingKeys.promotionUseOnce.rawValue],!(objpromotionUseOnce is NSNull){
            self.promotionUseOnce = "\(detail[CodingKeys.promotionUseOnce.rawValue]!)"
        }
        if let objpromotionImage = detail[CodingKeys.promotionImage.rawValue],!(objpromotionImage is NSNull){
            self.promotionImage = "\(detail[CodingKeys.promotionImage.rawValue]!)"
        }
        if let objpromotionExpiry = detail[CodingKeys.promotionExpiry.rawValue],!(objpromotionExpiry is NSNull){
            self.promotionExpiry = "\(detail[CodingKeys.promotionExpiry.rawValue]!)"
        }
        if let objID = detail[CodingKeys.id.rawValue],!(objID is NSNull){
            self.id = "\(detail[CodingKeys.id.rawValue]!)"
        }
        if let objearnAmount = detail[CodingKeys.earnAmount.rawValue],!(objearnAmount is NSNull){
            self.earnAmount = "\(detail[CodingKeys.earnAmount.rawValue]!)"
        }
        if let objearnStatus = detail[CodingKeys.earnStatus.rawValue],!(objearnStatus is NSNull){
            self.earnStatus = "\(detail[CodingKeys.earnStatus.rawValue]!)"
        }
        if let objremainingDays = detail[CodingKeys.remainingDay.rawValue],!(objremainingDays is NSNull){
            self.remainingDay = "\(detail[CodingKeys.remainingDay.rawValue]!)"
        }
        if let objpromotionName = detail[CodingKeys.promotionName.rawValue],!(objpromotionName is NSNull){
            self.promotionName = "\(detail[CodingKeys.promotionName.rawValue]!)"
        }
        if let objpromotionType = detail[CodingKeys.promotionType.rawValue],!(objpromotionType is NSNull){
            self.promotionType = "\(detail[CodingKeys.promotionType.rawValue]!)"
        }
        if let objpromotionValue = detail[CodingKeys.promotionValue.rawValue],!(objpromotionValue is NSNull){
            self.promotionValue = "\(detail[CodingKeys.promotionValue.rawValue]!)"
        }
    }
}
