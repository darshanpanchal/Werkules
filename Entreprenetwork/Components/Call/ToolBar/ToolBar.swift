//
//  ToolBar.swift
//  Entreprenetwork
//
//  Created by IPS on 14/04/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import Foundation
import UIKit

class ToolBar: UIToolbar {
    //MARK: - Properties
    var buttons: [UIButton] = []
    var actions: [(_ sender: UIButton?) -> Void] = []
    
    //MARK: - Life Circle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        setShadowImage(UIImage(), forToolbarPosition: .any)
        //Default Gray
        backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        
    }
    
    //MARK: - Public Methods
    func removeAllButtons() {
        buttons.removeAll()
        actions.removeAll()
    }
    
    func updateItems() {
        var items = [UIBarButtonItem]()
        let barButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        for button in buttons {
            let item = UIBarButtonItem(customView: button)
            if let barItems = self.items {
                items = items + barItems
            }
            items.append(barButton)
            items.append(item)
        }
        items.append(barButton)
        self.items = items
    }
    
    func add(_ button: UIButton?, action: @escaping (_ sender: UIButton?) -> Void) {
        button?.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
        if let button = button {
            buttons.append(button)
        }
        actions.append(action)
    }
    
    //MARK: - Actions
    @objc func didTap(_ button: CustomButton) {
        guard let index = buttons.firstIndex(of: button) else { return }
        let action: ((_ sender: UIButton?) -> Void)? = actions[index]
        action?(button)
    }
}
