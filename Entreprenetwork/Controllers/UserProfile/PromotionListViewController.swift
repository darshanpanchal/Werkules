//
//  PromotionListViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 04/02/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol PromotionListDelegate {
    func didSelectPromotionWith(promotiondetail:Promotion)
}
class PromotionListViewController: UIViewController {

    
    @IBOutlet weak var tableViewPromotion:UITableView!

    @IBOutlet weak var addpromotioncontainer:UIView!
    @IBOutlet weak var heightForAddPromotion:NSLayoutConstraint!
    
    
    var isLoadMorePromotion:Bool = false
    var currentPage:Int = 1
    var arrayOfPromotions:[Promotion] = []
    var fetchPageLimit:Int = 10
    
    var delegate:PromotionListDelegate?
    
    var providerId:String = ""
    var isForProviderSide:Bool = false
    var isForPromotionSelection:Bool = false
    var selectedIndex:Int?
    
    var expirePromotion:NSMutableSet = NSMutableSet()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureTableView()
        
       
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.expirePromotion = NSMutableSet()
        self.currentPage = 1
        self.arrayOfPromotions.removeAll()
        //GET request
        self.getUserPromotionAPIRequest()
        
        self.configureaddpromotioncontainer()
    }
    // MARK: - USER DEFINE METHODS
    func configureTableView(){
        self.tableViewPromotion.register(UINib.init(nibName: "PromotionTableViewCell", bundle: nil), forCellReuseIdentifier: "PromotionTableViewCell")
        self.tableViewPromotion.showsVerticalScrollIndicator = false
        self.tableViewPromotion.delegate = self
        self.tableViewPromotion.dataSource = self
        self.tableViewPromotion.dragInteractionEnabled = true // Enable intra-app drags for iPhone.
        self.tableViewPromotion.dragDelegate = self
        self.tableViewPromotion.dropDelegate = self
//        self.tableViewPromotion.rowHeight = UITableView.automaticDimension
        self.tableViewPromotion.estimatedRowHeight = 120.0
        self.tableViewPromotion.reloadData()
    }
    func configureaddpromotioncontainer(){
        DispatchQueue.main.async {
            if self.isForProviderSide{
                self.addpromotioncontainer.isHidden = false
                self.heightForAddPromotion.constant = 120.0
            }else{
                 self.addpromotioncontainer.isHidden = true
                self.heightForAddPromotion.constant = 0.0
               }
        }
       
        
    }
     // MARK: - API METHODS
    func deletePromotionAPIRequest(objPromotion:Promotion){
        
        var deletepromotion:[String:Any] = [:]
        deletepromotion["promotion_id"] = "\(objPromotion.id)"
        
        APIRequestClient.shared.sendAPIRequest(requestType: .DELETE, queryString:kDeletePromotion , parameter: deletepromotion as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                                     if let success = responseSuccess as? [String:Any]{
                                                self.currentPage = 1
                                                self.getUserPromotionAPIRequest()
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
                                                SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                            }
                                        }
                                    }
    }
    func getUserPromotionAPIRequest(){
         
           var dict:[String:Any]  = [:]
           dict["provider_id"] = "\(self.providerId)"
        dict["limit"] = "\(self.fetchPageLimit)"
           dict["page"] = "\(self.currentPage)"
           
                   APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kGETPromotionList , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                               if let success = responseSuccess as? [String:Any],let arrayPromotion = success["success_data"] as? [[String:Any]]{
                                
                                     if self.currentPage == 1{
                                            self.arrayOfPromotions.removeAll()
                                      }
                                        self.isLoadMorePromotion = arrayPromotion.count > 0

                                       for jsonPromotion in arrayPromotion{
                                         let objPromotion = Promotion.init(promotionDetail: jsonPromotion)
                                          self.arrayOfPromotions.append(objPromotion)
                                       }

                                       DispatchQueue.main.async {
                                          self.tableViewPromotion.reloadData()
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
                                          SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                      }
                                  }
                              }
       }
    // MARK: - SELECTOR METHODS
    @IBAction func buttonBackSelector(sender:UIButton){
              self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonAddpromotionSelector(sender:UIButton){
        self.pushToAddPromotionViewController()
    }
    @IBAction func buttonAddpromotionInfoSelector(sender:UIButton){
        let alert = UIAlertController(title: "Promotion Listing Help", message: "10% of every promotion is distributed to Werkules users as an incentive to market your company. The promotion entry and management screen will show you the total promotion amount saved by the purchaser, and how much will be distributed to those marketing your company", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushToAddPromotionViewController(){
        if let objAddPromotionViewController:AddPromotionViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddPromotionViewController") as? AddPromotionViewController{
                        self.navigationController?.pushViewController(objAddPromotionViewController, animated: true)
                      }
    }
}
extension PromotionListViewController:UITableViewDelegate, UITableViewDataSource, PromotionCellDelegate, UITableViewDropDelegate, UITableViewDragDelegate{
    func buttonradioSelectionWithIndex(index: Int) {
        self.selectedIndex = index
        DispatchQueue.main.async {
            self.tableViewPromotion.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let _ = self.delegate{
                    self.navigationController?.popViewController(animated: true)
                    self.delegate!.didSelectPromotionWith(promotiondetail: self.arrayOfPromotions[index])
                }
            }
        }
    }
   
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if self.expirePromotion.contains(indexPath.row){
            return false
        }else{
            return true
        }
    }
        
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if self.expirePromotion.contains(indexPath.row){
             return []
        }else{
            
            let dragItem = UIDragItem(itemProvider: NSItemProvider())
            dragItem.localObject = self.arrayOfPromotions[indexPath.row]
            return [dragItem]
            
        }
        
      
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update the model
        let mover = self.arrayOfPromotions.remove(at: sourceIndexPath.row)
        self.arrayOfPromotions.insert(mover, at: destinationIndexPath.row)
        
        var arrayofUpdate:[[String:Any]] = []
        for (index,promotion) in self.arrayOfPromotions.enumerated(){
            var dict:[String:Any] = [:]
            dict["order"] = "\(index)"
            dict["id"] = "\(promotion.id)"
            arrayofUpdate.append(dict)
        }
        var dictionaryUpdate:[String:Any] = [:]
        dictionaryUpdate["order"] = arrayofUpdate
        
        print(arrayofUpdate)
        self.callAPIRequestToUpdatePromotionOrder(dict: dictionaryUpdate)
    }
    func callAPIRequestToUpdatePromotionOrder(dict:[String:Any]){
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kUpdatePromotionOrder , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                            
                            if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                                       
                                       }else{
                                           DispatchQueue.main.async {
                                           //    SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
                                               SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                           }
                                       }
                                   }
    }
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        // Handle Drop Functionality
        print("===== drop")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DispatchQueue.main.async {
            self.tableViewPromotion.isHidden = (self.arrayOfPromotions.count == 0)
        }
        return self.arrayOfPromotions.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionTableViewCell", for: indexPath) as! PromotionTableViewCell
        cell.tag = indexPath.row
        cell.delegate = self
        if self.arrayOfPromotions.count > indexPath.row{
            let objPromotion = self.arrayOfPromotions[indexPath.row]
            cell.lblPromotionTitle.text = objPromotion.name
            
            if objPromotion.amount.count > 0{
               cell.lblPromotionDescription.text = "\(objPromotion.savingprice)% off your total bill"
                if objPromotion.type.count > 0{
                   if "\(objPromotion.type)" == "percentage"{
                       cell.lblPromotionDescription.text = "\(objPromotion.savingprice)% off your total bill"
                   }else{
                       cell.lblPromotionDescription.text = "\(CurrencyFormate.Currency(value: Double(objPromotion.savingprice) ?? 0)) off your total bill"
                   }
               }
           }
            //cell.lblPromotionDescription.text = objPromotion.promotionDescription
            
            
            if let isExpired:Bool = objPromotion.isExpired.bool{
                if isExpired{
                    cell.viewRadioButton.isHidden = true
                    self.expirePromotion.add(indexPath.row)
                    cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
                }else{
                    cell.viewRadioButton.isHidden = !self.isForPromotionSelection
                    if self.expirePromotion.contains(indexPath.row){
                        self.expirePromotion.remove(indexPath.row)
                    }
                    cell.backgroundColor = UIColor.white
                }
            }
        }
        
        
        if let  index = self.selectedIndex{
            if index == indexPath.row{
                cell.buttonradio.setImage(UIImage.init(named: "radio_check"), for: .normal)
            }else{
                cell.buttonradio.setImage(UIImage.init(named: "radio_uncheck"), for: .normal)
            }
        }
            
        
        
       
        if self.isForPromotionSelection{
            cell.objStackViewEditRemove.isHidden = true
            cell.btnSeedetail.isHidden = true
            
        }else{
            cell.btnSeedetail.isHidden = false
            if self.isForProviderSide{
               cell.objStackViewEditRemove.isHidden = false
            }else{
               cell.objStackViewEditRemove.isHidden = true
            }
        }
        
         if indexPath.row+1 == self.arrayOfPromotions.count, self.isLoadMorePromotion{ //last index
             DispatchQueue.global(qos: .background).async {
                 self.currentPage += 1
                 self.getUserPromotionAPIRequest()
             }
         }
       
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0//UITableView.automaticDimension
    }
    func buttonEditWithIndex(index: Int) {
        DispatchQueue.main.async {
            if self.arrayOfPromotions.count > index{
                     let objPromotion = self.arrayOfPromotions[index]
                     DispatchQueue.main.async {
                         self.pushToAddPromotionViewController(objPromotion: objPromotion)
                     }
                     
                 }
        }
     
    }
    func pushToAddPromotionViewController(objPromotion:Promotion){
        if let objAddPromotionViewController:AddPromotionViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddPromotionViewController") as? AddPromotionViewController{
            objAddPromotionViewController.isForEdit = true
            objAddPromotionViewController.currentPromotionDetail = objPromotion
                        self.navigationController?.pushViewController(objAddPromotionViewController, animated: true)
                      }
    }
    func buttonDeleteWithIndex(index: Int) {
        if self.arrayOfPromotions.count > index{
            
            let alert = UIAlertController(title: AppName, message: "Are you sure you want to delete?", preferredStyle: .alert)
                   
                   alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                   }))
                   alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
                       let objPromotion = self.arrayOfPromotions[index]
                                  self.deletePromotionAPIRequest(objPromotion: objPromotion)
                   }))
            alert.view.tintColor = UIColor.init(hex: "#38B5A3")
                   self.present(alert, animated: true, completion: nil)
            
            
           
        }
    }
    func buttonSeeDetailWithIndex(index: Int) {
        if self.arrayOfPromotions.count > index{
            let objPromotion = self.arrayOfPromotions[index]
            
            if let objStory = self.storyboard?.instantiateViewController(withIdentifier: "PromotionAlertViewController") as? PromotionAlertViewController{
                objStory.modalPresentationStyle = .overFullScreen
                objStory.objPromotion = objPromotion
                self.present(objStory, animated: true, completion: nil)
            }
            
        }
    }
  
}
