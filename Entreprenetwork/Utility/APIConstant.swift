//
//  APIConstant.swift
//  Lumha
//
//  Created by Sujal Adhia on 03/10/18.
//  Copyright © 2018 LumhaaLLC. All rights reserved.
//

import UIKit
import Foundation

typealias JSONDICTIONARY = [String : Any]

//let AppName = "Entreprenetwork"
let AppName = "Werkules"
//AWS
let BaseAPIURL = "http://apiv2.werkules.com/api"
//PRODUCTION
//let BaseAPIURL =  "https://prodapiv2.werkules.com/api"
//DEVELOPMENT
//let BaseAPIURL = "http://werkules.project-demo.info/api"
//User profile help
let kUserProfileHelp = "An aspect ratio of 1:1 would work best"

let Url_Login = "\(BaseAPIURL)/user/login"
let Url_Register = "\(BaseAPIURL)/user/saveOrUpdate"
let Url_sendOTP = "\(BaseAPIURL)/user/sendOTP"
let Url_deleteUser = "\(BaseAPIURL)/user/delete"
let Url_changePassword = "\(BaseAPIURL)/user/changePassword"
let Url_forgotPasswordOTP = "\(BaseAPIURL)/user/forgotPasswordOTP"
let Url_forgotPassword = "\(BaseAPIURL)/user/forgotPassword"
let Url_logoutUser = "\(BaseAPIURL)/user/logout"
let Url_ProffesionalsAroundMe = "\(BaseAPIURL)/user/aroundMe"
let Url_NotificationOnOff = "\(BaseAPIURL)/user/notification"
let Url_sendFeedback = "\(BaseAPIURL)/user/feedback"

let Url_jobSaveUpdate = "\(BaseAPIURL)/job/saveOrUpdate"
let Url_Categories = "\(BaseAPIURL)/job/category"
let Url_addCategory = "\(BaseAPIURL)/category/add"
let Url_JobList = "\(BaseAPIURL)/job/list"
let Url_JobListOfUser = "\(BaseAPIURL)/job/listByUserId"
let Url_deleteJob = "\(BaseAPIURL)/job/delete"

let Url_jobStatusChange = "\(BaseAPIURL)/job/status"
let Url_jobMatchCategory = "\(BaseAPIURL)/job/matchCategory"
let Url_reportJob = "\(BaseAPIURL)/job/report"
let Url_JobDetails = "\(BaseAPIURL)/job/details"

let Url_NetworkList = "\(BaseAPIURL)/network/list"
let Url_AddToNetwork = "\(BaseAPIURL)/network/add"
let Url_RemoveFromNetwork = "\(BaseAPIURL)/network/delete"

let Url_ChatBeforeList = "\(BaseAPIURL)/chat/beforeList"
let Url_ChatList = "\(BaseAPIURL)/chat/list"
let Url_SendChat = "\(BaseAPIURL)/chat/save"

let Url_ActivityList = "\(BaseAPIURL)/activity/list"
let Url_SaveUpdateLike = "\(BaseAPIURL)/activity/saveOrUpdateLike"
let Url_SaveUpdateComment = "\(BaseAPIURL)/activity/saveOrUpdateComment"
let Url_DeleteComment = "\(BaseAPIURL)/comment/delete"

let Url_sendMessage = "\(BaseAPIURL)/message/save"
let Url_messageBeforeList = "\(BaseAPIURL)/message/beforeList"
let Url_messageList = "\(BaseAPIURL)/message/list"
let Url_jobListOfEnt = "\(BaseAPIURL)/message/beforeListEnt"
let Url_deleteMyChat = "\(BaseAPIURL)/message/delete"

let Url_saveReview = "\(BaseAPIURL)/review/save"
let Url_getReview = "\(BaseAPIURL)/review/listByUserId"


class APIConstant: NSObject {
    
    /// This is the Structure for API
    internal struct API {
        
        // MARK: - API URL
        
        /// Structure for URL. This will have the API end point for the server.
        struct URL {
            
            /// Live Server Base URL
            /// ````
            /// API.URL.live
            /// ````
            static let live                                  = "https://lumhaa.com:1443/lumhaaApp"
            
            /// Development Server Base URL
            /// ````
            /// API.URL.development
            /// ````
            
            /// Server Base URL
            /// ````
            /// API.URL.BASE_URL
            /// ````
            static let BASE_URL                              = API.URL.live
            
        }
        
        
        // MARK: - Basic Response keys
        
        /// Structure for API Response Keys. This will use to get the data or anything based on the key from the repsonse. Do not directly use the key rather define here and use it.
        struct Response {
            
            /// Default message key from the response
            /// ````
            /// API.Response.message
            /// ````
            static let message                                  = "message"
            
            /// Default key for Data from the response
            /// ````
            /// API.Response.data
            /// ````
            static let data                                     = "data"
            
            /// Default key for Status from the response
            /// ````
            /// API.Response.success
            /// ````
            static let success                                  = "success"
            
            /// Default key for Auth Token from the response
            /// ````
            /// API.Response.authToken
            /// ````
            static let authToken                                = "authToken"
            
            /// Default key for User from the response
            /// ````
            /// API.Response.user
            /// ````
            static let user                                     = "user"
            
            /// Default key for statusCode from the response
            /// ````
            /// API.Response.statusCode
            /// ````
            static let statusCode                               = "statusCode"
            
        }
        
        
        // MARK: - Success Failure keys
        
        /// Structure for API Response Success or Failure. This will use to check that if API has responded success or failure
        struct Check {
            
            /// Default success response
            /// ````
            /// API.Check.success
            /// ````
            static let success                                   = "true"
            
            /// Default failure response
            /// ````
            /// API.Check.failure
            /// ````
            static let failure                                   = "false"
            
            /// Default deleteAccount response
            /// ````
            /// API.Check.deleteAccount
            /// ````
            static let deleteAccount                             = "405"
            
        }
        
    }
}

