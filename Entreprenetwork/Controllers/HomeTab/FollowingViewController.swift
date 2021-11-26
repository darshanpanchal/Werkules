//
//  FollowingViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 14/05/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class FollowingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
              self.tabBarController?.tabBar.isHidden = true
             SAAlertBar.show(.error, message:"Under Development".localizedLowercase)
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         DispatchQueue.main.async {
                      self.tabBarController?.tabBar.isHidden = false
         }
     }
    @IBAction func buttonBackSelector(sender:UIButton){
        //self.navigationController?.popViewController(animated: true)
        if let objTabView = self.navigationController?.tabBarController{
                   
                   if let objHomeNavigation = objTabView.viewControllers?.first as? UINavigationController,let objHome = objHomeNavigation.viewControllers.first as? HomeVC{
                       objTabView.selectedIndex = 0
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
