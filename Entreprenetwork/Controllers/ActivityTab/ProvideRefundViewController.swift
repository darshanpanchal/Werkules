//
//  ProvideRefundViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 16/04/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class ProvideRefundViewController: UIViewController {

    
    @IBOutlet fileprivate weak var lblTitle:UILabel!
    @IBOutlet fileprivate weak var buttonBack:UIButton!
    
    
    @IBOutlet fileprivate weak var lblTotalFundAvailable:UILabel!
    @IBOutlet fileprivate weak var lblTotalFundAvailableAmount:UILabel!
    
    @IBOutlet fileprivate weak var txtAmmount:UITextField!
    
    @IBOutlet fileprivate weak var buttonSubmit:UIButton!
    
    var earningAvailable:String = ""
    var withdrawpayment:[String:Any] = [:]
    var isEnable:Bool = false
    var isSubmitEnable:Bool{
        get{
            return isEnable
        }
        set{
            self.isEnable = newValue
            //configure Submit button
            self.configureSubmitButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    func setup(){
        self.isSubmitEnable = false
        self.txtAmmount.delegate = self
        
        if self.earningAvailable.count >  0{
            self.lblTotalFundAvailableAmount.text = "\(self.earningAvailable)"
        }else{
            self.lblTotalFundAvailableAmount.text = "$0.00"
        }
    }
    func isValidData()->Bool{
        guard let offerPrice = self.txtAmmount.text?.trimmingCharacters(in: .whitespacesAndNewlines),offerPrice.count > 0 else{
                        SAAlertBar.show(.error, message:"Please enter Withdrawal Amount".localizedLowercase)
                        return false
                    }
        let dollarTotal = "\(offerPrice)".replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        if let amount = Int.init("\(dollarTotal)"),let earning = Int.init("\(earningAvailable)"){
            if amount <= earning{
                self.withdrawpayment["amount"] = "\(dollarTotal)"
                return true
            }else{
                self.showMaximumAmountAlert()
                //SAAlertBar.show(.error, message:"Please enter Withdrawal Amoun".localizedLowercase)
                return false
            }
        }
        return true
    }
    func showMaximumAmountAlert(){
        DispatchQueue.main.async {
                UIAlertController.showOkAlert(self, aStrMessage: "The amount entered exceeds the funds available", completion: nil)
               }
    }
    func configureSubmitButton(){
        DispatchQueue.main.async {
            self.buttonSubmit.isEnabled = self.isSubmitEnable
            if self.isSubmitEnable{
                self.buttonSubmit.setBackgroundImage(UIImage.init(named: "background_update"), for: .normal)
            }else{
                self.buttonSubmit.setBackgroundImage(nil, for: .normal)
            }
        }
    }
    
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
          self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonSubmitSelector(sender:UIButton){
        if self.isValidData(){
            
        }
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
extension ProvideRefundViewController:UITextFieldDelegate{
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
              let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
              
              guard !typpedString.isContainWhiteSpace() else{
                  return false
              }
             self.isSubmitEnable = typpedString.count > 0
              print("===== \(typpedString)")
              return true
          }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
           if textField == self.txtAmmount{
                      DispatchQueue.main.async {
                        if let text = self.txtAmmount.text{
                            var updatedtext =  text.replacingOccurrences(of: "$", with: "")
                               updatedtext = updatedtext.trimmingCharacters(in: .whitespaces)
                            if updatedtext.count > 0{
                                self.txtAmmount.text = "\(updatedtext)"
                            }
                        }
                      }
           }
           return true
       }
       func textFieldDidEndEditing(_ textField: UITextField) {
           if textField == self.txtAmmount{
                      DispatchQueue.main.async {
                        if let text = self.txtAmmount.text{
                            var updatedtext =  text.replacingOccurrences(of: "$", with: "")
                               updatedtext = updatedtext.trimmingCharacters(in: .whitespaces)
                            if updatedtext.count > 0{
                                self.txtAmmount.text = "$ \(updatedtext)"
                            }else{
                                self.txtAmmount.text = "\(updatedtext)"
                            }
                            
                        }
                      }
           }
       }
}
