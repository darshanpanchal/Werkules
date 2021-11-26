//
//  CameraViewController.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 24/01/20.
//  Copyright © 2020 Sujal Adhia. All rights reserved.
//

import UIKit
import Gallery
import Photos
import Fusuma
import YPImagePicker
import Firebase

//@available(iOS 13.0, *)
class CameraViewController: UIViewController,GalleryControllerDelegate,FusumaDelegate {
    
    var mutArrImages = NSMutableArray()
    var imagesSelected = Bool()
    
    //MARK: -  UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        mutArrImages = NSMutableArray.init()
        imagesSelected = false
        
        Analytics.logEvent(NSLocalizedString("click_post_job_tab", comment: ""), parameters: [:])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if imagesSelected == false {
            imagesSelected = true
            
            self.mutArrImages.removeAllObjects()
            
            var config = YPImagePickerConfiguration()
            config.showsPhotoFilters = false
            config.library.maxNumberOfItems = 4
            config.isScrollToChangeModesEnabled = false
            config.startOnScreen = .library
            let picker = YPImagePicker(configuration: config)
            present(picker, animated: true, completion: nil)
            
            picker.didFinishPicking { [unowned picker] items, cancelled in
                
                if cancelled {
                    print("Picker was canceled")
                    
                    self.imagesSelected = false
                    let lastSelectedTabIndex = UserDefaults.standard.integer(forKey: "lastSelectedTabIndex")
                    
                    let tabbarcontroller = self.navigationController?.parent as! UITabBarController
                    tabbarcontroller.selectedIndex = lastSelectedTabIndex
                    
                    picker.dismiss(animated: true, completion: nil)
                    return
                }
                
                for item in items {
                    self.imagesSelected = false
                    switch item {
                    case .photo(let photo):
                        
                        let selectedImage = photo.image
                        let resizedImage = self.resize(selectedImage)
                        self.mutArrImages.add(resizedImage)
                        
                    default:
                        print("")
                    }
                }
                self.performSegue(withIdentifier: "addDetailsSegue", sender: self)
                picker.dismiss(animated: true, completion: nil)
            }
        }
        else {
            self.imagesSelected = false
        }
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
    
    func fusumaWillClosed() {
        
        imagesSelected = false
        let lastSelectedTabIndex = UserDefaults.standard.integer(forKey: "lastSelectedTabIndex")
        
        let tabbarcontroller = self.navigationController?.parent as! UITabBarController
        tabbarcontroller.selectedIndex = lastSelectedTabIndex
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode, metaData: [ImageMetadata]) {
        
        imagesSelected = false
        
        for (index,_) in images.enumerated() {
            
            let selectedImage = images[index]
            let resizedImage = self.resize(selectedImage)
            
            self.mutArrImages.add(resizedImage)
        }
        self.performSegue(withIdentifier: "addDetailsSegue", sender: self)
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
                
                self.mutArrImages.add(resizedImage)
            })
        }
        
        self.performSegue(withIdentifier: "addDetailsSegue", sender: self)
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
        
        let lastSelectedTabIndex = UserDefaults.standard.integer(forKey: "lastSelectedTabIndex")
        
        let tabbarcontroller = self.navigationController?.parent as! UITabBarController
        tabbarcontroller.selectedIndex = lastSelectedTabIndex
    }
    
    //MARK: - User Defined Methods
    
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "addDetailsSegue" {
            let vc = segue.destination as! PostJobVC
            vc.selectedImagesArray = self.mutArrImages
        }
    }
    
}
