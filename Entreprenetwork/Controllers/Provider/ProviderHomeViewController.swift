//
//  ProviderHomeViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 11/01/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import Quickblox
import QuickbloxWebRTC
class ProviderHomeViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var txtSearch:UITextField!
    @IBOutlet weak var objMapView:GMSMapView!
    @IBOutlet weak var collectionObj:UICollectionView!
    @IBOutlet weak var keywordSearchColllectionView:UICollectionView!
    @IBOutlet weak var viewCollectionViewContainer:UIView!
    
    @IBOutlet weak var searchViewContainer:MyBorderView!
    var arrayOfProvidersOffer:[OfferDetail] = []
    
    @IBOutlet weak var buttonKeyword:UIButton!
    @IBOutlet weak var buttonPerson:UIButton!
    @IBOutlet weak var buttonCompany:UIButton!
    

    @IBOutlet weak var containerViewSlideCollection:UIView!
    @IBOutlet weak var containerViewSliderButton:UIButton!
    @IBOutlet weak var containerView1:UIView!
    @IBOutlet weak var containerShadowView:ShadowBackgroundView!
    @IBOutlet weak var containerView2:UIView!
    
    @IBOutlet weak var leftContraintCollectionView:NSLayoutConstraint!
    @IBOutlet weak var leadingContraintProviderContainer:NSLayoutConstraint!
    
    @IBOutlet weak var viewProviderContainerView:UIView!
    @IBOutlet weak var viewProviderContainerSearchKeyword:UILabel!
    @IBOutlet weak var viewProviderContainerDate:UILabel!
    @IBOutlet weak var viewProviderContainerReview:UILabel!
    @IBOutlet weak var viewProviderContainerProviderName:UILabel!
    @IBOutlet weak var viewProviderContainerProviderImage:UIImageView!
    
    @IBOutlet weak var buttonClearKeyword:UIButton!
    
    @IBOutlet weak var leftArrow:UIImageView!
    @IBOutlet weak var rightArrow:UIImageView!
    @IBOutlet weak var viewRight:UIView!
    @IBOutlet weak var viewLeft:UIView!
    
    @IBOutlet weak var buttonCloseCollectionView:UIButton!
    
    @IBOutlet weak var buttonBookNowTile:UIButton!
    
    var lastContentOffset: CGPoint!
    
    var currentKeyWordSearchProvider:NotifiedProviderOffer = NotifiedProviderOffer(providersDetail: [:])
    var currentKeywordSearchOffer:OfferDetail = OfferDetail.init(offerDetail: [:])

    var selectedOption:Int = 0 //0 keyword 1 person  2 company
    var selectedSearchOption:Int{
        get{
            return selectedOption
        }
        set{
            selectedOption = newValue
            //ConfigureSeleted Option
            DispatchQueue.main.async {
                self.checkForCollectionHideButtonHideShow()
                self.configureSelectedSearchOption()
            }
            
        }
    }
    var searchedkeyword = ""
    var currentSearchKeyword:String {
        get{
            return searchedkeyword
        }
        set{
            self.searchedkeyword = newValue
            //Add Floating button And Timer
//            self.isForKeywordSearch = (newValue.count > 0)

                DispatchQueue.main.async {
                    self.checkForCollectionHideButtonHideShow()

                          if self.selectedSearchOption == 0 && "\(newValue)".count > 0{
                              self.buttonClearKeyword.isHidden = false
                            self.txtSearch.text = "\(newValue)".capitalized
                          }else{
                              if self.txtSearch.text == "" {
                                  self.buttonClearKeyword.isHidden = true
                              }else{
                                  self.buttonClearKeyword.isHidden = false
                              }
                              //self.txtSearch.text = ""
                           }
                          }
            
        }
    }
    var isKeywordSearch:Bool = false
    var isForKeywordSearch:Bool{
        get{
            return isKeywordSearch
        }
        set{
            self.isKeywordSearch = newValue
            //ConfigureKeywordSearch
            self.configurePageForKeywordSearchOrOffer()
            DispatchQueue.main.async {
               // self.txtSearch.text = "\(self.currentSearchKeyword)"
                
                if self.txtSearch.text == "" {
                    self.buttonClearKeyword.isHidden = true
                }else{
                    self.buttonClearKeyword.isHidden = false
                }
                self.buttonClearKeyword.isHidden = "\(self.currentSearchKeyword)".count > 0 ? false : true
                /*if newValue{
                    self.txtSearch.text = "\(self.currentSearchKeyword)"
                    self.buttonClearKeyword.isHidden = "\(self.currentSearchKeyword)".count > 0 ? false : true
                }else{
                      self.txtSearch.text = ""
                      self.buttonClearKeyword.isHidden = true
                }*/
            }
          
//            if newValue{
//                self.addtimerWith60SecondsForFloatingOptionShow()
//            }else{
//                self.removeTimer()
//            }
        }
    }
    var regionRadius = CLLocationDistance()
    var locationManager: CLLocationManager = CLLocationManager()
    
    var currentLat = Double()
    var currentLong = Double()


    var lastSearchLatForKeyword:String = ""
    var lastSearchLngForKeyword:String = ""
    
    var isFromChatNotificationReceive:Bool = false
    var chatNotificationreceiveID:String = ""
    var chatNotificationsenderID:String = ""
    var chatNotificationProfile:String = ""
    var chatNotificationreceiveName:String = ""
    var chatNotificationToUserType:String = ""
    
    var selectedTag:Int?
    
//    var arrayOfKeywordSearchOffer:[NotifiedProviderOffer] = []

    var arrayOfKeywordSearchOffer:[OfferDetail] = []

    var searchMapPinSelectedTag:Int?
    
    
    var isFromDidselectSearchKeyword:Bool = false
    
    var manageUserDetailState:Bool = false
    
    var isFromReviewNotificationReceive:Bool = false
    
    @IBOutlet weak var viewContact:UIView!

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
    @IBOutlet weak var viewbuttonSearchThisArea:UIView!
    var isFirstTimeKeywordSearch:Bool = true
    var currentMapScale = ""

    let currentUserdefault = UserDefaults.standard


    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewbuttonSearchThisArea.isHidden = true
        self.viewProviderContainerView.contentMode = .scaleAspectFill
        self.viewProviderContainerView.clipsToBounds = true
//        self.viewProviderContainerView.layer.cornerRadius = 30.0
        self.searchViewContainer.layer.cornerRadius = 26.0
        self.searchViewContainer.clipsToBounds = true
        // Do any additional setup after loading the view.
        
        do {
              if let styleURL = Bundle.main.url(forResource: "google_map_style", withExtension: "json") {
                  self.objMapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
              } else {
                  
              }
         } catch {
           NSLog("One or more of the map styles failed to load. \(error)")
         }

        self.RegisterCell()
        

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: .providerHome, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfNewProviderAvailableNotification(notification:)), name: .newProviderAvailableProviderHome, object: nil)
    
        if self.isFromChatNotificationReceive{
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                self.pushToChatViewControllerOnNotification(receiverId: self.chatNotificationreceiveID, quickblox_id: self.chatNotificationsenderID)
            }
         }
        if self.isFromReviewNotificationReceive{
            self.reviewOfProviderNotification()
        }
        NotificationCenter.default.addObserver(self,
                                                selector: #selector(handleAppDidBecomeActiveNotification(notification:)),
                                                name: UIApplication.didBecomeActiveNotification,
                                                object: nil)
        self.setup()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfNewMessageReceiveNotification(notification:)), name: .chatUnreadCount, object: nil)

    }
    @objc func methodOfNewMessageReceiveNotification(notification:Notification){
        if let userInfo = notification.userInfo as? [String:Any]{
            print(userInfo)
            self.callAPIRequestToGetChatUnreadCount()
        }
    }
    func setup(){
        self.viewbuttonSearchThisArea.clipsToBounds = true
        self.viewbuttonSearchThisArea.layer.borderColor = UIColor.lightGray.cgColor
        self.viewbuttonSearchThisArea.layer.borderWidth = 0.7
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func handleAppDidBecomeActiveNotification(notification: Notification) {
        if UserDetail.isUserLoggedIn{
            if let strCode = UserDefaults.standard.object(forKey: "GroupReferralCode") as? String,strCode != ""{
                DispatchQueue.main.async {
                    self.calladdgroupmemberAPI(ReferralCode: strCode)
                }
                
            }
        }
    }
    func checkForCollectionHideButtonHideShow(){
         DispatchQueue.main.async {
            if self.arrayOfKeywordSearchOffer.count >  0 && self.arrayOfProvidersOffer.count > 0{
                 self.buttonCloseCollectionView.isHidden = false
             }else{
                 self.buttonCloseCollectionView.isHidden = true
                }
         }
        
     }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.mylocation()
            //self.txtSearch.setPlaceHolderColor()
            self.objMapView.delegate = self
            self.objMapView.settings.allowScrollGesturesDuringRotateOrZoom = true
            self.objMapView.settings.zoomGestures = true
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            self.objMapView.isMyLocationEnabled = true
            self.objMapView.settings.myLocationButton = false
            
        }
        
       

        self.containerView1.clipsToBounds = true
        self.containerView1.layer.cornerRadius = 20.0

        self.containerView2.clipsToBounds = true
        self.containerView2.layer.cornerRadius = 20.0

        self.containerShadowView.rounding = 20.0
        self.containerShadowView.layer.cornerRadius = 20.0
        self.containerShadowView.layoutIfNeeded()

        if self.manageUserDetailState{
            self.manageUserDetailState = false
        }else{

            if let currentUser = UserDetail.getUserFromUserDefault(){
                self.getMyJOBCountAPIRequest()
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                var delayTime = 0.0
                if let lat = self.currentUserdefault.value(forKey: KcurrentUserLocationLatitude) as? Double, let lng = self.currentUserdefault.value(forKey: KcurrentUserLocationLongitude) as? Double{
                if lat != 0.0 && lng != 0.0{
                    delayTime = 0.0
                }else{
                    delayTime = appDelegate.currentLocationDelay
                }
                }else{
                    delayTime = appDelegate.currentLocationDelay
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                    if currentUser.userRoleType == .provider{
                    if self.isFromDidselectSearchKeyword{
                        self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: self.currentSearchKeyword,isFirstTime: false)
                    }else{
                        if self.currentSearchKeyword.count > 0{
                            self.fetchProviderOfferRequestAPIRequest(searchKeyword: self.currentSearchKeyword,isFirstTime:true)
                        }else{
                            self.fetchProviderOfferRequestAPIRequest(searchKeyword: "",isFirstTime:true)
                        }
                    }
                  }
                }
              }
            }


        }

        
    }
    fileprivate var currentPage: Int = 0 {
        didSet {
            print("page at centre = \(currentPage)")
            if self.arrayOfKeywordSearchOffer.count > currentPage{
                //self.currentKeyWordSearchProvider = self.arrayOfKeywordSearchOffer[currentPage]
                self.currentKeywordSearchOffer = self.arrayOfKeywordSearchOffer[currentPage]
            }
            self.setSelectedMarkerWithUpdatedColorIndex(index: currentPage,isFromMap: true)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                let lat = Double("\(self.currentKeywordSearchOffer.jobDetail!.lat)") ?? 0.0
                let lng = Double("\(self.currentKeywordSearchOffer.jobDetail!.lng)") ?? 0.0
                let markerPosition: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:lat, longitude:lng)
                print("------- \(self.isMarkerWithinScreen(markerPosition: markerPosition))")
                if self.isMarkerWithinScreen(markerPosition: markerPosition){

                }else{
//                    let camera = GMSCameraPosition.init(latitude: lat, longitude: lng, zoom: self.objMapView.camera.zoom)
//                    self.objMapView.camera = camera
//                    self.objMapView.animate(to: camera)
                    let markerpoint = self.objMapView.projection.point(for: markerPosition)
                    print("------ \(markerpoint.x)")
                    print("------ \(markerpoint.y)")
                    var scrollX:CGFloat = 0
                    var scrollY:CGFloat = 0
                    if markerpoint.x > 0 && markerpoint.x < UIScreen.main.bounds.width{
                        if markerpoint.x > 0{
                            scrollX = 50
                        }else{
                            scrollX = -50
                        }
                    }else{
                        if markerpoint.x > 0{
                            if markerpoint.x > UIScreen.main.bounds.width{
                                scrollX =  markerpoint.x - UIScreen.main.bounds.width
                                scrollX += 50
                            }else{
                                scrollX =  markerpoint.x + 50
                            }
                        }else{
                            scrollX = markerpoint.x + -50
                        }
                    }
                    let miniMumY = self.searchViewContainer.frame.maxY
                    let maxMumY = self.viewProviderContainerView.frame.minY - 88.0
                    if markerpoint.y > miniMumY && markerpoint.y < maxMumY{
                        if markerpoint.y > miniMumY{
                            scrollY = 10
                        }else{
                            scrollY = -10
                        }
                    }else{
                        if markerpoint.y > miniMumY{
                            if markerpoint.y > maxMumY{
                                scrollY =  markerpoint.y - maxMumY
                                scrollY += 10
                            }else{
                                scrollY =  markerpoint.y + 10
                            }
                        }else{
                            scrollY = markerpoint.y + -miniMumY + -10
                        }

                    }



                    let downwards = GMSCameraUpdate.scrollBy(x: scrollX, y: scrollY)
                    self.objMapView.animate(with: downwards)

                    
                }
            }
        }
    }
    fileprivate func isMarkerWithinScreen(markerPosition: CLLocationCoordinate2D) -> Bool {
        let markerpoint = self.objMapView.projection.point(for: markerPosition)
        print(markerpoint.x)
        print(markerpoint.y)
        print(self.searchViewContainer.frame)
        print(self.viewProviderContainerView.frame)
        let miniMumY = self.searchViewContainer.frame.maxY
        let maxMumY = self.viewProviderContainerView.frame.minY - 88.0

        let region = self.objMapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: region)
        if bounds.contains(markerPosition){
            return (markerpoint.y > miniMumY && markerpoint.y < maxMumY)
        }else{
            return false
        }

    }
    fileprivate func zoomOutMapTo3PinByDefault(){
        /*
        var bounds = GMSCoordinateBounds()
        if self.arrayOfKeywordSearchOffer.count > 0{
            for objprovider in self.arrayOfKeywordSearchOffer{
                bounds =  bounds.includingCoordinate(CLLocationCoordinate2D(latitude: Double("\(objprovider.jobDetail!.lat)") ?? 0.0, longitude: Double("\(objprovider.jobDetail!.lng)") ?? 0.0))
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let update = GMSCameraUpdate.fit(bounds)//(bounds, withPadding: 200.0)
            self.objMapView.animate(with: update)
        }*/
    }
    fileprivate func ZoomOutMapForWaitingForOffer(){
        /*var bounds = GMSCoordinateBounds()
        if self.arrayOfProvidersOffer.count > 0{
            for objprovider in self.arrayOfProvidersOffer{
                bounds =  bounds.includingCoordinate(CLLocationCoordinate2D(latitude: Double("\(objprovider.jobDetail!.lat)") ?? 0.0, longitude: Double("\(objprovider.jobDetail!.lng)") ?? 0.0))
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let update = GMSCameraUpdate.fit(bounds)//(bounds, withPadding: 200.0)
            self.objMapView.animate(with: update)
        }*/
    }
    func configureSelectedSearchOption(){
        DispatchQueue.main.async {
            if self.selectedSearchOption == 0{
                if self.currentSearchKeyword.count > 0{
                    self.txtSearch.text = "\(self.currentSearchKeyword)"
                    self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(self.currentSearchKeyword)")
                    self.buttonClearKeyword.isHidden = false
                }else{
                    if self.arrayOfProvidersOffer.count > 0{
                           self.containerViewSlideCollection.isHidden = false
                           self.containerViewSliderButton.isHidden = false
                           self.hideColllectionViewandShowSlider()
                       }else{
                        self.containerViewSliderButton.isHidden = true
                           self.containerViewSlideCollection.isHidden = true
                       }
                    self.objMapView.clear()
                  //  self.txtSearch.text = ""
                    self.buttonClearKeyword.isHidden = false
                }
                if self.arrayOfProvidersOffer.count > 0 && self.isForKeywordSearch{
                    self.containerViewSlideCollection.isHidden = false
                    self.containerViewSliderButton.isHidden = false
                }else{
                    self.containerViewSlideCollection.isHidden = true
                    self.containerViewSliderButton.isHidden = true
                }
                
                self.buttonKeyword.backgroundColor = UIColor.init(hex: "08405D")
                               self.buttonPerson.backgroundColor = UIColor.init(hex: "9CB7BF")
                               self.buttonCompany.backgroundColor = UIColor.init(hex: "9CB7BF")
                               self.buttonKeyword.alpha = 1.0
                               self.buttonPerson.alpha = 1.0
                               self.buttonCompany.alpha = 1.0
            }else if self.selectedSearchOption == 1{
                 if self.arrayOfProvidersOffer.count > 0{
                                  self.objMapView.clear()
                                  self.hideColllectionViewandShowSlider()
                              }else{
                                  self.containerViewSlideCollection.isHidden = true
                                  self.containerViewSliderButton.isHidden = true
                              }
              //  self.txtSearch.text = ""
                self.buttonClearKeyword.isHidden = false
                self.buttonKeyword.backgroundColor = UIColor.init(hex: "9CB7BF")
                self.buttonPerson.backgroundColor = UIColor.init(hex: "08405D")
                self.buttonCompany.backgroundColor = UIColor.init(hex: "9CB7BF")
                self.buttonKeyword.alpha = 1.0
                self.buttonPerson.alpha = 1.0
                self.buttonCompany.alpha = 1.0
            }else if self.selectedSearchOption == 2{
                if self.arrayOfProvidersOffer.count > 0{
                     self.objMapView.clear()
                     self.hideColllectionViewandShowSlider()
                 }else{
                     self.containerViewSlideCollection.isHidden = true
                    self.containerViewSliderButton.isHidden = true
                 }
                
               // self.txtSearch.text = ""
                self.buttonClearKeyword.isHidden = true
                self.buttonKeyword.backgroundColor = UIColor.init(hex: "9CB7BF")
                self.buttonPerson.backgroundColor = UIColor.init(hex: "9CB7BF")
                self.buttonCompany.backgroundColor = UIColor.init(hex: "08405D")
                self.buttonKeyword.alpha = 1.0
                self.buttonPerson.alpha = 1.0
                self.buttonCompany.alpha = 1.0
            }else{
                 if self.arrayOfProvidersOffer.count > 0{
                     self.objMapView.clear()
                     self.hideColllectionViewandShowSlider()
                 }else{
                     self.containerViewSlideCollection.isHidden = true
                    self.containerViewSliderButton.isHidden = true
                 }
              //  self.txtSearch.text = ""
                self.buttonClearKeyword.isHidden = true
                self.buttonKeyword.backgroundColor = UIColor.init(hex: "08405D")
                self.buttonPerson.backgroundColor = UIColor.init(hex: "9CB7BF")
                self.buttonCompany.backgroundColor = UIColor.init(hex: "9CB7BF")
                self.buttonKeyword.alpha = 1.0
                self.buttonPerson.alpha = 1.0
                self.buttonCompany.alpha = 1.0
            }
        }
    }
    @objc func methodOfNewProviderAvailableNotification(notification: Notification) {
        if let userInfo = notification.userInfo as? [String:Any]{
            print(userInfo)
            if let providerID = userInfo["provider_id"]{
                self.pushToProviderDetailScreenWithProviderId(providerID: "\(providerID)")
            }
        }
    }
    func pushToProviderDetailScreenWithProviderId(providerID: String){
        self.manageUserDetailState = true
        if let objProviderDetail = self.storyboard?.instantiateViewController(withIdentifier: "ProviderDetailViewController") as? ProviderDetailViewController{
                   objProviderDetail.hidesBottomBarWhenPushed = true
                   objProviderDetail.providerID = providerID
                  objProviderDetail.showBookNowButton = true
            self.navigationController?.pushViewController(objProviderDetail, animated: true)
        }
    }
    @objc func methodOfReceivedNotification(notification: Notification) {
        //fetch offer for provider
        self.fetchProviderOfferRequestAPIRequest(searchKeyword: "")
    }
    func reviewOfProviderNotification() {
        self.manageUserDetailState = true
        if let objCustomerReviewController = UIStoryboard.profile.instantiateViewController(withIdentifier: "CustomerReviewViewController") as? CustomerReviewViewController{
            self.navigationController?.pushViewController(objCustomerReviewController, animated: true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            ExternalClass.ShowProgress()
        }
        if let lat = currentUserdefault.value(forKey: KcurrentUserLocationLatitude) as? Double, let lng = currentUserdefault.value(forKey: KcurrentUserLocationLongitude) as? Double{
            self.currentLat = lat
            self.currentLong = lng
        }

        if let appdelegate = UIApplication.shared.delegate as? AppDelegate{
            self.currentSearchKeyword = "\(appdelegate.searchKeywordProvider)"
        }

        if self.currentLat != 0.0 && self.currentLong != 0.0 && !self.manageUserDetailState {
             let location = CLLocation(latitude: self.currentLat, longitude: self.currentLong)
            let locationObj =  CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            self.objMapView.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: self.objMapView.camera.zoom))
        }


//        self.containerViewSliderButton.isHidden = true
        self.callAPIRequestToGetChatUnreadCount()
        if let currentUser = UserDetail.getUserFromUserDefault(){
            let fname = currentUser.firstname
            let lname =  currentUser.lastname
             var username = currentUser.username.removeWhiteSpaces()
            let userID = currentUser.id
            //DEVELOPER
            username = "staging_\(username)"
            //No need to add prefix on production
            //self.signUp(fullName: fname + " " + lname , email: currentUser.email, login: username, password: "quickblox", userId: userID)
        }
        if let strCode = UserDefaults.standard.object(forKey: "GroupReferralCode") as? String,strCode != ""{
            DispatchQueue.main.async {
                self.calladdgroupmemberAPI(ReferralCode: strCode)
            }
            
        }
        
        
    }
    func calculateZoomLevelBasedOnMiles(miles:Double)->Double{
        let mtr = miles * 1609.344
        let  equatorLength:Double = 40075004 // in meters
        let  widthInPixels:Double = Double(UIScreen.main.bounds.width)
        var  metersPerPixel:Double = equatorLength / 256
        var  zoomLevel:Int = 1
        while ((metersPerPixel * widthInPixels) > mtr) {
            metersPerPixel =  metersPerPixel/2
            zoomLevel += 1
        }
        return Double(zoomLevel)
    }
    @IBAction func buttonChatListSelector(sender:UIButton){
        self.pushtoChatListViewController()
    }
    func pushtoChatListViewController(){
        self.manageUserDetailState = true
        if let chatListViewController = UIStoryboard.messages.instantiateViewController(identifier: "ChatListViewController") as? ChatListViewController{
            chatListViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatListViewController, animated: true)
        }

    }
    func callAPIRequestToGetChatUnreadCount(){
        if let currentUser = UserDetail.getUserFromUserDefault(){
            guard currentUser.userRoleType == .provider else {
                return
            }
        }
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
                            APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kGETChatUnreadCount)")
                             //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                         }
                     }
                 }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.searchKeywordProvider = self.txtSearch.text ?? ""
//                appDelegate.providerHomeLat = "\(self.objMapView.camera.target.latitude)"
//                appDelegate.providerHomeLng = "\(self.objMapView.camera.target.longitude)"
            }
        }
        if self.manageUserDetailState{
            
        }else{
            self.isFromDidselectSearchKeyword = false
            self.searchMapPinSelectedTag = nil
            locationManager.stopUpdatingLocation()
            if let container = self.so_containerViewController {
                container.isSideViewControllerPresented = false
            }
//            self.arrayOfProvidersOffer.removeAll()
            
            DispatchQueue.main.async {
                self.selectedTag = nil
                self.currentSearchKeyword = ""
                self.objMapView.clear()
            }
            /*
            self.searchMapPinSelectedTag = nil
            self.locationManager.stopUpdatingLocation()
            self.objMapView.clear()*/
 
        }
       
        
       
    }
    // MARK:Call API add-group-member
    func calladdgroupmemberAPI(ReferralCode:String){
        let dict:[String:Any] = [
            "group_referral_code" : "\(ReferralCode)",
        ]
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGroupAddMember , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any], let successMsg = success["success_data"] as?[String]{
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: AppName, message: successMsg[0], preferredStyle: .alert)
                                 
                                 alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                    
                                 }))
                               alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                    UserDefaults.standard.removeObject(forKey: "GroupReferralCode")
                                 self.present(alert, animated: true, completion: nil)
                }
            }
        }){ (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String]{
                DispatchQueue.main.async {
                    UserDefaults.standard.removeObject(forKey: "GroupReferralCode")
                    if errorMessage.count > 0{
                        SAAlertBar.show(.error, message:"\(errorMessage.first!)")
                    }
                }
            }
        }
    }
    // MARK: SignUp to QuickBlox for chat
    func signUp(fullName:String ,email: String, login: String,password:String,userId: String) {
        let newUser = QBUUser()
        newUser.login = login
        newUser.fullName = fullName
//        newUser.email = email
        newUser.password = password
        QBRequest.signUp(newUser, successBlock: { [weak self] response, user in
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.getLogsAPI(userid: userId, module: "quickblox_signup", description: "Sign Up success: \(newUser.id)")
                }
                self?.login(fullName: fullName, email: email, login: login,password: password,userId: userId)
            }
            
            }, errorBlock: { [weak self] response in
                DispatchQueue.main.async {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.getLogsAPI(userid: userId, module: "quickblox_signup", description: " \(response.status.rawValue) \(response.error?.error?.localizedDescription)")
                    }
                }
                if response.status.rawValue == 422 {
                    // The user with existent login was created earlier
                    self?.login(fullName: fullName, email: email, login: login,password: password,userId: userId)
                    return
                }
        })
    }
    func disconnect(completion: QBChatCompletionBlock? = nil) {
            QBChat.instance.disconnect(completionBlock: completion)
        }
    // MARK: Login to QuickBlox for chat
    private func login(fullName: String, email: String, login: String, password: String,userId: String) {
        QBRequest.logOut(successBlock: { (response) in
            print(response)
            self.disconnect()
        }, errorBlock: { (response) in
            print(response)
        })
        QBRequest.logIn(withUserLogin: login,
                        password: password,
                        successBlock: { [weak self] response, user in
                            user.password = password
                            user.updatedAt = Date()
                            Profile.synchronize(user)
                            DispatchQueue.main.async {
                                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                            appDelegate.getLogsAPI(userid: userId, module: "quickblox_login", description: "Log In success: \(user.id)")
                                }
                            }
                            // connect to chat
                            QBChat.instance.connect(withUserID:user.id,
                                                    password: password,
                                                    completion: { [weak self] error in
                                                        if let error = error {
                                                            if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                                                // Clean profile
                                                               // Profile.clearProfile()
                                                            } else {
                                                                
                                                            }
                                                        } else {
                                                            self?.callAddQuickBloxDetail(quickbloxId:user.id)
                                                        }
                                                    })
                        }, errorBlock: { [weak self] response in
                            DispatchQueue.main.async {
                                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                            appDelegate.getLogsAPI(userid: userId, module: "quickblox_login", description: "\(response.status.rawValue) \(response.error?.error?.localizedDescription)")
                                }
                            }
                            if response.status == QBResponseStatusCode.unAuthorized {
                               
                            }
                        })
    }
    
    //MARK: API Call of Save QuickBlox Detail
    func callAddQuickBloxDetail(quickbloxId:Any){
        QBRequest.subscriptions(successBlock: { (response, subscriptions) in
                print("==== count \(subscriptions?.count)")
                  if subscriptions!.count > 0{
                    let myGroup = DispatchGroup()

                    for (index,sub) in subscriptions!.enumerated(){
                        myGroup.enter()

                        QBRequest.deleteSubscription(withID: sub.id) { (response) in
                            print("Finished \(index) Request")
                            myGroup.leave()
                        } errorBlock: { (response) in
                            print("Finished \(index) Request")
                            myGroup.leave()
                        }
                      }
                    myGroup.notify(queue: .main){
                        print("Finished All Request")
                        //API
                        self.createSubsciptionAndAddIDTOAPIRequest(quickbloxId: quickbloxId)
                    }
                  }else{
                    //API
                    self.createSubsciptionAndAddIDTOAPIRequest(quickbloxId: quickbloxId)
                    
                    
                  }
                  }) { (errorResponse) in
                  // Create new subscriciption for current device here
                    print("==== error count \(errorResponse)")
                    //API
                    self.createSubsciptionAndAddIDTOAPIRequest(quickbloxId: quickbloxId)
                  }
    }
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    func createSubsciptionAndAddIDTOAPIRequest(quickbloxId:Any){
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
                   return
               }
       
        let subscription = QBMSubscription()
        

         subscription.notificationChannel = .APNSVOIP
         subscription.deviceUDID = deviceIdentifier
        var deviceToken = Data()
        if isKeyPresentInUserDefaults(key: "deviceToken") {
            if let deviceTokenvalue = UserDefaults.standard.object(forKey: "deviceToken") as? Data{
                deviceToken = deviceTokenvalue
            }
        }
       
        subscription.deviceToken = deviceToken
        if let value =  UInt("\(quickbloxId)"){
            print("=== \(value)")
            subscription.id = value
        }
        
        
        QBRequest.createSubscription(subscription, successBlock: { (response, objects) in
            self.callAPIToRegisterQuickBlox(quickbloxId: quickbloxId)
            
        }, errorBlock: { (response) in
            self.callAPIToRegisterQuickBlox(quickbloxId: quickbloxId)
            //debugPrint("[AppDelegate] createSubscription error: \(String(describing: response.error))")
        })
    }
    func callAPIToRegisterQuickBlox(quickbloxId:Any){
        let dict:[String:Any] = [
            "quickblox_id" : "\(quickbloxId)",
        ]
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSaveQuickBloxDetail , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any]{
                
            }
        }){ (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String]{
                
            }
        }

        
    }
    /*
    func callAddQuickBloxDetail(quickbloxId:Any){
        
        let dict:[String:Any] = [
            "quickblox_id" : "\(quickbloxId)",
        ]
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kListOfProviderOnKeywordSearch , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any]{
                
            }
        }){ (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String]{
                
            }
        }
    }*/
    func centerMapOnLocation(location: CLLocation) {
        let locationObj =  CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//        CATransaction.begin()
//        CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
        DispatchQueue.main.async {
          //  self.objMapView.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: 15))
        }
        
//        CATransaction.commit()
        /*let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setCenter(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), animated: true)*/
    }
    
    func RegisterCell()  {
        self.collectionObj.register(UINib.init(nibName: "ProviderOfferCell", bundle: nil), forCellWithReuseIdentifier: "ProviderOfferCell")
        self.collectionObj.register(UINib.init(nibName: "UpdateProviderHomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UpdateProviderHomeCollectionViewCell")

        self.keywordSearchColllectionView.register(UINib.init(nibName: "KeywordResultCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "KeywordResultCollectionViewCell")
        self.keywordSearchColllectionView.register(UINib.init(nibName: "UpdateProviderHomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UpdateProviderHomeCollectionViewCell")

        self.keywordSearchColllectionView.tag = 300
        let floawLayout = UPCarouselFlowLayout()
        floawLayout.itemSize = CGSize(width: self.keywordSearchColllectionView.bounds.width - 40.0, height: self.keywordSearchColllectionView.bounds.height - 10.0)
        floawLayout.scrollDirection = .horizontal
        floawLayout.sideItemScale = 0.95
        floawLayout.sideItemAlpha = 1.0
        floawLayout.spacingMode = .fixed(spacing: 10.0)
        floawLayout.sideItemShift = 6.0
        self.keywordSearchColllectionView.collectionViewLayout = floawLayout
        self.keywordSearchColllectionView.delegate = self
        self.keywordSearchColllectionView.dataSource = self
        self.keywordSearchColllectionView.reloadData()
//        self.keywordSearchColllectionView.backgroundColor = UIColor.clear



        let floawLayoutOffer = UPCarouselFlowLayout()
        floawLayoutOffer.itemSize = CGSize(width: self.collectionObj.bounds.width - 40.0, height: self.collectionObj.bounds.height - 10.0)
        floawLayoutOffer.scrollDirection = .horizontal
        floawLayoutOffer.sideItemScale = 0.95
        floawLayoutOffer.sideItemAlpha = 1.0
        floawLayoutOffer.spacingMode = .fixed(spacing: 10.0)
        floawLayoutOffer.sideItemShift = 6.0
        self.collectionObj.collectionViewLayout = floawLayoutOffer
        self.collectionObj.reloadData()
    }
    func mylocation()   {
        DispatchQueue.main.async {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()

            // Ask for Authorisation from the User.

            // For use in foreground

            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    //MARK: - User Defined Methods
     func configurePageForKeywordSearchOrOffer(){
         DispatchQueue.main.async {

//            if self.isFromDidselectSearchKeyword{
//                self.viewProviderContainerView.isHidden = (self.arrayOfKeywordSearchOffer.count == 0)
//                self.viewCollectionViewContainer.isHidden = true
//            }else{
//                self.viewProviderContainerView.isHidden = true
//                self.viewCollectionViewContainer.isHidden = (self.arrayOfProvidersOffer.count == 0)
//            }
             if self.isForKeywordSearch{
                 if self.arrayOfKeywordSearchOffer.count > 0{

                    self.setLocationOfKeywordSearchProviderOnMap()
                 }
                 self.hideColllectionViewandShowSlider()
//                 self.showCollectionViewHideCollectionSlider()
                 self.zoomOutMapTo3PinByDefault()
             }else{
                 if self.arrayOfProvidersOffer.count > 0{
                   self.setLocationMakerOnGoogleMap()
                }
//                 self.hideColllectionViewandShowSlider()
                 self.showCollectionViewHideCollectionSlider()
                 self.ZoomOutMapForWaitingForOffer()
             }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {

                if self.isFromDidselectSearchKeyword{
                    self.buttonCloseCollectionView.isHidden = true//(self.arrayOfKeywordSearchProvider.count == 0)
                    self.containerViewSliderButton.isHidden = (self.arrayOfProvidersOffer.count == 0)
                    if self.arrayOfKeywordSearchOffer.count > 0{
                        self.keywordSearchColllectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                    }
                }else{
                    if self.arrayOfProvidersOffer.count > 0{
                        self.collectionObj.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                    }
                    self.buttonCloseCollectionView.isHidden = false //(self.arrayOfKeywordSearchProvider.count == 0)
                    self.containerViewSliderButton.isHidden = true //(self.arrayOfProvidersNotified.count == 0)
                }
            }
         }
         
     }
    //Hide CollectionView and Show Slider
    func hideColllectionViewandShowSlider(){
        UIView.transition(with: self.viewProviderContainerView, duration: 0.2,
        options: .transitionCrossDissolve,
        animations: {
          DispatchQueue.main.async {
            self.viewLeft.isHidden = true
            self.viewRight.isHidden = true
            if self.arrayOfKeywordSearchOffer.count == 0{
                self.viewProviderContainerView.isHidden = true
            }else{
                self.viewProviderContainerView.isHidden = false
            }

         }
        })
        if self.arrayOfProvidersOffer.count > 0{
            UIView.animate(withDuration: 0.2, animations: {
                  self.leftContraintCollectionView.constant = (UIScreen.main.bounds.width)
                  self.view.layoutIfNeeded()
              }) { (_) in
                  
              }
            UIView.transition(with: self.containerViewSlideCollection, duration: 0.2,
                options: .transitionCrossDissolve,
                animations: {
                   DispatchQueue.main.async {
                    self.leadingContraintProviderContainer.constant = 0//5.0
                     self.containerViewSlideCollection.isHidden = false
                    self.containerViewSliderButton.isHidden = false
                  }
            })
            
            
        }else{
            UIView.transition(with: self.containerViewSlideCollection, duration: 0.2,
                           options: .transitionCrossDissolve,
                           animations: {
                              DispatchQueue.main.async {
                                self.leadingContraintProviderContainer.constant = 0//-20.0
                               self.containerViewSlideCollection.isHidden = true
                                self.containerViewSliderButton.isHidden = true
                             }
                       })
            
            self.collectionObj.isHidden = true
        }
    }
    func showCollectionViewHideCollectionSlider(){
        
    UIView.transition(with: self.viewProviderContainerView, duration: 0.2,
         options: .transitionCrossDissolve,
         animations: {
           DispatchQueue.main.async {
             self.viewProviderContainerView.isHidden = true
          }
         })
        
        
        
        if self.arrayOfProvidersOffer.count > 0{
            
            UIView.animate(withDuration: 0.2, animations: {
                
               UIView.transition(with: self.containerViewSlideCollection, duration: 0.2,
                    options: .transitionCrossDissolve,
                    animations: {
                       DispatchQueue.main.async {
                        self.leadingContraintProviderContainer.constant = 0 //-20.0
                        self.containerViewSlideCollection.isHidden = true
                        self.containerViewSliderButton.isHidden = true
                      }
                })
                
                self.collectionObj.isHidden = false
                self.collectionObj.reloadData()
                DispatchQueue.main.async {
                    self.view.layoutIfNeeded()
                    if self.arrayOfProvidersOffer.count > 0{
                        self.collectionObj.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                    }
                    //self.collectionObj.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                }
                /*if self.arrayOfProvidersOffer.count == 1 {
                    self.leftContraintCollectionView.constant = (UIScreen.main.bounds.width - 200.0)
                }else{
                    self.leftContraintCollectionView.constant = 0
                }*/
                self.leftContraintCollectionView.constant = 0

            }) { (_) in
                
            }
        }else{
             UIView.transition(with: self.containerViewSlideCollection, duration: 0.2,
                                      options: .transitionCrossDissolve,
                                      animations: {
                                         DispatchQueue.main.async {
                                            self.leadingContraintProviderContainer.constant = 0 //-20.0
                                          self.containerViewSlideCollection.isHidden = true
                                            self.containerViewSliderButton.isHidden = true
                                        }
                                  })
            self.collectionObj.isHidden = true
        }
    }
    func setLocationMakerOnGoogleMap(){
        self.objMapView.clear()
        for (index, obj) in self.arrayOfProvidersOffer.enumerated(){
            if let objJOBdetail = obj.jobDetail{
                print(objJOBdetail.lat)
                print(objJOBdetail.lng)
                var latitudeString = "\(objJOBdetail.lat)"
                var longitudeString = "\(objJOBdetail.lng)"
                
                let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((latitudeString as NSString).doubleValue), longitude: Double((longitudeString as NSString).doubleValue))
//                                         let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15.0)
//                                         self.objMapView.camera = camera
//                                         self.objMapView.animate(to: camera)
                let locationObj =  CLLocationCoordinate2DMake(location.latitude, location.longitude)
//                CATransaction.begin()
//                CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
                DispatchQueue.main.async {
//                    self.objMapView.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: self.objMapView.camera.zoom))
                }
//                CATransaction.commit()
                                         let marker = GMSMarker(position: location)
                                         marker.userData = index
                                         let objView = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 100, height: 30.0)))
                                         objView.backgroundColor = .black
                                            
                                            if var strRating = obj.customerDetail?.rating{
                                                if let pi: Double = Double("\(strRating)"){
                                                      let rating = String(format:"%.1f", pi)
                                                      strRating = "\(rating)"
                                                  }

                                                if let jobdetail = obj.jobDetail{
                                                    if let pi: Double = Double("\(jobdetail.askingPrice)"){
                                                        let value = String(format:"%.2f", pi)
                                                    marker.iconView = ProviderCustomMarker.instanceFromNibUpdate(withprice:"\(value)")
                                                        marker.map = self.objMapView
                                                    }
                                                }
                                            }
                                          
                                           

            }
            
        }
        /*
        do{
            if let _ = self.selectedTag{
               self.setProviderLocationMakerOnGoogleMapWithUpdatedColorIndex(index: self.selectedTag!)
            }else{
                self.setCenterToCurrentLocation()
            }
            
        }*/
        
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways ||  manager.authorizationStatus == .authorizedWhenInUse{
            locationManager.startUpdatingLocation()
            self.objMapView.isMyLocationEnabled = true
            self.objMapView.settings.myLocationButton = false
//          if self.currentSearchKeyword.count > 0{
//              self.fetchProviderOfferRequestAPIRequest(searchKeyword: self.currentSearchKeyword,isFirstTime:true)
//          }else{
//              self.fetchProviderOfferRequestAPIRequest(searchKeyword: "",isFirstTime:true)
//          }
        }
    }

    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse{
              locationManager.startUpdatingLocation()
              self.objMapView.isMyLocationEnabled = true
              self.objMapView.settings.myLocationButton = false
            if self.currentSearchKeyword.count > 0{
                self.fetchProviderOfferRequestAPIRequest(searchKeyword: self.currentSearchKeyword,isFirstTime:true)
            }else{
                self.fetchProviderOfferRequestAPIRequest(searchKeyword: "",isFirstTime:true)
            }

          }
      }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            var strLocation_debug = "Provider - step_1     -       \(self.currentLat)    -     \(self.currentLong)   -   \n"
            if locations.count > 0{
                strLocation_debug += "step_2     -       \(locations.count)     -      \n"
                let latestLocation: AnyObject = locations.last!
                let mystartLocation = latestLocation as! CLLocation
                print(self.currentLat)
                print(self.currentLong)
                if self.currentLat == 0.0 && self.currentLong == 0.0 {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.providerHomeLat = "\(mystartLocation.coordinate.latitude)"
                        appDelegate.providerHomeLng = "\(mystartLocation.coordinate.longitude)"
                    }
                        strLocation_debug += "step_3     -       \n"
                        self.mylocation()
                        strLocation_debug += "step_4     -      \(mystartLocation.coordinate.latitude)     -   \(mystartLocation.coordinate.longitude)      - \n"
                        let locationObj =  CLLocationCoordinate2DMake(mystartLocation.coordinate.latitude, mystartLocation.coordinate.longitude)
                        self.objMapView.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: Float(self.calculateZoomLevelBasedOnMiles(miles: 20.0))))
                }
                if mystartLocation.coordinate.latitude == 0.0 && mystartLocation.coordinate.longitude == 0.0 {
                    strLocation_debug += "step_5     -       \n"
                    self.mylocation()
                }else{
                    strLocation_debug += "step_6     -       \(mystartLocation.coordinate.latitude)      -        \(mystartLocation.coordinate.longitude)    - \n"
                    self.currentLat = mystartLocation.coordinate.latitude
                    self.currentLong = mystartLocation.coordinate.longitude
                    self.currentUserdefault.setValue(self.currentLat, forKey: KcurrentUserLocationLatitude)
                    self.currentUserdefault.setValue(self.currentLong, forKey: KcurrentUserLocationLongitude)
                    self.currentUserdefault.synchronize()
                }
            }else{
                strLocation_debug += "step_7     -       \n"

            }
            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                return
            }
            let dict = [
                       "user_id": "\(currentUser.id)",
                       "log_module" : "location",
                       "log_description" : "\(strLocation_debug)",
                       "log_platform" : "ios"
                ]
            /*
            APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSaveLog , parameter: dict as [String:AnyObject], isHudeShow: false, success: { (responseSuccess) in

            }) { (responseFail) in

            }*/
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
            return
        }
        let dict = [
                   "user_id": "\(currentUser.id)",
                   "log_module" : "location",
            "log_description" : "P Step 3 Fail Issue with location \(error.localizedDescription)",
                   "log_platform" : "ios"
            ]
        /*
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSaveLog , parameter: dict as [String:AnyObject], isHudeShow: false, success: { (responseSuccess) in

        }) { (responseFail) in

        }*/
    }
    //GET PROVIDER OFFER REQUEST
    func fetchProviderOfferRequestAPIRequest(searchKeyword:String,isFirstTime:Bool = false){
        DispatchQueue.main.async {
            ExternalClass.ShowProgress()
        }
        var dict:[String:Any] = [:]
        dict["is_provider_home"] = true

        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kFetchProviderOfferHome , parameter: dict as? [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                ExternalClass.ShowProgress()
            }
            if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [[String:Any]]{
                            self.arrayOfProvidersOffer.removeAll()
                                  if userInfo.count > 0 {
                                    
                                    for obj in userInfo{
                                        let objOffer = OfferDetail.init(offerDetail: obj)
                                        self.arrayOfProvidersOffer.append(objOffer)
                                    }
                                    DispatchQueue.main.async {
                                        
                                        self.setLocationMakerOnGoogleMap()
                                        self.ZoomOutMapForWaitingForOffer()

                                        if self.arrayOfProvidersOffer.count > 0 && self.currentSearchKeyword.count == 0{
                                            self.showCollectionViewHideCollectionSlider()
                                        }else if self.arrayOfProvidersOffer.count > 0 && self.currentSearchKeyword.count > 0{
                                            self.showCollectionViewHideCollectionSlider()
//                                            self.hideColllectionViewandShowSlider()
                                        }
                                        //self.viewLeft.isHidden = true
                                        //self.viewRight.isHidden = (userInfo.count > 2) ? false : true
                                        
                                        self.collectionObj.reloadData()
                                        self.collectionObj.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                                    }
                                  }
                                  
                                   
                                 }else{
                                     DispatchQueue.main.async {
                                       //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                     }
                                 }
            //self.getMyJOBCountAPIRequest()
            self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(searchKeyword)",isFirstTime: isFirstTime)
                             }) { (responseFail) in
                              
                           if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String]{
                                  
                                  DispatchQueue.main.async {
                                      if errorMessage.count > 0{
                                          SAAlertBar.show(.error, message:"\(errorMessage.first!)".localizedLowercase)
                                      }
                                  }
                              }else{
                                     DispatchQueue.main.async {
                                        APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kFetchProviderOfferHome)")
                                        // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                     }
                                 }
                             }
    }
    func callAPIRequestToGetProviderBasedOnSearchKeyword(keyword:String,latitude:String = "",longitude:String = "",isFirstTime:Bool = false){
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                ExternalClass.ShowProgress()
            }
            if let currentUser = UserDetail.getUserFromUserDefault(){
                guard currentUser.userRoleType == .provider else {
                    return
                }
            }
                var dict:[String:Any] = [
                    "keyword" : "\(keyword)",
                    "lat" : "\(latitude)",
                    "lng" : "\(longitude)",
                    "left_topcorner" : "\(self.objMapView.projection.visibleRegion().farLeft.getCommaSeperatedLatLongString())",
                    "right_topcorner": "\(self.objMapView.projection.visibleRegion().farRight.getCommaSeperatedLatLongString())",
                    "left_bottomcorner": "\(self.objMapView.projection.visibleRegion().nearLeft.getCommaSeperatedLatLongString())",
                    "right_bottomcorner": "\(self.objMapView.projection.visibleRegion().nearRight.getCommaSeperatedLatLongString())",
                    "is_first_time" : isFirstTime
                ]
        if latitude.count > 0 && longitude.count > 0{
            self.lastSearchLatForKeyword = "\(latitude)"
            self.lastSearchLngForKeyword = "\(longitude)"
        }else{
            dict["lat"] = "\(self.currentLat)"
            dict["lng"] =  "\(self.currentLong)"
            self.lastSearchLatForKeyword = "\(self.currentLat)"
            self.lastSearchLngForKeyword = "\(self.currentLong)"
        }
//            guard self.currentLat == 0.0 && self.currentLong == 0.0 else {
//                DispatchQueue.main.async {
//                    SAAlertBar.show(.error, message: "Your Location is disable please enable it from settings.")
//                }
//                return
//            }
        self.isFirstTimeKeywordSearch = isFirstTime
        self.lastSearchLatForKeyword = "\(latitude)"
        self.lastSearchLngForKeyword = "\(longitude)"
        self.currentMapScale = "\(self.objMapView.camera.zoom)"

        // kListOfProviderOnKeywordSearch
                APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString: kListOfJOBBasedOnKeyword, parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                    
                    if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [[String:Any]]{
                                if let searchKeyword = success["search_keyword"],!(searchKeyword is NSNull){
                                    self.currentSearchKeyword = keyword.count  >  0 ? "\(searchKeyword)" : ""
                                }else{
                                    self.currentSearchKeyword = ""
                                }
                        DispatchQueue.main.async {
                            
                            if isFirstTime{
                                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                        var delayTime = 1.0
                                        if let lat = self.currentUserdefault.value(forKey: KcurrentUserLocationLatitude) as? Double, let lng = self.currentUserdefault.value(forKey: KcurrentUserLocationLongitude) as? Double{
                                            if lat != 0.0 && lng != 0.0{
                                                delayTime = 1.0
                                            }else{
                                                delayTime = appDelegate.currentLocationDelay
                                            }
                                        }else{
                                            delayTime = appDelegate.currentLocationDelay
                                        }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                                        if self.currentLat != 0.0 && self.currentLong != 0.0{
                                            let userLocation = CLLocationCoordinate2D.init(latitude: self.currentLat, longitude: self.currentLong)
                                            if let mileScale = success["mile_scale"],let doubleMileScale = Double("\(mileScale)"){
                                                let cirlce = GMSCircle(position: userLocation, radius: doubleMileScale*1609.344)
                                                cirlce.fillColor = UIColor.clear
                                                cirlce.strokeWidth = 0
                                                cirlce.map = self.objMapView
                                                let update = GMSCameraUpdate.fit(cirlce.bounds())
                                                self.objMapView.animate(with: update)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                    self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: self.currentSearchKeyword)
                                                }
                                            }
                                        }
                                    }
                                }
                            }else{
                            
                                if arrayOfJOB.count > 0{

                                    self.arrayOfKeywordSearchOffer.removeAll()

                                    for objJOb in arrayOfJOB{
                                        let notifyProvider = OfferDetail.init(offerDetail: objJOb)
                                           //if self.objGoogleMap.projection.contains(location){
                                                    self.arrayOfKeywordSearchOffer.append(notifyProvider)
                                          //}
                                        }
                                        if self.isFromDidselectSearchKeyword{ //for keyword search
                                            self.objMapView.clear()
                                            if (self.arrayOfProvidersOffer.count > 0 || self.arrayOfProvidersOffer.count == 0) && self.arrayOfKeywordSearchOffer.count > 0{
                                                if isFirstTime{
                                                    self.zoomOutMapTo3PinByDefault()
                                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                                                        self.currentPage = 0
                                                    }
                                                }else{
                                                    if self.arrayOfKeywordSearchOffer.count > 0{
                                                        self.currentKeywordSearchOffer = self.arrayOfKeywordSearchOffer[0]
                                                    }
                                                    self.setSelectedMarkerWithUpdatedColorIndex(index: 0,isFromMap: true)
                                                }
                                                self.hideColllectionViewandShowSlider()
                                                
                                                self.keywordSearchColllectionView.reloadData()
                                                self.keywordSearchColllectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredHorizontally, animated: true)

                                            }else if self.arrayOfProvidersOffer.count > 0 && self.arrayOfKeywordSearchOffer.count == 0{
                                                self.showCollectionViewHideCollectionSlider()
                                                self.keywordSearchColllectionView.reloadData()
                                                self.collectionObj.reloadData()
                                            }else{

                                            }
                                        }else{
                                                if self.arrayOfProvidersOffer.count > 0{
                                                    self.showCollectionViewHideCollectionSlider()
                                                }else{
                                                    if self.arrayOfKeywordSearchOffer.count > 0{
                                                        if isFirstTime{
                                                            self.zoomOutMapTo3PinByDefault()
                                                            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                                                                self.currentPage = 0
                                                            }
                                                        }else{
                                                            if self.arrayOfKeywordSearchOffer.count > 0{
                                                                self.currentKeywordSearchOffer = self.arrayOfKeywordSearchOffer[0]
                                                            }
                                                            self.setSelectedMarkerWithUpdatedColorIndex(index: 0,isFromMap: true)
                                                        }
                                                        self.hideColllectionViewandShowSlider()
                                                        self.keywordSearchColllectionView.reloadData()
                                                        self.keywordSearchColllectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredHorizontally, animated: true)

                                                    }
                                                }
                                            self.keywordSearchColllectionView.reloadData()
                                            self.collectionObj.reloadData()
                                        }
                            }else{
                                print("------- \(self.isFromDidselectSearchKeyword)")
                                self.arrayOfKeywordSearchOffer.removeAll()
                                self.keywordSearchColllectionView.reloadData()
                                if self.isFromDidselectSearchKeyword{
                                    if self.arrayOfProvidersOffer.count > 0{
                                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                            self.objMapView.clear()
                                            self.viewCollectionViewContainer.isHidden = true
                                            self.containerViewSliderButton.isHidden = false
                                        }
                                    }else{
                                        self.collectionObj.reloadData()
                                    }
                                }else{
                                    self.collectionObj.reloadData()
                                }
                            }
                        }
                        }
                                /*
                               self.isForKeywordSearch = arrayOfJOB.count > 0
                                DispatchQueue.main.async {
                                    if self.isFromDidselectSearchKeyword{
                                        if self.arrayOfProvidersOffer.count > 0 && arrayOfJOB.count > 0 {
                                            self.hideColllectionViewandShowSlider()
                                        }else if self.arrayOfProvidersOffer.count > 0 && arrayOfJOB.count == 0 {
                                            self.showCollectionViewHideCollectionSlider()
                                        }
                                    }else{
                                        DispatchQueue.main.async {
                                            if self.arrayOfProvidersOffer.count > 0{
                                                self.isForKeywordSearch = false
                                                
                                            }else{
                                                self.hideColllectionViewandShowSlider()
                                                
                                            }
                                            self.collectionObj.reloadData()
                                        }
                                    }
                                  
                                 }
                        
                                if arrayOfJOB.count > 0 {
                                    self.arrayOfKeywordSearchOffer.removeAll()
                                    for objJOb in arrayOfJOB{

                                        let notifyProvider = OfferDetail.init(offerDetail: objJOb)
                                        self.arrayOfKeywordSearchOffer.append(notifyProvider)
                                    }
                                    /*
                                    self.arrayOfKeywordSearchOffer.removeAll()
                                    for objJOb in arrayOfJOB{
                                        
                                        let notifyProvider = NotifiedProviderOffer.init(providersDetail: objJOb)
                                        self.arrayOfKeywordSearchOffer.append(notifyProvider)
                                    }*/
                                    
                                    DispatchQueue.main.async {
                                     
                                        //add marker on google map
                                        //self.setLocationOfKeywordSearchProviderOnMap()

                                        self.zoomOutMapTo3PinByDefault()
                                        /*
                                        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                                            self.currentPage = 0
                                        }*/
                                        self.keywordSearchColllectionView.reloadData()
                                        self.keywordSearchColllectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                                        self.collectionObj.reloadData()

                                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                                            if let _ = self.searchMapPinSelectedTag{
                                                self.setSelectedMarkerWithUpdatedColorIndex(index: self.searchMapPinSelectedTag!,isFromMap: true)
                                            }else{
                                                self.setSelectedMarkerWithUpdatedColorIndex(index: 0,isFromMap: true)
                                            }
                                        }
                                    }
                                }else{
                                     //Clear All
                                    
                                }*/
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

                                    APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kListOfJOBBasedOnKeyword)")
                                     //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                   }
                               }
                           }
    }
        
    }
    @IBAction func searchTileSelector(button:UIButton){
        let latitudeString = "\(self.currentKeywordSearchOffer.jobDetail!.lat)"
        let longitudeString = "\(self.currentKeywordSearchOffer.jobDetail!.lng)"
             let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((latitudeString as NSString).doubleValue), longitude: Double((longitudeString as NSString).doubleValue))
//             let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 18)
//             //UIView.animate(withDuration: 0.5) {
//                 self.objMapView.camera = camera
//                 self.objMapView.animate(to: camera)
//            // }
        let locationObj =  CLLocationCoordinate2DMake(location.latitude, location.longitude)
//        CATransaction.begin()
//        CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
        DispatchQueue.main.async {
            self.objMapView.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: 15))
        }
        
//        CATransaction.commit()
     }
    func setProviderLocationMakerOnGoogleMapWithUpdatedColorIndex(index:Int,isFromMap:Bool = false){
        if let currentUser = UserDetail.getUserFromUserDefault(){
            guard currentUser.userRoleType == .provider else {
                return
            }
        }
        if self.arrayOfProvidersOffer.count > index{
            self.objMapView.clear()
        }
        for (newindex, obj) in self.arrayOfProvidersOffer.enumerated(){
            if let objJOBdetail = obj.jobDetail{
                print(objJOBdetail.lat)
                print(objJOBdetail.lng)
                var latitudeString = "\(objJOBdetail.lat)"
                var longitudeString = "\(objJOBdetail.lng)"
                
                let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((latitudeString as NSString).doubleValue), longitude: Double((longitudeString as NSString).doubleValue))
                                         let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: isFromMap ?  self.objMapView.camera.zoom:18)
                                         //self.objMapView.camera = camera
                                         //self.objMapView.animate(to: camera)
                                         
                                         let marker = GMSMarker(position: location)
                                         marker.zIndex = newindex == index ? 1 : 0
                                         marker.userData = newindex
                                         let objView = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 100, height: 30.0)))
                                         objView.backgroundColor = .black
                                            
                                            if var strRating = obj.customerDetail?.rating{
                                                if let pi: Double = Double("\(strRating)"){
                                                      let rating = String(format:"%.1f", pi)
                                                      strRating = "\(rating)"
                                                  }
                                                if let customerDetail = obj.customerDetail,let jobdetail = obj.jobDetail{
                                                  //let customerMarker = CustomMarker.instanceFromNib(withName: "\(customerDetail.firstname) \(customerDetail.lastname)", rating: "\(strRating)")
                                                    if let pi: Double = Double("\(jobdetail.askingPrice)"){
                                                        let value = String(format:"%.2f", pi)

                                                    let customerMarker = ProviderCustomMarker.instanceFromNibUpdate(withprice: "\(value)")

                                                    print(" === \(newindex)")
                                                    print(" === \(index)")
                                                 if newindex == index{
                                                    if !isFromMap{
                                                            self.objMapView.camera = camera
                                                            self.objMapView.animate(to: camera)
                                                    }else{
                                                     //   self.setCenterToCurrentLocation()
                                                    }
                                                    customerMarker.imageView.tintColor = UIColor.init(hex: "244355")
                                                }else{
                                                    customerMarker.imageView.tintColor = UIColor.init(hex: "F21600")
                                                }

                                                   marker.iconView = customerMarker
                                                }
                                                }
                                            }
                                          
                                           
                                         marker.map = self.objMapView
            }
            
        }
        
        
    }
    func setSelectedMarkerWithUpdatedColorIndex(index:Int,isFromMap:Bool = false){
        if self.arrayOfKeywordSearchOffer.count > index{
           //let objProvider = self.arrayOfKeywordSearchOffer[index]
           //self.currentKeyWordSearchProvider = objProvider
            self.currentKeywordSearchOffer = self.arrayOfKeywordSearchOffer[index]
           //ShowKeyword Search Provider detail
           //self.showKeywordSearchProviderView()
           self.objMapView.clear()
                      
            for (newindex, obj) in self.arrayOfKeywordSearchOffer.enumerated(){
                let latitudeString = "\(obj.jobDetail!.lat)"
                let longitudeString = "\(obj.jobDetail!.lng)"
                             
                                  print(latitudeString)
                                  print(latitudeString)
                                            let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((latitudeString as NSString).doubleValue), longitude: Double((longitudeString as NSString).doubleValue))
                                            let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: isFromMap ?  self.objMapView.camera.zoom:18)
                                            
                                            
                                            let marker = GMSMarker(position: location)
                                            marker.userData = newindex
                                            marker.zIndex = newindex == index ? 1:0
                                            let objView = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 100, height: 30.0)))
                                            objView.backgroundColor = .black
                                              var strRating = "\(obj.rating)"
                                              if let pi: Double = Double("\(obj.rating)"){
                                                  let rating = String(format:"%.1f", pi)
                                                  strRating = "\(rating)"
                                              }
                if let pi: Double = Double("\(obj.jobDetail!.askingPrice)"){
                    let value = String(format:"%.2f", pi)

                let customerMarker = ProviderCustomMarker.instanceFromNibUpdate(withprice: "\(value)")
                                    if newindex == index{
                                        if !isFromMap{
                                           // UIView.animate(withDuration: 0.5) {
                                                self.objMapView.camera = camera
                                                self.objMapView.animate(to: camera)
                                            //}
                                        }else{
                                            //self.setCenterToCurrentLocation()
                                        }
                                        customerMarker.imageView.tintColor = UIColor.init(hex: "244355")
                                    }else{
                                        customerMarker.imageView.tintColor = UIColor.init(hex: "F21600")
                                    }
                                  marker.iconView = customerMarker//CustomMarker.instanceFromNib(withName: "\(self.currentSearchKeyword)", rating: "\(strRating)")
                                  marker.map = self.objMapView
                }
                }
        }
    }
    func setLocationOfKeywordSearchProviderOnMap(){
        
        self.objMapView.clear()
                   
                for (index, obj) in self.arrayOfKeywordSearchOffer.enumerated(){
                    var latitudeString = "\(obj.jobDetail!.lat)"
                    var longitudeString = "\(obj.jobDetail!.lng)"
                   
                        print(latitudeString)
                        print(latitudeString)
                    let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((latitudeString as NSString).doubleValue), longitude: Double((longitudeString as NSString).doubleValue))
//                                  let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15.0)
//                                  self.objMapView.camera = camera
//                                  self.objMapView.animate(to: camera)
                    //Map Animation
                    let locationObj =  CLLocationCoordinate2DMake(location.latitude, location.longitude)
                    //CATransaction.begin()
                    DispatchQueue.main.async {
//                        self.objMapView.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: 15))
                    }
                    //CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
                    //CATransaction.commit()
                    
                    let marker = GMSMarker(position: location)
                    marker.userData = index
                    let objView = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 100, height: 30.0)))
                    objView.backgroundColor = .black
                    var strRating = "\(obj.rating)"
                    if let pi: Double = Double("\(obj.rating)"){
                        let rating = String(format:"%.1f", pi)
                        strRating = "\(rating)"
                    }

                    if let jobdetail = obj.jobDetail{
                        if let pi: Double = Double("\(jobdetail.askingPrice)"){
                            let value = String(format:"%.2f", pi)
                            marker.iconView = ProviderCustomMarker.instanceFromNibUpdate(withprice: "\(value)")
                            marker.map = self.objMapView
                        }
                    }


                    }
                  
        do{
//            self.setCenterToCurrentLocation()
        }
    }
    func getMyJOBCountAPIRequest(){
        DispatchQueue.main.async {
            ExternalClass.ShowProgress()
        }
        APIRequestClient.shared.sendAPIRequest(requestType: .GET, queryString:kGETProviderMyJOBCount , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                ExternalClass.ShowProgress()
            }
                 if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                                    DispatchQueue.main.async {
                                        /*
                                         accept job : green
                                        send_offer : yellow*/
                                        if let objTabView = self.navigationController?.tabBarController as? ProviderTabController{
                                            
                                            if let acceptjob = userInfo["accept_job"] as? Int,let sendOffer = userInfo["send_offer"] as? Int{
                                               if acceptjob > 0 && sendOffer == 0{
                                                   //green
                                                    objTabView.addGreenAnimatedCustomView()
                                               }else if acceptjob == 0 && sendOffer > 0 {
                                                   //yellow
                                                    objTabView.addYellowAnimatedCustomView()
                                               }else if acceptjob > 0 && sendOffer > 0{
                                                   //green and yellow
                                                    objTabView.addAnimatedCustomView()
                                               }else if acceptjob == 0 && sendOffer == 0{
                                                   //Clear
                                                   objTabView.removeCustomView()
                                               }else{
                                                   //Clear
                                                   objTabView.removeCustomView()
                                               }
                                            }else{
                                                //Clear
                                                objTabView.removeCustomView()
                                            }
                                        }
                                       
                                       
                                        
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
                                    APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kGETProviderMyJOBCount)")
                                     //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                   }
                               }
                           }
    }
    // MARK: - Selector Methods
    @IBAction func buttonSearchThisArea(sender:UIButton){
        DispatchQueue.main.async {
            self.isFromDidselectSearchKeyword = true
            self.objMapView.clear()
            self.viewProviderContainerView.isHidden = true
            self.viewCollectionViewContainer.isHidden  = true
//            self.keywordSearchColllectionView.reloadData()
            self.viewbuttonSearchThisArea.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: self.currentSearchKeyword, latitude: self.lastSearchLatForKeyword, longitude: self.lastSearchLatForKeyword, isFirstTime: false)
            }

        }
    }
    @IBAction func buttonLeftScrollSelector(sender:UIButton){
        print("==== \(self.collectionObj.contentOffset.x)")
            DispatchQueue.main.async {
                if self.collectionObj.contentOffset.x == 0 || self.collectionObj.contentOffset.x - 360.0 <= 0.0{
                    DispatchQueue.main.async {
                        self.viewLeft.isHidden = true
                        self.viewRight.isHidden = true //(self.arrayOfProvidersOffer.count > 2) ?  false : true
                        self.collectionObj.setContentOffset(CGPoint.zero, animated: true)
                    }
                }else{
                    print(self.collectionObj.contentOffset.x)
                    self.collectionObj.setContentOffset(CGPoint(x: self.collectionObj.contentOffset.x-180.0, y: self.collectionObj.contentOffset.y), animated: true)
                    self.checkForHideShowRightLeftScrollButton()
                }
                
                
                
            }
        }
    func checkForHideShowRightLeftScrollButton(){
        
        print(self.collectionObj.contentOffset.x)
        print(self.collectionObj.contentSize.width)
        print(self.collectionObj.frame.size.width)
        
        
        if self.collectionObj.contentOffset.x + 180 >= (self.collectionObj.contentSize.width - self.collectionObj.frame.size.width) || self.collectionObj.contentOffset.x >= (self.collectionObj.contentSize.width - self.collectionObj.frame.size.width){
            
             print("riched right")
             DispatchQueue.main.async {
                 self.viewRight.isHidden = true
                 self.viewLeft.isHidden = true //(self.arrayOfProvidersOffer.count > 2) ?  false : true
             }
        }else if self.collectionObj.contentOffset.x == 0 || self.collectionObj.contentOffset.x - 180 < 0.0{
                 DispatchQueue.main.async {
                     self.viewLeft.isHidden = true
                     self.viewRight.isHidden = true //(self.arrayOfProvidersOffer.count > 2) ?  false : true
                 }
                 print("riched left")
             
         }else{
              DispatchQueue.main.async {
                  self.viewLeft.isHidden = true//(self.arrayOfProvidersOffer.count > 2) ?  false : true
                  self.viewRight.isHidden = true//(self.arrayOfProvidersOffer.count > 2) ?  false : true
              }
          }
     }
     @IBAction func buttonRightScrollSelector(sender:UIButton){
        if self.collectionObj.contentOffset.x + 360.0 >= (self.collectionObj.contentSize.width - self.collectionObj.frame.size.width) || self.collectionObj.contentOffset.x >= (self.collectionObj.contentSize.width - self.collectionObj.frame.size.width){
            DispatchQueue.main.async {
                self.viewRight.isHidden = true
                self.viewLeft.isHidden = true //(self.arrayOfProvidersOffer.count > 2) ?  false : true
                self.collectionObj.setContentOffset(CGPoint(x: self.collectionObj.contentSize.width - self.collectionObj.frame.size.width, y: self.collectionObj.contentOffset.y), animated: true)

            }
        }else{
            DispatchQueue.main.async {
                print(self.collectionObj.contentOffset.x)
               self.collectionObj.setContentOffset(CGPoint(x: self.collectionObj.contentOffset.x+180.0, y: self.collectionObj.contentOffset.y), animated: true)
               self.checkForHideShowRightLeftScrollButton()
            }
        }
         
     }

    @IBAction func buttonClearKeywordSelector(sender:UIButton){
        DispatchQueue.main.async {
            if let appdelegate = UIApplication.shared.delegate as? AppDelegate{
                appdelegate.searchKeywordProvider = ""
            }
            self.arrayOfKeywordSearchOffer.removeAll()
            self.keywordSearchColllectionView.reloadData()
            self.objMapView.clear()
            self.txtSearch.text = ""
           self.buttonClearKeyword.isHidden = true
            DispatchQueue.main.asyncAfter(deadline:  .now()+0.5) {
                self.callClearKeywordAPIRequest()
            }
           
            if self.currentLat != 0.0 && self.currentLong != 0.0 {
                 let location = CLLocation(latitude: self.currentLat, longitude: self.currentLong)
                let locationObj =  CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                self.objMapView.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: self.objMapView.camera.zoom))

            }
        }
    }
    func callClearKeywordAPIRequest(){
       
                
                APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kClearJOBKeyword , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                    
                    if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [String]{
                                          DispatchQueue.main.async {
                                              if arrayOfJOB.count > 0{
                                                  SAAlertBar.show(.error, message:"\(arrayOfJOB.first!)".localizedLowercase)
                                              }
                                             
                                            self.objMapView.clear()
                                          }
                        self.fetchProviderOfferRequestAPIRequest(searchKeyword: "",isFirstTime: true)
                        
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
                                    APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kClearJOBKeyword)")
                                      // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                   }
                               }
                           }
    }
    @IBAction func buttonContactProviderCard(sender:UIButton){
        //self.self.pushtoChatViewControllerWith(provider:self.currentKeyWordSearchProvider)
    }
    @IBAction func buttonProviderDetailProviderCard(sender:UIButton){
        
        //self.pushtoProviderDetailFromProviderCard(provider: self.currentKeyWordSearchProvider, providerID: self.currentKeyWordSearchProvider.providerID)
    }
    func pushtoProviderDetailFromProviderCard(provider:NotifiedProviderOffer,providerID:String){
        self.manageUserDetailState = true
        if let objProviderDetail = self.storyboard?.instantiateViewController(withIdentifier: "ProviderDetailViewController") as? ProviderDetailViewController{
                   objProviderDetail.hidesBottomBarWhenPushed = true
                   objProviderDetail.providerID = providerID
                
                   objProviderDetail.currentProvider = provider
                   objProviderDetail.isFromSearchPersonCompany = false
                   self.navigationController?.pushViewController(objProviderDetail, animated: true)
               }
    }
    func pushtoChatViewControllerWith(provider:NotifiedProviderOffer){
        self.isFromDidselectSearchKeyword = false
        self.manageUserDetailState = true
            if let chatViewConroller = UIStoryboard.messages.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC{
                chatViewConroller.hidesBottomBarWhenPushed = true
             
                 chatViewConroller.strReceiverName = "\(provider.businessName)"
                 chatViewConroller.strReceiverProfileURL = "\(provider.businessLogo)"
                 if let id = provider.customerDetail["id"]{
                   chatViewConroller.receiverID = "\(id)"
                 }else{
                     chatViewConroller.receiverID = "\(provider.userID)"
                     print(provider.userID)
                 }
                if let qbuserId = provider.customerDetail["quickblox_id"]{
                    chatViewConroller.senderID = "\(qbuserId)"
                }
                chatViewConroller.toUserTypeStr = "provider"
                chatViewConroller.isForCustomerToProvider = true
                self.navigationController?.pushViewController(chatViewConroller, animated: true)
            }
        }
       @IBAction func buttonKeywordSelector(sender:UIButton){
           DispatchQueue.main.async {
               self.selectedSearchOption = 0
           }
       }
       @IBAction func buttonPersonSelector(sender:UIButton){
              DispatchQueue.main.async {
                           self.selectedSearchOption = 1
                     }
          }
       @IBAction func buttonCompanySelector(sender:UIButton){
              DispatchQueue.main.async {
                         self.selectedSearchOption = 2
                     }
          }
    @IBAction func buttonRecenterDirectionSelector(sender:UIButton){
         if self.currentLat != 0.0 && self.currentLong != 0.0 {
            DispatchQueue.main.async {
                self.viewbuttonSearchThisArea.isHidden = true
                let lat = Double(self.currentLat)
                let long = Double(self.currentLong)
                let locationObj =  CLLocationCoordinate2DMake(lat,long)
                self.objMapView.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom:self.objMapView.camera.zoom))
                self.objMapView.clear()
                self.viewProviderContainerView.isHidden = true
                self.viewCollectionViewContainer.isHidden  = true
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.isFirstTimeKeywordSearch = false
                    self.isFromDidselectSearchKeyword = false
                    if self.currentSearchKeyword.count > 0{
                        self.fetchProviderOfferRequestAPIRequest(searchKeyword: self.currentSearchKeyword,isFirstTime:true)
                    }else{
                        self.fetchProviderOfferRequestAPIRequest(searchKeyword: "",isFirstTime:true)
                    }

                    //self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: self.txtSearch.text ?? "",latitude: "\(self.currentLat)", longitude:"\(self.currentLong)", isFirstTime: true)
                }

            }

         }
         
     }
    func setCenterToCurrentLocation(){
          if self.currentLat != 0.0 && self.currentLong != 0.0 {
               let location = CLLocation(latitude: self.currentLat, longitude: self.currentLong)
              self.centerMapOnLocation(location: location)
          }
      }
    @IBAction func menuBtnClicked(_ sender: UIButton) {
         
         if let container = self.so_containerViewController {
             container.isSideViewControllerPresented = true
         }
     }
    @IBAction func buttonSwitchUserRoleSelector(sender:UIButton){
        if self.selectedSearchOption == 0{
            //self.showUserProfileSwitchAlert()
            self.pushToSearchPersonCompanyViewController(isForCompany: false)
        }else if self.selectedSearchOption == 1{
            self.pushToSearchPersonCompanyViewController(isForCompany: false)
        }else if self.selectedSearchOption == 2{
            self.pushToSearchPersonCompanyViewController(isForCompany:  true)
        }
    }
    func pushToSearchPersonCompanyViewController(isForCompany:Bool){
        self.objMapView.clear()
        self.manageUserDetailState = false
          if let searchViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "SearchPersonCompanyViewController") as? SearchPersonCompanyViewController{
              searchViewController.hidesBottomBarWhenPushed = true
              searchViewController.delegate = self
              searchViewController.isForCompany =  isForCompany
              searchViewController.selectedSearchOption = self.selectedSearchOption
                if let _ = self.selectedTag{
                    searchViewController.selectedTag = self.selectedTag!
                }
              self.navigationController?.pushViewController(searchViewController, animated: false)
          }
      }
    func showUserAccountSwitchAlertOnProviderBooking(index:Int){
        let strSwitch = "You need to be in Customer view to book a Provider. Would you like to switch?"
        UIAlertController.showAlertWithYesNoButton(self, aStrMessage: "\(strSwitch)") { (objInt, strString) in
            if objInt == 0{
                self.apiReuestToSwitchUserRoleAndBookProviderAtIndex(index:index)
            }
        }
    }
    func apiReuestToSwitchUserRoleAndBookProviderAtIndex(index:Int){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                   return
        }
        var dict:[String:Any]  = [:]
        if currentUser.userRoleType == .customer{
            dict["role"] = "provider"
        }else if currentUser.userRoleType == .provider{
          dict["role"] = "customer"
        }

        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSwitchAccount , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                        if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"]{
                            if currentUser.userRoleType == .customer{
                              currentUser.userRoleType = .provider
                            }else if currentUser.userRoleType == .provider{
                              currentUser.userRoleType = .customer
                            }
                            currentUser.setuserDetailToUserDefault()
                            DispatchQueue.main.async {
                                self.pushToCustomerOrProviderHomeViewController()
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                                    self.providerBookingAsProviderAfterUserRoleSwitch(index: index)
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
                                    APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kSwitchAccount)")

                                    // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                 }
                             }
                         }
    }
    func showUserProfileSwitchAlert(){
           var strSwitch = "Do you want to switch to provider view?"
           guard let currentUser = UserDetail.getUserFromUserDefault() else {
               
               return
           }
           if currentUser.userRoleType == .provider{
               strSwitch = "To do a search, you need to be in Customer view. Would you like to switch?"
           }else if currentUser.userRoleType == .customer{
               strSwitch = "Do you want to switch to provider view?"
           }
           
           UIAlertController.showAlertWithCancelButton(self, aStrMessage: "\(strSwitch)") { (objInt, strString) in
               if objInt == 0{
                   self.apiRequestForUserRoleSwitch()
               }
           }
       }
    func apiRequestForUserRoleSwitch(){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                   return
        }
        var dict:[String:Any]  = [:]
        if currentUser.userRoleType == .customer{
            dict["role"] = "provider"
        }else if currentUser.userRoleType == .provider{
          dict["role"] = "customer"
        }
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSwitchAccount , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                        if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"]{
                            if currentUser.userRoleType == .customer{
                              currentUser.userRoleType = .provider
                            }else if currentUser.userRoleType == .provider{
                              currentUser.userRoleType = .customer
                            }
                            currentUser.setuserDetailToUserDefault()
                            DispatchQueue.main.async {
                                self.pushToCustomerOrProviderHomeViewController()
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
                                  //   SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                 }
                             }
                         }
    }
    func pushToCustomerOrProviderHomeViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let navigationController = UINavigationController(rootViewController:VC)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushtosendofferviewcontrollewith(offerdetail:OfferDetail){
        self.manageUserDetailState = true
        if let sendofferviewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "SendOfferViewController") as? SendOfferViewController{
            sendofferviewcontroller.objOfferDetail = offerdetail
            sendofferviewcontroller.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(sendofferviewcontroller, animated: true)
        }
    }

}
extension ProviderHomeViewController{
    @IBAction func buttonShowCollectionView(sender:UIButton){
//            self.viewProviderContainerView.isHidden = true //(self.arrayOfKeywordSearchOffer.count == 0)
//            self.viewCollectionViewContainer.isHidden = true //(self.arrayOfProvidersOffer.count == 0)

        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {

            self.isForKeywordSearch = false
            self.isFromDidselectSearchKeyword = false
            if self.arrayOfProvidersOffer.count > 0{
                self.selectedTag = 0
//                self.checkforcustomerOfferMarkerWithInScreen()

            }
        })
        
    }
    @IBAction func buttonCloseCollectionAndShowSlider(sender:UIButton){
//        self.viewProviderContainerView.isHidden = true //(self.arrayOfKeywordSearchOffer.count == 0)
//        self.viewCollectionViewContainer.isHidden = true //(self.arrayOfProvidersOffer.count == 0)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            self.isForKeywordSearch = true
            self.isFromDidselectSearchKeyword = true
            if self.arrayOfKeywordSearchOffer.count > 0{
                self.searchMapPinSelectedTag = 0
//                self.checkforcustomerOfferMarkerWithInScreen()
            }
//            self.isForKeywordSearch = true
//            self.fetchProviderOfferRequestAPIRequest(searchKeyword: "\(self.currentSearchKeyword)")

      })
    }
}
extension ProviderHomeViewController:SearchKeywordDelegate{
    func didSelectKeywordWith(response: [String : Any]) {
        print(response)
        self.isForKeywordSearch = true
        self.isFromDidselectSearchKeyword = true
        self.arrayOfKeywordSearchOffer.removeAll()
        if let name = response["keywords_for_business"]{
            if let appdelegate = UIApplication.shared.delegate as? AppDelegate{
                appdelegate.searchKeywordProvider = "\(name)"
            }
            self.currentSearchKeyword = "\(name)"
          }
        DispatchQueue.main.async {
            self.objMapView.clear()

            if let tag = response["selectedTag"] as? Int{
                self.selectedTag = tag
            }
        }
    }
}
extension ProviderHomeViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,ProviderOfferCellDelegate, UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.tag != 300 else {
            return
        }
        DispatchQueue.main.async {
            //self.viewRight.isHidden = true
            //self.viewLeft.isHidden = true
//            self.checkForHideShowRightLeftScrollButton()
        }
    }
     func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView.tag != 300 else {
            return
        }
//        self.lastContentOffset = scrollView.contentOffset
//        DispatchQueue.main.async {
//            self.viewRight.isHidden = true
//            self.viewLeft.isHidden = true
//        }
     }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.tag != 300 else {
            return
        }
        //self.checkForHideShowRightLeftScrollButton()
    }
     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView.tag != 300 else {
            /*if let layout = self.keywordSearchColllectionView.collectionViewLayout as? UPCarouselFlowLayout{
                let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
                let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
                self.currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
            }*/
            let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
            if let ip = self.keywordSearchColllectionView.indexPathForItem(at: center) {
                    self.currentPage = ip.row
                }
            return
        }
        let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
        if let ip = self.collectionObj.indexPathForItem(at: center) {
                self.selectedTag = ip.row
            if let _ = self.selectedTag{
//                self.collectionObj.scrollToItem(at: IndexPath(item: self.selectedTag!, section: 0), at: .centeredHorizontally, animated: true)
                self.setProviderLocationMakerOnGoogleMapWithUpdatedColorIndex(index:self.selectedTag!,isFromMap: true)
//                self.collectionObj.reloadData()
                self.checkforcustomerOfferMarkerWithInScreen()
            }
         }
//        DispatchQueue.main.async {
//            self.viewLeft.isHidden = scrollView.contentOffset.x == 0 || scrollView.contentOffset.x - 180.0 < 0.0
//            self.viewRight.isHidden = scrollView.contentOffset.x + 180 >= (scrollView.contentSize.width - self.collectionObj.frame.size.width)
//        }
        
//        self.checkForHideShowRightLeftScrollButton()
//        if scrollView.contentOffset.x + 180 >= (self.collectionObj.contentSize.width - self.collectionObj.frame.size.width) {
//
//             print("riched right")
//             DispatchQueue.main.async {
//                 self.viewRight.isHidden = true
//                 self.viewLeft.isHidden = (self.arrayOfProvidersOffer.count > 2) ?  false : true
//             }
//        }else if scrollView.contentOffset.x == 0 || scrollView.contentOffset.x - 100.0 < 0.0{
//                 DispatchQueue.main.async {
//                     self.viewLeft.isHidden = true
//                     self.viewRight.isHidden = (self.arrayOfProvidersOffer.count > 2) ?  false : true
//                 }
//                 print("riched left")
//
//         }else{
//
//              DispatchQueue.main.async {
//                  self.viewLeft.isHidden = (self.arrayOfProvidersOffer.count > 2) ?  false : true
//                  self.viewRight.isHidden = (self.arrayOfProvidersOffer.count > 2) ?  false : true
//              }
//          }
        /*
        if scrollView.contentOffset.x == 0 || scrollView.contentOffset.x - 180.0 < 0.0{
                DispatchQueue.main.async {
                    self.viewLeft.isHidden = true
                    self.viewRight.isHidden = (self.arrayOfProvidersOffer.count > 2) ?  false : true
                }
                print("riched left")
            
        }else if scrollView.contentOffset.x + 180 >= (scrollView.contentSize.width - scrollView.frame.size.width){
            print("riched right")
            DispatchQueue.main.async {
                self.viewRight.isHidden = true
                self.viewLeft.isHidden = (self.arrayOfProvidersOffer.count > 2) ?  false : true
            }
        }else{
            DispatchQueue.main.async {
                self.viewLeft.isHidden = (self.arrayOfProvidersOffer.count > 2) ?  false : true
                self.viewRight.isHidden = (self.arrayOfProvidersOffer.count > 2) ?  false : true
            }
        }*/
   }
    fileprivate func checkforcustomerOfferMarkerWithInScreen(){
        if let currentOfferTag = self.selectedTag{
            if self.arrayOfProvidersOffer.count > currentOfferTag{
                let offerNotifiedProvider = self.arrayOfProvidersOffer[currentOfferTag]
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    let lat = Double("\(offerNotifiedProvider.jobDetail!.lat)") ?? 0.0
                    let lng = Double("\(offerNotifiedProvider.jobDetail!.lng)") ?? 0.0
                    let markerPosition: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:lat, longitude:lng)
                    print("------- \(self.isMarkerWithinScreen(markerPosition: markerPosition))")
                    if self.isMarkerWithinScreen(markerPosition: markerPosition){

                    }else{
                        let markerpoint = self.objMapView.projection.point(for: markerPosition)
                        print("------ \(markerpoint.x)")
                        print("------ \(markerpoint.y)")
                        var scrollX:CGFloat = 0
                        var scrollY:CGFloat = 0
                        if markerpoint.x > 0 && markerpoint.x < UIScreen.main.bounds.width{
                            if markerpoint.x > 0{
                                scrollX = 50
                            }else{
                                scrollX = -50
                            }
                        }else{
                            if markerpoint.x > 0{
                                if markerpoint.x > UIScreen.main.bounds.width{
                                    scrollX =  markerpoint.x - UIScreen.main.bounds.width
                                    scrollX += 50
                                }else{
                                    scrollX =  markerpoint.x + 50
                                }
                            }else{
                                scrollX = markerpoint.x + -50
                            }
                        }
                        let miniMumY = self.searchViewContainer.frame.maxY
                        let maxMumY = self.viewProviderContainerView.frame.minY - 88.0
                        if markerpoint.y > miniMumY && markerpoint.y < maxMumY{
                            if markerpoint.y > miniMumY{
                                scrollY = 10
                            }else{
                                scrollY = -10
                            }
                        }else{
                            if markerpoint.y > miniMumY{
                                if markerpoint.y > maxMumY{
                                    scrollY =  markerpoint.y - maxMumY
                                    scrollY += 10
                                }else{
                                    scrollY =  markerpoint.y + 10
                                }
                            }else{
                                scrollY = markerpoint.y + -miniMumY + -10
                            }

                        }
                        let downwards = GMSCameraUpdate.scrollBy(x: scrollX, y: scrollY)
                        self.objMapView.animate(with: downwards)
                    }

                }
            }
        }
    }
    
    // MARK: - CollectionView Layout Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        self.collectionObj.isHidden = (self.arrayOfProvidersOffer.count == 0)
        if self.isFromDidselectSearchKeyword{
            self.viewProviderContainerView.isHidden = (self.arrayOfKeywordSearchOffer.count == 0)
            self.viewCollectionViewContainer.isHidden = true
        }else{
            self.viewProviderContainerView.isHidden = true
            self.viewCollectionViewContainer.isHidden = (self.arrayOfProvidersOffer.count == 0)
        }
//        self.viewCollectionViewContainer.isHidden = (self.arrayOfProvidersOffer.count == 0)
//        self.viewProviderContainerView.isHidden = (self.arrayOfKeywordSearchOffer.count == 0)
        self.checkForCollectionHideButtonHideShow()
        guard self.collectionObj == collectionView else {
            return self.arrayOfKeywordSearchOffer.count//self.arrayOfKeywordSearchOffer.count
        }
        return self.arrayOfProvidersOffer.count//JobsModel.Shared.arrJobs.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard self.collectionObj == collectionView else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpdateProviderHomeCollectionViewCell", for: indexPath) as! UpdateProviderHomeCollectionViewCell
            if self.arrayOfKeywordSearchOffer.count > indexPath.item{
                let objOffer = self.arrayOfKeywordSearchOffer[indexPath.item]
                cell.lblOffer.text = "Available for Offer"
                if let customerDetail = objOffer.customerDetail, let pi: Double = Double("\(customerDetail.rating)"){
                    let rating = String(format:"%.1f", pi)
                    let underlineReview = NSAttributedString(string: "\(rating)",
                                                                              attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
                    cell.lblRatings.attributedText = underlineReview
                    cell.lblAllReview.text = "(\(objOffer.review) Reviews)"
                    cell.lblCustomerName.text = customerDetail.isFullNameShow ? "\(customerDetail.firstname) \(customerDetail.lastname)" : "\(customerDetail.firstname)"
                    //cell.lblCustomerName.text = "\(customerDetail.firstname)" //\(customerDetail.lastname)"
                        if let imageURL = URL.init(string: customerDetail.profilePic){
                            autoreleasepool {
                            cell.imgViewCustomer!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                            }
                        }
                    

                }
                if let objJOBDetail = objOffer.jobDetail{
                    cell.lblJobTitle.text = objJOBDetail.title
                    if objJOBDetail.askingPrice.count > 0{
                        if let pi: Double = Double("\(objJOBDetail.askingPrice)"){
                            let value = String(format:"%.2f", pi)
                           cell.lblAskingPrice.text = "\(CurrencyFormate.Currency(value: Double(value) ?? 0)) Budget"
                        }
                    }else{
                        cell.lblAskingPrice.text = "none"
                    }
                    let dateformatter = DateFormatter()
                             dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                             let date = dateformatter.date(from: objJOBDetail.createdAt)
                              dateformatter.dateFormat = "MM/dd/yyyy h:mm a"
                            cell.lblDate.text = dateformatter.string(from: date!.toLocalTime())

                }
                cell.viewKeyword.isHidden = true//!(self.currentSearchKeyword.count > 0)
                cell.lblKeyword.text = self.currentSearchKeyword

            }
            /*
            if self.arrayOfKeywordSearchOffer.count > indexPath.row{
                cell.currentSearchKeyword = self.currentSearchKeyword
                cell.provider = self.arrayOfKeywordSearchOffer[indexPath.row]

            }*/
            cell.tag = indexPath.row
            cell.delegate  = self
            cell.buttonmore.isHidden = true
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpdateProviderHomeCollectionViewCell", for: indexPath) as! UpdateProviderHomeCollectionViewCell
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProviderOfferCell", for: indexPath) as! ProviderOfferCell
        cell.delegate = self
        cell.tag = indexPath.item
        cell.buttonmore.isHidden = false
        if self.arrayOfProvidersOffer.count > indexPath.item{

            let objOffer = self.arrayOfProvidersOffer[indexPath.item]
            cell.buttonmore.isSelected = objOffer.isMoreOption
            cell.viewMore.isHidden = !objOffer.isMoreOption
            cell.lblOffer.text = "Waiting for Offer"
            cell.offerYellowView.backgroundColor = UIColor.systemYellow
//            cell.viewAttachmentContainer.isHidden = (objOffer.offerAttachment.count == 0)
            if let customerDetail = objOffer.customerDetail, let pi: Double = Double("\(customerDetail.rating)"){
                let rating = String(format:"%.1f", pi)
                let underlineReview = NSAttributedString(string: "\(rating)",
                                                                          attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
                cell.lblRatings.attributedText = underlineReview
                cell.lblAllReview.text = "(\(objOffer.review) Reviews)"
                cell.lblCustomerName.text = customerDetail.isFullNameShow ? "\(customerDetail.firstname) \(customerDetail.lastname)" : "\(customerDetail.firstname)"
//                cell.lblCustomerName.text = "\(customerDetail.firstname)" //\(customerDetail.lastname)"
                    if let imageURL = URL.init(string: customerDetail.profilePic){
                        autoreleasepool {
                        cell.imgViewCustomer!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                        }
                    }

            }


            if let objJOBDetail = objOffer.jobDetail{
                cell.lblJobTitle.text = objJOBDetail.title
                let dateformatter = DateFormatter()
                         dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                         let date = dateformatter.date(from: objJOBDetail.createdAt)
                          dateformatter.dateFormat = "MM/dd/yyyy h:mm a"
                        cell.lblDate.text = dateformatter.string(from: date!.toLocalTime())
                
                if objJOBDetail.askingPrice.count > 0{
                    if let pi: Double = Double("\(objJOBDetail.askingPrice)"){
                        let value = String(format:"%.2f", pi)
                       cell.lblAskingPrice.text  = "\(CurrencyFormate.Currency(value: Double(value) ?? 0)) Budget"
                    }
                    //cell.lblAskingPrice.text = "$\(objJOBDetail.askingPrice)"
                }else{
                    cell.lblAskingPrice.text = "none"
                }
            }
        }
                /*
                let offerString = NSMutableAttributedString()
                
                if objJOBDetail.isForSendOffer{
                    cell.viewSendOffer.isHidden = true
                    cell.buttonSendOffer.isHidden = true
                    cell.lblOffer.text = "Offer Sent: Waiting for Reply"
                    cell.viewDeleteJobDetail.isHidden = true
                    cell.viewCustomerDetail.isHidden = false
                    cell.viewContactDetail.isHidden = false
                    cell.viewWithdrawOfferDetail.isHidden = false
                    cell.viewOfferPriceContainer.isHidden = false
                    
                    var selectedColor = UIColor.black
                    var selectedOfferPriceAfterStripe  = UIColor.init(hex: "38B5A3")
                    if let tag = self.selectedTag, tag == indexPath.row{
                          selectedColor = UIColor.white
                          selectedOfferPriceAfterStripe = UIColor.init(hex: "00bfff")
                      }else{
                          selectedColor = UIColor.black
                          selectedOfferPriceAfterStripe = UIColor.init(hex: "38B5A3")
                      }
                    if objOffer.promotion.count > 0{
                        if let pi: Double = Double("\(objJOBDetail.offerPrice)"){
                            let updatedvalue = String(format:"%.2f", pi)
                            let newUpdatedValue = "$\(updatedvalue)".strikeThrough()
                            offerString.append("$\(updatedvalue)\n".strikeThrough())
                            offerString.addAttribute(NSAttributedString.Key.foregroundColor, value: selectedColor , range: NSMakeRange(0, newUpdatedValue.length))
                        }
                        if let pi: Double = Double("\(objJOBDetail.finalPrice)"){
                            let updatedvalue = String(format:"%.2f", pi)
                            let newUpdatedValue = NSAttributedString(string: "$\(updatedvalue)",attributes: [NSAttributedString.Key.foregroundColor: selectedOfferPriceAfterStripe])
                            offerString.append(newUpdatedValue)//(NSAttributedString.init(string: "$\(updatedvalue)"))
                        }
                    }else{
                        if let pi: Double = Double("\(objJOBDetail.offerPrice)"){
                            let updatedvalue = String(format:"%.2f", pi)
                            let newUpdatedValue = NSAttributedString(string: "$\(updatedvalue)",attributes: [NSAttributedString.Key.foregroundColor: selectedColor])

                            offerString.append(newUpdatedValue)//(NSAttributedString.init(string:"$\(updatedvalue)"))
                        }
                    }
                    
                    cell.lblOfferPrice.attributedText = offerString
                }else{
                    cell.viewOfferPriceContainer.isHidden = true
                    cell.viewSendOffer.isHidden = false
                    cell.buttonSendOffer.isHidden = false
                    cell.lblOffer.text = "Waiting for Offer"
                    cell.viewDeleteJobDetail.isHidden = false
                    cell.viewCustomerDetail.isHidden = true
                    cell.viewContactDetail.isHidden = true
                    cell.viewWithdrawOfferDetail.isHidden = true
                }
            }else{
                cell.viewOfferPriceContainer.isHidden = true
                cell.viewSendOffer.isHidden = false
                cell.buttonSendOffer.isHidden = false
                cell.lblOffer.text = "Waiting for Offer"
                cell.viewDeleteJobDetail.isHidden = false
                cell.viewCustomerDetail.isHidden = true
                cell.viewContactDetail.isHidden = true
                cell.viewWithdrawOfferDetail.isHidden = true
            }
            
            print(objOffer.promotion.count)
            if objOffer.promotion.count > 0{
                if let value =  objOffer.promotion.first!["customer_discount"]{
                                 if let type = objOffer.promotion.first!["type"]{
                                     if "\(type)" == "amount"{
                                         if let pi: Double = Double("\(value)"){
                                             let updatedvalue = String(format:"%.2f", pi)
                                            cell.lblPromotionOfferAmount.text = CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)//"$\(updatedvalue)"
                                         }
                                     }else{
                                         cell.lblPromotionOfferAmount.text = "\(value)%"
                                     }
                                 }
                                 
                             }
                cell.viewPromotionPriceContainer.isHidden = false
            }else{
                cell.viewPromotionPriceContainer.isHidden = true
            }
            
            if let customerDetail = objOffer.customerDetail{
                cell.lblProviderBusinessName.text = "\(customerDetail.firstname)"//\(customerDetail.lastname)"
                cell.lblCustomerName.text = "\(customerDetail.firstname)"// \(customerDetail.lastname)"
                if let imageURL = URL.init(string: "\(customerDetail.profilePic)"){
                    autoreleasepool {
                                  cell.imgViewCustomer!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                              }
                }
            }
            UIView.transition(with: cell.viewMore, duration: 0.5,
                options: .transitionCrossDissolve,
                animations: {
                   DispatchQueue.main.async {
                      cell.buttonmore.isSelected = objOffer.isMoreOption
                      cell.viewMore.isHidden = !objOffer.isMoreOption
                  }
            })
        }
        
//        if let tag = self.selectedTag, tag == indexPath.row{
//            cell.configureSelectedStatus(isCurrent: true)
//        }else{
//            cell.configureSelectedStatus(isCurrent: false)
//        }
         //cell.configureSelectedStatus(isCurrent: false)
                    */
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard self.collectionObj == collectionView else {
            return 0
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard self.collectionObj == collectionView else {
            return 0
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard collectionView.bounds.width > 40.0 && collectionView.bounds.height > 10 else{
            return collectionView.bounds.size
        }
        guard self.collectionObj == collectionView else {
            return CGSize(width: self.keywordSearchColllectionView.bounds.width - 40.0, height: self.keywordSearchColllectionView.bounds.height - 10.0)
        }
        return CGSize(width: self.collectionObj.bounds.width-40 , height:self.collectionObj.bounds.height-10)

//        return CGSize(width: 180, height:collectionView.bounds.height)
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.collectionObj == collectionView else {
            return
        }
        DispatchQueue.main.async {
            self.selectedTag = indexPath.item
            self.collectionObj.reloadData()
        }
    }
    func buttonWithDrawWith(index: Int) {
        if self.arrayOfProvidersOffer.count > index{
               let objOfferDetail = self.arrayOfProvidersOffer[index]
                
                   let alert = UIAlertController(title: AppName, message: "Are you sure you want to withdraw offer?", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                                    
                                }))
                                
                                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                                   if let jobdetail =  objOfferDetail.jobDetail{
                                           self.callWithDrawPostAPIRequest(jodId: jobdetail.jobID)
                                   }
                                   
                                }))
                              alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                                self.present(alert, animated: true, completion: nil)
               }
    }
    func callWithDrawPostAPIRequest(jodId:String){
        let dict:[String:Any] = [
        "job_id" : "\(jodId)"
        ]

        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kWithDrawOffer , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in

        if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [String]{
            
            DispatchQueue.main.async {
                            self.objMapView.clear()
                            self.fetchProviderOfferRequestAPIRequest(searchKeyword: "")
                       }
            DispatchQueue.main.async {
                if arrayOfJOB.count > 0{
                    SAAlertBar.show(.error, message:"\(arrayOfJOB.first!)".localizedLowercase)
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
                    APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kWithDrawOffer)")
                   // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
    }
    func buttonJOBDetailClick(index: Int) {
        if self.viewProviderContainerView.isHidden {
            if self.arrayOfProvidersOffer.count > index{
                let objOfferDetail = self.arrayOfProvidersOffer[index]
                if let objJobDetail = objOfferDetail.jobDetail{
                    self.pushToJOBDetailViewController(withJOBID: objJobDetail.jobID)
                }
            }
        }else{
            if self.arrayOfKeywordSearchOffer.count > index{
                let objOfferDetail = self.arrayOfKeywordSearchOffer[index]
                if let objJobDetail = objOfferDetail.jobDetail{
                    self.pushToJOBDetailViewController(withJOBID: objJobDetail.jobID)
                }
            }
        }

    }
    func buttonCustomerDetailClick(index: Int) {

        if self.viewProviderContainerView.isHidden {
            if self.arrayOfProvidersOffer.count > index{
                let objOfferDetail = self.arrayOfProvidersOffer[index]
                self.pushtoCustomerDetailWithOfferDetail(objOfferDetail: objOfferDetail)
            }
        }else{
            if self.arrayOfKeywordSearchOffer.count > index{
                let  objOfferDetail = self.arrayOfKeywordSearchOffer[index]
                self.pushtoCustomerDetailWithOfferDetail(objOfferDetail: objOfferDetail)
            }
        }

    }
    func pushtoCustomerDetailWithOfferDetail(objOfferDetail:OfferDetail){
        self.manageUserDetailState = true
        let profilestoryboard  = UIStoryboard.init(name: "Profile", bundle: nil)
        if let profileViewcontroller = profilestoryboard.instantiateViewController(withIdentifier: "CustomerProfileAsProviderVC") as? CustomerProfileAsProviderVC{
            if let customer = objOfferDetail.customerDetail{

                profileViewcontroller.userId = customer.userId
                profileViewcontroller.userProfile = customer.profilePic
                profileViewcontroller.userName = "\(customer.firstname) \(customer.lastname)"
            }
            profileViewcontroller.offerdetail = objOfferDetail
            profileViewcontroller.isForOffer = true
            profileViewcontroller.hidesBottomBarWhenPushed = true

            self.navigationController?.pushViewController(profileViewcontroller, animated: true)
        }
    }
    func buttonContactClick(index: Int) {
        if self.viewProviderContainerView.isHidden {
            if self.arrayOfProvidersOffer.count > index{
                let objOfferDetail = self.arrayOfProvidersOffer[index]
                self.pushtoChatViewControllerWith(offerDetail: objOfferDetail)
            }
        }else{
            if self.arrayOfKeywordSearchOffer.count > index{
                let objOfferDetail = self.arrayOfKeywordSearchOffer[index]
                self.pushtoChatViewControllerWith(offerDetail: objOfferDetail)
            }
        }

    }
    func pushToChatViewControllerOnNotification(receiverId:String, quickblox_id: String){
        if self.isFromChatNotificationReceive{
            self.manageUserDetailState = false
        }else{
            self.manageUserDetailState = true
        }

        if let chatViewConroller = UIStoryboard.messages.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC{
                   chatViewConroller.hidesBottomBarWhenPushed = true
                   chatViewConroller.receiverID = "\(receiverId)"
                   chatViewConroller.strReceiverName = "\(self.chatNotificationreceiveName)"
                   chatViewConroller.strReceiverProfileURL = "\(self.chatNotificationProfile)"
                   chatViewConroller.senderID = "\(quickblox_id)"
                   chatViewConroller.toUserTypeStr = "\(self.chatNotificationToUserType)"
                   chatViewConroller.isForCustomerToProvider = false
                   self.navigationController?.pushViewController(chatViewConroller, animated: false)
               }
    }
    func pushtoChatViewControllerWith(offerDetail:OfferDetail){
        self.manageUserDetailState = true
        if let chatViewConroller = UIStoryboard.messages.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC{
            chatViewConroller.hidesBottomBarWhenPushed = true
            if let customer = offerDetail.customerDetail{
                chatViewConroller.strReceiverName = "\(customer.firstname) "//\(customer.lastname)"
                chatViewConroller.strReceiverProfileURL = "\(customer.profilePic)"
                chatViewConroller.receiverID = "\(customer.userId)"
                chatViewConroller.senderID = "\(customer.quickblox_id)"
                chatViewConroller.toUserTypeStr = "provider"
            }
            
            chatViewConroller.isForCustomerToProvider = false
            self.navigationController?.pushViewController(chatViewConroller, animated: true)
        }
    }
    func buttonSendOfferClick(index: Int) {
        if self.arrayOfProvidersOffer.count > index{
            let objOfferDetail = self.arrayOfProvidersOffer[index]
            self.pushtosendofferviewcontrollewith(offerdetail: objOfferDetail)
        }
    }
    func buttonMoreProviderCellClick(index: Int) {
        if self.viewProviderContainerView.isHidden {
            if self.arrayOfProvidersOffer.count > index{
            let objOfferDetail = self.arrayOfProvidersOffer[index]
                objOfferDetail.isMoreOption = !objOfferDetail.isMoreOption
                           DispatchQueue.main.async {
                               self.collectionObj.reloadData()
                           }
            }
        }else{
            if self.arrayOfKeywordSearchOffer.count > index{
            let objOfferDetail = self.arrayOfKeywordSearchOffer[index]
                objOfferDetail.isMoreOption = !objOfferDetail.isMoreOption
                           DispatchQueue.main.async {
                               self.collectionObj.reloadData()
                           }
            }
        }


    }
    func buttonDeleteProviderCellClick(index: Int) {
        if self.viewProviderContainerView.isHidden {
            if self.arrayOfProvidersOffer.count > index{
            let objOfferDetail = self.arrayOfProvidersOffer[index]

                let alert = UIAlertController(title: AppName, message: "Are you sure you want to delete this offer?", preferredStyle: .alert)

                             alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in

                             }))

                             alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                                if let jobdetail =  objOfferDetail.jobDetail{
                                        self.callDeletePostAPIRequest(jodId: jobdetail.jobID)
                                }

                             }))
                           alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                             self.present(alert, animated: true, completion: nil)
            }
        }else{

        }

    }
         
            
        func callDeletePostAPIRequest(jodId:String){
            let dict:[String:Any] = [
            "job_id" : "\(jodId)"
            ]

            APIRequestClient.shared.sendAPIRequest(requestType: .DELETE, queryString:kDeleteOffer , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in

            if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [String]{
                DispatchQueue.main.async {
                    self.objMapView.clear()
                    if arrayOfJOB.count > 0{
                        SAAlertBar.show(.error, message:"\(arrayOfJOB.first!)".localizedLowercase)
                    }
                    self.fetchProviderOfferRequestAPIRequest(searchKeyword: "")
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
                        APIRequestClient.shared.saveLogAPIRequest(strMessage: "\(responseFail) \(kDeleteOffer)")
                      //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                    }
                }
            }
        }

    
    func buttonAttachmentClick(index: Int) {
        if self.arrayOfProvidersOffer.count > index{
            let offerDetail = self.arrayOfProvidersOffer[index]
            if let  objjobdetail = offerDetail.jobDetail{
                if objjobdetail.attatchment.count > 0{
                    if let attachment = objjobdetail.attatchment.first{
                        if let strImage = attachment["image"] as? String{
                            self.presentWebViewDetailPageWith(strTitle: "Attachment", strURL: strImage)
                            /*
                            if let url = URL(string: "\(strImage)") {
                                UIApplication.shared.open(url)
                            }*/
                        }
                    }
                }
            }
        }
       }
    func presentWebViewDetailPageWith(strTitle:String,strURL:String){
            
            if let attachmentViewController = UIStoryboard.profile.instantiateViewController(withIdentifier: "ConditionPolicyVC") as? ConditionPolicyVC{
                attachmentViewController.strURL = strURL
                attachmentViewController.strTitle = strTitle
                attachmentViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.present(attachmentViewController, animated: true, completion: nil)
            }
        }
    func pushToJOBDetailViewController(withJOBID:String){
        self.manageUserDetailState = true
        if let jobDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailViewController") as? JobDetailViewController{
            jobDetailViewController.hidesBottomBarWhenPushed = true
            jobDetailViewController.jobId = "\(withJOBID)"
            self.navigationController?.pushViewController(jobDetailViewController, animated: true)
        }
    }
}
extension ProviderHomeViewController:KeywordResultDelegate{
    func buttonContactSelector(index:Int){
        if self.arrayOfKeywordSearchOffer.count > index{
            let objnotifiedProviderOffer = self.arrayOfKeywordSearchOffer[index]
            self.pushtoChatViewControllerWith(offerDetail: objnotifiedProviderOffer)
            //self.pushtoChatViewControllerWith(provider:objnotifiedProvider)
        }
    }
    func buttonBookSelector(index:Int){

        self.showUserAccountSwitchAlertOnProviderBooking(index: index)


    }
    func providerBookingAsProviderAfterUserRoleSwitch(index:Int){
        if self.arrayOfKeywordSearchOffer.count > index{
            self.currentKeywordSearchOffer = self.arrayOfKeywordSearchOffer[index]
            self.locationManager.requestWhenInUseAuthorization()
            if self.locationManager.authorizationStatus == .authorizedAlways || self.locationManager.authorizationStatus == .authorizedWhenInUse{
            /*if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){*/
                guard let currentLocation = self.locationManager.location else {
                    return
                }

                var requestParameters:[String:Any] = [:]
                requestParameters["provider_id"] = "\(self.currentKeyWordSearchProvider.providerID)"
                requestParameters["name"] = "\(self.currentKeyWordSearchProvider.businessName)"
                requestParameters["lat"] = "\(currentLocation.coordinate.latitude)"
                requestParameters["lng"] = "\(currentLocation.coordinate.longitude)"
                NotificationCenter.default.post(name: .providerBookJOB, object: nil,userInfo: requestParameters)
            }
        }
    }
    func buttonDetailSelector(index:Int){
        self.currentPage = index
    }
    func buttonProviderDetailSelector(index:Int){

        self.pushtoProviderDetailFromProviderCard(provider: self.currentKeyWordSearchProvider, providerID: self.currentKeyWordSearchProvider.providerID)
    }
}
extension ProviderHomeViewController:GMSMapViewDelegate{
    func showKeywordSearchProviderView(){
        DispatchQueue.main.async {
            self.viewProviderContainerProviderImage.contentMode = .scaleAspectFill
            self.viewProviderContainerProviderImage.clipsToBounds = true
            self.viewProviderContainerSearchKeyword.text = self.currentSearchKeyword
            let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateformatter.date(from: self.currentKeyWordSearchProvider.searchDate)
                 dateformatter.dateFormat = "MM/dd/yyyy\nh:mm a"
            if let _ = date{
                self.viewProviderContainerDate.text = dateformatter.string(from: date!.toLocalTime())

            }
                 self.viewProviderContainerProviderName.text = "\(self.currentKeyWordSearchProvider.businessName)"
                 
                    let businessLogo = self.currentKeyWordSearchProvider.businessLogo
                    if let imageURL = URL.init(string: "\(businessLogo)"){
                        autoreleasepool {
                        self.viewProviderContainerProviderImage!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                        }
                    }
            if let pi: Double = Double("\(self.currentKeyWordSearchProvider.rating)"){
                          let rating = String(format:"%.1f", pi)
                           self.viewProviderContainerReview.text = "\(rating)"
                      }
            self.viewProviderContainerView.isHidden = false

            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                                  return
                              
                          }
            if currentUser.id == "\(self.currentKeyWordSearchProvider.customerDetail["id"] ?? "")"{
                
                self.viewContact.isHidden = true
            }else{
                self.viewContact.isHidden = false
                
            }
        }
    }
     func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if self.isFromDidselectSearchKeyword{//self.isForKeywordSearch{
              if let tag = marker.userData as? Int{
                self.searchMapPinSelectedTag = tag
                if let _ = self.keywordSearchColllectionView?.dataSource?.collectionView(self.keywordSearchColllectionView!, cellForItemAt: IndexPath(item: self.searchMapPinSelectedTag!, section: 0)){
                    self.setSelectedMarkerWithUpdatedColorIndex(index:tag,isFromMap: true)
                    self.keywordSearchColllectionView.scrollToItem(at: IndexPath(item: self.searchMapPinSelectedTag!, section: 0), at: .centeredHorizontally, animated: true)
                }
                   /*if self.arrayOfKeywordSearchOffer.count > tag{
                      let objProvider = self.arrayOfKeywordSearchOffer[tag]
                      self.currentKeyWordSearchProvider = objProvider
                      //ShowKeyword Search Provider detail
                      self.showKeywordSearchProviderView()
                    
                     // remove color from currently selected marker
                     if let selectedMarker = mapView.selectedMarker?.iconView as? CustomMarker{
                         selectedMarker.imageView.tintColor = UIColor.init(hex: "08405D")
                     }

                     if let currentmarker = marker.iconView  as? CustomMarker{
                         currentmarker.imageView.tintColor = UIColor.init(hex: "00bfff")
                         mapView.selectedMarker = marker
                     }
                    
                    
                  }*/
              }
          }else{
              if let tag = marker.userData as? Int{
                         self.selectedTag = tag
                     }
                     if let _ = self.selectedTag{
                        if let _ = self.collectionObj?.dataSource?.collectionView(self.collectionObj!, cellForItemAt: IndexPath(item: self.selectedTag!, section: 0)){
                           self.collectionObj.scrollToItem(at: IndexPath(item: self.selectedTag!, section: 0), at: .centeredHorizontally, animated: true)
                           self.setProviderLocationMakerOnGoogleMapWithUpdatedColorIndex(index: self.selectedTag!,isFromMap: true)
                        }
                     }
                     
            DispatchQueue.main.async {
                self.collectionObj.reloadData()
                self.checkForHideShowRightLeftScrollButton()
            }
          }
         
          return true
     }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture == true {
            self.viewbuttonSearchThisArea.isHidden = false
        }
        
    }
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {

        print("\(self.currentLat)")
        print("\(cameraPosition.target.latitude)")
        print("\(self.currentLong)")
        print("\(cameraPosition.target.longitude)")
        let currentLocationCoordinate = CLLocation.init(latitude: self.currentLat, longitude: self.currentLong)
        let mapCenterLocationCoordinate = CLLocation.init(latitude: cameraPosition.target.latitude, longitude: cameraPosition.target.longitude)
        let distanceInMeters = currentLocationCoordinate.distance(from: mapCenterLocationCoordinate)
        let miles = distanceInMeters / 1609.0
        print("meters \(distanceInMeters)")
        print("miles \(miles)")
        /*
        if miles >= 15.0{
            //self.currentLat = cameraPosition.target.latitude
            //self.currentLong = cameraPosition.target.longitude
            //Call API and refresh images of feed
            //self.apiRequestToFetchUpdatedBusinessFeed(latitude: "\(cameraPosition.target.latitude)", longitude: "\(cameraPosition.target.longitude)")
        }*/
        print("======= \(self.lastSearchLatForKeyword)")
        print("======= \(self.lastSearchLngForKeyword)")
        print("======= \(cameraPosition.target.latitude)")
        print("======= \(cameraPosition.target.longitude)")

        if self.lastSearchLatForKeyword.count > 0 && self.lastSearchLngForKeyword.count > 0{
            let location:CLLocation = CLLocation.init(latitude: (self.lastSearchLatForKeyword as NSString).doubleValue, longitude: (self.lastSearchLngForKeyword as NSString).doubleValue)
            let distanceInMeters = location.distance(from: mapCenterLocationCoordinate)
            let miles = distanceInMeters / 1609.0
            if !self.isFirstTimeKeywordSearch{
                //if miles > 60 || "\(self.currentMapScale)" != "\(self.objMapView.camera.zoom)"{
                    DispatchQueue.main.async {
                        self.lastSearchLatForKeyword = "\(cameraPosition.target.latitude)"
                        self.lastSearchLngForKeyword = "\(cameraPosition.target.longitude)"

                       // self.viewbuttonSearchThisArea.isHidden = false
                    }
                    //self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(self.currentSearchKeyword)", latitude: "\(cameraPosition.target.latitude)", longitude: "\(cameraPosition.target.longitude)",isFirstTime: false)
                //}
            }else{
                self.isFirstTimeKeywordSearch = false
            }
            /*if miles >= 60.0{
                if self.arrayOfKeywordSearchOffer.count > self.currentPage{
                    let objprovider = self.arrayOfKeywordSearchOffer[self.currentPage]

                    let locationUpdate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((objprovider.lat as NSString).doubleValue), longitude: Double((objprovider.lng as NSString).doubleValue))

                    if !self.objMapView.projection.contains(locationUpdate){
                        self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(self.currentSearchKeyword)", latitude: "\(cameraPosition.target.latitude)", longitude: "\(cameraPosition.target.longitude)")
                    }
                }else{
                    self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(self.currentSearchKeyword)", latitude: "\(cameraPosition.target.latitude)", longitude: "\(cameraPosition.target.longitude)")
                }

              //  self.callAPIRequestToGetProviderBasedOnSearchKeyword(keyword: "\(self.currentSearchKeyword)", latitude: "\(cameraPosition.target.latitude)", longitude: "\(cameraPosition.target.longitude)")
            }*/
        }else{
            if self.lastSearchLatForKeyword.count > 0 && self.lastSearchLngForKeyword.count > 0{

            }else{
                self.lastSearchLatForKeyword = "\(self.currentLat)"
                self.lastSearchLngForKeyword = "\(self.currentLong)"
            }
        }
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
           //do something
       }
    
}
class ProviderCustomMarker: UIView {

    @IBOutlet weak var viewContainer:UIView!
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var imageView:UIImageView!

    fileprivate func setupView(withprice:String) {
        // do your setup here
        self.lblPrice.text = "\(withprice)"
    }


    class func instanceFromNibUpdate(withprice:String) -> ProviderCustomMarker {
            let view = UINib(nibName: "ProviderCustomMarker", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ProviderCustomMarker
             view.viewContainer.layer.borderColor = UIColor.init(hex: "244355").cgColor
            view.viewContainer.layer.borderWidth = 0.7
            view.setupView(withprice:withprice)
            view.frame = CGRect(x: 0, y: 0, width:"\(withprice)".size(withAttributes:[.font: UIFont.systemFont(ofSize: 17.0)]).width+30.0, height: 30.0)
            return view
     }
}
