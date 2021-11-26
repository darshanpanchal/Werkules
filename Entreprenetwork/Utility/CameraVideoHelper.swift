//
//  ImageHelperClass.swift
//  SolApp
//
//  Created by Apple on 12/07/18.
//  Copyright © 2018 Apple. All rights reserved.
//



import UIKit
import AVFoundation
import MobileCoreServices
import Photos
import MediaPlayer
import AVKit



class CameraVideoHelper: NSObject, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    static let sharedInstance = CameraVideoHelper()
    //MARK:- Properties
    var objVC : UIViewController?
    typealias completionBlock = (UIImage?, URL? , String?) -> Void
    var block : completionBlock?
    
    
    // MARK: - Show Action sheet
    // MARK: -
    
    func showCameraVideoActionSheeet(_ controller : UIViewController ,showVideo : Bool,completionHandler:@escaping completionBlock){
        
        var arrOptions =  ["Capture Photo", "Capture Video" , "Import from library" ]   //["Capture Photo", "Capture Video"]
        
        if showVideo == false{
            arrOptions = ["Camera", "Import from library"]
        }
        
        DispatchQueue.main.async(execute: {
            
            UIAlertController.showActionsheetForImagePicker(controller, aStrTilte: nil, aStrMessage: nil, aOptionsArr: arrOptions, completion:{ (index, strTitle) in
                
                if index == 0 {
                    
                    // "Capture Video" selected
                    //if showVideo == true{
                    // "Capture Photo" selcted
                    self.openCamera(controller, isVideo: false , showVideoOption: showVideo)
                //}
                }
                else if index == 1 {
                    if showVideo == true{
//                    UIAlertController.showOkAlert(controller, aStrMessage: "How was your day? \n Record it in 30 secs") { (aInt, aStr) in
                        
                        // user tapped on video actionPerform action related to video
                        self.openCamera(controller, isVideo: true ,  showVideoOption: showVideo)
//                        }
                        
            
                    }
                  
                    else{
                        // If user selected gallery
                        let imagePicker =   UIImagePickerController()
                        //                        imagePicker.mediaTypes = [kUTTypeMovie as String , kUTTypeImage as String]
                        imagePicker.delegate = self
                        imagePicker.sourceType = .photoLibrary
                        imagePicker.allowsEditing = true
                        imagePicker.isEditing = true
                        controller.present(imagePicker, animated: true, completion: nil)
                        
                        
                    }
                }
                else if index == 2 {
                    
                    if showVideo == true {
                    // Import Video from  selected
                    
                    // If user selected gallery
                    let imagePicker =   UIImagePickerController()
                    imagePicker.mediaTypes = [kUTTypeMovie as String , kUTTypeImage as String]
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.allowsEditing = true
                    imagePicker.isEditing = true
                    controller.present(imagePicker, animated: true, completion: nil)
                    }
                }
                
            })
            
        } )
        
        
        objVC = controller
        block = completionHandler
    }
    
    
    // perform Camera or Video action Methods
    fileprivate func presentImagePicker(_ imagePicker: UIImagePickerController, _ showVideoOption: Bool, _ isVideo: Bool, _ VC: UIViewController) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.allowsEditing = true
            imagePicker.isEditing = true
           // imagePicker.cameraDevice = .front

            imagePicker.mediaTypes = showVideoOption ? [kUTTypeMovie as String , kUTTypeImage as String] : [kUTTypeImage as String]
            //                imagePicker.mediaTypes = [kUTTypeMovie as String , kUTTypeImage as String]
            if isVideo {
                //Check photo library permission
                self.checkPhotoLibraryPermission(VC)
                //set quality of video for compress size
                imagePicker.videoQuality = .type640x480
                if #available(iOS 11.0, *) {
                    
                    imagePicker.videoExportPreset = AVAssetExportPreset640x480
                }
                imagePicker.videoMaximumDuration = TimeInterval(30.0)
                imagePicker.cameraCaptureMode = .video
                imagePicker.mediaTypes = [kUTTypeMovie as String ,  kUTTypeImage as String ]
            }
            
            VC.present(imagePicker, animated: true, completion: nil)
            
        } else {
            //            print("Denied access to \(cameraMediaType)")
            SAAlertBar.show(.error, message: "ALLOW_CAMERA_ACCESS_FROM_SETTINGS")
        }
        
    }
    
    func openCamera (_ VC : UIViewController , isVideo : Bool , showVideoOption : Bool) {
        
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        
        let imagePicker = UIImagePickerController()
        
        switch cameraAuthorizationStatus {
            
        case .denied:
            //display alert to open setting if camera permission is denied
            alertPromptToAllowCameraAccessViaSettings(controller: VC, strType: "Camera")
            
        case .authorized:
            
            presentImagePicker(imagePicker, showVideoOption, isVideo, VC)
            
        case .restricted:
            break
            
        case .notDetermined:
            
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                SAAlertBar.show(.error, message: "CAMERA_NOT_SUPPORTED")
                return
            }
            
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                
                if granted {
                    
                    DispatchQueue.main.async {
                        self.presentImagePicker(imagePicker, showVideoOption, isVideo, VC)

                    }
                }
                
            }
            
        }
    }
    
    
    //MARK:- Show Alert to Open settings Page
    func alertPromptToAllowCameraAccessViaSettings(controller : UIViewController, strType : String) {
        
        UIAlertController.showAlert(controller, aStrTitle: "\"\("APP_Name")\" Would Like To Access the \(strType)", aStrMessage: "Please grant permission to use the \(strType).", style: .alert, aCancelBtn: "Cancel", aDistrutiveBtn: nil, otherButtonArr: ["Settings"]) { (aInt, aStrMsg) in
            if aInt == 0 {
     
                if !UIApplication.openSettingsURLString.isEmpty {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    //check if user has allowed for photo library permission
    func checkPhotoLibraryPermission(_ VC : UIViewController) {
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
        }
        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
            alertPromptToAllowCameraAccessViaSettings(controller: VC, strType: "Photo Library")
        }
        else if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    
                }else {
                    //show alert to allow access photo library
                    UIAlertController.showOkAlert(VC, aStrMessage: "Photo library access is required to record Video", completion: { (aInt, strMsg) in
                    })
                }
            })
        }
        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    // MARK:
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        
        if mediaType.isEqual(to: kUTTypeImage as String) {
            
            // Get the Original Image.
            //guard var image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
            guard var image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            }
            
            // Check If editing was enabled or not. If it was enabled then get the editted image.
            if picker.allowsEditing {
                image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage ?? image
            }
            
            // Convert the image to the Data.
            let data = image.pngData()
            // data?.writeToFile(imagePath, atomically: true)
            
            // Create the Destination path for saving the image.
            let destinationUrl = URL.urlForNewTemporaryFile(ext:"jpg")
            
            do {
                // Write the image to the path created.
//                try data?.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                
            } catch {
                
                // Catch exception here and act accordingly
                block?(nil , nil , "")
                return
            }
            // Call the completion block to pass the image and continue the further process of post.
            block?(image, nil , "image")
        }

        else if mediaType.isEqual(to: kUTTypeMovie as String) {


            if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
                let aVideoImage = self.getThumbnailImage(forUrl: videoURL)

                let avAsset = AVURLAsset(url: videoURL)
                let startDate = Date()
                let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPreset640x480)

                let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let myDocPath = NSURL(fileURLWithPath: docDir).appendingPathComponent("temp.mp4")?.absoluteString

                let docDir2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL

                var fileName = videoURL.deletingPathExtension().lastPathComponent
                let filePath = docDir2.appendingPathComponent(fileName + ".mp4")//docDir2.appendingPathComponent("rendered-Video.mp4")
                deleteFile(filePath!)

                if FileManager.default.fileExists(atPath: myDocPath!){
                    do{
                        try FileManager.default.removeItem(atPath: myDocPath!)
                    }catch let error{
                        print(error)
                    }
                }

                exportSession?.outputURL = filePath
                exportSession?.outputFileType = AVFileType.mp4
                exportSession?.shouldOptimizeForNetworkUse = true

                let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
                let range = CMTimeRange(start: start, duration: avAsset.duration)
                exportSession?.timeRange = range

                exportSession!.exportAsynchronously{() -> Void in
                    switch exportSession!.status{
                    case .failed:
                        print("\(exportSession!.error!)")
                        self.block?(aVideoImage,nil, "video")
                    case .cancelled:
                        print("Export cancelled")
                        self.block?(aVideoImage,nil, "video")
                    case .completed:
                        let endDate = Date()
                        let time = endDate.timeIntervalSince(startDate)
                        print(time)
                        print("Successful")
                        print(exportSession?.outputURL ?? "")
                        self.block?(aVideoImage,exportSession?.outputURL , "video")
                    // return exportSession?.outputURL
                    default:
                        break
                    }

                }

                //                PHPhotoLibrary.shared().performChanges({
                //                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                //
                //                }) { saved, error in
                //                    if saved{
                //
                //                        self.block?(aVideoImage,videoURL , "video")
                //                    }else{
                //                        self.block?(nil,nil,"video")
                //                    }
                //                }
            }
        }
    
        objVC?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        objVC?.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:- Get width and height for video
    func resolutionForVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    
    //MARK:- ADD child and remove child method to zoom image from other VC
    
    
    func addChildController( InView: UIView , parentController : UIViewController , strImageToDisplay : String){
  /*      let aPhotoZoomVC : PhotoZoomVC =  UIViewControllerWithName(SB_POST , "PhotoZoomVC") as! PhotoZoomVC  //
        parentController.addChildViewController(aPhotoZoomVC)
        InView.addSubview(aPhotoZoomVC.view)
        aPhotoZoomVC.view.frame = InView.bounds
        aPhotoZoomVC.imgView.kf.setImage(with:URL(string: strImageToDisplay))
        aPhotoZoomVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        aPhotoZoomVC.didMove(toParentViewController: parentController)*/
    }
    
    func removeChildController(controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }
    
    //MARK:- Open video Controller
    //MARK:-
    func playVideo (_ controller : UIViewController , videoUrl : URL)
    {
        let player = AVPlayer(url: videoUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        controller.present(playerViewController, animated: true)
        {
            DispatchQueue.main.async {
                playerViewController.player!.play()
            }
            
        }
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        //set property to get thumbnail the way video has taken
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    func deleteFile(_ filePath:URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else{
            return
        }
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
}

public extension URL {
    static public func urlForNewTemporaryFile(ext pathExtension: String) -> URL {
        let fileName = "\(NSUUID().uuidString).\(pathExtension)"
        let tempPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        return URL(fileURLWithPath: tempPath[0]).appendingPathComponent(fileName)
        
    }
}
