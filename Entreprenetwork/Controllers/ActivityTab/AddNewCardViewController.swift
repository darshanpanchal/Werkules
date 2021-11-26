//
//  AddNewCardViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 02/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import Stripe

class AddNewCardViewController: UIViewController {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var backButtton:UIButton!
    @IBOutlet weak var objCollection:UICollectionView!

    //Card Holder Name
    @IBOutlet weak var cardHolderNameShadow:ShadowBackgroundView!
    @IBOutlet weak var cardHolderView:UIView!
    
    
    
    @IBOutlet weak var  txtAddCard:STPPaymentCardTextField!
    @IBOutlet weak var txtCardHolderName:UITextField!
    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet weak var btnAddCard:UIButton!
    
    
    var arrayOfCardName:[String] = ["visa_card","master_card","amex_card"]
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    // MARK: - Setup Methods
    func setup(){
        self.objCollection.delegate = self
        self.objCollection.dataSource = self
        self.objCollection.reloadData()
        
        self.tableView.hideFooter()
        self.tableView.scrollEnableIfTableViewContentIsLarger()
        
        self.cardHolderView.addBordorRadiusWithColor()
        self.txtAddCard.addBordorRadiusWithColor()
    }
    func createToken(){
        guard let offerPrice = self.txtCardHolderName.text?.trimmingCharacters(in: .whitespacesAndNewlines),offerPrice.count > 0 else{
                  SAAlertBar.show(.error, message:"Please enter card holder name".localizedLowercase)
                  return
              }
        if self.txtAddCard.isValid{
            DispatchQueue.main.async {
                   ExternalClass.ShowProgress()
            }
        
            let cardParams: STPCardParams = STPCardParams()
            cardParams.number = self.txtAddCard!.cardNumber
            cardParams.expMonth = UInt(self.txtAddCard!.expirationMonth)
            cardParams.expYear = UInt(self.txtAddCard!.expirationYear)
            cardParams.currency = "USD"
            
            if let name = self.txtCardHolderName.text{
                cardParams.name = "\(name)"
            }
            
            cardParams.cvc = self.txtAddCard!.cvc
            
            print(cardParams.description)
            
            print("Brand Type", STPCardValidator.brand(forNumber: self.txtAddCard!.cardNumber ?? ""))

            STPAPIClient.shared.createToken(withCard: cardParams) { (token: STPToken?, error: Error?) in
                DispatchQueue.main.async {
                       ExternalClass.HideProgress()
                }
                guard let token = token, error == nil else {
                                   // Present error to user...
                                   return
                               }
                
                var dict:[String:Any] = [:]
                
                dict["token"] = "\(token)"
                
                let objfunding = STPCardFundingType.init(rawValue: token.card?.funding.rawValue ?? 0)
                
                if objfunding == .credit{
                    dict["card_type"] = "credit"
                }else if objfunding == .debit{
                    dict["card_type"] = "debit"
                }else if objfunding == .prepaid{
                    dict["card_type"] = "prepaid"
                }else{
                    dict["card_type"] = ""
                }
                print(dict)
                //API Request for save card using stripe
                self.callAPIRequestToSaveCardViaStripe(requestParameters: dict)
            }
        }else{
            DispatchQueue.main.async {
                SAAlertBar.show(.error, message: "Please enter valid card to add your payment method.")
            }
        }
    }
    // MARK: - Selector Methods
       @IBAction func buttonBackSelector(sender:UIButton){
           self.navigationController?.popViewController(animated: true)
       }
    @IBAction func buttonAddCardSelector(sender:UIButton){
        //Create Card Token
        
        self.createToken()
    }
    // MARK: - API Request Methods
    func callAPIRequestToSaveCardViaStripe(requestParameters:[String:Any]){
        
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kPaymentSaveCard , parameter: requestParameters as [String:AnyObject], isHudeShow: true, success: { (responseSuccess) in
                          
                          if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                                        DispatchQueue.main.async {
                                            self.navigationController?.popViewController(animated: true)
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
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
extension AddNewCardViewController:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayOfCardName.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddNewCardCollectionCell", for: indexPath) as! AddNewCardCollectionCell
        
        if self.arrayOfCardName.count > indexPath.item{
            let objImageName = self.arrayOfCardName[indexPath.item]
            collectionCell.imageViewCard.image = UIImage.init(named: "\(objImageName)")
            //collectionCell.imageViewCard.isHidden = true
            //collectionCell.backgroundColor = .red
        }
        return collectionCell
    }
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
         return 20
     }
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return 20
     }
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         
        return CGSize(width: 70.0, height:40.0)
         
     }*/
}
class AddNewCardCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewCard:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.imageViewCard.clipsToBounds = true
            self.imageViewCard.contentMode = .scaleAspectFit
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
