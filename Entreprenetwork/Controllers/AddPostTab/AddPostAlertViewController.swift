//
//  AddPostAlertViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 12/01/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol AddPostAlertDelegate {
    func buttonOkaySelector(arrayOfProvider:[NotifiedProviderOffer])
    func widenSearchSelector(requestParameters:[String:Any])
    func goToHomeSelector()
}

class AddPostAlertViewController: UIViewController {

    var arrayOfNotifiedProvider:[NotifiedProviderOffer] = []
    
    var delegate:AddPostAlertDelegate?
    @IBOutlet fileprivate weak var lblTitle:UILabel!
    @IBOutlet fileprivate weak var lblDetail:UILabel!
    
    @IBOutlet fileprivate weak var buttonOkay:UIButton!
    @IBOutlet fileprivate weak var buttonWidenSearch:UIButton!
    @IBOutlet fileprivate weak var buttonGoToHome:UIButton!
    
    @IBOutlet fileprivate weak var topConstraintOfImage:NSLayoutConstraint!
    @IBOutlet fileprivate weak var hieghtOfImageView:NSLayoutConstraint!
    
    var isForWiddenSearch :Bool = false
    var requestParameters:[String:Any] = [:]
    
    @IBOutlet fileprivate weak var imageHeader:UIImageView! //sad face for widen search and correct for else
    
    
    let strTitle = "Providers will be sending offers shortly!"
    let strDetail = "You can also book any provider directly without waiting for an offer"
    
    let strTitle1 = "We are unable to find providers within your current travel time. Widen Search to select a new travel time."//"Your Job has been posted successfully!"
    let strDetail1 = ""//"Unfortunately we didn't found any provider match for you, We will notifiy you shortly as soon as we have any match for you."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonWidenSearch.setTitle("WIDEN SEARCH", for: .normal)
        self.buttonGoToHome.setTitle("HOME", for: .normal)
        self.imageHeader.tintColor = UIColor.init(hex: "#195E68")
        self.lblDetail.textColor = UIColor.black
        if self.isForWiddenSearch{
            self.hieghtOfImageView.constant = 85.0
            self.topConstraintOfImage.constant = 40.0
            self.imageHeader.image = UIImage.init(named: "sad_face")
            self.lblTitle.text = "\(self.strTitle1)"
            self.lblDetail.text = "\(self.strDetail1)"
            self.buttonOkay.isHidden = true
            self.buttonWidenSearch.isHidden = false
            self.buttonGoToHome.isHidden = false
        }else{
            self.hieghtOfImageView.constant = 110.0
            self.topConstraintOfImage.constant = 10.0
            self.imageHeader.image = UIImage.init(named: "correct")
            self.lblTitle.text = "\(self.strTitle)"
            self.lblDetail.text = "\(self.strDetail)"
            self.buttonOkay.isHidden = false
            self.buttonWidenSearch.isHidden = true
            self.buttonGoToHome.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    @IBAction func buttonOkaySelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonOkaySelector(arrayOfProvider:self.arrayOfNotifiedProvider)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    @IBAction func buttonGoToHomeSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.goToHomeSelector()
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func buttonWiddenSearchSelector(sender:UIButton){
           if let _ = self.delegate{
            self.delegate!.widenSearchSelector(requestParameters: self.requestParameters)
            DispatchQueue.main.async {
                
               self.dismiss(animated: true, completion: nil)
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
