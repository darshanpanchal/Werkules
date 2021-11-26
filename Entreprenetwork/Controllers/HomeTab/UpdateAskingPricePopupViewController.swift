//
//  UpdateAskingPricePopupViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 01/04/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

protocol UpdateAskingPriceDelegate {
    func jobBookingdelegate()
}
class UpdateAskingPricePopupViewController: UIViewController {

    
    @IBOutlet weak var lblUpdateAskingPrice:UILabel!
    @IBOutlet weak var lblJOBName:UILabel!
    @IBOutlet weak var lblBusinessName:UILabel!
    @IBOutlet weak var lblCurrentAskingPrice :UILabel!
    @IBOutlet weak var lblJOBRating:UILabel!
    @IBOutlet weak var lblJOBDate:UILabel!
    
    @IBOutlet weak var txtUpdateAskingPrice:UITextField!
    
    
    @IBOutlet weak var containerView:UIView!
    
    var currentJobDetail:[String:Any] = [:]
    
    var delegate:UpdateAskingPriceDelegate?
    
    var currentProvider:NotifiedProviderOffer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.containerView.layer.cornerRadius = 6.0
        self.containerView.clipsToBounds = true
        self.txtUpdateAskingPrice.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //
        DispatchQueue.main.async {
            self.configureCurrentJOBDetails()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let objProvider = currentProvider{
            if objProvider.estimateBudget.count > 0{
                self.lblUpdateAskingPrice.text = "Update Budget"
            }else{
                self.lblUpdateAskingPrice.text = "Enter Agreed Price"
            }
        }
        
    }
    // MARK: - Custom Methods
    func isValid()->Bool{
        
        return true
    }
    func configureCurrentJOBDetails(){
        if let objProvider = currentProvider{
            self.lblJOBName.text = "\(objProvider.title)"
             let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateformatter.date(from: objProvider.createdAt)
             dateformatter.dateFormat = "MM/dd/yyyy"
            self.lblJOBDate.text = dateformatter.string(from: date!)
            self.lblBusinessName.text = "\(objProvider.businessName)"
            self.lblCurrentAskingPrice.text = "\(objProvider.estimateBudget)".add2DecimalString
             if let pi: Double = Double("\(objProvider.rating)"){
                 let rating = String(format:"%.1f", pi)
                self.lblJOBRating.text = "\(rating)"
             }
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonDismissSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func buttonPostSelector(sender:UIButton){
        if let  objnotifiedProvider = self.currentProvider{
                var dict:[String:Any] = [:]
            if objnotifiedProvider.estimateBudget.count > 0{
                if let updatedPrice = self.txtUpdateAskingPrice.text?.trimmingCharacters(in: .whitespacesAndNewlines){
                        dict["asking_price"] = "\(updatedPrice)"
                }
            }else{
                guard let updatedPrice = self.txtUpdateAskingPrice.text?.trimmingCharacters(in: .whitespacesAndNewlines),updatedPrice.count > 0 else{
                     SAAlertBar.show(.error, message:"Please enter the price you have agreed with the provider.".localizedLowercase)
                    return
                }
                 dict["asking_price"] = "\(updatedPrice)"
            }
           
                dict["job_id"] = "\(objnotifiedProvider.jobID)"
                dict["provider_id"] =  "\(objnotifiedProvider.providerID)"
                if objnotifiedProvider.isPreOffer.count > 0{
                    dict["is_pre_offer"] = "\(objnotifiedProvider.isPreOffer)"
                }
            self.callbookjobapireqest(dict: dict)
        }
        
    }
    // MARK: - API Request Methods
    func callbookjobapireqest(dict:[String:Any]){
        
            APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kBookJOB , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                    
                    if let success = responseSuccess as? [String:Any],let arrayOfJOB = success["success_data"] as? [String:Any]{
                        if let _ = self.delegate{
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                                self.delegate!.jobBookingdelegate()
                            }
                            
                        }
                            /*DispatchQueue.main.async {
                                        if let objTabView = self.navigationController?.tabBarController{
                                            print(objTabView.viewControllers)
                                            if let objHomeNavigation:UINavigationController = objTabView.viewControllers?[2] as? UINavigationController{
                                                if let objMyPost:MessagesVC = objHomeNavigation.viewControllers.first as? MessagesVC{
                                                    objTabView.selectedIndex = 2
                                                    //objMyPost.isFromHomeBooking = true
                                                    objMyPost.selectedIndexFromNotification = 1
                                                }
                                            }
                                         }
                                    } */
                               }else{
                                   DispatchQueue.main.async {
                                      // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
   

}
extension UpdateAskingPricePopupViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
                return true
             }
}
