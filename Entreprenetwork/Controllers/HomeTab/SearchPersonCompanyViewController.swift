//
//  SearchPersonCompanyViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 14/05/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol SearchKeywordDelegate {
    func didSelectKeywordWith(response:[String:Any])
}
class SearchPersonCompanyViewController: UIViewController {

    var isForCompany:Bool = false
    var selectedSearchOption:Int = 0 // 0 keyword 1 person 2 company
    
    @IBOutlet weak var searchContainerView:UIView!
    @IBOutlet weak var txtSearch:UITextField!
    @IBOutlet weak var lblHeaderTitle:UILabel!
    @IBOutlet weak var tableViewSearch:UITableView!
    
    @IBOutlet weak var lblSearchKeyworextraText:UILabel!
    
    
    let strKeywordSearch = "Searching by Keyword in Business Providers"
    let strPersonSearch = "Searching by Person in Business Providers"
    let strCompanySearch = "Searching by Company in Business Providers"
    
    var arrayOfDetail:[[String:Any]] = []
    var arrayOfFilterDetail:[[String:Any]] = []
    var delegate:SearchKeywordDelegate?
    
    var selectedTag:Int?
    
    var isLoadMoreSearch:Bool = false
    var currentPage:Int = 1
    var fetchPageLimit:Int = 10

    var isfromCreatePost:Bool = false

    @IBOutlet  var chatViewBottomConstraint : NSLayoutConstraint!
//    var name = ["jonny","denny","ronnny","john","Sam","Genny"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtSearch.delegate = self
        self.txtSearch.keyboardType = .namePhonePad
        self.txtSearch.autocorrectionType = .no
        self.searchContainerView.clipsToBounds = true
        self.searchContainerView.layer.cornerRadius = 17.0
        // Do any additional setup after loading the view.
        if self.selectedSearchOption == 0{
            self.lblSearchKeyworextraText.isHidden = self.isfromCreatePost//false
            self.lblHeaderTitle.text = "\(self.strKeywordSearch)"
        }else if self.selectedSearchOption == 1{
            self.lblSearchKeyworextraText.isHidden = true
            self.lblHeaderTitle.text = "\(self.strPersonSearch)"
        }else if self.selectedSearchOption == 2{
            self.lblSearchKeyworextraText.isHidden = true
            self.lblHeaderTitle.text = "\(self.strCompanySearch)"
        }else {
            self.lblSearchKeyworextraText.isHidden = true
            self.lblHeaderTitle.text = "\(self.strPersonSearch)"
        }
        self.configureTableView()
        
       
        self.arrayOfFilterDetail = self.arrayOfDetail
        self.tableViewSearch.reloadData()
        
        DispatchQueue.main.async {
            self.txtSearch.becomeFirstResponder()
        }
        NotificationCenter.default.addObserver(self,
                                                     selector: #selector(keyboardWillShow(notification:)),
                                                     name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                                     selector: #selector(keyboardWillHide(notification:)),
                                                     name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    func configureTableView(){
          self.tableViewSearch.register(UINib.init(nibName: "UpdatedSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "UpdatedSearchTableViewCell")
          self.tableViewSearch.showsVerticalScrollIndicator = false
          self.tableViewSearch.delegate = self
          self.tableViewSearch.dataSource = self
          self.tableViewSearch.rowHeight = UITableView.automaticDimension
          self.tableViewSearch.estimatedRowHeight = 100.0
          self.tableViewSearch.reloadData()
      }
    @objc func keyboardWillShow(notification: NSNotification) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                          let keyboardRectangle = keyboardFrame.cgRectValue
                          var keyboardHeight = keyboardRectangle.height
                          
                          if keyboardHeight > 350{
                              keyboardHeight = keyboardHeight - 30
                          }
                        self.chatViewBottomConstraint.constant = CGFloat(keyboardHeight)
                      }
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.chatViewBottomConstraint.constant = 10
                self.view.layoutIfNeeded()
            }
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - API Request Methods
    func apiRequestForSearchWithTyppedString(string:String){
        
        var strAPIEndPoint  = kkeyWordSearch
       if self.selectedSearchOption == 0{
            strAPIEndPoint  = kkeyWordSearch
        }else if self.selectedSearchOption == 1{
            strAPIEndPoint  = kPersonSearch
        }else if self.selectedSearchOption == 2{
            strAPIEndPoint  = kCompanySearch
        }else {
            strAPIEndPoint  = kkeyWordSearch
        }
        APIRequestClient.shared.cancelTaskWithUrl { (true) in
            var dict:[String:Any]  = [:]
              dict["keyword"] = "\(string)"
            dict["limit"] = "\(self.fetchPageLimit)"
            dict["page"] = "\(self.currentPage)"
                  APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:strAPIEndPoint , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                                DispatchQueue.main.async {
                                    var typpedText = ""
                                     if let typped = self.txtSearch.text{
                                        typpedText = typped
                                    }
                                    if self.currentPage == 1 || typpedText.count == 0{
                                        self.arrayOfDetail.removeAll()
                                        self.arrayOfFilterDetail.removeAll()
                                        self.tableViewSearch.reloadData()
                                        if typpedText.count == 0{
                                            return
                                        }
                                    }
                                  if let success = responseSuccess as? [String:Any],let arrayReview = success["success_data"] as? [[String:Any]]{
                                    self.isLoadMoreSearch = (arrayReview.count == self.fetchPageLimit)
                                          DispatchQueue.main.async {
                                            self.arrayOfDetail.append(contentsOf: arrayReview)// = arrayReview
                                            self.arrayOfFilterDetail.append(contentsOf: arrayReview) //= arrayReview
                                            self.tableViewSearch.reloadData()
                                          }
                                  }else if let success = responseSuccess as? [String:Any],let arrayReview = success["success_data"] as? [Any]{
                                    self.isLoadMoreSearch = (arrayReview.count == self.fetchPageLimit)
                                    for keyword in arrayReview{
                                        var keywordresponse :[String:Any] = [:]
                                        
                                        keywordresponse["keywords_for_business"] = "\(keyword)".capitalized.components(separatedBy:.whitespacesAndNewlines).filter { $0.count > 0 }.joined(separator: " ")
                                        self.arrayOfDetail.append(keywordresponse)
                                    }
                                    DispatchQueue.main.async {
                                        
                                      self.arrayOfFilterDetail = self.arrayOfDetail
                                      self.tableViewSearch.reloadData()
                                    }
                                     }else{
                                         DispatchQueue.main.async {
                                            self.isLoadMoreSearch = false
                                            self.tableViewSearch.reloadData()
                                            // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                         }
                                     }
                                }
                                 }) { (responseFail) in
                                        DispatchQueue.main.async {
                                            self.resetToDefalt()
                               if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String]{
                                      
                                          if errorMessage.count > 0{
                                              SAAlertBar.show(.error, message:"\(errorMessage.first!)".localizedLowercase)
                                          }
                                      
                                  }else{
                                         DispatchQueue.main.async {
                                            // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                         }
                                     }
                                        }
                                 }
        }
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
extension SearchPersonCompanyViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfFilterDetail.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpdatedSearchTableViewCell") as! UpdatedSearchTableViewCell
         cell.tag = indexPath.row
        if self.arrayOfFilterDetail.count > indexPath.row{
            let objJSON = self.arrayOfFilterDetail[indexPath.row]
            if self.selectedSearchOption == 0{
                
                    if let keywordName = objJSON["keywords_for_business"]{
                        cell.lblName.text  = "\(keywordName)"
                    }
               }else if self.selectedSearchOption == 1{
               
                   if let firstname = objJSON["firstname"],let lastname = objJSON["lastname"]{
                       cell.lblName.text  = "\(firstname) \(lastname)"
                    
                   }
                if let profilePic =  objJSON["profile_pic"],let imageURL = URL.init(string: "\(profilePic)"){
                    cell.imageUser!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                }
               }else if self.selectedSearchOption == 2{
              
                   if let firstname = objJSON["business_name"]{
                       cell.lblName.text  = "\(firstname)"
                   }
                if let profilePic =  objJSON["business_logo"],let imageURL = URL.init(string: "\(profilePic)"){
                                   cell.imageUser!.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                               }
               }else {
               }
            if indexPath.row+1 == self.arrayOfFilterDetail.count, self.isLoadMoreSearch{ //last index
                  DispatchQueue.global(qos: .background).async {
                     self.currentPage += 1
                    DispatchQueue.main.async {
                        if let currenttext = self.txtSearch.text,currenttext.count > 0{
                            self.apiRequestForSearchWithTyppedString(string: self.txtSearch.text ?? "")
                        }else{
                            self.resetToDefalt()
                        }
                    }
                  }
            }
        }
        cell.viewImageView.isHidden = (self.selectedSearchOption == 0)
        return cell
    }
    func resetToDefalt(){
        DispatchQueue.main.async {
            self.currentPage = 1
            self.isLoadMoreSearch = false
            self.arrayOfFilterDetail.removeAll()
            self.arrayOfDetail.removeAll()
            self.tableViewSearch.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           if self.arrayOfFilterDetail.count > indexPath.row{
                 var objJSON = self.arrayOfFilterDetail[indexPath.row]
            print("didSelectRowAt \(objJSON)")
            if let  _ = self.delegate, self.selectedSearchOption == 0{ //keyword
                DispatchQueue.main.async {
                    self.view.endEditing(true)
                    self.navigationController?.popViewController(animated: false)
                    if let _ = self.selectedTag{
                        objJSON["selectedTag"] = self.selectedTag!
                    }
                    self.delegate!.didSelectKeywordWith(response: objJSON)
                }
            }
            DispatchQueue.main.async {
                if let id = objJSON["provider_id"]{
                    self.pushToProviderDetailScreenWithProviderId(providerID: "\(id)")
                }
            }
        }
    }
    func pushToProviderDetailScreenWithProviderId(providerID:String){
           let objStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
           if let objProviderDetail = objStoryboard.instantiateViewController(withIdentifier: "ProviderDetailViewController") as? ProviderDetailViewController{
               objProviderDetail.hidesBottomBarWhenPushed = true
               objProviderDetail.providerID = providerID
               objProviderDetail.isFromSearchPersonCompany = true
            objProviderDetail.showBookNowButton = true
               self.view.endEditing(true)
               self.navigationController?.pushViewController(objProviderDetail, animated: true)
           }
       }
}
extension SearchPersonCompanyViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        guard typpedString.count > 0 else {
            DispatchQueue.main.async {
                APIRequestClient.shared.cancelTaskWithUrl { (true) in
                    DispatchQueue.main.async {
                        self.resetToDefalt()
                    }
                }
            }
            return true
        }
        DispatchQueue.main.async {
            self.resetToDefalt()
            APIRequestClient.shared.cancelTaskWithUrl { (true) in
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                    self.apiRequestForSearchWithTyppedString(string: typpedString)
                }
            }
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
       
        DispatchQueue.main.async {
            APIRequestClient.shared.cancelTaskWithUrl { (true) in
                DispatchQueue.main.async{
                    self.resetToDefalt()
                    textField.resignFirstResponder()
                }
            }
        }
        return true
    }
}
