//
//  CreateBusinssProfile.swift
//  Entreprenetwork
//
//  Created by khushbu on 18/12/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit
import MobileCoreServices
import YPImagePicker
import SKCountryPicker
import TagListView
import CropViewController
import UniformTypeIdentifiers

protocol CreateBusinessProfileDelegate {
    func redirectToProviderHome()
}


class CreateBusinssProfile: UIViewController,UITextViewDelegate {

    @IBOutlet weak var btnsetUpBusiness: UIButton!
    @IBOutlet weak var blurView: UIView!

    @IBOutlet weak var objTagView:TagListView!
    var arrayOfKeywordsTag:[String] = []
    @IBOutlet weak var buttonAddKeyword:UIButton!
    
    @IBOutlet weak var txtBusinessName: UITextField!
    @IBOutlet weak var btnUploadBusiensslogo: UIButton!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var lblBusinessemail: UITextField!
    @IBOutlet weak var txtBusinessAddress: UITextView!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtZipcode: UITextField!
    @IBOutlet weak var txtdescriptionOfBusienss: UITextView!
    @IBOutlet weak var txtBusinessType: UITextField!
    @IBOutlet weak var txtKeywords: CustomTextField!
    @IBOutlet weak var txtFldEIN: UITextField!
    @IBOutlet weak var btnEIN:UIButton!
    
    var delegate:CreateBusinessProfileDelegate?
    var isFromSidemenu = false
   
    @IBOutlet weak var txtFledBusinessLicence: UITextField!
    @IBOutlet weak var btnBusinessLicence:UIButton!
    
    @IBOutlet weak var btndriverlicence_Info: UIButton!
    @IBOutlet weak var txtFLDdriwverLicence: UITextField!
    @IBOutlet weak var btnDriverLicence_Upload:UIButton!
    
    @IBOutlet weak var txtFldHowtoTravel: UITextField!
    
    @IBOutlet weak var txtFieldInsurance: UITextField!
    
    var checked = false
    @IBOutlet weak var tableViewCreateBusiness:UITableView!
    @IBOutlet weak var imgBusinessLogo:UIImageView!
    
    
    @IBOutlet weak var btnCountryCode:UIButton!
    
    @IBOutlet weak var stackViewCity:UIStackView!
    @IBOutlet weak var stackViewState:UIStackView!
    @IBOutlet weak var stackViewZipCode:UIStackView!

    @IBOutlet weak var stackViewBusinessProfileImage:UIView!
    @IBOutlet weak var stackViewDescription:UIStackView!
    @IBOutlet weak var stackViewEIN:UIStackView!
    @IBOutlet weak var stackViewBusinessLicense:UIStackView!
    @IBOutlet weak var stackViewDriverLicense:UIStackView!
    @IBOutlet weak var stackViewInsurance:UIStackView!
    @IBOutlet weak var stackViewHowlongWilling:UIStackView!

    @IBOutlet weak var viewMoreOption:UIView!
    @IBOutlet weak var btnMoreOption:UIButton!
    
    
    @IBOutlet weak var buttonOne:UIButton!
    @IBOutlet weak var buttonTwo:UIButton!
    
    var customerBussinessLogoData:Data?
    var businessLogoParameters:[String:Any] = [:]
    
    var businessLicenceData:Data?
    var businessLicenceParameters:[String:Any] = [:]
    
    var driverLicenceData:Data?
    var driverLicenceParameters:[String:Any] = [:]
    
    var insuranceFileData:Data?
    var driverInsuranceParameters:[String:Any] = [:]
    
    var travelTimePicker:UIPickerView = UIPickerView()
    var travelTimePickerToolbar:UIToolbar = UIToolbar()
    
    var businessRegisterParameters:[String:Any] = [:]
    
    var arrayOfTravelTime:[GeneralList] = []
    var currentTravelTimeList:GeneralList?
    
    var businessTime = "1 hour, 00 minutes"
    var currentTravelTime:String{
        get{
            return  businessTime
        }
        set{
            self.businessTime = newValue
            
            
        }
    }
    var objImagePickerController = UIImagePickerController()
    var imageForCrop: UIImage?
    var is_firsttimeregister: Bool = false
    var userID:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblBusinessemail.delegate = self
        self.imgBusinessLogo.clipsToBounds = true
        self.imgBusinessLogo.contentMode = .scaleAspectFill
        self.txtCity.autocapitalizationType = .words
        self.txtState.autocapitalizationType = .words
        self.txtFldEIN.keyboardType = .numberPad
        self.txtCity.delegate = self
               self.txtState.delegate = self
        
        // Do any additional setup after loading the view.
        self.txtBusinessAddress.delegate = self
        self.tableViewCreateBusiness.tableFooterView = UIView()
        self.showHideCityStateZipCode(hide: true)
        
        
         //#
        self.buttonOne.layer.borderColor = UIColor.init(hex:"#AAAAAA").cgColor
        self.buttonOne.layer.borderWidth = 1.0
        self.buttonOne.clipsToBounds = true
        self.buttonOne.layer.cornerRadius = 25.0


        self.buttonTwo.layer.borderColor = UIColor.init(hex:"#248483").cgColor
        self.buttonTwo.layer.borderWidth = 1.0
        self.buttonTwo.clipsToBounds = true
        self.buttonTwo.layer.cornerRadius = 25.0
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.arrayOfTravelTime =  appDelegate.arrayTravelTime
                if self.arrayOfTravelTime.count > 0{
                    self.currentTravelTime = self.arrayOfTravelTime[0].name
                    
                }
        }
//        self.configureSelectedBusinessTravelTime()
        self.configureBusinessTimePredefinePicker()
        
        
        self.businessRegisterParameters["country_code"] = "+1"
        self.btnCountryCode.setTitle("+1", for: .normal)
        //
        self.objTagView.delegate = self
        let image = UIImage(named: "add_tag")?.withRenderingMode(.alwaysTemplate)
        self.buttonAddKeyword.setImage(image, for: .normal)
        self.buttonAddKeyword.tintColor = UIColor.init(hex: "#38B5A3")


        let underlineSeeDetail = NSAttributedString(string: "More Business Profile Options",
                                                                  attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnMoreOption.setAttributedTitle(underlineSeeDetail, for: .normal)
        self.btnMoreOption.addTarget(self, action: #selector(CreateBusinssProfile.buttonMoreOptionsSelector(sender:)), for: .touchUpInside)


//        self.presentCustomerHelpViewController()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    func configureBusinessTimePredefinePicker(){
        self.travelTimePickerToolbar.sizeToFit()
        self.travelTimePickerToolbar.layer.borderColor = UIColor.clear.cgColor
        self.travelTimePickerToolbar.layer.borderWidth = 1.0
        self.travelTimePickerToolbar.clipsToBounds = true
        self.travelTimePickerToolbar.backgroundColor = UIColor.white
        self.travelTimePicker.delegate = self
        self.travelTimePicker.dataSource = self
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(CreateBusinssProfile.donetravelTimePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "Travel Time", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:"Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(CreateBusinssProfile.cancelFormDatePicker))
        self.travelTimePickerToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
        
        
        self.txtFldHowtoTravel.inputView = self.travelTimePicker
        self.txtFldHowtoTravel.inputAccessoryView = self.travelTimePickerToolbar
    }
    func configureSelectedBusinessTravelTime(){
        DispatchQueue.main.async {
            self.txtFldHowtoTravel.text = self.currentTravelTime
            let filterArray = self.arrayOfTravelTime.filter{ $0.name == self.currentTravelTime}
                if filterArray.count > 0{
                    let index = self.arrayOfTravelTime.firstIndex(where: {$0.id == "\(filterArray.first!.id)"})
                    if let _ = index{
                        self.travelTimePicker.selectRow(index!, inComponent: 0, animated: true)
                    }
                   self.businessRegisterParameters["how_long_willing_to_travel"] = filterArray.first!.id
                }
        }
    }
        @objc func donetravelTimePicker(){
            self.configureSelectedBusinessTravelTime()
            DispatchQueue.main.async {
                self.view.endEditing(true)
            }
        }
        @objc func cancelFormDatePicker(){
            DispatchQueue.main.async {
                self.view.endEditing(true)
            }
        }
    private func initialize() {
        
    }
    func sizeHeaderFit(){
        DispatchQueue.main.async {
            if let headerView =  self.tableViewCreateBusiness.tableHeaderView {
                headerView.setNeedsLayout()
                headerView.layoutIfNeeded()
                print(headerView.bounds)
                print(headerView.frame)
                
                let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
                print(height)
                var frame = headerView.frame
                frame.size.height = height
                headerView.frame = frame
                self.tableViewCreateBusiness.tableHeaderView = headerView
                self.view.layoutIfNeeded()
            }
        }
       }
    func showHideCityStateZipCode(hide:Bool){
        self.stackViewCity.isHidden = hide
        self.stackViewState.isHidden = hide
        self.stackViewZipCode.isHidden = hide
        
        self.sizeHeaderFit()
        
        
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("textViewShouldBeginEditing")
        if self.txtBusinessAddress == textView{
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.showHideCityStateZipCode(hide: false)
                }
            }
        }
        return true
    }
    //MARK: Action keywords
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func action_Keywords_info(_ sender: Any) {
    }
    @IBAction func buttonBusinessLogoSelector(sender:UIButton){
        
        self.presentCameraAndPhotosSelector()
        /*
              var config = YPImagePickerConfiguration()
               config.showsPhotoFilters = false
               config.library.maxNumberOfItems = 1
               config.isScrollToChangeModesEnabled = false
               config.startOnScreen = .library
               
               let picker = YPImagePicker(configuration: config)
               
               picker.didFinishPicking { [unowned picker] items, _ in
                   if let photo = items.singlePhoto {
                       let aImg = photo.image
                       
                       let resizedImage = self.resize(aImg)
                       self.imgBusinessLogo.image = UIImage.init(data: resizedImage)
                       self.customerBussinessLogoData = resizedImage
                      //Upload business logo api request
                      self.uploadBusinessLogoAPIRequest(imageData: resizedImage)
                    
                       
                   }
                   picker.dismiss(animated: true, completion: nil)
               }
              self.present(picker, animated: true, completion: nil)
        */
        
    }
    func presentCameraAndPhotosSelector(){
         //PresentMedia Selector
         let actionSheetController = UIAlertController.init(title: "", message: "Business Profile", preferredStyle: .actionSheet)
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
    func resize(_ image: UIImage) -> Data{
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
        return imageData!//UIImage(data: imageData!) ?? UIImage()
    }
    //MARK: Selector Methods
    @IBAction func buttonMoreOptionsSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.viewMoreOption.fadeOut() //hide
            self.stackViewBusinessProfileImage.fadeIn()
            self.stackViewDescription.fadeIn()
            self.stackViewEIN.fadeIn()
            self.stackViewBusinessLicense.fadeIn()
            self.stackViewDriverLicense.fadeIn()
            self.stackViewInsurance.fadeIn()
            self.stackViewHowlongWilling.fadeIn()
            do{
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {

                    self.sizeHeaderFit()

                }
            }
        }
    }
    @IBAction func buttonCameraInfoSelector(sender:UIButton){
        DispatchQueue.main.async {
            let cameraInfo = UIAlertController.init(title:AppName, message: kUserProfileHelp, preferredStyle: .alert)
            cameraInfo.addAction(UIAlertAction.init(title:"ok", style: .cancel, handler: nil))
            cameraInfo.view.tintColor = UIColor.init(hex: "#38B5A3")
            self.present(cameraInfo, animated: true, completion: nil)
        }
    }
    @IBAction func btnCountryCodeSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in
            
            guard let self = self else { return }
            
            self.btnCountryCode.setTitle(country.dialingCode, for: .normal)
            self.businessRegisterParameters["country_code"] = "\(country.dialingCode ?? "+1")"
            
        }
        // can customize the countryPicker here e.g font and color
        countryController.detailColor = UIColor.red
    }
    @IBAction func buttonAddKeywordSelector(sender:UIButton){
            guard let strKeywords = self.txtKeywords.text?.trimmingCharacters(in: .whitespacesAndNewlines),strKeywords.count > 0 else{
                return
            }
        if self.arrayOfKeywordsTag.count < 50{
                 DispatchQueue.main.async {
                              self.view.endEditing(true)
                              self.objTagView.addTag(strKeywords)
                              self.arrayOfKeywordsTag.append(strKeywords)
                              UIView.animate(withDuration: 0.3) {
                                  self.txtKeywords.text = ""
                                  self.sizeHeaderFit()
                              }
                          }
             }else{
                 DispatchQueue.main.async {
                      SAAlertBar.show(.error, message:"You cannot add more than 50 keywords".localizedLowercase)
                 }
             }
        /*
            DispatchQueue.main.async {
                self.view.endEditing(true)
                self.objTagView.addTag(strKeywords)
                self.arrayOfKeywordsTag.append(strKeywords)
                UIView.animate(withDuration: 0.3) {
                    self.txtKeywords.text = ""
                    self.sizeHeaderFit()
                }
            }*/
    }
    @IBAction func buttonKeywordHelpSelector(button:UIButton){
        let alert = UIAlertController(title: "Keywords Help", message: "Keywords, are how customers find you. Ex. If you have a residential or commercial cleaning company, good keywords would be “cleaning” or “maid”.The more targeted and focused your keywords are, the better your leads will be.", preferredStyle: .alert)
        let cancelAction =  UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.view.tintColor = UIColor.init(hex: "#38B5A3")
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func btnEnInformationSelector(button:UIButton){
         
         let alert = UIAlertController(title: "EIN Help", message: "This field is optional, but if you have one it will help legitimize your business.", preferredStyle: .alert)
         
         let cancelAction =  UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
         alert.addAction(cancelAction)
         alert.view.tintColor = UIColor.init(hex: "#38B5A3")
         self.present(alert, animated: true, completion: nil)
     }
    @IBAction func buttonBusinessLicenceInfoSelector(button:UIButton){
        let alert = UIAlertController(title: "Business License & Credentials Help", message: "While these are optional, a business license lets customers know you mean exactly that, and credentials show you know your stuff.", preferredStyle: .alert)
        
        let cancelAction =  UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.view.tintColor = UIColor.init(hex: "#38B5A3")
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func btnDriverLicenceInfoSelector(button:UIButton){
            let alert = UIAlertController(title: "Driver's License Help", message: "Your driver’s license will not be shared. We let customers know we have confirmed your license to provide them with additional confidence", preferredStyle: .alert)
                  
                  let cancelAction =  UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
                  alert.addAction(cancelAction)
                    alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                  self.present(alert, animated: true, completion: nil)
     }
    
    @IBAction func buttonInsuranceHelpSelector(button:UIButton){
           let alert = UIAlertController(title: "Insurance Help", message: "While it is not mandatory to enter this information here, it is your responsibility to have insurance if it is relevant to your business. For example, if you are a web designer who works remotely, insurance is optional, but if you are a home renovator of any kind, not only is it mandatory, customers will not hire you without it.", preferredStyle: .alert)
           
           let cancelAction =  UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
           alert.addAction(cancelAction)
           alert.view.tintColor = UIColor.init(hex: "#38B5A3")
           self.present(alert, animated: true, completion: nil)
    }
    @IBAction func buttonHowlongwillingtotravelSelector(button:UIButton){
           let alert = UIAlertController(title: "How long willing to travel? Help", message: "We find customers for you within the travel time you are willing to travel. If you do roofing work, you might be willing to drive 2 hours for a job. If you provide haircuts onsite, an hour max might be more to your liking. If customers will be coming to you for a haircut then select N/A, as travel time from your perspective is not applicable.Keep in mind that customers will also be putting in their maximum travel times, and if they only want to entertain roofing providers from up to 1 hour away, or drive up to 30 minutes for a haircut, only providers that are within their maximum time limits will alerted to provide them with an offer.", preferredStyle: .alert)
                     
                     let cancelAction =  UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
                     alert.addAction(cancelAction)
                     alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                     self.present(alert, animated: true, completion: nil)
    }
    
 
    @IBAction func btnBusinesslicence_upload_selector(_ sender: Any) {
        
        self.presentDocumentAndImagePickerActionSheet(indexForPicker: 0)
    }
    @IBAction func btnInsurance_upload_selector(_ sender: Any) {
           self.presentDocumentAndImagePickerActionSheet(indexForPicker: 2)
           //self.presentDocumentAndImagePickerActionSheet(isBusinessLicence: true)
       }
    func presentDocumentPickerForBusinessLicence(){
        let types: [UTType] = [UTType.pdf, UTType.text, UTType.rtf, UTType.spreadsheet]
        let importMenu = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        /*
        let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet]
        let importMenu = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        */
        importMenu.allowsMultipleSelection = false
        

        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        importMenu.accessibilityValue = "1"
        self.present(importMenu, animated: true)
    }
    func presentDocumentPickerForInsurance(){
        let types: [UTType] = [UTType.pdf, UTType.text, UTType.rtf, UTType.spreadsheet]
        let importMenu = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
          /*
           let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet]
           let importMenu = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)*/

               importMenu.allowsMultipleSelection = false
           

           importMenu.delegate = self
           importMenu.modalPresentationStyle = .formSheet
           importMenu.accessibilityValue = "3"
           self.present(importMenu, animated: true)
       }
    func presentImagePickerForLicenceUplaod(indexForPicker:Int){
        var config = YPImagePickerConfiguration()
         config.showsPhotoFilters = false
         config.library.maxNumberOfItems = 1
         config.isScrollToChangeModesEnabled = false
         config.startOnScreen = .library
         
         let picker = YPImagePicker(configuration: config)
         
         picker.didFinishPicking { [unowned picker] items, _ in
             if let photo = items.singlePhoto {
                 let aImg = photo.image
                 
                 let resizedImage = self.resize(aImg)
                if indexForPicker == 0{
                    self.businessLicenceData = resizedImage
                   //Upload business licence api request
                   self.uploadBusinessLogoAPIRequest(imageData: resizedImage,index:1)
                }else if indexForPicker == 1{
                    self.driverLicenceData = resizedImage
                    //Upload driver licence api request
                    self.uploadBusinessLogoAPIRequest(imageData: resizedImage,index:2)
                }else if indexForPicker == 2 {
                    self.insuranceFileData = resizedImage
                    //Upload driver licence api request
                    self.uploadBusinessLogoAPIRequest(imageData: resizedImage,index:3)
                }else{
                    
                }
             }
             picker.dismiss(animated: true, completion: nil)
         }
        self.present(picker, animated: true, completion: nil)
        
        
    }
    func presentDocumentAndImagePickerActionSheet(indexForPicker:Int){ // 0 for business licence 1 for driver liecence 2 for insurance
        var title = "Select Licence"
        if indexForPicker == 2{
            title = "Select Insurance"
        }
        
        let actionSheet: UIAlertController = UIAlertController(title: "\(title)", message: "", preferredStyle: .actionSheet)
               
               let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                   print("Cancel")
               }
               cancelActionButton.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
               actionSheet.addAction(cancelActionButton)
               
               let cameraActionButton = UIAlertAction(title: "Image", style: .default)
               { _ in
                   
                self.presentImagePickerForLicenceUplaod(indexForPicker: indexForPicker)
               }
         cameraActionButton.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
               actionSheet.addAction(cameraActionButton)
               
               let galleryActionButton = UIAlertAction(title: "Document", style: .default)
               { _ in
                if indexForPicker == 0{
                    self.presentDocumentPickerForBusinessLicence()
                }else if indexForPicker == 1{
                    self.presentDocumentPickerForDriverLicence()
                }else if indexForPicker == 2{
                    self.presentDocumentPickerForInsurance()
                }else{
                    
                }
               }
        galleryActionButton.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
               actionSheet.addAction(galleryActionButton)
               
               self.present(actionSheet, animated: true, completion: nil)
    }
    
   
    @IBAction func btnDriverLicenceUploadSelector(button:UIButton){
        
        self.presentDocumentAndImagePickerActionSheet(indexForPicker: 1)
    }
    func presentDocumentPickerForDriverLicence(){
        let types: [UTType] = [UTType.pdf, UTType.text, UTType.rtf, UTType.spreadsheet]
        let importMenu = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        /*let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet]
        let importMenu = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)*/
        
            importMenu.allowsMultipleSelection = false
        

        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        importMenu.accessibilityValue = "2"
        self.present(importMenu, animated: true)
    }
    // Action_Submit
    @IBAction func btnSubmitSelector(_ sender: Any) {
        if self.isValidaData(){
            //Provider Register API request
            self.sendBusinessRegisterAPIRequest()
        }
    }
    func popToLogInViewController(){
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let navigationController = UINavigationController(rootViewController:loginVC)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }
    func isValidaData()->Bool{
        
        if let currentUser = UserDetail.getUserFromUserDefault(){
            self.businessRegisterParameters["user_id"] = "\(currentUser.id)"
        }else{
            if self.userID.count > 0{
                self.businessRegisterParameters["user_id"] = "\(self.userID)"
            }
        }
        
        /*guard let _ = self.customerBussinessLogoData else {
             SAAlertBar.show(.error, message:"Please select business logo".localizedLowercase)
             return false
        }*/
        if let _ = self.customerBussinessLogoData{
            self.businessRegisterParameters["business_logo"] = self.businessLogoParameters
        }

        
        guard let businessName = self.txtBusinessName.text?.trimmingCharacters(in: .whitespacesAndNewlines),businessName.count > 0 else{
            SAAlertBar.show(.error, message:"Please enter business name".localizedLowercase)
            return false
        }
        self.businessRegisterParameters["business_name"] = "\(businessName)"
        
        guard let mobileNumber = self.txtMobileNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines),mobileNumber.count > 0 else{
           SAAlertBar.show(.error, message:"Please enter mobile number".localizedLowercase)
           return false
        }
        self.businessRegisterParameters["phone"] = "\(mobileNumber)"
        
        
        
        
        guard let businessEmail = self.lblBusinessemail.text?.trimmingCharacters(in: .whitespacesAndNewlines),businessEmail.count > 0 else{
          SAAlertBar.show(.error, message:"Please enter business email".localizedLowercase)
          return false
        }
 
        guard self.isValidEmail(email: "\(businessEmail)") else{
           SAAlertBar.show(.error, message:"Please enter valid business email".localizedLowercase)
            return false
        }
        self.businessRegisterParameters["email"] = "\(businessEmail)"
       
        guard let businessAddress = self.txtBusinessAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines),businessAddress.count > 0 else{
          SAAlertBar.show(.error, message:"Please enter business Address".localizedLowercase)
          return false
        }
        self.businessRegisterParameters["address"] = "\(businessAddress)"
        
        guard let businessCity = self.txtCity.text?.trimmingCharacters(in: .whitespacesAndNewlines),businessCity.count > 0 else{
          SAAlertBar.show(.error, message:"Please enter business City".localizedLowercase)
          return false
        }
        self.businessRegisterParameters["city"] = "\(businessCity)"
        
        guard let businessState = self.txtState.text?.trimmingCharacters(in: .whitespacesAndNewlines),businessState.count > 0 else{
          SAAlertBar.show(.error, message:"Please enter business State".localizedLowercase)
          return false
        }
        self.businessRegisterParameters["state"] = "\(businessState)"
        
        guard let businessZipCode = self.txtZipcode.text?.trimmingCharacters(in: .whitespacesAndNewlines),businessZipCode.count > 0 else{
          SAAlertBar.show(.error, message:"Please enter business ZipCode".localizedLowercase)
          return false
        }
//        if businessZipCode.count > 6{
//            SAAlertBar.show(.error, message:"for zip code maximum limit 6 characters")
//            return false
//        }
                
        self.businessRegisterParameters["zipcode"] = "\(businessZipCode)"
        
        /*guard let businessdescription = self.txtdescriptionOfBusienss.text?.trimmingCharacters(in: .whitespacesAndNewlines),businessdescription.count > 0 else{
          SAAlertBar.show(.error, message:"Please enter business Description".localizedLowercase)
          return false
        }*/
        if let businessdescription = self.txtdescriptionOfBusienss.text?.trimmingCharacters(in: .whitespacesAndNewlines),businessdescription.count > 0{
            self.businessRegisterParameters["description"] = "\(businessdescription)"
        }

        //Remove business Type
        /*
        guard let businessType = self.txtBusinessType.text?.trimmingCharacters(in: .whitespacesAndNewlines),businessType.count > 0 else{
          SAAlertBar.show(.error, message:"Please enter business Type".localizedLowercase)
          return false
        }
        self.businessRegisterParameters["business_type"] = "\(businessType)"*/
        
        guard self.arrayOfKeywordsTag.count > 0 else {
            SAAlertBar.show(.error, message:"Please enter business Keywords".localizedLowercase)
            return false
        }
        /*
        guard let businessKeyword = self.txtKeywords.text?.trimmingCharacters(in: .whitespacesAndNewlines),businessKeyword.count > 0 else{
          SAAlertBar.show(.error, message:"Please enter business Keywords".localizedLowercase)
          return false
        }*/
        self.businessRegisterParameters["keywords_for_business"] = "\(self.arrayOfKeywordsTag.joined(separator: ", "))"
        
//        guard let businessEIN = self.txtFldEIN.text?.trimmingCharacters(in: .whitespacesAndNewlines),businessEIN.count > 0 else{
//          SAAlertBar.show(.error, message:"Please enter EIN".localizedLowercase)
//          return false
//        }
        self.businessRegisterParameters["ein"] = "\(self.txtFldEIN.text ?? "")"
        
        if let _ = self.driverLicenceData {
                   self.businessRegisterParameters["driver_license"] = self.driverLicenceParameters
        }
        
        if let _ = self.businessLicenceData {
            self.businessRegisterParameters["business_license"] = self.businessLicenceParameters

              //SAAlertBar.show(.error, message:"Please add business license".localizedLowercase)
              //return false
         }
        
        if let businessInsurance = self.txtFieldInsurance.text?.trimmingCharacters(in: .whitespacesAndNewlines),businessInsurance.count > 0{
//             self.businessRegisterParameters["insurance"] = businessInsurance////////
//          SAAlertBar.show(.error, message:"Please enter business Insurance".localizedLowercase)
//          return false
        }
        
       
        
        
        
        return true
    }
    
     func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
        
        }
     
     //MARk:Enbale Business Profle Enable and Disable
     @IBAction func action_enable_buisness_Profile(_ sender: UIButton) {
        if checked {
            sender.setImage( UIImage(named:"checkBox"), for: .normal
            )
               checked = false
            blurView.isHidden = false
           } else {
            sender.setImage(UIImage(named:"checkBoxEmpty"), for: .normal)
               checked = true
            blurView.isHidden = true
           }
     }
     
    
    //MARK:- API request methods
    //Upload Business Logo image
    func uploadBusinessLogoAPIRequest(imageData:Data,index:Int = 0){ //0 for business logo 1 for business licence 2 for driver licence
        
        var businessLogoUploadParameters :[String:Any] = [:]
        
        businessLogoUploadParameters["page_name"] = "provider-register"
        
        APIRequestClient.shared.uploadImage(requestType: .POST, queryString:kProviderFileUpload , parameter: businessLogoUploadParameters as [String:AnyObject], imageData:imageData ,isFileUpload : true, isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                ExternalClass.HideProgress()
            }
            if let success = responseSuccess as? [String:Any],let fileInfo = success["success_data"] as? [String:Any]{
                
                switch index {
                    case 0:
                        self.businessLogoParameters = fileInfo
                        break
                    
                    case 1:
                        self.businessLicenceParameters = fileInfo
                        if let fileName = fileInfo["file_name"]{
                            DispatchQueue.main.async {
                                self.txtFledBusinessLicence.text = "\(fileName)"
                            }
                        }
                        break
                    
                    case 2:
                        self.driverLicenceParameters = fileInfo
                        if let fileName = fileInfo["file_name"]{
                            DispatchQueue.main.async {
                                self.txtFLDdriwverLicence.text = "\(fileName)"
                            }
                        }
                        break
                    case 3:
                           self.driverInsuranceParameters = fileInfo
                           if let fileName = fileInfo["file_name"]{
                               DispatchQueue.main.async {
                                   self.txtFieldInsurance.text = "\(fileName)"
                               }
                           }
                           self.businessRegisterParameters["insurance"] = self.driverInsuranceParameters
                           break
                    default:
                        print("default")
                }
                
                
                
                DispatchQueue.main.async {
                    
                }
            }
        }) { (responseFail) in
                DispatchQueue.main.async {
                    ExternalClass.HideProgress()
                }
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"]{
                DispatchQueue.main.async {
                    SAAlertBar.show(.error, message:"\(errorMessage)".localizedLowercase)
        //                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                   // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
    }
    //Upload business licence
    func uploadBusinessLicenceAPIRequest(fileData:Data){
               
               var businessLogoUploadParameters :[String:Any] = [:]
               
               businessLogoUploadParameters["page_name"] = "provider-register"
               
               APIRequestClient.shared.uploadImage(requestType: .POST, queryString:kProviderFileUpload , parameter: businessLogoUploadParameters as [String:AnyObject], imageData:fileData ,isFileUpload : true, isHudeShow: true, success: { (responseSuccess) in
                   DispatchQueue.main.async {
                       ExternalClass.HideProgress()
                   }
                   if let success = responseSuccess as? [String:Any],let fileInfo = success["success_data"] as? [String:Any]{
                       
                       self.businessLicenceParameters = fileInfo
                    self.businessRegisterParameters["business_license"] = self.businessLicenceParameters

                        if let fileName = fileInfo["file_name"]{
                            DispatchQueue.main.async {
                                self.txtFledBusinessLicence.text = "\(fileName)"
                            }
                        }
                    
                       DispatchQueue.main.async {
                           //self.navigationController?.popViewController(animated: true)
                       }
                   }
               }) { (responseFail) in
                       DispatchQueue.main.async {
                           ExternalClass.HideProgress()
                       }
                   if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"]{
                       DispatchQueue.main.async {
                           SAAlertBar.show(.error, message:"\(errorMessage)".localizedLowercase)
               //                    ShowToast.show(toatMessage: "\(errorMessage)")
                       }
                   }else{
                       DispatchQueue.main.async {
                           //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                       }
                   }
               }
    }
    //Upload driver licence
    func uploadDriverLicenceAPIRequest(fileData:Data){
      
        var businessLogoUploadParameters :[String:Any] = [:]
        
        businessLogoUploadParameters["page_name"] = "provider-register"
        
        APIRequestClient.shared.uploadImage(requestType: .POST, queryString:kProviderFileUpload , parameter: businessLogoUploadParameters as [String:AnyObject], imageData:fileData ,isFileUpload : true, isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                ExternalClass.HideProgress()
            }
            if let success = responseSuccess as? [String:Any],let fileInfo = success["success_data"] as? [String:Any]{
                
                self.driverLicenceParameters = fileInfo
                self.businessRegisterParameters["driver_license"] = self.driverLicenceParameters

                if let fileName = fileInfo["file_name"]{
                    DispatchQueue.main.async {
                        self.txtFLDdriwverLicence.text = "\(fileName)"
                    }
                }
                DispatchQueue.main.async {
                    //self.navigationController?.popViewController(animated: true)
                }
            }
        }) { (responseFail) in
                DispatchQueue.main.async {
                    ExternalClass.HideProgress()
                }
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"]{
                DispatchQueue.main.async {
                    SAAlertBar.show(.error, message:"\(errorMessage)".localizedLowercase)
        //                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                   // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
    }
    func uploadInsuranceAPIRequest(fileData:Data){
      
        var businessLogoUploadParameters :[String:Any] = [:]
        
        businessLogoUploadParameters["page_name"] = "provider-update"
        
        APIRequestClient.shared.uploadImage(requestType: .POST, queryString:kProviderFileUpload , parameter: businessLogoUploadParameters as [String:AnyObject], imageData:fileData ,isFileUpload : true, isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                ExternalClass.HideProgress()
            }
            if let success = responseSuccess as? [String:Any],let fileInfo = success["success_data"] as? [String:Any]{
                
                self.driverInsuranceParameters = fileInfo
                self.businessRegisterParameters["insurance"] = self.driverInsuranceParameters
                if let fileName = fileInfo["file_name"]{
                    DispatchQueue.main.async {
                        self.txtFieldInsurance.text = "\(fileName)"
                    }
                }
                DispatchQueue.main.async {
                    //self.navigationController?.popViewController(animated: true)
                }
            }
        }) { (responseFail) in
                DispatchQueue.main.async {
                    ExternalClass.HideProgress()
                }
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"]{
                DispatchQueue.main.async {
                    SAAlertBar.show(.error, message:"\(errorMessage)".localizedLowercase)
        //                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                   // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
    }
    //User register API request
    func sendBusinessRegisterAPIRequest(){
        
        self.businessRegisterParameters["is_first_time_register"] = self.is_firsttimeregister
        print(self.businessRegisterParameters)
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kProviderRegister , parameter: self.businessRegisterParameters as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                DispatchQueue.main.async {
                    
                    if let customerData = userInfo["customer_data"] as? [String:Any]{
                            let objUser:UserDetail = UserDetail.init(userDetail: customerData)
                            if let providerDetail = userInfo["provider_data"] as? [String:Any]{
                                let objprovider:BusinessDetail = BusinessDetail.init(businessDetail: providerDetail)
                                objUser.businessDetail = objprovider
                            }
                            objUser.setuserDetailToUserDefault()
                        DispatchQueue.main.async {
                            if self.isFromSidemenu{
                                if let _ = self.delegate{
                                    //MOVE TO Home View 17/06/2021
                                    
                                    if let strMessage = success["success_message"]{
                                        let alert = UIAlertController(title: AppName, message: "\(strMessage)", preferredStyle: .alert)
                                             let cancelAction = UIAlertAction.init(title: "Ok", style: .default) { (_) in
                                                        DispatchQueue.main.async {
                                                           //MOVE TO HOME SCREEN 17/06/2021
                                                            self.pushToCustomerHomeViewController()
                                                        }
                                                    }
                                        
                                             alert.addAction(cancelAction)
                                             alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                                             self.present(alert, animated: true, completion: nil)
                                    }
                                    //self.delegate!.redirectToProviderHome()
                                }
                            }else{
                                if let strMessage = success["success_message"]{
                                    let alert = UIAlertController(title: AppName, message: "\(strMessage)", preferredStyle: .alert)
                                         let cancelAction = UIAlertAction.init(title: "Ok", style: .default) { (_) in
                                                    DispatchQueue.main.async {
                                                        //MOVE TO LOGIN SCREEN // 29/06/2021
                                                        self.navigationController?.popToRootViewController(animated: true)
                                                       //MOVE TO HELP SCREEN 23/03/2021
                                                       //self.pushToHelpViewController()
                                                    }
                                                }
                                    
                                         alert.addAction(cancelAction)
                                         alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                                         self.present(alert, animated: true, completion: nil)
                                }else{
                                    //MOVE TO HELP SCREEN 23/03/2021
//                                    self.pushToHelpViewController()
                                    self.presentCustomerHelpViewController()
                                }
                               
                                //self.popToLogInViewController()
                            }
                            
                        }
                            
                        }
//                    let objUser = UserDetail.init(userDetail: userInfo)
//                    objUser.setuserDetailToUserDefault()
                    
                     
                            
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
                    //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                }
            }
        }
    }
    func pushToCustomerHomeViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let navigationController = UINavigationController(rootViewController:VC)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }
    func pushToHelpViewController(){
        if let helpViewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomerHelpViewController") as? CustomerHelpViewController{
            self.navigationController?.pushViewController(helpViewController, animated: true)
        }
      
    }
    func presentCustomerHelpViewController(){
        DispatchQueue.main.async {
            if let customerHelp = UIStoryboard.profile.instantiateViewController(withIdentifier: "CustomerProviderHelpVideoViewController") as? CustomerProviderHelpVideoViewController{
                customerHelp.modalPresentationStyle = .fullScreen
                customerHelp.delegate = self
                customerHelp.isForCustomer = true
                self.navigationController?.present(customerHelp, animated: true, completion: nil)
            }
        }

    }
    func presentProviderHelpViewController(){
        DispatchQueue.main.async {
            if let customerHelp = UIStoryboard.profile.instantiateViewController(withIdentifier: "CustomerProviderHelpVideoViewController") as? CustomerProviderHelpVideoViewController{
                customerHelp.modalPresentationStyle = .fullScreen
                customerHelp.delegate = self
                customerHelp.isForCustomer = false
                self.navigationController?.present(customerHelp, animated: true, completion: nil)
            }
        }

    }
    func pushToOnlyproviderHelpViewController(){
             if let helpViewController = self.storyboard?.instantiateViewController(withIdentifier: "HelpViewController") as? HelpViewController{
                 self.navigationController?.pushViewController(helpViewController, animated: true)
             }
         }

}
extension CreateBusinssProfile:CustomerProviderHelpDelegate{
    func playerDidFinishWithPlay(isforcustomer: Bool, isForVerifiedProvider: Bool) {

        DispatchQueue.main.async {
            if isforcustomer{
                self.presentProviderHelpViewController()
            }else{
                self.navigationController?.popToRootViewController(animated: true)
                //self.pushToCustomerHomeViewController()
            }

        }
    }
}
extension CreateBusinssProfile:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)

        if textField == self.lblBusinessemail{
            guard !typpedString.isContainWhiteSpace() else{
                        return false
            }
            return typpedString.count < 255
        }
        if textField == self.txtCity || textField == self.txtState{
            do {
                                let regex = try NSRegularExpression(pattern: ".*[^A-Za-z\\s].*", options: [])
                                if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
                                    return false
                                }
                            }
                            catch {
                                print("ERROR")
                            }
                        return true
        }
//        if(textField == self.txtFieldPassword && !self.txtFieldPassword.isSecureTextEntry) {
//            self.txtFieldPassword.isSecureTextEntry = true
//        }
//        if(textField == self.txtFldConfirmPassword && !self.txtFldConfirmPassword.isSecureTextEntry) {
//            self.txtFldConfirmPassword.isSecureTextEntry = true
//        }
        
        return true
    }
  
}
extension CreateBusinssProfile:UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        self.dismiss(animated: true, completion: nil)
        let resizedImage = self.resize(image)
                             self.imgBusinessLogo.image = UIImage.init(data: resizedImage)
                             self.customerBussinessLogoData = resizedImage
                            //Upload business logo api request
                            self.uploadBusinessLogoAPIRequest(imageData: resizedImage)
                   
    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.imageForCrop = image
           /*
             let resizedImage = self.resize(image)
                        self.btnUserProfilePic.setBackgroundImage(UIImage.init(data: resizedImage), for: .normal)
                        self.customerProfileImageData = resizedImage
             */
            
            
            
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
        //cropViewController.setAspectRatioPreset(.presetSquare, animated: true)
        cropViewController.delegate = self
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.cropView.cropBoxResizeEnabled = false
        self.present(cropViewController, animated: true, completion: nil)
        /*
        // Use view controller
        let controller = CropViewController()
        controller.delegate = self
        controller.image = image
        controller.isBadge = false
        kUserDefault.set(false, forKey: "isBadge")
        let navController = UINavigationController(rootViewController: controller)
        controller.modalPresentationStyle = .fullScreen
        navigationController?.modalPresentationStyle = .fullScreen
        self.present(navController, animated: false, completion: nil)
        */
    }
    /*
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        switch mediaType {
        case kUTTypeImage:
            //                if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage,let imageData = editedImage.jpeg(.lowest){
            //                    print("\(Date().ticks)")
            //                    self.uploadImageRequest(imageData: imageData, imageName:"image")
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                dismiss(animated: false, completion: nil)
                return
            }
            self.imageForCrop = image
            dismiss(animated: false) { [unowned self] in
                self.openEditor(nil, pickingViewTag: picker.view.tag)
            }
            break
        case kUTTypeMovie:
            if let videoURL = info[UIImagePickerControllerMediaURL] as? URL{
                
                guard let data = NSData(contentsOf: videoURL as URL) else {
                    DispatchQueue.main.async {
                        self.lblTesting.text = "No data"
                        ProgressHud.hide()
                    }
                    return
                }
                DispatchQueue.main.async {
                    ProgressHud.show()
                    self.lblTesting.text = "Video URL \(videoURL) \r File size before compression: \(Double(data.length / 1048576)) mb"
                }
                print("File size before compression: \(Double(data.length / 1048576)) mb")
                let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
                self.compressVideo(inputURL: videoURL as URL, outputURL: compressedURL) { (exportSession) in
                    guard let session = exportSession else {
                        DispatchQueue.main.async {
                            self.lblTesting.text = "No exportSession"
                            ProgressHud.hide()
                        }
                        return
                    }
                    if session.status == .completed{
                        guard let compressedData = NSData(contentsOf: compressedURL) else {
                            DispatchQueue.main.async {
                                self.lblTesting.text = "No compress data"
                                ProgressHud.hide()
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            ProgressHud.show()
                            self.lblTesting.text = "Start Uploading \r File size after compression: \(Double(compressedData.length / 1048576)) mb"
                        }
                        self.uploadVideoRequest(videoData: compressedData as Data, videoName:"\(videoURL.lastPathComponent)")
                    }else{
                        DispatchQueue.main.async {
                            ProgressHud.hide()
                            ShowToast.show(toatMessage:kCommonError)
                        }
                    }
                }
                
            }
            break
        case kUTTypeLivePhoto:
            
            break
        default:
            break
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }*/
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
}

extension CreateBusinssProfile:UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
           print(urls)
            if urls.count > 0,let fileURL = urls.first{
                if FileManager.default.fileExists(atPath: fileURL.path){
                    print("yes")
                    if let data = self.loadFileFromLocalPath(fileURL.path){
                        if controller.accessibilityValue == "1"{
                            self.businessLicenceData = data
                            //Upload Business Licenece document
                            self.uploadBusinessLicenceAPIRequest(fileData: data)
                        }else if controller.accessibilityValue == "2"{
                            self.driverLicenceData = data
                            //Upload Driver Licenece document
                            self.uploadDriverLicenceAPIRequest(fileData: data)
                        }else if controller.accessibilityValue == "3"{
                            self.insuranceFileData = data
                            //Upload Driver Licenece document
                            self.uploadInsuranceAPIRequest(fileData: data)
                        }
                    }
                }else{
                    print("false")
                }
            }
        }

         func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true, completion: nil)
        }
    func loadFileFromLocalPath(_ localFilePath: String) ->Data? {
       return try? Data(contentsOf: URL(fileURLWithPath: localFilePath))
    }
    
    
}
extension CreateBusinssProfile:UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.arrayOfTravelTime[row].name
       
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return UIScreen.main.bounds.width
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.arrayOfTravelTime.count
       
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currentTravelTime = self.arrayOfTravelTime[row].name
    }
}
extension CreateBusinssProfile:TagListViewDelegate{
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        DispatchQueue.main.async {
            self.objTagView.removeTag(title)
            if self.arrayOfKeywordsTag.contains(title){
                if let index = self.arrayOfKeywordsTag.firstIndex(of: title){
                    self.arrayOfKeywordsTag.remove(at: index)
                }
            }
            
            self.sizeHeaderFit()
        }
    }
}
