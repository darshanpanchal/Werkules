//
//  ShadowView.swift
//  Skinary
//
//  Created by Sujal Adhia on 09/12/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    private var shadowLayer: CAShapeLayer!


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func draw(_ rect: CGRect) {
        
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor

            shadowLayer.shadowColor = UIColor.lightGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 2, height: 2.0)
            shadowLayer.shadowOpacity = 0.3
            shadowLayer.shadowRadius = 10
            layer.insertSublayer(shadowLayer, at: 0)
        }
        
       }
    
       func dropShadow(color: UIColor, opacity: Float = 1.0, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
//            self.layer.masksToBounds = false
//            self.layer.cornerRadius = 14.0

//            self.layer.shadowOffset = CGSize(width: -2, height: 2)
//            self.layer.shadowColor = UIColor.gray.cgColor//UIColor.shadowColor.cgColor//UIColor.gray.cgColor
//            self.layer.shadowOpacity = 0.3
//            self.layer.shadowRadius = 10
        
       }

}

