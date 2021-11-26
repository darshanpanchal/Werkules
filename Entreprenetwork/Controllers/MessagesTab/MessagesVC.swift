//
//  MessagesVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 27/07/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import GoogleMaps


//@available(iOS 13.0, *)
class MessagesVC: UIViewController,UITableViewDelegate,UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var tblViewMessages: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNoJobExists: UILabel!
    @IBOutlet weak var btnToggle: UIButton!
    
    @IBOutlet weak var objMapView:GMSMapView!
    
    var isLoadMore:Bool = false
    var currentPage:Int = 1
    var fetchPageLimit:Int = 50
    var arrayofofferjob:[NotifiedProviderOffer] = []
    
    
    
    var arrMyJobs = NSMutableArray()
    var arrAppliedJobs = NSMutableArray()
    var assignedArray = NSMutableArray()
    var pendingArray = NSMutableArray()
    var completedArray = NSMutableArray()
    
    @IBOutlet weak var objSegmentConroller:UISegmentedControl!
    
    
    @IBOutlet weak var messageViewContainer:UIView!
    @IBOutlet weak var lblMessageJOBStarted:UILabel!
    @IBOutlet weak var heightOfMessage:NSLayoutConstraint!


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
    var locationManager: CLLocationManager = CLLocationManager()
    
    var currentLat = Double()
    var currentLong = Double()
    
    var isFromHomeBooking:Bool = false
    
    var selected:Int = 0
        
    var selectedIndex:Int{
        get{
            return selected
        }
        set{
            self.selected = newValue
            //Configure Selected Index
            DispatchQueue.main.async {
                self.objSegmentConroller.selectedSegmentIndex = newValue
                self.configureSelectedIndex()
            }
        }
    }
    var selectedIndexFromNotification:Int?
    
    // MARK: - UIView Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup
        self.setup()
        
        self.mylocation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: .updateMyPostTab, object: nil)
        
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fixBackgroundSegmentControl(self.objSegmentConroller)
        
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
    @objc func methodOfReceivedNotification(notification: Notification) {
        
        /*
        DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
            self.isLoadMore = false
            self.currentPage = 1
            self.arrayofofferjob.removeAll()
            self.tblViewMessages.reloadData()
            self.getMyPostCountAPIRequest()
        }*/
        
        print("----- \(notification.userInfo)")
        //Offer
        //Not started
        //In progress
        //Completed
        //Unsuccessful Offers
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            if let userInfo = notification.userInfo{
                
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    
                    if let offerInt = userInfo["offer"] as? Int,let notStarted = userInfo["not_started"] as? Int, let inprogress = userInfo["in_progress"] as? Int{
                     
                            let filterArray = self.arrayofofferjob.filter{ $0.isPreOffer == "0"}
                            
                               if offerInt > 0{
                                if self.objSegmentConroller.selectedSegmentIndex != 0{
                                    //Green Animation
                                    self.selectedIndex =  0 //offer
                                }
                                 
                              }else{
                                if offerInt == 0 && notStarted > 0{
                                    if self.objSegmentConroller.selectedSegmentIndex != 1{
                                        
                                        self.selectedIndex =  1 //not started
                                    }
//                                    self.selectedIndex =  1 //not started
                                }else if inprogress > 0{
                                    if self.objSegmentConroller.selectedSegmentIndex != 2{
                                        
                                        self.selectedIndex =  2 //inprogress
                                    }
                                    //self.selectedIndex = 2 //inprogress
                                }else{
                                    if self.objSegmentConroller.selectedSegmentIndex != 0{
                                        //Green Animation
                                        self.selectedIndex =  0 //offer
                                    }
                                }
                              }
                           }
                }
            }
        }
        
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
        
       let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "#08405D"),NSAttributedString.Key.font:UIFont(name: "Avenir Medium", size: 12)]
        let selectedtitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font:UIFont(name: "Avenir Medium", size: 12)]

        self.objSegmentConroller.setTitleTextAttributes(titleTextAttributes, for: .normal)
        self.objSegmentConroller.setTitleTextAttributes(selectedtitleTextAttributes, for: .selected)

        self.objSegmentConroller.addTarget(self, action: #selector(MessagesVC.indexChanged(_:)), for: .valueChanged)
        self.objSegmentConroller.layer.borderWidth = 0.7
        self.objSegmentConroller.layer.borderColor = UIColor.init(hex: "#08405D").cgColor
        
//        self.objSegmentConroller.setWidth(60, forSegmentAt: 0)
        self.objSegmentConroller.setWidth(80, forSegmentAt: 3)
//        self.objSegmentConroller.setWidth(70, forSegmentAt: 4)
        self.objSegmentConroller.apportionsSegmentWidthsByContent = true
        
        self.messageViewContainer.clipsToBounds = true
        self.messageViewContainer.layer.cornerRadius = 6.0
        RegisterCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
//            self.getMyPostCountAPIRequest()
            self.callAPIRequestToGetChatUnreadCount()
        }

        self.currentPage = 1
        self.isLoadMore = false
        self.arrayofofferjob.removeAll()
        
         /*if self.isFromHomeBooking{
            self.objSegmentConroller.selectedSegmentIndex = 1
            self.selectedIndex = 1
        }else{
            */
            if let _ = self.selectedIndexFromNotification{
                self.objSegmentConroller.selectedSegmentIndex =  self.selectedIndexFromNotification!
                self.selectedIndex = self.selectedIndexFromNotification!
            }else{
                self.selectedIndex = self.objSegmentConroller.selectedSegmentIndex
                //self.objSegmentConroller.selectedSegmentIndex = 0
                //self.selectedIndex = 0
            }
        
//            self.selectedIndex = self.objSegmentConroller.selectedSegmentIndex
        //}
        
        
    }
    func getMyPostCountAPIRequest(){
        APIRequestClient.shared.sendAPIRequest(requestType: .GET, queryString:kGETCustomerMyPostCount , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                 if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                                    DispatchQueue.main.async {
                                        
                                        if let offerInt = userInfo["offer"] as? Int,let notStarted = userInfo["not_started"] as? Int, let inprogress = userInfo["in_progress"] as? Int{
                                                if offerInt > 0{
                                                     //Green Animation
                                                     self.selectedIndex =  0 //offer
                                                  }else{
                                                    if offerInt == 0 && notStarted > 0{
                                                        self.selectedIndex =  1 //not started
                                                    }else if inprogress > 0{
                                                        self.selectedIndex = 2 //inprogress
                                                    }else{
                                                        self.selectedIndex =  self.objSegmentConroller.selectedSegmentIndex//0 //offer
                                                    }
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
                                      // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                   }
                               }
                           }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        self.locationManager.stopUpdatingLocation()
        self.selectedIndexFromNotification = nil
//        self.arrayofofferjob = []
        
    }
    // MARK: - User Methods
    func configureSelectedIndex(){
        APIRequestClient.shared.cancelTaskWithUrl { response in
            self.currentPage = 1
            self.isLoadMore = false
            self.arrayofofferjob.removeAll()
            self.tblViewMessages.reloadData()
            self.btnToggle.isHidden = true//(self.selectedIndex != 0)


            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                if self.selectedIndex == 0{ //offer
                    self.callAPIRequestToFetchOfferJOBList()
                }else if self.selectedIndex == 1 {
                    self.callAPIRequestToFetchNotStartedJOBList()
                }else if self.selectedIndex == 2 {
                    self.callAPIRequestToFetchInProgressJOBList()
                }else if self.selectedIndex == 3 {
                    self.callAPIRequestToFetchCompletedJOBList()
                }else if self.selectedIndex == 4 {
                    self.callAPIRequestToNoOfferJOBList()

                }else{

                }
            }
            if self.selectedIndex == 1{
                self.messageViewContainer.isHidden = false
                self.heightOfMessage.constant = 50.0
              self.lblNoJobExists.isHidden = false
            }else{
                self.heightOfMessage.constant = 0.0
                self.messageViewContainer.isHidden = true
              self.lblNoJobExists.isHidden = true
            }
            DispatchQueue.main.async {
                self.tblViewMessages.reloadData()
            }
        }
    }
    @objc func indexChanged(_ sender: UISegmentedControl) {

        self.selectedIndex = self.objSegmentConroller.selectedSegmentIndex
    }
    // MARK: - Register Cell
    
    func RegisterCell()  {
        self.tblViewMessages.estimatedRowHeight = 150.0
        self.tblViewMessages.rowHeight = UITableView.automaticDimension
        self.tblViewMessages.allowsSelection = true
        self.tblViewMessages.tableFooterView = UIView()
        self.tblViewMessages.delegate = self
        self.tblViewMessages.dataSource = self
        self.tblViewMessages.reloadData()
        let objnib = UINib.init(nibName:"CustommerOfferTableViewCell", bundle: nil)
        self.tblViewMessages.register(objnib, forCellReuseIdentifier: "CustommerOfferTableViewCell")
        let objUpdatednib = UINib.init(nibName:"CustomerOfferUpdatedTableViewCell", bundle: nil)
        self.tblViewMessages.register(objUpdatednib, forCellReuseIdentifier: "CustomerOfferUpdatedTableViewCell")
        let objnibnotstarted = UINib.init(nibName:"CustomerNotStartedUpdatedTableViewCell", bundle: nil)
        self.tblViewMessages.register(objnibnotstarted, forCellReuseIdentifier: "CustomerNotStartedUpdatedTableViewCell")
        let objnibInprogress = UINib.init(nibName:"CustomerInprogressUpdatedTableViewCell", bundle: nil)
        self.tblViewMessages.register(objnibInprogress, forCellReuseIdentifier: "CustomerInprogressUpdatedTableViewCell")
        let objnibCompleted = UINib.init(nibName:"CustomerCompletedUpdatedTableViewCell", bundle: nil)
        self.tblViewMessages.register(objnibCompleted, forCellReuseIdentifier: "CustomerCompletedUpdatedTableViewCell")
        let objnibUnsuccessful = UINib.init(nibName:"CustomerUnsuccessfulOfferUpdatedTableViewCell", bundle: nil)
        self.tblViewMessages.register(objnibUnsuccessful, forCellReuseIdentifier: "CustomerUnsuccessfulOfferUpdatedTableViewCell")


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
//        CATransaction.begin()
//        CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
        DispatchQueue.main.async {
            self.objMapView.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: 15))
        }
//        CATransaction.commit()
        /*let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setCenter(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), animated: true)*/
    }
    // MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.selectedIndex == 0 || self.selectedIndex == 1 || self.selectedIndex == 2 || self.selectedIndex == 3 || self.selectedIndex == 4{
            return self.arrayofofferjob.count
        }else{
            return 0
        }
        
      
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     
        if self.selectedIndex == 0 {
            if self.arrayofofferjob.count > indexPath.row {
                   let objoffer  = self.arrayofofferjob[indexPath.row]
                if let preoff = objoffer.isPreOffer.bool{
                    if preoff{
                        return 120.0
                    }else{
                        return (objoffer.promotion.count > 0 ) ? 300.0 : 270.0
                    }
                }else{
                    return UITableView.automaticDimension
                }
            }else {
                return UITableView.automaticDimension
            }
        }else if self.selectedIndex == 1{ //New UI
            if self.arrayofofferjob.count > indexPath.row {
                   let objoffer  = self.arrayofofferjob[indexPath.row]
                if let preoff = objoffer.isPreOfferDirectBook.bool{
                    if preoff{
                        return 210.0
                    }else{
                        return (objoffer.promotion.count > 0 ) ? 300 : 270
                    }
                }else{
                    return 270.0
                }
            }else {
                return 270.0
            }
        }else if self.selectedIndex == 2{ //New UI
            if self.arrayofofferjob.count > indexPath.row {
                   let objoffer  = self.arrayofofferjob[indexPath.row]
                if let preoff = objoffer.isPreOfferDirectBook.bool{
                    if preoff{
                        return 210.0
                    }else{
                        return (objoffer.promotion.count > 0 ) ? 300 : 270
                    }
                }else{
                    return 270.0
                }
            }else {
                return 270.0
            }
        }else if self.selectedIndex == 3{ //New UI
            if self.arrayofofferjob.count > indexPath.row {
                   let objoffer  = self.arrayofofferjob[indexPath.row]
                if let preoff = objoffer.isPreOfferDirectBook.bool{
                    if preoff{
                        return 210.0
                    }else{
                        return (objoffer.promotion.count > 0 ) ? 300 : 270
                    }
                }else{
                    return 270.0
                }
            }else {
                return 270.0
            }
        }else if self.selectedIndex == 4{ //New UI

            //return UITableView.automaticDimension

            if self.arrayofofferjob.count > indexPath.row {
                   let objoffer  = self.arrayofofferjob[indexPath.row]
                if let preoff = objoffer.isPreOfferDirectBook.bool{
                    if preoff{
                        return 120.0
                    }else{
                        return (objoffer.promotion.count > 0 ) ? 210.0 : 180.0
                    }
                }else{
                    return UITableView.automaticDimension
                }
            }else {
                return UITableView.automaticDimension
            }
        }/*else if self.selectedIndex == 2 || self.selectedIndex == 1{ //old UI
            if self.arrayofofferjob.count > indexPath.row {
                   let objoffer  = self.arrayofofferjob[indexPath.row]
                if let preoff = objoffer.isPreOfferDirectBook.bool{
                    if preoff{
                        return 270.0
                    }else{
                        return 320.0
                    }
                }else{
                    return 320.0
                }
            }else {
                return 320.0
            }
        }else if self.selectedIndex == 4{
            let objoffer  = self.arrayofofferjob[indexPath.row]
            if objoffer.promotion.count > 0 {
                return 160.0
            }else{
                return 130.0
            }
        }else if self.selectedIndex == 3{
            if self.arrayofofferjob.count > indexPath.row {
                   let objoffer  = self.arrayofofferjob[indexPath.row]
                if let preoff = objoffer.isPreOfferDirectBook.bool{
                    if preoff{
                        return 270.0
                    }else{
                        return 340.0
                    }
                }else{
                    return 340.0
                }
            }else {
                return 340.0
            }
        }*/else{
            return 320.0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.selectedIndex == 0{
            let cell = tblViewMessages.dequeueReusableCell(withIdentifier: "CustomerOfferUpdatedTableViewCell", for: indexPath) as! CustomerOfferUpdatedTableViewCell
            cell.delegate = self
            if self.arrayofofferjob.count > indexPath.row {
                      let objoffer  = self.arrayofofferjob[indexPath.row]
                cell.viewDocument.isHidden = (objoffer.offerAttachment.count == 0)
                if let preoff = objoffer.isPreOffer.bool{
                    DispatchQueue.main.async {
                        cell.configureOfferCell(isPreOffer: preoff)
                    }
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    if preoff{
                        if objoffer.createdAt.count > 0{
                            if let date = dateformatter.date(from: objoffer.createdAt){
                                dateformatter.dateFormat = "MM/dd/yyyy\nhh:mm a"
                                let updatedDate = dateformatter.string(from: date.toLocalTime())//"\(objProvider.offerDate)" + "\(timeStr)"//
                           cell.lblOfferDate.text = "Post Date: \(updatedDate)"
                            //cell.lblOfferTime.text = self.getTime(time: String(objoffer.createdAt.suffix(8)))
                            }
                        }else{
                           cell.lblOfferDate.text = "Post Date: none"
                           // cell.lblOfferTime.text = " "
                        }
                    }else{
                        if objoffer.offerDate.count > 0{
                            if let date = dateformatter.date(from: objoffer.offerDate){
                                dateformatter.dateFormat = "MM/dd/yyyy\nhh:mm a"
                                let updatedDate = dateformatter.string(from: date.toLocalTime())//"\(objProvider.offerDate)" + "\(timeStr)"//
                            cell.lblOfferDate.text = "Offer Date: \(updatedDate)"
                         }//cell.lblOfferTime.text = self.getTime(time: String(objoffer.offerDate.suffix(8)))
                        }else{
                           cell.lblOfferDate.text = "Offer Date: none"
                            //cell.lblOfferTime.text = self.getTime(time: String(objoffer.offerDate.suffix(8)))
                        }
                    }
                }else{
                    print("===== \(false)")
                    DispatchQueue.main.async {
                        cell.configureOfferCell(isPreOffer: false)
                    }
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    if objoffer.offerDate.count > 0{
                        if let date = dateformatter.date(from: objoffer.offerDate){
                            dateformatter.dateFormat = "MM/dd/yyyy\nhh:mm a"
                            let updatedDate = dateformatter.string(from: date.toLocalTime())
                            cell.lblOfferDate.text = "Offer Date: \(updatedDate)"
                        }
                        //cell.lblOfferTime.text = self.getTime(time: String(objoffer.offerDate.suffix(8)))
                    }else{
                       cell.lblOfferDate.text = "Offer Date: none"
                       //cell.lblOfferTime.text = self.getTime(time: String(objoffer.offerDate.suffix(8)))
                    }
                }
                UIView.performWithoutAnimation {
                    DispatchQueue.main.async {
                       cell.btnMore.isSelected = objoffer.isMoreOption
                       cell.viewMore.isHidden = !objoffer.isMoreOption
                   }
                }
                /*
                UIView.transition(with: cell.viewMore, duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                             
                      })*/
                
                       cell.lbltitle.text = objoffer.title
                if objoffer.estimateBudget.count > 0{
                    if let pi: Double = Double("\(objoffer.estimateBudget)"){
                                     let updatedvalue = String(format:"%.2f", pi)
                        cell.lblAskingPrice.text = CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)//"$\(updatedvalue)"
                                 }
                    //cell.lblAskingPrice.text = "$\(objoffer.estimateBudget)"
                }else{
                    cell.lblAskingPrice.text = "none"
                }
                
                let offerString = NSMutableAttributedString()
                         if objoffer.promotion.count > 0{
                               
                             if let value =  objoffer.promotion.first!["customer_discount"]{
                                 if let type = objoffer.promotion.first!["type"]{
                                  if "\(type)" == "amount"{
                                    if let pi: Double = Double("\(value)"){
                                       let updatedvalue = String(format:"%.2f", pi)
                                        cell.lblPromotionOfferAmount.text = CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)//"$\(updatedvalue)"
                                    }
                                      //cell.lblPromotionOfferAmount.text = "$\(value)"
                                  }else{
                                      cell.lblPromotionOfferAmount.text = "\(value)%"
                                  }
                                 }
                             }
                             if objoffer.offerPrice.count > 0 && objoffer.finalPrice.count > 0{
                                if let pi: Double = Double("\(objoffer.offerPrice)"){
                                    let updatedvalue = String(format:"%.2f", pi)
                                    offerString.append("\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))".strikeThrough())
                                }
                                if let pi: Double = Double("\(objoffer.finalPrice)"){
                                    let updatedvalue = String(format:"%.2f", pi)
                                    offerString.append(NSAttributedString.init(string: " \(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))"))
                                }
                             }else{
                                 offerString.append(NSAttributedString.init(string: "none"))
                             }
                              
                           }else{
                             cell.lblPromotionOfferAmount.text = "none"
                             if objoffer.offerPrice.count > 0{
                                if let pi: Double = Double("\(objoffer.offerPrice)"){
                                    let updatedvalue = String(format:"%.2f", pi)
                                    offerString.append(NSAttributedString.init(string: "\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))"))
                                }
                             }else{
                                 offerString.append(NSAttributedString.init(string: "none"))
                             }
                               
                           }
                if objoffer.promotion.count > 0 {//&& (self.selectedIndex == 0 || self.selectedIndex == 1  || self.selectedIndex == 2){
                             cell.viewPromotionContainer.isHidden = false
                         }else{
                             cell.viewPromotionContainer.isHidden = true
                         }
                        print("======= \(offerString)")
                        offerString.append(NSAttributedString.init(string: " "))
                            //cell.lblOfferPrice.text = "$\(objoffer.offerPrice)"
                           cell.lblOfferPrice.attributedText = offerString
                           
                           
                           if let imageURL = URL.init(string: "\(objoffer.businessLogo)"){
                               cell.businessLogo!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                           }
                           cell.lblBusinessName.text = objoffer.businessName
                            if let pi: Double = Double("\(objoffer.rating)"){
                                let updatedvalue = String(format:"%.1f", pi)
                                cell.lblRating.text = "\(updatedvalue)"
                            }
                           cell.btnAttachment.isHidden = (objoffer.offerAttachment.count == 0)
                           cell.btnNoAttachment.isHidden = (objoffer.offerAttachment.count != 0)
//                           if objoffer.acceptedPrice.count > 0{
//                               cell.lblAcceptedPrice.text = "$\(objoffer.acceptedPrice)"
//                           }else{
//                               cell.lblAcceptedPrice.text = "none"
//                           }
               
                if objoffer.createdAt.count > 0{
                    cell.lbldateofpost.text = objoffer.createdAt.changeDateFormat
                }else{
                    cell.lbldateofpost.text = "none"
                }
            }
            
            
            if indexPath.row+1 == self.arrayofofferjob.count, self.isLoadMore{ //last index
                              DispatchQueue.global(qos: .background).async {
                                  self.currentPage += 1
                               if self.selectedIndex == 0{ //offer
                                   self.callAPIRequestToFetchOfferJOBList()
                               }else if self.selectedIndex == 1 {  // not started
                                   self.callAPIRequestToFetchNotStartedJOBList()
                               }else if self.selectedIndex == 2 {  //Inprogress
                                   self.callAPIRequestToFetchInProgressJOBList()
                               }else if self.selectedIndex == 3 {  // Completed
                                   self.callAPIRequestToFetchCompletedJOBList()
                               }else if self.selectedIndex == 4 {  // No Offer
                                   self.callAPIRequestToNoOfferJOBList()
                               }else{
                                   
                               }
                                 
                              }
                          }
                   cell.tag = indexPath.row
                   cell.delegate = self
            return cell
        }else if self.selectedIndex == 1{
            let cell = tblViewMessages.dequeueReusableCell(withIdentifier: "CustomerNotStartedUpdatedTableViewCell", for: indexPath) as! CustomerNotStartedUpdatedTableViewCell
            
            if self.arrayofofferjob.count > indexPath.row {
                let objoffer  = self.arrayofofferjob[indexPath.row]
                DispatchQueue.main.async {
                    cell.lbltitle.text = objoffer.title
                    
                    if let preoff = objoffer.isPreOfferDirectBook.bool{
                        if preoff{ //agreed price for direct book
                            cell.viewDocument.isHidden = true
                            cell.viewAcceptedPrice.isHidden = true
                            cell.lblAskingPriceName.text = "Agreed Price : "
                        }else{ //Configure for not a direct book
                            cell.viewDocument.isHidden = false
                            cell.viewAcceptedPrice.isHidden = false
                            cell.lblAskingPriceName.text = "Budget : "
                        }
                    }else{ //Configure for not a direct book
                        cell.viewDocument.isHidden = false
                        cell.viewAcceptedPrice.isHidden = false
                        cell.lblAskingPriceName.text = "Budget : "
                    }
                    if objoffer.askingPrice.count > 0{
                        if let pi: Double = Double("\(objoffer.askingPrice)"){
                            let updatedvalue = String(format:"%.2f", pi)
                            cell.lblAskingPrice.text = CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)//"$\(updatedvalue)"
                           }
                    }else{
                        cell.lblAskingPrice.text = "none"
                    }
                    
                    cell.btnAttachment.isHidden = (objoffer.offerAttachment.count == 0)
                    cell.btnNoAttachment.isHidden = (objoffer.offerAttachment.count != 0)
                    let offerString = NSMutableAttributedString()
                    if objoffer.promotion.count > 0 {
                        cell.viewPromotionContainer.isHidden = false
                        if let value =  objoffer.promotion.first!["customer_discount"]{
                            if let type = objoffer.promotion.first!["type"]{
                             if "\(type)" == "amount"{
                               if let pi: Double = Double("\(value)"){
                                  let updatedvalue = String(format:"%.2f", pi)
                                   cell.lblPromotionOfferAmount.text = CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)
                               }
                             }else{
                                 cell.lblPromotionOfferAmount.text = "\(value)%"
                             }
                            }
                        }
                        if objoffer.offerPrice.count > 0 && objoffer.finalPrice.count > 0{
                           if let pi: Double = Double("\(objoffer.offerPrice)"){
                               let updatedvalue = String(format:"%.2f", pi)
                               offerString.append("\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))".strikeThrough())
                           }
                           if let pi: Double = Double("\(objoffer.finalPrice)"){
                               let updatedvalue = String(format:"%.2f", pi)
                               offerString.append(NSAttributedString.init(string: " \(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))"))
                           }
                        }else{
                            offerString.append(NSAttributedString.init(string: "none"))
                        }
                    }else{
                        cell.lblPromotionOfferAmount.text = "none"
                        cell.viewPromotionContainer.isHidden = true
                        if objoffer.offerPrice.count > 0{
                           if let pi: Double = Double("\(objoffer.offerPrice)"){
                               let updatedvalue = String(format:"%.2f", pi)
                               offerString.append(NSAttributedString.init(string: "\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))"))
                           }
                        }else{
                            offerString.append(NSAttributedString.init(string: "none"))
                        }
                    }
                    //Based on Offer and new UI for sprint 9
                    cell.lblAcceptedPrice.attributedText = offerString
                    
                    if objoffer.dateOfPost.count > 0{
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        if let date = dateformatter.date(from: objoffer.dateOfPost){
                            dateformatter.dateFormat = "MM/dd/yyyy hh:mm a"
                            let updatedDate = dateformatter.string(from: date.toLocalTime())
                            cell.lblDateOfPost.text = "\(updatedDate)"
                        }else{
                            cell.lblDateOfPost.text = objoffer.dateOfPost.changeDateFormat
                        }
                      }else{
                        cell.lblDateOfPost.text = "none"
                      }
                    if objoffer.dateOfferAccepted.count > 0{
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        if let date = dateformatter.date(from: objoffer.dateOfferAccepted){
                            dateformatter.dateFormat = "MM/dd/yyyy hh:mm a"
                            let updatedDate = dateformatter.string(from: date.toLocalTime())
                            cell.lblDateOfAccepted.text = "\(updatedDate)"
                        }else{
                            cell.lblDateOfAccepted.text =  objoffer.dateOfferAccepted.changeDateFormat
                        }
                        
                    }else{
                         cell.lblDateOfAccepted.text = "none"
                    }
                    if let imageURL = URL.init(string: "\(objoffer.businessLogo)"){
                        cell.businessLogo!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                    }
                    cell.lblBusinessName.text = objoffer.businessName
                     if let pi: Double = Double("\(objoffer.rating)"){
                         let updatedvalue = String(format:"%.1f", pi)
                         cell.lblRating.text = "\(updatedvalue)"
                     }
                }
                
                
                UIView.performWithoutAnimation {
                    DispatchQueue.main.async {
                       cell.btnMore.isSelected = objoffer.isMoreOption
                       cell.viewMore.isHidden = !objoffer.isMoreOption
                   }
                }
            }
            
            if indexPath.row+1 == self.arrayofofferjob.count, self.isLoadMore{ //last index
                              DispatchQueue.global(qos: .background).async {
                                self.currentPage += 1
                                self.callAPIRequestToFetchNotStartedJOBList()
                              }
            }
            cell.tag = indexPath.row
            cell.delegate = self
            return cell
        }else if self.selectedIndex == 2{
            let cell = tblViewMessages.dequeueReusableCell(withIdentifier: "CustomerInprogressUpdatedTableViewCell", for: indexPath) as! CustomerInprogressUpdatedTableViewCell
            
            if self.arrayofofferjob.count > indexPath.row {
                let objoffer  = self.arrayofofferjob[indexPath.row]
                DispatchQueue.main.async {
                    cell.lbltitle.text = objoffer.title
                    
                    if let preoff = objoffer.isPreOfferDirectBook.bool{
                        if preoff{ //agreed price for direct book
                            cell.viewDocument.isHidden = true
                            cell.viewAcceptedPrice.isHidden = true
                            cell.lblAskingPriceName.text = "Agreed Price : "
                        }else{ //Configure for not a direct book
                            cell.viewDocument.isHidden = false
                            cell.viewAcceptedPrice.isHidden = false
                            cell.lblAskingPriceName.text = "Budget : "
                        }
                    }else{ //Configure for not a direct book
                        cell.viewDocument.isHidden = false
                        cell.viewAcceptedPrice.isHidden = false
                        cell.lblAskingPriceName.text = "Budget : "
                    }
                    if objoffer.askingPrice.count > 0{
                        if let pi: Double = Double("\(objoffer.askingPrice)"){
                            let updatedvalue = String(format:"%.2f", pi)
                            cell.lblAskingPrice.text = CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)//"$\(updatedvalue)"
                           }
                    }else{
                        cell.lblAskingPrice.text = "none"
                    }
                    
                    cell.btnAttachment.isHidden = (objoffer.offerAttachment.count == 0)
                    cell.btnNoAttachment.isHidden = (objoffer.offerAttachment.count != 0)
                    let offerString = NSMutableAttributedString()
                    if objoffer.promotion.count > 0 {
                        cell.viewPromotionContainer.isHidden = false
                        if let value =  objoffer.promotion.first!["customer_discount"]{
                            if let type = objoffer.promotion.first!["type"]{
                             if "\(type)" == "amount"{
                               if let pi: Double = Double("\(value)"){
                                  let updatedvalue = String(format:"%.2f", pi)
                                   cell.lblPromotionOfferAmount.text = CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)
                               }
                             }else{
                                 cell.lblPromotionOfferAmount.text = "\(value)%"
                             }
                            }
                        }
                        if objoffer.offerPrice.count > 0 && objoffer.finalPrice.count > 0{
                           if let pi: Double = Double("\(objoffer.offerPrice)"){
                               let updatedvalue = String(format:"%.2f", pi)
                               offerString.append("\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))".strikeThrough())
                           }
                           if let pi: Double = Double("\(objoffer.finalPrice)"){
                               let updatedvalue = String(format:"%.2f", pi)
                               offerString.append(NSAttributedString.init(string: " \(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))"))
                           }
                        }else{
                            offerString.append(NSAttributedString.init(string: "none"))
                        }
                    }else{
                        cell.lblPromotionOfferAmount.text = "none"
                        cell.viewPromotionContainer.isHidden = true
                        if objoffer.offerPrice.count > 0{
                           if let pi: Double = Double("\(objoffer.offerPrice)"){
                               let updatedvalue = String(format:"%.2f", pi)
                               offerString.append(NSAttributedString.init(string: "\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))"))
                           }
                        }else{
                            offerString.append(NSAttributedString.init(string: "none"))
                        }
                    }
                    //Based on Offer and new UI for sprint 9
                    cell.lblAcceptedPrice.attributedText = offerString
                    
                    if objoffer.dateOfPost.count > 0{
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        if let date = dateformatter.date(from: objoffer.dateOfPost){
                            dateformatter.dateFormat = "MM/dd/yyyy hh:mm a"
                            let updatedDate = dateformatter.string(from: date.toLocalTime())
                            cell.lblDateOfPost.text = "\(updatedDate)"
                        }else{
                            cell.lblDateOfPost.text = objoffer.dateOfPost.changeDateFormat
                        }
                      }else{
                        cell.lblDateOfPost.text = "none"
                      }
                    if objoffer.dateJOBStartDate.count > 0{
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        if let date = dateformatter.date(from: objoffer.dateJOBStartDate){
                            dateformatter.dateFormat = "MM/dd/yyyy hh:mm a"
                            let updatedDate = dateformatter.string(from: date.toLocalTime())
                            cell.lblDateOfAccepted.text = "\(updatedDate)"
                        }else{
                            cell.lblDateOfAccepted.text =  objoffer.dateJOBStartDate.changeDateFormat
                        }
                        
                    }else{
                         cell.lblDateOfAccepted.text = "none"
                    }
                    if let imageURL = URL.init(string: "\(objoffer.businessLogo)"){
                        cell.businessLogo!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                    }
                    cell.lblBusinessName.text = objoffer.businessName
                     if let pi: Double = Double("\(objoffer.rating)"){
                         let updatedvalue = String(format:"%.1f", pi)
                         cell.lblRating.text = "\(updatedvalue)"
                     }
                }
                
                
                UIView.performWithoutAnimation {
                    DispatchQueue.main.async {
                       cell.btnMore.isSelected = objoffer.isMoreOption
                       cell.viewMore.isHidden = !objoffer.isMoreOption
                   }
                }
            }
            
            if indexPath.row+1 == self.arrayofofferjob.count, self.isLoadMore{ //last index
                              DispatchQueue.global(qos: .background).async {
                                self.currentPage += 1
                                self.callAPIRequestToFetchInProgressJOBList()
                              }
            }
            cell.tag = indexPath.row
            cell.delegate = self
            return cell
        }else if self.selectedIndex == 3{
               let cell = tblViewMessages.dequeueReusableCell(withIdentifier: "CustomerCompletedUpdatedTableViewCell", for: indexPath) as! CustomerCompletedUpdatedTableViewCell

               if self.arrayofofferjob.count > indexPath.row {
                let objoffer  = self.arrayofofferjob[indexPath.row]
                DispatchQueue.main.async {
                    cell.lbltitle.text = objoffer.title

                    if let preoff = objoffer.isPreOfferDirectBook.bool{
                        if preoff{ //agreed price for direct book
                            cell.viewDocument.isHidden = true
                            cell.viewAcceptedPrice.isHidden = true
                            cell.lblAskingPriceName.text = "Agreed Price : "
                        }else{ //Configure for not a direct book
                            cell.viewDocument.isHidden = false
                            cell.viewAcceptedPrice.isHidden = false
                            cell.lblAskingPriceName.text = "Budget : "
                        }
                    }else{ //Configure for not a direct book
                        cell.viewDocument.isHidden = false
                        cell.viewAcceptedPrice.isHidden = false
                        cell.lblAskingPriceName.text = "Budget : "
                    }
                    if objoffer.askingPrice.count > 0{
                        if let pi: Double = Double("\(objoffer.askingPrice)"){
                            let updatedvalue = String(format:"%.2f", pi)
                            cell.lblAskingPrice.text = CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)//"$\(updatedvalue)"
                           }
                    }else{
                        cell.lblAskingPrice.text = "none"
                    }

                    cell.btnAttachment.isHidden = (objoffer.offerAttachment.count == 0)
                    cell.btnNoAttachment.isHidden = (objoffer.offerAttachment.count != 0)
                    let offerString = NSMutableAttributedString()
                    if objoffer.promotion.count > 0 {
                        cell.viewPromotionContainer.isHidden = false
                        if let value =  objoffer.promotion.first!["customer_discount"]{
                            if let type = objoffer.promotion.first!["type"]{
                             if "\(type)" == "amount"{
                               if let pi: Double = Double("\(value)"){
                                  let updatedvalue = String(format:"%.2f", pi)
                                   cell.lblPromotionOfferAmount.text = CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)
                               }
                             }else{
                                 cell.lblPromotionOfferAmount.text = "\(value)%"
                             }
                            }
                        }
                        if objoffer.offerPrice.count > 0 && objoffer.finalPrice.count > 0{
                           if let pi: Double = Double("\(objoffer.offerPrice)"){
                               let updatedvalue = String(format:"%.2f", pi)
                               offerString.append("\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))".strikeThrough())
                           }
                           if let pi: Double = Double("\(objoffer.finalPrice)"){
                               let updatedvalue = String(format:"%.2f", pi)
                               offerString.append(NSAttributedString.init(string: " \(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))"))
                           }
                        }else{
                            offerString.append(NSAttributedString.init(string: "none"))
                        }
                    }else{
                        cell.lblPromotionOfferAmount.text = "none"
                        cell.viewPromotionContainer.isHidden = true
                        if objoffer.offerPrice.count > 0{
                           if let pi: Double = Double("\(objoffer.offerPrice)"){
                               let updatedvalue = String(format:"%.2f", pi)
                               offerString.append(NSAttributedString.init(string: "\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))"))
                           }
                        }else{
                            offerString.append(NSAttributedString.init(string: "none"))
                        }
                    }
                    //Based on Offer and new UI for sprint 9
                    cell.lblAcceptedPrice.attributedText = offerString

                    if objoffer.dateOfPost.count > 0{
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        if let date = dateformatter.date(from: objoffer.dateOfPost){
                            dateformatter.dateFormat = "MM/dd/yyyy hh:mm a"
                            let updatedDate = dateformatter.string(from: date.toLocalTime())
                            cell.lblDateOfPost.text = "\(updatedDate)"
                        }else{
                            cell.lblDateOfPost.text = objoffer.dateOfPost.changeDateFormat
                        }
                      }else{
                        cell.lblDateOfPost.text = "none"
                      }
                    if objoffer.dateOfCompletion.count > 0{
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        if let date = dateformatter.date(from: objoffer.dateOfCompletion){
                            dateformatter.dateFormat = "MM/dd/yyyy hh:mm a"
                            let updatedDate = dateformatter.string(from: date.toLocalTime())
                            cell.lblDateOfAccepted.text = "\(updatedDate)"
                        }else{
                            cell.lblDateOfAccepted.text =  objoffer.dateOfCompletion.changeDateFormat
                        }

                    }else{
                         cell.lblDateOfAccepted.text = "none"
                    }
                    if let imageURL = URL.init(string: "\(objoffer.businessLogo)"){
                        cell.businessLogo!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                    }
                    cell.lblBusinessName.text = objoffer.businessName
                     if let pi: Double = Double("\(objoffer.rating)"){
                         let updatedvalue = String(format:"%.1f", pi)
                         cell.lblRating.text = "\(updatedvalue)"
                     }
                }


                UIView.performWithoutAnimation {
                    DispatchQueue.main.async {
                       cell.btnMore.isSelected = objoffer.isMoreOption
                       cell.viewMore.isHidden = !objoffer.isMoreOption
                   }
                }
            }
            if indexPath.row+1 == self.arrayofofferjob.count, self.isLoadMore{ //last index
                              DispatchQueue.global(qos: .background).async {
                                self.currentPage += 1
                                self.callAPIRequestToFetchCompletedJOBList()
                              }
            }
            cell.tag = indexPath.row
            cell.delegate = self
            return cell
        }else if self.selectedIndex == 4{
            let cell = tblViewMessages.dequeueReusableCell(withIdentifier: "CustomerUnsuccessfulOfferUpdatedTableViewCell", for: indexPath) as! CustomerUnsuccessfulOfferUpdatedTableViewCell
            if self.arrayofofferjob.count > indexPath.row {
             let objoffer  = self.arrayofofferjob[indexPath.row]
                DispatchQueue.main.async {
                    cell.lblJOBNote.text = objoffer.customerJobNote
                    cell.lblJobcanceldate.text = objoffer.jobCancelDate.changeDateFormat
                    cell.lbltitle.text = objoffer.title

                    if let preoff = objoffer.isPreOfferDirectBook.bool{
                        if preoff{ //agreed price for direct book
                            cell.viewDocument.isHidden = true
                            cell.viewAcceptedPrice.isHidden = true
                            cell.lblAskingPriceName.text = "Agreed Price : "
                        }else{ //Configure for not a direct book
                            cell.viewDocument.isHidden = false
                            cell.viewAcceptedPrice.isHidden = false
                            cell.lblAskingPriceName.text = "Budget : "
                        }
                    }else{ //Configure for not a direct book
                        cell.viewDocument.isHidden = false
                        cell.viewAcceptedPrice.isHidden = false
                        cell.lblAskingPriceName.text = "Budget : "
                    }
                    if objoffer.askingPrice.count > 0{
                        if let pi: Double = Double("\(objoffer.askingPrice)"){
                            let updatedvalue = String(format:"%.2f", pi)
                            cell.lblAskingPrice.text = CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)//"$\(updatedvalue)"
                           }
                    }else{
                        cell.lblAskingPrice.text = "none"
                    }
                    cell.btnAttachment.isHidden = (objoffer.offerAttachment.count == 0)
                    cell.btnNoAttachment.isHidden = (objoffer.offerAttachment.count != 0)
                    let offerString = NSMutableAttributedString()
                    if objoffer.promotion.count > 0 {
                        cell.viewPromotionContainer.isHidden = false
                        if let value =  objoffer.promotion.first!["customer_discount"]{
                            if let type = objoffer.promotion.first!["type"]{
                             if "\(type)" == "amount"{
                               if let pi: Double = Double("\(value)"){
                                  let updatedvalue = String(format:"%.2f", pi)
                                   cell.lblPromotionOfferAmount.text = CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)
                               }
                             }else{
                                 cell.lblPromotionOfferAmount.text = "\(value)%"
                             }
                            }
                        }
                        if objoffer.offerPrice.count > 0 && objoffer.finalPrice.count > 0{
                           if let pi: Double = Double("\(objoffer.offerPrice)"){
                               let updatedvalue = String(format:"%.2f", pi)
                               offerString.append("\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))".strikeThrough())
                           }
                           if let pi: Double = Double("\(objoffer.finalPrice)"){
                               let updatedvalue = String(format:"%.2f", pi)
                               offerString.append(NSAttributedString.init(string: " \(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))"))
                           }
                        }else{
                            offerString.append(NSAttributedString.init(string: "none"))
                        }
                    }else{
                        cell.lblPromotionOfferAmount.text = "none"
                        cell.viewPromotionContainer.isHidden = true
                        if objoffer.offerPrice.count > 0{
                           if let pi: Double = Double("\(objoffer.offerPrice)"){
                               let updatedvalue = String(format:"%.2f", pi)
                               offerString.append(NSAttributedString.init(string: "\(CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0))"))
                           }
                        }else{
                            offerString.append(NSAttributedString.init(string: "none"))
                        }
                    }
                    //Based on Offer and new UI for sprint 9
                    cell.lblAcceptedPrice.attributedText = offerString


                    if objoffer.dateOfPost.count > 0{
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        if let date = dateformatter.date(from: objoffer.dateOfPost){
                            dateformatter.dateFormat = "MM/dd/yyyy hh:mm a"
                            let updatedDate = dateformatter.string(from: date.toLocalTime())
                            cell.lblDateOfPost.text = "\(updatedDate)"
                        }else{
                            cell.lblDateOfPost.text = objoffer.dateOfPost.changeDateFormat
                        }
                      }else{
                        cell.lblDateOfPost.text = "none"
                      }
                }
            }

            if indexPath.row+1 == self.arrayofofferjob.count, self.isLoadMore{ //last index
                              DispatchQueue.global(qos: .background).async {
                                self.currentPage += 1
                                self.callAPIRequestToNoOfferJOBList()
                              }
            }
            cell.tag = indexPath.row
            cell.delegate = self
            DispatchQueue.main.async {
                cell.layoutIfNeeded()
            }
            return cell

        }else{
        
        let cell = tblViewMessages.dequeueReusableCell(withIdentifier: "CustommerOfferTableViewCell", for: indexPath) as! CustommerOfferTableViewCell
        
       
        if self.arrayofofferjob.count > indexPath.row {
            let objoffer  = self.arrayofofferjob[indexPath.row]
//            cell.viewDocument.isHidden = (objoffer.offerAttachment.count == 0)

            //configure cell data
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if objoffer.offerDate.count > 0{
                    if let date = dateformatter.date(from: objoffer.offerDate){
                        dateformatter.dateFormat = "MM/dd/yyyy\nhh:mm a"
                        let updatedDate = dateformatter.string(from: date.toLocalTime())
                        print("------ \(updatedDate)")
                        cell.lblOfferDate.text = "Offer Date: \(updatedDate)"
                    }
                }else{
                   cell.lblOfferDate.text = ""//"Offer Date: none"
                }
                //cell.lblOfferDate.text = "Offer Date: \(objoffer.offerDate.changeDateFormat)"
            
            if let preoff = objoffer.isPreOfferDirectBook.bool{
                print("===== \(preoff)")
                if preoff{
                    DispatchQueue.main.async {
                        cell.viewDocument.isHidden = true
                        cell.viewOfferPrice.isHidden = true
                        cell.viewAcceptedPrice.isHidden = true
                        cell.lblAskingPriceName.text = "Agreed Price : "
                                    }
                }else{
                    DispatchQueue.main.async {
                        if self.selectedIndex == 4{
                            cell.viewDocument.isHidden = true
                        }else{
                            cell.viewDocument.isHidden = false
                        }
                        
                        if self.selectedIndex == 1 || self.selectedIndex == 3 || self.selectedIndex == 4 {
                            cell.viewOfferPrice.isHidden = true
                        }else{
                            cell.viewOfferPrice.isHidden = false
                        }
                        
                        
                        if self.selectedIndex == 2 || self.selectedIndex == 4{
                            cell.viewAcceptedPrice.isHidden = true
                        }else{
                            cell.viewAcceptedPrice.isHidden = false
                        }
                        cell.lblAskingPriceName.text = "Budget : "
                                    }
                }
            }else{
                DispatchQueue.main.async {
                    if self.selectedIndex == 4{
                        cell.viewDocument.isHidden = true
                    }else{
                        cell.viewDocument.isHidden = false
                    }
                    if self.selectedIndex == 1 || self.selectedIndex == 3 || self.selectedIndex == 4 {
                        cell.viewOfferPrice.isHidden = true
                    }else{
                        cell.viewOfferPrice.isHidden = false
                    }
                    
                    if self.selectedIndex == 2  || self.selectedIndex == 4{
                        cell.viewAcceptedPrice.isHidden = true
                    }else{
                        cell.viewAcceptedPrice.isHidden = false
                    }
                    cell.lblAskingPriceName.text = "Budget : "
                                }
            }
            /*
            if let preoff = objoffer.isPreOffer.bool{
                print("===== \(preoff)")
//                DispatchQueue.main.async {
//                    cell.configureOfferCell(isPreOffer: preoff)
//                }
                if preoff{

                }else{
                    if objoffer.offerDate.count > 0{
                        
                        
                       cell.lblOfferDate.text = "Offer Date: \(objoffer.offerDate.changeDateFormat)"
                       //cell.lblOfferTime.text = self.getTime(time: String(objoffer.offerDate.suffix(8)))
                    }else{
                        
                    }
                }
            }else{
                print("===== \(false)")
                DispatchQueue.main.async {
                    //cell.configureOfferCell(isPreOffer: false)
                }
                if objoffer.offerDate.count > 0{
                    
                   cell.lblOfferDate.text = "Offer Date: \(objoffer.offerDate.changeDateFormat)"
                    //cell.lblOfferTime.text = self.getTime(time: String(objoffer.offerDate.suffix(8)))
                }else{
                   
                }
            }*/
        //*********************************************
            
            cell.lbltitle.text = objoffer.title
              if self.selectedIndex == 0{ //offer
                if objoffer.estimateBudget.count > 0{
                    if let pi: Double = Double("\(objoffer.estimateBudget)"){
                     let updatedvalue = String(format:"%.2f", pi)
                        cell.lblAskingPrice.text =  CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)//"$\(updatedvalue)"
                    }
                }else{
                    cell.lblAskingPrice.text = "none"
                }
              }else{
                if objoffer.askingPrice.count > 0{
                    if let pi: Double = Double("\(objoffer.askingPrice)"){
                        let updatedvalue = String(format:"%.2f", pi)
                        cell.lblAskingPrice.text = CurrencyFormate.Currency(value: Double(updatedvalue) ?? 0)//"$\(updatedvalue)"
                       }
                }else{
                    cell.lblAskingPrice.text = "none"
                }
                
               }
             
            
            let offerString = NSMutableAttributedString()
            if objoffer.promotion.count > 0{
                  
                if let objvalue =  objoffer.promotion.first!["customer_discount"]{
                    if let type = objoffer.promotion.first!["type"]{
                     if "\(type)" == "amount"{
                        cell.lblPromotionOfferAmount.text = "\(CurrencyFormate.Currency(value: objvalue as! Double))"
                     }else{
                         cell.lblPromotionOfferAmount.text = "\(objvalue)%"
                     }
                    }
                }
                
                print("===== \(objoffer.offerPrice)")
                print("===== \(objoffer.finalPrice)")
                print("===== \(objoffer.price)")
                
            if objoffer.offerPrice.count > 0 && objoffer.finalPrice.count > 0{
                offerString.append("\(CurrencyFormate.Currency(value: Double(objoffer.offerPrice) ?? 0))".strikeThrough())
                offerString.append(NSAttributedString.init(string: " "))
                offerString.append(NSAttributedString.init(string:"\(CurrencyFormate.Currency(value: Double(objoffer.finalPrice) ?? 0))"))
            }else if objoffer.price.count > 0 && objoffer.finalPrice.count > 0{
                offerString.append("\(CurrencyFormate.Currency(value: Double(objoffer.price) ?? 0))".add2DecimalString.strikeThrough())
                offerString.append(NSAttributedString.init(string: " "))
                offerString.append(NSAttributedString.init(string: "\(CurrencyFormate.Currency(value: Double(objoffer.finalPrice) ?? 0))"))
                }else{
                    offerString.append(NSAttributedString.init(string: "none"))
                }
                 
              }else{
                cell.lblPromotionOfferAmount.text = "none"
                if objoffer.offerPrice.count > 0{
                    offerString.append(NSAttributedString.init(string: "\(CurrencyFormate.Currency(value: Double(objoffer.offerPrice) ?? 0))"))
                }else if objoffer.price.count > 0{
                    offerString.append(NSAttributedString.init(string: "\((CurrencyFormate.Currency(value: Double(objoffer.price) ?? 0)))"))
                }else{
                    offerString.append(NSAttributedString.init(string: "none"))
                }
                  
              }
            if objoffer.promotion.count > 0 {//&& (self.selectedIndex == 0 || self.selectedIndex == 1  || self.selectedIndex == 2){
                cell.viewPromotionContainer.isHidden = false
            }else{
                cell.viewPromotionContainer.isHidden = true
            }
            
                print("======= \(offerString)")
             //cell.lblOfferPrice.text = "$\(objoffer.offerPrice)"
            cell.lblOfferPrice.attributedText = offerString
            
            
            if let imageURL = URL.init(string: "\(objoffer.businessLogo)"){
                cell.businessLogo!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
            }
            cell.lblBusinessName.text = objoffer.businessName
            if let pi: Double = Double("\(objoffer.rating)"){
                                           let updatedvalue = String(format:"%.1f", pi)
                                           cell.lblRating.text = "\(updatedvalue)"
                                       }
            //cell.lblRating.text = "\(objoffer.rating)"
            cell.btnAttachment.isHidden = (objoffer.offerAttachment.count == 0)
            cell.btnNoAttachment.isHidden = (objoffer.offerAttachment.count != 0)
            if objoffer.acceptedPrice.count > 0{
                cell.lblAcceptedPrice.text = CurrencyFormate.Currency(value: Double(objoffer.acceptedPrice) ?? 0)//"\(objoffer.acceptedPrice)".add2DecimalString
            }else{
                cell.lblAcceptedPrice.text = "none"
            }
            
            
          
            if objoffer.createdAt.count > 0{
                cell.lblDate.text = objoffer.createdAt.changeDateFormat
            }else{
                cell.lblDate.text = "none"
            }
            if objoffer.jobcreated.count > 0{
                cell.lbldateofpost.text = objoffer.jobcreated.changeDateFormat
               // cell.lbltimeofpost.text = String(objoffer.jobcreated.suffix(4))
            }else{
                cell.lbldateofpost.text = "none"
               // cell.lbltimeofpost.text = "none"
            }
            if objoffer.acceptedDate.count > 0{
                cell.lbldateofaccepted.text =  objoffer.acceptedDate.changeDateFormat
            }else{
                 cell.lbldateofaccepted.text = "none"
            }
           
            
            if self.selectedIndex == 0{ //offer
                cell.btnProviderDetail.isHidden = false
                cell.btnContact.isHidden = false
                cell.lblDate.isHidden = false
                cell.buttonPayment.isHidden = true
                cell.buttonReportProblem.isHidden = true
                cell.btnBookNow.isHidden = false
                cell.viewAcceptedPrice.isHidden = true
                cell.viewAskingPrice.isHidden = false
                cell.viewOfferPrice.isHidden = false
                //cell.viewDocument.isHidden = false
                cell.viewDateOfPost.isHidden = true
                cell.viewTimeOfPost.isHidden = true
                cell.viewDateofAccepted.isHidden = true
                cell.viewTimeofAccepted.isHidden = true
                cell.viewProviderDetail.isHidden = false
                cell.heightOfProviderDetailView.constant = 100.0
                cell.buttonPaymentHistory.isHidden = true
            }else if self.selectedIndex == 1{ //not started
                cell.btnProviderDetail.isHidden = false
                cell.btnContact.isHidden = false
                cell.lblDate.isHidden = true
                cell.buttonPayment.isHidden = true
                cell.buttonReportProblem.isHidden = true
                cell.btnBookNow.isHidden = true
                
                //cell.viewAcceptedPrice.isHidden = false
                
                cell.viewAskingPrice.isHidden = false
                cell.viewOfferPrice.isHidden = true
//                cell.viewDocument.isHidden = false
                cell.viewDateOfPost.isHidden = false
                cell.viewTimeOfPost.isHidden = true
                cell.viewDateofAccepted.isHidden = false
                cell.viewTimeofAccepted.isHidden = true
                cell.viewProviderDetail.isHidden = false
                cell.buttonPaymentHistory.isHidden = true
                cell.heightOfProviderDetailView.constant = 100.0
            }else if self.selectedIndex == 2{ //In progress
                cell.btnProviderDetail.isHidden = false
                cell.btnContact.isHidden = false
                cell.lblDate.isHidden = true
                cell.buttonPayment.isHidden = false
                cell.buttonReportProblem.isHidden = false
                cell.btnBookNow.isHidden = true
//                cell.viewAcceptedPrice.isHidden = true
                cell.viewAskingPrice.isHidden = false
//                cell.viewOfferPrice.isHidden = true
//                cell.viewDocument.isHidden = false
                cell.viewDateOfPost.isHidden = false
                cell.viewTimeOfPost.isHidden = true
                cell.viewDateofAccepted.isHidden = false
                cell.viewTimeofAccepted.isHidden = true
                cell.viewProviderDetail.isHidden = false
                cell.buttonPaymentHistory.isHidden = true
                cell.heightOfProviderDetailView.constant = 100.0
                cell.lblDateOfCompleted.text = "Date of Accepted :"
            }else if self.selectedIndex == 3{ //Completed
                cell.btnProviderDetail.isHidden = false
                cell.btnContact.isHidden = true
                cell.lblDate.isHidden = true
                cell.buttonReportProblem.isHidden = true
                cell.buttonPayment.isHidden = true
                cell.btnBookNow.isHidden = true
//                cell.viewAcceptedPrice.isHidden = false
                cell.viewAskingPrice.isHidden = false
                cell.viewOfferPrice.isHidden = true
//                cell.viewDocument.isHidden = false
                cell.viewDateOfPost.isHidden = false
                cell.viewTimeOfPost.isHidden = true
                cell.viewDateofAccepted.isHidden = false
                cell.viewTimeofAccepted.isHidden = true
                cell.viewProviderDetail.isHidden = false
                cell.buttonPaymentHistory.isHidden = false
                cell.heightOfProviderDetailView.constant = 100.0
                cell.lblDateOfCompleted.text = "Date of Completed :"
            }else if self.selectedIndex == 4{ //No Offer
                cell.btnProviderDetail.isHidden = true
                cell.btnContact.isHidden = true
                cell.lblDate.isHidden = true
                cell.buttonReportProblem.isHidden = true
                cell.buttonPayment.isHidden = true
                cell.btnBookNow.isHidden = true
                cell.viewAcceptedPrice.isHidden = true
                cell.viewAskingPrice.isHidden = false
                cell.viewOfferPrice.isHidden = true
//                cell.viewDocument.isHidden = true
                cell.viewDateOfPost.isHidden = false
                cell.viewTimeOfPost.isHidden = true
                cell.viewDateofAccepted.isHidden = true
                cell.viewTimeofAccepted.isHidden = true
                cell.viewProviderDetail.isHidden = true
                cell.buttonPaymentHistory.isHidden = true
                cell.heightOfProviderDetailView.constant = 0.0
            }else{
                cell.btnProviderDetail.isHidden = true
                cell.btnContact.isHidden = true
                cell.lblDate.isHidden = true
                cell.buttonReportProblem.isHidden = true
                cell.buttonPayment.isHidden = true
                cell.btnBookNow.isHidden = true
                cell.viewAcceptedPrice.isHidden = true
                cell.viewAskingPrice.isHidden = true
                cell.viewOfferPrice.isHidden = true
                cell.viewDocument.isHidden = true
                cell.viewDateOfPost.isHidden = true
                cell.viewTimeOfPost.isHidden = true
                cell.viewDateofAccepted.isHidden = true
                cell.viewTimeofAccepted.isHidden = true
                cell.viewProviderDetail.isHidden = true
                cell.buttonPaymentHistory.isHidden = true
                cell.heightOfProviderDetailView.constant = 0.0
            }
            
        }
        if indexPath.row+1 == self.arrayofofferjob.count, self.isLoadMore{ //last index
                   DispatchQueue.global(qos: .background).async {
                       self.currentPage += 1
                    if self.selectedIndex == 0{ //offer
                        self.callAPIRequestToFetchOfferJOBList()
                    }else if self.selectedIndex == 1 {  // not started
                        self.callAPIRequestToFetchNotStartedJOBList()
                    }else if self.selectedIndex == 2 {  //Inprogress
                        self.callAPIRequestToFetchInProgressJOBList()
                    }else if self.selectedIndex == 3 {  // Completed
                        self.callAPIRequestToFetchCompletedJOBList()
                    }else if self.selectedIndex == 4 {  // No Offer
                        self.callAPIRequestToNoOfferJOBList()
                    }else{
                        
                    }
                      
                   }
               }
        cell.tag = indexPath.row
        cell.delegate = self
        return cell
     }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedIndex == 0 || self.selectedIndex == 1 || self.selectedIndex == 2{
            if self.arrayofofferjob.count > indexPath.row {
                let objnotifiedProvider = self.arrayofofferjob[indexPath.row ]
                if objnotifiedProvider.isMoreOption{
                    objnotifiedProvider.isMoreOption = !objnotifiedProvider.isMoreOption
                    DispatchQueue.main.async {
                        self.tblViewMessages.reloadData()
                    }
                }
            }
        }
        /*
        selectedIndex = indexPath.row
        
        if btnToggle.isSelected == false { // find my job
            self.performSegue(withIdentifier: "showEnterpreneurs", sender: self)
        }
        else { // applied jobs
            self.performSegue(withIdentifier: "goToChatSegue", sender: self)
        }*/
    }
    /*
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if btnToggle.isSelected == false { // find my job
            
            let dataDict = arrMyJobs.object(at: indexPath.row) as! NSDictionary
            if dataDict["status"] as! String == "pending" {
                return true
            }
        }
        return false
    }
   
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            let alert = UIAlertController(title: AppName, message: "Are you sure you want to delete this job?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                
            }))
            
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
                
                let dataDict = self.arrMyJobs.object(at: indexPath.row) as! NSDictionary
                let jobID = dataDict["id"] as! Int
                
                let dict = [
                    APIManager.Parameter.jobID : String(jobID)
                ]
                
                APIManager.sharedInstance.CallAPIPost(url: Url_deleteJob, parameter: dict, complition: { (error, JSONDICTIONARY) in
                    
                    let isError = JSONDICTIONARY!["isError"] as! Bool
                    
                    if  isError == false{
                        print(JSONDICTIONARY as Any)
                        
                        self.arrMyJobs.removeObject(at: indexPath.row)
                        self.tblViewMessages.reloadData()
                    }
                    else{
                        let message = JSONDICTIONARY!["response"] as! String
                        
                        SAAlertBar.show(.error, message:message.capitalized)
                    }
                })
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            
            let dataDict = self.arrMyJobs.object(at: indexPath.row) as! NSDictionary
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PostJobVC") as! PostJobVC
            vc.isJobEditing = true
            vc.isFromActivity = false
            vc.isFromProfile = false
            vc.dictJob = dataDict
            self.show(vc, sender: self)
        }
        
        edit.backgroundColor = UIColor.lightGray
        
        return [delete,edit]
    }
     
     */
    func getTime(time:String) -> String{
        
        let actualTime = time.prefix(5)
        let hours = time.prefix(2)
        let actualHours = Int(hours)
        var ampm : String = ""
        ampm = (actualHours! % 12 >= 12) ? "PM" : "AM"
        let timestr = actualTime + " " + ampm
        return timestr
    }
    // MARK: - Actions
    @IBAction func buttonChatListSelector(sender:UIButton){
        self.pushtoChatListViewController()
    }
    @IBAction func menuBtnClicked(_ sender: UIButton) {
        
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
  
    @objc func btnEditJobClicked(_ sender: UIButton) {
        
        let dataDict = self.arrMyJobs.object(at: sender.tag) as! NSDictionary
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PostJobVC") as! PostJobVC
        vc.isJobEditing = true
        vc.isFromActivity = false
        vc.isFromProfile = false
        vc.dictJob = dataDict
        self.show(vc, sender: self)
    }
    
    @objc func btnRatingsClicked(_ sender : UIButton) {
        
        selectedIndex = sender.tag
        
//        self.performSegue(withIdentifier: "showReviewsSegue", sender: self)
    }
    
    @IBAction func btnToggleClicked(_ sender: UIButton) {
        if let objTabView = self.navigationController?.tabBarController{
                   if let objHomeNavigation = objTabView.viewControllers?.first as? UINavigationController,let objHome = objHomeNavigation.viewControllers.first as? HomeVC{
                       objTabView.selectedIndex = 0
                   }
        }
        /*
        if sender.isSelected == true {
            sender.isSelected = false
            
            lblTitle.text = "My jobs"
            self.callAPIToGetMyJobs()
        }
        else {
            sender.isSelected = true
            
            lblTitle.text = "Applied jobs"
            self.callAPIToGetAppliedJobs()
        }*/
    }
    
    
    // MARK: - API Calls
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
    func callAPIRequestToFetchOfferJOBList(){
        APIRequestClient.shared.cancelAllAPIRequest(json: nil)
        var dict:[String:Any] = [:]
        //NEED TO REMOVE IT LATER
        //self.arrayofofferjob.removeAll()
        //NEED TO REMOVE IT LATER
        
        dict["status"] = "pending"
        dict["limit"] = "\(self.fetchPageLimit)"
        dict["page"] = "\(self.currentPage)"
        print(dict)
            APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kListOfCustomerOffer , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                    
                    if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [[String:Any]]{
                                if self.currentPage == 1{
                                    self.arrayofofferjob.removeAll()
                                }
                                self.isLoadMore = arrayOfJOB.count > 0
                                if arrayOfJOB.count > 0 {
                                    for objOffer in arrayOfJOB{
                                       let offer = NotifiedProviderOffer.init(providersDetail: objOffer)
                                       self.arrayofofferjob.append(offer)
                                    }
                                    DispatchQueue.main.async {
                                        let filterArray = self.arrayofofferjob.filter{ $0.isPreOffer == "0"}
                                        
                                        if let objTabView = self.navigationController?.tabBarController as? MyTabController{
                                           if filterArray.count > 0{
                                              objTabView.addAnimatedCustomView()
                                          }else{
                                              objTabView.removeCustomView()
                                          }
                                       }
                                        self.tblViewMessages.reloadData()
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
                                       //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                   }
                               }
                           }
        
        
    }
    //CALL book job api
    func callbookjobapireqest(dict:[String:Any]){
         
     
         
             APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kBookJOB , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                     
                     if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [String:Any]{
                              
                                 DispatchQueue.main.async {
                                    self.callAPIRequestToFetchOfferJOBList()
                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                        self.objSegmentConroller.selectedSegmentIndex = 1
                                        self.selectedIndex = 1
                                        self.tblViewMessages.reloadData()
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
                                        //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                    }
                                }
                            }
         
         
     }
    
    //Call Note started JOB
    func callAPIRequestToFetchNotStartedJOBList(){
         
         var dict:[String:Any] = [:]
         
         dict["limit"] = "\(self.fetchPageLimit)"
         dict["page"] = "\(self.currentPage)"
         
             APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kNotStartedJOB , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                     
                     if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [[String:Any]]{
                                print(arrayOfJOB)
                                 if self.currentPage == 1{
                                     self.arrayofofferjob.removeAll()
                                 }
                                 self.isLoadMore = arrayOfJOB.count > 0
                                 if arrayOfJOB.count > 0 {
                                     for objOffer in arrayOfJOB{
                                        let offer = NotifiedProviderOffer.init(providersDetail: objOffer)
                                        self.arrayofofferjob.append(offer)
                                     }
                                 }
                                 DispatchQueue.main.async {
                                     self.tblViewMessages.reloadData()
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
                                        //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                    }
                                }
                            }
         
         
     }
    //Call In progress JOB
    func callAPIRequestToFetchInProgressJOBList(){
         
         var dict:[String:Any] = [:]
         
         dict["limit"] = "\(self.fetchPageLimit)"
         dict["page"] = "\(self.currentPage)"
         
             APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCustomerInprogressJOB , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                     
                     if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [[String:Any]]{
                                print(arrayOfJOB)
                                 if self.currentPage == 1{
                                     self.arrayofofferjob.removeAll()
                                 }
                                 self.isLoadMore = arrayOfJOB.count > 0
                                 if arrayOfJOB.count > 0 {
                                     for objOffer in arrayOfJOB{
                                        let offer = NotifiedProviderOffer.init(providersDetail: objOffer)
                                        self.arrayofofferjob.append(offer)
                                     }
                                 }
                                 DispatchQueue.main.async {
                                     self.tblViewMessages.reloadData()
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
                                        //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                    }
                                }
                            }
         
         
     }
    //Call Completed JOB
    func callAPIRequestToFetchCompletedJOBList(){
         
         var dict:[String:Any] = [:]
         
         dict["limit"] = "\(self.fetchPageLimit)"
         dict["page"] = "\(self.currentPage)"
         
             APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCustomerCompletedJOB , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                     
                     if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [[String:Any]]{
                                print(arrayOfJOB)
                                 if self.currentPage == 1{
                                     self.arrayofofferjob.removeAll()
                                 }
                                 self.isLoadMore = arrayOfJOB.count > 0
                                 if arrayOfJOB.count > 0 {
                                     for objOffer in arrayOfJOB{
                                        let offer = NotifiedProviderOffer.init(providersDetail: objOffer)
                                        self.arrayofofferjob.append(offer)
                                     }
                                 }
                                 DispatchQueue.main.async {
                                     self.tblViewMessages.reloadData()
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
    //Call No Offer JOB
    func callAPIRequestToNoOfferJOBList(){
         
         var dict:[String:Any] = [:]
         
         dict["limit"] = "\(self.fetchPageLimit)"
         dict["page"] = "\(self.currentPage)"
         
             APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCustomerNoOfferJOB , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                     
                     if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [[String:Any]]{
                                print(arrayOfJOB)
                                 if self.currentPage == 1{
                                     self.arrayofofferjob.removeAll()
                                 }
                                 self.isLoadMore = arrayOfJOB.count > 0
                                 if arrayOfJOB.count > 0 {
                                     for objOffer in arrayOfJOB{
                                        let offer = NotifiedProviderOffer.init(providersDetail: objOffer)
                                        self.arrayofofferjob.append(offer)
                                     }
                                 }
                                 DispatchQueue.main.async {

                                     self.tblViewMessages.reloadData()
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
    
    /*
    func callAPIToGetMyJobs() {
        
        let dict = [
            APIManager.Parameter.userID : UserSettings.userID
        ]
        
        APIManager.sharedInstance.CallAPIPost(url: Url_JobListOfUser, parameter: dict, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                if (dataDict["data"] as! NSArray).count == 0 {
                    
                    self.tblViewMessages.isHidden = true
                    self.lblNoJobExists.isHidden = false
                    
                    self.lblNoJobExists.text = (dataDict["message"] as! String)
                    self.arrMyJobs.removeAllObjects()
                }
                else {
                    
                    self.tblViewMessages.isHidden = false
                    self.lblNoJobExists.isHidden = true
                    
                    if self.arrMyJobs.count > 0 {
                        self.arrMyJobs.removeAllObjects()
                    }
                    let tempArray = ((dataDict["data"] as! NSArray).mutableCopy()) as! NSMutableArray
                    
                    for item in tempArray.reversed() {
                        let dataDict = item as! NSDictionary

                        let isActivity = (dataDict.value(forKey: "is_activity") as! NSString).intValue

                        if isActivity == 1 {
                            tempArray.remove(item)
                        }
                    }
                    
                    self.assignedArray.removeAllObjects()
                    self.pendingArray.removeAllObjects()
                    self.completedArray.removeAllObjects()
                    
                    for job in tempArray {
                        
                        let dict = job as! NSDictionary
                        print(dict)
                        
                        if dict["status"] as! String == "progress" {
                            self.assignedArray.add(dict)
                        }
                        else if dict["status"] as! String == "pending" {
                            self.pendingArray.add(dict)
                        }
                        else if dict["status"] as! String == "completed" {
                            self.completedArray.add(dict)
                        }
                    }
                    
                    self.arrMyJobs.addObjects(from: self.assignedArray as! [Any])
                    self.arrMyJobs.addObjects(from: self.pendingArray as! [Any])
                    self.arrMyJobs.addObjects(from: self.completedArray as! [Any])

                    if self.arrMyJobs.count > 0 {
                        self.tblViewMessages.isHidden = false
                        self.lblNoJobExists.isHidden = true
                    }
                    else {
                        self.tblViewMessages.isHidden = true
                        self.lblNoJobExists.isHidden = false
                        
                        self.lblNoJobExists.text = "No Job found."
                        self.arrMyJobs.removeAllObjects()
                    }
                    
                    self.tblViewMessages.reloadData()
                }
            }
            else {
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    
    func callAPIToGetAppliedJobs() {
        
        let dict = [
            APIManager.Parameter.limit : "100",
            APIManager.Parameter.page : "1",
            APIManager.Parameter.fromID : UserSettings.userID
        ]
        
        APIManager.sharedInstance.CallAPIPost(url: Url_jobListOfEnt, parameter: dict, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                if self.arrAppliedJobs.count > 0 {
                    self.arrAppliedJobs.removeAllObjects()
                }
                
                if (dataDict["data"] as! NSArray).count == 0 {
                    
                    self.tblViewMessages.isHidden = true
                    self.lblNoJobExists.isHidden = false
                       
                    self.lblNoJobExists.text = (dataDict["message"] as! String)
                }
                else {
                    
                    self.tblViewMessages.isHidden = false
                    self.lblNoJobExists.isHidden = true
                    
                    let tempArray = dataDict["data"] as! NSArray
                    
                    self.assignedArray.removeAllObjects()
                    self.pendingArray.removeAllObjects()
                    self.completedArray.removeAllObjects()
                    
                    for job in tempArray {
                        
                        let dict = job as! NSDictionary
                        let jobDict = dict.value(forKey: "job") as! NSDictionary
                        print(dict)
                        
                        if jobDict["status"] as! String == "progress" {
                            self.assignedArray.add(dict)
                        }
                        else if jobDict["status"] as! String == "pending" {
                            self.pendingArray.add(dict)
                        }
                        else if jobDict["status"] as! String == "completed" {
                            self.completedArray.add(dict)
                        }
                    }
                    
                    self.arrAppliedJobs.addObjects(from: self.assignedArray as! [Any])
                    self.arrAppliedJobs.addObjects(from: self.pendingArray as! [Any])
                    self.arrAppliedJobs.addObjects(from: self.completedArray as! [Any])
                    
                    self.tblViewMessages.reloadData()
                }
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }*/
    
    //MARK: - User Defined Methods
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
    
    @objc func goToChat() {
        
        let storyboard = UIStoryboard.init(name: "Messages", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        
        chatVC.toId = UserDefaults.standard.value(forKeyPath: "toId") as! String
        chatVC.jobId = UserDefaults.standard.value(forKeyPath: "jobId") as! String
        chatVC.fromId = UserSettings.userID
        chatVC.userName = UserDefaults.standard.value(forKeyPath: "userName") as! String
        chatVC.userProfilePath = UserDefaults.standard.value(forKeyPath: "userProfilePic") as! String
        chatVC.isFromNotification = true
        
        if (UserDefaults.standard.value(forKeyPath: "jobId") as! String) == "" {
            chatVC.isForJobChat = false
        }
        else {
            chatVC.isForJobChat = true
        }
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc func goToNotificationJobProfile() {
          
           let jobID = UserDefaults.standard.value(forKeyPath: "jobId") as! String
           //let jobID = "278"
           
           let dict = [
               APIManager.Parameter.jobID : jobID
           ]
           
           APIManager.sharedInstance.CallAPI(url: Url_JobDetails, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
               
               let isError = JSONDICTIONARY!["isError"] as! Bool
               
               if  isError == false{
                   print(JSONDICTIONARY as Any)
                   let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                   
                   let userData = dataDict["data"] as! NSArray
                   let myDict = userData.object(at: 0) as! NSDictionary
                   
                   let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                   let vc = storyBoard.instantiateViewController(withIdentifier: "JobProfileVC") as! JobProfileVC
                   vc.dictJobDetails = myDict as! NSDictionary
                   vc.userDict = (myDict as AnyObject).value(forKey: "user") as! NSDictionary
                   vc.isFromMessages = true
                   self.navigationController?.pushViewController(vc, animated: true)
                   
               }
               
               else{
                   let message = JSONDICTIONARY!["response"] as! String
                   
                   SAAlertBar.show(.error, message:message.capitalized)
               }
           }
       }
    
    @objc func goToCommentsNotificationJobProfile() {
        //UserDefaults.standard.set(false, forKey: "forCommentNotification")
        let jobID = UserDefaults.standard.value(forKeyPath: "jobId") as! String
        //let jobID = "278"
        
        let dict = [
            APIManager.Parameter.jobID : jobID
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_JobDetails, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                let userData = dataDict["data"] as! NSArray
                let myDict = userData.object(at: 0) as! NSDictionary
                
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "JobProfileVC") as! JobProfileVC
                vc.dictJobDetails = myDict as! NSDictionary
                vc.userDict = (myDict as AnyObject).value(forKey: "user") as! NSDictionary
                vc.isFromMessages = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        }
    }
    
    @objc func removeData() {
        
        self.arrMyJobs.removeAllObjects()
        
        self.tblViewMessages.reloadData()
    }
    
    @objc func goToJobProfile(_ sender : UIButton) {
        
        if btnToggle.isSelected == false {
            let dataDict = arrMyJobs.object(at: sender.tag) as! NSDictionary
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "JobProfileVC") as! JobProfileVC
            vc.dictJobDetails = dataDict
            vc.userDict = dataDict.value(forKey: "user") as! NSDictionary
            vc.isFromMessages = true
            self.navigationController?.pushViewController(vc, animated: true)
            
         
        }
        else {
            let dict = arrAppliedJobs.object(at: sender.tag) as! NSDictionary
            let dataDict = dict["job"] as! NSDictionary
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "JobProfileVC") as! JobProfileVC
            vc.dictJobDetails = dataDict
            vc.userDict = dataDict.value(forKey: "user") as! NSDictionary
            vc.isFromMessages = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    //MARK: - Navigation
    func pushtoChatListViewController(){
        if let chatListViewController = UIStoryboard.messages.instantiateViewController(identifier: "ChatListViewController") as? ChatListViewController{
            chatListViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatListViewController, animated: true)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    
        if segue.identifier == "showEnterpreneurs" {
            
            let jobID = ((arrMyJobs.object(at: selectedIndex) as! NSDictionary).value(forKey: "id") as! Int)
            let jobStatus = ((arrMyJobs.object(at: selectedIndex) as! NSDictionary).value(forKey: "status") as! String)
            var assignedToIDString = String()
            let jobTitle = ((arrMyJobs.object(at: selectedIndex) as! NSDictionary).value(forKey: "title") as! String)
            
            if jobStatus == "pending" {
                assignedToIDString = "0"
            }
            else {
                assignedToIDString = ((arrMyJobs.object(at: selectedIndex) as! NSDictionary).value(forKey: "progress_by") as! String)
            }
            
            let jobidString = "\(jobID)"
            //let vc = segue.destination as! EntrepreneursListVC
            let vc = segue.destination as! EntrepreneursListVC
            vc.jobID = jobidString
            vc.jobTitle = jobTitle
            vc.jobStatus = jobStatus
            vc.assignedToId = assignedToIDString
        }
        else if segue.identifier == "goToChatSegue" {
            
            let dict = (arrAppliedJobs.object(at: selectedIndex) as! NSDictionary)
            let  dataDict = dict["job"] as! NSDictionary
            let userDict = dataDict["user"] as! NSDictionary
            
            let jobID = dataDict.value(forKey: "id") as! Int
            let jobidString = "\(jobID)"
            let vc = segue.destination as! ChatVC
            vc.jobId = jobidString
            vc.fromId = UserSettings.userID
            
            let userID = dataDict.value(forKey: "user_id") as! Int
            vc.profileDict = userDict
            vc.toId = "\(userID)"
            vc.userName = (userDict["firstname"] as! String) + " " + (userDict["lastname"] as! String)
            vc.userProfilePath = userDict["profile_pic"] as! String
            vc.isForJobChat = true
            
            let tabbarController = self.navigationController?.parent as! UITabBarController
            tabbarController.tabBar.isHidden = true
        }
        else if segue.identifier == "showReviewsSegue" {
            
            let vc = segue.destination as! RatingReviewVC
            
            var dict = NSDictionary()
            var userDict = NSDictionary()
            var jobidString = String()
            var jobTitle = String()
            var toIDString = String()
            
            if btnToggle.isSelected == false { // find my job
                dict = arrMyJobs.object(at: self.selectedIndex) as! NSDictionary
                
                if dict["user_progress_by"] is String{
                    SAAlertBar.show(.error, message: "User not available")
                    return
                }
                
                userDict = dict["user_progress_by"] as! NSDictionary
                
                let jobID = dict.value(forKey: "id") as! Int
                jobidString = "\(jobID)"
                
                jobTitle = dict["title"] as! String
                
                let toid = (dict["progress_by"] as! NSString)
                toIDString = toid as String
            }
            else {
                dict = arrAppliedJobs.object(at: selectedIndex) as! NSDictionary
                let  dataDict = dict["job"] as! NSDictionary
                
                userDict = dataDict["user"] as! NSDictionary
                
                let jobID = dataDict.value(forKey: "id") as! Int
                jobidString = "\(jobID)"
                
                jobTitle = dataDict["title"] as! String
                
                let toid = (userDict["id"] as! Int)
                toIDString = "\(toid)"
            }
            
            vc.jobId = jobidString
            vc.jobTitle = jobTitle
            vc.userNameToReview = (userDict["firstname"] as! String) + " " + (userDict["lastname"] as! String)
            
            vc.toId = toIDString
            vc.fromId = UserSettings.userID
        }
    }
}
extension MessagesVC:CustomerOfferCellDelegate,CustomerOfferUpdateCellDelegate,CustomerNotstartedCellDelegate,CustomerInprogressCellDelegate,CustomerCompletedCellDelegate,CustomerUnsuccessfulOfferDelegate{
    func buttonJOBDetailWith(index: Int) {
        if self.arrayofofferjob.count > index{
            let objoffer = self.arrayofofferjob[index]
                self.pushToJOBDetailViewController(withJOBID: objoffer.jobID)
            
        }
    }
    
    func buttonDeleteOfferClick(index:Int){
          if self.arrayofofferjob.count > index{
              let objnotifiedProvider = self.arrayofofferjob[index]
            
              let alert = UIAlertController(title: AppName, message: "Are you sure you want to delete this offer?", preferredStyle: .alert)
              
              alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                  
              }))
              
              alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                  
                if let preoff = objnotifiedProvider.isPreOffer.bool{
                    if preoff{
                        //Post
                        self.callDeletePostAPIRequest(jodId: objnotifiedProvider.jobID)
                    }else{
                        //Offer
                        self.callDeleteOfferPostAPIRequest(jodId: objnotifiedProvider.jobID, providerId: objnotifiedProvider.providerID)
                    }
                }else{
                    //Offer
                    self.callDeleteOfferPostAPIRequest(jodId: objnotifiedProvider.jobID, providerId: objnotifiedProvider.providerID)
                }
                  
              }))
            alert.view.tintColor = UIColor.init(hex: "#38B5A3")
              self.present(alert, animated: true, completion: nil)

          }
      }
    func callDeleteOfferPostAPIRequest(jodId:String,providerId:String){
        let dict:[String:Any] = [
              "job_id" : "\(jodId)",
            "provider_id":"\(providerId)"
          ]
          
          APIRequestClient.shared.sendAPIRequest(requestType: .DELETE, queryString:kCustomerDeleteOffer , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
              DispatchQueue.main.async {
                  self.configureSelectedIndex()
              }
              if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [String]{
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
    func callDeletePostAPIRequest(jodId:String){
        let dict:[String:Any] = [
              "job_id" : "\(jodId)"
          ]
          
          APIRequestClient.shared.sendAPIRequest(requestType: .DELETE, queryString:kDeletePost , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
              DispatchQueue.main.async {
                  self.arrayofofferjob.removeAll()
                  self.configureSelectedIndex()
              }
              if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [String]{
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
                               //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                             }
                         }
                     }
    }
    
    func buttonCancelPostClick(index: Int) {
        if self.arrayofofferjob.count > index{
                     let objnotifiedProvider = self.arrayofofferjob[index]
                     let alert = UIAlertController(title: AppName, message: "Are you sure you want to cancel this post?", preferredStyle: .alert)
                     
                     alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                         
                     }))
                     
                     alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                       self.callCancelPostAPIRequest(jodId: objnotifiedProvider.jobID)
                        
                     }))
                   alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                     self.present(alert, animated: true, completion: nil)
                 }
    }
    func callCancelPostAPIRequest(jodId:String){
        let dict:[String:Any] = [
                    "job_id" : "\(jodId)"
                ]
                
                APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCancelPost , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                    DispatchQueue.main.async {
                        self.configureSelectedIndex()
                    }
                    if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"]  as? [String]{
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
    func buttonPostDetailCellClick(inde: Int) {
        if self.arrayofofferjob.count > inde{
            let objnotifiedProvider = self.arrayofofferjob[inde]
            self.pushToJOBDetailViewController(withJOBID: objnotifiedProvider.jobID)

        }
    }
    func pushToJOBDetailViewController(withJOBID:String){
        if let jobDetailViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "JobDetailViewController") as? JobDetailViewController{
            jobDetailViewController.hidesBottomBarWhenPushed = true
            jobDetailViewController.jobId = "\(withJOBID)"
            self.navigationController?.pushViewController(jobDetailViewController, animated: true)
        }
    }
    func buttonMoreProviderCellClick(index: Int) {
        if self.arrayofofferjob.count > index{
            let objnotifiedProvider = self.arrayofofferjob[index]
            objnotifiedProvider.isMoreOption = !objnotifiedProvider.isMoreOption
            DispatchQueue.main.async {
                self.tblViewMessages.reloadData()
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
    
    func buttonContactSelectorWith(index:Int){
        if self.arrayofofferjob.count > index{
             let objOffer = self.arrayofofferjob[index]
            self.pushtoChatViewControllerWith(provider: objOffer)
            /*
            DispatchQueue.main.async {
                SAAlertBar.show(.error, message:"Under Development".localizedLowercase)
            }*/
        }
    }
    func pushtoChatViewControllerWith(provider:NotifiedProviderOffer){
           if let chatViewConroller = UIStoryboard.messages.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC{
               chatViewConroller.hidesBottomBarWhenPushed = true
            
                chatViewConroller.strReceiverName = "\(provider.businessName)"
                chatViewConroller.strReceiverProfileURL = "\(provider.businessLogo)"
                chatViewConroller.senderID = "\(provider.quickblox_id)"
                chatViewConroller.toUserTypeStr = "provider"
                if let id = provider.customerDetail["id"]{
                  chatViewConroller.receiverID = "\(id)"
                }else{
                    chatViewConroller.receiverID = "\(provider.userID)"
                    print(provider.userID)
                }
               chatViewConroller.isForCustomerToProvider = true
               self.navigationController?.pushViewController(chatViewConroller, animated: true)
           }
       }
    
    
    func buttonAttachmentSelectorWith(index:Int){
        if self.arrayofofferjob.count > index{
              let objOffer = self.arrayofofferjob[index]
              print(objOffer.offerAttachment)
              //Present Condition Page
            if objOffer.offerAttachment.count > 0{
                if let objAttachment = objOffer.offerAttachment.first!["image"] as? String{
                    self.presentWebViewDetailPageWith(strTitle: "Attachment", strURL: "\(objAttachment)")
                }
            }
            
            
        }
    }
    func buttonProviderDetailSelectorWith(index:Int){
        if self.arrayofofferjob.count > index{
            let objOffer = self.arrayofofferjob[index]
            var dict:[String:Any] = [:]
                          dict["job_id"] = "\(objOffer.jobID)"
                          dict["provider_id"] =  "\(objOffer.providerID)"
                if objOffer.isPreOffer.count > 0{
                    dict["is_pre_offer"] = "\(objOffer.isPreOffer)"
                }
           
            self.pushToProviderDetailScreenWithProviderId(providerID: objOffer.providerID,dictJOBBook: dict)
        }
    }
    func pushToProviderDetailScreenWithProviderId(providerID:String,dictJOBBook:[String:Any]){
        let objStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let objProviderDetail = objStoryboard.instantiateViewController(withIdentifier: "ProviderDetailViewController") as? ProviderDetailViewController{
            objProviderDetail.hidesBottomBarWhenPushed = true
            objProviderDetail.providerID = providerID
            if self.selectedIndex == 0 {
                objProviderDetail.showBookNowButton = true
                objProviderDetail.dictJOBBooking = dictJOBBook
            }else{
                objProviderDetail.showBookNowButton = false
                objProviderDetail.dictJOBBooking = [:]
            }
            
            self.navigationController?.pushViewController(objProviderDetail, animated: true)
        }
    }
    func buttonBookJOBSelectorWith(index:Int){
        if self.arrayofofferjob.count > index{
            let objOffer = self.arrayofofferjob[index]
            //call book job api with is_pre_offer false
            var dict:[String:Any] = [:]
            dict["job_id"] = "\(objOffer.jobID)"
            dict["provider_id"] = "\(objOffer.providerID)"
            dict["is_pre_offer"] = "\(objOffer.isPreOffer)"
            print(dict)
            self.callbookjobapireqest(dict: dict)
        }
    }
    func buttonPaymentSelectorWith(index: Int) {
        if self.arrayofofferjob.count > index{
            let objOffer = self.arrayofofferjob[index]
            DispatchQueue.main.async {
                self.pushtopaymentServiceViewController(provider: objOffer)
                 //SAAlertBar.show(.error, message:"Under Development".localizedLowercase)
            }
        }
    }
    func buttonPaymentHistorySelectorWith(index: Int) {
        if self.arrayofofferjob.count > index{
            let objOffer = self.arrayofofferjob[index]
            
            DispatchQueue.main.async {
                self.pushtoPaymentHistoryViewController(jobID: objOffer.jobID)
                // SAAlertBar.show(.error, message:"Under Development".localizedLowercase)
            }
        }
    }
    func pushtoPaymentHistoryViewController(jobID:String){
          if let paymentHistory = UIStoryboard.activity.instantiateViewController(withIdentifier: "CustommerPaymentHistoryViewController") as? CustommerPaymentHistoryViewController{
              paymentHistory.isForJOBSpecific = true
              paymentHistory.jobId = jobID
              paymentHistory.hidesBottomBarWhenPushed = true
              self.navigationController?.pushViewController(paymentHistory, animated: true)
          }
      }
    func buttonReportProblemSelectorWith(index: Int) {
        if self.arrayofofferjob.count > index{
            let objOffer = self.arrayofofferjob[index]
            self.pushToFileReportViewController(objOffer: objOffer)
        }
    }
    func pushtopaymentServiceViewController(provider:NotifiedProviderOffer){
        if let objpaymentservice = UIStoryboard.activity.instantiateViewController(withIdentifier: "PaymentForServiceViewController") as? PaymentForServiceViewController{
            objpaymentservice.hidesBottomBarWhenPushed = true
            print(provider.jobID)
            print(provider.businessName)
            objpaymentservice.jobid = provider.jobID
            objpaymentservice.strBusinessName = provider.businessName
            self.navigationController?.pushViewController(objpaymentservice, animated: true)
        }
    }
    func pushToFileReportViewController(objOffer:NotifiedProviderOffer){

        let profileStroyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        if let reportBugViewController = profileStroyboard.instantiateViewController(withIdentifier: "ReportBugViewController") as? ReportBugViewController{
         reportBugViewController.providerId = objOffer.providerID
            var objproviderdetail  = ProviderDetail.init(providerDetail: [:])
            objproviderdetail.userID = objOffer.userID
            objproviderdetail.id =  objOffer.providerID
            objproviderdetail.businessName = objOffer.businessName
            reportBugViewController.providerDetail = objproviderdetail

            reportBugViewController.isForFileDispute = true
            reportBugViewController.hidesBottomBarWhenPushed = true
             self.navigationController?.pushViewController(reportBugViewController, animated: true)
         }
        
    }
}

