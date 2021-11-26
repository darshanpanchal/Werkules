//
//  MarketResearchViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 11/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import CoreLocation

class MarketResearchViewController: UIViewController {

    
    @IBOutlet weak var buttonBack:UIButton!
    @IBOutlet weak var tableViewMarketResearch:UITableView!
    //job keywords
    @IBOutlet weak var txtJOBKeywords:UITextField!
    
    //job category
    @IBOutlet weak var txtJOBCategory:UITextField!
    var businessCategoryPicker:UIPickerView = UIPickerView()
       var businessCategoryToolbar:UIToolbar = UIToolbar()
     var arrayOfCategory:[GeneralList] = []
    var businessCategory = "Automotive"
     var currentbusinessCategory:String{
             get{
                 return  businessCategory
             }
             set{
                 self.businessCategory = newValue
             }
     }
    //job ranges in miles
    @IBOutlet fileprivate weak var distanceMilesSlider:RangeSeekSlider!
    
    //minimum and maximum value
    @IBOutlet fileprivate weak var minimumAndMaimmumValueSlider:RangeSeekSlider!
    
    
    //Select Type
    @IBOutlet fileprivate weak var buttonInprogressLocation:UIButton!
    @IBOutlet fileprivate weak var buttonWaitingLocation:UIButton!
    @IBOutlet fileprivate weak var buttonCompletedLocation:UIButton!
    
    var searchTypeSet:NSMutableSet = NSMutableSet()//completed","pending","progress
    
    
    @IBOutlet fileprivate weak var buttonHomeLocation:UIButton!
    @IBOutlet fileprivate weak var buttonCurrentLocation:UIButton!
    
    var isHome:Bool = true
    var isHomeLocation:Bool {
        get{
            return isHome
        }
        set{
            self.isHome = newValue
            //Configure isHome
            DispatchQueue.main.async {
                self.configureHomeLocationSelector()
            }
        }
    }
    
    var marketSearchParmaters:[String:Any] = [:]
    
    
    var location = CLLocationCoordinate2D()
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonInprogressLocation.isSelected = true
        self.buttonWaitingLocation.isSelected = false
        self.buttonCompletedLocation.isSelected = true
        
        self.isHomeLocation = true
        //setup
        self.setup()
        //configure tableview
        self.configureTableView()
        //setup picker
        self.configureCategoryPicker()
    }
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          self.locationManager.stopUpdatingLocation()
         
      }
    //Setup
    func setup(){
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            //
            if let pi: Double = Double("\(appDelegate.minMiles)"){
               let strMinMiles = String(format:"%.2f", pi)
               self.distanceMilesSlider.minValue = CGFloat((strMinMiles as  NSString).floatValue)
               self.distanceMilesSlider.selectedMinValue = CGFloat((strMinMiles as NSString).floatValue)
            }
            if let pi: Double = Double("\(appDelegate.maxMiles)"){
                let strMaxMiles = String(format:"%.2f", pi)
                self.distanceMilesSlider.maxValue = CGFloat((strMaxMiles as NSString).floatValue)
                self.distanceMilesSlider.selectedMaxValue = CGFloat((strMaxMiles as NSString).floatValue)
            }
            
            //
            if let pi: Double = Double("\(appDelegate.jobMinPrice)"){
               let strMinPrice = String(format:"%.2f", pi)
               self.minimumAndMaimmumValueSlider.minValue = CGFloat((strMinPrice as  NSString).floatValue)
               self.minimumAndMaimmumValueSlider.selectedMinValue = CGFloat((strMinPrice as NSString).floatValue)
            }
            if let pi: Double = Double("\(appDelegate.jobMaxPrice)"){
                let strMaxPrice = String(format:"%.2f", pi)
                self.minimumAndMaimmumValueSlider.maxValue = CGFloat((strMaxPrice as NSString).floatValue)
                self.minimumAndMaimmumValueSlider.selectedMaxValue = CGFloat((strMaxPrice as NSString).floatValue)
            }
            self.minimumAndMaimmumValueSlider.delegate = self
            self.distanceMilesSlider.handleDiameter = 20.0
            self.minimumAndMaimmumValueSlider.handleDiameter = 20.0
             
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
    func configureHomeLocationSelector(){
        if self.isHomeLocation{
            self.buttonHomeLocation.isSelected = false
            self.buttonCurrentLocation.isSelected = true
        }else{
            self.buttonHomeLocation.isSelected = true
            self.buttonCurrentLocation.isSelected = false
        }
    }
    //Configure TableView
    func configureTableView(){
        //self.tableViewMarketResearch.sizeHeaderFit()
        self.tableViewMarketResearch.scrollEnableIfTableViewContentIsLarger()
        self.tableViewMarketResearch.hideFooter()
    }
    func resentAllFields(){
        //self.setup()
        self.txtJOBKeywords.text = ""
        self.txtJOBCategory.text = ""
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let pi: Double = Double("\(appDelegate.maxMiles)"){
                                let strMaxMiles = String(format:"%.2f", pi)
                                self.distanceMilesSlider.selectedMaxValue = CGFloat((strMaxMiles as NSString).floatValue)
            }
            if let pi: Double = Double("\(appDelegate.jobMinPrice)"){
                        let strMinPrice = String(format:"%.2f", pi)
                        self.minimumAndMaimmumValueSlider.selectedMinValue = CGFloat((strMinPrice as NSString).floatValue)
                     }
                     if let pi: Double = Double("\(appDelegate.jobMaxPrice)"){
                         let strMaxPrice = String(format:"%.2f", pi)
                         self.minimumAndMaimmumValueSlider.selectedMaxValue = CGFloat((strMaxPrice as NSString).floatValue)
                     }
        }
        self.minimumAndMaimmumValueSlider.setNeedsLayout()
        self.minimumAndMaimmumValueSlider.layoutSubviews()
        self.distanceMilesSlider.setNeedsLayout()
        self.distanceMilesSlider.layoutSubviews()
        
        self.buttonInprogressLocation.isSelected = true
        self.buttonWaitingLocation.isSelected = false
        self.buttonCompletedLocation.isSelected = true

        self.isHomeLocation = true
    }
    //isValid Data
    func isValidData()->Bool {
        /*guard let keyword = self.txtJOBKeywords.text?.trimmingCharacters(in: .whitespacesAndNewlines),keyword.count > 0 else{
              DispatchQueue.main.async {
                  SAAlertBar.show(.error, message:"Please enter JOB Keyword".localizedLowercase)
              }
                     return false
              }
        */
        if let keyword = self.txtJOBKeywords.text?.trimmingCharacters(in: .whitespacesAndNewlines){
          self.marketSearchParmaters["job_keyword"] = "\(keyword)"
        }
          
        
        
        guard let category = self.txtJOBCategory.text?.trimmingCharacters(in: .whitespacesAndNewlines),category.count > 0 else{
            DispatchQueue.main.async {
                SAAlertBar.show(.error, message:"Please enter JOB Category".localizedLowercase)
            }
                   return false
            }
        let filterArray2 = self.arrayOfCategory.filter{$0.name == category}
               if filterArray2.count > 0{
                   self.marketSearchParmaters["category"] = filterArray2.first!.id
               }
        
        if let value = self.distanceMilesSlider.selectedMaxValue as? CGFloat{
            self.marketSearchParmaters["miles"] = "\(value)"
        }
        if let value = self.minimumAndMaimmumValueSlider.selectedMinValue as? CGFloat{
                   self.marketSearchParmaters["min_price"] = "\(value)"
            }
        if let value = self.minimumAndMaimmumValueSlider.selectedMaxValue as? CGFloat{
                   self.marketSearchParmaters["max_price"] = "\(value)"
            }
        
        var arrayOfStatus:[String] = []
        if !self.buttonInprogressLocation.isSelected{
            arrayOfStatus.append("progress")
        }
        if !self.buttonWaitingLocation.isSelected{
            arrayOfStatus.append("pending")
        }
        if !self.buttonCompletedLocation.isSelected{
            arrayOfStatus.append("completed")
        }
        self.marketSearchParmaters["status"] = arrayOfStatus
        if self.isHomeLocation{
                   self.marketSearchParmaters["lat"] = ""
                   self.marketSearchParmaters["lng"] = ""
        }
        
        
        return true
    }
    //Configure Category Picker
    func configureCategoryPicker(){
        let doneBusinesCategoryPicker = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(MarketResearchViewController.doneBusinesCategoryPicker))
               let title2 = UILabel.init()
               title2.attributedText = NSAttributedString.init(string: "Category", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
               
               title2.sizeToFit()
               let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)

               let cancelButton2 = UIBarButtonItem(title:"Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(MarketResearchViewController.cancelFormDatePicker))

               self.businessCategoryToolbar.setItems([cancelButton2,spaceButton,UIBarButtonItem.init(customView: title2),spaceButton,doneBusinesCategoryPicker], animated: false)
               self.businessCategoryToolbar.sizeToFit()
                     self.businessCategoryToolbar.layer.borderColor = UIColor.clear.cgColor
                     self.businessCategoryToolbar.layer.borderWidth = 1.0
                     self.businessCategoryToolbar.clipsToBounds = true
                     self.businessCategoryToolbar.backgroundColor = UIColor.white
                     self.businessCategoryPicker.delegate = self
                     self.businessCategoryPicker.dataSource = self
               self.businessCategoryPicker.tag = 2
               self.txtJOBCategory.inputView = self.businessCategoryPicker
               self.txtJOBCategory.inputAccessoryView = self.businessCategoryToolbar
        
        
        
        
        
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.arrayOfCategory = appDelegate.arrayCategory
              if self.arrayOfCategory.count > 0{
                 //self.currentbusinessCategory = self.arrayOfCategory[0].name
                 //self.txtJOBCategory.text = self.currentbusinessCategory
                 let filterArray = self.arrayOfCategory.filter{$0.name == self.currentbusinessCategory}
                 if filterArray.count > 0{
                     //self.marketSearchParmaters["category"] = filterArray.first!.id
                 }
             }
        }
   
    }
    @objc func doneBusinesCategoryPicker(){
         self.configureSelectedBusinessCategoryActive()
         DispatchQueue.main.async {
             self.view.endEditing(true)
         }
     }
     @objc func cancelFormDatePicker(){
         DispatchQueue.main.async {
             self.view.endEditing(true)
         }
     }
    func configureSelectedBusinessCategoryActive(){
                   DispatchQueue.main.async {
                       self.txtJOBCategory.text = self.currentbusinessCategory
                    let filterArray = self.arrayOfCategory.filter{$0.name == self.currentbusinessCategory}
                    if filterArray.count > 0{
                        self.marketSearchParmaters["category"] = filterArray.first!.id
                    }
                   }
               }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonResetSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.resentAllFields()
        }
    }
    @IBAction func buttonInprogressSelector(sender:UIButton){
        self.buttonInprogressLocation.isSelected = !self.buttonInprogressLocation.isSelected
    }
    @IBAction func buttonWaitingsSelector(sender:UIButton){
        self.buttonWaitingLocation.isSelected = !self.buttonWaitingLocation.isSelected
    }
    @IBAction func buttonCompletedSelector(sender:UIButton){
        if self.buttonCompletedLocation.isSelected{
            self.buttonCompletedLocation.isSelected = !self.buttonCompletedLocation.isSelected
        }
        
    }
    @IBAction func buttonHomeCurrentLocationSelector(sender:UIButton){
        self.isHomeLocation = !self.isHomeLocation
    }
    @IBAction func buttonSearchSelector(sender:UIButton){
        if self.isValidData(){
            self.searchMarketResearchAPIRequest()
        }
    }
    // MARK: - API Request
    func searchMarketResearchAPIRequest(){
        print(self.marketSearchParmaters)
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kJOBMarketSearch , parameter: self.marketSearchParmaters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let arrayJOBResult = success["success_data"] as? [[String:Any]]{
                                   
                    self.pushToMarketResearchViewController(result: arrayJOBResult)
                    
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
    func pushToMarketResearchViewController(result:[[String:Any]]){
        DispatchQueue.main.async {
            self.resentAllFields()
            if let resultViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "MarketResearchResultViewController") as? MarketResearchResultViewController{
                      resultViewController.hidesBottomBarWhenPushed = true
                     resultViewController.arrayOfResult = result
                      self.navigationController?.pushViewController(resultViewController, animated: true)
                  }
        }
      
    }

}
extension MarketResearchViewController:RangeSeekSliderDelegate{
    fileprivate func priceString(value: CGFloat) -> String {
        
        if let pi: Double = Double("\(value)"){
        let price = String(format:"%.f", pi)
            return "$\(price)"
        }
        /*
        if value == .leastNormalMagnitude {
              return "min $ \(value)"
        } else if value == .greatestFiniteMagnitude {
              return "max $ \(value)"
          } else {
              return "$ \(value)"
          }*/
         return "$\(value)"
      }
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMinValue minValue: CGFloat) -> String? {
        return priceString(value: minValue)
    }

    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue maxValue: CGFloat) -> String? {
        return priceString(value: maxValue)
    }
}
extension MarketResearchViewController:UIPickerViewDelegate,UIPickerViewDataSource, CLLocationManagerDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
             return self.arrayOfCategory[row].name
       }
       func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
           return UIScreen.main.bounds.width
       }
       func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
           return 30.0
       }
       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
             return self.arrayOfCategory.count
       }
       func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1
       }
       func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.currentbusinessCategory = self.arrayOfCategory[row].name
        
       }
    //MARK: - Location Manager Delegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latestLocation: AnyObject = locations[locations.count - 1]
        let mystartLocation = latestLocation as! CLLocation;
        
        UserJob.Shared.lat = String(mystartLocation.coordinate.latitude)
        UserJob.Shared.long =  String(mystartLocation.coordinate.longitude)
        self.marketSearchParmaters["lat"] = String(mystartLocation.coordinate.latitude)
        self.marketSearchParmaters["lng"] = String(mystartLocation.coordinate.longitude)
       
    }
}

