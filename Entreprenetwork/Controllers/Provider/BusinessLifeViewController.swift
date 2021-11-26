//
//  BusinessLifeViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 11/01/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
import GoogleMaps

class BusinessLifeViewController: UIViewController {

    @IBOutlet weak var objMapView:GMSMapView!
            
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.objMapView.delegate = self
        self.objMapView.isMyLocationEnabled = true
        self.objMapView.settings.myLocationButton = true
    }
    // MARK: - Selector Methods
       @IBAction func menuBtnClicked(_ sender: UIButton) {
            
            if let container = self.so_containerViewController {
                container.isSideViewControllerPresented = true
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
extension BusinessLifeViewController:GMSMapViewDelegate{
        
}
