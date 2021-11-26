//
//  PhoneEmailVerificationAlertViewController.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 07/09/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol PhoneEmailDelegate {
    func smsEmailVerifiedDelegate(isTextOptionSelection:Bool,customerData:[String:Any],strText:String)
}
class PhoneEmailVerificationAlertViewController: UIViewController {


    var delegate:PhoneEmailDelegate?

    var strDynamicText:String = ""
    var strMobileNumber:String = ""
    var strEmailAddress:String = ""
    var customerDetail:[String:Any] = [:]

    @IBOutlet weak var lblDynamicText:UILabel!
    @IBOutlet weak var lblMobileNumber:UILabel!
    @IBOutlet weak var lblEmailNumber:UILabel!

    @IBOutlet weak var imageMobile:UIImageView!
    @IBOutlet weak var imageEmail:UIImageView!


    var isForBusinessSignUp:Bool = false
    var textSelection:Bool = true
    var isTextOptionSelection:Bool{
        get{
            return textSelection
        }
        set{
            self.textSelection = newValue
            DispatchQueue.main.async {
                //Configure Update
                self.configureUpdateSelection()
            }

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.isTextOptionSelection = true
        self.lblDynamicText.text = self.strDynamicText
        self.lblMobileNumber.text = "(***)-(***)-\(self.strMobileNumber.suffix(4))"
        self.lblEmailNumber.text = self.getUpdateEmail()//"\(self.strEmailAddress)"
        self.imageEmail.tintColor = UIColor.init(named: "dark_green")
        self.imageMobile.tintColor = UIColor.init(named: "dark_green")
    }
    func getUpdateEmail()->String{
        let updated = self.strEmailAddress.components(separatedBy: "@")
        print("\(updated)")
        if updated.first?.count == 1{
            return "*@\(updated.last ?? "")"
        }else if updated.first?.count == 2{
            let array = Array.init("\(updated.first!)")
            return "\(array[0])*@\(updated.last ?? "")"
        }else if updated.first?.count == 3{
            let array = Array.init("\(updated.first!)")
            return "\(array[0])**@\(updated.last ?? "")"
        }else if updated.first!.count  > 3{
            let array = Array.init("\(updated.first!)")
            if array.count > 4{
                return "\(array[0])\(array[1])\(array[2])\(array[3])***@\(updated.last ?? "")"
            }else if array.count > 3{
                return "\(array[0])\(array[1])\(array[2])***@\(updated.last ?? "")"
            }else{
                return "\(array[0])***@\(updated.last ?? "")"
            }
        }else{
            return "*@\(updated.last ?? "")"
        }


    }
    func configureUpdateSelection(){
        if self.isTextOptionSelection{
            self.lblMobileNumber.textColor = UIColor(named: "dark_green")
            self.lblEmailNumber.textColor = UIColor.black
            self.imageMobile.image = UIImage.init(named: "radio_check_update")?.withRenderingMode(.alwaysTemplate)
            self.imageEmail.image = UIImage.init(named: "radio_uncheck")

        }else{
            self.lblMobileNumber.textColor = UIColor.black
            self.lblEmailNumber.textColor = UIColor(named: "dark_green")
            self.imageMobile.image = UIImage.init(named: "radio_uncheck")
            self.imageEmail.image = UIImage.init(named: "radio_check_update")?.withRenderingMode(.alwaysTemplate)
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonTextSelection(sender:UIButton){

        self.isTextOptionSelection = true
    }
    @IBAction func buttonEmailSelection(sender:UIButton){
        self.isTextOptionSelection = false
    }
    @IBAction func buttonSubmitSelection(sender:UIButton){
        self.apiRequestOnSubmitSelection()
    }
    // MARK: - API REQUEST
    func apiRequestOnSubmitSelection(){
        //customer/select-verification-type
        var dict:[String:Any] = [:]
        if let objID = self.customerDetail["id"]{
            dict["id"] = "\(objID)"
        }
        dict["is_adding_business_profile"] = "\(self.isForBusinessSignUp)"
        dict["is_first_time"] = "true"
        dict["verification_type"] = self.isTextOptionSelection ? "sms":"email"
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCustomerSignUpVerification , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in

            if let success = responseSuccess as? [String:Any], let successMsg = success["success_data"] as? [String]{
                DispatchQueue.main.async {
                    self.dismiss(animated: false , completion: nil)
                    self.delegate?.smsEmailVerifiedDelegate(isTextOptionSelection: self.isTextOptionSelection, customerData: self.customerDetail, strText: "\(successMsg.first ?? "")")
                }
            }
        }){ (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String]{
                DispatchQueue.main.async {
                    if errorMessage.count > 0{
                        SAAlertBar.show(.error, message:"\(errorMessage.first!)")
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
