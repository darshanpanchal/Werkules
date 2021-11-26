//
//  SendOfferViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 19/02/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import YPImagePicker
import MobileCoreServices
import CropViewController
import UniformTypeIdentifiers

class SendOfferViewController: UIViewController {

    var ischecked = false
    var isPromotionChecked:Bool{
        get{
            return ischecked
        }
        set{
            self.ischecked = newValue
            //ConfigureisChecked
            DispatchQueue.main.async {
                self.configureAddPromotionCheckedUnChecked()
            }
            
        }
    }
    var objOfferDetail:OfferDetail?
    var attachmentdata:Data?
    var attachmentUploaded:[String:Any] = [:]
    var currentPromotionDetail:Promotion?
    
    
    
    @IBOutlet weak var lblPromotion:UILabel!
    @IBOutlet weak var lblJOBTitle:UILabel!
    @IBOutlet weak var txtJOBOfferPrice:UITextField!
    @IBOutlet weak var txtAttachmentName:UITextField!
    @IBOutlet weak var buttonAttachment:UIButton!
    
    @IBOutlet weak var txtDescription:UITextView!
    
    @IBOutlet weak var viewPromotion:UIView!
    @IBOutlet weak var buttonAddPromotionTick:UIButton!
    @IBOutlet weak var buttonSubmit:UIButton!
    
    @IBOutlet weak var lblPromotionTitle:UILabel!
    @IBOutlet weak var lblPromotionDetail:UILabel!
    @IBOutlet weak var btnPromotionDetail:UIButton!
     
    @IBOutlet weak var tableviewSendOffer:UITableView!
    
    
    var attributesBold: [NSAttributedString.Key: Any] = [
    .font: UIFont.init(name: "Avenir Heavy", size: 14.0)!,
    .foregroundColor: UIColor.init(hex: "#38B5A3"),
       ]
    var attributesNormal: [NSAttributedString.Key: Any] = [
       .font:  UIFont.init(name: "Avenir Medium", size: 14.0)!,
       .foregroundColor: UIColor.init(hex: "#707070"),
       ]
    
    var placeholderLabel : UILabel!
    
    var addBusinessOfferParameters:[String:Any] = [:]
    var objImagePickerController = UIImagePickerController()
      var imageForCrop: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        // Do any additional setup after loading the view.
        if let offer = self.objOfferDetail{
            self.lblJOBTitle.text = offer.jobDetail?.title ?? ""
          
            
        }
        self.txtJOBOfferPrice.delegate = self
        
    }
     
    func setup(){
        self.view.layoutIfNeeded()
        txtDescription.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Additional notes or information for the customer"
        placeholderLabel.font = UIFont(name: "Avenir Medium", size: 16)
        placeholderLabel.numberOfLines = 0
        txtDescription.addSubview(placeholderLabel)
        self.txtJOBOfferPrice.keyboardType = .decimalPad

        placeholderLabel.frame = CGRect.init(origin: CGPoint(x: 3.0, y: -10.0), size: CGSize.init(width: self.txtDescription.bounds.width - 10.0, height: 80.0))

        //placeholderLabel.sizeToFit()
        //placeholderLabel.frame.origin = CGPoint(x: 5, y: (txtDescription.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = false//!txtDescription.text.isEmpty
        
        self.tableviewSendOffer.tableFooterView = UIView()
        
         let mutableString = NSMutableAttributedString.init(string: "Include promotion ", attributes: self.attributesNormal)
         let mutableString1 = NSMutableAttributedString.init(string: "(Add New Promotion)", attributes: self.attributesBold)
         mutableString.append(mutableString1)
        self.lblPromotion.attributedText = mutableString
        self.isPromotionChecked = false
        
        
        let underlineSeeDetail = NSAttributedString(string: "See Details",
                                                                      attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnPromotionDetail.setAttributedTitle(underlineSeeDetail, for: .normal)
        //self.btnPromotionDetail.titleLabel?.attributedText = underlineSeeDetail
        
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tappedOnLabel(_:)))
        tapGesture.numberOfTouchesRequired = 1
        self.lblPromotion.addGestureRecognizer(tapGesture)
    }
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = lblPromotion.text else { return }
        let numberRange = (text as NSString).range(of: "Include promotion ")
        let emailRange = (text as NSString).range(of: "(Add New Promotion)")
        if gesture.didTapAttributedTextInLabel(label: self.lblPromotion, inRange: numberRange) {
            print("number tapped")
            self.pushToListofPromotionViewController()
        } else if gesture.didTapAttributedTextInLabel(label: self.lblPromotion, inRange: emailRange) {
            self.pushToAddPromotionDetailViewController()
        }
    }
    func configureAddPromotionCheckedUnChecked(){
        if self.isPromotionChecked{
            //self.viewPromotion.isHidden = false
           // self.heightOfPromotionContainer.constant = 120
            //self.buttonAddPromotionTick.setImage( UIImage(named:"checkBox"), for: .normal)
            //push to promotion list
            self.pushToListofPromotionViewController()
        }else{
            self.viewPromotion.isHidden = true
           // self.heightOfPromotionContainer.constant = 30
            self.buttonAddPromotionTick.setImage( UIImage(named:"checkBoxEmpty"), for: .normal)
        }
    }
    func isValidOfferData()->Bool{
        if let jobdetail = self.objOfferDetail?.jobDetail{
            self.addBusinessOfferParameters["job_id"] = "\(jobdetail.jobID)"
        }
        
        guard let offerPrice = self.txtJOBOfferPrice.text?.trimmingCharacters(in: .whitespacesAndNewlines),offerPrice.count > 0 else{
                  SAAlertBar.show(.error, message:"Please enter Offer Price".localizedLowercase)
                  return false
              }
        let dollarTotal = "\(offerPrice)".replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespacesAndNewlines)

        self.addBusinessOfferParameters["price"] = "\(dollarTotal)"
        if let _ = self.attachmentdata{
            self.addBusinessOfferParameters["attachment"] = [self.attachmentUploaded]
        }
        /*
        guard let _ = self.attachmentdata else{
              SAAlertBar.show(.error, message:"Please enter Offer attachment".localizedLowercase)
            return false
        } */
        if let strNotes = self.txtDescription.text?.trimmingCharacters(in: .whitespacesAndNewlines),strNotes.count > 0 {
            self.addBusinessOfferParameters["notes"] = "\(strNotes)"
        }
        /*guard let strNotes = self.txtDescription.text?.trimmingCharacters(in: .whitespacesAndNewlines),strNotes.count > 0 else{
                         SAAlertBar.show(.error, message:"Please enter Offer notes".localizedLowercase)
                         return false
                     }*/
        
        if let _ = self.currentPromotionDetail{
            self.addBusinessOfferParameters["promotion_id"] = "\(self.currentPromotionDetail!.id)"
        }
        
        return true
    }
    // MARK: - Selector Methods
    @IBAction func buttonbackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonAddAttachmentSelector(sender:UIButton){
        self.presentDocumentAndImagePickerActionSheet()
    }
    @IBAction func buttonAddPromotionChecked(sender:UIButton){
        self.isPromotionChecked = !self.isPromotionChecked
    }
    @IBAction func buttonSubmitSelector(sender:UIButton){
        if self.isValidOfferData(){
            self.sendOfferAPIRequest()
        }
    }
    @IBAction func buttonPromotionalSeeDetailSelector(sender:UIButton){
        if let objPromotion = self.currentPromotionDetail{
            if let objStory = self.storyboard?.instantiateViewController(withIdentifier: "PromotionAlertViewController") as? PromotionAlertViewController{
                           objStory.modalPresentationStyle = .overFullScreen
                           objStory.objPromotion = objPromotion
                           self.present(objStory, animated: true, completion: nil)
                       }
        }
    }
    @IBAction func buttonAddNewPromotionSelector(sender:UIButton){
            self.pushToAddPromotionDetailViewController()
       }
        
    func presentDocumentAndImagePickerActionSheet(){
             //PresentMedia Selector
             let actionSheetController = UIAlertController.init(title: "", message: "Profile", preferredStyle: .actionSheet)
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
            let galleryActionButton = UIAlertAction(title: "Document", style: .default)
                      { _ in
                       
                       self.presentDocumentPickerForAttachment()
                       
                      }
             galleryActionButton.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
             actionSheetController.addAction(galleryActionButton)
             self.present(actionSheetController, animated: true, completion: nil)
        /*
        let actionSheet: UIAlertController = UIAlertController(title: "Select Attachment", message: "", preferredStyle: .actionSheet)
               
               let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                   print("Cancel")
               }
               actionSheet.addAction(cancelActionButton)
               
               let cameraActionButton = UIAlertAction(title: "Image", style: .default)
               { _ in
                   
                self.presentImagePickerForLicenceUplaod()
               }
               actionSheet.addAction(cameraActionButton)
               
               let galleryActionButton = UIAlertAction(title: "Document", style: .default)
               { _ in
                
                self.presentDocumentPickerForAttachment()
                
               }
               actionSheet.addAction(galleryActionButton)
               
               self.present(actionSheet, animated: true, completion: nil)*/
    }
    func presentDocumentPickerForAttachment(){
        let types: [UTType] = [UTType.pdf, UTType.text, UTType.rtf, UTType.spreadsheet]
        let importMenu = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)//UIDocumentPickerViewController(documentTypes: types as [String], in: .import)

        importMenu.allowsMultipleSelection = false
        

        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        importMenu.accessibilityValue = "1"
        self.present(importMenu, animated: true)
    }
    func presentImagePickerController(){
            self.view.endEditing(true)
            self.objImagePickerController.modalPresentationStyle = .fullScreen
            self.present(self.objImagePickerController, animated: true, completion: nil)
           
        }
    func presentImagePickerForLicenceUplaod(){
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
                
                self.attachmentdata = resizedImage
                self.uploadAttachmentAPIRequest(fileData: resizedImage)
                   
               
             }
             picker.dismiss(animated: true, completion: nil)
         }
        self.present(picker, animated: true, completion: nil)
        
        
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
    // MARK: - API
    func sendOfferAPIRequest(){
        
        print(self.addBusinessOfferParameters)
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kSendOffer , parameter: self.addBusinessOfferParameters as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                                      if let success = responseSuccess as? [String:Any],let arraySuccess = success["success_data"] as? [String]{
                                        DispatchQueue.main.async {
                                            var customerName = ""
                                            if let offer = self.objOfferDetail,let customer = offer.customerDetail{
                                                customerName = "\(customer.firstname)"
                                            }
                                            self.presentSendOfferSuccessPOPUP(strMessage: "\(arraySuccess.first ?? "")", customerName: customerName)
                                                      // SAAlertBar.show(.error, message:"\(arraySuccess.first ?? "")".localizedLowercase)
                                                    //self.navigationController?.popViewController(animated: true)
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
   
    func uploadAttachmentAPIRequest(fileData:Data){
      
        var businessLogoUploadParameters :[String:Any] = [:]
        
        businessLogoUploadParameters["page_name"] = "provider-sendoffer"
        
        APIRequestClient.shared.uploadImage(requestType: .POST, queryString:kProviderFileUpload , parameter: businessLogoUploadParameters as [String:AnyObject], imageData:fileData ,isFileUpload : true, isHudeShow: true, success: { (responseSuccess) in
            DispatchQueue.main.async {
                ExternalClass.HideProgress()
            }
            if let success = responseSuccess as? [String:Any],let fileInfo = success["success_data"] as? [String:Any]{
                
                self.attachmentUploaded = fileInfo
                if let fileName = fileInfo["file_name"]{
                    DispatchQueue.main.async {
                        self.txtAttachmentName.text = "\(fileName)"
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushToAddPromotionDetailViewController(){
        if let addPromotionViewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "AddPromotionViewController") as? AddPromotionViewController{
            self.navigationController?.pushViewController(addPromotionViewcontroller, animated: true)
        }
    }
    func pushToListofPromotionViewController(){
        
        
        if let addPromotionViewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "PromotionListViewController") as? PromotionListViewController{
            guard let currentUser = UserDetail.getUserFromUserDefault() else {
                
                return
            }
            addPromotionViewcontroller.delegate = self
            addPromotionViewcontroller.providerId = currentUser.businessDetail?.id ?? ""
            addPromotionViewcontroller.isForProviderSide = true
            addPromotionViewcontroller.isForPromotionSelection = true
                   self.navigationController?.pushViewController(addPromotionViewcontroller, animated: true)
               }
    }
    func presentSendOfferSuccessPOPUP(strMessage:String,customerName:String){
        print(strMessage)
        print(customerName)
           if let sendOfferPopup = UIStoryboard.main.instantiateViewController(withIdentifier: "SendOfferSuccessPopupViewController") as? SendOfferSuccessPopupViewController{
               sendOfferPopup.modalPresentationStyle = .overFullScreen
                   sendOfferPopup.delegate = self
            sendOfferPopup.strSuccessMessage = strMessage
            sendOfferPopup.customerName = customerName
                self.present(sendOfferPopup, animated: true, completion: nil)
               }
           
       }

}
extension SendOfferViewController:SendOfferSuccessPopupDeledate{
    func buttonHomeselector() {
        self.navigationController?.popToRootViewController(animated: true)
        if let objTabView = self.navigationController?.tabBarController{
                            if let objHomeNavigation = objTabView.viewControllers?.first as? UINavigationController,let objHome = objHomeNavigation.viewControllers.first as? ProviderHomeViewController{
                                objTabView.selectedIndex = 0
                            }
               }
    }
}
extension SendOfferViewController:PromotionListDelegate {
    func didSelectPromotionWith(promotiondetail: Promotion) {
        DispatchQueue.main.async {
            self.currentPromotionDetail = promotiondetail
            self.lblPromotionTitle.text = promotiondetail.name
             let amount = promotiondetail.savingprice
            self.lblPromotionDetail.text = "\(amount)% off your total bill"
               let promotionType = promotiondetail.type
               if "\(promotionType)" == "percentage"{
                   self.lblPromotionDetail.text = "\(amount)% off your total bill"
               }else{
                   self.lblPromotionDetail.text = "\(CurrencyFormate.Currency(value: Double(amount) ?? 0)) off your total bill"
               }
                                       
                                   
            //self.lblPromotionDetail.text = promotiondetail.promotionDescription
            self.viewPromotion.isHidden = false
            self.buttonAddPromotionTick.setImage( UIImage(named:"checkBox"), for: .normal)
            
        }
    }
}
extension SendOfferViewController:UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
           print(urls)
            if urls.count > 0,let fileURL = urls.first{
                if FileManager.default.fileExists(atPath: fileURL.path){
                    print("yes")
                    if let data = self.loadFileFromLocalPath(fileURL.path){
                        self.attachmentdata = data
                        self.uploadAttachmentAPIRequest(fileData: data)
                        /*
                        if controller.accessibilityValue == "1"{
                            self.businessLicenceData = data
                            //Upload Business Licenece document
                            self.uploadBusinessLicenceAPIRequest(fileData: data)
                        }else if controller.accessibilityValue == "2"{
                            self.driverLicenceData = data
                            //Upload Driver Licenece document
                            self.uploadDriverLicenceAPIRequest(fileData: data)
                        }*/
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
extension SendOfferViewController:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        self.placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
extension SendOfferViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtJOBOfferPrice{
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
        }
       return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtJOBOfferPrice{
                   DispatchQueue.main.async {
                     if let text = self.txtJOBOfferPrice.text{
                         var updatedtext =  text.replacingOccurrences(of: "$", with: "")
                            updatedtext = updatedtext.trimmingCharacters(in: .whitespaces)
                         self.txtJOBOfferPrice.text = "\(updatedtext)"
                     }
                   }
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtJOBOfferPrice{
                   DispatchQueue.main.async {
                     if let text = self.txtJOBOfferPrice.text{
                         var updatedtext =  text.replacingOccurrences(of: "$", with: "")
                            updatedtext = updatedtext.trimmingCharacters(in: .whitespaces)
                         self.txtJOBOfferPrice.text = "$\(updatedtext)"
                     }
                   }
        }
    }
        
}
extension SendOfferViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.dismiss(animated: true, completion: nil)
        let resizedImage = self.resize(image)
        
        self.attachmentdata = resizedImage
        self.uploadAttachmentAPIRequest(fileData: resizedImage)
                 
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
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.cropView.cropBoxResizeEnabled = false
        self.present(cropViewController, animated: true, completion: nil)
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
}


