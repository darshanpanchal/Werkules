//
//  ReviewUpdatedTableViewCell.swift
//  Entreprenetwork
//
//  Created by IPS on 27/05/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit
protocol ReviewUpdatedCellDeletegate {
    func buttonFirstReviewSelector(isForHelp:Bool)
    func buttonSecondReviewSelector(isForHelp:Bool)
    func buttonThirdReviewSelector()
    func buttonExpandReviewSelector(isExpanded:Bool,isForHelp:Bool)
}
class ReviewUpdatedTableViewCell: UITableViewCell {

    var isForHelp:Bool = false

    var isExpand:Bool = false
      var isReviewExpand:Bool{
          get{
              return isExpand
          }
          set{
              self.isExpand = newValue
          }
          
      }
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblReviewFirst:UILabel!
    @IBOutlet weak var lblReviewSecond:UILabel!
    @IBOutlet weak var lblReviewThird:UILabel!

    @IBOutlet weak var imgReviewImage:UIImageView!
    @IBOutlet weak var stackViewReview:UIStackView!

    @IBOutlet weak var viewThirdOption:UIView!


    var delegate:ReviewUpdatedCellDeletegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
          self.imgReviewImage.contentMode = .scaleAspectFill
                            self.imgReviewImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonExpandSelector(sender:UIButton){
        if let _ = self.delegate{
            if self.isReviewExpand{
                UIView.animate(withDuration: 2, animations: {
                     self.imgReviewImage.transform = CGAffineTransform.identity
                })
            }else{
                UIView.animate(withDuration: 2, animations: {
                    self.imgReviewImage.transform = CGAffineTransform(rotationAngle: .pi/2)
                })
            }
            self.isReviewExpand = !self.isReviewExpand
            self.delegate!.buttonExpandReviewSelector(isExpanded:self.isReviewExpand,isForHelp:self.isForHelp)
            
        }
    }
    @IBAction func buttonFirstReviewSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonFirstReviewSelector(isForHelp: self.isForHelp)
        }
    }
    @IBAction func buttonSecondReviewSelector(sender:UIButton){
        if let _ = self.delegate{
                    self.delegate!.buttonSecondReviewSelector(isForHelp: self.isForHelp)
        }
    }
    @IBAction func buttonThirdReviewSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonThirdReviewSelector()
        }
    }

}
