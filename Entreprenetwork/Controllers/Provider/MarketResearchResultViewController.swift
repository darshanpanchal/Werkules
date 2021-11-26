//
//  MarketResearchResultViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 11/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class MarketResearchResultViewController: UIViewController {

    @IBOutlet weak var buttonBack:UIButton!
    
    var arrayOfResult:[[String:Any]] = []
    var locationManager: CLLocationManager = CLLocationManager()
    
    var currentLat = Double()
    var currentLong = Double()
    
      @IBOutlet weak var objMapView:GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.objMapView.delegate = self
               self.objMapView.isMyLocationEnabled = true
               self.objMapView.settings.myLocationButton = false
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setLocationMakerOnGoogleMap()
        }
       
    }
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          self.locationManager.stopUpdatingLocation()
         
      }
    func setLocationMakerOnGoogleMap(){
        self.objMapView.clear()
        for (index, obj) in self.arrayOfResult.enumerated(){
            print(obj)
            if let lat = obj["lat"], let long = obj["lng"]{
                var latitudeString = "\(lat)"
                var longitudeString = "\(long)"
                    let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((latitudeString as NSString).doubleValue), longitude: Double((longitudeString as NSString).doubleValue))
//                                             let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15.0)
//                                             self.objMapView.camera = camera
//                                             self.objMapView.animate(to: camera)
                //Map Animation
                let locationObj =  CLLocationCoordinate2DMake(location.latitude, location.longitude)
//                CATransaction.begin()
//                CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
                DispatchQueue.main.async {
                    self.objMapView.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: 15))
                }
                
//                CATransaction.commit()
                                             let marker = GMSMarker(position: location)
                                             marker.userData = index
                                             //let objView = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 100, height: 120.0)))
                                             //objView.backgroundColor = .black
                                                /*
                                                if var strRating = obj.customerDetail?.rating{
                                                    if let pi: Double = Double("\(strRating)"){
                                                          let rating = String(format:"%.1f", pi)
                                                          strRating = "\(rating)"
                                                      }
                                                     marker.iconView = CustomMarker.instanceFromNib(withName: "\(objJOBdetail.title)", rating: "\(strRating)")
                                                }*/
                                    if let title = obj["title"],let price = obj["estimate_budget"],let date = obj["created_at"]{
                                        let customView = CustomeMarkerDisplayJOB.instanceFromNib(withName: "\(title)", date: "\(date)".changeDateFormat, price: "\(price)")
                                        customView.tag = index
                                        customView.delegate = self
                                        marker.iconView =  customView
                                        //CustomMarker.instanceFromNib(withName: "\(title)", rating: "1.0")

                                    }
                                               
                                             marker.map = self.objMapView
                }
            }
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
        ///CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
        DispatchQueue.main.async {
            self.objMapView.animate(to: GMSCameraPosition.camera(withTarget: locationObj, zoom: 15))
        }
        
        //CATransaction.commit()
        /*let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setCenter(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), animated: true)*/
    }
        /*
        for (index, obj) in self.arrayOfResult.enumerated(){
            if let objJOBdetail = obj.jobDetail{
                print(objJOBdetail.lat)
                print(objJOBdetail.lng)
                var latitudeString = "\(objJOBdetail.lat)"
                var longitudeString = "\(objJOBdetail.lng)"
                
                let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((latitudeString as NSString).doubleValue), longitude: Double((longitudeString as NSString).doubleValue))
                                         let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 20.0)
                                         self.objMapView.camera = camera
                                         self.objMapView.animate(to: camera)
                                         
                                         let marker = GMSMarker(position: location)
                                         marker.userData = index
                                         let objView = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 100, height: 30.0)))
                                         objView.backgroundColor = .black
                                            
                                            if var strRating = obj.customerDetail?.rating{
                                                if let pi: Double = Double("\(strRating)"){
                                                      let rating = String(format:"%.1f", pi)
                                                      strRating = "\(rating)"
                                                  }
                                                 marker.iconView = CustomMarker.instanceFromNib(withName: "\(objJOBdetail.title)", rating: "\(strRating)")
                                            }
                                          
                                           
                                         marker.map = self.objMapView
            }
            
        }*/
        
    
    // MARK: - Selector Methods
      @IBAction func buttonBackSelector(sender:UIButton){
          self.navigationController?.popViewController(animated: true)
      }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
extension MarketResearchResultViewController:CustomMarkerDelegate,GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let tag = marker.userData as? Int,self.arrayOfResult.count > tag{
            if let  jsonObject = self.arrayOfResult[tag] as? [String:Any],let joID = jsonObject["id"]{
                self.pushToJOBDetailViewController(withJOBID: "\(joID)")
            }
        }
        return true
    }
    
   
    func buttonDetailSelector(index: Int) {
        if self.arrayOfResult.count > index {
            if let  jsonObject = self.arrayOfResult[index] as? [String:Any],let joID = jsonObject["id"]{
                self.pushToJOBDetailViewController(withJOBID: "\(joID)")
            }
        }
    }
    func pushToJOBDetailViewController(withJOBID:String){
        DispatchQueue.main.async {
            if let jobDetailViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "JobDetailViewController") as? JobDetailViewController{
                         jobDetailViewController.hidesBottomBarWhenPushed = true
                         jobDetailViewController.jobId = "\(withJOBID)"
                         self.navigationController?.pushViewController(jobDetailViewController, animated: true)
                     }
        }
      }
   
}
