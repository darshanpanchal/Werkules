//
//  StripeValidationViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 15/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class StripeValidationViewController: UIViewController {

    @IBOutlet fileprivate weak var buttonback:UIButton!
    @IBOutlet fileprivate weak var tableViewStripevalidation:UITableView!
    
    
    @IBOutlet fileprivate weak var txtDateOfBirth:UITextField!
    @IBOutlet fileprivate weak var txtSSN:UITextField!
    @IBOutlet fileprivate weak var txtIndustry:UITextField!
    @IBOutlet fileprivate weak var txtBusinessWebsite:UITextField!
    
    @IBOutlet fileprivate weak var butonSubmit:UIButton!
    
    var fromDatePicker:UIDatePicker = UIDatePicker()
    var fromDatePickerToolbar:UIToolbar = UIToolbar()
    
    
    var businessCategory = ""
    var currentbusinessCategory:String{
            get{
                return  businessCategory
            }
            set{
                self.businessCategory = newValue
                
            }
    }
    
    var businessCategoryPicker:UIPickerView = UIPickerView()
    var businessCategoryToolbar:UIToolbar = UIToolbar()
    
    
    var addStripevalidationParameters:[String:Any] = [:]
    var arrayOfIndustry:[Industry] = []
    
    var selectedIndustry:[Industry]?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //setup
        self.setup()
        
        //configure tableview
        self.configureTableView()
        
        
        self.getIndustryTypeAPIRequest()
    }
    
    
    // MARK: - User and Validation Methods
    func setup(){
        
        self.configureFormDatePicker()
        
        self.configureIndustryPicker()
        
    }
    func isvalidData()-> Bool{
        
        guard let dob = self.txtDateOfBirth.text?.trimmingCharacters(in: .whitespacesAndNewlines),dob.count > 0 else{
                   SAAlertBar.show(.error, message:"Please enter Date of Birth".localizedLowercase)
                   return false
               }
        self.addStripevalidationParameters["date_of_birth"] = "\(dob)"
        guard let ssn = self.txtSSN.text?.trimmingCharacters(in: .whitespacesAndNewlines),ssn.count > 0 else{
                        SAAlertBar.show(.error, message:"Please enter SSN".localizedLowercase)
                        return false
        }
        guard self.isValidSSN(testStr: ssn) else {
             SAAlertBar.show(.error, message:"Please enter valid SSN".localizedLowercase)
            return false
        }
        self.addStripevalidationParameters["ssn"] = "\(ssn)"
        
        guard let industry = self.txtIndustry.text?.trimmingCharacters(in: .whitespacesAndNewlines),industry.count > 0 else{
                          SAAlertBar.show(.error, message:"Please enter industry".localizedLowercase)
                          return false
            }
        self.configureSelectedBusinessCategoryActive()
        //self.addStripevalidationParameters["industry_type"] = "\(industry)"
        
        guard let website = self.txtBusinessWebsite.text?.trimmingCharacters(in: .whitespacesAndNewlines),website.count > 0 else{
                              SAAlertBar.show(.error, message:"Please enter website".localizedLowercase)
                              return false
                }
        guard self.canOpenURL(website) else {
                    SAAlertBar.show(.error, message:"Please enter valid website".localizedLowercase)
                   return false
               }
        
        self.addStripevalidationParameters["business_website"] = "\(website)"
        
        return true
    }
    func isValidSSN(testStr:String) -> Bool {
         let emailRegEx = "^(?!000|666)[0-8][0-9]{2}(?!00)[0-9]{2}(?!0000)[0-9]{4}$"
         let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
         return emailTest.evaluate(with: testStr)
     }
    func canOpenURL(_ string: String?) -> Bool {
        guard let urlString = string,
            let url = URL(string: urlString)
            else { return false }

        if !UIApplication.shared.canOpenURL(url) { return false }

        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    func configureTableView(){
        self.tableViewStripevalidation.hideFooter()
    }
    func configureIndustryPicker(){
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)

           self.businessCategoryToolbar.sizeToFit()
               self.businessCategoryToolbar.layer.borderColor = UIColor.clear.cgColor
               self.businessCategoryToolbar.layer.borderWidth = 1.0
               self.businessCategoryToolbar.clipsToBounds = true
               self.businessCategoryToolbar.backgroundColor = UIColor.white
               self.businessCategoryPicker.delegate = self
               self.businessCategoryPicker.dataSource = self
               
               
               let doneBusinesCategoryPicker = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(StripeValidationViewController.doneBusinesCategoryPicker))
               let title2 = UILabel.init()
               title2.attributedText = NSAttributedString.init(string: "Category", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
               
               title2.sizeToFit()
               
               let cancelButton2 = UIBarButtonItem(title:"Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(StripeValidationViewController.cancelFormDatePicker))

               self.businessCategoryToolbar.setItems([cancelButton2,spaceButton,UIBarButtonItem.init(customView: title2),spaceButton,doneBusinesCategoryPicker], animated: false)
               
               self.businessCategoryPicker.tag = 2
               self.txtIndustry.inputView = self.businessCategoryPicker
               self.txtIndustry.inputAccessoryView = self.businessCategoryToolbar
    }
    @objc func doneBusinesCategoryPicker(){
        self.configureSelectedBusinessCategoryActive()
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    func configureSelectedBusinessCategoryActive(){
                  DispatchQueue.main.async {
                      self.txtIndustry.text = self.currentbusinessCategory
                   let filterArray = self.arrayOfIndustry.filter{$0.name == self.currentbusinessCategory}
                   if filterArray.count > 0{
                       self.addStripevalidationParameters["industry_type"] = filterArray.first!.value
                   }
                  }
              }
    
    func configureFormDatePicker(){
            
            self.fromDatePickerToolbar.sizeToFit()
            self.fromDatePickerToolbar.layer.borderColor = UIColor.clear.cgColor
            self.fromDatePickerToolbar.layer.borderWidth = 1.0
            self.fromDatePickerToolbar.clipsToBounds = true
            self.fromDatePickerToolbar.backgroundColor = UIColor.white
            self.fromDatePicker.datePickerMode = .date
            self.fromDatePicker.maximumDate = Date()
            
            let doneButton = UIBarButtonItem(title:"done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(StripeValidationViewController.doneFormDatePicker))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            
            let title = UILabel.init()
            title.attributedText = NSAttributedString.init(string: "Date of birth", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
            
            title.sizeToFit()
            let cancelButton = UIBarButtonItem(title:"Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(StripeValidationViewController.cancelFormDatePicker))
            self.fromDatePickerToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
            
            
            self.txtDateOfBirth.inputView = self.fromDatePicker
            self.txtDateOfBirth.inputAccessoryView = self.fromDatePickerToolbar
        }
        @objc func doneFormDatePicker(){
            let date =  self.fromDatePicker.date
                self.addStripevalidationParameters["date_of_birth"] = date.ddMMyyyy
                DispatchQueue.main.async {
                    self.txtDateOfBirth.text = date.ddMMyyyy
                    self.txtDateOfBirth.resignFirstResponder()
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
    
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonSubmitSelector(sender:UIButton){
        if self.isvalidData(){
            self.submitStripeValidationAPIRequest()
        }
    }
    @IBAction func buttonSelectIndustry(sender:UIButton){
        self.presentClassSearchViewController()
    }
    // MARK: - API Request Methods
    func getIndustryTypeAPIRequest(){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .GET, queryString:kGETIndustryType , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [[String:Any]]{
                           if userInfo.count > 0 {
                               DispatchQueue.main.async {
                                self.arrayOfIndustry.removeAll()
                                for obj in userInfo{
                                    let objIndustry = Industry.init(detail: obj)
                                    self.arrayOfIndustry.append(objIndustry)
                                }
                                let firstIndex:[String:Any] = userInfo[0]
                                if let name = firstIndex["name"]{
                                    self.currentbusinessCategory = "\(name)"
                                    self.configureSelectedBusinessCategoryActive()
                                }
                                
                                   //SAAlertBar.show(.error, message:"\(userInfo[0])".localizedLowercase)
                               }
                           }
                          }else{
                              DispatchQueue.main.async {
                                  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
    func submitStripeValidationAPIRequest(){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kPostStripevalidation , parameter: self.addStripevalidationParameters as? [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                   if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                                
                    }else{
                                     DispatchQueue.main.async {
                                         SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func presentClassSearchViewController(){
           DispatchQueue.main.async {
            
            if let schoolClassPicker = UIStoryboard.activity.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
                   schoolClassPicker.modalPresentationStyle = .overFullScreen
                   schoolClassPicker.objSearchType = .Industry
                   schoolClassPicker.arrayOfIndustry = self.arrayOfIndustry
                   self.view.endEditing(true)
                   schoolClassPicker.delegate = self
                   schoolClassPicker.isSingleSelection = true
                if let selected = self.selectedIndustry, selected.count > 0 {
                    schoolClassPicker.selectedIndustry = NSMutableSet.init(array:selected)
                }
                   self.present(schoolClassPicker, animated: true, completion: nil)
               }
           }
       }

}
extension StripeValidationViewController:SearchViewDelegate{
    func didSelectValuesFromSearchView(values: [Any],searchType:SearchType) {
        if searchType == .Industry{
            if let arrayOfIndustry = values as? [Industry]{
                if arrayOfIndustry.count > 0{
                    self.selectedIndustry = arrayOfIndustry
                    self.currentbusinessCategory = arrayOfIndustry.first!.name
                    self.configureSelectedBusinessCategoryActive()
                }
            }
        }
    }
}
extension StripeValidationViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
        return self.arrayOfIndustry[row].name
       }
       func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
           return UIScreen.main.bounds.width
       }
       func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
           return 30.0
       }
       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      
        return self.arrayOfIndustry.count
          
       }
       func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1
       }
       func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        self.currentbusinessCategory = self.arrayOfIndustry[row].name
       }
}
class Industry:NSObject{
    var value = "", name = "", code:String = ""
   init(detail:[String:Any]){
        if let value = detail["code"]{
            self.code  = "\(value)"
        }
        if let value = detail["name"]{
            self.name  = "\(value)"
        }
        if let value = detail["value"]{
            self.value  = "\(value)"
        }
    }
}
