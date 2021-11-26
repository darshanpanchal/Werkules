//
//  containerVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 09/10/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import SidebarOverlay

class containerVC: SOContainerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.menuSide = .left
        let homeStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let profileStoryboard = UIStoryboard.init(name: "Profile", bundle: nil)
        self.topViewController = homeStoryboard.instantiateViewController(withIdentifier: "HomeVC")
        self.sideViewController = profileStoryboard.instantiateViewController(withIdentifier: "SettingsVC")
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
