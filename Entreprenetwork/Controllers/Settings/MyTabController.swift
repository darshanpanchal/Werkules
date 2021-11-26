//
//  MyTabController.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 06/08/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
let kHeightOfTabBar:CGFloat = 5.0

class MyTabController: UITabBarController,UITabBarControllerDelegate {
    
    fileprivate lazy var defaultTabBarHeight = { tabBar.frame.size.height}()

    var customeView:UIButton?
    var animationViewTag = 100
    var numberOfTab:Int{
        get{
            return self.tabBar.items?.count ?? 4
        }
    }
    @IBOutlet  weak var imageViewFeed:UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            self.tabBar.standardAppearance = appearance
//            self.tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
        // Do any additional setup after loading the view.
        self.delegate = self
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let newTabBarHeight = defaultTabBarHeight + kHeightOfTabBar
        var newFrame = self.tabBar.frame
        newFrame.size.height = newTabBarHeight
        newFrame.origin.y = view.frame.size.height - newTabBarHeight
        self.tabBar.frame = newFrame
        DispatchQueue.main.async {
            self.imageViewFeed.backgroundColor = UIColor.clear
            if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first{
                let bottompedding = window.safeAreaInsets.bottom

                self.imageViewFeed.frame =  CGRect.init(x: UIScreen.main.bounds.width-UIScreen.main.bounds.width/CGFloat(self.numberOfTab), y: 0, width: CGFloat(self.numberOfTab), height: self.defaultTabBarHeight+kHeightOfTabBar - bottompedding)
            }
            self.tabBar.addSubview(self.imageViewFeed)
        }
       
    }
    func addAnimatedCustomView(){
        DispatchQueue.main.async {
            if let viewWithTag = self.tabBar.viewWithTag(self.animationViewTag) {
                viewWithTag.layer.removeAllAnimations()
                viewWithTag.removeFromSuperview()
            }
            self.view.layoutIfNeeded()
            //self.removeCustomView()
            self.customeView = UIButton.init(frame: CGRect.init(x: UIScreen.main.bounds.width/CGFloat(self.numberOfTab), y: 0, width: UIScreen.main.bounds.width/CGFloat(self.numberOfTab), height: self.defaultTabBarHeight + 10.0))
//            self.customeView?.backgroundColor = UIColor.red
            self.customeView?.alpha = 0.5
            let changeColor = CATransition()
            changeColor.duration = 1
            changeColor.type = .fade
            changeColor.repeatCount = Float.infinity
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.customeView?.layer.add(changeColor, forKey: nil)
                self.customeView?.backgroundColor = .green
            }
//            self.customeView?.backgroundColor = UIColor.green.withAlphaComponent(0.5)
            CATransaction.commit()
            self.customeView?.tag = self.animationViewTag
            self.customeView?.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
            
            self.tabBar.addSubview(self.customeView!)
        }

        
    }
   @objc func buttonClicked() {
        self.selectedIndex = 1
        //self.removeCustomView()
        self.getMyPostCountAPIRequest()
    }
    func removeCustomView(){
        DispatchQueue.main.async {
            if let viewWithTag = self.tabBar.viewWithTag(self.animationViewTag) {
                viewWithTag.layer.removeAllAnimations()
                viewWithTag.removeFromSuperview()
            }
        }
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

          
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            //self.removeCustomView()
        }
    }
    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Selected item \(self.selectedIndex)")
       
        if let _ = self.viewControllers{
            let objSelectedView = self.viewControllers![self.selectedIndex]
            if let objHomeNavigation = objSelectedView as? UINavigationController,let objHome = objHomeNavigation.viewControllers.first as? HomeVC{
                                  objHome.arrayOfProvidersNotified = []
            }
        }
        if let name = item.title{
            if name == "My Posts"{
                self.getMyPostCountAPIRequest()
            }
        }

        
    }
    func getMyPostCountAPIRequest(){
        APIRequestClient.shared.sendAPIRequest(requestType: .GET, queryString:kGETCustomerMyPostCount , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                 if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                                    DispatchQueue.main.async {
                                        
                                        if let dict = userInfo as? NSDictionary{
                                            NotificationCenter.default.post(name: .updateMyPostTab, object: nil,userInfo: userInfo)
                                        }
                                        /*
                                        if let makeOffer = userInfo["make_offer"]{
                                            
                                            if "\(makeOffer)" == "0"{
                                                NotificationCenter.default.post(name: .updateMyJobTab, object: nil)
                                            }
                                        }*/
                                    }
                                
                               }else{
                                   DispatchQueue.main.async {
                                     //  SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
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
                                       //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                   }
                               }
                           }
    }
    
    //func to perform spring animation on imageview
    func performSpringAnimation(imgView: UIImageView) {

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {

            imgView.transform = CGAffineTransform.init(scaleX: 1.4, y: 1.4)

            //reducing the size
            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                imgView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { (flag) in
            }
        }) { (flag) in

        }
    }
    // UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        if let objHomeNavigation = viewController as? UINavigationController,let objHome = objHomeNavigation.viewControllers.first as? HomeVC{
//                              objHome.arrayOfProvidersNotified = []
//        }
        
        print("didSelect \(viewController)")
        /*
        if tabBarController.selectedIndex != 1 {
            UserDefaults.standard.set(tabBarController.selectedIndex, forKey: "lastSelectedTabIndex")
        }
        
        if tabBarController.selectedIndex == 3 {
            let vc = viewController as! UINavigationController
            print(vc.viewControllers)
            let myVC = vc.viewControllers.first as! ActivityVC
            myVC.scrollToTop()
           
            NotificationCenter.default.post(name: Notification.Name("RefreshscreenNotification"), object: nil)
        }
        
        if tabBarController.selectedIndex == 1 || tabBarController.selectedIndex == 2 {
            
            if UserSettings.isUserLogin == false {
                
                let alert = UIAlertController(title: AppName, message: "please login to proceed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                    print("default")
                    self.tabBar.isHidden = false
                    tabBarController.selectedIndex = 0
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }*/
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
class ProviderTabController: UITabBarController  {
    fileprivate lazy var defaultTabBarHeight = { tabBar.frame.size.height }()

    var customeView:UIButton?
    var animationViewTag = 100

    var numberOfTab:Int{
        get{
            return self.tabBar.items?.count ?? 4
        }
    }
     override func viewDidLoad() {
            super.viewDidLoad()
            
            // Do any additional setup after loading the view.
            self.delegate = self
            //self.addAnimatedCustomView()
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            tabBar.standardAppearance = appearance
//            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
        }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let newTabBarHeight = defaultTabBarHeight + kHeightOfTabBar
        var newFrame = self.tabBar.frame
        newFrame.size.height = newTabBarHeight
        newFrame.origin.y = view.frame.size.height - newTabBarHeight
        self.tabBar.frame = newFrame
        
    }
        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()

        }
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          DispatchQueue.main.async {
              //self.removeCustomView()
          }
      }
        // UITabBarDelegate
        override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
            print("Selected item \(self.selectedIndex)")
            if let name = item.title{
                if name == "My Jobs"{
                    self.getMyJOBCountAPIRequest()
                }
            }

                
            
           // self.removeCustomView()
            
        }
    func addAnimatedCustomView(){
        DispatchQueue.main.async {
            if let viewWithTag = self.tabBar.viewWithTag(self.animationViewTag) {
                         viewWithTag.layer.removeAllAnimations()
                         viewWithTag.removeFromSuperview()
                     }
        self.view.layoutIfNeeded()
          //self.removeCustomView()

            self.customeView = UIButton.init(frame: CGRect.init(x: UIScreen.main.bounds.width/CGFloat(self.numberOfTab), y: 0, width: UIScreen.main.bounds.width/CGFloat(self.numberOfTab), height: self.defaultTabBarHeight))
          self.customeView?.backgroundColor = UIColor.clear
          self.customeView?.alpha = 0.5
          let changeColor = CATransition()
          changeColor.duration = 1
          changeColor.type = .fade
          changeColor.repeatCount = Float.infinity
          CATransaction.begin()
          CATransaction.setCompletionBlock {
              self.customeView?.layer.add(changeColor, forKey: nil)
              self.customeView?.backgroundColor = .yellow
              
          }
          self.customeView?.backgroundColor = .green
          CATransaction.commit()
          self.customeView?.tag = self.animationViewTag
          self.customeView?.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)

          self.tabBar.addSubview(self.customeView!)
        }
      }
    
    func addGreenAnimatedCustomView(){
        DispatchQueue.main.async {
            if let viewWithTag = self.tabBar.viewWithTag(self.animationViewTag) {
                         viewWithTag.layer.removeAllAnimations()
                         viewWithTag.removeFromSuperview()
                     }
              self.view.layoutIfNeeded()
              //self.removeCustomView()
            self.customeView = UIButton.init(frame: CGRect.init(x: UIScreen.main.bounds.width/CGFloat(self.numberOfTab), y: 0, width: UIScreen.main.bounds.width/CGFloat(self.numberOfTab), height: self.defaultTabBarHeight))
              self.customeView?.backgroundColor = UIColor.clear
              self.customeView?.alpha = 0.5
              let changeColor = CATransition()
              changeColor.duration = 1
              changeColor.type = .fade
              changeColor.repeatCount = Float.infinity
              CATransaction.begin()
              CATransaction.setCompletionBlock {
                  self.customeView?.layer.add(changeColor, forKey: nil)
                  self.customeView?.backgroundColor = .green
                  
              }
              //self.customeView?.backgroundColor = .green
              CATransaction.commit()
              self.customeView?.tag = self.animationViewTag
              self.customeView?.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)

              self.tabBar.addSubview(self.customeView!)
        }
    }
    func addYellowAnimatedCustomView(){
        DispatchQueue.main.async {
            if let viewWithTag = self.tabBar.viewWithTag(self.animationViewTag) {
                         viewWithTag.layer.removeAllAnimations()
                         viewWithTag.removeFromSuperview()
                     }
              self.view.layoutIfNeeded()
              //self.removeCustomView()
            self.customeView = UIButton.init(frame: CGRect.init(x: UIScreen.main.bounds.width/CGFloat(self.numberOfTab), y: 0, width: UIScreen.main.bounds.width/CGFloat(self.numberOfTab), height: self.defaultTabBarHeight))
              self.customeView?.backgroundColor = UIColor.clear
              self.customeView?.alpha = 0.5
              let changeColor = CATransition()
              changeColor.duration = 1
              changeColor.type = .fade
              changeColor.repeatCount = Float.infinity
              CATransaction.begin()
              CATransaction.setCompletionBlock {
                  self.customeView?.layer.add(changeColor, forKey: nil)
                  self.customeView?.backgroundColor = .yellow
                  
              }
              //self.customeView?.backgroundColor = .green
              CATransaction.commit()
              self.customeView?.tag = self.animationViewTag
              self.customeView?.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)

              self.tabBar.addSubview(self.customeView!)
        }
    }
    
    
     @objc func buttonClicked() {
        DispatchQueue.main.async {
            self.selectedIndex = 1
            self.getMyJOBCountAPIRequest()
//            self.removeCustomView()
        }
        
        
      }
      func removeCustomView(){
          if let viewWithTag = self.tabBar.viewWithTag(self.animationViewTag) {
              viewWithTag.layer.removeAllAnimations()
              viewWithTag.removeFromSuperview()
          }
      }
}
extension ProviderTabController : UITabBarControllerDelegate{
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        /*
        if tabBarController.selectedIndex != 1 {
            UserDefaults.standard.set(tabBarController.selectedIndex, forKey: "lastSelectedTabIndex")
        }
        
        if tabBarController.selectedIndex == 3 {
            let vc = viewController as! UINavigationController
            print(vc.viewControllers)
            let myVC = vc.viewControllers.first as! ActivityVC
            myVC.scrollToTop()
           
            NotificationCenter.default.post(name: Notification.Name("RefreshscreenNotification"), object: nil)
        }
        
        if tabBarController.selectedIndex == 1 || tabBarController.selectedIndex == 2 {
            
            if UserSettings.isUserLogin == false {
                
                let alert = UIAlertController(title: AppName, message: "please login to proceed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                    print("default")
                    self.tabBar.isHidden = false
                    tabBarController.selectedIndex = 0
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        } */
    }
    func getMyJOBCountAPIRequest(){
        APIRequestClient.shared.sendAPIRequest(requestType: .GET, queryString:kGETProviderMyJOBCount , parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                 if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                                    DispatchQueue.main.async {
                                        
                                        if let acceptjob = userInfo["accept_job"] as? Int,let sendOffer = userInfo["send_offer"] as? Int{
                                            if acceptjob > 0 && sendOffer == 0{
                                                //green
                                                 self.addGreenAnimatedCustomView()
                                            }else if acceptjob == 0 && sendOffer > 0 {
                                                //yellow
                                                 self.addYellowAnimatedCustomView()
                                            }else if acceptjob > 0 && sendOffer > 0{
                                                //green and yellow
                                                 self.addAnimatedCustomView()
                                            }else if acceptjob == 0 && sendOffer == 0{
                                                //Clear
                                                self.removeCustomView()
                                            }else{
                                                //Clear
                                                self.removeCustomView()
                                            }
                                         }else{
                                             //Clear
                                             self.removeCustomView()
                                         }
                                        print(userInfo)
                                        if let dict = userInfo as? NSDictionary{
                                            NotificationCenter.default.post(name: .updateMyJobTab, object: nil,userInfo: userInfo)
                                        }
                                        /*
                                        if let makeOffer = userInfo["make_offer"]{
                                            
                                            if "\(makeOffer)" == "0"{
                                                NotificationCenter.default.post(name: .updateMyJobTab, object: nil)
                                            }
                                        }*/
                                    }
                                
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
    
}




