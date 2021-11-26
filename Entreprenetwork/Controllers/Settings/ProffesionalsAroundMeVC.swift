//
//  ProffesionalsAroundMeVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 27/12/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreLocation
import Firebase
import AVKit

class ProffesionalsAroundMeVC: UIViewController,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var mapProfessionals: MKMapView!
    @IBOutlet weak var tblProffesionals: UITableView!
    @IBOutlet weak var lblNoRecord : UILabel!
    @IBOutlet weak var viewList: UIView!
    
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var txtFldName: UITextField!
    @IBOutlet weak var txtviewDescription: UITextView!
    @IBOutlet weak var txtfldCategories: UITextField!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLat = Double()
    var currentLong = Double()
    
    var zoomRect = MKMapRect.null
    var selectedTag = Int()
    
    var isWebserviceCalled = Bool()
    
    var arrayProffesionals = NSArray()
    var arrCategories = NSArray()
    var categoryIDS = String()
    var fromID = String()
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    //MARK: - UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        RegisterCell()
        
        Analytics.logEvent(NSLocalizedString("click_professionals_around", comment: ""), parameters: [:])
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        swipeDown.direction = .down
        viewList.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        swipeUp.direction = .up
        viewList.addGestureRecognizer(swipeUp)
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isKeyPresentInUserDefaults(key: "isfromCategoriesForProffesionals") {
            
            let isFromCategories = UserDefaults.standard.value(forKey: "isfromCategoriesForProffesionals") as! Bool
            if isFromCategories == true {
                
                UserDefaults.standard.set(false, forKey: "isfromCategoriesForProffesionals")
                
                let myCatArr = UserDefaults.standard.value(forKey: "selectedCategoriesForProffesionals") as! NSArray
                print(myCatArr)
                categoryIDS = ""
                
                for item in myCatArr {
                    
                    let dataDict = item as! NSDictionary
                    let id = dataDict["id"] as! NSNumber
                    var catID = String()
                    catID =  "\(id)"
                    
                    if categoryIDS.count == 0 {
                        categoryIDS = catID
                    }
                    else {
                        categoryIDS = categoryIDS + "," + catID
                    }
                }
                self.isWebserviceCalled = false
            }
        }
        self.mylocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.locationManager.stopUpdatingLocation()

        self.isWebserviceCalled = false
        UserDefaults.standard.removeObject(forKey: "selectedCategoriesForProffesionals")
    }
    
    //MARK: - Register Cell
    
    func RegisterCell() {
        tblProffesionals.register(UINib(nibName: "ProffesionalsCell", bundle: nil), forCellReuseIdentifier: "ProffesionalsCell")
    }
    
    //MARK: - UITableView Datasource & Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayProffesionals.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblProffesionals.dequeueReusableCell(withIdentifier: "ProffesionalsCell") as! ProffesionalsCell
        cell.selectionStyle = .none
        
        let dataDict = arrayProffesionals.object(at: indexPath.row) as! NSDictionary
        
        var url = dataDict["profile_pic"] as! String
        url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
        
        cell.btnProfilePic.tag = indexPath.row
        cell.btnProfilePic.sd_setImage(with: URL(string: url), for: .normal, completed: nil)
        cell.btnProfilePic.addTarget(self, action: #selector(goToUserProfile), for: .touchUpInside)
        
        let userName = (dataDict["firstname"] as! String) + " " + (dataDict["lastname"] as! String)
        
        cell.btnUserName.tag = indexPath.row
        cell.btnUserName.setTitle(userName, for: .normal)
        cell.btnUserName.addTarget(self, action: #selector(goToUserProfile), for: .touchUpInside)
        
        cell.lblCompanyName.text = (dataDict["company"] as! String)
        
        cell.btnMessage.tag = indexPath.row
        cell.btnMessage.addTarget(self, action: #selector(goToChat), for: .touchUpInside)
        
        let userId = dataDict.value(forKey: "id") as! Int
        let isUseradded = self.isUserAdded(userID: userId)
        if isUseradded == true {
            cell.btnAddToNetwork.setImage(UIImage(named: "user_added"), for: .normal)
        }
        else {
            cell.btnAddToNetwork.setImage(UIImage(named: "addToNetwork"), for: .normal)
        }
        
        cell.btnAddToNetwork.tag = indexPath.row
        cell.btnAddToNetwork.addTarget(self, action: #selector(addToMyNetwork), for: .touchUpInside)
        
        return cell
    }
    
    func isUserAdded(userID : Int) -> Bool {
        
        for user in NetworkModel.Shared.arrUsers {
            
            let networkUserId = user.userId
            
            if networkUserId == userID {
                return true
            }
        }
        
        return false
    }
    
    //MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latestLocation: AnyObject = locations[locations.count - 1]
        let mystartLocation = latestLocation as! CLLocation;
        
        self.currentLat = mystartLocation.coordinate.latitude
        self.currentLong = mystartLocation.coordinate.longitude
        
        UserRegister.Shared.lat = String(self.currentLat)
        UserRegister.Shared.long = String(self.currentLong)
        
        if isWebserviceCalled == false {
            callAPIToGetProffesionalsAroundMe()
        }
    }
    
    private func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
    }
    
    //MARK: - User Defined Methods
    
    @objc func goToChat(_ sender : UIButton) {
        
        let storyboard = UIStoryboard.init(name: "Messages", bundle: nil)
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        
        let dict = (arrayProffesionals.object(at: sender.tag) as! NSDictionary)
        
        chatVC.fromId = UserSettings.userID
        
        let userID = dict.value(forKey: "id") as! Int
        chatVC.profileDict = dict
        chatVC.toId = "\(userID)"
        chatVC.userName = (dict["firstname"] as! String) + " " + (dict["lastname"] as! String)
        chatVC.userProfilePath = dict["profile_pic"] as! String
        if let quickbloxID = dict["quickblox_id"]{
            chatVC.senderID = "\(quickbloxID)"
        }
        chatVC.isForJobChat = false
        
        self.navigationController?.pushViewController(chatVC, animated: true)
            }
    
    @objc func addToMyNetwork(_ sender : UIButton) {
        
        let userDict = self.arrayProffesionals.object(at: sender.tag) as! NSDictionary
        let userId = userDict.value(forKey: "id") as! Int
        self.fromID = "\(userId)"
        self.callAPIToAddUserToNetwork(tag: sender.tag)
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    @objc func handleSwipes(sender:UISwipeGestureRecognizer) {
        if let gesture = sender as? UISwipeGestureRecognizer {
            switch(gesture.direction) {
            case UISwipeGestureRecognizer.Direction.up: viewHeightConstraint.constant = self.view.frame.size.height * 0.7
            case UISwipeGestureRecognizer.Direction.down:
                viewHeightConstraint.constant = 60
            default:
                break
            }
            UIView.animate(withDuration: 0.5) {
                self.viewList.layoutIfNeeded()
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
    
    @objc func goToUserProfile(_ sender: UIButton ) {
        
        let dict = arrayProffesionals.object(at: sender.tag) as! NSDictionary
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EntrepreneurProfileVC") as! EntrepreneurProfileVC
        vc.isOtherUser = true
        let userID = dict["id"] as! Int
        vc.otherUserId = "\(userID)"
        vc.dictEntrpreneur = dict
        vc.modalPresentationStyle = .fullScreen
        self.show(vc, sender: self)
    }
    
    // MARK: - Annotations
    
    func addannotation()  {
        
        for (index,professional) in self.arrayProffesionals.enumerated() {
            
            let dict = professional as! NSDictionary
            let carPin = MyPointAnnotation()
            carPin.identifier = index
            carPin.gpcode = ""
            
            let lat = Double(dict["lat"] as! String)
            let long = Double(dict["lng"] as! String)
            
            carPin.coordinate = CLLocationCoordinate2DMake(lat! , long! )
            
            let anView:MKAnnotationView = MKAnnotationView()
            anView.annotation = carPin
            
            self.mapProfessionals.addAnnotation(carPin)
            
            let annotationPoint = MKMapPoint(carPin.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
            self.zoomRect = zoomRect.union(pointRect)
        }
        
        mapProfessionals.showAnnotations(mapProfessionals.annotations, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if (annotation is MKUserLocation)
        {
            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            //return nil so map draws default view for it (eg. blue dot)...
            return nil
        }
        
        let reuseId = "test"
        
        guard let annotation = annotation as? MyPointAnnotation else {
            return nil
        }
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        anView!.canShowCallout = true
//        anView!.image = UIImage(named:"user_icon")
        anView!.image = UIImage(named:"redDot")
        anView?.isEnabled = true
        anView?.detailCalloutAccessoryView?.isHidden = false
        anView?.tag = annotation.identifier!
        
        return anView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        selectedTag = view.tag
        
        tblProffesionals.scrollToRow(at: IndexPath(item: selectedTag, section: 0), at: .middle, animated: true)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: 100, longitudinalMeters: 100)
        mapProfessionals.setRegion(coordinateRegion, animated: true)
        //        mapView.setCenter(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), animated: true)
    }
    
    //MARK: - API
    
    func callAPIToGetProffesionalsAroundMe() {
        
        let dict = [
            APIManager.Parameter.latitude : String(self.currentLat),
            APIManager.Parameter.longitude : String(self.currentLong),
            APIManager.Parameter.name : txtFldName.text!,
            APIManager.Parameter.filterDescription : txtviewDescription.text!,
            APIManager.Parameter.categoryIds : self.categoryIDS,
            APIManager.Parameter.radius : "5000",
            APIManager.Parameter.limit : "50",
            APIManager.Parameter.page : "1"
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_ProffesionalsAroundMe, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                self.isWebserviceCalled = true
                
                if self.mapProfessionals.annotations.count > 0 {
                    self.mapProfessionals.removeAnnotations(self.mapProfessionals.annotations)
                }
                
                let location = CLLocation(latitude: self.currentLat, longitude: self.currentLong)
                self.centerMapOnLocation(location: location)
                
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                if (dataDict["data"] as! NSArray).count != 0 {
                    
                    self.arrayProffesionals = dataDict["data"] as! NSArray
                    
                    self.addannotation()
                    self.tblProffesionals.reloadData()
                }
                else {
                    self.tblProffesionals.isHidden = true
                    self.lblNoRecord.isHidden = false
                }
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        }
    }
    
    func callAPIToAddUserToNetwork( tag : Int) {
        
        let dict = [
            APIManager.Parameter.fromID : UserSettings.userID,
            APIManager.Parameter.toID : self.fromID
        ]
        
        APIManager.sharedInstance.CallAPI(url: Url_AddToNetwork, parameter: dict as JSONDICTIONARY) { Error,JSONDICTIONARY in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                let response = JSONDICTIONARY!["response"] as! NSDictionary
                let dataDict = response.value(forKey: "data") as! NSDictionary
//                let cell = self.tblProffesionals.cellForRow(at: IndexPath(row: tag, section: 0)) as! ProffesionalsCell
//                cell.btnAddToNetwork.setImage(UIImage(named: "user_added"), for: .normal)
                
                var networkData = [NetworkModel]()
                
                let DataObject = NetworkModel()
//                DataObject.JsonParseFromDict(dataDict as! JSONDICTIONARY)
                let id = dataDict.value(forKey: "to_id") as! String
                DataObject.userId = Int(id)!
                networkData.append(DataObject)
                NetworkModel.Shared.arrUsers.append(DataObject)
                
                self.tblProffesionals.reloadData()
                
//                let response = JSONDICTIONARY!["response"] as! NSDictionary
//                SAAlertBar.show(.error, message:response.value(forKey: "message") as! String)
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                if message != "Already added in your network!" {
                    SAAlertBar.show(.error, message:message.capitalized)
                }
            }
        }
    }
    
    func callAPIToGetCategories() {
        
        APIManager.sharedInstance.CallAPIPost(url: Url_Categories, parameter: nil, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                self.arrCategories = dataDict["data"] as! NSArray
                
                self.performSegue(withIdentifier: "categorySegue", sender: self)
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    
    //MARK: - Action
    
    @IBAction func btnCancelClicked(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnFilterClicked(_ sender : UIButton) {
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        viewFilter.layer.add(transition, forKey: nil)
        
        self.viewFilter.isHidden = false
    }
    
    @IBAction func btnSearchClicked(_ sender: UIButton) {
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        viewFilter.layer.add(transition, forKey: nil)
        
        viewFilter.isHidden = true
        txtFldName.resignFirstResponder()
        txtviewDescription.resignFirstResponder()
        
        self.callAPIToGetProffesionalsAroundMe()
    }
    
    //MARK: -------------------------------------------------- Filter View
    
    @IBAction func btnFiltercancelClicked(_ sender: UIButton) {
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        viewFilter.layer.add(transition, forKey: nil)
        
        viewFilter.isHidden = true
        
        txtFldName.resignFirstResponder()
        txtviewDescription.resignFirstResponder()
    }
    
    @IBAction func btnResetClicked(_ sender: UIButton) {
        
        txtFldName.text = ""
        txtviewDescription.text = ""
        txtfldCategories.text = ""
        viewFilter.isHidden = true
        
        self.callAPIToGetProffesionalsAroundMe()
    }
    
    //MARK: - UITextfield Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == txtfldCategories {
            
            self.callAPIToGetCategories()
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        let vc = segue.destination as! CategoriesVC
        vc.arrCategories = self.arrCategories.mutableCopy() as! NSMutableArray
        vc.isForProffesionals = true
    }
    
}
