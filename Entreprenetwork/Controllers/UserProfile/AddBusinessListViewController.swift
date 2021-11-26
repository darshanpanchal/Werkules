//
//  AddBusinessListViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 09/02/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import YPImagePicker
import MobileCoreServices
import CropViewController
import AVKit

class AddBusinessListViewController: UIViewController {

    @IBOutlet weak var lblTitle:UILabel!
    
    @IBOutlet weak var txtUploadImageVideo:UITextField!
    @IBOutlet weak var txtDiscription:UITextView!
    @IBOutlet weak var buttonPublish:UIButton!
    
    
    var addBusinessLifeParameters:[String:Any] = [:]
    var currentFileData:Data?
    
    var placeholderLabel : UILabel!
    
    var isForEdit:Bool = false
    var currentBusinessLife:BusinessLife?
    
    var objImagePickerController = UIImagePickerController()
    var imageForCrop: UIImage?
    
    var videoPickerController = UIImagePickerController()
    var videoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
             txtDiscription.delegate = self
              placeholderLabel = UILabel()
              placeholderLabel.text = "Write something....."
              placeholderLabel.font = UIFont(name: "Avenir Medium", size: 17)
              placeholderLabel.sizeToFit()
             // txtDiscription.addSubview(placeholderLabel)
              placeholderLabel.frame.origin = CGPoint(x: 5, y: (txtDiscription.font?.pointSize)! / 2)
              placeholderLabel.textColor = UIColor.lightGray
              placeholderLabel.isHidden = !txtDiscription.text.isEmpty
              
        if self.isForEdit,let businessLife = self.currentBusinessLife{
            self.lblTitle.text = "Update Business Life"
            self.buttonPublish.setTitle("UPDATE", for: .normal)
            self.addBusinessLifeParameters["id"] = "\(businessLife.id)"
            
//            self.configureCurrentBusinessLifeForEdit(businessLife: self.currentBusinessLife!)
            placeholderLabel.isHidden = true
            self.txtUploadImageVideo.text = self.currentBusinessLife!.displayName
            self.txtDiscription.text = self.currentBusinessLife!.businessLifeDescription
        }else{
            self.lblTitle.text = "Add Business Life"
            self.buttonPublish.setTitle("PUBLISH", for: .normal)
            self.txtDiscription.text = ""
        }
    }
    func configureCurrentBusinessLifeForEdit(businessLife:BusinessLife){
        self.addBusinessLifeParameters["id"] = "\(businessLife.id)"
        self.txtDiscription.text = businessLife.businessLifeDescription
        if let url = URL.init(string: businessLife.file){
            do {
                let videoData = try Data(contentsOf:url)
                 self.currentFileData = videoData
                 DispatchQueue.main.async {
                     if let currentUser = UserDetail.getUserFromUserDefault(),let currentprovider = currentUser.businessDetail{
                        if businessLife.fileType == "image" || businessLife.fileType == "IMAGE"{
                            self.txtUploadImageVideo.text = "businesslife-image-provider-\(currentprovider.id)"
                        }else if businessLife.fileType == "video" || businessLife.fileType == "VIDEO"{
                            self.txtUploadImageVideo.text = "businesslife-video-provider-\(currentprovider.id)"
                        }

                        }
                 }
              } catch let error {
                print(error)
              }
        }
       
        
    }
     // MARK: - Selector methods
    @IBAction func buttonCameraInfoSelector(sender:UIButton){
        DispatchQueue.main.async {
            let cameraInfo = UIAlertController.init(title:AppName, message: kUserProfileHelp, preferredStyle: .alert)
            cameraInfo.addAction(UIAlertAction.init(title:"Ok", style: .cancel, handler: nil))
            cameraInfo.view.tintColor = UIColor.init(hex: "#38B5A3")
            self.present(cameraInfo, animated: true, completion: nil)
        }
    }
    @IBAction func buttonBackSelector(sender:UIButton){
           self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonPublishSelector(sender:UIButton){
        if self.isValidData(){
            self.addBusinessLifeAPIRequest()
        }
    }
    @IBAction func buttonUploadImageVideoSelector(sender:UIButton){
        
        let actionSheet: UIAlertController = UIAlertController(title: "Business Life", message: "", preferredStyle: .actionSheet)
              
              let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                  print("Cancel")
              }
               cancelActionButton.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
              actionSheet.addAction(cancelActionButton)
              
              let cameraActionButton = UIAlertAction(title: "Image", style: .default)
              { _ in
                DispatchQueue.main.async {
                    self.presentImagePicker()
                }
              }
               cameraActionButton.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
              actionSheet.addAction(cameraActionButton)
              
              let gallery1ActionButton = UIAlertAction(title: "Upload Video", style: .default)
              { _ in
                DispatchQueue.main.async {
                    self.presentVideoGallery()
                }
                
                
              }
                
        gallery1ActionButton.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
              actionSheet.addAction(gallery1ActionButton)
        
              let galleryActionButton = UIAlertAction(title: "Record Video", style: .default)
              { _ in
                DispatchQueue.main.async {
                    self.presentVideoPicker()
                }
                
              }
                galleryActionButton.setValue(UIColor(hex:"38B5A3"), forKey: "titleTextColor")
              actionSheet.addAction(galleryActionButton)
              
              self.present(actionSheet, animated: true, completion: nil)
    }
    func presentVideoGallery(){
            self.videoPickerController = UIImagePickerController()
            self.videoPickerController.sourceType = .savedPhotosAlbum
        self.videoPickerController.delegate = self
            videoPickerController.mediaTypes = ["public.movie"]
            present(videoPickerController, animated: true, completion: nil)
        
    }
    func presentImagePickerController(){
             self.view.endEditing(true)
             self.objImagePickerController.modalPresentationStyle = .fullScreen
             self.present(self.objImagePickerController, animated: true, completion: nil)
            
         }
    func presentImagePicker(){
        DispatchQueue.main.async {
                          self.objImagePickerController = UIImagePickerController()
                          self.objImagePickerController.sourceType = .savedPhotosAlbum
                          self.objImagePickerController.delegate = self
                          self.objImagePickerController.allowsEditing = false
                          self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                          self.view.endEditing(true)
                          self.presentImagePickerController()
                      }
        
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
                                       self.txtUploadImageVideo.text = "businesslife-image-provider-\(currentprovider.id)"

                                      }
                               }
                                 self.currentFileData = resizedImage
                                 
                                 
                             }
                             picker.dismiss(animated: true, completion: nil)
                         }
                         present(picker, animated: true, completion: nil)
        */
    }
    func presentVideoPicker(){
        self.videoPickerController = UIImagePickerController()
        self.videoPickerController.delegate = self
        self.videoPickerController.sourceType = .camera
        self.videoPickerController.allowsEditing = false
        self.videoPickerController.mediaTypes = [kUTTypeMovie as String]
        //self.videoPickerController.cameraCaptureMode = .video
        
        self.present(self.videoPickerController, animated: true, completion: nil)
        /*
      // Here we configure the picker to only show videos, no photos.
        var config = YPImagePickerConfiguration()
        config.screens = [.video]
        config.library.maxNumberOfItems = 1
        config.library.mediaType = .video
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, _ in
            
            if let video = items.singleVideo {
                print(video.fromCamera)
                print(video.thumbnail)
                print(video.url)
                print(video.asset)
                  do {
                       let videoData = try Data(contentsOf: video.url)
                        self.currentFileData = videoData
                        DispatchQueue.main.async {
                            if let currentUser = UserDetail.getUserFromUserDefault(),let currentprovider = currentUser.businessDetail{
                                self.txtUploadImageVideo.text = "businesslife-video-provider-\(currentprovider.id)"

                               }
                        }
                     } catch let error {
                       print(error)
                     }
                

            }
            picker.dismiss(animated: true, completion: nil)
        }
        self.present(picker, animated: true, completion: nil)
        */
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
    // MARK: - API methods
    func addBusinessLifeAPIRequest(){
        
        
        
        APIRequestClient.shared.uploadpromotionImage(requestType: .POST, queryString: self.isForEdit ? kUpdateBusinessLife:kAddBusinessLife , parameter: self.addBusinessLifeParameters as [String:AnyObject], imageData:self.currentFileData ?? nil,isFileUpload:true , isHudeShow: true, success: { (responseSuccess) in
                       
                           DispatchQueue.main.async {
                               ExternalClass.HideProgress()
                           }
                            DispatchQueue.main.async {
                                   SAAlertBar.show(.error, message:"Business Life added successfully.".localizedLowercase)
                                  self.navigationController?.popViewController(animated: true)
                              }
//                           if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
//
//
//                           }
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
    func isValidData()->Bool {
        if !self.isForEdit{
            guard let _ = self.currentFileData else{
                 SAAlertBar.show(.error, message:"Please select business file".localizedLowercase)
                 return false
             }
             if let currentData = self.currentFileData{
                 print("===== current data count \(currentData.count)")
                 if currentData.count > 52428800{ // 50 mb
                     if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                         SAAlertBar.show(.error, message:"\(appDelegate.filesizelimitvalidationMessage)".localizedLowercase)
                     }
                     return false
                 }
                 
             }

        }
 
        guard let name = self.txtDiscription.text?.trimmingCharacters(in: .whitespacesAndNewlines),name.count > 0 else{
                   SAAlertBar.show(.error, message:"Please enter description".localizedLowercase)
                   return false
               }
        self.addBusinessLifeParameters["description"] = "\(name)"
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
extension AddBusinessListViewController:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
extension AddBusinessListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
         self.dismiss(animated: true, completion: nil)
         let resizedImage = self.resize(image)
                                      
        DispatchQueue.main.async {
        if let currentUser = UserDetail.getUserFromUserDefault(),let currentprovider = currentUser.businessDetail{
            self.txtUploadImageVideo.text = "businesslife-image-provider-\(currentprovider.id)"

           }
        }
        self.currentFileData = resizedImage
        // self.attachmentdata = resizedImage
        //self.uploadAttachmentAPIRequest(fileData: resizedImage)
                  
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if picker == self.objImagePickerController{
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                self.imageForCrop = image
                
            }
            
            self.dismiss(animated: false) { [unowned self] in
                                      self.openEditor(nil, pickingViewTag: picker.view.tag)
                                  }
        }else {
            
        
        if let objvideoURL = info[.mediaURL] as? URL{
            print(objvideoURL)
            self.videoURL = objvideoURL
            do {
              let videoData = try Data(contentsOf: objvideoURL)
                
                print("File size before compression: \(videoData.count.byteSize) mb")
                      let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
                self.currentFileData = videoData
                /*self.compressVideo(inputURL: videoURL as! URL, outputURL: compressedURL) { (exportSession) in
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
                                  self.currentFileData = compressedData as Data
                                  print("File size after compression: \(compressedData.count.byteSize) mb")
                              case .failed:
                                  break
                              case .cancelled:
                                  break
                              }
                          }*/
               
               DispatchQueue.main.async {
                   if let currentUser = UserDetail.getUserFromUserDefault(),let currentprovider = currentUser.businessDetail{
                       self.txtUploadImageVideo.text = "businesslife-video-provider-\(currentprovider.id)"
                      }
               }
            } catch let error {
              print(error)
            }
        }

        // Code here
        self.dismiss(animated: true, completion: nil)
        }
    }
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
           let urlAsset = AVURLAsset(url: inputURL, options: nil)
           guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetLowQuality) else {
               handler(nil)

               return
           }
           exportSession.outputURL = outputURL
           exportSession.outputFileType = .mov
           exportSession.shouldOptimizeForNetworkUse = true
           exportSession.exportAsynchronously { () -> Void in
               handler(exportSession)
           }
       }
    
}
extension Int {
    var byteSize: String {
        return ByteCountFormatter().string(fromByteCount: Int64(self))
    }
}
