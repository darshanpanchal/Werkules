
import Alamofire
import UIKit
import SystemConfiguration

typealias SUCCESS = (_ response:Any)->()
typealias FAIL = (_ response:Any)->()

let KcurrentUserLocationLatitude = "currentUserLatitude"
let KcurrentUserLocationLongitude = "currentUserLongitude"

let maxJOBAmount:Double = 999999.99//1000000.00
let minWithDrawAmount:Double = 20.00

let kCommonError = "Something went wrong"
let kGeneralList = "/general-list"
let kLogin = "/login"
let kSocialLogIn = "/social-login"
let kCustomerRegister = "/customer/register"
let kProviderFileUpload = "/provider/fileupload"
let kProviderRegister = "/provider/register"
let kProviderUpdate = "/provider/update"
let kForgotPassword = "/forgot-password"
let kPostJOBDeleteImage = "/delete-file"
let kAddJOB = "/job/create"
let kUpdateJOBWidenSearch = "/job/update-job-detail"
let kAddJOBSingleProviderBook = "/job/single-provider-book"
let kWidenSeach = "/job/job-wid-search"
let kSwitchAccount = "/switchAccount"
let kListOfJOBCustomerHome = "/job/listAllJobs"
let kListOfCustomerOffer = "/job/customer/offer-list"
let kCustomerDetails = "/customer/details"
let kGETUserReview = "/review/get-user-review"
let kGETCustomerReview = "/review/get-customer-review"
let kGETProviderReview = "/review/get-provider-review"
let kGETMYReview = "/review/my-review"
let kUpdateReview = "/review/edit"
let kAddReview = "/review/add"
let kUpdateCustomerProfile = "/customer/update"
let kGETProviderDetail = "/provider/details"
let kGETBusinessLife = "/provider/listBusinessLife"
let kAddPromotion = "/provider/addPromotion"
let kGETPromotionList = "/provider/listPromotions"
let kAddProviderReport = "/job/provider-job-report"
let kAddMyGroupReport = "/group/group-earning-report"
let kAddBusinessLife = "/provider/add-business-life"
let kDeletePromotion = "/provider/delete-promotion"
let kUpdatePromotion = "/provider/update-promotion"
let kDeleteBusinessLife = "/provider/delete-business-life"
let kUpdateBusinessLife = "/provider/update-business-life"
let kDeleteSuspendUser = "/user/delete"
let kAddCustomerReport = "/job/customer-job-report"
let kAddGenralreport = "/general-report"
let kFetchProviderOfferHome = "/job/list-offer"
let kJOBDetail = "/job/detail"
let kSendOffer = "/job/send-offer"
let kNotStartedJOB = "/job/not-started-job"
let kBookJOB = "/job/book-now"
let kDirectBookValidation = "/job/direct-provider-book"
let kAcceptJOBList = "/job/accept-job"
let kStartJOB = "/job/start-job"
let kProviderInprogressJOB = "/job/provider/in-progress-job"
let kProviderCompletedJOB = "/job/provider/complete-job"
let kProviderUnSuccessFullJOB = "/job/unsuccessful-offer"
let kCustomerInprogressJOB = "/job/in-progress-job"
let kCustomerCompletedJOB = "/job/customer/job-complete"
let kCustomerNoOfferJOB = "/job/no-offer"
let kCutomerToProviderChat = "/chat/customer-provider-chat"
let kProviderToCustomerChat = "/chat/provider-customer-chat"
let kUsertoUserChat = "/chat/list"
let kUserToUserUpdatedChat = "/v2/chat/list"
let kPostNewMessage = "/chat/save"
let kChatHeaderDetails = "/chat/get-chat-header-detail"
let kPaymentSaveCard = "/payment/save-card"
let kPaymentCardList = "/payment/card-list"
let kPaymentRemainingDetail = "/payment/remaining-payment-detail"
let kPaymentJOBPayment = "/payment/job-payment"
let kPaymentDeleteCard = "/payment/delete-card"
let kProviderCustomerLogout = "/logout"
let kUserChangePassword = "/user/change-password"
let kUpdatePromotionOrder = "/provider/promotion-order-change"


let kProviderGeneralPaymentHistory = "/payment/provider/payment-history"
let kProviderJOBPaymentHistory = "/payment/provider/job-payment-history"
let kProviderPendingPaymentHistory = "/payment/provider/pending-payment-history"

let kCustomerGeneralPaymentHistory = "/payment/payment-history"
let kCustomerPendingPaymentHistory = "/payment/pending-payment-history"


let kCustomerJOBPaymentHistory = "/payment/job-payment-history"
let kCustomerProviderGroupList = "/group/group-list"
let kGroupEarningDetail = "/group/view-group-earning"

let kJOBMarketSearch = "/job/market-research"

let kApplicationFeedback = "/feedback"

let kGETIndustryType = "/mcc_code.json"

let kPostStripevalidation = "/payment/stripe/create-provider-account"
let kGETProviderMyJOBCount = "/job/my-job-count"
let kGETCustomerMyPostCount = "/job/my-post-count"

let kGETMYBusinessEarning = "/group/my-business-earning"
let kGETPaymentReceiptAccountStatus = "/paymentrails/get-recipient-account-status"

let kWithDrawBusinessEarning = "/payment/paymentrails/withdraw-business-earnings"
let kWithDrawGroupEarning = "/payment/paymentrails/withdraw-group-earnings"

let kWithDrawGroupEarningHistory = "/group/earning-history"

let kUserCloseAccount = "/user/close-account"
let kUserCloseAccountValidation = "/user/close-account-validation"

let kPaymentTransactionReport = "/payment/payment-transaction-report"

let kkeyWordSearch = "/search/keyword-search"
let kPersonSearch = "/search/person-search"
let kCompanySearch = "/search/company-search"

let kListOfProviderOnKeywordSearch = "/search/provider-list-by-keyword"
let kListOfJOBBasedOnKeyword = "/search/job-list-by-keyword"
let kCancelPost = "/job/cancel"
let kDeletePost = "/job/delete"
let kCustomerDeleteOffer = "/job/customer/delete-offer"
let kDeleteOffer = "/job/delete-offer"
let kClearKeyword = "/search/clear-search"
let kClearJOBKeyword = "/search/clear-job-keyword-search"
let kWithDrawOffer = "/job/withdraw-offer"

let kCustomerVerifyEmail = "/customer/resend-email-verification"


let kGETBankAccountList = "/payment/stripe/external-account-list"
let kUpdateCurrentSelectedBank = "/payment/stripe/update-default-external-account"
let kDeleteBankAccount = "/payment/stripe/delete-external-account"
let kAddBankAccount = "/payment/stripe/create-external-account"

let kSaveQuickBloxDetail = "/customer/add-quickblox-detail"
let kSaveLog = "/save-log"
let kGroupAddMember = "/group/add-group-member"

let kGETProviderFeeds = "/provider/get-provider-feeds"
let kBusinessFeedFollow = "/provider/follow"
let kBusinessFeedUnFollow = "/provider/unfollow"

let kGETSingleBusinessLife = "/provider/get-business-life"


let kCustomerSignUpVerification = "/customer/select-verification-type"
let kCustomerOTPVerification = "/customer/verify-otp"


let kFollowingList = "/provider/get-following-list"

let kSearchChatList = "/v2/chat/contact-list"
let kGETChatUnreadCount = "/v2/chat/total-unread-message"
let kDeleteChat = "/v2/chat/delete-conversation"
class APIRequestClient: NSObject {

enum RequestType {
    case POST
    case GET
    case PUT
    case DELETE
    case PATCH
    case OPTIONS
}

static let shared:APIRequestClient = APIRequestClient()
    
    func cancelAllAPIRequest(json:Any?){
          
          let sessionManager = Alamofire.SessionManager.default
          sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
              dataTasks.forEach { $0.cancel() }
              uploadTasks.forEach { $0.cancel() }
              downloadTasks.forEach { $0.cancel() }
          }
          if let url  = URL.init(string:BaseAPIURL){
              let task:URLSessionDataTask = URLSession.shared.dataTask(with:url)
              task.cancel()
          }
          if let _ = json{
              if let arrayFail = json as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                  DispatchQueue.main.async {
                    ExternalClass.HideProgress()
                    SAAlertBar.show(.error, message:"\(errorMessage)".localizedLowercase)

                  }
              }else{
                  DispatchQueue.main.async {
                      ExternalClass.HideProgress()
                      SAAlertBar.show(.error, message:"invalid access token".localizedLowercase)
                  }
              }
          }
          if let _ = json{
              DispatchQueue.main.async {
                  if let appDel = UIApplication.shared.delegate as? AppDelegate ,let navigation = appDel.window?.rootViewController as? UINavigationController{
//                      kUserDefault.removeObject(forKey: "isLocationPushToHome")
//                      User.removeUserFromUserDefault()
//                      kUserDefault.removeObject(forKey: kExperienceDetail)
//                      kUserDefault.synchronize()
                      navigation.popToRootViewController(animated: false)
                  }
              }
          }
      }
    func cancelAllPendingAPIRequest(completionHandler: @escaping SUCCESS){
        URLSession.shared.getAllTasks { tasks in
         let myGroup = DispatchGroup()
         for currenttask in tasks{
             myGroup.enter()
             currenttask.cancel()
             myGroup.leave()
         }
         myGroup.notify(queue: .main) {
             completionHandler(true)
                print("Finished all requests.")
            }
      }
    }
    func cancelTaskWithUrl(completionHandler: @escaping SUCCESS){
       URLSession.shared.getAllTasks { tasks in

        let myGroup = DispatchGroup()
        /*
         let kGETProviderMyJOBCount = "/job/my-job-count"
         let kGETCustomerMyPostCount = "/job/my-post-count"
         */
        for currenttask in tasks{
            myGroup.enter()
            if let urlString = currenttask.currentRequest?.url?.absoluteString{
                if urlString.contains("job/my-job-count") || urlString.contains("job/my-post-count") || urlString.contains("/group/group-list") || urlString.contains( "/search/provider-list-by-keyword") || urlString.contains("/v2/chat/list"){
                }else{
                    currenttask.cancel()
                }
            }
            myGroup.leave()
        }
        myGroup.notify(queue: .main) {
            completionHandler(true)
               print("Finished all requests.")
           }
     }
    }
    func saveLogAPIRequest(strMessage:String){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
            return
        }
        let dict = [
                   "user_id": "\(currentUser.id)",
                   "log_module" : "location",
                   "log_description" : "\(strMessage)",
                   "log_platform" : "ios"
            ]

        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSaveLog , parameter: dict as [String:AnyObject], isHudeShow: false, success: { (responseSuccess) in

        }) { (responseFail) in

        }
    }
    func sendAPIRequest(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            SAAlertBar.show(.error, message:"No Internet Connection".localizedLowercase)
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ExternalClass.ShowProgress()
            }
        }
        let urlString = BaseAPIURL + (queryString == nil ? "" : queryString!)
        
        print("===== \(urlString) =====")
        print("==== \(parameter)")
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,let buidnumber =  Bundle.main.infoDictionary?["CFBundleVersion"] as? String{
            request.setValue("\(appVersion) \(buidnumber)", forHTTPHeaderField: "app-version")
        }

        
        if UserDetail.isUserLoggedIn,let currentUser = UserDetail.getUserFromUserDefault(){
            print(currentUser.rememberToken)
            request.setValue("Bearer \(currentUser.rememberToken)", forHTTPHeaderField: "Authorization")
            
        }
        /*
        request.setValue(kXAPIKey, forHTTPHeaderField:"X-API-KEY")
         
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        if let user = User.getUserFromUserDefault(){ //Id 2 for student and 1 for admin/super admin
            if user.userrole_id.count > 0{
                request.setValue("\(user.userrole_id)", forHTTPHeaderField: "roll_id")
            }
        }*/
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                DispatchQueue.main.async {
                    ExternalClass.HideProgress()
                }
                SAAlertBar.show(.error, message:kCommonError.localizedLowercase)
                fail(["error":kCommonError])
            }
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ExternalClass.HideProgress()
            }
            if error != nil{
//                SAAlertBar.show(.error, message:"\(error!.localizedDescription)".localizedLowercase)
                
                //fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        if httpStatus.statusCode == 403{
                            DispatchQueue.main.async(execute: {
                               UserDetail.removeUserFromUserDefault()
                               self.popToLogInViewController()
                               //self.navigationController?.popToRootViewController(animated: false)
                            })
                            fail(json)
                        }
                        print(json)
                        (httpStatus.statusCode == 200) ? success(json):fail(json)
                    }
                    catch{
                        //ShowToast.show(toatMessage: kCommonError)
                        //fail(["error":kCommonError])
                    }
            }else{
//                SAAlertBar.show(.error, message:kCommonError.localizedLowercase)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    func popToLogInViewController(){
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let navigationController = UINavigationController(rootViewController:loginVC)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }
    func uploadImage(requestType:RequestType,queryString:String?,parameter:[String:AnyObject],imageData:Data?,isFileUpload:Bool = false,fileName:String = "file",isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
           guard CommonClass.shared.isConnectedToInternet else{
               SAAlertBar.show(.error, message:"No Internet Connection".localizedLowercase)
               return
           }
           if isHudeShow{
               DispatchQueue.main.async {
                   ExternalClass.ShowProgress()
               }
           }
           let urlString = BaseAPIURL + (queryString == nil ? "" : queryString!)
          
            
           var headers: HTTPHeaders = ["Content-type": "multipart/form-data"]
        
           if UserDetail.isUserLoggedIn,let currentUser = UserDetail.getUserFromUserDefault(){
                headers["Authorization"] = "Bearer \(currentUser.rememberToken)"
            
            }
            Alamofire.upload(multipartFormData: { (multipartFormData) in
               
            for (key, value) in parameter {
                   multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
             if let data = imageData{
               if isFileUpload{
                
                multipartFormData.append(imageData!, withName: "file", fileName: "\(fileName)", mimeType: "\(data.mimeType)")
               }else{
                   multipartFormData.append(imageData!, withName: "profile_pic", fileName: "image.png", mimeType: "image/png")
               }
               
            }
            
            }, usingThreshold: UInt64.init(), to: urlString, method:HTTPMethod(rawValue:"\(requestType)")!, headers: headers) { (result) in
              
              
            switch result{
            case .success(let upload, _, _):
            upload.responseJSON { response in
               
            if let objResponse = response.response,objResponse.statusCode == 200{
               if let successResponse = response.value as? [String:Any]{
                   success(successResponse)
               }
            }else if let objResponse = response.response,objResponse.statusCode == 401{
               self.cancelAllAPIRequest(json: response.value)
            }else if let objResponse = response.response,objResponse.statusCode == 400{
               if let failResponse = response.value as? [String:Any]{
                   fail(failResponse)
               }
            }else if let error = response.error{
               DispatchQueue.main.async {
                   SAAlertBar.show(.error, message:"\(error.localizedDescription)".localizedLowercase)
                   fail(["error":"\(error.localizedDescription)"])
               }
            }else{
               DispatchQueue.main.async {
                   if let failResponse = response.value as? [String:Any]{
                       fail(failResponse)
                   }
               }
              }
            }
            case .failure(let error):
               DispatchQueue.main.async {
                   SAAlertBar.show(.error, message:"\(error.localizedDescription)".localizedLowercase)
                   fail(["error":"\(error.localizedDescription)"])
               }
            }
            }
       }
        
    func uploadpromotionImage(requestType:RequestType,queryString:String?,parameter:[String:AnyObject],imageData:Data?,isFileUpload:Bool = false,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            SAAlertBar.show(.error, message:"No Internet Connection".localizedLowercase)
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ExternalClass.ShowProgress()
            }
        }
        let urlString = BaseAPIURL + (queryString == nil ? "" : queryString!)
       
         
        var headers: HTTPHeaders = ["Content-type": "multipart/form-data"]
     
        if UserDetail.isUserLoggedIn,let currentUser = UserDetail.getUserFromUserDefault(){
             headers["Authorization"] = "Bearer \(currentUser.rememberToken)"
         }
         Alamofire.upload(multipartFormData: { (multipartFormData) in
            
         for (key, value) in parameter {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
         }
         
          if let data = imageData{
            if isFileUpload{
             multipartFormData.append(imageData!, withName: "file", fileName: "file", mimeType: "\(data.mimeType)")
            }else{
                multipartFormData.append(imageData!, withName: "image", fileName: "image.png", mimeType: "image/png")
            }
            
         }
         
         }, usingThreshold: UInt64.init(), to: urlString, method:HTTPMethod(rawValue:"\(requestType)")!, headers: headers) { (result) in
           
           
         switch result{
         case .success(let upload, _, _):
         upload.responseJSON { response in
            
         if let objResponse = response.response,objResponse.statusCode == 200{
            if let successResponse = response.value as? [String:Any]{
                success(successResponse)
            }else{
                success(response.value)
            }
         }else if let objResponse = response.response,objResponse.statusCode == 401{
            self.cancelAllAPIRequest(json: response.value)
         }else if let objResponse = response.response,objResponse.statusCode == 400{
            if let failResponse = response.value as? [String:Any]{
                fail(failResponse)
            }
         }else if let error = response.error{
            DispatchQueue.main.async {
                SAAlertBar.show(.error, message:"\(error.localizedDescription)".localizedLowercase)
                fail(["error":"\(error.localizedDescription)"])
            }
         }else{
            DispatchQueue.main.async {
                if let failResponse = response.value as? [String:Any]{
                    fail(failResponse)
                }
            }
           }
         }
         case .failure(let error):
            DispatchQueue.main.async {
                SAAlertBar.show(.error, message:"\(error.localizedDescription)".localizedLowercase)
                fail(["error":"\(error.localizedDescription)"])
            }
         }
         }
    }
    
    
    
    
    
}
class CommonClass{
     //SingleTon
     static let shared:CommonClass = {
        let common = CommonClass()
        return common
     }()
     var isConnectedToInternet:Bool{
         get{
             var zeroAddress = sockaddr_in()
             zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
             zeroAddress.sin_family = sa_family_t(AF_INET)
             
             guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
                 $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                     SCNetworkReachabilityCreateWithAddress(nil, $0)
                 }
             }) else {
                 return false
             }
             
             var flags: SCNetworkReachabilityFlags = []
             if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
                 return false
             }
             
             let isReachable = flags.contains(.reachable)
             let needsConnection = flags.contains(.connectionRequired)
             return (isReachable && !needsConnection)
         }
     }
     static let isSimulator: Bool = {
         return TARGET_OS_SIMULATOR == 1
     }()
     var noInternetAlertController:UIAlertController{
         get{
             let alertController = UIAlertController.init(title:"No Internet", message: "Please check your connection and try again.", preferredStyle: .alert)
             let alertAction = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
             alertController.addAction(alertAction)
             return alertController
         }
     }
    
}
extension Double {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}
extension String{
    
    var add2DecimalWithCommaString:String{
        let updated = "\(self)"
        if updated.count > 0{
            if let pi: Double = Double("\(updated)"){
             let updatedvalue = String(format:"%.2f", pi)
                let array = updatedvalue.components(separatedBy:".")
                if array.count > 1{
                    if let newValue = Double("\(array.first!)"){
                        let withCommaValue = newValue.withCommas()
                        print("$\(withCommaValue).\(array[1])")
                        return "$\(withCommaValue).\(array[1])"
                    }
                }
                return "$\(updatedvalue)"
            }
        }
        return updated
    }
    var add2DecimalString:String{
        let updated = "\(self)"
        if updated.count > 0{
            if let pi: Double = Double("\(updated)"){
             let updatedvalue = String(format:"%.2f", pi)
                /*
                let array = updatedvalue.components(separatedBy:".")
                if array.count > 1{
                    if let newValue = Double("\(array.first!)"){
                        let withCommaValue = newValue.withCommas()
                        return "$\(withCommaValue).\(array[1])"
                    }
                }*/
                return "$\(updatedvalue)"
            }
        }
        return updated
    }
    
    var changeDateFormat:String{
          let dateFormatter = DateFormatter()
          let tempLocale = dateFormatter.locale // save locale temporarily
          dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
          dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
          if let date = dateFormatter.date(from: self){
              let dateFormatter = DateFormatter()
              dateFormatter.dateStyle = .medium
              dateFormatter.dateFormat = "MM/dd/yyyy"
              let dateString = dateFormatter.string(from: date)
              return dateString
          }else{
              return self
          }
      }
        var bool: Bool? {
            switch self.lowercased() {
            case "true", "t", "yes", "y", "1":
                return true
            case "false", "f", "no", "n", "0":
                return false
            default:
                return nil
            }
        }
    
    func isValidEmail() -> Bool {
           let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
           return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
       }
    func converTo12hoursFormate()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        if let date = dateFormatter.date(from: self){
            dateFormatter.dateFormat = "hh:mm a"
             let date12:String = dateFormatter.string(from: date)
             return "\(date12)"
        }else{
            return self
        }
    }
    func converTo24hoursFormate()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        if let date = dateFormatter.date(from: self){
            dateFormatter.dateFormat = "HH:mm"
            let date24:String = dateFormatter.string(from: date)
            return "\(date24)"
        }else{
            return self
        }
    }
    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first.uppercased() + other.lowercased()
    }
    func removeWhiteSpaces()->String
    {
        return self.replacingOccurrences(of: " ", with: "")
    }
    var removingWhitespacesAndNewlines: String {
        return components(separatedBy: .whitespacesAndNewlines).joined()
    }
    func convertString(string: String) -> String {
        let data = string.data(using: String.Encoding.ascii, allowLossyConversion: true)
        return NSString(data: data!, encoding: String.Encoding.ascii.rawValue)! as String
    }
    func compareCaseInsensitive(str:String)->Bool{
        return self.caseInsensitiveCompare(str) == .orderedSame
    }
    
    func isContainWhiteSpace()->Bool{
        guard self.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines) == nil else{
            return true
        }
        return false
    }
    func isOnlyWhiteSpace()->Bool{
        let whiteSpaceSet = NSCharacterSet.whitespacesAndNewlines
        guard self.trimmingCharacters(in: whiteSpaceSet).count != 0 else{
            return true
        }
        return false
    }
   static func getSelectedLanguage()->String{
        if let selection = UserDefaults.standard.value(forKey: "selectedLanguageCode") as? String{ // 1 eng , 2 swed
            return selection.removeWhiteSpaces().lowercased()
        }
        return "1"
    }
}
class MyBorderView: UIView {
  override init(frame: CGRect) {
      super.init(frame: frame)
      didLoad()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    didLoad()
  }

  convenience init() {
    self.init(frame: .zero)
  }

  func didLoad() {
    //Place your initialization code here
    self.layer.borderWidth = 0.7
    self.layer.borderColor = UIColor.lightGray.cgColor
  }
}
extension Data {
    private static let mimeTypeSignatures: [UInt8 : String] = [
        0xFF : "image/jpeg",
        0x89 : "image/png",
        0x47 : "image/gif",
        0x49 : "image/tiff",
        0x4D : "image/tiff",
        0x25 : "application/pdf",
        0xD0 : "application/vnd",
        0x46 : "text/plain",
        ]

    var mimeType: String {
        var c: UInt8 = 0
        copyBytes(to: &c, count: 1)
        return Data.mimeTypeSignatures[c] ?? "application/octet-stream"
    }
}

