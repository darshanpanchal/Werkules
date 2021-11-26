//
//  AddPromotionViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 04/02/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import YPImagePicker
import MobileCoreServices
import CropViewController

class AddPromotionViewController: UIViewController {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tableViewAddPromotions:UITableView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtDescription:UITextView!
    
    @IBOutlet weak var lblDiscountpercentage:UILabel!
    @IBOutlet weak var lblDiscountpercentageTotal:UILabel!
    
    @IBOutlet weak var txtDiscountpercentage:UITextField!
    @IBOutlet weak var btnDiscountpercentage:UIButton!
    
    @IBOutlet weak var lblSavingpercentage:UILabel!
    @IBOutlet weak var lblSavingpercentageTotal:UILabel!
    
    @IBOutlet weak var txtSavingpercentage:UITextField!
    @IBOutlet weak var btnSavingpercentage:UIButton!
    
    @IBOutlet weak var btnUploadImage:UIButton!
    @IBOutlet weak var txtPicturename:UITextField!
    
    @IBOutlet weak var txtexpireyDate:UITextField!
    @IBOutlet weak var btnUserOncePerCustomer:UIButton!
    
    
    @IBOutlet weak var stackViewCustomerPercentageDiscount:UIStackView!
    @IBOutlet weak var stackViewCustomerAmountDiscount:UIStackView!
    
    
    var fromDatePicker:UIDatePicker = UIDatePicker()
    var fromDatePickerToolbar:UIToolbar = UIToolbar()
    
    @IBOutlet weak var buttonCreate:UIButton!
    
    var promotionImageData:Data?
    
    var isUseOnce:Bool = false
    var isCheckUseOnce:Bool {
        get{
            return isUseOnce
        }
        set{
            isUseOnce = newValue
            DispatchQueue.main.async {
                //ConfigureCheck
                self.configureIsChecked()
            }
        }
    }
    var isDiscount:Bool = false
    var isCheckPercentageDiscount:Bool {
        get{
            return isDiscount
        }
        set{
            isDiscount = newValue
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    //ConfigureDiscount/Saving
                    self.txtDiscountpercentage.text = ""
                    self.txtPercentageCustomerAmount.text = ""
                    self.txtPercentageWerkulesAmount.text = ""
                    self.txtSavingpercentage.text = ""
                    self.txtDollarCustomerAmount.text = ""
                    self.txtDollarWerkulesAmount.text = ""
                    
                    self.txtDiscountpercentage.keyboardType = .decimalPad
                    
                    self.configureIsCheckedDiscount()
                    self.tableViewAddPromotions.sizeTableviewHeaderFit()
                    self.view.layoutIfNeeded()
                }
                
            }
        }
    }
    var addpromotionparameters:[String:Any] = [:]
    var placeholderLabel : UILabel!
    
    @IBOutlet weak var  stackViewPercentageCustomer:UIStackView!
    @IBOutlet weak var  stackViewPercentageWerkules:UIStackView!
    
    @IBOutlet weak var  stackViewDollarCustomer:UIStackView!
    @IBOutlet weak var  stackViewDollarWerkules:UIStackView!
    @IBOutlet weak var  bottomSpaceFromPercentageContainer:NSLayoutConstraint! // 250 15
    @IBOutlet weak var  bottomSpaceFromDollarContainer:NSLayoutConstraint! // 250 15
    
    @IBOutlet weak var txtPercentageCustomerAmount:UITextField!
    @IBOutlet weak var txtDollarCustomerAmount:UITextField!
    
    @IBOutlet weak var txtPercentageWerkulesAmount:UITextField!
    @IBOutlet weak var txtDollarWerkulesAmount:UITextField!
    
    
    var currentPromotionDetail:Promotion?
    var isForEdit:Bool = false
    var objImagePickerController = UIImagePickerController()
    var imageForCrop: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    // MARK: - USER METHODS
    func setup(){
        
//        self.txtName.setPlaceHolderColor()
//        self.txtDiscountpercentage.setPlaceHolderColor()
//        self.txtSavingpercentage.setPlaceHolderColor()
//        self.txtexpireyDate.setPlaceHolderColor()
//        
//        self.txtPercentageCustomerAmount.setPlaceHolderColor()
//        self.txtDollarCustomerAmount.setPlaceHolderColor()
//        self.txtPercentageWerkulesAmount.setPlaceHolderColor()
//        self.txtDollarWerkulesAmount.setPlaceHolderColor()
        
        if #available(iOS 13.4, *) {
            self.fromDatePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
        }else{
            
        }
    
        self.txtPicturename.isEnabled = false
        self.isCheckUseOnce = true
        self.isCheckPercentageDiscount = true
        self.configureFormDatePicker()
        self.txtDiscountpercentage.keyboardType = .decimalPad
        self.txtDiscountpercentage.delegate = self
        self.txtPercentageCustomerAmount.keyboardType = .decimalPad
        self.txtPercentageCustomerAmount.delegate = self
        
        
        self.txtSavingpercentage.keyboardType = .decimalPad
        self.txtSavingpercentage.delegate = self
        self.txtDollarCustomerAmount.keyboardType = .decimalPad
        self.txtDollarCustomerAmount.delegate = self
        
        
        self.txtName.delegate = self
        self.txtDescription.delegate = self
        
        txtDescription.delegate = self
        txtDescription.textContainer.maximumNumberOfLines = 3
        txtDescription.textContainer.lineBreakMode = .byClipping
        self.txtName.delegate = self
      //  self.txtName.textContainer.maximumNumberOfLines = 1
        self.txtName.textColor = UIColor.black
        placeholderLabel = UILabel()
        placeholderLabel.text = "Write something....."
        placeholderLabel.font = UIFont(name: "Avenir Medium", size: 17)
        placeholderLabel.sizeToFit()
        //txtDescription.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (txtDescription.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !txtDescription.text.isEmpty
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            //self.addpromotionparameters["werkules_fee"] = "\(appDelegate.werkulesfees)"
           // self.txtPercentageWerkulesAmount.text = "\(appDelegate.werkulesfees) %"
          //  self.txtDollarWerkulesAmount.text = "$ \(appDelegate.werkulesfees)"
        }
        if self.isForEdit, let currentPromotion = self.currentPromotionDetail{
            self.lblTitle.text = "Update Promotion"
            self.configureCurrentPromotionDetailOnEdit()
            self.buttonCreate.setTitle("UPDATE", for: .normal)
            self.addpromotionparameters["promotion_id"] = currentPromotion.id
        }else{
            self.lblTitle.text = "Add Promotion"
            self.buttonCreate.setTitle("CREATE", for: .normal)
        }
        
    }
    func configureIsChecked(){
        if self.isCheckUseOnce{
            self.btnUserOncePerCustomer.setImage(UIImage.init(named: "select"), for: .normal)
        }else {
            self.btnUserOncePerCustomer.setImage(UIImage.init(named: "unselect"), for: .normal)
        }
    }
    func presentCameraAndPhotosSelector(){
          //PresentMedia Selector
          let actionSheetController = UIAlertController.init(title: "", message: "Promotion", preferredStyle: .actionSheet)
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
    func configureIsCheckedDiscount(){
        if self.isCheckPercentageDiscount{
            self.btnDiscountpercentage.setImage(UIImage.init(named: "box_selected"), for: .normal)
            self.btnSavingpercentage.setImage(UIImage.init(named: "box_unselected"), for: .normal)
            self.lblDiscountpercentage.textColor = UIColor.init(hex: "248483")
            self.lblDiscountpercentageTotal.textColor = UIColor.init(hex: "248483")
            self.lblSavingpercentage.textColor = UIColor.init(hex: "#AAAAAA")
            self.lblSavingpercentageTotal.textColor = UIColor.init(hex: "#AAAAAA")
            
            self.txtDiscountpercentage.isEnabled = true
            self.txtSavingpercentage.isEnabled = false
            self.txtSavingpercentage.text = ""
            
            self.stackViewPercentageCustomer.isHidden = false
            self.stackViewPercentageWerkules.isHidden = false
            self.bottomSpaceFromPercentageContainer.constant = 250.0
           self.bottomSpaceFromDollarContainer.constant = 15.0
            
            self.stackViewDollarCustomer.isHidden = true
            self.stackViewDollarWerkules.isHidden = true
            
            self.stackViewCustomerAmountDiscount.isHidden = true
            self.stackViewCustomerPercentageDiscount.isHidden = false
        }else{
            self.stackViewCustomerAmountDiscount.isHidden = false
            self.stackViewCustomerPercentageDiscount.isHidden = true
            
            self.stackViewPercentageCustomer.isHidden = true
            self.stackViewPercentageWerkules.isHidden = true
            self.bottomSpaceFromPercentageContainer.constant = 15.0
           self.bottomSpaceFromDollarContainer.constant = 250.0
            self.stackViewDollarCustomer.isHidden = false
            self.stackViewDollarWerkules.isHidden = false
            
            
            self.btnDiscountpercentage.setImage(UIImage.init(named: "box_unselected"), for: .normal)
            self.btnSavingpercentage.setImage(UIImage.init(named: "box_selected"), for: .normal)
            self.lblDiscountpercentage.textColor = UIColor.init(hex: "#AAAAAA")
            self.lblDiscountpercentageTotal.textColor = UIColor.init(hex: "#AAAAAA")
            self.lblSavingpercentage.textColor = UIColor.init(hex: "#248483")
            self.lblSavingpercentageTotal.textColor = UIColor.init(hex: "#248483")
            self.txtDiscountpercentage.isEnabled = false
            self.txtDiscountpercentage.text = ""
            self.txtSavingpercentage.isEnabled = true
        }
    }
    func configureFormDatePicker(){
            
            self.fromDatePickerToolbar.sizeToFit()
            self.fromDatePickerToolbar.layer.borderColor = UIColor.clear.cgColor
            self.fromDatePickerToolbar.layer.borderWidth = 1.0
            self.fromDatePickerToolbar.clipsToBounds = true
            self.fromDatePickerToolbar.backgroundColor = UIColor.white
            self.fromDatePicker.datePickerMode = .date
            self.fromDatePicker.minimumDate = Date()
            
            let doneButton = UIBarButtonItem(title:"done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddPromotionViewController.doneFormDatePicker))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            
            let title = UILabel.init()
            title.attributedText = NSAttributedString.init(string: "Expire Date", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
            
            title.sizeToFit()
            let cancelButton = UIBarButtonItem(title:"Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddPromotionViewController.cancelFormDatePicker))
            self.fromDatePickerToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
            
            
            self.txtexpireyDate.inputView = self.fromDatePicker
            self.txtexpireyDate.inputAccessoryView = self.fromDatePickerToolbar
        }
        @objc func doneFormDatePicker(){
            let date =  self.fromDatePicker.date
                self.addpromotionparameters["expiry_date"] = date.dateddMMyyy
                DispatchQueue.main.async {
                    self.txtexpireyDate.text = date.ddMMyyyy
                    self.txtexpireyDate.resignFirstResponder()
                }
            //dismiss date picker dialog
            DispatchQueue.main.async {
                self.view.endEditing(true)
            }
        }
        @objc func cancelFormDatePicker(){
            DispatchQueue.main.async {
                self.view.endEditing(true)
            }
        }
    func configureCurrentPromotionDetailOnEdit(){
        if let currentpromotion = self.currentPromotionDetail{
            self.txtName.text  = "\(currentpromotion.name)"

            
            self.placeholderLabel.isHidden = true
            self.txtDescription.text  = "\(currentpromotion.promotionDescription)"
            self.txtDescription.isScrollEnabled = false
            
            if currentpromotion.type == "percentage"{
                self.isCheckPercentageDiscount = true
            }else if currentpromotion.type == "amount"{
                self.isCheckPercentageDiscount = false
            }else{
                self.isCheckPercentageDiscount = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.isCheckPercentageDiscount{
                           self.txtDiscountpercentage.text = "\(currentpromotion.amount) %"
                           self.txtPercentageCustomerAmount.text = "\(currentpromotion.savingprice) %"
                           self.txtPercentageWerkulesAmount.text = "\(currentpromotion.werkulesFees) %"//"\(self.getWerkulesPercentage(totalAmount: "\(updatedtext)")) %"

                       }else{
                        self.txtSavingpercentage.text = "\(currentpromotion.amount)".add2DecimalString
                        self.txtDollarCustomerAmount.text = "\(currentpromotion.savingprice)".add2DecimalString
                        self.txtDollarWerkulesAmount.text = "$ \(currentpromotion.werkulesFees)"
                       }
            }
       
            
            DispatchQueue.global().async {
                do {
                    if let imgURL = URL.init(string: "\(currentpromotion.image)"){
                        let imagedata = try Data(contentsOf:imgURL)
                        self.promotionImageData = imagedata
                        DispatchQueue.main.async {
                            self.txtPicturename.text = imgURL.lastPathComponent
                        }
                    }
                  
                } catch let error {
                  print(error)
                }
            }
            
            let dateformatter = DateFormatter()
                      dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                      let date = dateformatter.date(from: currentpromotion.expiryDate)
            self.txtexpireyDate.text = date?.ddMMyyyy ?? ""
            
            if let value = currentpromotion.useOnce.bool{
                if value{
                    self.isCheckUseOnce = true
                } else {
                    self.isCheckUseOnce = false
                }
            }
            
        }
        
    }
    func presentPercentageDiscountHelp(){
        let alert = UIAlertController(title: "Percentage Discount Total Help", message: "Enter the Percentage Discount Total you want to offer here, and the Customer and Werkules amounts will be displayed. If you want to offer a specific amount to your customers, enter it directly in the Customer Amount field", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                    }))
                    alert.view.tintColor = UIColor.init(hex: "#38B5A3")

                    self.present(alert, animated: true, completion: nil)
    }
    func presentPercentageCustomerAmountHelp(){
        let alert = UIAlertController(title: "Percentage Discount Amount Help", message: "Enter the Percentage Discount you want to offer your Customers here, and the Discount Percentage Total and Werkules amounts will be displayed", preferredStyle: .alert)
                          
                          alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                          }))
                          alert.view.tintColor = UIColor.init(hex: "#38B5A3")

                          self.present(alert, animated: true, completion: nil)
    }
    func presentDollarDiscountHelp(){
             let alert = UIAlertController(title: "Dollar Discount Amount Help", message: "Enter the Dollar Discount Total you want to offer here, and the Customer Discount and Werkules Amounts will be displayed. If you want to offer a specific amount to your customers, enter it directly in the Customer Discount field", preferredStyle: .alert)
                       
                       alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                       }))
                       alert.view.tintColor = UIColor.init(hex: "#38B5A3")

                       self.present(alert, animated: true, completion: nil)
       }
       func presentDollarCustomerAmountHelp(){
           let alert = UIAlertController(title: "Dollar Discount Amount Help", message: "Enter the Dollar Discount you want to offer your Customers here, and Dollar Discount Total and Werkules amounts will be displayed", preferredStyle: .alert)
                             
                             alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                             }))
                             alert.view.tintColor = UIColor.init(hex: "#38B5A3")

                             self.present(alert, animated: true, completion: nil)
       }
    
    // MARK: - SELECTOR METHODS
    @IBAction func buttonAddpromotionInfoSelector(sender:UIButton){
        let alert = UIAlertController(title: "Werkules Promotion Fee Percentage", message: "10% of every promotion is distributed to Werkules users as an incentive to market your company. The promotion entry and management screen will show you the total promotion amount saved by the purchaser, and how much will be distributed to those marketing your company", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            
        }))
        
        alert.view.tintColor = UIColor.init(hex: "#38B5A3")
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func buttonDollarAddpromotionInfoSelector(sender:UIButton){
        let alert = UIAlertController(title: "Werkules Promotion Fee Percentage", message: "10% of every promotion is distributed to Werkules users as an incentive to market your company. The promotion entry and management screen will show you the total promotion amount saved by the purchaser, and how much will be distributed to those marketing your company", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            
        }))
        
        alert.view.tintColor = UIColor.init(hex: "#38B5A3")
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonDiscountPercentageSelector(sender:UIButton){
        self.isCheckPercentageDiscount = true
    }
    @IBAction func buttonDiscountPercentageHelpSelector(sender:UIButton){
        self.presentPercentageDiscountHelp()
    }
    @IBAction func buttonDiscountPercentageAmountHelpSelector(sender:UIButton){
        self.presentPercentageCustomerAmountHelp()
       }
    @IBAction func buttonDiscountDollarHelpSelector(sender:UIButton){
          self.presentDollarDiscountHelp()
    }
    @IBAction func buttonDiscountDollarAmountHelpSelector(sender:UIButton){
            self.presentDollarCustomerAmountHelp()
    }
    @IBAction func buttonSavingPercentageSelector(sender:UIButton){
        self.isCheckPercentageDiscount = false
    }
    @IBAction func buttonImageuploadSelector(sender:UIButton){
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
                          
                        DispatchQueue.main.async {
                            if let currentUser = UserDetail.getUserFromUserDefault(),let currentprovider = currentUser.businessDetail{
                                self.txtPicturename.text = "promotional-image-provider-\(currentprovider.id)"

                               }
                        }
                          self.promotionImageData = resizedImage
                          
                          
                      }
                      picker.dismiss(animated: true, completion: nil)
                  }
                  present(picker, animated: true, completion: nil)*/
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
    
    @IBAction func buttonDateSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.txtexpireyDate.becomeFirstResponder()
        }
    }
    @IBAction func buttonUseOnceSelector(sender:UIButton){
        self.isCheckUseOnce = !self.isCheckUseOnce
    }
    @IBAction func buttonCreateSelector(sender:UIButton){
        if self.isValidData(){
            self.presentPromotionAlertViewController()
            //self.callAddPromotionAPIRequest()
        }
    }
    func presentPromotionAlertViewController(){
        if let objStory = self.storyboard?.instantiateViewController(withIdentifier: "PromotionCreateEditAlertViewController") as? PromotionCreateEditAlertViewController{
                 objStory.modalPresentationStyle = .overFullScreen
                objStory.delegate = self
                objStory.addEditPromotionParameters = self.addpromotionparameters
                objStory.promotiondata = self.promotionImageData
                 self.present(objStory, animated: true, completion: nil)
             }
    }
    // MARK: - API Request Methods
    func callAddPromotionAPIRequest(){
        print(self.addpromotionparameters)
        APIRequestClient.shared.uploadpromotionImage(requestType: .POST, queryString: isForEdit ? kUpdatePromotion:kAddPromotion , parameter: self.addpromotionparameters as [String:AnyObject], imageData:self.promotionImageData! , isHudeShow: true, success: { (responseSuccess) in
                   print(responseSuccess)
                    DispatchQueue.main.async {
                        ExternalClass.HideProgress()
                    }
                    if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                            DispatchQueue.main.async {
                                if self.isForEdit{
                                    SAAlertBar.show(.error, message:"Promotion updated successfully.".localizedLowercase)
                                }else{
                                    SAAlertBar.show(.error, message:"Promotion added successfully.".localizedLowercase)
                                }
                                 
                                self.navigationController?.popViewController(animated: true)
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
                            SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                        }
                    }
                }
        }
    
   func isValidData()->Bool{
      
    guard let currentUser = UserDetail.getUserFromUserDefault(),let currentprovider = currentUser.businessDetail else {
               return false
    }
    self.addpromotionparameters["provider_id"] = "\(currentprovider.id)"

    guard let name = self.txtName.text?.trimmingCharacters(in: .whitespacesAndNewlines),name.count > 0 else{
               SAAlertBar.show(.error, message:"Please enter promotion name".localizedLowercase)
               return false
           }
    self.addpromotionparameters["name"] = "\(name)"

    guard let description = self.txtDescription.text?.trimmingCharacters(in: .whitespacesAndNewlines),description.count > 0 else{
                  SAAlertBar.show(.error, message:"Please enter promotion description".localizedLowercase)
                  return false
              }
    self.addpromotionparameters["description"] = "\(description)"
    
    // discount_type = discount|fix_saving|flat_amount [ must be any of this ]
    if self.isCheckPercentageDiscount{
        guard let discount = self.txtDiscountpercentage.text?.trimmingCharacters(in: .whitespacesAndNewlines),discount.count > 0 else{
                      SAAlertBar.show(.error, message:"Please enter promotion percentage".localizedLowercase)
                      return false
                  }
        let percentageDiscountTotal = "\(discount)".replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        
         self.addpromotionparameters["discount_value"] = percentageDiscountTotal
        self.addpromotionparameters["werkules_fee"] = self.getWerkulesPercentage(totalAmount: percentageDiscountTotal)
           self.addpromotionparameters["discount_type"] = "percentage"
        
        guard let customerdiscount = self.txtPercentageCustomerAmount.text?.trimmingCharacters(in: .whitespacesAndNewlines),customerdiscount.count > 0 else{
                            SAAlertBar.show(.error, message:"Please enter customer promotion percentage".localizedLowercase)
                            return false
                        }
        self.addpromotionparameters["saving_price"]  = "\(customerdiscount)".replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespacesAndNewlines)

    }else{
        guard let saving = self.txtSavingpercentage.text?.trimmingCharacters(in: .whitespacesAndNewlines),saving.count > 0 else{
                             SAAlertBar.show(.error, message:"Please enter promotion dollar".localizedLowercase)
                             return false
                         }
        let dollarTotal = "\(saving)".replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.addpromotionparameters["discount_value"] = "\(dollarTotal)"
        self.addpromotionparameters["werkules_fee"] = self.getWerkulesPercentage(totalAmount: dollarTotal)
        self.addpromotionparameters["discount_type"] = "amount"
        self.addpromotionparameters["saving_price"]  = "\(self.getPercentageCustomerAmountFrom(percentageAmount: dollarTotal))"
    }
    
    guard let _ = self.promotionImageData else{
         SAAlertBar.show(.error, message:"Please select promotion image".localizedLowercase)
        return false
    }
    
    guard let expiry_date = self.txtexpireyDate.text?.trimmingCharacters(in: .whitespacesAndNewlines),expiry_date.count > 0 else{
                     SAAlertBar.show(.error, message:"Please enter promotion expiry date".localizedLowercase)
                     return false
                 }
    let date =  self.fromDatePicker.date
    self.addpromotionparameters["expiry_date"] = date.dateddMMyyy
    
    if self.isCheckUseOnce{
        self.addpromotionparameters["use_once"] = "yes"
    }else{
        self.addpromotionparameters["use_once"] = "no"
    }
     
    
          return true
      }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension AddPromotionViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.dismiss(animated: true, completion: nil)
        let resizedImage = self.resize(image)
        DispatchQueue.main.async {
         if let currentUser = UserDetail.getUserFromUserDefault(),let currentprovider = currentUser.businessDetail{
             self.txtPicturename.text = "promotional-image-provider-\(currentprovider.id)"

            }
        }
        self.promotionImageData = resizedImage
//                   self.btnUserProfilePic.setBackgroundImage(UIImage.init(data: resizedImage), for: .normal)
//                   self.customerProfileImageData = resizedImage
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
extension AddPromotionViewController:PromotionCreateEditProtocol{
    func buttonYesSelector(addUpdatePromotionParameters: [String : Any]) {
        self.addpromotionparameters = addUpdatePromotionParameters
        self.callAddPromotionAPIRequest()
    }
        
    
}

extension AddPromotionViewController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
          let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
          
//          guard !typpedString.isContainWhiteSpace() else{
//              return false
//          }
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
        
        
          return true
      }
      func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtDiscountpercentage{
              DispatchQueue.main.async {
                 if let text = self.txtDiscountpercentage.text{
                    var updatedtext = text.replacingOccurrences(of: "%", with: "")
                    updatedtext = updatedtext.trimmingCharacters(in: .whitespaces)
                    self.txtDiscountpercentage.text = "\(updatedtext)"
                  }
              }
        }else if textField == self.txtPercentageCustomerAmount{
            DispatchQueue.main.async {
                            if let text = self.txtPercentageCustomerAmount.text{
                               var updatedtext = text.replacingOccurrences(of: "%", with: "")
                               updatedtext = updatedtext.trimmingCharacters(in: .whitespaces)
                               self.txtPercentageCustomerAmount.text = "\(updatedtext)"
                             }
                         }
        }else if textField == self.txtSavingpercentage{
            DispatchQueue.main.async {
              if let text = self.txtSavingpercentage.text{
                  var updatedtext =  text.replacingOccurrences(of: "$", with: "")
                     updatedtext = updatedtext.trimmingCharacters(in: .whitespaces)
                  self.txtSavingpercentage.text = "\(updatedtext)"
              }
            }
        }else if textField == self.txtDollarCustomerAmount{
            DispatchQueue.main.async {
              if let text = self.txtDollarCustomerAmount.text{
                  var updatedtext =  text.replacingOccurrences(of: "$", with: "")
                     updatedtext = updatedtext.trimmingCharacters(in: .whitespaces)
                  self.txtDollarCustomerAmount.text = "\(updatedtext)"
              }
            }
        }
          return true
      }
      func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
          if textField == self.txtDiscountpercentage{
                DispatchQueue.main.async {
                    
                }
          }else if textField == self.txtSavingpercentage{
              DispatchQueue.main.async {
                
              }
          }
          return true
      }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtDiscountpercentage{
                     DispatchQueue.main.async {
                        if let text = self.txtDiscountpercentage.text,text.count > 0{
                            let updatedtext = text.replacingOccurrences(of: "%", with: "")
                            self.txtDiscountpercentage.text = "\(updatedtext) %"
                            self.txtPercentageCustomerAmount.text = "\(self.getPercentageCustomerAmountFrom(percentageAmount: updatedtext)) %"
                            self.txtPercentageWerkulesAmount.text = "\(self.getWerkulesPercentage(totalAmount: "\(updatedtext)")) %"
                            
                        }
                        
                     }
        }else if textField == self.txtPercentageCustomerAmount{
            
            DispatchQueue.main.async {
                                   if let text = self.txtPercentageCustomerAmount.text,text.count > 0{
                                       let updatedtext = text.replacingOccurrences(of: "%", with: "")
                                       self.txtPercentageCustomerAmount.text = "\(updatedtext) %"
                                       self.txtDiscountpercentage.text = "\(self.getPercentageAmountFrom(customerAmount: updatedtext)) %"
                                        let totalAmount = (self.getPercentageAmountFrom(customerAmount: updatedtext))
                                        self.txtPercentageWerkulesAmount.text = "\(self.getWerkulesPercentage(totalAmount: "\(totalAmount)")) %"
                                        
                                        
                                   }
                                   
                                }
            
            
               }else if textField == self.txtSavingpercentage{ //
                   DispatchQueue.main.async {
                    if let text = self.txtSavingpercentage.text,text.count > 0{
                        let updatedtext =  text.replacingOccurrences(of: "$", with: "")
                        self.txtSavingpercentage.text = "$\(updatedtext)"
                        self.txtDollarCustomerAmount.text = "$\(self.getPercentageCustomerAmountFrom(percentageAmount: updatedtext))"
                        self.txtDollarWerkulesAmount.text = "$\(self.getWerkulesPercentage(totalAmount: updatedtext))"
                    }
                   }
        }else if textField == self.txtDollarCustomerAmount{
            DispatchQueue.main.async {
                               if let text = self.txtDollarCustomerAmount.text,text.count > 0{
                                   let updatedtext =  text.replacingOccurrences(of: "$", with: "")
                                   self.txtDollarCustomerAmount.text = "$\(updatedtext)"
                                   self.txtSavingpercentage.text = "$\(self.getPercentageAmountFrom(customerAmount: updatedtext))"
                                   let totalAmount = self.getPercentageAmountFrom(customerAmount: updatedtext)
                                   self.txtDollarWerkulesAmount.text = "$\(self.getWerkulesPercentage(totalAmount: totalAmount ))"
                               }
                              }
        }
    }
      func textFieldShouldClear(_ textField: UITextField) -> Bool {
          
          return true
      }
      func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
    }
    func getWerkulesPercentage(totalAmount:String)->String{
        var werkulesfees = ""
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if appDelegate.werkulesfees.count > 0{
                if let floatCustomerAmnt = Float(totalAmount),let feespercentage = Float(appDelegate.werkulesfees){
                               //werkules percentage
                               let werkules = feespercentage / 100.0
                               let valuewerkules = floatCustomerAmnt * werkules
                                werkulesfees = String(format: "%.2f", valuewerkules)
                           }
            }
        }
        return werkulesfees
        
    }
    func getWerkulesAmount(totalAmount:String)->String{
        var werkulesfees = ""
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                 if appDelegate.werkulesfees.count > 0{
                    if let total = Float(totalAmount),let feespercentage = Float(appDelegate.werkulesfees){
                        let finalvalue = total - feespercentage
                        werkulesfees = String(format: "%.2f", finalvalue)
                    }
            }
        }
        return werkulesfees
    }
    func getPercentageCustomerAmountFrom(percentageAmount:String,isForPercentage:Bool = false)->String{
        var customerAmount:String = ""
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if appDelegate.werkulesfees.count > 0{
                if let floatPer = Float(percentageAmount),let feespercentage = Float(appDelegate.werkulesfees){
                    let value = floatPer * feespercentage
                    let werkulesvalue = value/100.0
                    let finalvalue = floatPer - werkulesvalue
                    if isForPercentage{
                        if let valueInt = Int(finalvalue) as? Int{
                            customerAmount = "\(valueInt)"
                        }else{
                            customerAmount = "\(finalvalue)"
                        }
                        
                    }else{
                        customerAmount = String(format: "%.2f", finalvalue)
                    }
                    
                }
            }
        }
        return customerAmount
    }
    func getPercentageAmountFrom(customerAmount:String)->String{
        var totalPercentageAmount:String = ""
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
           if appDelegate.werkulesfees.count > 0{
               if let floatCustomerAmnt = Float(customerAmount),let feespercentage = Float(appDelegate.werkulesfees){
                    let p = 100.0 - feespercentage
                    let decimalPercentage = p/100.0
                    let value = floatCustomerAmnt / decimalPercentage
                    totalPercentageAmount = String(format: "%.2f", value)
                    //werkules percentage
                    let werkules = feespercentage / 100.0
                    let valuewerkules = floatCustomerAmnt / werkules
                
                }
           }
        }
        return totalPercentageAmount
    }
    
}
extension AddPromotionViewController:UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        //placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
extension Date {
    var day:Int {return Calendar.current.component(.day, from:self)}
    var month:Int {return Calendar.current.component(.month, from:self)}
    var year:Int {return Calendar.current.component(.year, from:self)}
    var mmddyyyy:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: self)
    }
    var ddMMyyyy:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: self)
    }
    var dateddMMyyy:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: self)
    }
    
}
extension UITableView{
    func sizeTableviewHeaderFit(){
           if let headerView =  self.tableHeaderView {
               headerView.setNeedsLayout()
               headerView.layoutIfNeeded()
               print(headerView.frame)
               print(headerView.bounds)
               
               let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
               var frame = headerView.frame
               frame.size.height = height
               headerView.frame = frame
               self.tableHeaderView = headerView
           }
       }
}
