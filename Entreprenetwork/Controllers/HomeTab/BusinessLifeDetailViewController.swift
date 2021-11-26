//
//  BusinessLifeDetailViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 05/04/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import AVFoundation

class BusinessLifeDetailViewController: UIViewController {
    
    @IBOutlet weak var imgUser:UIImageView!

    @IBOutlet weak var tableViewBusinessLife:UITableView!
    
    var currentBusinessLife:BusinessLife?
    var providerProfileURL:String = ""

    var isForProvider:Bool = false
    var postID:String = ""
    var isFromDynamicLink:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imgUser.contentMode = .scaleAspectFill
        self.imgUser.clipsToBounds = true
        self.imgUser.layer.cornerRadius = 20.0
        if let imgURL = URL.init(string:  providerProfileURL){
                   self.imgUser.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
               }
        // Do any additional setup after loading the view.
        self.setup()
    }
    // MARK: - Setup Methods
    func setup(){
        if self.isFromDynamicLink{
            self.imgUser.isHidden = true
            self.getSingleBusinessLifeDetail(businessLifeID: self.postID)
        }else{
            self.imgUser.isHidden = false
            self.configureTableViewForSingleRecord()
        }

    }
    func configureTableViewForSingleRecord(){
        self.tableViewBusinessLife.register(UINib.init(nibName: "BusinessLifeTableViewCell", bundle: nil), forCellReuseIdentifier: "BusinessLifeTableViewCell")
        self.tableViewBusinessLife.showsVerticalScrollIndicator = false
        self.tableViewBusinessLife.delegate = self
        self.tableViewBusinessLife.dataSource = self
        self.tableViewBusinessLife.rowHeight = UITableView.automaticDimension
        self.tableViewBusinessLife.estimatedRowHeight = 180.0
        self.tableViewBusinessLife.tableFooterView = UIView()
        self.tableViewBusinessLife.reloadData()
    }
    //provider/get-business-life

    // MARK: - APIREQUEST
    func getSingleBusinessLifeDetail(businessLifeID:String){
        var dict:[String:Any] = [:]
        dict["id"] = "\(businessLifeID)"
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGETSingleBusinessLife , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                    if let success = responseSuccess as? [String:Any],let objReview = success["success_data"] as? [String:Any]{
                               let review = BusinessLife.init(businessLifeDetail: objReview)

                            DispatchQueue.main.async {
                                self.currentBusinessLife = review
                                self.configureTableViewForSingleRecord()
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
                              // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                           }
                       }
                   }
    }

    // MARK: - Navigation
    @IBAction func buttonBackSelector(sender:UIButton){
        if self.isFromDynamicLink{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            let navigationController = UINavigationController(rootViewController:VC)
            // Make the Tab Bar Controller the root view controller
            //connect()
              if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first{
                  window.rootViewController? = navigationController
                  window.makeKeyAndVisible()
              }
        }else{
            self.navigationController?.popViewController(animated: true)
        }

        
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
extension BusinessLifeDetailViewController:BusinessLifeCellDelegate{
    func buttonImageSelectorWithIndex(index: Int) {
        if  let objBusinessLife = self.currentBusinessLife{
            self.presentWebViewDetailPageWith(strTitle:"Business Life", strURL: objBusinessLife.file)
        }
    }
    func presentWebViewDetailPageWith(strTitle:String,strURL:String){
                       
                       if let attachmentViewController = UIStoryboard.profile.instantiateViewController(withIdentifier: "ConditionPolicyVC") as? ConditionPolicyVC{
                           attachmentViewController.strURL = strURL
                           attachmentViewController.strTitle = strTitle
                           //attachmentViewController.modalPresentationStyle = .
                           self.navigationController?.present(attachmentViewController, animated: true, completion: nil)
                       }
                   }
    func buttonPlaySelectorWithIndex(index: Int) {
        if  let objBusinessLife = self.currentBusinessLife{
                    if let videoViewController:videoPlayVC = self.storyboard?.instantiateViewController(withIdentifier: "videoPlayVC") as? videoPlayVC{
                         videoViewController.hidesBottomBarWhenPushed = true
                         videoViewController.strMediaUrl = objBusinessLife.file
                         self.navigationController?.present(videoViewController, animated: true, completion: nil)
                         
                       }
        }
    }
    func buttonEditSelectorWithIndex(index: Int) {
        DispatchQueue.main.async {
        if  let objBusinessLife = self.currentBusinessLife{
                      
                      if let addBusinesslifeViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddBusinessListViewController") as? AddBusinessListViewController{
                          addBusinesslifeViewController.isForEdit = true
                          addBusinesslifeViewController.currentBusinessLife = objBusinessLife
                          self.navigationController?.pushViewController(addBusinesslifeViewController, animated: true)
                      }
                  }
        }
       
    }
    func buttonDeleteSelectorWithIndex(index: Int) {
        if  let objBusinessLife = self.currentBusinessLife{
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
    func deleteBusinessLifeAPIRequest(objPromotion:BusinessLife){
          
          var deletepromotion:[String:Any] = [:]
          deletepromotion["id"] = "\(objPromotion.id)"
          
          APIRequestClient.shared.sendAPIRequest(requestType: .DELETE, queryString:kDeleteBusinessLife , parameter: deletepromotion as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                                       if let success = responseSuccess as? [String:Any]{
                                                self.navigationController?.popViewController(animated: true)
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
}
extension BusinessLifeDetailViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            if let _ = self.currentBusinessLife{
                DispatchQueue.main.async {
                       self.tableViewBusinessLife.isHidden = false
                }
                    return 1
                }else{
                DispatchQueue.main.async {
                        self.tableViewBusinessLife.isHidden = true
                }
                       return 0
                   }
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
        if let objBusinessLife = self.currentBusinessLife{
            
            cell.lblBusinesslifeDescription.text = "\(objBusinessLife.businessLifeDescription)"
            cell.heightForFilePreview.constant = (objBusinessLife.file.count > 0) ? 200.0 : 0.0
            
            if "\(objBusinessLife.fileType)" == "image" || "\(objBusinessLife.fileType)" == "IMAGE"{
                    cell.videoPrevie.isHidden = true
                    if objBusinessLife.file.count > 0 {
                                if let imgURL = URL.init(string: "\(objBusinessLife.file)"){
                                    cell.imgBusinessLife.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                                }
                           }
            }else if "\(objBusinessLife.fileType)" == "video" || "\(objBusinessLife.fileType)" == "VIDEO"{
                          cell.videoPrevie.isHidden = false
                          if objBusinessLife.file.count > 0 {
                            if let imgURL = URL.init(string: "\(objBusinessLife.videoThumnail)"){
                                cell.imgBusinessLife.sd_setImage(with: imgURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                            }
                      
                          }
                      }
                }
                  
        
        
      
        return cell
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
