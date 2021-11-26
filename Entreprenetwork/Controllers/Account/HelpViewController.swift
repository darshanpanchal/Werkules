//
//  HelpViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 08/01/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    private let kSkip = "HelpViewController_Skip"
    private let kNext = "HelpViewController_Next"
    private let kFont = UIFont.init(name: "Avenir Medium", size: 18)
    private let kFontColor = UIColor.init(hex: "#38B5A3")
    
    
    @IBOutlet weak var objPageController:UIPageControl!
    @IBOutlet weak var buttonSkip:UIButton! //
    @IBOutlet weak var buttonNext:UIButton! //
    
    @IBOutlet weak var collectionViewIntro:UICollectionView!
    
    @IBOutlet fileprivate weak var imageHeader:UIImageView! //providerHelp //cooperation
    @IBOutlet fileprivate weak var lblTitle:UILabel!
    @IBOutlet fileprivate weak var lblDetail:UILabel!
    @IBOutlet fileprivate weak var txtDetail:UITextView!
    
    
    let providerTitle = "Welcome to Werkules and a leg up for your business."
    let providerDetail = ""
    let providerTextViewDetail = "1. Based on the keywords you entered, we are going to provide you with free leads to bid on. This would be a good time to review the keyword(s) you entered, to make sure customers can find you. Ex. If you have a residential or commercial cleaning company, good keywords would be “cleaning” or “maid”..\n\n2. You will be notified when a lead comes in. Only the first 5 providers to respond with an offer will be in the running to get the job, so time is of the essence.\n\n3. You’re good to go! Kick back while we find you new business to bid on."
    
    let customerTitle = "Welcome to Werkules!"
    let customerDetail = "We’re here to help you find the stuff you need when you need it and give you back a little time in your busy day."
    let customerTextViewDetail =
    "1. To start, all you need to do is enter what you’re looking for in the “What can we help you find? search bar.\n\n2. After that, you can sit back and relax while we find providers for what you need.\n\n3. You will be alerted when a provider sends you an offer and you will receive up to 5 offers.\n\n4. You review the offers and select your provider of your choice.\n\nEnjoy!"
    
    var isFromSideMenu = false
    
    var isForVerifiedProvider = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.buttonNext.isHidden = self.isFromSideMenu
        //configure  current user role
        self.configureCurrentUserRole()
        
        if self.isFromSideMenu{
            self.buttonNext.setTitle("OK", for: .normal)
        }else{
            if self.isForVerifiedProvider{
                self.buttonNext.setTitle("NEXT", for: .normal)
            }else{
                self.buttonNext.setTitle("GET STARTED", for: .normal)
            }
            
        }
    }
    
    func configureCurrentUserRole(){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                    
                    return
                }
        if currentUser.userRoleType == .provider{
            self.imageHeader.image = UIImage.init(named: "providerHelp")
            self.lblTitle.text = "\(self.providerTitle)"
            self.lblDetail.text = "\(self.providerDetail)"
            self.txtDetail.text = "\(self.providerTextViewDetail)"
        }else if currentUser.userRoleType == .customer{
           self.imageHeader.image = UIImage.init(named: "cooperation")
            self.lblTitle.text = "\(self.customerTitle)"
           self.lblDetail.text = "\(self.customerDetail)"
           self.txtDetail.text = "\(self.customerTextViewDetail)"
            
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    // MARK: - Setup Methods
    private func setup(){
        
        

    }
 
    // MARK: - Selector Methods
    @IBAction func buttonNextSelector(sender:UIButton){
        
    }
    @IBAction func buttonSkipSelector(sender:UIButton){
        if self.isFromSideMenu{
            self.navigationController?.popViewController(animated: true)
        }else{
            self.pushToCustomerHomeViewController()
            
        }
        
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    //PROVIDER HELP
    func pushToHelpViewController(){
        if let helpViewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomerHelpViewController") as? CustomerHelpViewController{
            self.navigationController?.pushViewController(helpViewController, animated: true)
        }
      
    }
    //PushToHome
    func pushToCustomerHomeViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC  = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let navigationController = UINavigationController(rootViewController:VC)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }
}

extension UIButton{
    func setTitleFontAndColor(title:String,font:UIFont,color:UIColor){
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = font
        self.setTitleColor(color, for: .normal)
    }
}
extension UIPageControl {

    func customPageControl(dotFillColor:UIColor, dotBorderColor:UIColor, dotBorderWidth:CGFloat) {
        for (pageIndex, dotView) in self.subviews.enumerated() {
            if self.currentPage == pageIndex {
                dotView.backgroundColor = dotFillColor
                dotView.layer.cornerRadius = dotView.frame.size.height / 2
            }else{
                dotView.backgroundColor = .clear
                dotView.layer.cornerRadius = dotView.frame.size.height / 2
                dotView.layer.borderColor = dotBorderColor.cgColor
                dotView.layer.borderWidth = dotBorderWidth
            }
        }
    }

}
