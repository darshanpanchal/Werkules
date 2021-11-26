//
//  SAAlertBar.swift
//  SolApp
//
//  Created by Apple on 12/07/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import SwiftMessages
import Foundation
public class SAAlertBar {
    
    /// This method will used to display a Message Bar on the screen.
    ///
    ///     MessageBar.show(.info, title: "OPTIONAL TITLE", message: "YOUR MESSAGE HERE")
    ///     MessageBar.show(.success, title: "OPTIONAL TITLE", message: "YOUR MESSAGE HERE")
    ///     MessageBar.show(.warning, title: "OPTIONAL TITLE", message: "YOUR MESSAGE HERE")
    ///     MessageBar.show(.error, title: "OPTIONAL TITLE", message: "YOUR MESSAGE HERE")
    ///
    /// - Parameters:
    ///   - theme: Type of Message Bar you wanted to display. There are 4 types available. - error | success | warning | info
    ///   - title: String Title you wanted to display on message. Pass nil here if you wanted to display default title based on the theme. If value if this param is passed then it will override the default title.
    ///   - message: String Message you wanted to display on message.
    public class func show(_ theme: Theme, title: String? = nil, message: String) -> Void {
        DispatchQueue.main.async {
            guard message != kCommonError else{
                return
            }
        
        // -- View setup
        let view: MessageView = MessageView.viewFromNib(layout: .cardView)
        
        //        DispatchQueue.main.async {
        //            SwiftMessages.show(config: config, view: view)
        //        }
        
        
        //  view.backgroundView.cornerRadius = 12.0
        
        view.configureContent(title: "Info", body: message.capitalizingFirstLetter(), iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "", buttonTapHandler: { _ in SwiftMessages.hide() })
        
        // Icon Style
        let iconStyle: IconStyle = .default
        
        // Theme
        switch theme {
        case .info:
            
            //  view.configureTheme(backgroundColor: UIColor.hexString("CFD8DC"), foregroundColor: .white, iconImage: iconStyle.image(theme: .info), iconText: nil)
            view.titleLabel?.text = "Error"
        case .success:
//            view.configureTheme(backgroundColor: UIColor.app.primary, foregroundColor: .white, iconImage: iconStyle.image(theme: .success), iconText: nil)
            
        
            view.titleLabel?.text = "Success"
        case .warning:
            
            //  view.configureTheme(backgroundColor: UIColor.hexString("FFAB00"), foregroundColor: .white, iconImage: iconStyle.image(theme: .warning), iconText: nil)
            view.titleLabel?.text = "Warning"
        case .error:
          
            //   view.configureTheme(backgroundColor: UIColor.hexString("FC2125"), foregroundColor: .white, iconImage: iconStyle.image(theme: .error), iconText: nil)
            view.titleLabel?.text = "Error"
        }
        
        view.titleLabel?.text = ""
        
        if title != nil {
            view.titleLabel?.text = title!
        }
        
        // Set Font
        //view.titleLabel?.font = UIFont.appFont(20, .bold)      //  view.titleLabel?.font = UIFont.appFont(14.0, .medium)
        
        // Set Shadow
        view.configureDropShadow()
        
        // Set Button
        view.button?.isHidden = true
        
        // Show Icon
        view.iconImageView?.isHidden = true
        view.iconLabel?.isHidden = true
        
        // Show Title
        view.titleLabel?.isHidden = false
        
        // Show Body
        view.bodyLabel?.isHidden = false
        
        
        // -- Config setup
        
        var config = SwiftMessages.defaultConfig
        
        // Presentation
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        
        // Duration
        config.duration = .seconds(seconds: 3)
        
        // Rotation
        config.shouldAutorotate = true
        
        // Hide on Interaction
        config.interactiveHide = true
        
        
        // Show Message Bar
        DispatchQueue.main.async {
            SwiftMessages.show(config: config, view: view)
        }
    }
    }
    
    /// This method will hide all the Messages which are displayed and also clear the queue.
    public class func hide() -> Void {
        SwiftMessages.hideAll()
    }
    
}
