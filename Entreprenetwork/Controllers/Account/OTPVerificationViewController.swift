//
//  OTPVerificationViewController.swift
//  Entreprenetwork
//
//  Created by IPS-Darshan on 08/09/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol OTPVerificationDelegate {
    func otpSuccessFullVerificationDelegate(customerData:[String:Any])
}
class OTPVerificationViewController: UIViewController, UITextFieldDelegate,CustomTextFieldDelegate {

    var strDynamicText:String = ""
    var customerDetail:[String:Any] = [:]

    var delegate:OTPVerificationDelegate?

    @IBOutlet weak var lblDynamicText:UILabel!
    @IBOutlet weak var txtOTPCode:AEOTPTextField!

    @IBOutlet weak var first:CustomOTPTextField!
    @IBOutlet weak var second:CustomOTPTextField!
    @IBOutlet weak var third:CustomOTPTextField!
    @IBOutlet weak var fourth:CustomOTPTextField!
    @IBOutlet weak var fifth:CustomOTPTextField!
    @IBOutlet weak var sixth:CustomOTPTextField!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.lblDynamicText.text = self.strDynamicText
        self.txtOTPCode.otpDelegate = self
        self.txtOTPCode.configure()
        self.txtOTPCode.textContentType = .oneTimeCode


        self.first.textContentType = .oneTimeCode
//        self.first.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.first.becomeFirstResponder()
        self.first.otpCustomDelegate = self
        self.first.delegate = self
        self.second.delegate = self
        self.second.otpCustomDelegate = self
        self.second.tag = 1
        self.third.delegate = self
        self.third.otpCustomDelegate = self
        self.third.tag = 2
        self.fourth.delegate = self
        self.fourth.otpCustomDelegate = self
        self.fourth.tag = 3
        self.fifth.delegate = self
        self.fifth.otpCustomDelegate = self
        self.fifth.tag = 4
        self.sixth.delegate = self
        self.sixth.otpCustomDelegate = self
        self.sixth.tag = 5

    }

    @objc func textFieldDidChange(_ textField: UITextField) {
           if textField.textContentType == UITextContentType.oneTimeCode{
               //here split the text to your four text fields
               if let otpCode = textField.text, otpCode.count > 5{
                  self.first.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 0)])
                  self.second.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 1)])
                  self.third.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 2)])
                  self.fourth.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 3)])
                  self.fifth.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 4)])
                  self.sixth.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 5)])
               }
           }
     }
    func textFieldDidDelete(index: Int) {
        DispatchQueue.main.async {
            if index == 5{
                self.fifth.text = ""
                self.fifth.becomeFirstResponder()
            }else if index == 4{
                self.fourth.text = ""
                self.fourth.becomeFirstResponder()
            }else if index == 3{
                self.third.text = ""
                self.third.becomeFirstResponder()
            }else if index == 2{
                self.second.text = ""
                self.second.becomeFirstResponder()
            }else if index == 1{
                self.first.text = ""
                self.first.becomeFirstResponder()
            }else{

            }
        }

    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

            //This lines allows the user to delete the number in the textfield.
            if string.isEmpty{
                

                return true
            }
            //----------------------------------------------------------------

            //This lines prevents the users from entering any type of text.
            if Int(string) == nil {
                return false
            }
            //----------------------------------------------------------------

            //This lines lets the user copy and paste the One Time Code.
            //For this code to work you need to enable subscript in Strings https://gist.github.com/JCTec/6f6bafba57373f7385619380046822a0
            if string.count == 6 {
                first.text = "\(string[0])"
                second.text = "\(string[1])"
                third.text = "\(string[2])"
                fourth.text = "\(string[3])"
                fifth.text = "\(string[4])"
                sixth.text = "\(string[5])"

                DispatchQueue.main.async {
                    self.dismissKeyboard()
                    self.validCode()
                }
            }
            //----------------------------------------------------------------

            //This is where the magic happens. The OS will try to insert manually the code number by number, this lines will insert all the numbers one by one in each TextField as it goes In. (The first one will go in normally and the next to follow will be inserted manually)
            if string.count == 1 {
                if (textField.text?.count ?? 0) == 1 && textField.tag == 0{
                    if (second.text?.count ?? 0) == 1{
                        if (third.text?.count ?? 0) == 1{
                            if (fourth.text?.count ?? 0) == 1{
                                if (fifth.text?.count ?? 0) == 1{
                                    sixth.text = string
                                    DispatchQueue.main.async {
                                        self.dismissKeyboard()
                                        self.validCode()
                                    }
                                    return false
                                }else{
                                    fifth.text = string
                                    return false
                                }
                            }else{
                                fourth.text = string
                                return false
                            }
                        }else{
                            third.text = string
                            return false
                        }
                    }else{
                        second.text = string
                        return false
                    }
                }
            }
            //----------------------------------------------------------------


            //This lines of code will ensure you can only insert one number in each UITextField and change the user to next UITextField when function ends.
            guard let textFieldText = textField.text,
                let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                    return false
            }
            let substringToReplace = textFieldText[rangeOfTextToReplace]
            let count = textFieldText.count - substringToReplace.count + string.count


            if count == 1{
                if textField.tag == 0{
                    DispatchQueue.main.async {
                        self.second.becomeFirstResponder()
                    }

                }else if textField.tag == 1{
                    DispatchQueue.main.async {
                        self.third.becomeFirstResponder()
                    }

                }else if textField.tag == 2{
                    DispatchQueue.main.async {
                        self.fourth.becomeFirstResponder()
                    }

                }else if textField.tag == 3{
                    DispatchQueue.main.async {
                        self.fifth.becomeFirstResponder()
                    }

                }else if textField.tag == 4{
                    DispatchQueue.main.async {
                        self.sixth.becomeFirstResponder()
                    }

                }else {
                    DispatchQueue.main.async {
                        self.dismissKeyboard()
                        self.validCode()
                    }
                }
            }

            return count <= 1
            //----------------------------------------------------------------

        }
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    func validCode(){
        print(self.first.text)
        print(self.second.text)
        print(self.third.text)
        print(self.fourth.text)
        print(self.fifth.text)
        print(self.sixth.text)
        self.apiRequestToVerifyOTP(strOTP: "\(self.first.text ?? "")\(self.second.text ?? "")\(self.third.text ?? "")\(self.fourth.text ?? "")\(self.fifth.text ?? "")\(self.sixth.text ?? "")")
    }
    @IBAction func buttonSubmitSelection(sender:UIButton){
        self.apiRequestOnSubmitSelection()
    }

    func apiRequestOnSubmitSelection(){
        //customer/select-verification-type
        var dict:[String:Any] = [:]
        if let objID = self.customerDetail["id"]{
            dict["id"] = "\(objID)"
        }
        dict["is_first_time"] = "false"
        dict["verification_type"] = "sms"

        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCustomerSignUpVerification , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in

            if let success = responseSuccess as? [String:Any], let successMsg = success["success_data"] as? [String]{
                DispatchQueue.main.async {
                    SAAlertBar.show(.error, message:"\(successMsg.first ?? "")")
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
    func apiRequestToVerifyOTP(strOTP:String){
        //customer/select-verification-type
        var dict:[String:Any] = [:]
        if let objID = self.customerDetail["id"]{
            dict["id"] = "\(objID)"
        }
        dict["otp"] = "\(strOTP)"


        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kCustomerOTPVerification , parameter: dict as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in

            if let success = responseSuccess as? [String:Any], let userInfo = success["success_data"] as? [String:Any]{
                DispatchQueue.main.async {
                    let objUser = UserDetail.init(userDetail: userInfo)
                    objUser.setuserDetailToUserDefault()
                    self.dismiss(animated: false, completion: nil)
                    self.delegate?.otpSuccessFullVerificationDelegate(customerData:self.customerDetail)
//                    SAAlertBar.show(.error, message:"\(successMsg.first ?? "")")
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

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }


}
extension OTPVerificationViewController: AEOTPTextFieldDelegate {
    func didUserFinishEnter(the code: String) {

        self.apiRequestToVerifyOTP(strOTP: code)
    }
}
extension StringProtocol {
    subscript(offset: Int) -> Element {
        return self[index(startIndex, offsetBy: offset)]
    }
    subscript(_ range: Range<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence {
        return prefix(range.upperBound.advanced(by: 1))
    }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
        return prefix(range.upperBound)
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence {
        return suffix(Swift.max(0, count - range.lowerBound))
    }
}

extension LosslessStringConvertible {
    var string: String { return .init(self) }
}

extension BidirectionalCollection {
    subscript(safe offset: Int) -> Element? {
        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
        return self[i]
    }
}
protocol CustomTextFieldDelegate{
    func textFieldDidDelete(index:Int)
}
class CustomOTPTextField: UITextField {
  var otpCustomDelegate : CustomTextFieldDelegate!

  override func deleteBackward() {

    print("\(self.text?.count)")
    print("\(self.text)")

    if let textCount = self.text?.count{
        if textCount == 0{
            self.otpCustomDelegate.textFieldDidDelete(index: self.tag)
        }
    }
    super.deleteBackward()

 }
}
