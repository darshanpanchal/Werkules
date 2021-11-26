//
//  PaymentSuccessAlertViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 04/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

protocol PaymentSuccessPopupDeledate {
    func buttonHomeselector(isForPartialPayment:Bool)
}
class PaymentSuccessAlertViewController: UIViewController {

    var delegate:PaymentSuccessPopupDeledate?

    var isForPartialPayment:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
      @IBAction func buttonHomeSelector(sender:UIButton){
          if let  _ = self.delegate{
            self.delegate!.buttonHomeselector(isForPartialPayment:isForPartialPayment)
              self.dismiss(animated: true, completion: nil)
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
