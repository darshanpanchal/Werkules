//
//  BusinessLifeListViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 02/02/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import AVFoundation

class BusinessLifeListViewController: UIViewController {

    @IBOutlet weak var imgUser:UIImageView!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var tableViewBusinessLife:UITableView!
    @IBOutlet weak var heightForAddBusinessHeader:NSLayoutConstraint!
    @IBOutlet weak var viewAddBusinessLife:UIView!
    
    var isLoadMoreReview:Bool = false
    var currentPage:Int = 1
    var arrayOfReview:[BusinessLife] = []
    var fetchPageLimit:Int = 10
    
    var providerId:String = ""
    var providerProfileURL:String = ""
    
    var isForProvider:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
        self.configureTableView()
        // Do any additional setup after loading the view.
      
       
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isLoadMoreReview = false
        self.currentPage = 1
        self.arrayOfReview.removeAll()
        //GET request
        self.getUserReviewAPIRequest()
    }
    // MARK: - Setup Methods
     func setUp(){
        
        if self.isForProvider{
            self.heightForAddBusinessHeader.constant = 100
            self.viewAddBusinessLife.isHidden = false
        }else{
            self.heightForAddBusinessHeader.constant = 0
            self.viewAddBusinessLife.isHidden = true
        }
        self.imgUser.contentMode = .scaleAspectFill
         self.imgUser.clipsToBounds = true
         self.imgUser.layer.cornerRadius = 20.0
         
         if let imgURL = URL.init(string:  providerProfileURL){
             self.imgUser.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
         }
       
     }
     func configureTableView(){
         self.tableViewBusinessLife.register(UINib.init(nibName: "BusinessLifeTableViewCell", bundle: nil), forCellReuseIdentifier: "BusinessLifeTableViewCell")
         self.tableViewBusinessLife.showsVerticalScrollIndicator = false
         self.tableViewBusinessLife.delegate = self
         self.tableViewBusinessLife.dataSource = self
         self.tableViewBusinessLife.rowHeight = UITableView.automaticDimension
        self.tableViewBusinessLife.estimatedRowHeight = 180.0
         self.tableViewBusinessLife.reloadData()
     }
    // MARK: - Add Methods
    @IBAction func buttonAddbusinesslifeselector(sender:UIButton){
        if let addBusinesslifeViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddBusinessListViewController") as? AddBusinessListViewController{
            self.navigationController?.pushViewController(addBusinesslifeViewController, animated: true)
        }
    }
    // MARK: - API Request Methods
    func getUserReviewAPIRequest(){
      
        var dict:[String:Any]  = [:]
        dict["provider_id"] = "\(self.providerId)"
        dict["limit"] = "\(fetchPageLimit)"
        dict["page"] = "\(self.currentPage)"
        
                APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGETBusinessLife , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                            if let success = responseSuccess as? [String:Any],let arrayReview = success["success_data"] as? [[String:Any]]{
                             
                                  if self.currentPage == 1{
                                         self.arrayOfReview.removeAll()
                                   }
                                    self.isLoadMoreReview = arrayReview.count > 0

                                    for objReview in arrayReview{
                                       var review = BusinessLife.init(businessLifeDetail: objReview)
                                       self.arrayOfReview.append(review)
                                    }

                                    DispatchQueue.main.async {
                                       self.tableViewBusinessLife.reloadData()
                                    }
                               
                             
                                if let totalRating = success["total_page"] as? String{
                                    if let pi: Double = Double("\(totalRating)"){
                                        let rating = String(format:"%.1f", pi)
                                        print(rating)
                                    }
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
                                     //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                   }
                               }
                           }
    }
    func deleteBusinessLifeAPIRequest(objPromotion:BusinessLife){
          
          var deletepromotion:[String:Any] = [:]
          deletepromotion["id"] = "\(objPromotion.id)"
          
          APIRequestClient.shared.sendAPIRequest(requestType: .DELETE, queryString:kDeleteBusinessLife , parameter: deletepromotion as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                                       if let success = responseSuccess as? [String:Any]{
                                                  self.currentPage = 1
                                                  self.getUserReviewAPIRequest()
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
    // MARK: - Navigation
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
extension BusinessLifeListViewController:BusinessLifeCellDelegate{
    func buttonImageSelectorWithIndex(index: Int) {
        if self.arrayOfReview.count > index{
            let objBusinessLife = self.arrayOfReview[index]
           self.pushtobusinesslifedetailView(businesslife: objBusinessLife, providerImage: self.providerProfileURL)
            
        }
    }
    func buttonPlaySelectorWithIndex(index: Int) {
        if self.arrayOfReview.count > index{
            let objBusinessLife = self.arrayOfReview[index]
                    if let videoViewController:videoPlayVC = self.storyboard?.instantiateViewController(withIdentifier: "videoPlayVC") as? videoPlayVC{
                         videoViewController.hidesBottomBarWhenPushed = true
                         videoViewController.strMediaUrl = objBusinessLife.file
                         self.navigationController?.present(videoViewController, animated: true, completion: nil)
                         
                       }
        }
    }
    func buttonEditSelectorWithIndex(index: Int) {
        DispatchQueue.main.async {
            if self.arrayOfReview.count > index{
                      let objBusinessLife = self.arrayOfReview[index]
                      if let addBusinesslifeViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddBusinessListViewController") as? AddBusinessListViewController{
                          addBusinesslifeViewController.isForEdit = true
                          addBusinesslifeViewController.currentBusinessLife = objBusinessLife
                          self.navigationController?.pushViewController(addBusinesslifeViewController, animated: true)
                      }
                  }
        }
       
    }
    func buttonDeleteSelectorWithIndex(index: Int) {
        if self.arrayOfReview.count > index{
            let objBusinessLife = self.arrayOfReview[index]
            let alert = UIAlertController(title: AppName, message: "Are you sure you want to delete?", preferredStyle: .alert)
                   
                   alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                   }))
                   alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
                       
                                  self.deleteBusinessLifeAPIRequest(objPromotion: objBusinessLife)
                   }))
            alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                   self.present(alert, animated: true, completion: nil)
            
            
        }
    }
}
extension BusinessLifeListViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DispatchQueue.main.async {
            self.tableViewBusinessLife.isHidden = (self.arrayOfReview.count == 0)
        }
        return self.arrayOfReview.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessLifeTableViewCell", for: indexPath) as! BusinessLifeTableViewCell
        cell.tag = indexPath.row
        if indexPath.row == 0{
            cell.lblSeperator.isHidden = true
        }else{
            cell.lblSeperator.isHidden = false
        }
        if self.isForProvider{
            cell.stackViewEditDelete.isHidden = false
            cell.bottomVideoPreview.constant = 50.0
        }else{
            cell.stackViewEditDelete.isHidden = true
            cell.bottomVideoPreview.constant = 0.0
        }
        cell.delegate = self
        if self.arrayOfReview.count > indexPath.row{
            var objBusinessLife = self.arrayOfReview[indexPath.row]
            cell.lblBusinesslifeDescription.text = "\(objBusinessLife.businessLifeDescription)"
            cell.lblBusinesslifeDescription.numberOfLines = 1
            cell.heightForFilePreview.constant = (objBusinessLife.file.count > 0) ? 200.0 : 0.0
            
            if "\(objBusinessLife.fileType)" == "image" || "\(objBusinessLife.fileType)" == "IMAGE"{
                    cell.videoPrevie.isHidden = true
                    if objBusinessLife.file.count > 0 {
                                if let imgURL = URL.init(string: "\(objBusinessLife.file)"){
                                    cell.imgBusinessLife.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                                }
                           }
                objBusinessLife.displayName = "businesslife-image-provider-\(objBusinessLife.id)"
            }else if "\(objBusinessLife.fileType)" == "video" || "\(objBusinessLife.fileType)" == "VIDEO"{
                objBusinessLife.displayName = "businesslife-video-provider-\(objBusinessLife.id)"
                          cell.videoPrevie.isHidden = false
                          if objBusinessLife.file.count > 0 {
                            if let imgURL = URL.init(string: "\(objBusinessLife.videoThumnail)"){
                                cell.imgBusinessLife.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                            }
                            /*
                            if let  image = objBusinessLife.videoThumnail{
                                DispatchQueue.main.async {
                                     cell.imgBusinessLife.image = image
                                }
                            }else{
                                if let videoURL = URL.init(string: "\(objBusinessLife.file)"){
                                                                  DispatchQueue.global(qos: .background).async {
                                                                      if let imgURL = self.getThumbnailImage(forUrl: videoURL){
                                                                        DispatchQueue.main.async {
                                                                            objBusinessLife.videoThumnail = imgURL
                                                                             cell.imgBusinessLife.image = imgURL
                                                                            self.tableViewBusinessLife.reloadData()
                                                                        }
                                                                      }
                                                                  }
                                                                    
                                                            }
                            } */
                          
                          }
                      }
                }
                  
        
        
         if indexPath.row+1 == self.arrayOfReview.count, self.isLoadMoreReview{ //last index
             DispatchQueue.global(qos: .background).async {
                 self.currentPage += 1
                 self.getUserReviewAPIRequest()
             }
         }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select row")
        if self.arrayOfReview.count > indexPath.row{
            let objBusinessLife = self.arrayOfReview[indexPath.row]
            self.pushtobusinesslifedetailView(businesslife: objBusinessLife, providerImage: self.providerProfileURL)
        }
    }
   func pushtobusinesslifedetailView(businesslife:BusinessLife,providerImage:String){
        if let businesslifedetail = self.storyboard?.instantiateViewController(withIdentifier:"BusinessLifeDetailViewController") as? BusinessLifeDetailViewController{
            businesslifedetail.currentBusinessLife = businesslife
            businesslifedetail.providerProfileURL = providerImage
            
            self.navigationController?.pushViewController(businesslifedetail, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
            let asset: AVAsset = AVAsset(url: url)
                      let imageGenerator = AVAssetImageGenerator(asset: asset)

                      do {
                          let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
                          return UIImage(cgImage: thumbnailImage)
                      } catch let error {
                          print(error)
                      }

                      return nil
        
       
       }
}
class BusinessLife:NSObject{
        var id = "", providerID: String = ""
        var file = "", fileType: String = ""
        var businessLifeDescription  = "", createdAt  = "", updatedAt: String  = ""
        //var videoThumnail:UIImage?
        var videoThumnail:String = ""
        var displayName:String = ""
        var userID  = "", businessName  = "", businessLogo = "", name: String  = ""
        var review = "",rating = "" , follow:String = ""

        enum CodingKeys: String, CodingKey {
            case id
            case providerID = "provider_id"
            case file
            case fileType = "file_type"
            case businessLifeDescription = "description"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case videoThumnail = "video_thumbnail_url"
            case displayName = "displayName"
            case userID = "user_id"
            case businessName = "business_name"
            case businessLogo = "business_logo"
            case name,review
            case rating
            case follow



        }
    init(businessLifeDetail:[String:Any]) {
        if let _ = businessLifeDetail[CodingKeys.businessLogo.rawValue]{
            self.businessLogo = "\(businessLifeDetail[CodingKeys.businessLogo.rawValue]!)"
        }
        if let _ = businessLifeDetail[CodingKeys.userID.rawValue]{
            self.userID = "\(businessLifeDetail[CodingKeys.userID.rawValue]!)"
        }
        if let _ = businessLifeDetail[CodingKeys.businessName.rawValue]{
            self.businessName = "\(businessLifeDetail[CodingKeys.businessName.rawValue]!)"
        }
        if let _ = businessLifeDetail[CodingKeys.name.rawValue]{
            self.name = "\(businessLifeDetail[CodingKeys.name.rawValue]!)"
        }
        if let _ = businessLifeDetail[CodingKeys.review.rawValue]{
            self.review = "\(businessLifeDetail[CodingKeys.review.rawValue]!)"
        }
        if let _ = businessLifeDetail[CodingKeys.rating.rawValue]{
            self.rating = "\(businessLifeDetail[CodingKeys.rating.rawValue]!)"
        }
        if let _ = businessLifeDetail[CodingKeys.follow.rawValue]{
            self.follow = "\(businessLifeDetail[CodingKeys.follow.rawValue]!)"
        }
        if let _ = businessLifeDetail[CodingKeys.displayName.rawValue]{
            self.displayName = "\(businessLifeDetail[CodingKeys.displayName.rawValue]!)"
        }
        if let _ = businessLifeDetail[CodingKeys.id.rawValue]{
            self.id = "\(businessLifeDetail[CodingKeys.id.rawValue]!)"
        }
        if let _ = businessLifeDetail[CodingKeys.providerID.rawValue]{
            self.providerID = "\(businessLifeDetail[CodingKeys.providerID.rawValue]!)"
        }
        if let objfile = businessLifeDetail[CodingKeys.file.rawValue],!(objfile is NSNull){
            self.file = "\(businessLifeDetail[CodingKeys.file.rawValue]!)"
        }
        if let objfileType = businessLifeDetail[CodingKeys.fileType.rawValue],!(objfileType is NSNull){
            self.fileType = "\(businessLifeDetail[CodingKeys.fileType.rawValue]!)"
            
           
        }
        if let _ = businessLifeDetail[CodingKeys.businessLifeDescription.rawValue]{
            self.businessLifeDescription = "\(businessLifeDetail[CodingKeys.businessLifeDescription.rawValue]!)"
        }
        if let _ = businessLifeDetail[CodingKeys.createdAt.rawValue]{
            self.createdAt = "\(businessLifeDetail[CodingKeys.createdAt.rawValue]!)"
        }
        if let _ = businessLifeDetail[CodingKeys.updatedAt.rawValue]{
            self.updatedAt = "\(businessLifeDetail[CodingKeys.updatedAt.rawValue]!)"
        }
        if let _ = businessLifeDetail[CodingKeys.videoThumnail.rawValue]{
                   self.videoThumnail = "\(businessLifeDetail[CodingKeys.videoThumnail.rawValue]!)"
               }
    }
    /*
    func checkForVideoThumnail(){
        if "\(self.fileType)" == "video" || "\(self.fileType)" == "VIDEO"{
            DispatchQueue.global(qos: .background).async {
                if let fileURL = URL.init(string: self.file), let imgURL = self.getThumbnailImage(forUrl: fileURL){
                      DispatchQueue.main.async {
                        self.videoThumnail = imgURL
                      }
                    }
                }
        }
    }*/
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
         let imageGenerator = AVAssetImageGenerator(asset: asset)

         do {
             let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
             return UIImage(cgImage: thumbnailImage)
         } catch let error {
             print(error)
         }

         return nil
    }
}
