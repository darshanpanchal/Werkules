//
//  SectionHeaderView.swift
//  Entreprenetwork
//
//  Created by IPS on 08/03/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
enum SectioStatus {
    case open
    case close
}
protocol SectionHeaderViewDelegate {
    func sectionHeaderView(status: SectioStatus, sectionOpened: Int)
    func sectionHeaderView(status: SectioStatus, sectionClosed: Int)
}
class SectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var disclosureButton: UIButton!
    
    @IBAction func toggleOpen() {
        self.toggleOpenWithUserAction(userAction: true)
    }
    var delegate: SectionHeaderViewDelegate?
    
    func toggleOpenWithUserAction(userAction: Bool) {
        
//        self.disclosureButton.isSelected = !self.disclosureButton.isSelected
           
           if userAction {
            if self.disclosureButton.isSelected {
                self.delegate?.sectionHeaderView(status: .open, sectionOpened: self.tag)
            } else {
                self.delegate?.sectionHeaderView(status: .close, sectionClosed: self.tag)
               }
           }
       }
       
       override func awakeFromNib() {
        // var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector(("toggleOpen")))
        //  self.addGestureRecognizer(tapGesture)
        // change the button image here, you can also set image via IB.
        //self.disclosureButton.setImage(UIImage(named: "up_arrow"), for: UIControl.State.selected)
        //self.disclosureButton.setImage(UIImage(named: "down_arrow"), for: UIControl.State.normal)
        self.disclosureButton.setImage(UIImage(named: "ellipsis_selected"), for: UIControl.State.selected)
        self.disclosureButton.setImage(UIImage(named: "ellipsis"), for: UIControl.State.normal)
       }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
class SectionInfo: NSObject {
    var open: Bool = false
    var itemsInSection: NSMutableArray = []
    var sectionTitle: String?
    
    init(itemsInSection: NSMutableArray, sectionTitle: String) {
        self.itemsInSection = itemsInSection
        self.sectionTitle = sectionTitle
    }
}
