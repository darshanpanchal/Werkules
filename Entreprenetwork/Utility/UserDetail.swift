//
//  User.swift
//  Live
//
//  Created by ITPATH on 4/5/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import CoreData

let kUserDefault = UserDefaults.standard
let kUserDetail = "UserDetail"
let kSelectedLanguage = "SelectedLanguage" //en or other language
let kAppleUserName = "appleUserName"
let kAppleFirstName = "appleFirstName"
let kAppleLastName = "appleLastName"
let kAppleEmail = "appleEmail"

enum UserType:String,Codable{
    case customer
    case provider
}
class UserDetail: NSObject,Codable {
    
    var id = "", username = "",firstname : String = ""
    var lastname = "", email = "", phone : String = ""
    var profilePic = "", coverPic = "", userType = "", company : String = ""
    var ein = "", address = "", insurance = "", tagline: String  = ""
    var userDetailsDescription = "", file1 = "", file2 = "", file3: String = ""
    var file4 = "", file5 = "", file6 = "", otp: String = ""
    var fpOtp = "", deviceToken = "", isNotification = "", platform: String = ""
    var categoryIDS = "", lat = "", lng = "", createdAt: String = ""
    var updatedAt = "", deletedAt = "", loginType = "", rememberToken: String = ""
    var authID: String = ""
    var currentRoleID: String = ""
    var userRoleType:UserType = .customer
    var businessDetail:BusinessDetail?
    var city = "",state = "", zipcode = "",countryCode:String = ""
    var referalCode = ""
    var groupReferralCode = ""
    var groupName = ""
    var quickbloxid = ""
    var isFirstTimeLogin:Bool = false
    
//      private enum CodingKeys: String, CodingKey {
//         case city
//         case state
//         case zipcode
//      }
    init(userDetail:[String:Any]){
        
        super.init()
        if let isfirsttime = userDetail["is_first_time_login"] as? Bool{
            self.isFirstTimeLogin = isfirsttime
        }
        if let userID = userDetail["id"]{
           self.id = "\(userID)"
        }
        if let quickbloxid = userDetail["quickbloxid"]{
           self.quickbloxid = "\(quickbloxid)"
        }
        if let name = userDetail["group_name"]{
            self.groupName = "\(name)"
        }
        if let referal_Code = userDetail["group_referral_code"]{
            self.groupReferralCode = "\(referal_Code)"
        }
        if let referal_Code = userDetail["referal_code"]{
            self.referalCode = "\(referal_Code)"
        }
        if let txtusername = userDetail["username"]{
          self.username = "\(txtusername)"
        }
        if let txtemail = userDetail["email"]{
          self.email = "\(txtemail)"
        }
        if let userfirstname = userDetail["firstname"]{
           self.firstname = "\(userfirstname)"
        }
        if let userlastname = userDetail["lastname"]{
            self.lastname = "\(userlastname)"
        }
        if let _ = userDetail["country_code"]{
            self.countryCode = "\(userDetail["country_code"]!)"
        }
         if let userphone = userDetail["phone"]{
            self.phone = "\(userphone)"
        }
        if let userprofilePic = userDetail["profile_pic"]{
            self.profilePic = "\(userprofilePic)"
        }
        if let usercoverPic = userDetail["cover_pic"]{
               self.coverPic = "\(usercoverPic)"
        }
        if let useruserType = userDetail["user_type"]{
               self.userType = "\(useruserType)"
            if "\(useruserType)".caseInsensitiveCompare("customer") == .orderedSame {
                self.userRoleType = .customer
            }else if "\(useruserType)".caseInsensitiveCompare("provider") == .orderedSame {
                self.userRoleType = .provider
            }
        }
        if let usercompany = userDetail["company"]{
            self.company = "\(usercompany)"
        }
        if let userein = userDetail["ein"]{
            self.ein = "\(userein)"
        }
        if let useraddress = userDetail["address"]{
               self.address = "\(useraddress)"
        }
        if let _ = userDetail["city"]{
            self.city = "\(userDetail["city"]!)"
        }
        if let _ = userDetail["state"]{
            self.state = "\(userDetail["state"]!)"
        }
        if let _ = userDetail["zipcode"]{
            self.zipcode = "\(userDetail["zipcode"]!)"
        }
        if let userinsurance = userDetail["insurance"]{
               self.insurance = "\(userinsurance)"
        }
        if let usertagline = userDetail["tagline"]{
               self.tagline = "\(usertagline)"
        }
        if let useruserDetailsDescription = userDetail["description"]{
               self.userDetailsDescription = "\(useruserDetailsDescription)"
        }
        if let userisNotification = userDetail["is_notification"]{
                      self.isNotification = "\(userisNotification)"
        }
        if let userlat = userDetail["lat"]{
            self.lat = "\(userlat)"
        }
        if let userLng = userDetail["lng"]{
            self.lng = "\(userLng)"
        }
        if let userLoginType = userDetail["login_type"] {
            self.loginType = "\(userLoginType)"
        }
        
        if let _ = userDetail["remember_token"]{
            self.rememberToken = "\(userDetail["remember_token"]!)"
        }
        if let _ = userDetail["auth_id"]{
                   self.authID = "\(userDetail["auth_id"]!)"
               }
        if let _ = userDetail["current_role_id"]{
                   self.currentRoleID = "\(userDetail["current_role_id"]!)"
               }
        if let _ = userDetail["category_ids"]{
                   self.categoryIDS = "\(userDetail["category_ids"]!)"
        }
       
        if let objBusinessDetail = userDetail["business_data"] as? [String:Any]{
            self.businessDetail = BusinessDetail.init(businessDetail:objBusinessDetail)
        }else {
            if let currentUser = UserDetail.getUserFromUserDefault(),let _ = currentUser.businessDetail{
                self.businessDetail = currentUser.businessDetail!
            }
        }
        
//               self.file2 = file2
//               self.file3 = file3
//               self.file4 = file4
//               self.file5 = file5
//               self.file6 = file6
//               self.otp = otp
//               self.fpOtp = fpOtp
//               self.deviceToken = deviceToken
//               self.platform = platform
//               self.createdAt = createdAt
//               self.updatedAt = updatedAt
//               self.deletedAt = deletedAt
             
    }
}
extension UserDetail{
    
    func assignDefaultValueBeforeSuperInit(){
        
    }
    static var isUserLoggedIn:Bool{
        if let userDetail  = kUserDefault.value(forKey: kUserDetail) as? Data{
            return self.isValiduserDetail(data: userDetail)
        }else{
          return false
        }
    }
    func setuserDetailToUserDefault(){
        do{
            let userDetail = try JSONEncoder().encode(self)
            UserSettings.isUserLogin = true
            kUserDefault.setValue(userDetail, forKey:kUserDetail)
            kUserDefault.synchronize()
        }catch{
            DispatchQueue.main.async {
                SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                //ShowToast.show(toatMessage: kCommonError)
            }
        }
    }
    static func isValiduserDetail(data:Data)->Bool{
        do {
            let _ = try JSONDecoder().decode(UserDetail.self, from: data)
            return true
        }catch{
            return false
        }
    }
    static func getUserFromUserDefault() -> UserDetail?{
        if let userDetail = kUserDefault.value(forKey: kUserDetail) as? Data{
            do {
                let user:UserDetail = try JSONDecoder().decode(UserDetail.self, from: userDetail)
                return user
            }catch{
                DispatchQueue.main.async {
                    SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
                return nil
            }
        }
        DispatchQueue.main.async {
            //ShowToast.show(toatMessage: kCommonError)
        }
        return nil
    }
    static func removeUserFromUserDefault(){
        UserSettings.isUserLogin = false
        kUserDefault.removeObject(forKey:kUserDetail)
    }
    
}

class BusinessDetail:NSObject,Codable {
    var id = "", businessName : String = ""
    var businessLogo = "",businessLicense = "", email = "", phone : String = ""
    var city = "", state = "",address:String = "",zipcode = ""
    var ein = "", insurance :String = ""
    var countryCode = ""
    var businessDetailsDescription = ""
    var driver_license = ""
    var how_long_willing_to_travel = ""
    var keywords_for_business = ""
    var lat = "", lng = ""
    var userID = ""
    var isDeleted:String = ""
    var status:String = ""
    
    init(businessDetail:[String:Any]){
        super.init()
        if let value = businessDetail["status"],!(value is NSNull){
            self.status = "\(value)"
        }
        if let _ = businessDetail["id"]{
            self.id = "\(businessDetail["id"]!)"
        }
        if let _ = businessDetail["business_name"]{
            self.businessName = "\(businessDetail["business_name"]!)"
        }
        if let _ = businessDetail["business_logo"]{
            self.businessLogo = "\(businessDetail["business_logo"]!)"
        }
        if let _ = businessDetail["business_license"]{
            self.businessLicense = "\(businessDetail["business_license"]!)"
        }
        if let _ = businessDetail["email"]{
            self.email = "\(businessDetail["email"]!)"
        }
        if let _ = businessDetail["phone"]{
            self.phone = "\(businessDetail["phone"]!)"
        }
        if let _ = businessDetail["city"]{
            self.city = "\(businessDetail["city"]!)"
        }
        if let _ = businessDetail["state"]{
            self.state = "\(businessDetail["state"]!)"
        }
        if let _ = businessDetail["address"]{
            self.address = "\(businessDetail["address"]!)"
        }
        if let _ = businessDetail["zipcode"]{
            self.zipcode = "\(businessDetail["zipcode"]!)"
        }
        if let _ = businessDetail["ein"]{
            self.ein = "\(businessDetail["ein"]!)"
        }
        if let _ = businessDetail["insurance"]{
            self.insurance = "\(businessDetail["insurance"]!)"
        }
        if let _ = businessDetail["country_code"]{
            self.countryCode = "\(businessDetail["country_code"]!)"
        }
        if let _ = businessDetail["description"]{
            self.businessDetailsDescription = "\(businessDetail["description"]!)"
        }
        if let _ = businessDetail["driver_license"]{
            self.driver_license = "\(businessDetail["driver_license"]!)"
        }
        if let _ = businessDetail["how_long_willing_to_travel"]{
            self.how_long_willing_to_travel = "\(businessDetail["how_long_willing_to_travel"]!)"
        }
        if let _ = businessDetail["keywords_for_business"]{
            self.keywords_for_business = "\(businessDetail["keywords_for_business"]!)"
        }
        if let _ = businessDetail["lat"]{
            self.lat = "\(businessDetail["lat"]!)"
        }
        if let _ = businessDetail["lng"]{
            self.lng = "\(businessDetail["lng"]!)"
        }
        if let _ = businessDetail["user_id"]{
            self.userID = "\(businessDetail["user_id"]!)"
        }
        if let _ = businessDetail["is_deleted"]{
                   self.isDeleted = "\(businessDetail["is_deleted"]!)"
               }
        
    }
}

class NotifiedProviderOffer:NSObject{
    
    var id = "", userID: String = ""
    var rating = "", businessName:String = "", review = ""
    var categoryIDS: String = ""
    var file1: String = ""
    var title = "", estimateBudget: String = ""
    var fairMarketValue: String = ""
    var lat = "", lng = "", address = "", city: String = ""
    var state = "", zipcode = "", notifiedProviderDescription = "", status: String = ""
    var progressBy = "", progressDate = "",offerDate = "", completedDate: String = ""
    var platform = "",searchDate = "", createdAt: String = ""
    var price:String = ""
    var postActiveTime  = "", travelTime: String = ""
    var offerPrice = ""
    var savingPrice = ""
    var finalPrice = ""
    var sent:[String] = [], offers:[String] = []
    var offerAttachment:[[String:Any]] = []
    var promotion:[[String:Any]] = []
    var providerID = ""
    var businessLogo = ""
    var jobID = ""
    var acceptedDate = "",jobcreated = ""
    var acceptedPrice = ""
    var askingPrice = ""
    var customerDetail:[String:Any] = [:]
    var isPreOffer:String = ""
    var profilePicture:String = ""
    var isMoreOption:Bool = false
    var quickblox_id:String = ""
    //is_pre_offer : 1 // without offer price
    //is_pre_offer : 0 // must be offer price
    var isPreOfferDirectBook:String = ""
    //is_preoffer :  1 //direct book
    //is_preoffer :  0 //direct book
    var dateOfferAccepted:String = ""
    var dateOfPost = ""
    
    var dateJOBStartDate = ""
    var dateOfCompletion = ""

    var customerJobNote = ""
    var jobCancelDate = ""

    enum CodingKeys: String {
        case id
        case offerDate = "offer_date"
        case profilePicture = "profile_pic"
        case searchDate = "search_date"
        case userID = "user_id"
        case businessName = "business_name"
        case rating
        case review
        case offerPrice = "offer_price"
        case categoryIDS = "category_ids"
        case file1, title
        case estimateBudget = "estimate_budget"
        case fairMarketValue = "fair_market_value"
        case lat, lng, address, city, state, zipcode
        case notifiedProviderDescription = "description"
        case status
        case progressBy = "progress_by"
        case progressDate = "progress_date"
        case completedDate = "completed_date"
        case platform
        case createdAt = "created_at"
        case price
        case postActiveTime = "post_active_time"
        case travelTime = "travel_time"
        case sent, offers
        case offerAttachment = "offer_attachments"
        case providerID = "provider_id"
        case businessLogo = "business_logo"
        case jobID = "job_id"
        case acceptedDate = "accepted_date"
        case jobcreated = "job_created"
        case acceptedPrice = "accepted_price"
        case askingPrice = "asking_price"
        case customerDetail = "customer_details"
        case ispreoffer = "is_pre_offer"
        case promotion = "promotion"
        case savingPrice = "saving_price"
        case finalPrice = "final_price"
        case isMoreOption = "isMoreOption"
        case quickblox_id = "quickblox_id"
        case isPreOfferDirectBook = "is_preoffer"
        case dateOfferAccepted = "date_offer_accepted"
        case dateOfPost = "post_date"
        case dateJOBStartDate = "job_start_date"
        case dateOfCompletion = "date_of_completion"
        case customerJobNote = "customer_job_note"
        case jobCancelDate = "job_cancel_date"
    }
    init(providersDetail:[String:Any]){
        super.init()
        if let value = providersDetail[CodingKeys.review.rawValue],!(value is NSNull){
                   self.review = "\(value)"
        }
        if let value = providersDetail[CodingKeys.jobCancelDate.rawValue],!(value is NSNull){
                   self.jobCancelDate = "\(value)"
        }
        if let value = providersDetail[CodingKeys.customerJobNote.rawValue],!(value is NSNull){
                   self.customerJobNote = "\(value)"
        }
        if let value = providersDetail[CodingKeys.dateOfCompletion.rawValue],!(value is NSNull){
                   self.dateOfCompletion = "\(value)"
        }
        if let value = providersDetail[CodingKeys.dateJOBStartDate.rawValue],!(value is NSNull){
                   self.dateJOBStartDate = "\(value)"
        }
        if let value = providersDetail[CodingKeys.dateOfPost.rawValue],!(value is NSNull){
                   self.dateOfPost = "\(value)"
        }
        if let value = providersDetail[CodingKeys.dateOfferAccepted.rawValue],!(value is NSNull){
                   self.dateOfferAccepted = "\(value)"
        }
        if let value = providersDetail[CodingKeys.isPreOfferDirectBook.rawValue],!(value is NSNull){
                   self.isPreOfferDirectBook = "\(value)"
        }
       if let ismore = providersDetail[CodingKeys.isMoreOption.rawValue] as? Bool{
           self.isMoreOption = ismore
       }
        if let quickId = providersDetail[CodingKeys.quickblox_id.rawValue] as? String{
            self.quickblox_id = quickId
        }
        if let _ = providersDetail[CodingKeys.offerDate.rawValue]{
            self.offerDate = "\(providersDetail[CodingKeys.offerDate.rawValue]!)"
        }
        if let _ = providersDetail[CodingKeys.id.rawValue]{
            self.id = "\(providersDetail[CodingKeys.id.rawValue]!)"
        }
    
        if let _ = providersDetail[CodingKeys.userID.rawValue]{
            self.userID = "\(providersDetail[CodingKeys.userID.rawValue]!)"
        }
        if let _ = providersDetail[CodingKeys.businessName.rawValue]{
            self.businessName = "\(providersDetail[CodingKeys.businessName.rawValue]!)"
        }
        if let _ = providersDetail[CodingKeys.title.rawValue]{
            self.title = "\(providersDetail[CodingKeys.title.rawValue]!)"
        }
        if let _ = providersDetail[CodingKeys.rating.rawValue]{
            self.rating = "\(providersDetail[CodingKeys.rating.rawValue]!)"
        }
        if let value = providersDetail[CodingKeys.offerPrice.rawValue],!(value is NSNull){
            self.offerPrice = "\(value)"
        }
        if let _ = providersDetail[CodingKeys.lng.rawValue]{
            self.lng = "\(providersDetail[CodingKeys.lng.rawValue]!)"
        }
        if let _ = providersDetail[CodingKeys.lat.rawValue]{
            self.lat = "\(providersDetail[CodingKeys.lat.rawValue]!)"
        }
        if let value = providersDetail[CodingKeys.estimateBudget.rawValue],!(value is NSNull){
            self.estimateBudget = "\(value)"
        }
        if let value = providersDetail[CodingKeys.savingPrice.rawValue],!(value is NSNull){
                   self.savingPrice = "\(value)"
               }
        if let value = providersDetail[CodingKeys.finalPrice.rawValue],!(value is NSNull){
                   self.finalPrice = "\(value)"
               }
        if let _ = providersDetail[CodingKeys.searchDate.rawValue]{
            self.searchDate = "\(providersDetail[CodingKeys.searchDate.rawValue]!)"
        }
        if let _ = providersDetail[CodingKeys.createdAt.rawValue]{
            self.createdAt = "\(providersDetail[CodingKeys.createdAt.rawValue]!)"
        }
        if let _ = providersDetail[CodingKeys.providerID.rawValue]{
            self.providerID = "\(providersDetail[CodingKeys.providerID.rawValue]!)"
        }
        if let objofferAttachment = providersDetail[CodingKeys.offerAttachment.rawValue] as? [[String:Any]],objofferAttachment.count > 0{
            
            self.offerAttachment = objofferAttachment
        }else if let objofferAttachment = providersDetail["offer_attachment"] as? [[String:Any]],objofferAttachment.count > 0{
            self.offerAttachment = objofferAttachment
        }
        if let value = providersDetail[CodingKeys.businessLogo.rawValue],!(value is NSNull){
                   self.businessLogo = "\(value)"
        }
        if let value = providersDetail[CodingKeys.profilePicture.rawValue],!(value is NSNull){
                   self.profilePicture = "\(value)"
        }
        if let value = providersDetail[CodingKeys.jobID.rawValue],!(value is NSNull){
                   self.jobID = "\(value)"
        }
        if let value = providersDetail[CodingKeys.acceptedDate.rawValue],!(value is NSNull){
                   self.acceptedDate = "\(value)"
        }
        if let value = providersDetail[CodingKeys.jobcreated.rawValue],!(value is NSNull){
                   self.jobcreated = "\(value)"
        }
        if let value = providersDetail[CodingKeys.acceptedPrice.rawValue],!(value is NSNull){
                   self.acceptedPrice = "\(value)"
        }
        if let value = providersDetail[CodingKeys.customerDetail.rawValue] as? [String:Any]{
                          self.customerDetail = value
               }
        if let value = providersDetail[CodingKeys.promotion.rawValue] as? [[String:Any]]{
                                 self.promotion = value
                      }
       if let value = providersDetail[CodingKeys.askingPrice.rawValue],!(value is NSNull){
                  self.askingPrice = "\(value)"
                if self.estimateBudget.count  == 0{
                    self.estimateBudget = "\(value)"
                }
       }
        if let value = providersDetail[CodingKeys.ispreoffer.rawValue],!(value is NSNull){
                   self.isPreOffer = "\(value)"
        }
    }
    /*
    init(from decoder:Decoder) throws{
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.userID = try values.decodeIfPresent(String.self, forKey: .userID) ?? ""
        self.title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.estimateBudget = try values.decodeIfPresent(String.self, forKey: .estimateBudget) ?? ""
        self.lat =  try values.decodeIfPresent(String.self, forKey: .lat) ?? ""
        self.lng =  try values.decodeIfPresent(String.self, forKey: .lng) ?? ""
    }*/
}

class Review: NSObject {
    var id = "", fromID = "", toID = "", rating: String = ""
    var review = "", createdAt = "", updatedAt = "", deletedAt: String = ""
    var name = "", profilePic: String = ""
    var toUserType = ""
    var fromUserType = ""
    var providerId = ""
    var fromUser: FromUser?

    enum CodingKeys: String, CodingKey {
        case id
        case fromID = "from_id"
        case toID = "to_id"
        case rating, review
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case fromUser = "from_user"
        case name
        case profilePic = "profile_pic"
        case toUserType = "to_user_type"
        case providerId = "provider_id"
        case fromUserType = "from_user_type"
    }
    init(reviewDetail:[String:Any]) {

        if let _ = reviewDetail[CodingKeys.fromUserType.rawValue]{
            self.fromUserType = "\(reviewDetail[CodingKeys.fromUserType.rawValue]!)"
        }
        if let _ = reviewDetail[CodingKeys.providerId.rawValue]{
            self.providerId = "\(reviewDetail[CodingKeys.providerId.rawValue]!)"
        }
        if let _ = reviewDetail[CodingKeys.toUserType.rawValue]{
            self.toUserType = "\(reviewDetail[CodingKeys.toUserType.rawValue]!)"
        }
        if let _ = reviewDetail[CodingKeys.id.rawValue]{
            self.id = "\(reviewDetail[CodingKeys.id.rawValue]!)"
        }
        if let _ = reviewDetail[CodingKeys.fromID.rawValue]{
            self.fromID = "\(reviewDetail[CodingKeys.fromID.rawValue]!)"
        }
        if let _ = reviewDetail[CodingKeys.toID.rawValue]{
            self.toID = "\(reviewDetail[CodingKeys.toID.rawValue]!)"
        }
        if let _ = reviewDetail[CodingKeys.rating.rawValue]{
            self.rating = "\(reviewDetail[CodingKeys.rating.rawValue]!)"
        }
        if let _ = reviewDetail[CodingKeys.review.rawValue]{
            self.review = "\(reviewDetail[CodingKeys.review.rawValue]!)"
        }
        if let _ = reviewDetail[CodingKeys.createdAt.rawValue]{
            self.createdAt = "\(reviewDetail[CodingKeys.createdAt.rawValue]!)"
        }
        if let _ = reviewDetail[CodingKeys.updatedAt.rawValue]{
            self.updatedAt = "\(reviewDetail[CodingKeys.updatedAt.rawValue]!)"
        }
        if let _ = reviewDetail[CodingKeys.deletedAt.rawValue]{
            self.deletedAt = "\(reviewDetail[CodingKeys.deletedAt.rawValue]!)"
        }
        if let _ = reviewDetail[CodingKeys.name.rawValue]{
            self.name = "\(reviewDetail[CodingKeys.name.rawValue]!)"
        }
        if let _ = reviewDetail[CodingKeys.profilePic.rawValue]{
                   self.profilePic = "\(reviewDetail[CodingKeys.profilePic.rawValue]!)"
        }
        
        if let fromUserDetail = reviewDetail[CodingKeys.fromUser.rawValue] as? [String:Any]{
            self.fromUser =  FromUser.init(fromuserDetail: fromUserDetail)
        }
        
    }
}
class OfferDetail:NSObject{
    var id = ""
    var rating = "0.0"
    var review = "0"
    var jobDetail:JOB?
    var customerDetail:CustomerDetail?
    var isMoreOption:Bool = false
    var promotion:[[String:Any]] = []
    var offerAttachment:[[String:Any]] = []
    var isPreOffer:String = ""
    
    enum CodingKeys: String, CodingKey{
        case id
        case review
        case rating
        case jobDetail = "job_detail"
        case customerDetail = "customer_detail"
        case ismoreoption
        case promotion = "promotion"
        case offerAttachment = "offer_attachments"
        case ispreoffer = "is_preoffer"
    }
    init(offerDetail:[String:Any]){
        if let value = offerDetail[CodingKeys.ispreoffer.rawValue],!(value is NSNull){
                   self.isPreOffer = "\(value)"
        }
        if let objofferAttachment = offerDetail[CodingKeys.offerAttachment.rawValue] as? [[String:Any]],objofferAttachment.count > 0{
            
            self.offerAttachment = objofferAttachment
        }else if let objofferAttachment = offerDetail["offer_attachment"] as? [[String:Any]],objofferAttachment.count > 0{
            self.offerAttachment = objofferAttachment
        }
        
        if let objId = offerDetail[CodingKeys.id.rawValue],!(objId is NSNull){
                   self.id = "\(objId)"
        }
      
        if let objismoreoption = offerDetail[CodingKeys.ismoreoption.rawValue] as? Bool{
                          self.isMoreOption = objismoreoption
               }
        if let objrating = offerDetail[CodingKeys.rating.rawValue],!(objrating is NSNull){
                   self.rating = "\(objrating)"
        }
        if let objreview = offerDetail[CodingKeys.review.rawValue],!(objreview is NSNull){
                   self.review = "\(objreview)"
        }
        if let objjobDetail = offerDetail[CodingKeys.jobDetail.rawValue] as? [String:Any]{
            self.jobDetail = JOB.init(jobDetail: objjobDetail)
        }
        if let objcustomerDetail = offerDetail[CodingKeys.customerDetail.rawValue] as? [String:Any]{
            self.customerDetail = CustomerDetail.init(customerDetail: objcustomerDetail)
        }
        if let objpromotiondetail = offerDetail[CodingKeys.promotion.rawValue] as? [[String:Any]]{
                  self.promotion = objpromotiondetail
              }
    }
}
class JOB:NSObject{
        var jobID: String = ""
        var title = "", createdAt = "", askingPrice = "0.0", lat: String = ""
        var jobCreated = ""
        var lng: String = ""
        var attatchment:[[String:Any]] = []
        var isForSendOffer:Bool = false
        var offerPrice = ""
        var offerDate = ""
        var savingPrice = ""
        var finalPrice = ""
        var jobcreatedat = ""
        enum CodingKeys: String, CodingKey {
            case jobID = "job_id"
            case title
            case createdAt = "created_at"
            case askingPrice = "asking_price"
            case lat, lng
            case attatchment
            case jobCreated = "job_created"
            case jobcreatedat = "job_created_at"
            case isForSendOffer = "is_send_offer"
            case offerPrice = "offer_price"
            case offerDate = "offer_date"
            case savingPrice = "saving_price"
            case finalPrice = "final_price"
        }
    init(jobDetail:[String:Any]){
        
        if let objIsForSendOffer = jobDetail[CodingKeys.isForSendOffer.rawValue] as? Bool{
            self.isForSendOffer = objIsForSendOffer
        }
        if let value = jobDetail[CodingKeys.offerPrice.rawValue],!(value is NSNull){
                                 self.offerPrice = "\(value)"
                      }
        if let value = jobDetail[CodingKeys.savingPrice.rawValue],!(value is NSNull){
                   self.savingPrice = "\(value)"
        }
        if let value = jobDetail[CodingKeys.finalPrice.rawValue],!(value is NSNull){
                   self.finalPrice = "\(value)"
        }
        if let value = jobDetail[CodingKeys.offerDate.rawValue],!(value is NSNull){
                                 self.offerDate = "\(value)"
                      }
        
        if let objjobCreated = jobDetail[CodingKeys.jobCreated.rawValue],!(objjobCreated is NSNull){
                          self.jobCreated = "\(objjobCreated)"
               }
        if let objjobCreatedat = jobDetail[CodingKeys.jobcreatedat.rawValue],!(objjobCreatedat is NSNull){
                          self.jobcreatedat = "\(objjobCreatedat)"
               }
        if let objjobID = jobDetail[CodingKeys.jobID.rawValue],!(objjobID is NSNull){
                   self.jobID = "\(objjobID)"
        }
        if let objtitle = jobDetail[CodingKeys.title.rawValue],!(objtitle is NSNull){
                   self.title = "\(objtitle)"
        }
        if let objcreatedAt = jobDetail[CodingKeys.createdAt.rawValue],!(objcreatedAt is NSNull){
                   self.createdAt = "\(objcreatedAt)"
        }
        if let objvalue = jobDetail[CodingKeys.askingPrice.rawValue],!(objvalue is NSNull){
                          self.askingPrice = "\(objvalue)"
               }
        if let objvalue = jobDetail[CodingKeys.lat.rawValue],!(objvalue is NSNull){
                                 self.lat = "\(objvalue)"
                      }
        if let objvalue = jobDetail[CodingKeys.lng.rawValue],!(objvalue is NSNull){
                                        self.lng = "\(objvalue)"
                             }
        if let objvalue = jobDetail[CodingKeys.attatchment.rawValue] as? [[String:Any]]{
                                               self.attatchment = objvalue
                                    }
        
    }
}
class GeneralData:NSObject{
    var id: String = ""
    var name:String = ""
    var value:String  = ""
    
    enum CodingKeys:String, CodingKey{
        case id,name,value
    }
    
    init(detail:[String:Any]){
        if let value = detail[CodingKeys.id.rawValue],!(value is NSNull){
                          self.id = "\(value)"
               }
        if let value = detail[CodingKeys.name.rawValue],!(value is NSNull){
                   self.name = "\(value)"
        }
        if let value = detail[CodingKeys.value.rawValue],!(value is NSNull){
                   self.value = "\(value)"
        }
    }
    
}
class JOBDetail:NSObject{
    var address: String = ""
    var askingPrice:String = ""
    var descriptionDetail:String  = ""
    var category:GeneralData?
    var createdAt:String = ""
    var id:String = ""
    var images:[[String:Any]] = []
    var title = ""
    var status = ""
    var tavelTime:GeneralData?
    var keepPostActive : GeneralData?
    var userDetail:[String:Any] = [:]
    var userId = ""
    var lat = "", lng:String = ""
    var isDirectionShowHide:Bool = false
    var isFullNameShow:Bool = false
    var isPreoffer:Bool = false
    var isForSendOffer:Bool = false
    var distance:String = ""
    var directionLink:String = ""

    enum CodingKeys:String, CodingKey{
        case directionLink = "direction_link"
        case isFullNameShow = "is_full_name_show"
        case distance
        case address
        case isForSendOffer = "is_send_offer"
        case askingPrice = "asking_price"
        case descriptionDetail = "description"
        case category
        case createdAt = "created_at"
        case id
        case images
        case title
        case status
        case tavelTime = "travel_time"
        case user
        case userId = "user_id"
        case keepPostActive = "keep_post_active"
        case lat, lng
        case isDirectionShowHide = "direction_show_hide"
        case isPreoffer = "is_preoffer"
    }
    init(jobDetail:[String:Any]){
        if let value = jobDetail[CodingKeys.directionLink.rawValue],!(value is NSNull){
            self.directionLink = "\(value)"
        }
        if let value = jobDetail[CodingKeys.distance.rawValue],!(value is NSNull){
            self.distance = "\(value)"
        }
        if let objIsFullNameShow = jobDetail[CodingKeys.isFullNameShow.rawValue] as? Bool{
            self.isFullNameShow = objIsFullNameShow
        }
        if let objIsForSendOffer = jobDetail[CodingKeys.isForSendOffer.rawValue] as? Bool{
            self.isForSendOffer = objIsForSendOffer
        }
        if let value = jobDetail[CodingKeys.status.rawValue],!(value is NSNull){
            self.status = "\(value)"
        }
        if let objisDirectionShowHide = jobDetail[CodingKeys.isDirectionShowHide.rawValue] as? Bool{
            self.isDirectionShowHide = objisDirectionShowHide
        }
        if let objisPreoffer = jobDetail[CodingKeys.isPreoffer.rawValue],!(objisPreoffer is NSNull){
            self.isPreoffer = "\(objisPreoffer)".bool ?? false
        }
        if let value = jobDetail[CodingKeys.address.rawValue],!(value is NSNull){
                   self.address = "\(value)"
        }
        if let value = jobDetail[CodingKeys.askingPrice.rawValue],!(value is NSNull){
                   self.askingPrice = "\(value)"
        }
        if let value = jobDetail[CodingKeys.category.rawValue] as? [String:Any]{
                   self.category = GeneralData.init(detail: value)
        }
        if let value = jobDetail[CodingKeys.createdAt.rawValue], !(value is NSNull){
                          self.createdAt = "\(value)"
               }
        if let value = jobDetail[CodingKeys.descriptionDetail.rawValue], !(value is NSNull){
                   self.descriptionDetail = "\(value)"
        }
        if let value = jobDetail[CodingKeys.id.rawValue], !(value is NSNull){
                   self.id = "\(value)"
        }
        if let value = jobDetail[CodingKeys.title.rawValue], !(value is NSNull){
                          self.title = "\(value)"
               }
        if let value = jobDetail[CodingKeys.tavelTime.rawValue] as? [String:Any]{
            self.tavelTime = GeneralData.init(detail: value)
        }
        if let value = jobDetail[CodingKeys.keepPostActive.rawValue] as? [String:Any]{
            self.keepPostActive = GeneralData.init(detail: value)
        }
        if let value = jobDetail[CodingKeys.user.rawValue] as? [String:Any]{
                          self.userDetail = value
               }
       if let value = jobDetail[CodingKeys.userId.rawValue], !(value is NSNull){
                   self.userId = "\(value)"
        }
        if let value = jobDetail[CodingKeys.images.rawValue] as? [[String:Any]]{
                   self.images = value
               }
        if let value = jobDetail[CodingKeys.lat.rawValue], !(value is NSNull){
        self.lat = "\(value)"

        }
        if let value = jobDetail[CodingKeys.lng.rawValue], !(value is NSNull){
               self.lng = "\(value)"
               
           }
         
    }
}
class CustomerDetail:NSObject{
    var id = ""
    var quickblox_id = ""
    var firstname = "", lastname = "", username = "", email: String = ""
    var countryCode = "", phone: String = ""
    var profilePic: String = ""
    var coverPic = "", userType = "", company = "", address: String = ""
    var city = "", state = "", zipcode = "", customerDetailDescription: String = ""
    var userId = ""
    var lat = "", lng = ""
    var rating = ""
    var review = ""
    var job = ""
    var inprogressJOB:[String:Any] = [:] //show direction and last name if and only if job is booked
    var isFullNameShow:Bool = false
    var isContactButtonShow:Bool = false
    var isGetDirectionLinkShow:Bool = false
    var isReportFlagShow:Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case quickblox_id
        case firstname, lastname, username, email
        case countryCode = "country_code"
        case phone
        case profilePic = "profile_pic"
        case coverPic = "cover_pic"
        case userType = "user_type"
        case company, address, city, state, zipcode
        case customerDetailDescription = "description"
        case userId = "user_id"
        case lat, lng
        case rating, review
        case job
        case inprogressJOB = "in_progress_job"
        case isFullNameShow = "is_full_name_show"
        case isContactButtonShow = "is_contact_button_show"
        case isGetDirectionLinkShow = "is_get_direction_link_show"
        case isReportFlagShow = "is_report_flag_show"
    }
    init(customerDetail:[String:Any]){
        if let isfullnameshow = customerDetail[CodingKeys.isFullNameShow.rawValue] as? Bool{
            self.isFullNameShow = isfullnameshow
        }
        if let iscontactbuttonshow = customerDetail[CodingKeys.isContactButtonShow.rawValue] as? Bool{
            self.isContactButtonShow = iscontactbuttonshow
        }
        if let isgetdirectionlinkshow = customerDetail[CodingKeys.isGetDirectionLinkShow.rawValue] as? Bool{
            self.isGetDirectionLinkShow = isgetdirectionlinkshow
        }
        if let isreportflagshow = customerDetail[CodingKeys.isReportFlagShow.rawValue] as? Bool{
            self.isReportFlagShow = isreportflagshow
        }
        if let value = customerDetail[CodingKeys.inprogressJOB.rawValue] as? [String:Any]{
            self.inprogressJOB = value
        }
        if let objquickblox_id = customerDetail[CodingKeys.quickblox_id.rawValue],!(objquickblox_id is NSNull){
                   self.quickblox_id = "\(objquickblox_id)"
        }
        if let objId = customerDetail[CodingKeys.id.rawValue],!(objId is NSNull){
            self.id = "\(objId)"
        }
        if let value = customerDetail[CodingKeys.userId.rawValue],!(value is NSNull){
            self.userId = "\(value)"
        }
        if let value = customerDetail[CodingKeys.lat.rawValue],!(value is NSNull){
            self.lat = "\(value)"
        }
        if let value = customerDetail[CodingKeys.lng.rawValue],!(value is NSNull){
            self.lng = "\(value)"
        }
        if let objfirstname = customerDetail[CodingKeys.firstname.rawValue],!(objfirstname is NSNull){
            self.firstname = "\(objfirstname)"
        }
        if let objlastname = customerDetail[CodingKeys.lastname.rawValue],!(objlastname is NSNull){
            self.lastname = "\(objlastname)"
        }
        if let objusername = customerDetail[CodingKeys.username.rawValue],!(objusername is NSNull){
            self.username = "\(objusername)"
        }
        if let objemail = customerDetail[CodingKeys.email.rawValue],!(objemail is NSNull){
            self.email = "\(objemail)"
        }
        if let objcountryCode = customerDetail[CodingKeys.countryCode.rawValue],!(objcountryCode is NSNull){
            self.countryCode = "\(objcountryCode)"
        }
        if let objphone = customerDetail[CodingKeys.phone.rawValue],!(objphone is NSNull){
            self.phone = "\(objphone)"
        }
        if let objprofilePic = customerDetail[CodingKeys.profilePic.rawValue],!(objprofilePic is NSNull){
            self.profilePic = "\(objprofilePic)"
        }
        if let objcoverPic = customerDetail[CodingKeys.coverPic.rawValue],!(objcoverPic is NSNull){
            self.coverPic = "\(objcoverPic)"
        }
        if let objuserType = customerDetail[CodingKeys.userType.rawValue],!(objuserType is NSNull){
            self.userType = "\(objuserType)"
        }
        if let objcompany = customerDetail[CodingKeys.company.rawValue],!(objcompany is NSNull){
            self.company = "\(objcompany)"
        }
        if let objaddress = customerDetail[CodingKeys.address.rawValue],!(objaddress is NSNull){
            self.address = "\(objaddress)"
        }
        if let objcity = customerDetail[CodingKeys.city.rawValue],!(objcity is NSNull){
            self.city = "\(objcity)"
        }
        if let objstate = customerDetail[CodingKeys.state.rawValue],!(objstate is NSNull){
            self.state = "\(objstate)"
        }
        if let objzipcode = customerDetail[CodingKeys.zipcode.rawValue],!(objzipcode is NSNull){
            self.zipcode = "\(objzipcode)"
        }
        if let objcustomerDetailDescription = customerDetail[CodingKeys.customerDetailDescription.rawValue],!(objcustomerDetailDescription is NSNull){
            self.customerDetailDescription = "\(objcustomerDetailDescription)"
        }
        if let value = customerDetail[CodingKeys.rating.rawValue],!(value is NSNull){
            self.rating = "\(value)"
        }
         if let value = customerDetail[CodingKeys.review.rawValue],!(value is NSNull){
                   self.review = "\(value)"
               }
        if let value = customerDetail[CodingKeys.job.rawValue],!(value is NSNull){
                          self.job = "\(value)"
                      }
        
    }
}
class ProviderDetail : NSObject{
    
        var id = "", userID:String = ""
        var businessName = "", countryCode = "", phone = "", email: String = ""
        var address = "", city = "", state = "", zipcode: String = ""
        var lat = "", lng = "", providerDetailDescription = "", keywordsForBusiness: String = ""
        var ein: String = ""
        var businessLogo = "", businessLicense = "", driverLicense: String = ""
        var insurance = "", howLongWillingToTravel = "", createdAt = "", updatedAt: String = ""
        var deletedAt: String = ""
        var isDeleted: String = ""
        var rating:String = ""
        var review:String = ""
        var businessLife: [[String:Any]] = []
        var userDetail:ProviderUserDetail?
        var promotions: [[String:Any]] = []
        var objPromotion:Promotion?
        var job:[[String:Any]] = []
        var isInprogressJOB:[String:Any] = [:]
    var isBookNowButtonShow:Bool = false
    var isContactButtonShow:Bool = false
    var isGetDirectionLinkShow:Bool = false
    var isReportFlagShow:Bool = false
    var promotionSectionText:String = ""
    var isViewAllButtonShow:Bool = true
    
        enum CodingKeys: String, CodingKey {
            case id
            case userID = "user_id"
            case businessName = "business_name"
            case countryCode = "country_code"
            case phone, email, address, city, state, zipcode, lat, lng
            case providerDetailDescription = "description"
            case keywordsForBusiness = "keywords_for_business"
            case ein
            case businessLogo = "business_logo"
            case businessLicense = "business_license"
            case driverLicense = "driver_license"
            case insurance
            case howLongWillingToTravel = "how_long_willing_to_travel"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case deletedAt = "deleted_at"
            case isDeleted = "is_deleted"
            case businessLife = "business_life"
            case userDetail = "user_detail"
            case rating, promotions, review
            case job = "jobs"
            case isInprogressJOB = "in_progress_job"
            case isBookNowButtonShow = "is_book_now_button_show"
            case isContactButtonShow = "is_contact_button_show"
            case isGetDirectionLinkShow = "is_get_direction_link_show"
            case isReportFlagShow = "is_report_flag_show"
            case promotionSectionText = "promotion_section_text"
            case isViewAllButtonShow = "view_all_promotion_button"
        }
        init(providerDetail:[String:Any]){
            if let objisViewAllButtonShow = providerDetail[CodingKeys.isViewAllButtonShow.rawValue] as? Bool{
                self.isViewAllButtonShow = objisViewAllButtonShow
            }
            if let isbooknowbuttonshow = providerDetail[CodingKeys.isBookNowButtonShow.rawValue] as? Bool{
                self.isBookNowButtonShow = isbooknowbuttonshow
            }
            if let isbooknowbuttonshow = providerDetail[CodingKeys.isBookNowButtonShow.rawValue] as? Bool{
                self.isBookNowButtonShow = isbooknowbuttonshow
            }
            if let iscontactbuttonshow = providerDetail[CodingKeys.isContactButtonShow.rawValue] as? Bool{
                self.isContactButtonShow = iscontactbuttonshow
            }
            if let isgetdirectionlinkshow = providerDetail[CodingKeys.isGetDirectionLinkShow.rawValue] as? Bool{
                self.isGetDirectionLinkShow = isgetdirectionlinkshow
            }
            if let isreportflagshow = providerDetail[CodingKeys.isReportFlagShow.rawValue] as? Bool{
                self.isReportFlagShow = isreportflagshow
            }
            
            if let _ = providerDetail[CodingKeys.promotionSectionText.rawValue]{
                self.promotionSectionText = "\(providerDetail[CodingKeys.promotionSectionText.rawValue]!)"
            }
        if let _ = providerDetail[CodingKeys.id.rawValue]{
            self.id = "\(providerDetail[CodingKeys.id.rawValue]!)"
        }
            if let inprogressJOB = providerDetail[CodingKeys.isInprogressJOB.rawValue] as? [String:Any]{
                self.isInprogressJOB = inprogressJOB
            }
        if let _ = providerDetail[CodingKeys.userID.rawValue]{
          self.userID = "\(providerDetail[CodingKeys.userID.rawValue]!)"
        }
        if let _ = providerDetail[CodingKeys.businessName.rawValue]{
             self.businessName = "\(providerDetail[CodingKeys.businessName.rawValue]!)"
           }
        if let _ = providerDetail[CodingKeys.countryCode.rawValue]{
             self.countryCode = "\(providerDetail[CodingKeys.countryCode.rawValue]!)"
           }
        if let _ = providerDetail[CodingKeys.phone.rawValue]{
             self.phone = "\(providerDetail[CodingKeys.phone.rawValue]!)"
           }
        if let _ = providerDetail[CodingKeys.email.rawValue]{
            self.email = "\(providerDetail[CodingKeys.email.rawValue]!)"
        }
        if let _ = providerDetail[CodingKeys.address.rawValue]{
            self.address = "\(providerDetail[CodingKeys.address.rawValue]!)"
        }
        if let _ = providerDetail[CodingKeys.city.rawValue]{
            self.city = "\(providerDetail[CodingKeys.city.rawValue]!)"
        }
        if let _ = providerDetail[CodingKeys.state.rawValue]{
            self.state = "\(providerDetail[CodingKeys.state.rawValue]!)"
        }
        if let _ = providerDetail[CodingKeys.zipcode.rawValue]{
            self.zipcode = "\(providerDetail[CodingKeys.zipcode.rawValue]!)"
        }
        if let _ = providerDetail[CodingKeys.lat.rawValue]{
            self.lat = "\(providerDetail[CodingKeys.lat.rawValue]!)"
        }
        if let _ = providerDetail[CodingKeys.lng.rawValue]{
            self.lng = "\(providerDetail[CodingKeys.lng.rawValue]!)"
        }
        if let _ = providerDetail[CodingKeys.providerDetailDescription.rawValue]{
            self.providerDetailDescription = "\(providerDetail[CodingKeys.providerDetailDescription.rawValue]!)"
        }
        if let _ = providerDetail[CodingKeys.keywordsForBusiness.rawValue]{
            self.keywordsForBusiness = "\(providerDetail[CodingKeys.keywordsForBusiness.rawValue]!)"
        }
        if let _ = providerDetail[CodingKeys.ein.rawValue]{
            self.ein = "\(providerDetail[CodingKeys.ein.rawValue]!)"
        }
        if let _ = providerDetail[CodingKeys.businessLogo.rawValue]{
                   self.businessLogo = "\(providerDetail[CodingKeys.businessLogo.rawValue]!)"
               }
        if let _ = providerDetail[CodingKeys.businessLicense.rawValue]{
                   self.businessLicense = "\(providerDetail[CodingKeys.businessLicense.rawValue]!)"
               }
        if let _ = providerDetail[CodingKeys.driverLicense.rawValue]{
               self.driverLicense = "\(providerDetail[CodingKeys.driverLicense.rawValue]!)"
           }
        if let value = providerDetail[CodingKeys.insurance.rawValue],!(value is NSNull){
            self.insurance = "\(providerDetail[CodingKeys.insurance.rawValue]!)"
        }
        if let value = providerDetail[CodingKeys.howLongWillingToTravel.rawValue],!(value is NSNull){
            self.howLongWillingToTravel = "\(value)"//"\(providerDetail[CodingKeys.howLongWillingToTravel.rawValue]!)"
        }
        if let _ = providerDetail[CodingKeys.createdAt.rawValue]{
            self.createdAt = "\(providerDetail[CodingKeys.createdAt.rawValue]!)"
        }
        if let _ = providerDetail[CodingKeys.updatedAt.rawValue]{
            self.updatedAt = "\(providerDetail[CodingKeys.updatedAt.rawValue]!)"
        }
        if let _ = providerDetail[CodingKeys.deletedAt.rawValue]{
                       self.deletedAt = "\(providerDetail[CodingKeys.deletedAt.rawValue]!)"
                   }
        if let _ = providerDetail[CodingKeys.isDeleted.rawValue]{
                       self.isDeleted = "\(providerDetail[CodingKeys.isDeleted.rawValue]!)"
                   }
        if let _ = providerDetail[CodingKeys.rating.rawValue]{
                             self.rating = "\(providerDetail[CodingKeys.rating.rawValue]!)"
                         }
            if let _ = providerDetail[CodingKeys.review.rawValue]{
                                       self.review = "\(providerDetail[CodingKeys.review.rawValue]!)"
            }
        if let objbusinessLife = providerDetail[CodingKeys.businessLife.rawValue] as? [[String:Any]]{
                                  self.businessLife = objbusinessLife
                              }
            if let arrayJob = providerDetail[CodingKeys.job.rawValue] as? [[String:Any]]{
                                         self.job = arrayJob
                                     }
            
        if let objcustomer = providerDetail[CodingKeys.userDetail.rawValue] as? [String:Any]{
            self.userDetail = ProviderUserDetail.init(fromuserDetail: objcustomer)
        }
            
        if let objpromotions = providerDetail[CodingKeys.promotions.rawValue] as? [[String:Any]]{
            self.promotions = objpromotions
            if objpromotions.count > 0{
                self.objPromotion = Promotion.init(promotionDetail: objpromotions[0])
            }
        }
        
            
    }
}

class ProviderUserDetail: NSObject {
    var id: String = ""
    var quickblox_id: String = ""
    var firstname  = "", lastname  = "", email  = "", countryCode: String = ""
    var phone: String  = ""
    var profilePic: String  = ""
    var address = "", city = "", state = "", zipcode: String  = ""
    var lat = "", lng: String  = ""

    enum CodingKeys: String, CodingKey {
        case id, firstname, lastname, email, quickblox_id
        case countryCode = "country_code"
        case phone
        case profilePic = "profile_pic"
        case address, city, state, zipcode, lat, lng
    }
    init(fromuserDetail:[String:Any]) {
        if let _ = fromuserDetail[CodingKeys.id.rawValue]{
               self.id = "\(fromuserDetail[CodingKeys.id.rawValue]!)"
        }
        if let _ = fromuserDetail[CodingKeys.quickblox_id.rawValue]{
               self.quickblox_id = "\(fromuserDetail[CodingKeys.quickblox_id.rawValue]!)"
        }
        if let _ = fromuserDetail[CodingKeys.firstname.rawValue]{
                      self.firstname = "\(fromuserDetail[CodingKeys.firstname.rawValue]!)"
               }
        if let _ = fromuserDetail[CodingKeys.lastname.rawValue]{
                      self.lastname = "\(fromuserDetail[CodingKeys.lastname.rawValue]!)"
               }
        if let _ = fromuserDetail[CodingKeys.email.rawValue]{
                      self.email = "\(fromuserDetail[CodingKeys.email.rawValue]!)"
               }
        if let _ = fromuserDetail[CodingKeys.countryCode.rawValue]{
                      self.countryCode = "\(fromuserDetail[CodingKeys.countryCode.rawValue]!)"
               }
        if let _ = fromuserDetail[CodingKeys.phone.rawValue]{
                      self.phone = "\(fromuserDetail[CodingKeys.phone.rawValue]!)"
               }
        if let _ = fromuserDetail[CodingKeys.profilePic.rawValue]{
                      self.profilePic = "\(fromuserDetail[CodingKeys.profilePic.rawValue]!)"
               }
        if let _ = fromuserDetail[CodingKeys.address.rawValue]{
                      self.address = "\(fromuserDetail[CodingKeys.address.rawValue]!)"
               }
        if let _ = fromuserDetail[CodingKeys.city.rawValue]{
                      self.city = "\(fromuserDetail[CodingKeys.city.rawValue]!)"
               }
        if let _ = fromuserDetail[CodingKeys.state.rawValue]{
                             self.state = "\(fromuserDetail[CodingKeys.state.rawValue]!)"
                      }
        
        if let _ = fromuserDetail[CodingKeys.zipcode.rawValue]{
               self.zipcode = "\(fromuserDetail[CodingKeys.zipcode.rawValue]!)"
        }
        if let _ = fromuserDetail[CodingKeys.lat.rawValue]{
               self.lat = "\(fromuserDetail[CodingKeys.lat.rawValue]!)"
        }
        if let _ = fromuserDetail[CodingKeys.lng.rawValue]{
               self.lng = "\(fromuserDetail[CodingKeys.lng.rawValue]!)"
        }
        
        
        
    }
}
//Promotions
class Promotion: NSObject {
    var id: String = ""
    var name = "", promotionDescription: String  = ""
    var image: String = ""
    var expiryDate: String = ""
    var useOnce: String = ""
    var code: String  = ""
    var isCurrent: String  = ""
    var createdAt = "", updatedAt: String = ""
    var deletedAt: String = ""
    var createdBy: String = ""
    var updatedBy = "", deletedBy: String = ""
    var type: String = ""
    var amount: String = ""
    var savingprice :String = ""
    var customerDiscount : String = ""
    var isDeleted:String = ""
    var isExpired:String = ""
    var werkulesFees:String = ""
    
    enum CodingKeys: String, CodingKey {
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
    }
    init(promotionDetail:[String:Any]) {
        if let _ = promotionDetail[CodingKeys.customerDiscount.rawValue]{
                             self.customerDiscount = "\(promotionDetail[CodingKeys.customerDiscount.rawValue]!)"
                         }
        
        if let _ = promotionDetail[CodingKeys.isExpired.rawValue]{
                          self.isExpired = "\(promotionDetail[CodingKeys.isExpired.rawValue]!)"
                      }
        if let _ = promotionDetail[CodingKeys.isDeleted.rawValue]{
                   self.isDeleted = "\(promotionDetail[CodingKeys.isDeleted.rawValue]!)"
               }
        if let _ = promotionDetail[CodingKeys.id.rawValue]{
            self.id = "\(promotionDetail[CodingKeys.id.rawValue]!)"
        }
        if let _ = promotionDetail[CodingKeys.werkulesFees.rawValue]{
            self.werkulesFees = "\(promotionDetail[CodingKeys.werkulesFees.rawValue]!)"
        }
        if let _ = promotionDetail[CodingKeys.name.rawValue]{
                   self.name = "\(promotionDetail[CodingKeys.name.rawValue]!)"
               }
        if let _ = promotionDetail[CodingKeys.promotionDescription.rawValue]{
                   self.promotionDescription = "\(promotionDetail[CodingKeys.promotionDescription.rawValue]!)"
               }
        if let _ = promotionDetail[CodingKeys.image.rawValue]{
            self.image = "\(promotionDetail[CodingKeys.image.rawValue]!)"
        }
        if let _ = promotionDetail[CodingKeys.expiryDate.rawValue]{
                   self.expiryDate = "\(promotionDetail[CodingKeys.expiryDate.rawValue]!)"
               }
        if let _ = promotionDetail[CodingKeys.useOnce.rawValue]{
                   self.useOnce = "\(promotionDetail[CodingKeys.useOnce.rawValue]!)"
               }
        if let _ = promotionDetail[CodingKeys.code.rawValue]{
                   self.code = "\(promotionDetail[CodingKeys.code.rawValue]!)"
               }
        if let _ = promotionDetail[CodingKeys.isCurrent.rawValue]{
                   self.isCurrent = "\(promotionDetail[CodingKeys.isCurrent.rawValue]!)"
               }
        if let _ = promotionDetail[CodingKeys.createdAt.rawValue]{
            self.createdAt = "\(promotionDetail[CodingKeys.createdAt.rawValue]!)"
        }
        if let _ = promotionDetail[CodingKeys.updatedAt.rawValue]{
            self.updatedAt = "\(promotionDetail[CodingKeys.updatedAt.rawValue]!)"
        }
        if let _ = promotionDetail[CodingKeys.deletedAt.rawValue]{
            self.deletedAt = "\(promotionDetail[CodingKeys.deletedAt.rawValue]!)"
        }
        if let _ = promotionDetail[CodingKeys.createdBy.rawValue]{
            self.createdBy = "\(promotionDetail[CodingKeys.createdBy.rawValue]!)"
        }
        if let _ = promotionDetail[CodingKeys.updatedBy.rawValue]{
            self.updatedBy = "\(promotionDetail[CodingKeys.updatedBy.rawValue]!)"
        }
        if let _ = promotionDetail[CodingKeys.deletedBy.rawValue]{
            self.deletedBy = "\(promotionDetail[CodingKeys.deletedBy.rawValue]!)"
        }
        if let _ = promotionDetail[CodingKeys.type.rawValue]{
                   self.type = "\(promotionDetail[CodingKeys.type.rawValue]!)"
               }
        if let _ = promotionDetail[CodingKeys.amount.rawValue]{
                   self.amount = "\(promotionDetail[CodingKeys.amount.rawValue]!)"
               }
        if let _ = promotionDetail[CodingKeys.savingprice.rawValue]{
                   self.savingprice = "\(promotionDetail[CodingKeys.savingprice.rawValue]!)"
               }
        
        
        
    }
    
}
// MARK: - FromUser
class FromUser: NSObject {
    var id: String = ""
    var firstname = "", lastname = "", username = "", email: String = ""
    var profilePic: String = ""
    var isFullNameShow:Bool = false

    enum CodingKeys: String, CodingKey {
        case id, firstname, lastname, username, email
        case profilePic = "profile_pic"
        case isFullNameShow = "is_full_name_show"
        
    }
    init(fromuserDetail:[String:Any]) {
        if let isfullnameshow = fromuserDetail[CodingKeys.isFullNameShow.rawValue] as? Bool{
            self.isFullNameShow = isfullnameshow
        }
        if let _ = fromuserDetail[CodingKeys.id.rawValue]{
            self.id = "\(fromuserDetail[CodingKeys.id.rawValue]!)"
        }
        if let _ = fromuserDetail[CodingKeys.firstname.rawValue]{
            self.firstname = "\(fromuserDetail[CodingKeys.firstname.rawValue]!)"
        }
        if let _ = fromuserDetail[CodingKeys.lastname.rawValue]{
            self.lastname = "\(fromuserDetail[CodingKeys.lastname.rawValue]!)"
        }
        if let _ = fromuserDetail[CodingKeys.username.rawValue]{
            self.username = "\(fromuserDetail[CodingKeys.username.rawValue]!)"
        }
        if let _ = fromuserDetail[CodingKeys.email.rawValue]{
            self.email = "\(fromuserDetail[CodingKeys.email.rawValue]!)"
        }
        if let _ = fromuserDetail[CodingKeys.profilePic.rawValue]{
                   self.profilePic = "\(fromuserDetail[CodingKeys.profilePic.rawValue]!)"
        }
    }
}


struct SchoolClass {
    var strClassId:String
    var strTeacherId:String
    var strName:String
}
class DashBoardModule: NSObject {
    var moduleID: String = ""
    var moduleName: String = ""
    var slug: String = ""
    var moduleIcon: String = ""
    
    
    init(dashBoardDetail:[String:Any]){
        super.init()
        if let id = dashBoardDetail["module_id"]{
            self.moduleID = "\(id)"
        }
        if let name = dashBoardDetail["module_name"]{
            self.moduleName = "\(name)"
        }
        if let objSlug = dashBoardDetail["slug"]{
            self.slug = "\(objSlug)"
        }
        if let objIcon = dashBoardDetail["module_icon"] as? String,
            let objImage = objIcon.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed){

            self.moduleIcon = "\(objImage)"
        }
    }
}
class PhotoGalleryAlbum: NSObject {
    var albumID: String = ""
    var albumName: String = ""
    var albumClasses: String = ""
    var albumDescription: String = ""
    var albumStatus: String = ""
    var albumCreated: String = ""
    var albumModified: String = ""
    var albumImage:String = ""
    
    init(photoGalleryDetail:[String:Any]){
        super.init()
        if let id = photoGalleryDetail["event_galllery_id"]{
            self.albumID = "\(id)"
        }
        if let name = photoGalleryDetail["album_name"]{
            self.albumName = "\(name)"
        }
        if let classes = photoGalleryDetail["classes"]{
            self.albumClasses = "\(classes)"
        }
        if let description = photoGalleryDetail["description"]{
            self.albumDescription = "\(description)"
        }
        if let status = photoGalleryDetail["status"]{
            self.albumStatus = "\(status)"
        }
        if let created = photoGalleryDetail["created"]{
            self.albumCreated = "\(created)"
        }
        if let modifies = photoGalleryDetail["modifies"]{
            self.albumModified = "\(modifies)"
        }
        if let attachment = photoGalleryDetail["attachment"] as? String,
            let objImage = attachment.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed){
            self.albumImage = "\(objImage)"
        }
    }
}
class SchoolStudent: NSObject {
    
    fileprivate var kStudentRelID = "stud_rel_id"
    fileprivate var kStudentRollNo =  "roll_no"
    fileprivate var kStudentAcademiYearID =  "academic_year_id"
    fileprivate var kStudentGRNO =  "gr_no"
    fileprivate var kStudentID =  "student_id"
    fileprivate var kStudentSurName =  "surname"
    fileprivate var kStudentName =  "student_name"
    fileprivate var kStudentFatherName =  "father_name"
    fileprivate var kStudentClassName = "class_name"
    fileprivate var kStudentDiVisonName = "divison_name"
    fileprivate var kStudentISNew = "is_new"
    fileprivate var kStudentDateOfAddmission = "date_of_admission"
    fileprivate var kStudentClassID =  "class_id"
    fileprivate var kStudentDivisionID = "divison_id"
    fileprivate var kStudentIsAbsent = "is_absent"
    
    var relID: String = ""
    var rollNo: String = ""
    var accedemicYearID: String = ""
    var grNo: String = ""
    var studentID: String = ""
    var surName: String = ""
    var studentName:String = ""
    var fatherName: String = ""
    var className:String = ""
    var divisionName:String = ""
    var isNew:String = ""
    var dateOfAddmission:String = ""
    var classID:String = ""
    var devisionID:String = ""
    var fullName:String = ""
    var isAbsent:Bool = false
    
    init(studentDetail:[String:Any]){
        super.init()
        if let id = studentDetail[kStudentRelID]{
            self.relID = "\(id)"
        }
        if let roll_no = studentDetail[kStudentRollNo]{
            self.rollNo = "\(roll_no)"
        }
        if let academic_year_id = studentDetail[kStudentAcademiYearID]{
            self.accedemicYearID = "\(academic_year_id)"
        }
        if let gr_no = studentDetail["gr_no"]{
            self.grNo = "\(gr_no)"
        }
        if let student_id = studentDetail["student_id"]{
            self.studentID = "\(student_id)"
        }
        if let sur_name = studentDetail["surname"]{
            self.surName = "\(sur_name)"
        }
        if let student_name = studentDetail["student_name"]{
            self.studentName = "\(student_name)"
        }
        if let father_name = studentDetail["father_name"]{
            self.fatherName = "\(father_name)"
        }
        if let class_name = studentDetail["class_name"]{
            self.className = "\(class_name)"
        }
        if let divison_name = studentDetail["divison_name"]{
            self.divisionName = "\(divison_name)"
        }
        if let is_new = studentDetail["is_new"]{
            self.isNew = "\(is_new)"
        }
        if let date_of_admission = studentDetail["date_of_admission"]{
            self.dateOfAddmission = "\(date_of_admission)"
        }
        if let class_id = studentDetail["class_id"]{
            self.classID = "\(class_id)"
        }
        if let divison_id = studentDetail["divison_id"]{
            self.devisionID = "\(divison_id)"
        }
        if let objIsAbsent = studentDetail[kStudentIsAbsent] as? Bool{
            self.isAbsent = objIsAbsent
        }
        self.fullName = "\(self.studentName) \(self.fatherName) \(self.surName)"
        
    }
}
@IBDesignable
class ShadowBackgroundView:UIView{
    private var theShadowLayer: CAShapeLayer!
    
    @IBInspectable open var rounding: Double = 15.0 {
       didSet {
           if rounding != oldValue {
                self.layoutSubviews()
           }
       }
   }
    
 
    override func layoutSubviews() {
        super.layoutSubviews()
         
            let rounding = CGFloat.init(self.rounding)
            var shadowLayer = CAShapeLayer.init()
            shadowLayer.name = "ShadowLayer1"
            shadowLayer.path = UIBezierPath.init(roundedRect: bounds, cornerRadius: rounding).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowColor = UIColor.init(red: 60.0/255.0, green: 64.0/255.0, blue: 67.0/255.0, alpha:0.3).cgColor
            shadowLayer.shadowRadius = CGFloat.init(2.0)
            shadowLayer.shadowOpacity = Float.init(0.5)
            shadowLayer.shadowOffset = CGSize.init(width: 0.0, height: 1.0)
            if  let arraySublayer1:[CALayer] = self.layer.sublayers?.filter({$0.name == "ShadowLayer1"}),let sublayer1 =  arraySublayer1.first{
                    sublayer1.removeFromSuperlayer()
            }
            self.layer.insertSublayer(shadowLayer, below: nil)
            shadowLayer = CAShapeLayer.init()
            shadowLayer.name = "ShadowLayer2"
            shadowLayer.path = UIBezierPath.init(roundedRect: bounds, cornerRadius: rounding).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowColor = UIColor.init(red: 60.0/255.0, green: 64.0/255.0, blue: 67.0/255.0, alpha:0.15).cgColor
            shadowLayer.shadowRadius = CGFloat.init(6.0)
            shadowLayer.shadowOpacity = Float.init(0.5)
            shadowLayer.shadowOffset = CGSize.init(width: 0.0, height: 2.0)
            if  let arraySublayer2:[CALayer] = self.layer.sublayers?.filter({$0.name == "ShadowLayer2"}),let sublayer2 =  arraySublayer2.first{
                sublayer2.removeFromSuperlayer()
            }
            self.layer.insertSublayer(shadowLayer, below: nil)
        
    }
}
  extension UIView {

    func dropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
class Vocabulary: NSObject {
    enum Language : String{
        case english = "en"
        case spanish = "sp"
    }
    static let shared:Vocabulary  = Vocabulary()
    var language = Language.english.rawValue
    var currentLanguage:String{
        get{
            return language
        }
        set{
            language = newValue
            kUserDefault.setValue("\(newValue)", forKey: kSelectedLanguage)
        }
    }
    override init() {
        super.init()
        
    }
    func setSelectedLanguage(language:Language){
        self.currentLanguage = language.rawValue
    }
    func getVocabularyAsPerSelectedLanguage(key:String)->String{
        var vocabDictionary: NSDictionary = NSDictionary()
        if let language = kUserDefault.value(forKey: kSelectedLanguage){
            if "\(language)" == Language.english.rawValue{
                if let path = Bundle.main.path(forResource: "VocabularyEnglish", ofType: "plist") {
                    vocabDictionary = NSDictionary(contentsOfFile: path) ?? NSDictionary()
                }
            }else if "\(language)" == Language.spanish.rawValue{
                
            }else{
                
            }
        }
        if let value = vocabDictionary[key] as? String{
            return value
        }
        return key
    }
}
extension UIView{
    func addBordorRadiusWithColor(radius:CGFloat = 6.0,borderWidth:CGFloat = 0.5,color:CGColor = UIColor.lightGray.cgColor){
        DispatchQueue.main.async {
            self.layer.cornerRadius = radius
            self.clipsToBounds = true
            self.layer.borderColor = color
            self.layer.borderWidth = borderWidth
        }
    }
}
extension UITableView{
    func hideFooter(){
        DispatchQueue.main.async {
            self.tableFooterView = UIView()
        }
    }
    func hideHeader(){
        DispatchQueue.main.async {
            self.tableHeaderView = UIView()
        }
    }
    func scrollEnableIfTableViewContentIsLarger(){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.isScrollEnabled = (self.contentSize.height > self.bounds.height)
        }
    }
    func sizeHeaderFit(){
          DispatchQueue.main.async {
              if let headerView =  self.tableHeaderView {
                  headerView.setNeedsLayout()
                  headerView.layoutIfNeeded()
                  print(headerView.bounds)
                  print(headerView.frame)
                  
                  let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
                  print(height)
                  var frame = headerView.frame
                  frame.size.height = height
                  headerView.frame = frame
                  self.tableHeaderView = headerView
                 self.layoutIfNeeded()
              }
          }
         }
}
extension Dictionary where  Key == String {
    mutating func updateJSONNullToString(){
        let keysToRemove = self.keys.filter{(self[$0] is NSNull)}
        for key in keysToRemove {
            self["\(key)"] = "" as? Value
        }
    }
}
extension UIStoryboard{
    class var main:UIStoryboard{
        return  UIStoryboard.init(name: "Main", bundle: nil)
    }
    class var profile:UIStoryboard{
          return  UIStoryboard.init(name: "Profile", bundle: nil)
    }
    class var messages:UIStoryboard{
             return  UIStoryboard.init(name: "Messages", bundle: nil)
       }
    class var activity:UIStoryboard{
                return  UIStoryboard.init(name: "Activity", bundle: nil)
    }
    class var businessFeed:UIStoryboard{
        return  UIStoryboard.init(name: "BusinessLifeFeed", bundle: nil)
    }
}
