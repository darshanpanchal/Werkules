//
//  BaseViewController.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 24/07/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLbl: UILabel!

    // MARK: - UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        let gradient = CAGradientLayer()
//        
//        gradient.frame = topView.bounds
//        let color1 = UIColor(red: 20/255, green: 125/255, blue: 115/255, alpha: 1.0)
//        let color2 = UIColor(red: 7/255, green: 58/255, blue: 86/255, alpha: 1.0)
//        gradient.colors = [color1.cgColor, color2.cgColor]
//        
//        topView.layer.insertSublayer(gradient, at: 0)
    }
}
