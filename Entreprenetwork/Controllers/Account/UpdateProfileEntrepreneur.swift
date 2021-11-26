//
//  UpdateProfileEntrepreneur.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 21/08/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import AVKit
import SKCountryPicker
import GooglePlaces
import TaggerKit
import SimpleImageViewer
import Fusuma
import Firebase
import YPImagePicker

class UpdateProfileEntrepreneur: UIViewController,GMSAutocompleteViewControllerDelegate,UITextViewDelegate,TKCollectionViewDelegate,FusumaDelegate {
    
    @IBOutlet weak var scrlViewDesc: UIScrollView!
    @IBOutlet weak var btnCoverPic: UIButton!
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var txtFldFirstName: UITextField!
    @IBOutlet weak var txtFldLastName: UITextField!
    @IBOutlet weak var txtFldCompanyName: UITextField!
    @IBOutlet weak var txtFldEmail: UITextField!
    @IBOutlet weak var txtfldPhoneNumber: UITextField!
    @IBOutlet weak var txtViewAddress: UITextView!
    @IBOutlet weak var txtFldInsurance: UITextField!
    @IBOutlet weak var txtFldTagline: UITextField!
    @IBOutlet weak var txtViewDescription: UITextView!
    @IBOutlet weak var btnCountryCode: UIButton!
    
    @IBOutlet weak var viewTagContainer: UIView!
    @IBOutlet weak var view2HeightConstraint: NSLayoutConstraint!
    
    var mediaArray = NSMutableArray()
    var mediaDataArray = NSMutableArray ()
    var tagCollection = TKCollectionView()
    var myCatArr = NSArray()
    var arrCategories = NSMutableArray()
    
    
    var isProfilePicChanged = Bool()
    var deleteFlag = String()
    
    
    //MARK: - UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        // Do any additional setup after loading the view.
        
        GMSPlacesClient.provideAPIKey("AIzaSyANGw649sAMH-QJ0qXIjSdWOQfdFDrvz4M")
        
        mediaArray = NSMutableArray.init()
        mediaDataArray = NSMutableArray.init()
        
        guard let country = CountryManager.shared.currentCountry else {
            self.btnCountryCode.setTitle("Pick Country", for: .normal)
            return
        }
        
        btnCountryCode.setTitle(country.dialingCode, for: .normal)
        btnCountryCode.clipsToBounds = true
        
        add(tagCollection, toView: viewTagContainer)
        
        tagCollection.delegate = self
        tagCollection.customBackgroundColor = UIColor.init(hex: "ebf6f8")
        tagCollection.customCornerRadius = 5.0
        tagCollection.customFont = UIFont.init(name: "Avenir Medium", size: 12.0)!
        tagCollection.action     = .removeTag
        
        view2HeightConstraint.constant = 90
        
        print(CurrentUserModel.Shared.mediaArray)
        callAPIToGetCategories()*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
        self.deleteFlag = "0"
        
        if isKeyPresentInUserDefaults(key: "isfromCategories") {
            
            let isFromCategories = UserDefaults.standard.value(forKey: "isfromCategories") as! Bool
            if isFromCategories == true {
                
                UserDefaults.standard.set(false, forKey: "isfromCategories")
                myCatArr = UserDefaults.standard.value(forKey: "selectedCategories") as! NSArray
                print(myCatArr)
                
                tagCollection.tags.removeAll()
                for item in myCatArr {
                    let dict = item as! NSDictionary
                    let name = dict["name"] as! String
                    tagCollection.tags.append(name)
                    tagCollection.tagsCollectionView.reloadData()
                    
                    if myCatArr.count <= 2 {
                        view2HeightConstraint.constant = 100
                    }
                    else {
                        view2HeightConstraint.constant = 135
                    }
                }
            }
        }*/
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
        
        if selectedCategories.count <= 2 {
            view2HeightConstraint.constant = 90
        }
        else {
            view2HeightConstraint.constant = 135
        }
        
        UserDefaults.standard.set(selectedCategories, forKey: "selectedCategories")
    }
    
    //MARK: - Actions
    
    @IBAction func btnCoverPicClicked(_ sender: UIButton) {
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.modalPresentationStyle = .fullScreen
        fusuma.availableModes = [.library, .camera] // Add .video capturing mode to the default .library and .camera modes
        fusuma.cropHeightRatio = 0.4 // Height-to-width ratio. The default value is 1, which means a squared-size photo.
        fusuma.allowMultipleSelection = false // You can select multiple photos from the camera roll. The default value is false.
        //fusuma.photoSelectionLimit = 1
        self.present(fusuma, animated: true, completion: nil)
    }
    
    @IBAction func btnProfilePicClicked(_ sender: UIButton) {
        
        var config = YPImagePickerConfiguration()
        config.showsPhotoFilters = false
        config.library.maxNumberOfItems = 1
        config.isScrollToChangeModesEnabled = false
        config.startOnScreen = .library
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                let aImg = photo.image
                
                let resizedImage = self.resize(aImg, size: 450)
                
                self.btnProfilePic.setImage(resizedImage, for: .normal)
                self.isProfilePicChanged = true
                UserRegister.Shared.vProfilepic = resizedImage
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func btnFinishClicked(_ sender: UIButton) {
        
        if isDataValidOnStep2() {
            
            var categoryIDS = String()
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
            UserRegister.Shared.catId = categoryIDS
            callUpdateEnterpreneurAPI()
        }
        
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCountryCodeClicked(_ sender: UIButton) {
        
        txtFldFirstName.resignFirstResponder()
        txtFldLastName.resignFirstResponder()
        txtfldPhoneNumber.resignFirstResponder()
        txtFldEmail.resignFirstResponder()
        txtFldCompanyName.resignFirstResponder()
        
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in
            
            guard let self = self else { return }
            
            self.btnCountryCode.setTitle(country.dialingCode, for: .normal)
        }
        // can customize the countryPicker here e.g font and color
        countryController.detailColor = UIColor.red
    }
    
    @IBAction func btnReviewsClicked(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "reviewSegue", sender: self)
    }
    
    @IBAction func btnChangePasswordClicked(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "changePasswordSegue", sender: self)
    }
    
    @IBAction func btnDeleteAccountClicked(_ sender: UIButton) {
        
        let alert = UIAlertController(title: AppName, message: "Are you sure you want to delete this account?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
            
            self.callDeleteAccountAPI()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Fusuma Delegate Methods
    
    // Return the image which is selected from camera roll or is taken via the camera.
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        
        let orientationFixedImage = image.fixOrientation()
        let resizedImage = self.resizeCoverPic(orientationFixedImage!, size: Int(self.view.frame.size.width * 2))
        
        print("Image selected")
        btnCoverPic.setImage(resizedImage, for: .normal)
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
        
        let orientationFixedImage = image.fixOrientation()
        let resizedImage = self.resizeCoverPic(orientationFixedImage!, size: Int(self.view.frame.size.width * 2))
        
        btnCoverPic.setImage(resizedImage, for: .normal)
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode, metaData: [ImageMetadata]) {
    }
    
    //MARK: - User Defined Methods
    
    func resize(_ image: UIImage , size : Int) -> UIImage {
        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxHeight: Float = 900.0
        let maxWidth: Float = 900.0
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
    
    func resizeCoverPic(_ image: UIImage , size : Int) -> UIImage {
        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxWidth: Float = Float(size)
        let maxHeight: Float = Float(size) * 0.4
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 1.0
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
    
    func setupView() {
        
        // update categories
        let catIDs = CurrentUserModel.Shared.catId!
        if catIDs != "" {
            let arrCat = catIDs.components(separatedBy: ",") as NSArray
            
            let mutArrCats = NSMutableArray.init()
            
            if arrCat.count == 1 {
                
                let catDict = getDictFromIDString(id: arrCat.object(at: 0) as! String)
                mutArrCats.add(catDict)
            }
            else {
                for item in arrCat {
                    let catDict = getDictFromIDString(id : item as! String)
                    mutArrCats.add(catDict)
                }
            }
            myCatArr = NSArray(array: mutArrCats)
            print(myCatArr)
            UserDefaults.standard.set(myCatArr, forKey: "selectedCategories")
            
            tagCollection.tags.removeAll()
            if myCatArr.count > 0 {
                
                for item in myCatArr {
                    let dict = item as! NSDictionary
                    let name = dict["name"] as! String
                    tagCollection.tags.append(name)
                    
                    if myCatArr.count <= 2 {
                        view2HeightConstraint.constant = 90
                    }
                    else {
                        view2HeightConstraint.constant = 135
                    }
                }
                tagCollection.tagsCollectionView.reloadData()
            }
        }
        
        var profilePath = CurrentUserModel.Shared.vProfilepic!
        
        profilePath = profilePath.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
        
        let url = URL(string: profilePath)
        
        DispatchQueue.main.async {
            self.btnProfilePic.sd_setImage(with: url, for:UIControl.State.normal, placeholderImage: UIImage(named:"user_placeholder"), options: []) { (image,
                error, cache, url) in
            }
        }
        
        var CoverPath = CurrentUserModel.Shared.vCoverPic!
        CoverPath = CoverPath.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
        
        let urlCover = URL(string: CoverPath)
        
        DispatchQueue.main.async {
            self.btnCoverPic.sd_setImage(with: urlCover, for:UIControl.State.normal, placeholderImage: UIImage(named:"user_placeholder"), options: []) { (image,
                error, cache, url) in
            }
        }
        
        txtFldFirstName.text = CurrentUserModel.Shared.firstName
        txtFldLastName.text = CurrentUserModel.Shared.lastName
        if CurrentUserModel.Shared.phone?.isEmpty == false {
            let phone = CurrentUserModel.Shared.phone!
            let number = String(phone.suffix(10))
            txtfldPhoneNumber.text = number
            let code = phone.replacingOccurrences(of: number, with: "")
            btnCountryCode.setTitle(code, for: .normal)
        }
        
        txtFldEmail.text = CurrentUserModel.Shared.email
        txtFldCompanyName.text = CurrentUserModel.Shared.companyName
        txtFldTagline.text = CurrentUserModel.Shared.tagline
        txtFldInsurance.text = CurrentUserModel.Shared.insurance
        txtViewAddress.text = CurrentUserModel.Shared.companyAddress
        txtViewDescription.text = CurrentUserModel.Shared.companyDescription
    }
    
    func getDictFromIDString(id : String) -> NSDictionary {
        
        let tempDict = NSDictionary()
        for item in self.arrCategories {
            let dict = item as! NSDictionary
            let catId = dict["id"] as! Int
            let strCatId = "\(catId)"
            
            if strCatId == id {
                return dict
            }
        }
        return tempDict
    }
    
    func clearModelData() {
        
        UserRegister.Shared.deviceToken = ""
        UserRegister.Shared.vProfilepic = nil
        UserRegister.Shared.vfileKey = ""
        UserRegister.Shared.vchunkedMode = ""
        UserRegister.Shared.vmimeType = ""
        UserRegister.Shared.vTimestamp = ""
        UserRegister.Shared.userType = ""
        
        UserRegister.Shared.firstName = ""
        UserRegister.Shared.lastName = ""
        UserRegister.Shared.companyName = ""
        
        if UserSettings.isUserLogin == true {
            UserRegister.Shared.userId = UserSettings.userID
        }
        else {
            UserRegister.Shared.userId = ""
        }
        UserRegister.Shared.phone = ""
        UserRegister.Shared.email = ""
        UserRegister.Shared.password = ""
        UserRegister.Shared.EIN = ""
        UserRegister.Shared.companyAddress = ""
        UserRegister.Shared.insurance = ""
        
        UserRegister.Shared.tagline = ""
        UserRegister.Shared.companyDescription = ""
        UserRegister.Shared.mediaArray = NSMutableArray.init()
        
        UserSettings.isUserLogin = false
        UserSettings.PasswordText = ""
        UserDefaults.standard.set("0", forKey: "userID")
        UserSettings.userID = "0"
        
        
        CurrentUserModel.Shared.deviceToken = ""
        CurrentUserModel.Shared.vProfilepic = nil
        CurrentUserModel.Shared.vfileKey = ""
        CurrentUserModel.Shared.vchunkedMode = ""
        CurrentUserModel.Shared.vmimeType = ""
        CurrentUserModel.Shared.vTimestamp = ""
        CurrentUserModel.Shared.userType = ""
        
        CurrentUserModel.Shared.firstName = ""
        CurrentUserModel.Shared.lastName = ""
        CurrentUserModel.Shared.companyName = ""
        
        if UserSettings.isUserLogin == true {
            CurrentUserModel.Shared.userId = UserSettings.userID
        }
        else {
            CurrentUserModel.Shared.userId = ""
        }
        CurrentUserModel.Shared.phone = ""
        CurrentUserModel.Shared.email = ""
        CurrentUserModel.Shared.EIN = ""
        CurrentUserModel.Shared.companyAddress = ""
        CurrentUserModel.Shared.insurance = ""
        
        CurrentUserModel.Shared.tagline = ""
        CurrentUserModel.Shared.companyDescription = ""
        CurrentUserModel.Shared.mediaArray = NSMutableArray.init()
        
        
        NotificationCenter.default.post(name: Notification.Name("UserSignOutNotification"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("UserSignInOutNotification"), object: nil)
    }
    
    // MARK: - UITextView Delegate Method
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == txtViewAddress {
            
            let gmsAutoCompleteViewController = GMSAutocompleteViewController()
            gmsAutoCompleteViewController.delegate = self
            
            present(gmsAutoCompleteViewController, animated: true) {
            }
            txtViewAddress.resignFirstResponder()
        }
        
        return true
    }
    
    
    //MARK:- GMSAutocomplete ViewController Delegate Methods
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        txtViewAddress.text = (place.formattedAddress!)
        dismiss(animated: true, completion: nil)
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func isDataValidOnStep1() -> Bool {
        
        if (txtFldFirstName.text?.isEmpty)!{
            SAAlertBar.show(.error, message:"Please enter your first name".localizedLowercase)
            return false
        }
        
        if (txtFldLastName.text?.isEmpty)!{
            SAAlertBar.show(.error, message:"Please enter last name".localizedLowercase)
            return false
        }
        
        if (txtFldCompanyName.text?.isEmpty)!{
            SAAlertBar.show(.error, message:"Please enter company name".localizedLowercase)
            return false
        }
        
        if (txtFldInsurance.text?.isEmpty)!{
            SAAlertBar.show(.error, message:"Please enter Insurance".localizedLowercase)
            return false
        }
        return true
    }
    
    func isDataValidOnStep2() -> Bool {
        
        return true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z]+([._%+-]{1}[A-Z0-9a-z]+)*@[A-Za-z0-9]+\\.([A-Za-z])*([A-Za-z0-9]+\\.[A-Za-z]{2,4})*"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    // MARK: - API
    
    func callAPIToGetCategories() {
        
        APIManager.sharedInstance.CallAPIPost(url: Url_Categories, parameter: nil, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                self.arrCategories = NSMutableArray.init()
                self.arrCategories = (dataDict["data"] as! NSArray).mutableCopy() as! NSMutableArray
                
                self.setupView()
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    
    func callDeleteAccountAPI() {
        
        let dict = [
            APIManager.Parameter.userID : UserSettings.userID
        ]
        
        APIManager.sharedInstance.CallAPIPost(url: Url_deleteUser, parameter: dict, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                SAAlertBar.show(.success, message:dataDict["message"] as! String)
                
                self.clearModelData()
                UserRegister.Shared.email = ""
                UserSettings.emailText = ""
                
                self.navigationController?.popToRootViewController(animated: true)
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func callUpdateEnterpreneurAPI() {
        
        var deviceTokenNew = String()
        if isKeyPresentInUserDefaults(key: "fcmToken") {
            deviceTokenNew = UserDefaults.standard.object(forKey: "fcmToken") as! String
        }
        else{
            deviceTokenNew = "Sujal"
        }
        
        let userID = UserSettings.userID//UserDefaults.standard.value(forKey: "userID") as! String
        
        UserRegister.Shared.deviceToken = deviceTokenNew
        
        let timestamp = String(Date().currentTimeMillis())
        
        if self.isProfilePicChanged == true {
            UserRegister.Shared.vProfilepic = self.btnProfilePic.image(for: .normal)
        }
        UserRegister.Shared.vCoverpic = self.btnCoverPic.image(for: .normal)
        UserRegister.Shared.vfileKey = "file"
        UserRegister.Shared.vchunkedMode = "false"
        UserRegister.Shared.vmimeType = "image/png"
        // UserRegister.Shared.vTimestamp = "profile.png"
        
        UserRegister.Shared.vTimestamp = timestamp + "_" + (userID)
        
        UserRegister.Shared.userType = "entrepreneur"
        
        UserRegister.Shared.userId = userID
        UserRegister.Shared.firstName = txtFldFirstName.text!
        UserRegister.Shared.lastName = txtFldLastName.text!
        UserRegister.Shared.companyName = txtFldCompanyName.text!
        if txtfldPhoneNumber.text?.isEmpty == false {
            UserRegister.Shared.phone = btnCountryCode.title(for: .normal)! + txtfldPhoneNumber.text!
        }
        else {
            UserRegister.Shared.phone = ""
        }
        UserRegister.Shared.email = txtFldEmail.text!.lowercased()
        UserRegister.Shared.companyAddress = txtViewAddress.text!
        UserRegister.Shared.insurance = txtFldInsurance.text!
        
        UserRegister.Shared.tagline = txtFldTagline.text!
        UserRegister.Shared.companyDescription = txtViewDescription.text!
        if self.deleteFlag == "1" {
            UserRegister.Shared.mediaArray = self.mediaDataArray//self.mediaArray
        }
        else {
            UserRegister.Shared.mediaArray = NSMutableArray.init()
        }
        UserRegister.Shared.deleteflag = self.deleteFlag
        
        APIManager.sharedInstance.CallAPIRegisterUser(parameter: UserRegister.Shared, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                let userData = dataDict["data"] as! JSONDICTIONARY
                
                var mediaArray = NSMutableArray()
                mediaArray = NSMutableArray.init()
                for index in 1...6 {
                    let fileName = "file" + String(index)
                    
                    let filePath = userData[fileName] as! String
                    if filePath.count != 0 {
                        mediaArray.add(filePath)
                    }
                }
                CurrentUserModel.Shared.JsonParseFromDict(userData)
                CurrentUserModel.Shared.mediaArray = mediaArray
                
                Analytics.logEvent(NSLocalizedString("profile_update", comment: ""), parameters: [NSLocalizedString("user_name", comment: ""): (UserRegister.Shared.firstName! + " " + UserRegister.Shared.lastName!)])
                
                UserDefaults.standard.removeObject(forKey: "selectedCategories")
                self.navigationController?.popToRootViewController(animated: true)
                
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "reviewSegue" {
            
            let vc = segue.destination as! ReviewsVC
            vc.userID = UserSettings.userID
        }
        else if segue.identifier == "addCategoriesSegue" {
            
            let vc = segue.destination as! CategoriesVC
            vc.arrCategories = self.arrCategories.mutableCopy() as! NSMutableArray
        }
    }
}

extension UIImage {
    func fixOrientation() -> UIImage? {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
