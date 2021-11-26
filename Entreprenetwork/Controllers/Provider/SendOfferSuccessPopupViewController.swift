//
//  SendOfferSuccessPopupViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 23/02/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol SendOfferSuccessPopupDeledate {
    func buttonHomeselector()
}

class SendOfferSuccessPopupViewController: UIViewController {

    @IBOutlet weak var lblSuccessMessage:UILabel!
    @IBOutlet weak var lblCustomerDetailMessage:UILabel!
    @IBOutlet weak var btnHome:UIButton!
    
    var delegate:SendOfferSuccessPopupDeledate?
    
    var strSuccessMessage:String = ""
    var customerName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lblSuccessMessage.text  = "\(strSuccessMessage)"
        self.lblCustomerDetailMessage.text  = "Waiting for \(customerName) to respond."
        
    }
    

    // MARK: - Navigation
    @IBAction func buttonHomeSelector(sender:UIButton){
        if let  _ = self.delegate{
            
            self.delegate!.buttonHomeselector()
            self.dismiss(animated: true, completion: nil)
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
   

}
