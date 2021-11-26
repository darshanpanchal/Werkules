//
//  ProviderUserProfile.swift
//  Entreprenetwork
//
//  Created by IPS on 22/07/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import Foundation
import UIKit
class ProviderUserProfile: UIViewController {
    @IBOutlet weak var profileImage:UIImageView!
    var profileStr:UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileImage.image = self.profileStr
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
      @IBAction func buttonHomeSelector(sender:UIButton){
              self.dismiss(animated: true, completion: nil)
      }
 

}
