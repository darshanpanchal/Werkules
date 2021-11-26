//
//  PostJobVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 25/07/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation
import TaggerKit
import Firebase
import YPImagePicker
import AVFoundation
import MobileCoreServices
import CropViewController

protocol PostJOBSingleProviderDelegate {
    func postCreatedFromSingleProviderBook()
}
class PostJobVC: UIViewController,GMSAutocompleteViewControllerDelegate,UITextFieldDelegate,CLLocationManagerDelegate,TKCollectionViewDelegate,UITextViewDelegate ,SearchKeywordDelegate{
    
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var txtFieldJobTitle: UITextField!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    
    @IBOutlet weak var txtFieldEstBudget: UITextField!
    @IBOutlet weak var txtFieldLocation: UITextField!
    @IBOutlet weak var txtViewDescription: UITextView!
    @IBOutlet weak var btnPost: UIButton!
    @IBOutlet weak var switchService: UISwitch!
    @IBOutlet weak var viewJob: UIView!
    
    @IBOutlet weak var tableViewAddPost:UITableView!
    @IBOutlet weak var buttonAddImage:UIButton!
    @IBOutlet weak var collectionViewImages:UICollectionView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var txtKeepPostActive: UITextField!
    @IBOutlet weak var txtTravelTime: UITextField!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var txtAskingPrice: UITextField!
    
    @IBOutlet weak var buttonHomeAddress:UIButton!
    @IBOutlet weak var buttonCurrentAddress:UIButton!
    @IBOutlet weak var buttonPost:UIButton!
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var buttonMoreoptions:UIButton!
    @IBOutlet weak var viewMoreoptions:UIView!
    @IBOutlet weak var viewMoreImageoptions:UIView!
    @IBOutlet weak var viewMoreKeepPostActiveoptions:UIView!
    @IBOutlet weak var viewMoreTravelTimeoptions:UIView!
    @IBOutlet weak var viewMoreCategoryoptions:UIView!
    
    @IBOutlet weak var buttonBackSelector:UIButton!
    @IBOutlet weak var lblAskingPrice:UILabel!
    @IBOutlet weak var lblAskingPriceStar:UILabel!
    
    
    var delegate:PostJOBSingleProviderDelegate?
    
    var homeSelected = true
    var isHomeLocationSelected:Bool{
        get{
            return homeSelected
        }
        set{
            homeSelected = newValue
            self.cofigureLocationSelection()
        }
    }
    var arrayOfImages:[[String:Any]] = []
    
    var arrayOfTravelTime:[GeneralList] = []
           
    var businessTime = "1 hour, 00 minutes"
    var currentTravelTime:String{
       get{
           return  businessTime
       }
       set{
           self.businessTime = newValue
       }
    }
    var travelTimePicker:UIPickerView = UIPickerView()
    var travelTimePickerToolbar:UIToolbar = UIToolbar()
    
    var arrayOfKeepPostActive:[GeneralList] = []
    var keepPostActive = "1 Month"
      var currentKeepPostActive:String{
         get{
             return  keepPostActive
         }
         set{
             self.keepPostActive = newValue
         }
      }
      var keepPostActivePicker:UIPickerView = UIPickerView()
      var keepPostActiveToolbar:UIToolbar = UIToolbar()
    
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
    var businessCategoryPicker:UIPickerView = UIPickerView()
    var businessCategoryToolbar:UIToolbar = UIToolbar()
       
    
    
    var location = CLLocationCoordinate2D()
    var locationManager: CLLocationManager = CLLocationManager()
    
    var isJobEditing = Bool()
    var isactivity = Bool()
    var dictJob = NSDictionary()
    
    var firstImageSet = Bool()
    var secondImageSet = Bool()
    var thirdImageSet = Bool()
    var fourthImageSet = Bool()
    
    var shouldGetAddress = Bool()
    var selectedImagesArray = NSMutableArray()
    
    var isFromProfile = Bool()
    var isFromActivity = Bool()
    var jobDictModel = UserJobListModel()
    var dictJobModel = NSDictionary()
    
    var imagesChanged = Bool()
    var deleteFlag = String()
    
    var addJOBParameters:[String:Any] = [:]
 
    var strPrefilledTitle:String = ""
    
    var placeholderLabel : UILabel!
    
    var isForEditJOBOnWidenSearch:Bool = false
    
    var isForSingleProviderBook:Bool = false
    var singleProvider:NotifiedProviderOffer?
    var providerID = ""
    var providerName = ""
    
    var objImagePickerController = UIImagePickerController()
    var imageForCrop: UIImage?
    var isForDirectBook = false

    var isFromHome:Bool = false
    
    let currentUserdefault = UserDefaults.standard

    
    
    //MARK: - UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtAskingPrice.keyboardType = .decimalPad
        self.txtAskingPrice.delegate = self
        self.txtTitle.delegate = self

        if self.isForSingleProviderBook{
            if let provider = self.singleProvider,let customerdetail = provider.customerDetail as? [String:Any],let firstname = customerdetail["firstname"],let lastname = customerdetail["lastname"]{
                self.lblTitle.text = "Create a Post for \(firstname) \(lastname)"
                self.lblAskingPrice.text = "Agreed Price"
                self.lblAskingPriceStar.isHidden = false
                if self.isForDirectBook{
                    self.lblTitle.text = "Direct Book for \(firstname) \(lastname)"
                }else{
                    self.lblTitle.text = "Create a Post for \(firstname) \(lastname)"
                }
            }else if providerName.count > 0 {
                self.lblAskingPriceStar.isHidden = false
                self.lblAskingPrice.text = "Agreed Price"
                self.lblTitle.text = "Create a Post for \(providerName)"
                 if self.isForDirectBook{
                    self.lblTitle.text = "Direct Book for \(providerName)"
                 }else{
                    self.lblTitle.text = "Create a Post for \(providerName)"
                }
            }else{
                self.lblAskingPriceStar.isHidden = true
                self.lblAskingPrice.text = "Budget"
                self.lblTitle.text = "Create a Post"
            }
        }else{
            self.lblAskingPriceStar.isHidden = true
            self.lblAskingPrice.text = "Budget"
            self.lblTitle.text = "Create a Post"
        }
        let underlineSeeDetail = NSAttributedString(string: "More Post Options",
                                                                  attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.buttonMoreoptions.titleLabel?.attributedText = underlineSeeDetail
        // Do any additional setup after loading the view.
        /*
        GMSPlacesClient.provideAPIKey("AIzaSyANGw649sAMH-QJ0qXIjSdWOQfdFDrvz4M")
        
        imagesChanged = false
        
        if self.isJobEditing == true {
            print(self.dictJob)
            
            setUpView()
            
            btnPost.setTitle("UPDATE", for: .normal)
        }
        else {
            self.deleteFlag = "0"
            txtViewDescription.textColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.3)
            
            txtViewDescription.text = "Tell us a little more about what you are looking for"
            switchService.isOn = false
            viewJob.isUserInteractionEnabled = false
            viewJob.alpha = 0.5
            
            btnPost.setTitle("POST", for: .normal)
        }
        */
        self.view.endEditing(true)
        if self.isForDirectBook || self.isForSingleProviderBook{
            self.viewMoreoptions.fadeOut() //hide
            self.viewMoreImageoptions.fadeIn() //show
            self.viewMoreKeepPostActiveoptions.fadeOut() //show
            self.viewMoreTravelTimeoptions.fadeOut() //show
            self.viewMoreCategoryoptions.fadeOut() //show
            self.buttonPost.setTitle("Book", for: .normal)
            self.buttonBackSelector.setTitle("Cancel", for: .normal)
            self.buttonBackSelector.setTitleColor(UIColor.white, for: .normal)
            self.buttonBackSelector.borderColor = UIColor.clear
            self.buttonBackSelector.setBackgroundImage(UIImage.init(named: "background_update"), for: .normal)
        }else{
            self.viewMoreoptions.fadeIn() //hide
            self.viewMoreImageoptions.fadeOut() //show
            self.viewMoreKeepPostActiveoptions.fadeOut() //show
            self.viewMoreTravelTimeoptions.fadeOut() //show
            self.viewMoreCategoryoptions.fadeOut() //show
            self.buttonPost.setTitle("Post", for: .normal)
            self.buttonBackSelector.setTitle("Back", for: .normal)
            self.buttonBackSelector.setTitleColor(UIColor.init(hex: "AAAAAA"), for: .normal)
            self.buttonBackSelector.borderColor = UIColor.init(hex: "AAAAAA")
            self.buttonBackSelector.setBackgroundImage(nil, for: .normal)
        }
        do{
            self.sizeHeaderFit()
        }
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      self.tabBarController?.tabBar.isHidden = true
        self.mylocation()
        /*
        if self.isJobEditing == false {
         
            btnBack.isHidden = true
            btnMenu.isHidden = false
            
            switchService.isUserInteractionEnabled = true
        }
        else {
            btnBack.isHidden = false
            btnMenu.isHidden = true
            
            switchService.isUserInteractionEnabled = false
        }
          
        */
        self.sizeHeaderFit()
        self.isHomeLocationSelected = true
        self.buttonAddImage.imageView?.contentMode = .scaleAspectFit
        
        self.configureUIPickers()
        self.view.endEditing(true)
        if self.strPrefilledTitle.count > 0{
            self.txtTitle.text = "\(strPrefilledTitle)"
        }



    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.tabBarController?.tabBar.isHidden = !self.isFromHome
//        self.clearAllDataResetPage()
        DispatchQueue.main.async {
            if let title = self.txtTitle.text,title.count > 0{
                self.strPrefilledTitle = title
            }
            self.txtTitle.resignFirstResponder()
        }
        self.locationManager.stopUpdatingLocation()

        

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.txtTitle.setPlaceHolderColor()
        self.txtDescription.delegate = self
        self.collectionViewImages.delegate = self
        self.collectionViewImages.dataSource = self
        self.collectionViewImages.reloadData()
        self.placeholderLabel = UILabel()
         self.placeholderLabel.text = "Tell us a little more about what you are looking for"
         self.placeholderLabel.numberOfLines = 0
         self.placeholderLabel.font = UIFont(name: "Avenir Medium", size: 16)
         self.placeholderLabel.sizeToFit()
         
        if let viewWithTag = self.txtDescription.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
         self.placeholderLabel.tag = 100
         self.txtDescription.addSubview(placeholderLabel)
         self.placeholderLabel.frame = CGRect.init(origin: CGPoint(x: 3.0, y: 0.0), size: CGSize.init(width: self.txtDescription.bounds.width - 10.0, height: self.txtDescription.bounds.height - 10.0))
         //self.placeholderLabel.frame.origin =
         self.placeholderLabel.textColor = UIColor.lightGray
        
        if self.txtDescription.text.count > 0{
            self.placeholderLabel.isHidden = true
        }else{
            self.placeholderLabel.isHidden = false
        }
        
        DispatchQueue.main.async {
            self.tableViewAddPost.tableFooterView = UIView()
        }
        
    }
    //MARK: - User Defined Methods
    func cofigureLocationSelection(){
        if self.isHomeLocationSelected{
            self.buttonHomeAddress.isSelected = false
            self.buttonCurrentAddress.isSelected = true
        }else{
            self.buttonHomeAddress.isSelected = true
            self.buttonCurrentAddress.isSelected = false
        }
    }
    func configureUIPickers(){
        self.travelTimePicker.tag = 0
        self.keepPostActivePicker.tag = 1
        self.businessCategoryPicker.tag = 2
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.currentTravelTime = appDelegate.defaultTravelTime.name
            self.configureSelectedBusinessTravelTime()
               self.arrayOfTravelTime =  appDelegate.arrayTravelTime
                if self.arrayOfTravelTime.count > 0{
            //        self.currentTravelTime = self.arrayOfTravelTime[0].name
//                    self.txtTravelTime.text = self.currentTravelTime
                    let filterArray = self.arrayOfTravelTime.filter{$0.name == self.currentTravelTime}
                    if filterArray.count > 0{
                        self.addJOBParameters["travel_time"] = filterArray.first!.id
                    }
                }
            self.currentKeepPostActive = appDelegate.defaultPostActive.name
            self.configureSelectedBusinessKeepPostActive()
             self.arrayOfKeepPostActive = appDelegate.arrayPostActive
             if self.arrayOfKeepPostActive.count > 0{
             //  self.currentKeepPostActive = self.arrayOfKeepPostActive[0].name
//                self.txtKeepPostActive.text = self.currentKeepPostActive
                let filterArray = self.arrayOfKeepPostActive.filter{$0.name == self.currentKeepPostActive}
                if filterArray.count > 0{
                    self.addJOBParameters["keep_post_active"] = filterArray.first!.id
                }
            }
            self.currentbusinessCategory = appDelegate.defaultCategory.name
            self.configureSelectedBusinessCategoryActive()
             self.arrayOfCategory = appDelegate.arrayCategory
             if self.arrayOfCategory.count > 0{
              //  self.currentbusinessCategory = self.arrayOfCategory[0].name
//                self.txtCategory.text = self.currentbusinessCategory
                let filterArray = self.arrayOfCategory.filter{$0.name == self.currentbusinessCategory}
                if filterArray.count > 0{
                    self.addJOBParameters["category_id"] = filterArray.first!.id
                }
            }
        }
        
        self.configureBusinessTimePredefinePicker()
        
    }
    func configureBusinessTimePredefinePicker(){
        self.travelTimePickerToolbar.sizeToFit()
        self.travelTimePickerToolbar.layer.borderColor = UIColor.clear.cgColor
        self.travelTimePickerToolbar.layer.borderWidth = 1.0
        self.travelTimePickerToolbar.clipsToBounds = true
        self.travelTimePickerToolbar.backgroundColor = UIColor.white
        self.travelTimePickerToolbar.tintColor = UIColor.init(hex: "#38B5A3")
        self.travelTimePicker.delegate = self
        self.travelTimePicker.dataSource = self
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PostJobVC.donetravelTimePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "Travel Time", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:"Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PostJobVC.cancelFormDatePicker))
        self.travelTimePickerToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
        
        self.travelTimePicker.tag = 0
        self.txtTravelTime.inputView = UIView()//self.travelTimePicker
        self.txtTravelTime.inputAccessoryView = UIView()//self.travelTimePickerToolbar
        self.txtTravelTime.delegate = self
        self.keepPostActiveToolbar.sizeToFit()
        self.keepPostActiveToolbar.layer.borderColor = UIColor.clear.cgColor
        self.keepPostActiveToolbar.layer.borderWidth = 1.0
        self.keepPostActiveToolbar.clipsToBounds = true
        self.keepPostActiveToolbar.backgroundColor = UIColor.white
        self.keepPostActiveToolbar.tintColor = UIColor.init(hex: "#38B5A3")

        self.keepPostActivePicker.delegate = self
        self.keepPostActivePicker.dataSource = self
        
        
        let doneKeepPostActive = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PostJobVC.doneKeepPostPicker))
        
        let title1 = UILabel.init()
        title1.attributedText = NSAttributedString.init(string: "Keep Post Active", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title1.sizeToFit()
        let cancelButton1 = UIBarButtonItem(title:"Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PostJobVC.cancelFormDatePicker))
        self.keepPostActiveToolbar.setItems([cancelButton1,spaceButton,UIBarButtonItem.init(customView: title1),spaceButton,doneKeepPostActive], animated: false)
        
        self.keepPostActivePicker.tag = 1
        self.txtKeepPostActive.inputView = self.keepPostActivePicker
        self.txtKeepPostActive.inputAccessoryView = self.keepPostActiveToolbar
        
        
        
        self.businessCategoryToolbar.sizeToFit()
        self.businessCategoryToolbar.layer.borderColor = UIColor.clear.cgColor
        self.businessCategoryToolbar.layer.borderWidth = 1.0
        self.businessCategoryToolbar.clipsToBounds = true
        self.businessCategoryToolbar.backgroundColor = UIColor.white
        self.businessCategoryToolbar.tintColor = UIColor.init(hex: "#38B5A3")

        self.businessCategoryPicker.delegate = self
        self.businessCategoryPicker.dataSource = self
        
        
        let doneBusinesCategoryPicker = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PostJobVC.doneBusinesCategoryPicker))
        let title2 = UILabel.init()
        title2.attributedText = NSAttributedString.init(string: "Category", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title2.sizeToFit()
        
        let cancelButton2 = UIBarButtonItem(title:"Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PostJobVC.cancelFormDatePicker))

        self.businessCategoryToolbar.setItems([cancelButton2,spaceButton,UIBarButtonItem.init(customView: title2),spaceButton,doneBusinesCategoryPicker], animated: false)
        
        self.businessCategoryPicker.tag = 2
        self.txtCategory.inputView = self.businessCategoryPicker
        self.txtCategory.inputAccessoryView = self.businessCategoryToolbar
        
        
        
    }
   
    @objc func donetravelTimePicker(){
        self.configureSelectedBusinessTravelTime()
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    @objc func doneKeepPostPicker(){
           self.configureSelectedBusinessKeepPostActive()
           DispatchQueue.main.async {
               self.view.endEditing(true)
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
            //self.configureSelectedBusinessTravelTime()
            //self.configureSelectedBusinessKeepPostActive()
            //self.configureSelectedBusinessCategoryActive()
            self.view.endEditing(true)
        }
    }
    func configureSelectedBusinessTravelTime(){
           DispatchQueue.main.async {
               self.txtTravelTime.text = self.currentTravelTime
            let filterArray = self.arrayOfTravelTime.filter{$0.name == self.currentTravelTime}
            if filterArray.count > 0{
                let index = self.arrayOfTravelTime.firstIndex(where: {$0.id == "\(filterArray.first!.id)"})
                if let _ = index{
                    self.travelTimePicker.selectRow(index!, inComponent: 0, animated: true)
                }
                self.addJOBParameters["travel_time"] = filterArray.first!.id
            }
           }
       }
    func configureSelectedBusinessKeepPostActive(){
             DispatchQueue.main.async {
                 self.txtKeepPostActive.text = self.currentKeepPostActive
              let filterArray = self.arrayOfKeepPostActive.filter{$0.name == self.currentKeepPostActive}
              if filterArray.count > 0{
                let index = self.arrayOfKeepPostActive.firstIndex(where: {$0.id == "\(filterArray.first!.id)"})
                
                if let _ = index{
                    self.keepPostActivePicker.selectRow(index!, inComponent: 0, animated: true)
                }
                  self.addJOBParameters["keep_post_active"] = filterArray.first!.id
              }
             }
         }
    func configureSelectedBusinessCategoryActive(){
                DispatchQueue.main.async {
                    self.txtCategory.text = self.currentbusinessCategory
                 let filterArray = self.arrayOfCategory.filter{$0.name == self.currentbusinessCategory}
                    
                 if filterArray.count > 0{
                    let index = self.arrayOfCategory.firstIndex(where: {$0.id == "\(filterArray.first!.id)"})
                    
                    if let _ = index{
                        self.businessCategoryPicker.selectRow(index!, inComponent: 0, animated: true)
                    }
                    
                    
                    
                     self.addJOBParameters["category_id"] = filterArray.first!.id
                 }
                    
                    
                }
            }
    func sizeHeaderFit(){
             if let headerView =  self.tableViewAddPost.tableHeaderView {
                 headerView.setNeedsLayout()
                 headerView.layoutIfNeeded()
                 print(headerView.frame)
                 print(headerView.bounds)
                 
                 let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
                 var frame = headerView.frame
                 frame.size.height = height
                 headerView.frame = frame
                 self.tableViewAddPost.tableHeaderView = headerView
                 self.view.layoutIfNeeded()
             }
         }
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
    
    func setUpView() {
        
        if self.isactivity == true {
            UserJob.Shared.isActivity = "1"
            switchService.isOn = false
        }
        else {
            UserJob.Shared.isActivity = "0"
            switchService.isOn = true
        }
        
        if isFromProfile == true {
            
            if jobDictModel.jobImg1Path != "" {
                var url = jobDictModel.jobImg1Path!
                url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                
                if url.contains(".mp4") == true {
                    self.getThumbnailImageFromVideoUrl(url: URL(string: url)!) { (thumbImage) in
                        self.btn1.setImage(thumbImage, for: .normal)
                    }
                }
                else {
                    btn1.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                    }
                }
                firstImageSet = true
            }
            if jobDictModel.jobImg2Path != "" {
                
                var url = jobDictModel.jobImg2Path!
                url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                
                if url.contains(".mp4") == true {
                    self.getThumbnailImageFromVideoUrl(url: URL(string: url)!) { (thumbImage) in
                        self.btn2.setImage(thumbImage, for: .normal)
                    }
                }
                else {
                    btn2.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                            error, cache, url) in
                        }
                }
                
                secondImageSet = true
            }
            if jobDictModel.jobImg3Path != "" {
                var url = jobDictModel.jobImg3Path!
                url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                
                if url.contains(".mp4") == true {
                    self.getThumbnailImageFromVideoUrl(url: URL(string: url)!) { (thumbImage) in
                        self.btn3.setImage(thumbImage, for: .normal)
                    }
                }
                else {
                    btn3.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                    }
                }
                
                
                thirdImageSet = true
            }
            if jobDictModel.jobImg4Path != ""  {
                var url = jobDictModel.jobImg4Path!
                url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                
                if url.contains(".mp4") == true {
                    self.getThumbnailImageFromVideoUrl(url: URL(string: url)!) { (thumbImage) in
                        self.btn4.setImage(thumbImage, for: .normal)
                    }
                }
                else {
                    btn4.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                    }
                }
                
                fourthImageSet = true
            }
            
            if self.isactivity == true {
                txtViewDescription.text = jobDictModel.jobTitle
            }
            else {
                txtFieldJobTitle.text = jobDictModel.jobTitle
                txtViewDescription.text = jobDictModel.jobDescription
            }
            
            if txtViewDescription.text != "" || txtViewDescription.text != "Tell us a little more about what you are looking for" {
                txtViewDescription.textColor = UIColor(red: 9/255, green: 64/255, blue: 94/255, alpha: 1.0)
            }
            
            txtFieldEstBudget.text = jobDictModel.estimatedBudget
            txtFieldLocation.text = jobDictModel.jobAddress
            UserJob.Shared.lat = jobDictModel.jobLatitude
            UserJob.Shared.long = jobDictModel.jobLongitude
            let userID = jobDictModel.jobUserId
            UserJob.Shared.userId = "\(userID!)"
            let jobId = jobDictModel.jobId
            UserJob.Shared.jobID = "\(jobId!)"
        }
        else if isFromActivity == true {
            
            UserJob.Shared.jobID = String(dictJobModel["id"] as! Int)
            UserJob.Shared.userId = String(dictJobModel["user_id"] as! Int)
            
            let titleText = (dictJobModel["title"] as! String)
            
            if self.isactivity == true {
                txtViewDescription.text = titleText
            }
            else {
                txtFieldJobTitle.text = titleText
                txtViewDescription.text = (dictJobModel["description"] as! String)
            }
            
            if txtViewDescription.text != "" || txtViewDescription.text != "Tell us a little more about what you are looking for" {
                txtViewDescription.textColor = UIColor(red: 9/255, green: 64/255, blue: 94/255, alpha: 1.0)
            }
            
            txtFieldEstBudget.text = (dictJobModel["estimate_budget"] as! String)
            txtFieldLocation.text = (dictJobModel["address"] as! String)
            UserJob.Shared.lat = (dictJobModel["lat"] as! String)
            UserJob.Shared.long = (dictJobModel["lng"] as! String)
            
            if (dictJobModel["file1"] as! String) != "" {
                var url = (dictJobModel["file1"] as! String)
                url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                
                if url.contains(".mp4") == true {
                    self.getThumbnailImageFromVideoUrl(url: URL(string: url)!) { (thumbImage) in
                        self.btn1.setImage(thumbImage, for: .normal)
                    }
                }
                else {
                    btn1.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                    }
                }
                btn1.isHidden = false
                firstImageSet = true
            }
            if (dictJobModel["file2"] as! String) != "" {
                
                var url = (dictJobModel["file2"] as! String)
                url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
               
                if url.contains(".mp4") == true {
                    self.getThumbnailImageFromVideoUrl(url: URL(string: url)!) { (thumbImage) in
                        self.btn2.setImage(thumbImage, for: .normal)
                    }
                }
                else {
                    btn2.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                            error, cache, url) in
                        }
                }
                btn2.isHidden = false
                secondImageSet = true
            }
            if (dictJobModel["file3"] as! String) != "" {
                var url = (dictJobModel["file3"] as! String)
                url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                if url.contains(".mp4") == true {
                    self.getThumbnailImageFromVideoUrl(url: URL(string: url)!) { (thumbImage) in
                        self.btn3.setImage(thumbImage, for: .normal)
                    }
                }
                else {
                    btn3.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                    }
                }
                btn3.isHidden = false
                thirdImageSet = true
            }
            if (dictJobModel["file4"] as! String) != ""  {
                var url = (dictJobModel["file4"] as! String)
                url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                
                if url.contains(".mp4") == true {
                    self.getThumbnailImageFromVideoUrl(url: URL(string: url)!) { (thumbImage) in
                        self.btn4.setImage(thumbImage, for: .normal)
                    }
                }
                else {
                    btn4.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                    }
                }
                btn4.isHidden = false
                fourthImageSet = true
            }
        }
        else {
            if (dictJob.value(forKey: "file1") as! String).count > 0 {
                var url = dictJob.value(forKey: "file1") as! String
                url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                
                if url.contains(".mp4") == true {
                    self.getThumbnailImageFromVideoUrl(url: URL(string: url)!) { (thumbImage) in
                        self.btn1.setImage(thumbImage, for: .normal)
                    }
                }
                else {
                    btn1.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                    }
                }
                firstImageSet = true
            }
            if (dictJob.value(forKey: "file2") as! String).count > 0 {
                var url = dictJob.value(forKey: "file2") as! String
                url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                if url.contains(".mp4") == true {
                    self.getThumbnailImageFromVideoUrl(url: URL(string: url)!) { (thumbImage) in
                        self.btn2.setImage(thumbImage, for: .normal)
                    }
                }
                else {
                    btn2.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                            error, cache, url) in
                        }
                }
                secondImageSet = true
            }
            if (dictJob.value(forKey: "file3") as! String).count > 0 {
                var url = dictJob.value(forKey: "file3") as! String
                url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                if url.contains(".mp4") == true {
                    self.getThumbnailImageFromVideoUrl(url: URL(string: url)!) { (thumbImage) in
                        self.btn3.setImage(thumbImage, for: .normal)
                    }
                }
                else {
                    btn3.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                    }
                }
                thirdImageSet = true
            }
            if (dictJob.value(forKey: "file4") as! String).count > 0  {
                var url = dictJob.value(forKey: "file4") as! String
                url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                
                if url.contains(".mp4") == true {
                    self.getThumbnailImageFromVideoUrl(url: URL(string: url)!) { (thumbImage) in
                        self.btn4.setImage(thumbImage, for: .normal)
                    }
                }
                else {
                    btn4.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                    }
                }
                fourthImageSet = true
            }
            
            txtFieldJobTitle.text = (self.dictJob.value(forKey: "title") as! String)
            txtFieldEstBudget.text = (self.dictJob.value(forKey: "estimate_budget") as! String)
            txtFieldLocation.text = (self.dictJob.value(forKey: "address") as! String)
            txtViewDescription.text = (self.dictJob.value(forKey: "description") as! String)
            UserJob.Shared.lat = (self.dictJob.value(forKey: "lat") as! String)
            UserJob.Shared.long =  (self.dictJob.value(forKey: "lng") as! String)
            let userID = self.dictJob.value(forKey: "user_id") as! Int
            UserJob.Shared.userId = "\(userID)"
            let jobId = self.dictJob.value(forKey: "id") as! Int
            UserJob.Shared.jobID = "\(jobId)"
        }
    }
    
    func callAPIToGetCategories() {
        
        APIManager.sharedInstance.CallAPIPost(url: Url_Categories, parameter: nil, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                if self.isJobEditing == true {
                    self.setUpView()
                }
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    
    func resize(_ image: UIImage) -> UIImage {
        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxHeight: Float = 900
        let maxWidth: Float = 900
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        //50 percent compression
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        //let imageData = UIImageJPEGRepresentation(img!, CGFloat(compressionQuality))
        // let imageData = image.jpeg(UIImage.JPEGQuality(rawValue: CGFloat(compressionQuality))!)
        let imageData = img!.jpegData(compressionQuality: 0.3)
        
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!) ?? UIImage()
    }
    
    //MARK: - TKCollectionView Delegate Method
    
    func tagIsBeingAdded(name: String?) {
    }
    
    func tagIsBeingRemoved(name: String?) {
        
        let myCatArr = UserDefaults.standard.value(forKey: "selectedCategories") as! NSArray
        let selectedCategories = myCatArr.mutableCopy() as! NSMutableArray
        
        for item in selectedCategories {
            let dict = item as! NSDictionary
            let CatName = dict["name"] as! String
            
            if name == CatName {
                selectedCategories.remove(item)
            }
        }
        
        UserDefaults.standard.set(selectedCategories, forKey: "selectedCategories")
    }
    
    //MARK: - UISwitch Value Change Method
    
    @IBAction func switchServiceValueChangee(_ sender: UISwitch) {
        
        if sender.isOn == true {
            viewJob.isUserInteractionEnabled = true
            viewJob.alpha = 1.0
            txtFieldJobTitle.becomeFirstResponder()
        }
        else {
            viewJob.isUserInteractionEnabled = false
            viewJob.alpha = 0.5
        }
    }
    
    //MARK: - Actions
    @IBAction func buttonBackSelector(sender:UIButton){
        /*if let objTabView = self.navigationController?.tabBarController{
            
            if let objHomeNavigation = objTabView.viewControllers?.first as? UINavigationController,let objHome = objHomeNavigation.viewControllers.first as? HomeVC{
                objTabView.selectedIndex = 0
            }
            
        }*/
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonMoreOptionsSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.viewMoreoptions.fadeOut() //hide
            self.viewMoreImageoptions.fadeIn() //show
            self.viewMoreKeepPostActiveoptions.fadeIn() //show
            self.viewMoreTravelTimeoptions.fadeIn() //show
            self.viewMoreCategoryoptions.fadeIn() //show
            
            do{
                self.sizeHeaderFit()
            }
        }
    }
    @IBAction func buttonPostJOBSelector(sender:UIButton){
        
        if self.isValidData(){
            if self.isForSingleProviderBook{
                self.callSingleProviderBookAPIRequest()
            }else{
                self.callPostJOBAPIRequest()
            }
            
        }
//        self.presentJOBAddedSuccessFullyAlert()
    }
    func presentClassSearchViewController(){
           DispatchQueue.main.async {
            
            if let schoolClassPicker = UIStoryboard.activity.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
                   schoolClassPicker.modalPresentationStyle = .overFullScreen
                   schoolClassPicker.objSearchType = .TravelTime
                   schoolClassPicker.arrayOfTravelTime = self.arrayOfTravelTime
                   self.view.endEditing(true)
                   schoolClassPicker.delegate = self
                   schoolClassPicker.isSingleSelection = true
                
                let filterArray = self.arrayOfTravelTime.filter{$0.name == self.currentTravelTime}
                if filterArray.count > 0{
                    let currentselected = NSMutableSet()
                    currentselected.add(filterArray.first!.name)
                    schoolClassPicker.selectedTravelTime = currentselected
                }
                   self.present(schoolClassPicker, animated: true, completion: nil)
               }
           }
       }
    func presentJOBAddedSuccessFullyAlert(arrayProvider:[NotifiedProviderOffer]){
        
        if let objStory = self.storyboard?.instantiateViewController(withIdentifier: "AddPostAlertViewController") as? AddPostAlertViewController{
            objStory.modalPresentationStyle = .overFullScreen
            objStory.delegate = self
            objStory.arrayOfNotifiedProvider = arrayProvider
            self.present(objStory, animated: true, completion: nil)
        }
    }
    func presentJOBAddedSuccessFullyWithNoResultAlert(requestParameters:[String:Any]){
        if let objStory = self.storyboard?.instantiateViewController(withIdentifier: "AddPostAlertViewController") as? AddPostAlertViewController{
                 objStory.modalPresentationStyle = .overFullScreen
                 objStory.delegate = self
                 objStory.arrayOfNotifiedProvider = []
                objStory.isForWiddenSearch = true
                objStory.requestParameters = requestParameters
                self.present(objStory, animated: false, completion: nil)
             }
    }
    func presentWideSearchAlertViewController(requestParameters:[String:Any]){
        self.presentJOBAddedSuccessFullyWithNoResultAlert(requestParameters: requestParameters)
        /*
            let message = "No result found on your current search"
            let alert = UIAlertController(title: "\(AppName)", message: "\(message)", preferredStyle: .alert)
            let wideSearch = UIAlertAction.init(title: "Widen Your Search", style: .default) { (_ ) in
                self.callAPIRequestforWidenSearchRequest(requestParamters: requestParameters)
            }
               alert.addAction(wideSearch)
        
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { (_ ) in
            DispatchQueue.main.async {
                self.clearAllDataResetPage()
            }
        }
        
               alert.addAction(cancelAction)
               alert.view.tintColor = UIColor.init(hex: "#38B5A3")
               self.present(alert, animated: true, completion: nil)
        */
        
    }
    @IBAction func buttonAddImages(sender:UIButton){
        self.presentCameraAndPhotosSelector()
        /*
        var config = YPImagePickerConfiguration()
              config.showsPhotoFilters = false
              config.library.maxNumberOfItems = 1
              config.isScrollToChangeModesEnabled = false
              config.startOnScreen = .library
              config.albumName = "\(self.strPrefilledTitle)"
              let picker = YPImagePicker(configuration: config)
              
              picker.didFinishPicking { [unowned picker] items, _ in
                  if let photo = items.singlePhoto {
                      let aImg = photo.image
                      
                    let resizedImage = self.resize(aImg)
                    if let imageData = resizedImage.jpegData(compressionQuality: 0.5){
                        print("\(self.strPrefilledTitle)")
                        self.uploadPostImageAPIRequest(imageData: imageData)
                    }
                    
                  }
                
                  picker.dismiss(animated: true, completion: nil)
              }
              present(picker, animated: true, completion: nil)
        */
    }
    func presentCameraAndPhotosSelector(){
        //PresentMedia Selector
        let actionSheetController = UIAlertController.init(title: "", message: "Images", preferredStyle: .actionSheet)
        let cancelSelector = UIAlertAction.init(title: "Cancel", style: .cancel, handler:nil)
        cancelSelector.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
        
        actionSheetController.addAction(cancelSelector)
        let photosSelector = UIAlertAction.init(title: "Photos", style: .default) { (_) in
            DispatchQueue.main.async {
                self.objImagePickerController = UIImagePickerController()
                self.objImagePickerController.sourceType = .savedPhotosAlbum
                self.objImagePickerController.delegate = self
                self.objImagePickerController.allowsEditing = false
                self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                self.view.endEditing(true)
                self.presentImagePickerController()
            }
        }
        photosSelector.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
        
        actionSheetController.addAction(photosSelector)
        
   
        
        let cameraSelector = UIAlertAction.init(title: "Camera", style: .default) { (_) in
            if CommonClass.isSimulator{
                DispatchQueue.main.async {
                    let noCamera = UIAlertController.init(title:"Cameranotsupported", message: "", preferredStyle: .alert)
                    noCamera.addAction(UIAlertAction.init(title:"ok", style: .cancel, handler: nil))
                    self.present(noCamera, animated: true, completion: nil)
                }
            }else{
                DispatchQueue.main.async {
                    self.objImagePickerController = UIImagePickerController()
                    self.objImagePickerController.delegate = self
                    self.objImagePickerController.allowsEditing = false
                    self.objImagePickerController.sourceType = .camera
                    self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                    self.presentImagePickerController()
                }
            }
        }
        cameraSelector.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
        
        actionSheetController.addAction(cameraSelector)
        self.view.endEditing(true)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    func presentImagePickerController(){
           self.view.endEditing(true)
           self.objImagePickerController.modalPresentationStyle = .fullScreen
           self.present(self.objImagePickerController, animated: true, completion: nil)
          
       }
    @IBAction func buttonAlertInformationPopUp(sender:UIButton){
        
        var title = "", message:String = ""
        
        if sender.tag == 0{ //keep post active
            title = kKeepPostActive.0
            message = kKeepPostActive.1
        }else if sender.tag == 1{ //travel time
            title = kTravelTime.0
            message = kTravelTime.1
        }else if sender.tag == 2{ // Budget
            if self.isForSingleProviderBook{
                if self.isForDirectBook{
                    title = kAgreedPrice.0
                    message = "Please contact the provider to agree on a final price before you book this job. You can’t change the price later."
                }else{
                    title = kAgreedPrice.0
                    message = kAgreedPrice.1
                }
                
                
            }else{
                title = kAskingPrice.0
                message = kAskingPrice.1
            }
            
        }
        let alert = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: .alert)
        let cancelAction =  UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.view.tintColor = UIColor.init(hex: "#38B5A3")
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttonHomeAndCurrentAddressSelector(sender:UIButton){
        self.isHomeLocationSelected = !self.isHomeLocationSelected
    }
    @IBAction func btnBackClicked(_ sender: UIButton) {
        if let objTabView = self.navigationController?.tabBarController{
                   
                   if let objHomeNavigation = objTabView.viewControllers?.first as? UINavigationController,let objHome = objHomeNavigation.viewControllers.first as? HomeVC{
                       objTabView.selectedIndex = 0
                   }
                   
               }
        /*
        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
            let viewController = navController.viewControllers[navController.viewControllers.count - 2]
            if viewController.isKind(of: HomeVC.self) {
                self.navigationController?.popViewController(animated: true)
            }
            else if viewController.isKind(of: EntrepreneurProfileVC.self) {
                self.navigationController?.popViewController(animated: true)
            }
            else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }*/
    }
    
    @IBAction func btnMenuClicked(_ sender: UIButton) {
        
        txtViewDescription.resignFirstResponder()
        txtFieldJobTitle.resignFirstResponder()
        txtFieldLocation.resignFirstResponder()
        txtFieldEstBudget.resignFirstResponder()
        
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    @IBAction func btnaddPhotosClicked(_ sender: UIButton) {
        
        if selectedImagesArray.count > 0 {
            selectedImagesArray.removeAllObjects()
        }
        
        var config = YPImagePickerConfiguration()
        config.showsPhotoFilters = false
        config.library.maxNumberOfItems = 4
        config.isScrollToChangeModesEnabled = false
        config.startOnScreen = .library
        config.library.mediaType = .photoAndVideo
        config.screens = [.library, .photo, .video]
        
        let picker = YPImagePicker(configuration: config)
        present(picker, animated: true, completion: nil)
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if cancelled {
                print("Picker was canceled")
                
                //                self.imagesSelected = false
                //                let lastSelectedTabIndex = UserDefaults.standard.integer(forKey: "lastSelectedTabIndex")
                //
                //                let tabbarcontroller = self.navigationController?.parent as! UITabBarController
                //                tabbarcontroller.selectedIndex = lastSelectedTabIndex
                
                picker.dismiss(animated: true, completion: nil)
                return
            }
            
            var resizedImage = UIImage()
            
            for item in items {
                //                self.imagesSelected = false
                
                self.btnRemoveAllImages()
                self.imagesChanged = true
                self.deleteFlag = "1"
                
                switch item {
                case .photo(let photo):
                    
                    let dataDict = NSMutableDictionary.init()
                    let selectedImage = photo.image
                    resizedImage = self.resize(selectedImage)
                    
                    dataDict.setObject(resizedImage.pngData()!, forKey: "data" as NSCopying)
                    dataDict.setObject("Image", forKey: "type" as NSCopying)
                    
                    self.selectedImagesArray.add(dataDict)
                case .video(let video):
                    
                    let dataDict = NSMutableDictionary.init()
                    let selectedImage = video.thumbnail
                    resizedImage = self.resize(selectedImage)
                    let videoData = try? Data(contentsOf: video.url)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.fileOutput(outputFileURL: video.url,thumbnail: resizedImage)
                    }
                    
                default:
                    print("")
                }
            }
            //            self.performSegue(withIdentifier: "addDetailsSegue", sender: self)
            self.setImages()
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func setImages() {
        
        btn1.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        btn2.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        btn3.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        btn4.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        
        if self.selectedImagesArray.count > 0 {
            let dataDict = self.selectedImagesArray.object(at: 0) as! NSDictionary
            if dataDict["type"] as! String == "Image" {
                let imageData = dataDict["data"] as! NSData
                let image = UIImage(data: imageData as Data)
                btn1.setImage(image, for: .normal)
            }
            else {
                let imageData = dataDict["thumbnail"] as! NSData
                let image = UIImage(data: imageData as Data)
                btn1.setImage(image, for: .normal)
            }
            firstImageSet = true
        }
        if self.selectedImagesArray.count > 1 {
            let dataDict = self.selectedImagesArray.object(at: 1) as! NSDictionary
            if dataDict["type"] as! String == "Image" {
                let imageData = dataDict["data"] as! NSData
                let image = UIImage(data: imageData as Data)
                btn2.setImage(image, for: .normal)
            }
            else {
                let imageData = dataDict["thumbnail"] as! NSData
                let image = UIImage(data: imageData as Data)
                btn2.setImage(image, for: .normal)
            }
            secondImageSet = true
        }
        if self.selectedImagesArray.count > 2 {
            let dataDict = self.selectedImagesArray.object(at: 2) as! NSDictionary
            if dataDict["type"] as! String == "Image" {
                let imageData = (dataDict["data"] as! NSData)
                let image = UIImage(data: imageData as Data)
                btn3.setImage(image, for: .normal)
            }
            else {
                let imageData = dataDict["thumbnail"] as! NSData
                let image = UIImage(data: imageData as Data)
                btn3.setImage(image, for: .normal)
            }
            thirdImageSet = true
        }
        if self.selectedImagesArray.count > 3 {
            let dataDict = self.selectedImagesArray.object(at: 3) as! NSDictionary
            if dataDict["type"] as! String == "Image" {
                let imageData = (dataDict["data"] as! NSData)
                let image = UIImage(data: imageData as Data)
                btn4.setImage(image, for: .normal)
            }
            else {
                let imageData = dataDict["thumbnail"] as! NSData
                let image = UIImage(data: imageData as Data)
                btn4.setImage(image, for: .normal)
            }
            fourthImageSet = true
        }
    }
    
    func btnRemoveAllImages() {
        
        btn1.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        firstImageSet = false
        btn2.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        secondImageSet = false
        btn3.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        thirdImageSet = false
        btn4.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        fourthImageSet = false
    }
    
    @IBAction func btnAutoFillClicked(_ sender: UIButton) {
        
        self.shouldGetAddress = true
        mylocation()
    }
    
    @IBAction func btnPostClicked(_ sender: UIButton) {
        
        if isDataValid() {
            
            if firstImageSet == true //btn1.image(for: .normal) != UIImage(named: "Icon_Add_Picture")
            {
                UserJob.Shared.img1 = btn1.image(for: .normal)
            }
            if secondImageSet == true //btn2.image(for: .normal) != UIImage(named: "Icon_Add_Picture")
            {
                UserJob.Shared.img2 = btn2.image(for: .normal)
            }
            if thirdImageSet == true //btn3.image(for: .normal) != UIImage(named: "Icon_Add_Picture")
            {
                UserJob.Shared.img3 = btn3.image(for: .normal)
            }
            if fourthImageSet == true //btn4.image(for: .normal) != UIImage(named: "Icon_Add_Picture")
            {
                UserJob.Shared.img4 = btn4.image(for: .normal)
            }
            
            UserJob.Shared.fairMarketValue = "0"
            if switchService.isOn == true {
                UserJob.Shared.isActivity = "0"
                UserJob.Shared.jobTitle = txtFieldJobTitle.text!
                UserJob.Shared.estBudget = txtFieldEstBudget.text!
                UserJob.Shared.jobAddress = txtFieldLocation.text!
                if txtViewDescription.text != "Tell us a little more about what you are looking for" {
                    UserJob.Shared.jobDescription = txtViewDescription.text!
                }
            }
            else {
                UserJob.Shared.isActivity = "1"
                if txtViewDescription.text != "Tell us a little more about what you are looking for" {
                    UserJob.Shared.jobTitle = txtViewDescription.text!
                }
            }
            
            if self.isJobEditing == false {
                UserJob.Shared.userId = UserSettings.userID//(UserDefaults.standard.value(forKey: "userID") as! String)
            }
            //let selectedCategories = UserDefaults.standard.value(forKey: "selectedCategories")as! NSArray
            
            if self.deleteFlag == "1" {
                UserJob.Shared.mediaArray = self.selectedImagesArray
                UserJob.Shared.deleteFlag = "1"
            }
            else {
                UserJob.Shared.mediaArray = NSMutableArray.init()
                UserJob.Shared.deleteFlag = "0"
            }
            
            let timestamp = String(Date().currentTimeMillis())
            UserJob.Shared.vTimestamp = timestamp + "_" + UserJob.Shared.userId!
            
            btnPost.isUserInteractionEnabled = false
        
            
            callPostJobAPI()
        }
    }
    
    //MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latestLocation: AnyObject = locations[locations.count - 1]
        let mystartLocation = latestLocation as! CLLocation;
        
        UserJob.Shared.lat = String(mystartLocation.coordinate.latitude)
        UserJob.Shared.long =  String(mystartLocation.coordinate.longitude)
        self.addJOBParameters["lat"] = String(mystartLocation.coordinate.latitude)
        self.addJOBParameters["lng"] = String(mystartLocation.coordinate.longitude)
        
        if self.shouldGetAddress == true {
            self.shouldGetAddress = false
            getAddressFromLatLon(pdblLatitude: UserJob.Shared.lat!, withLongitude: UserJob.Shared.long!)
        }
    }
    
    // MARK: - UITextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if  textField == txtTitle && self.isFromHome && self.strPrefilledTitle.count == 0 && !self.isForSingleProviderBook{
            self.pushToSearchPersonCompanyViewController(isForCompany: false)
        }else if textField == txtFieldLocation {
            let gmsAutoCompleteViewController = GMSAutocompleteViewController()
            gmsAutoCompleteViewController.delegate = self
            
            present(gmsAutoCompleteViewController, animated: true) {
            }
        }else if textField == self.txtTravelTime{
            self.presentClassSearchViewController()
        }
    }
    //MARK: - Search Delegate
    func didSelectKeywordWith(response: [String : Any]) {
        DispatchQueue.main.async {
            if let name = response["keywords_for_business"]{
                self.txtTitle.resignFirstResponder()
                self.txtTitle.text = "\(name)"
            }
        }
    }
    func pushToSearchPersonCompanyViewController(isForCompany:Bool){
        if let searchViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "SearchPersonCompanyViewController") as? SearchPersonCompanyViewController{
            searchViewController.hidesBottomBarWhenPushed = true
            searchViewController.isForCompany =  isForCompany
            searchViewController.isfromCreatePost = true
            searchViewController.selectedSearchOption = 0//self.selectedSearchOption
            searchViewController.delegate = self
//            if let _ = self.selectedTag{
//                searchViewController.selectedTag = self.selectedTag!
//            }
            self.txtTitle.resignFirstResponder()
            self.navigationController?.pushViewController(searchViewController, animated: false)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.txtAskingPrice{
            let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
         
            let dotString = "."
            if let text = textField.text {
             let isDeleteKey = string.isEmpty
             if !isDeleteKey {
                 if text.contains(dotString) {
                   
                    if text.components(separatedBy: dotString)[1].count == 2 || string == dotString{
                                 return false
                     }
                 }
             }
            }
            if let pi: Double = Double("\(typpedString)"){
                print("\(pi) ===== ")
                return pi <= maxJOBAmount
            }
            
          
            
          return true
        }
        if textField == txtFieldJobTitle {
            let maxLength = 100
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        
        return true
    }
    
    // MARK: - UITexyView Delegate Method
    /*
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Tell us a little more about what you are looking for" {
            textView.text = ""
            txtViewDescription.textColor = UIColor(red: 9/255, green: 64/255, blue: 94/255, alpha: 1.0)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            // textView.resignFirstResponder()
            return true
        }
        if textView == txtViewDescription {
            
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            let numberOfChars = newText.count
            
            if switchService.isOn == true {
                return numberOfChars < 100
            }
            return numberOfChars < 1000
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Tell us a little more about what you are looking for"
            
            txtViewDescription.textColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.3)
        }
    } */
    
    // MARK: - User Defined Methods
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
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
    
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        //21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    var addressString : String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    
                    self.txtFieldLocation.text = addressString
                }
        })
    }
    
    func isDataValid() -> Bool {
        
        if switchService.isOn == false {
            if firstImageSet == false && secondImageSet == false && thirdImageSet == false && fourthImageSet == false && txtViewDescription.text == "" || txtViewDescription.text == "Tell us a little more about what you are looking for" {
                SAAlertBar.show(.error, message:"Invalid data to post".localizedLowercase)
                return false
            }
        }
        
        if switchService.isOn == true {
            
            if firstImageSet == false && secondImageSet == false && thirdImageSet == false && fourthImageSet == false {
                SAAlertBar.show(.error, message:"Please enter atleast one photo".localizedLowercase)
                return false
            }
            if (txtFieldJobTitle.text?.isEmpty)!{
                SAAlertBar.show(.error, message:"Please enter job title".localizedLowercase)
                return false
            }
            
            if (txtFieldEstBudget.text?.isEmpty)!{
                SAAlertBar.show(.error, message:"Please enter estimated budget".localizedLowercase)
                return false
            }
            
            if (txtFieldLocation.text?.isEmpty)!{
                SAAlertBar.show(.error, message:"Please enter location".localizedLowercase)
                return false
            }
        }
        
        return true
    }
    
    func clearModelData() {
        
        UserJob.Shared.arrCategory = NSArray.init() as! [UserJob]
        UserJob.Shared.jobID = ""
        UserJob.Shared.catId = ""
        UserJob.Shared.jobTitle = ""
        UserJob.Shared.estBudget = ""
        UserJob.Shared.fairMarketValue = ""
        UserJob.Shared.jobAddress = ""
        UserJob.Shared.jobDescription = "Tell us a little more about what you are looking for"
        UserJob.Shared.img1 = nil
        UserJob.Shared.img2 = nil
        UserJob.Shared.img3 = nil
        UserJob.Shared.img4 = nil
        UserJob.Shared.lat = ""
        UserJob.Shared.long = ""
        UserJob.Shared.isActivity = "0"
        
        //self.txtFieldJobTitle.text = ""
        btn1.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        btn2.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        btn3.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        btn4.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        
        txtFieldEstBudget.text = ""
        txtViewDescription.text = ""
        txtFieldLocation.text = ""
        
        locationManager.stopUpdatingLocation()
    }
    func clearAllDataResetPage(){
        DispatchQueue.main.async {
            self.strPrefilledTitle = ""
            self.txtTitle.text = ""//"self.strPrefilledTitle
            self.arrayOfImages = []
            self.collectionViewImages.reloadData()
            self.txtDescription.text = ""
            self.placeholderLabel.isHidden = false
            self.txtAskingPrice.text = ""
            self.txtKeepPostActive.text = ""
            self.txtTravelTime.text = ""
            self.txtCategory.text = ""
            self.view.endEditing(true)
        }
    }
    private func isValidData()-> Bool{
            
       
        guard let businessName = self.txtTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines),businessName.count > 0 else{
            DispatchQueue.main.async {
                SAAlertBar.show(.error, message:"Please enter title".localizedLowercase)
            }
                   return false
            }
        self.addJOBParameters["title"] = "\(businessName)"
        
        if self.arrayOfImages.count > 0{
            self.addJOBParameters["images"] = self.arrayOfImages
        }
//        guard self.arrayOfImages.count > 0 else {
//            DispatchQueue.main.async {
//                SAAlertBar.show(.error, message:"Please add job images".localizedLowercase)
//            }
//            return false
//        }
        
        
        guard let jobDescription = self.txtDescription.text?.trimmingCharacters(in: .whitespacesAndNewlines),jobDescription.count > 0 else{
            DispatchQueue.main.async {
                 SAAlertBar.show(.error, message:"Please enter post description".localizedLowercase)
            }
                   return false
               }
        self.addJOBParameters["description"] = "\(jobDescription)"
        
        
        if let strKeepPostActive = self.txtKeepPostActive.text?.trimmingCharacters(in: .whitespacesAndNewlines),strKeepPostActive.count > 0 {
//            DispatchQueue.main.async {
//                 SAAlertBar.show(.error, message:"Please select keep post active time".localizedLowercase)
//            }
//                   return false
            let filterArray = self.arrayOfKeepPostActive.filter{$0.name == strKeepPostActive}
                   if filterArray.count > 0{
                       self.addJOBParameters["keep_post_active"] = filterArray.first!.id
                   }
               }
        
       
        
        
        if let strTravelTime = self.txtTravelTime.text?.trimmingCharacters(in: .whitespacesAndNewlines),strTravelTime.count > 0{
//           DispatchQueue.main.async {
//                SAAlertBar.show(.error, message:"Please select travel time".localizedLowercase)
//           }
//                  return false
            let filterArray1 = self.arrayOfTravelTime.filter{$0.name == strTravelTime}
            if filterArray1.count > 0{
                self.addJOBParameters["travel_time"] = filterArray1.first!.id
            }
              }
        
        
        if let strCategory = self.txtCategory.text?.trimmingCharacters(in: .whitespacesAndNewlines),strCategory.count > 0 {
//           DispatchQueue.main.async {
//                SAAlertBar.show(.error, message:"Please select Category".localizedLowercase)
//           }
//                  return false
            
            let filterArray2 = self.arrayOfCategory.filter{$0.name == strCategory}
                   if filterArray2.count > 0{
                       self.addJOBParameters["category_id"] = filterArray2.first!.id
                   }
              }
       
        
        if self.isForSingleProviderBook{
            guard let jobAskingPrice = self.txtAskingPrice.text?.trimmingCharacters(in: .whitespacesAndNewlines),jobAskingPrice.count > 0 else{
                           DispatchQueue.main.async {
                                SAAlertBar.show(.error, message:"Please enter the price you have agreed with the provider.".localizedLowercase)
                           }
                return false
              
            }
            self.addJOBParameters["asking_price"] = "\(jobAskingPrice)"
        }else{
            if let jobAskingPrice = self.txtAskingPrice.text?.trimmingCharacters(in: .whitespacesAndNewlines),jobAskingPrice.count > 0{
                       DispatchQueue.main.async {
                        //  SAAlertBar.show(.error, message:"Please enter job Budget".localizedLowercase)
                       }
                        self.addJOBParameters["estimate_budget"] = "\(jobAskingPrice)"
                    }
        }
       
        /*let price:Int = (jobAskingPrice as NSString).integerValue
            guard  price > 0 else {
                DispatchQueue.main.async {
                   SAAlertBar.show(.error, message:"Please enter valid job Budget".localizedLowercase)
                }
                return false
            } */
        
        
         self.addJOBParameters["home_location"] = self.isHomeLocationSelected
        if self.isHomeLocationSelected{
            self.addJOBParameters["lat"] = ""
            self.addJOBParameters["lng"] = ""
        }else{
            if let lat = currentUserdefault.value(forKey: KcurrentUserLocationLatitude) as? Double, let lng = currentUserdefault.value(forKey: KcurrentUserLocationLongitude) as? Double{
                self.addJOBParameters["lat"] = "\(lat)"
                self.addJOBParameters["lng"] = "\(lng)"
            }
        }
         return true
        
    }
    //MARK: - API
    func uploadPostImageAPIRequest(imageData:Data){ //0 for business logo 1 for business licence 2 for driver licence
           
           var businessLogoUploadParameters :[String:Any] = [:]
           
           businessLogoUploadParameters["page_name"] = "job"
           
           APIRequestClient.shared.uploadImage(requestType: .POST, queryString:kProviderFileUpload , parameter: businessLogoUploadParameters as [String:AnyObject], imageData:imageData ,isFileUpload : true, isHudeShow: true, success: { (responseSuccess) in
               DispatchQueue.main.async {
                   ExternalClass.HideProgress()
               }
               if let success = responseSuccess as? [String:Any],let fileInfo = success["success_data"] as? [String:Any]{
                   
                  
                    self.arrayOfImages.append(fileInfo)
                    print(self.arrayOfImages.count)
                   
                   DispatchQueue.main.async {
                    self.collectionViewImages.reloadData()
                   }
               }
           }) { (responseFail) in
                   DispatchQueue.main.async {
                       ExternalClass.HideProgress()
                   }
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
    func deleteJOBImageAPIRequest(index:Int){
        
        let objImageJSON = self.arrayOfImages[index]
        
    
                  APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kPostJOBDeleteImage , parameter: objImageJSON as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                                 if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [Any]{
                                    self.arrayOfImages.remove(at: index)
                                    DispatchQueue.main.async {
                                        print(success)
                                        self.collectionViewImages.reloadData()
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
    func callSingleProviderBookAPIRequest(){
        if let provider = self.singleProvider{
            self.addJOBParameters["provider_id"] = "\(provider.providerID)"
        }else if self.providerID.count > 0{
            self.addJOBParameters["provider_id"] = "\(self.providerID)"
        }
        
        
         APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kAddJOBSingleProviderBook , parameter: self.addJOBParameters as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
             DispatchQueue.main.async {
                   self.clearAllDataResetPage()
             }
            if let success = responseSuccess as? [String:Any],let arrayOfProvider = success["success_data"] as? [String:Any]{
                DispatchQueue.main.async {
                    if let _ = self.delegate{
                        //self.delegate!.postCreatedFromSingleProviderBook()
                    }
                    NotificationCenter.default.post(name: .jobBook, object: nil)
                    self.navigationController?.popToRootViewController(animated: false)
                }
                     
                
                 }else{
                     DispatchQueue.main.async {
                        // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                     }
                 }
             }) { (responseFail) in
                 DispatchQueue.main.async {
                                  self.clearAllDataResetPage()
                            }
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
    func    callPostJOBAPIRequest(){
        print(self.addJOBParameters)
        print(self.isForEditJOBOnWidenSearch)
//        self.addJOBParameters =
//         ["images": [["file_name": "job-1610523189-file", "file_size": "18724", "file_type": "image/jpeg", "file_path": "http://werkules.project-demo.info/storage/temp/job-1610523189-file"]], "description": "Did", "keep_post_active": "1", "title": "Test", "travel_time": "1", "home_location": true, "estimate_budget": "12", "category_id": "1"]
        
            
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:self.isForEditJOBOnWidenSearch ? kUpdateJOBWidenSearch : kAddJOB , parameter: self.addJOBParameters as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                  //self.clearAllDataResetPage()
            }
            if let success = responseSuccess as? [String:Any],let arrayOfProvider = success["success_data"] as? [Any]{
                if arrayOfProvider.count > 0{
                    if let array = arrayOfProvider as? [[String:Any]]{
                        DispatchQueue.main.async {
                            var arrayNotified : [NotifiedProviderOffer] = []
                               for  objProviderDetail in array {
                                    let objNotifiedProvider = NotifiedProviderOffer.init(providersDetail: objProviderDetail)
                                    arrayNotified.append(objNotifiedProvider)
                            }
                            
                            self.presentJOBAddedSuccessFullyAlert(arrayProvider: arrayNotified)
                            self.clearAllDataResetPage()
                        }
                    }
                   
                }else{
                    if let parameter = success["request_paramter"] as? [String:Any]{
                        DispatchQueue.main.async {
                            self.presentWideSearchAlertViewController(requestParameters:parameter )
                        }
                    }
                }
                    
               
                }else{
                    DispatchQueue.main.async {
                       // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                    }
                }
            }) { (responseFail) in
                DispatchQueue.main.async {
                                 //self.clearAllDataResetPage()
                           }
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
    func callAPIRequestforWidenSearchRequest(requestParamters:[String:Any]){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kWidenSeach , parameter: requestParamters as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                
                   if let success = responseSuccess as? [String:Any],let arrayOfProvider = success["success_data"] as? [Any]{
                            if arrayOfProvider.count > 0{
                                if let array = arrayOfProvider as? [[String:Any]]{
                                    DispatchQueue.main.async {
                                        var arrayNotified : [NotifiedProviderOffer] = []
                                           for  objProviderDetail in array {
                                                let objNotifiedProvider = NotifiedProviderOffer.init(providersDetail: objProviderDetail)
                                                arrayNotified.append(objNotifiedProvider)
                                        }
                                        
                                        self.presentJOBAddedSuccessFullyAlert(arrayProvider: arrayNotified)
                                    }
                                }
                               
                            }else{
                                if let parameter = success["request_paramter"] as? [String:Any]{
                                    DispatchQueue.main.async {
                                        self.presentWideSearchAlertViewController(requestParameters:parameter )
                                    }
                                }
                                if let sucessMessage = success["success_message"] as? [String]{
                                   DispatchQueue.main.async {
                                        if sucessMessage.count > 0{
                                            SAAlertBar.show(.error, message:"\(sucessMessage.first!)".localizedLowercase)
                                        }
                                    }
                                }
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
    func callPostJobAPI() {
           /*
        APIManager.sharedInstance.CallAPISaveUpdatePost(parameter: UserJob.Shared, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            self.btnPost.isUserInteractionEnabled = true
            
            if  isError == false{
                print(JSONDICTIONARY!)
                
                ExternalClass.HideProgress()
                
                Analytics.logEvent(NSLocalizedString("new_job_post", comment: ""), parameters: [NSLocalizedString("job_post_title", comment: ""): UserJob.Shared.jobTitle!])
                
                UserDefaults.standard.removeObject(forKey: "selectedCategories")
                
                if self.switchService.isOn == false {
                    NotificationCenter.default.post(name: Notification.Name("RefreshscreenNotification"), object: nil)
                }
                
                self.navigationController?.popToRootViewController(animated: true)
                
                self.clearModelData()
                
                let lastSelectedTabIndex = UserDefaults.standard.integer(forKey: "lastSelectedTabIndex")
                
                if self.navigationController?.parent != nil {
                    let tabbarcontroller = self.navigationController?.parent as! UITabBarController
                    tabbarcontroller.selectedIndex = lastSelectedTabIndex
                }
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })*/
    }
    
    //MARK: - GMSAutocomplete ViewController Delegate Methods
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        location =  place.coordinate
        txtFieldLocation.text = place.name
        
        UserJob.Shared.lat = String(location.latitude)
        UserJob.Shared.long =  String(location.longitude)
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}
extension PostJobVC{
    func textViewDidChange(_ textView: UITextView) {
        print(textView.text.count)
        if textView.text.count > 0{
            self.placeholderLabel.isHidden = true
        }else{
            self.placeholderLabel.isHidden = false
        }
        
    }
}
extension Date {
    
    func currentTimeMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 10)
    }
}

extension UINavigationController {
    public func hasViewController(ofKind kind: AnyClass) -> UIViewController? {
        return self.viewControllers.first(where: {$0.isKind(of: kind)})
    }
}
extension PostJobVC:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayOfImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostJOBCollectionViewCell", for: indexPath) as! PostJOBCollectionViewCell
        
        cell.buttonDelete.tag = indexPath.item
        cell.delegate = self
        if self.arrayOfImages.count > indexPath.item{
            let objDictImage = self.arrayOfImages[indexPath.item]
            
            if let objFile = objDictImage["file_path"] as? String, let fileURL = URL.init(string: "\(objFile)"){
                cell.imgView.sd_setImage(with: fileURL, placeholderImage: UIImage.init(named: "Photo"), options: .refreshCached, context: nil)
            }else{
                cell.imgView.image =  UIImage.init(named: "Photo")
            }
            cell.imgView.contentMode = .scaleAspectFill
            cell.layoutIfNeeded()
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120.0, height:70.0)
       }
}
extension PostJobVC:PostJOBDelegate{
    func buttonDeleteSelector(index:Int){
        if self.arrayOfImages.count > index{
            
            let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete image?", preferredStyle: .alert)
            let cancelAction =  UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
           
            let okayAction =  UIAlertAction.init(title: "Delete", style: .default){ _ in
                self.deleteJOBImageAPIRequest(index: index)
            }
            okayAction.setValue(UIColor.red, forKey: "titleTextColor")

            alert.addAction(okayAction)
            alert.view.tintColor = UIColor.init(hex: "#38B5A3")
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }
}
extension PostJobVC {
    
    // Delegate function has been updated
    func fileOutput( outputFileURL: URL, thumbnail : UIImage) {
        guard let data = NSData(contentsOf: outputFileURL as URL) else {
            return
        }

        print("File size before compression: \(Double(data.length / 1048576)) mb")
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
        compressVideo(inputURL: outputFileURL as URL, outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }

            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
                
                print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                
                let dataDict = NSMutableDictionary.init()
                
                dataDict.setObject(compressedData as Data, forKey: "data" as NSCopying)
                dataDict.setObject(thumbnail.pngData()!, forKey: "thumbnail" as NSCopying)
                dataDict.setObject("Video", forKey: "type" as NSCopying)
                
                self.selectedImagesArray.add(dataDict)
                DispatchQueue.main.async {
                    self.setImages()
                }
                
                
            case .failed:
                break
            case .cancelled:
                break
            }
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset640x480) else {
            handler(nil)

            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
}
extension PostJobVC:UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0{
             return self.arrayOfTravelTime[row].name
        }else if pickerView.tag == 1{
             return self.arrayOfKeepPostActive[row].name
        }else if pickerView.tag == 2{
             return self.arrayOfCategory[row].name
        }else{
            return nil
        }
          
       }
       func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
           return UIScreen.main.bounds.width
       }
       func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
           return 30.0
       }
       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0{
             return self.arrayOfTravelTime.count
        }else if pickerView.tag == 1{
             return self.arrayOfKeepPostActive.count
        }else if pickerView.tag == 2{
             return self.arrayOfCategory.count
        }else{
          return 0
        }
          
          
       }
       func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1
       }
       func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0{
            self.currentTravelTime = self.arrayOfTravelTime[row].name
        }else if pickerView.tag == 1{
            self.currentKeepPostActive = self.arrayOfKeepPostActive[row].name
        }else if pickerView.tag == 2{
            self.currentbusinessCategory = self.arrayOfCategory[row].name
        }
           
       }
}
protocol PostJOBDelegate {
    func buttonDeleteSelector(index:Int)
}
class PostJOBCollectionViewCell: UICollectionViewCell {

    var delegate:PostJOBDelegate?
    @IBOutlet weak var buttonDelete:UIButton!
    @IBOutlet weak var imgView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgView.clipsToBounds = true
        self.imgView.contentMode = .scaleAspectFill
        self.imgView.layer.borderColor = UIColor.lightGray.cgColor
        self.imgView.layer.borderWidth = 1.0
    }
    //MARK: SELECTOR METHODS
    @IBAction func buttonDeleteSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonDeleteSelector(index: sender.tag)
        }
    }
}
extension PostJobVC:SearchViewDelegate{
    func didSelectValuesFromSearchView(values: [Any],searchType:SearchType) {
        DispatchQueue.main.async {
            if searchType == .TravelTime{
                if let arrayOfTravelTimeValue = values as? [GeneralList]{
                    if arrayOfTravelTimeValue.count > 0{
                        self.currentTravelTime = arrayOfTravelTimeValue.first!.name
                        self.configureSelectedBusinessTravelTime()
                    }
                }
            }
        }
      
    }
}
extension PostJobVC:AddPostAlertDelegate{
   
    
    func widenSearchSelector(requestParameters:[String:Any]) {
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                if let jobId = requestParameters["job_id"]{
                    self.addJOBParameters["job_id"] = "\(jobId)"
                }
                    self.isForEditJOBOnWidenSearch = true
                   self.view.endEditing(true)
                   self.txtTravelTime.becomeFirstResponder()
                   self.viewMoreoptions.fadeOut() //hide
                   self.viewMoreImageoptions.fadeIn() //show
                   self.viewMoreKeepPostActiveoptions.fadeIn() //show
                   self.viewMoreTravelTimeoptions.fadeIn() //show
                   self.viewMoreCategoryoptions.fadeIn() //show
                   
                   do{
                       self.sizeHeaderFit()
                   }
               }
        }
        //self.callAPIRequestforWidenSearchRequest(requestParamters: requestParameters)
    }
    func goToHomeSelector() {
        self.navigationController?.popViewController(animated: true)
        /*
        if let objTabView = self.navigationController?.tabBarController{
                       if let objHomeNavigation = objTabView.viewControllers?.first as? UINavigationController,let objHome = objHomeNavigation.viewControllers.first as? HomeVC{
                           objHome.arrayOfProvidersNotified = []
                           objTabView.selectedIndex = 0
                       }
            }*/
    }
    func buttonOkaySelector(arrayOfProvider: [NotifiedProviderOffer]) {
        self.navigationController?.popViewController(animated: true)
        /*
        if let objTabView = self.navigationController?.tabBarController{
                   if let objHomeNavigation = objTabView.viewControllers?.first as? UINavigationController,let objHome = objHomeNavigation.viewControllers.first as? HomeVC{
                       objHome.arrayOfProvidersNotified = arrayOfProvider
                       objTabView.selectedIndex = 0
                   }
        }*/
    }
}
extension PostJobVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.dismiss(animated: true, completion: nil)
        let resizedImage = self.resize(image)
        if let imageData = resizedImage.jpegData(compressionQuality: 0.5){
            self.uploadPostImageAPIRequest(imageData: imageData)
        }
        
        
                   //self.btnUserProfilePic.setBackgroundImage(UIImage.init(data: resizedImage), for: .normal)
                   //self.customerProfileImageData = resizedImage
    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.imageForCrop = image
            
        }
        
        self.dismiss(animated: false) { [unowned self] in
                                  self.openEditor(nil, pickingViewTag: picker.view.tag)
                              }
                  
         //self.dismiss(animated:true, completion: nil)
    }
    func openEditor(_ sender: UIBarButtonItem?, pickingViewTag: Int) {
        guard let image = self.imageForCrop else {
            return
        }
        
        let cropViewController = CropViewController(image: image)
        cropViewController.setAspectRatioPreset(.presetSquare, animated: true)
        cropViewController.delegate = self
        cropViewController.aspectRatioPreset = .preset16x9
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.cropView.cropBoxResizeEnabled = false
        self.present(cropViewController, animated: true, completion: nil)
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
}

extension UIView {

func fadeIn(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in }) {
    self.alpha = 0.0

    UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
        self.isHidden = false
        self.alpha = 1.0
    }, completion: completion)
}

func fadeOut(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in }) {
    self.alpha = 1.0

    UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
        self.alpha = 0.0
    }) { (completed) in
        self.isHidden = true
        completion(true)
    }
}
}

