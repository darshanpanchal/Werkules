//
//  MyJobViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 11/01/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import GoogleMaps

class MyJobViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var tableViewProviderOffer:UITableView!
    
    @IBOutlet weak var objMapView:GMSMapView!
    
    @IBOutlet weak var btnToggle: UIButton!
    @IBOutlet weak var objSegmentConroller:UISegmentedControl!
    
    var isLoadMore:Bool = false
    var currentPage:Int = 1
    var fetchPageLimit:Int = 50

    var arrayofofferjob:[OfferDetail] = []
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var currentLat = Double()
    var currentLong = Double()
    
    
    
    var selected:Int = 0
    var selectedIndex:Int{
        get{
            return selected
        }
        set{
            self.selected = newValue
            //Configure Selected Index
            DispatchQueue.main.async {
                self.configureSelectedIndex()
            }
        }
    }
    
    var selectedIndexFromNotification:Int?
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
        self.objMapView.delegate = self
        self.objMapView.isMyLocationEnabled = true
        self.objMapView.settings.myLocationButton = false
        
        self.setup()
        self.mylocation()
        
        //Add Notification Observer for Accept job movement if no offer for provider
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: .updateMyJobTab, object: nil)

        do {
              if let styleURL = Bundle.main.url(forResource: "google_map_style", withExtension: "json") {
                  self.objMapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
              } else {
                  
              }
         } catch {
           NSLog("One or more of the map styles failed to load. \(error)")
         }
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfNewMessageReceiveNotification(notification:)), name: .chatUnreadCount, object: nil)
    }
    @objc func methodOfNewMessageReceiveNotification(notification:Notification){
        if let userInfo = notification.userInfo as? [String:Any]{
            print(userInfo)
            self.callAPIRequestToGetChatUnreadCount()
        }
    }
    func fixBackgroundSegmentControl( _ segmentControl: UISegmentedControl){
        if #available(iOS 13.0, *) {
            //just to be sure it is full loaded
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                for i in 0...(segmentControl.numberOfSegments-1)  {
                    let backgroundSegmentView = segmentControl.subviews[i]
                    print(backgroundSegmentView.subviews.count)
                    print(backgroundSegmentView)
                    //it is not enogh changing the background color. It has some kind of shadow layer
                    backgroundSegmentView.isHidden = true
                    
                    let updatedView = segmentControl.subviews[(segmentControl.subviews.count - 1) - i]
                    updatedView.layer.cornerRadius = 8.0
                    updatedView.layer.borderColor = UIColor.init(hex: "#08405D").cgColor
                    updatedView.layer.borderWidth = 1.0

                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.objSegmentConroller.setWidth(65, forSegmentAt: 2)
//        self.objSegmentConroller.setWidth(100, forSegmentAt: 3)
//        self.objSegmentConroller.setWidth(90, forSegmentAt: 4)
        self.objSegmentConroller.apportionsSegmentWidthsByContent = true
        
        self.fixBackgroundSegmentControl(self.objSegmentConroller)
         self.objSegmentConroller.backgroundColor = UIColor.white

        
        

    }
    @objc func methodOfReceivedNotification(notification: Notification) {
        print("----- \(notification.userInfo)")
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            if let userInfo = notification.userInfo{
                if let acceptjob = userInfo["accept_job"] as? Int,let sendOffer = userInfo["send_offer"] as? Int, let inprogress = userInfo["in_progress"] as? Int{
                  if acceptjob > 0 && sendOffer == 0{
                    if self.objSegmentConroller.selectedSegmentIndex != 1{
                        //green
                        //Accept job
                        self.objSegmentConroller.selectedSegmentIndex = 1
                        self.selectedIndex = 1
                    }
                        
                    }else if acceptjob == 0 && sendOffer > 0 {
                        //yellow
                        //Offer
                        if self.objSegmentConroller.selectedSegmentIndex != 0{
                            self.objSegmentConroller.selectedSegmentIndex = 0
                            self.selectedIndex = 0
                        }
                        
                        
                    }else if acceptjob > 0 && sendOffer > 0{
                        //green and yellow
                        //Offer
                        if self.objSegmentConroller.selectedSegmentIndex != 0{
                            self.objSegmentConroller.selectedSegmentIndex = 0
                            self.selectedIndex = 0
                        }
                       
                         
                    }else if acceptjob == 0 && sendOffer == 0 && inprogress > 0{
                        //Clear
                        //Inprogress
                        if self.objSegmentConroller.selectedSegmentIndex != 2{
                            self.objSegmentConroller.selectedSegmentIndex = 2
                            self.selectedIndex = 2
                        }
                    }else{
                        //Clear
                        
                    }
                 }else{
                     //Clear
                     
                 }
            }
    //
        }
       //Offer
//        self.objSegmentConroller.selectedSegmentIndex = 0
//        self.selectedIndex = 0
//
//        //Accept job
//        self.objSegmentConroller.selectedSegmentIndex = 1
//        self.selectedIndex = 1
//
//        //Inprogress
//        self.objSegmentConroller.selectedSegmentIndex = 2
//        self.selectedIndex = 2
    }
    func mylocation()   {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        // Ask for Authorisation from the User.
        
        // For use in foreground
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    func setup(){
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "#08405D"),NSAttributedString.Key.font:UIFont(name: "Avenir Medium", size: 11.5)]
        let selectedtitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font:UIFont(name: "Avenir Medium", size: 11.5)]
        
        

        self.objSegmentConroller.setTitleTextAttributes(titleTextAttributes, for: .normal)
        self.objSegmentConroller.setTitleTextAttributes(selectedtitleTextAttributes, for: .selected)

        self.objSegmentConroller.addTarget(self, action: #selector(MyJobViewController.indexChanged(_:)), for: .valueChanged)
        self.objSegmentConroller.layer.borderWidth = 0.7
        self.objSegmentConroller.layer.borderColor = UIColor.init(hex: "#08405D").cgColor
        RegisterCell()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         
         let latestLocation: AnyObject = locations[locations.count - 1]
         let mystartLocation = latestLocation as! CLLocation
         print(self.currentLat)
         print(self.currentLong)
         if self.currentLat == 0.0 && self.currentLong == 0.0 {
             self.centerMapOnLocation(location: mystartLocation)
         }
         
         self.currentLat = mystartLocation.coordinate.latitude
         self.currentLong = mystartLocation.coordinate.longitude

     }
    func centerMapOnLocation(location: CLLocation) {
        
//        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15.0)
//        self.objMapView.camera = camera
//        self.objMapView.animate(to: camera)
        //Map Animation
        let locationObj =  CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //CATransaction.begin()
        //CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
        DispatchQueue.main.async {
            self.objMapView.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: 15))
        }
        
        //CATransaction.commit()
        /*let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setCenter(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), animated: true)*/
    }
    @objc func indexChanged(_ sender: UISegmentedControl) {
        self.selectedIndex = self.objSegmentConroller.selectedSegmentIndex
    }
    func RegisterCell()  {
       self.tableViewProviderOffer.allowsSelection = false
       self.tableViewProviderOffer.tableFooterView = UIView()
       self.tableViewProviderOffer.delegate = self
       self.tableViewProviderOffer.dataSource = self
       self.tableViewProviderOffer.reloadData()
       let objnib = UINib.init(nibName:"ProviderJOBOfferTableViewCell", bundle: nil)
       self.tableViewProviderOffer.register(objnib, forCellReuseIdentifier: "ProviderJOBOfferTableViewCell")
        
       let objnibupdate = UINib.init(nibName:"ProviderUpdatedJOBOfferTableViewCell", bundle: nil)
       self.tableViewProviderOffer.register(objnibupdate, forCellReuseIdentifier: "ProviderUpdatedJOBOfferTableViewCell")
        
    }
       
    func configureSelectedIndex(){
        DispatchQueue.main.async {
            self.btnToggle.isHidden = true//(self.selectedIndex != 0)
            self.currentPage = 1
            self.isLoadMore = false
            self.arrayofofferjob.removeAll()
            self.tableViewProviderOffer.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            if self.selectedIndex == 0{ //offer
                self.callAPIRequestToFetchOfferJOBList()
            }else if self.selectedIndex == 1 {
                self.callAPIRequestToFetchAcceptJOBList()
            }else if self.selectedIndex == 2 { //inprogress
                self.callAPIRequestToFetchInprogressJOBList()
            }else if self.selectedIndex == 3 { //completed
                 self.callAPIRequestToFetchCompletedJOBList()
            }else if self.selectedIndex == 4 { //unsuccessfull
                 self.callAPIRequestToFetchUnSuccessFullJOBList()
            }else{
                
            }
        }
              
              
    }
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
        self.callAPIRequestToGetChatUnreadCount()
          if let _ = self.selectedIndexFromNotification{
              self.objSegmentConroller.selectedSegmentIndex = self.selectedIndexFromNotification!
              self.selectedIndex = self.selectedIndexFromNotification!
          }else{
            self.selectedIndex = self.objSegmentConroller.selectedSegmentIndex
         }
//        self.getMyJOBCountAPIRequest()
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
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          self.locationManager.stopUpdatingLocation()
          self.selectedIndexFromNotification = nil
        self.arrayofofferjob = []
      }
    // MARK: - Selector Methods
       @IBAction func menuBtnClicked(_ sender: UIButton) {
            
            if let container = self.so_containerViewController {
                container.isSideViewControllerPresented = true
            }
        }
    @IBAction func btnToggleClicked(_ sender: UIButton) {
          if let objTabView = self.navigationController?.tabBarController{
                     if let objHomeNavigation = objTabView.viewControllers?.first as? UINavigationController,let objHome = objHomeNavigation.viewControllers.first as? ProviderHomeViewController{
                         objTabView.selectedIndex = 0
                     }
        }
    }
    // MARK: - API Request Methods
    func callAPIRequestToFetchOfferJOBList(){
           var dict:[String:Any] = [:]
                      
                      dict["limit"] = "\(self.fetchPageLimit)"
                      dict["page"] = "\(self.currentPage)"
                      dict["is_provider_home"] = false
        
               APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kFetchProviderOfferHome , parameter:dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                       
                       if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [[String:Any]]{
                                   if self.currentPage == 1{
                                       self.arrayofofferjob.removeAll()
                                   }
                                   self.isLoadMore = arrayOfJOB.count > 0
                                   if arrayOfJOB.count > 0 {
                                       for objOffer in arrayOfJOB{
                                        let offer =  OfferDetail.init(offerDetail: objOffer)//NotifiedProviderOffer.init(providersDetail: objOffer)
                                          self.arrayofofferjob.append(offer)
                                       }
                                   }
                                   DispatchQueue.main.async {
                                       self.tableViewProviderOffer.reloadData()
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
        //Call Note started JOB
        func callAPIRequestToFetchAcceptJOBList(){
             
             var dict:[String:Any] = [:]
             
             dict["limit"] = "\(self.fetchPageLimit)"
             dict["page"] = "\(self.currentPage)"
             
                 APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kAcceptJOBList , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                         
                         if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [[String:Any]]{
                                    print(arrayOfJOB)
                                     if self.currentPage == 1{
                                         self.arrayofofferjob.removeAll()
                                     }
                                     self.isLoadMore = arrayOfJOB.count > 0
                                     if arrayOfJOB.count > 0 {
                                         for objOffer in arrayOfJOB{
                                            var offer =  OfferDetail.init(offerDetail: objOffer)//NotifiedProviderOffer.init(providersDetail: objOffer)
                                            offer.jobDetail = JOB.init(jobDetail: objOffer)
                                            offer.customerDetail = CustomerDetail.init(customerDetail: objOffer)
                                            if let listOfPromotion = objOffer["promotion"] as? [[String:Any]]{
                                                offer.promotion = listOfPromotion
                                            }
                                            if let objofferAttachment = objOffer["offer_attachments"] as? [[String:Any]],objofferAttachment.count > 0{
                                                offer.offerAttachment = objofferAttachment
                                            }else if let objofferAttachment = objOffer["offer_attachment"] as? [[String:Any]],objofferAttachment.count > 0{
                                                offer.offerAttachment = objofferAttachment
                                            }
                                            self.arrayofofferjob.append(offer)
                                         }
                                     }
                                     DispatchQueue.main.async {
                                         self.tableViewProviderOffer.reloadData()
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
                                          //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                        }
                                    }
                                }
             
             
         }
        //kStartJOB
     func callAPIRequestToStartJOB(jobid:String){
            
            var dict:[String:Any] = [:]
            
            dict["job_id"] = "\(jobid)"
            
            
                APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kStartJOB , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                        
                    if let success = responseSuccess as? [String:Any],let objSuccess = success["success_data"] as? [String]{

                                    DispatchQueue.main.async {
                                        let strMessage = "Your customer will be notified that you are starting the job"
                                        SAAlertBar.show(.error, message:"\(strMessage)".localizedLowercase)
                                        if objSuccess.count > 0{
                                        //    SAAlertBar.show(.error, message:"\(objSuccess.first!)".localizedLowercase)
                                        }
                                        self.getMyJOBCountAPIRequest()
                                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                            self.objSegmentConroller.selectedSegmentIndex = 2
                                            self.selectedIndex = 2
                                            self.tableViewProviderOffer.reloadData()
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
                                          // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                       }
                                   }
                               }
            
            
        }
    //Provider Inprogress job
    func callAPIRequestToFetchInprogressJOBList(){
              
            
              var dict:[String:Any] = [:]
              
              dict["limit"] = "\(self.fetchPageLimit)"
              dict["page"] = "\(self.currentPage)"
                          
              
                  APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kProviderInprogressJOB , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                          
                       if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [[String:Any]]{
                                       if self.currentPage == 1{
                                           self.arrayofofferjob.removeAll()
                                       }
                                       self.isLoadMore = arrayOfJOB.count > 0
                                       if arrayOfJOB.count > 0 {
                                           for objOffer in arrayOfJOB{
                                            var offer =  OfferDetail.init(offerDetail: objOffer)//NotifiedProviderOffer.init(providersDetail: objOffer)
                                            offer.jobDetail = JOB.init(jobDetail: objOffer)
                                            offer.customerDetail = CustomerDetail.init(customerDetail: objOffer)
                                            //When customer details is blank we are assigning userid
                                            if let userIdStr = objOffer["user_id"] as? Int{
                                                offer.customerDetail?.id = "\(userIdStr)"
                                            }
                                            
                                            if let objofferAttachment = objOffer["offer_attachments"] as? [[String:Any]],objofferAttachment.count > 0{
                                                offer.offerAttachment = objofferAttachment
                                            }else if let objofferAttachment = objOffer["offer_attachment"] as? [[String:Any]],objofferAttachment.count > 0{
                                                offer.offerAttachment = objofferAttachment
                                            }
                                            
                                              self.arrayofofferjob.append(offer)
                                           }
                                       }
                                       DispatchQueue.main.async {
                                           self.tableViewProviderOffer.reloadData()
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
                                          //   SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                         }
                                     }
                                 }
              
              
        }
        //Provider Completed JOB
    func callAPIRequestToFetchCompletedJOBList(){
        
      
        var dict:[String:Any] = [:]
        
        dict["limit"] = "\(self.fetchPageLimit)"
        dict["page"] = "\(self.currentPage)"
                    
        
            APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kProviderCompletedJOB , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                    
                 if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [[String:Any]]{
                                 if self.currentPage == 1{
                                     self.arrayofofferjob.removeAll()
                                 }
                                 self.isLoadMore = arrayOfJOB.count > 0
                                 if arrayOfJOB.count > 0 {
                                     for objOffer in arrayOfJOB{
                                      var offer =  OfferDetail.init(offerDetail: objOffer)//NotifiedProviderOffer.init(providersDetail: objOffer)
                                        offer.jobDetail = JOB.init(jobDetail: objOffer)
                                        offer.customerDetail = CustomerDetail.init(customerDetail: objOffer)
                                        if let objofferAttachment = objOffer["offer_attachments"] as? [[String:Any]],objofferAttachment.count > 0{
                                            offer.offerAttachment = objofferAttachment
                                        }else if let objofferAttachment = objOffer["offer_attachment"] as? [[String:Any]],objofferAttachment.count > 0{
                                            offer.offerAttachment = objofferAttachment
                                        }
                                        self.arrayofofferjob.append(offer)
                                     }
                                 }
                                 DispatchQueue.main.async {
                                     self.tableViewProviderOffer.reloadData()
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
    //Provider Unsucessfull Offers
    func callAPIRequestToFetchUnSuccessFullJOBList(){
           
         
           var dict:[String:Any] = [:]
           
           dict["limit"] = "\(self.fetchPageLimit)"
           dict["page"] = "\(self.currentPage)"
                       
           
               APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kProviderUnSuccessFullJOB , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                       
                    if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [[String:Any]]{
                                    if self.currentPage == 1{
                                        self.arrayofofferjob.removeAll()
                                    }
                                    self.isLoadMore = arrayOfJOB.count > 0
                                    if arrayOfJOB.count > 0 {
                                        for objOffer in arrayOfJOB{
                                         var offer =  OfferDetail.init(offerDetail: objOffer)//NotifiedProviderOffer.init(providersDetail: objOffer)
                                           offer.jobDetail = JOB.init(jobDetail: objOffer)
                                           offer.customerDetail = CustomerDetail.init(customerDetail: objOffer)
                                           self.arrayofofferjob.append(offer)
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        self.tableViewProviderOffer.reloadData()
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
                                         // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                      }
                                  }
                              }
           
           
       }
    func getMyJOBCountAPIRequest(){
        APIRequestClient.shared.sendAPIRequest(requestType: .GET, queryString:kGETProviderMyJOBCount , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
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
                                     //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
    func pushToJOBDetailViewController(withJOBID:String){
        
        if let jobDetailViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "JobDetailViewController") as? JobDetailViewController{
            jobDetailViewController.hidesBottomBarWhenPushed = true
            jobDetailViewController.jobId = "\(withJOBID)"
            self.navigationController?.pushViewController(jobDetailViewController, animated: true)
        }
    }
    func pushToCustomerDetailViewController(objOfferDetail:OfferDetail){
        let profilestoryboard  = UIStoryboard.init(name: "Profile", bundle: nil)
                if let profileViewcontroller = profilestoryboard.instantiateViewController(withIdentifier: "CustomerProfileAsProviderVC") as? CustomerProfileAsProviderVC{
                    if let customer = objOfferDetail.customerDetail{
                        
                        profileViewcontroller.userId = customer.userId
                        profileViewcontroller.userProfile = customer.profilePic
                        profileViewcontroller.userName = "\(customer.firstname) \(customer.lastname)"
                    }
                    profileViewcontroller.offerdetail = objOfferDetail
                    profileViewcontroller.hidesBottomBarWhenPushed = true
                    if self.selectedIndex == 0{
                        if let jobdetail = objOfferDetail.jobDetail{
                            profileViewcontroller.isForOffer = !jobdetail.isForSendOffer
                        }else{
                            profileViewcontroller.isForOffer = false
                        }
                    }else{
                        profileViewcontroller.isForOffer = false
                    }
                    
                    self.navigationController?.pushViewController(profileViewcontroller, animated: true)
                }
    }
   
    func pushtosendofferviewcontrollewith(offerdetail:OfferDetail){
           if let sendofferviewcontroller = UIStoryboard.main.instantiateViewController(withIdentifier: "SendOfferViewController") as? SendOfferViewController{
               sendofferviewcontroller.objOfferDetail = offerdetail
               sendofferviewcontroller.hidesBottomBarWhenPushed = true
               
               self.navigationController?.pushViewController(sendofferviewcontroller, animated: true)
           }
    }
    func pushtoReportProblemViewController(offerDetail:OfferDetail){
        let profileStroyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        if let reportBugViewController = profileStroyboard.instantiateViewController(withIdentifier: "ReportBugViewController") as? ReportBugViewController{
            reportBugViewController.customerID = offerDetail.customerDetail?.id ?? ""
         if let customer = offerDetail.customerDetail{
             reportBugViewController.customerDetail = customer
             reportBugViewController.isForFileDispute = true
         }
            reportBugViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(reportBugViewController, animated: true)
        }
    }

}

extension MyJobViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           
        if self.selectedIndex == 0 || self.selectedIndex == 1 || self.selectedIndex == 2 || self.selectedIndex == 3 || self.selectedIndex == 4{
            return self.arrayofofferjob.count
           }else{
               return 0
           }
         
       }
       
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.selectedIndex == 0{
            if self.arrayofofferjob.count  > indexPath.row{
            let objoffer = self.arrayofofferjob[indexPath.row]
                if let job = objoffer.jobDetail{
                    return job.isForSendOffer ? 250.0 : 190.0
                }else{
                    return 190.0
                }
            }else{
                return 190.0
            }
            
            
        }else if self.selectedIndex == 1 || self.selectedIndex == 2 || self.selectedIndex == 3 || self.selectedIndex == 4{
            if self.arrayofofferjob.count  > indexPath.row{
                let objoffer = self.arrayofofferjob[indexPath.row]
                if let jobdetail  = objoffer.jobDetail{
                    if jobdetail.isForSendOffer{
                        if objoffer.promotion.count > 0{
                            return 250
                        }else{
                            return 220
                        }
                    }else{
                        return 190.0
                    }
                }else{
                    return 190.0
                }
            }else{
                return 190.0
            }
           
           }else{
               return 360.0
           }
           
       }
  
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if self.selectedIndex == 0{
           let cell = tableViewProviderOffer.dequeueReusableCell(withIdentifier: "ProviderUpdatedJOBOfferTableViewCell", for: indexPath) as! ProviderUpdatedJOBOfferTableViewCell
            
            if self.arrayofofferjob.count  > indexPath.row{
                let objoffer = self.arrayofofferjob[indexPath.row]
                cell.viewDocument.isHidden = (objoffer.offerAttachment.count == 0)
                if let jobdetail = objoffer.jobDetail{
                    cell.lbltitle.text = jobdetail.title
                    if let objVal = jobdetail.askingPrice as? String{
                        cell.lblAskingPrice.text = CurrencyFormate.Currency(value: Double(objVal) ?? 0)
                    }
                  // cell.lblAskingPrice.text = (jobdetail.askingPrice.count > 0) ? "\(jobdetail.askingPrice)".add2DecimalString : "none"
                    
                    var strDate = ""
                    //if jobdetail.createdAt.count > 0{
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                        if jobdetail.isForSendOffer{
                            if let date = dateformatter.date(from: jobdetail.offerDate){
                                dateformatter.dateFormat = "MM/dd/yyyy\nhh:mm a"
                                let updatedDate = dateformatter.string(from: date.toLocalTime())
                                strDate = "Offer Sent Date : \(updatedDate)"
                            }
                          
                          //cell.lblOfferTime.text = self.getTime(time: String(jobdetail.offerDate.suffix(8)))
                        }else{
                            if let date = dateformatter.date(from: jobdetail.createdAt){
                                dateformatter.dateFormat = "MM/dd/yyyy\nhh:mm a"
                                let updatedDate = dateformatter.string(from: date.toLocalTime())
                                strDate = "Post Date : \(updatedDate)"
                            }
                           // cell.lblOfferTime.isHidden = false
                            //cell.lblOfferTime.text = self.getTime(time: String(jobdetail.createdAt.suffix(8)))
                        }
                        cell.lbldateofpost.text = "\(jobdetail.createdAt)".changeDateFormat
                    //}
                    print(" ------- \(strDate)")
                    
                    cell.lblOfferDate.text = "\(strDate)"
                    
                    cell.configureOfferCell(isOfferSent: jobdetail.isForSendOffer)
                    
                                let offerString = NSMutableAttributedString()
                                if objoffer.promotion.count > 0{
                                         if let pi: Double = Double("\(jobdetail.offerPrice)"){
                                             let updatedvalue = String(format:"%.2f", pi)
                                             offerString.append("\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))".strikeThrough())
                                            
                                         }
                                    if let pi: Double = Double("\(jobdetail.finalPrice)"){
                                             let updatedvalue = String(format:"%.2f", pi)
                                             let newUpdatedValue = NSAttributedString(string:" \(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))",attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
                                             offerString.append(newUpdatedValue)//(NSAttributedString.init(string: "$\(updatedvalue)"))
                                         }
                                    }else{
                                     if let pi: Double = Double("\(jobdetail.offerPrice)"){
                                         let updatedvalue = String(format:"%.2f", pi)
                                        
                                         let newUpdatedValue = NSAttributedString(string: "\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))",attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])

                                         offerString.append(newUpdatedValue)//(NSAttributedString.init(string:"$\(updatedvalue)"))
                                     }
                                 }
                    
                    if let objOfferVal = jobdetail.offerPrice as? String{
                        cell.lblOfferAmount.text = CurrencyFormate.Currency(value: Double(objOfferVal) ?? 0)
                    }
                    //cell.lblOfferAmount.attributedText = CurrencyFormate.Currency(value: Double(jobdetail.offerPrice))(jobdetail.offerPrice.count > 0) ? offerString : NSAttributedString.init(string: "none")
                    if objoffer.promotion.count > 0{
                               if let value =  objoffer.promotion.first!["customer_discount"]{
                                                if let type = objoffer.promotion.first!["type"]{
                                                    if "\(type)" == "amount"{
                                                        if let pi: Double = Double("\(value)"){
                                                            let updatedvalue = String(format:"%.2f", pi)
                                                            cell.lblPromotionOfferAmount.text = "\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))"
                                                        }
                                                    }else{
                                                        cell.lblPromotionOfferAmount.text = "\(value)%"
                                                    }
                                                }
                                                
                                            }
                               cell.viewPromotionContainer.isHidden = false
                           }else{
                               cell.viewPromotionContainer.isHidden = true
                           }
                    UIView.transition(with: cell.viewMore, duration: 0.5,
                                options: .transitionCrossDissolve,
                                animations: {
                                   DispatchQueue.main.async {
                                      cell.btnMore.isSelected = objoffer.isMoreOption
                                      cell.viewMore.isHidden = !objoffer.isMoreOption
                                  }
                            })
                    
                }
                
                
                if let customerDetail = objoffer.customerDetail{
                                              if let imageURL = URL.init(string: "\(customerDetail.profilePic)"){
                                                autoreleasepool {
                                                  cell.imgCustomerLogo!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                                                }
                                              }
                    cell.lblCustomerName.text = customerDetail.isFullNameShow ? "\(customerDetail.firstname) \(customerDetail.lastname)" : "\(customerDetail.firstname)"
//                                          cell.lblCustomerName.text = "\(customerDetail.firstname) \(customerDetail.lastname)"
                                          if  let pi: Double = Double("\(customerDetail.rating)"){
                                              let rating = String(format:"%.1f", pi)
                                              cell.lblrating.text = "\(rating)"
                                          }
                                      }
            }
            
            if indexPath.row+1 == self.arrayofofferjob.count, self.isLoadMore{ //last index
                              DispatchQueue.global(qos: .background).async {
                                  self.currentPage += 1
                               if self.selectedIndex == 0{ //offer
                                   self.callAPIRequestToFetchOfferJOBList()
                               }else if self.selectedIndex == 1 {
                                   self.callAPIRequestToFetchAcceptJOBList()
                               }else if self.selectedIndex == 2 { //inprogress
                                   self.callAPIRequestToFetchInprogressJOBList()
                               }else if self.selectedIndex == 3 { //completed
                                    self.callAPIRequestToFetchCompletedJOBList()
                               }else if self.selectedIndex == 4 { //unsuccessfull
                                    self.callAPIRequestToFetchUnSuccessFullJOBList()
                               }else{
                                   
                               }
                              }
                          }
                cell.tag = indexPath.row
            cell.delegate = self
            cell.lblOfferTime.isHidden = true

           return cell
            
        }else{
        let cell = tableViewProviderOffer.dequeueReusableCell(withIdentifier: "ProviderJOBOfferTableViewCell", for: indexPath) as! ProviderJOBOfferTableViewCell
        
        if  self.selectedIndex == 1 || self.selectedIndex == 2 || self.selectedIndex == 3 || self.selectedIndex == 4{
            cell.deleagate = self
            if self.arrayofofferjob.count  > indexPath.row{
                          let objoffer = self.arrayofofferjob[indexPath.row]
                print(objoffer.offerAttachment)
                cell.viewDocument.isHidden = (objoffer.offerAttachment.count == 0)
                            if objoffer.promotion.count > 0{
                                if let value =  objoffer.promotion.first!["customer_discount"]{
                                    if let type = objoffer.promotion.first!["type"]{
                                        if "\(type)" == "amount"{
                                            if let pi: Double = Double("\(value)"){
                                                let updatedvalue = String(format:"%.2f", pi)
                                                cell.lblPromotionOfferAmount.text = "\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))"
                                            }
                                        }else{
                                            cell.lblPromotionOfferAmount.text = "\(value)%"
                                        }
                                    }
                                }
                                cell.viewPromotionContainer.isHidden = false
                            }else{
                               cell.viewPromotionContainer.isHidden = true
                            }
                           
                          if let jobdetail = objoffer.jobDetail{
                        
                            if let preoff = objoffer.isPreOffer.bool{
                                if preoff{
                                    DispatchQueue.main.async {
                                        cell.viewOfferAmount.isHidden = true
                                        cell.lblAskingPriceName.text = "Agreed Price : "
                                                    }
                                }else{
                                    DispatchQueue.main.async {
                                        cell.viewOfferAmount.isHidden = false
                                        cell.lblAskingPriceName.text = "Budget : "
                                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    cell.viewOfferAmount.isHidden = false
                                    cell.lblAskingPriceName.text = "Budget : "
                                                }
                            }
                            
                            if jobdetail.isForSendOffer{
                                let offerString = NSMutableAttributedString()
                                    if objoffer.promotion.count > 0{
                                             if let pi: Double = Double("\(jobdetail.offerPrice)"){
                                                 let updatedvalue = String(format:"%.2f", pi)
                                                offerString.append("\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))".strikeThrough())
                                                
                                             }
                                             if let pi: Double = Double("\(jobdetail.finalPrice)"){
                                                 let updatedvalue = String(format:"%.2f", pi)
                                                 let newUpdatedValue = NSAttributedString(string:" \(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))",attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
                                                 offerString.append(newUpdatedValue)//(NSAttributedString.init(string: "$\(updatedvalue)"))
                                             }
                                        }else{
                                         if let pi: Double = Double("\(jobdetail.offerPrice)"){
                                             let updatedvalue = String(format:"%.2f", pi)
                                            
                                             let newUpdatedValue = NSAttributedString(string: "\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))",attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])

                                             offerString.append(newUpdatedValue)//(NSAttributedString.init(string:"$\(updatedvalue)"))
                                         }
                                     }
                                if let objOfferVal = jobdetail.offerPrice as? String{
                                    cell.lblOfferAmount.text = CurrencyFormate.Currency(value: Double(objOfferVal) ?? 0)
                                }
                                //cell.lblOfferAmount.attributedText = (jobdetail.offerPrice.count > 0) ? offerString : NSAttributedString.init(string: "none")
                                
                            }else{
                                
                            }
                              cell.lbltitle.text = jobdetail.title
                            let dateformatter = DateFormatter()
                            dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            
                           // arrayofofferjob
                            if selectedIndex == 4 {
                                if let date = dateformatter.date(from: jobdetail.jobcreatedat){
                                    dateformatter.dateFormat = "MM/dd/yyyy\nhh:mm a"
                                    let updatedDate = dateformatter.string(from: date.toLocalTime())
                                    let strDate = "\(updatedDate)"
                                    cell.lblDate.text = "\(strDate)"
                                }
                                //"\(jobdetail.jobcreatedat)".changeDateFormat
                                cell.lblTime.isHidden = true
                                //cell.lblTime.text = self.getTime(time: String(jobdetail.jobcreatedat.suffix(8)))
                            }else if jobdetail.jobCreated.count > 0{
                                if let date = dateformatter.date(from: jobdetail.jobCreated){
                                    dateformatter.dateFormat = "MM/dd/yyyy\nhh:mm a"
                                    let updatedDate = dateformatter.string(from: date.toLocalTime())
                                    let strDate = "\(updatedDate)"
                                    cell.lblDate.text = "\(strDate)"
                                }
                                //cell.lblDate.text = "\(jobdetail.jobCreated)".changeDateFormat
                                cell.lblTime.isHidden = true
                                //cell.lblTime.text = self.getTime(time: String(jobdetail.jobCreated.suffix(8)))
                              }else if jobdetail.createdAt.count > 0{
                                if let date = dateformatter.date(from: jobdetail.createdAt){
                                    dateformatter.dateFormat = "MM/dd/yyyy\nhh:mm a"
                                    let updatedDate = dateformatter.string(from: date.toLocalTime())
                                    let strDate = "\(updatedDate)"
                                    cell.lblDate.text = "\(strDate)"
                                }
                                //cell.lblDate.text = "\(jobdetail.createdAt)".changeDateFormat
                                cell.lblTime.isHidden = true
                                //cell.lblTime.text = self.getTime(time: String(jobdetail.jobCreated.suffix(8)))
                              }else{
                                cell.lblDate.text = " "
                                cell.lblTime.isHidden = true
                                }
                            if let objVal = jobdetail.askingPrice as? String{
                                cell.lblAskingPrice.text = CurrencyFormate.Currency(value: Double(objVal) ?? 0)
                            }
                            //(jobdetail.askingPrice.count > 0) ? "\(jobdetail.askingPrice)".add2DecimalString : "none"
                          }
                          if let customerDetail = objoffer.customerDetail{
                                  if let imageURL = URL.init(string: "\(customerDetail.profilePic)"){
                                    autoreleasepool {
                                      cell.imgCustomerLogo!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                                    }
                                  }
//                            cell.lblCustomerName.text = customerDetail.isFullNameShow ? "\(customerDetail.firstname) \(customerDetail.lastname)" : "\(customerDetail.firstname)"
                              cell.lblCustomerName.text = "\(customerDetail.firstname) \(customerDetail.lastname)"
                              if  let pi: Double = Double("\(customerDetail.rating)"){
                                  let rating = String(format:"%.1f", pi)
                                  cell.lblrating.text = "\(rating)"
                              }
                          }
            }
          
            
            
            if self.selectedIndex == 0{
                cell.btnreportproblem.isHidden = true
                cell.btnContactDetailTop.isHidden = true
                cell.btnJOBDetailTop.isHidden = true
                cell.btnPaymenthistory.isHidden = true
                cell.btnStart.isHidden = true
                cell.btnCustomerDetail.isHidden = false
                cell.btnJOBDetailbottom.isHidden = false
                cell.btnSendOffer.isHidden = false
                cell.btnPayment.isHidden = true
            }else if self.selectedIndex == 1{
               cell.btnreportproblem.isHidden = true
                cell.btnContactDetailTop.isHidden = false
                cell.btnJOBDetailTop.isHidden = true
                cell.btnPaymenthistory.isHidden = true
                cell.btnStart.isHidden = false
                cell.btnCustomerDetail.isHidden = false
                cell.btnJOBDetailbottom.isHidden = false
                cell.btnSendOffer.isHidden = true
                cell.btnPayment.isHidden = true
            }else if self.selectedIndex == 2{
                cell.btnreportproblem.isHidden = false
                cell.btnContactDetailTop.isHidden = false
                cell.btnJOBDetailTop.isHidden = true
                cell.btnPaymenthistory.isHidden = true
                cell.btnStart.isHidden = true
                cell.btnCustomerDetail.isHidden = false
                cell.btnJOBDetailbottom.isHidden = false
                cell.btnSendOffer.isHidden = true
                cell.btnPayment.isHidden = false
            }else if self.selectedIndex == 3{
                cell.btnreportproblem.isHidden = true
                cell.btnContactDetailTop.isHidden = true
                cell.btnJOBDetailTop.isHidden = false
                cell.btnPaymenthistory.isHidden = false
                cell.btnStart.isHidden = true
                cell.btnCustomerDetail.isHidden = false
                cell.btnJOBDetailbottom.isHidden = true
                cell.btnSendOffer.isHidden = true
                cell.btnPayment.isHidden = true
            }else if self.selectedIndex == 4{
                cell.btnreportproblem.isHidden = true
                cell.btnContactDetailTop.isHidden = true
                cell.btnJOBDetailTop.isHidden = true
                cell.btnPaymenthistory.isHidden = true
                cell.btnStart.isHidden = true
                cell.btnCustomerDetail.isHidden = false
                cell.btnJOBDetailbottom.isHidden = false
                cell.btnSendOffer.isHidden = true
                cell.btnPayment.isHidden = true
                cell.lblDate.isHidden = false
                cell.lblTime.isHidden = false
            }else{
                cell.btnreportproblem.isHidden = true
                cell.btnContactDetailTop.isHidden = true
                cell.btnJOBDetailTop.isHidden = true
                cell.btnPaymenthistory.isHidden = true
                cell.btnStart.isHidden = true
                cell.btnCustomerDetail.isHidden = true
                cell.btnJOBDetailbottom.isHidden = true
                cell.btnSendOffer.isHidden = true
                cell.btnPayment.isHidden = true
            }
        }else{
            cell.btnreportproblem.isHidden = true
            cell.btnJOBDetailTop.isHidden = true
            cell.btnPaymenthistory.isHidden = true
            cell.btnStart.isHidden = true
            cell.btnCustomerDetail.isHidden = true
            cell.btnJOBDetailbottom.isHidden = true
            cell.btnSendOffer.isHidden = true
            cell.btnPayment.isHidden = true
        }
        
        if indexPath.row+1 == self.arrayofofferjob.count, self.isLoadMore{ //last index
                       DispatchQueue.global(qos: .background).async {
                           self.currentPage += 1
                        if self.selectedIndex == 0{ //offer
                            self.callAPIRequestToFetchOfferJOBList()
                        }else if self.selectedIndex == 1 {
                            self.callAPIRequestToFetchAcceptJOBList()
                        }else if self.selectedIndex == 2 { //inprogress
                            self.callAPIRequestToFetchInprogressJOBList()
                        }else if self.selectedIndex == 3 { //completed
                             self.callAPIRequestToFetchCompletedJOBList()
                        }else if self.selectedIndex == 4 { //unsuccessfull
                             self.callAPIRequestToFetchUnSuccessFullJOBList()
                        }else{
                            
                        }
                       }
                   }
         cell.tag = indexPath.row
        
        
        return cell
              }
    }
    func getTime(time:String) -> String{
        let actualTime = time.prefix(5)
        let hours = time.prefix(2)
        let actualHours = Int(hours)
        var ampm : String = ""
        ampm = (actualHours! % 12 >= 12) ? "PM" : "AM"
        let timestr = actualTime + " " + ampm
        return timestr
    }
}
extension MyJobViewController:OfferProviderTableCellDelegate,ProviderOfferUpdateCellDelegate{
    
    func buttonDeleteJOBWith(index: Int) {
        if self.arrayofofferjob.count > index{
        let objOfferDetail = self.arrayofofferjob[index]
         
            let alert = UIAlertController(title: AppName, message: "Are you sure you want to delete this job?", preferredStyle: .alert)
                         
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
    }
         
            
        func callDeletePostAPIRequest(jodId:String){
            let dict:[String:Any] = [
            "job_id" : "\(jodId)"
            ]

            APIRequestClient.shared.sendAPIRequest(requestType: .DELETE, queryString:kDeleteOffer , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in

            if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [String]{
                DispatchQueue.main.async {
                    self.objMapView.clear()
                               self.configureSelectedIndex()
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
                        //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                    }
                }
            }
        }
    func buttonWithDrawWith(index: Int) {
        if self.arrayofofferjob.count > index{
               let objOfferDetail = self.arrayofofferjob[index]
                
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
                           self.configureSelectedIndex()
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
                   // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
    }
    func buttonMoreProviderCellClick(index: Int) {
        if self.arrayofofferjob.count > index{
            let objoffer = self.arrayofofferjob[index]
            objoffer.isMoreOption =  !objoffer.isMoreOption
            DispatchQueue.main.async {
                self.tableViewProviderOffer.reloadData()
            }
        }
    }
    func buttonJOBDetailWith(index: Int) {
        if self.arrayofofferjob.count > index{
            let objoffer = self.arrayofofferjob[index]
            if let job = objoffer.jobDetail{
                self.pushToJOBDetailViewController(withJOBID: job.jobID)
            }
        }
    }
    func buttonContactDetailWith(index: Int) {
        if self.arrayofofferjob.count > index{
            let objoffer = self.arrayofofferjob[index]
            self.pushToProviderToCustomerChatViewController(offerDetail: objoffer)
            
        }
    }
    func pushToProviderToCustomerChatViewController(offerDetail:OfferDetail){
        if let chatViewConroller = UIStoryboard.messages.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC{
                   chatViewConroller.hidesBottomBarWhenPushed = true
                   if let customer = offerDetail.customerDetail{
                    if self.selectedIndex == 0{
                        chatViewConroller.strReceiverName = "\(customer.firstname)" //\(customer.lastname)"
                    }else{
                        chatViewConroller.strReceiverName = "\(customer.firstname) \(customer.lastname)"
                    }
                       
                       chatViewConroller.strReceiverProfileURL = "\(customer.profilePic)"
                       chatViewConroller.receiverID = "\(customer.userId)"
                      chatViewConroller.senderID = "\(customer.quickblox_id)"
                      chatViewConroller.toUserTypeStr = "customer"
                   }
                   chatViewConroller.isForCustomerToProvider = false
                   self.navigationController?.pushViewController(chatViewConroller, animated: true)
               }
    }
    func buttonSendOfferWith(index: Int) {
        if self.arrayofofferjob.count > index{
            let objoffer = self.arrayofofferjob[index]
            self.pushtosendofferviewcontrollewith(offerdetail: objoffer)
        }
    }
    func buttonAttachmentSelectorWith(index:Int){
        if self.arrayofofferjob.count > index{
              let objOffer = self.arrayofofferjob[index]
            
            if objOffer.offerAttachment.count > 0{
                    if let objAttachment =  objOffer.offerAttachment.first!["image"] as? String{
                        self.presentWebViewDetailPageWith(strTitle: "Attachment", strURL: "\(objAttachment)")
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
    func buttonCustomerDetailWith(index: Int) {
        if self.arrayofofferjob.count > index{
            let objoffer = self.arrayofofferjob[index]
            self.pushToCustomerDetailViewController(objOfferDetail: objoffer)
        }
    }
    func buttonStartSelector(index: Int) {
        if self.selectedIndex == 1,self.arrayofofferjob.count > index{
            let objoffer = self.arrayofofferjob[index]
            if let jobdetail = objoffer.jobDetail{
                self.callAPIRequestToStartJOB(jobid: jobdetail.jobID)
            }
            
        }
    }
    func buttonPromotionDetailSelector(index: Int) {
        if self.arrayofofferjob.count > index{
                    let objOffer = self.arrayofofferjob[index]
            if let objStory = UIStoryboard.main.instantiateViewController(withIdentifier: "PromotionAlertViewController") as? PromotionAlertViewController{
                        objStory.modalPresentationStyle = .overFullScreen
                        if objOffer.promotion.count > 0{
                            objStory.objPromotion = Promotion.init(promotionDetail: objOffer.promotion.first!)
                        }
                        self.present(objStory, animated: true, completion: nil)
                    }
        }
    }
    func buttonPaymentSelector(index: Int) {
        if self.selectedIndex == 2,self.arrayofofferjob.count > index{
              let objoffer = self.arrayofofferjob[index]
            DispatchQueue.main.async {
                 //SAAlertBar.show(.error, message:"Under Development".localizedLowercase)
                if let jobID = objoffer.jobDetail?.jobID{
                    if let customerDetail = objoffer.customerDetail{
                        self.pushtoViewPaymentViewController(jobID: jobID,customerName:"\(customerDetail.firstname) \(customerDetail.lastname)")
                    }
                }
            }
        }
    }
    func buttonReportProblemSelector(index: Int) {
        if self.arrayofofferjob.count > index{
                     let objoffer = self.arrayofofferjob[index]
                    self.pushtoReportProblemViewController(offerDetail: objoffer)
                   
               }
    }
    func buttonPaymentHistorySelector(index: Int) {
        if self.arrayofofferjob.count > index{
                     let objoffer = self.arrayofofferjob[index]
            
                   DispatchQueue.main.async {
                    if let jobID = objoffer.jobDetail?.jobID{
                        self.pushtoPaymentHistoryViewController(jobID: jobID)
                    }
                    //    SAAlertBar.show(.error, message:"Under Development".localizedLowercase)
                   }
               }
    }
    func pushtoPaymentHistoryViewController(jobID:String){
            if let paymentHistory = UIStoryboard.activity.instantiateViewController(withIdentifier: "ProviderPaymentHistoryViewController") as? ProviderPaymentHistoryViewController{
                paymentHistory.isForJOBSpecific = true
                paymentHistory.jobId = jobID
                paymentHistory.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(paymentHistory, animated: true)
            }
        }
    func pushtoViewPaymentViewController(jobID:String,customerName:String){
            if let paymentHistory = UIStoryboard.activity.instantiateViewController(withIdentifier: "ViewPaymentViewController") as? ViewPaymentViewController{
                paymentHistory.job_id = jobID
                paymentHistory.customerName = customerName
                paymentHistory.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(paymentHistory, animated: true)
            }
        }
    
}

extension MyJobViewController:GMSMapViewDelegate{
    
}
