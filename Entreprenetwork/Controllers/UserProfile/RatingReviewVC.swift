//
//  RatingReviewVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 27/09/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import FloatRatingView

class RatingReviewVC: UIViewController,FloatRatingViewDelegate {
    
    @IBOutlet weak var txtViewReviews: UITextView!
    @IBOutlet var floatRatingView: FloatRatingView!
    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var lblUserNameToReview : UILabel!
    
    var currentRatings = Int()
    var jobId = String()
    var fromId = String()
    var toId = String()
    var jobTitle = String()
    var userNameToReview = String()
    
    // MARK: - UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        currentRatings = 0
        floatRatingView.delegate = self
        floatRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        floatRatingView.type = .wholeRatings
        
        lblUserNameToReview.text = self.userNameToReview
    }
    
    // MARK:- FloatRatingViewDelegate
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Double) {
        currentRatings = Int(self.floatRatingView.rating)
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        currentRatings = Int(self.floatRatingView.rating)
    }
    
    // MARK: - User Defined Methods
    
    func validateDate() -> Bool {
        if currentRatings == 0 {
            SAAlertBar.show(.info, message: "please enter ratings.")
            return false
        }
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func btnBackClicked(_ sender : UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnDoneClicked(_ sender: UIButton) {
        
        if validateDate() == true {
            
            let dict = [
                APIManager.Parameter.jobID : self.jobId,
                APIManager.Parameter.fromID : self.fromId,
                APIManager.Parameter.toID : self.toId,
                APIManager.Parameter.review : txtViewReviews.text!,
                APIManager.Parameter.rating : String(currentRatings)
            ]
            
            APIManager.sharedInstance.CallAPIPost(url: Url_saveReview, parameter: dict, complition: { (error, JSONDICTIONARY) in
                
                let isError = JSONDICTIONARY!["isError"] as! Bool
                
                if  isError == false{
                    print(JSONDICTIONARY as Any)
                    self.navigationController?.popViewController(animated: true)
                }
                else{
                    let message = JSONDICTIONARY!["response"] as! String
                    
                    SAAlertBar.show(.error, message:message.capitalized)
                }
            })
        }
    }
}
