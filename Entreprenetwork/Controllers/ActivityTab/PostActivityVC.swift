//
//  PostActivityVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 22/01/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation
import Gallery
import Photos
import Fusuma
import YPImagePicker
import Firebase

class PostActivityVC: UIViewController,UITextViewDelegate,CLLocationManagerDelegate,GalleryControllerDelegate,FusumaDelegate {
    
    @IBOutlet weak var btnUserProfilePic: UIButton!
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var scrollViewPhotos: UIScrollView!
    @IBOutlet weak var viewTextView: UIView!
    @IBOutlet weak var textViewShare: UITextView!
    @IBOutlet weak var btnPost: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btnClose1: UIButton!
    @IBOutlet weak var btnClose2: UIButton!
    @IBOutlet weak var btnClose3: UIButton!
    @IBOutlet weak var btnClose4: UIButton!
    @IBOutlet weak var btnGallery: UIButton!
    
    var firstImageSet = Bool()
    var secondImageSet = Bool()
    var thirdImageSet = Bool()
    var fourthImageSet = Bool()
    
    var isJobEditing = Bool()
    var isFromActivity = Bool()
    var jobDictModel = UserJobListModel()
    var dictJobModel = NSDictionary()
    
    var locationManager: CLLocationManager = CLLocationManager()
    @IBOutlet weak var scrollHeightConstraint: NSLayoutConstraint!
    
    // MARK: - UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if CurrentUserModel.Shared.vProfilepic?.isEmpty == false {
            var profilePath = CurrentUserModel.Shared.vProfilepic!
            profilePath = profilePath.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
            
            let url = URL(string: profilePath)
            
            btnUserProfilePic.sd_setImage(with: url, for:UIControl.State.normal, placeholderImage: UIImage(named:"user_placeholder"), options: []) { (image,
                error, cache, url) in
            }
        }
        
        let username = CurrentUserModel.Shared.firstName! + " " + CurrentUserModel.Shared.lastName!
        btnUserName.setTitle(username, for: .normal)
        
        textViewShare.text = "What would you like to share?"
        
        btn1.imageView?.contentMode = .scaleAspectFill
        btn1.contentHorizontalAlignment = .fill
        btn1.contentVerticalAlignment = .fill
        
        btn2.imageView?.contentMode = .scaleAspectFill
        btn2.contentHorizontalAlignment = .fill
        btn2.contentVerticalAlignment = .fill
        
        btn3.imageView?.contentMode = .scaleAspectFill
        btn3.contentHorizontalAlignment = .fill
        btn3.contentVerticalAlignment = .fill
        
        btn4.imageView?.contentMode = .scaleAspectFill
        btn4.contentHorizontalAlignment = .fill
        btn4.contentVerticalAlignment = .fill
        
        self.mylocation()
        
        btnPost.setTitle("Post", for: .normal)
        
        if isJobEditing == true {
            
            btnPost.setTitle("Update", for: .normal)
            
            if isFromActivity == true {
                
                UserJob.Shared.jobID = String(dictJobModel["id"] as! Int)
                let titleText = (dictJobModel["title"] as! String)
                if titleText == "" {
                    textViewShare.text = "What would you like to share?"
                }
                else {
                    textViewShare.text = titleText
                }
                
                if (dictJobModel["file1"] as! String) != "" {
                    var url = (dictJobModel["file1"] as! String)
                    url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                    
                    btn1.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                        
                    }
                    btn1.isHidden = false
                    btnClose1.isHidden = false
                    firstImageSet = true
                }
                if (dictJobModel["file2"] as! String) != "" {
                    
                    var url = (dictJobModel["file2"] as! String)
                    url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                    btn2.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                    }
                    btn2.isHidden = false
                    btnClose2.isHidden = false
                    secondImageSet = true
                }
                if (dictJobModel["file3"] as! String) != "" {
                    var url = (dictJobModel["file3"] as! String)
                    url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                    btn3.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                    }
                    btn3.isHidden = false
                    btnClose3.isHidden = false
                    thirdImageSet = true
                }
                if (dictJobModel["file4"] as! String) != ""  {
                    var url = (dictJobModel["file4"] as! String)
                    url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                    
                    btn4.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                    }
                    btn4.isHidden = false
                    btnClose4.isHidden = false
                    fourthImageSet = true
                }
            }
            else {
                
                UserJob.Shared.jobID = String(jobDictModel.jobId!)
                let titleText = jobDictModel.jobTitle
                if titleText == "" {
                    textViewShare.text = "What would you like to share?"
                }
                else {
                    textViewShare.text = titleText
                }
                
                if jobDictModel.jobImg1Path != "" {
                    var url = jobDictModel.jobImg1Path!
                    url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                    
                    btn1.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                        
                    }
                    btn1.isHidden = false
                    btnClose1.isHidden = false
                    firstImageSet = true
                }
                if jobDictModel.jobImg2Path != "" {
                    
                    var url = jobDictModel.jobImg2Path!
                    url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                    btn2.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                    }
                    btn2.isHidden = false
                    btnClose2.isHidden = false
                    secondImageSet = true
                }
                if jobDictModel.jobImg3Path != "" {
                    var url = jobDictModel.jobImg3Path!
                    url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                    btn3.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                    }
                    btn3.isHidden = false
                    btnClose3.isHidden = false
                    thirdImageSet = true
                }
                if jobDictModel.jobImg4Path != ""  {
                    var url = jobDictModel.jobImg4Path!
                    url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
                    
                    btn4.sd_setImage(with: URL(string: url), for:UIControl.State.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                        error, cache, url) in
                    }
                    btn4.isHidden = false
                    btnClose4.isHidden = false
                    fourthImageSet = true
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           self.locationManager.stopUpdatingLocation()
          
       }
    // MARK: - UITexyView Delegate Method
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "What would you like to share?" {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "What would you like to share?"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            return true
        }
        if textView == textViewShare {
            
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            let numberOfChars = newText.count
            return numberOfChars < 100
        }
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnaddPhotosClicked(_ sender: UIButton) {
        
        var config = YPImagePickerConfiguration()
        config.showsPhotoFilters = false
        config.library.maxNumberOfItems = 4
        config.isScrollToChangeModesEnabled = false
        config.startOnScreen = .library
        config.library.defaultMultipleSelection = false
        let picker = YPImagePicker(configuration: config)
        present(picker, animated: true, completion: nil)
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if cancelled {
                print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
            }
            
            for (index,item) in items.enumerated() {
                
                switch item {
                case .photo(let photo):
                    
                    let selectedImage = photo.image
                    let resizedImage = self.resize(selectedImage)
                    
                    switch index {
                    case 0:
                        self.firstImageSet = true
                        self.btn1.setImage(resizedImage, for: .normal) // you can get image like this way
                        self.btn1.isHidden = false
                        self.btnClose1.isHidden = false
                    case 1:
                        self.secondImageSet = true
                        self.btn2.setImage(resizedImage, for: .normal)
                        self.btn2.isHidden = false
                        self.btnClose2.isHidden = false
                    case 2:
                        self.thirdImageSet = true
                        self.btn3.setImage(resizedImage, for: .normal)
                        self.btn3.isHidden = false
                        self.btnClose3.isHidden = false
                    case 3:
                        self.fourthImageSet = true
                        self.btn4.setImage(resizedImage, for: .normal)
                        self.btn4.isHidden = false
                        self.btnClose4.isHidden = false
                    default:
                        print("")
                    }
                default:
                    print("")
                }
                picker.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func btnRemoveImagesClicked(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            btn1.isHidden = true
            btnClose1.isHidden = true
            firstImageSet = false
        case 2:
            btn2.isHidden = true
            btnClose2.isHidden = true
            secondImageSet = false
        case 3:
            btn3.isHidden = true
            btnClose3.isHidden = true
            thirdImageSet = false
        case 4:
            btn4.isHidden = true
            btnClose4.isHidden = true
            fourthImageSet = false
        default:
            print("")
        }
    }
    
    @IBAction func btnPostClicked(_ sender: UIButton) {
        
        if isDataValid() == false {
            return
        }
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
        
        UserJob.Shared.userId = UserSettings.userID
        UserJob.Shared.fairMarketValue = "0"
        if textViewShare.text == "What would you like to share?" {
            UserJob.Shared.jobTitle = ""
        }
        else {
            UserJob.Shared.jobTitle = textViewShare.text!
        }
        UserJob.Shared.isActivity = "1"
        
        let timestamp = String(Date().currentTimeMillis())
        UserJob.Shared.vTimestamp = timestamp + "_" + UserJob.Shared.userId!
        
        sender.isUserInteractionEnabled = false
        
        callPostJobAPI()
    }
    
    //MARK: - Fusuma Delegate Methods
    
    // Return the image which is selected from camera roll or is taken via the camera.
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        
        print("Image selected")
    }
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(image: UIImage, source: FusumaMode) {
        
        print("Called just after FusumaViewController is dismissed.")
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        print("Called just after a video has been selected.")
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
    }
    
    // Return selected images when you allow to select multiple photos.
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
    }
    
    // Return an image and the detailed information.
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode, metaData: ImageMetadata) {
        
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode, metaData: [ImageMetadata]) {
        for (index,_) in images.enumerated() {
            
            let selectedImage = images[index]
            let _ = self.resize(selectedImage)
            
            switch index {
            case 0:
                self.firstImageSet = true
                self.btn1.setImage(selectedImage, for: .normal) // you can get image like this way
                self.btn1.isHidden = false
                self.btnClose1.isHidden = false
            case 1:
                self.secondImageSet = true
                self.btn2.setImage(selectedImage, for: .normal)
                self.btn2.isHidden = false
                self.btnClose2.isHidden = false
            case 2:
                self.thirdImageSet = true
                self.btn3.setImage(selectedImage, for: .normal)
                self.btn3.isHidden = false
                self.btnClose3.isHidden = false
            case 3:
                self.fourthImageSet = true
                self.btn4.setImage(selectedImage, for: .normal)
                self.btn4.isHidden = false
                self.btnClose4.isHidden = false
            default:
                print("")
            }
        }
    }
    
    //MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latestLocation: AnyObject = locations[locations.count - 1]
        let mystartLocation = latestLocation as! CLLocation;
        
        UserJob.Shared.lat = String(mystartLocation.coordinate.latitude)
        UserJob.Shared.long =  String(mystartLocation.coordinate.longitude)
        
        getAddressFromLatLon(pdblLatitude: UserJob.Shared.lat!, withLongitude: UserJob.Shared.long!)
        locationManager.stopUpdatingLocation()
    }
    
    //MARK: - Gallery Controller Delegate Methods
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        print("")
        
        let Images = images as NSArray
        
        for (index,_) in Images.enumerated() {
            let selectedImage = Images[index] as! Image
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            requestOptions.isNetworkAccessAllowed = true
            // this one is key
            requestOptions.isSynchronous = true
            
            PHImageManager.default().requestImage( for: selectedImage.asset , targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestOptions, resultHandler: { (pickedImage, info) in
                
                let resizedImage = self.resize(pickedImage!)
                
                switch index {
                case 0:
                    self.firstImageSet = true
                    self.btn1.setImage(resizedImage, for: .normal) // you can get image like this way
                    self.btn1.isHidden = false
                    self.btnClose1.isHidden = false
                case 1:
                    self.secondImageSet = true
                    self.btn2.setImage(resizedImage, for: .normal)
                    self.btn2.isHidden = false
                    self.btnClose2.isHidden = false
                case 2:
                    self.thirdImageSet = true
                    self.btn3.setImage(resizedImage, for: .normal)
                    self.btn3.isHidden = false
                    self.btnClose3.isHidden = false
                case 3:
                    self.fourthImageSet = true
                    self.btn4.setImage(resizedImage, for: .normal)
                    self.btn4.isHidden = false
                    self.btnClose4.isHidden = false
                default:
                    print("")
                }
            })
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        print("")
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        print("")
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        print("")
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - User Defined Methods
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            scrollHeightConstraint.constant = 530 - 180
        }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        scrollHeightConstraint.constant = 530
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
                        addressString = addressString + pm.locality! //+ ", "
                    }
                    //                    if pm.country != nil {
                    //                        addressString = addressString + pm.country! + ", "
                    //                    }
                    //                    if pm.postalCode != nil {
                    //                        addressString = addressString + pm.postalCode! + " "
                    //                    }
                    
                    UserJob.Shared.jobAddress = addressString
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
    
    func isDataValid() -> Bool {
        
        if textViewShare.text?.isEmpty == true || textViewShare.text == "What would you like to share?" && firstImageSet == false && secondImageSet == false && thirdImageSet == false && fourthImageSet == false {
            
            SAAlertBar.show(.error, message:"Invalid data to post".localizedLowercase)
            return false
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
        UserJob.Shared.jobDescription = ""
        UserJob.Shared.img1 = nil
        UserJob.Shared.img2 = nil
        UserJob.Shared.img3 = nil
        UserJob.Shared.img4 = nil
        UserJob.Shared.lat = ""
        UserJob.Shared.long = ""
        UserJob.Shared.isActivity = "0"
        
        btn1.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        btn2.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        btn3.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        btn4.setImage(UIImage(named: "Icon_Add_Picture"), for: .normal)
        textViewShare.text = ""
    }
    
    //MARK: - API
    
    func callPostJobAPI() {
        
        APIManager.sharedInstance.CallAPISaveUpdatePost(parameter: UserJob.Shared, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            
            self.btnPost.isUserInteractionEnabled = true
            if  isError == false{
                
                ExternalClass.HideProgress()
                
                Analytics.logEvent(NSLocalizedString("new_activity_post", comment: ""), parameters: [NSLocalizedString("activity_post_title", comment: ""): UserJob.Shared.jobTitle!])
                
                UserDefaults.standard.set(true, forKey: "ActivityAdded")
                
                self.clearModelData()
                
                self.dismiss(animated: true, completion: nil)
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
}
