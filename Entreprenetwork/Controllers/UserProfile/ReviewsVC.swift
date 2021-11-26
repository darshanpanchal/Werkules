//
//  ReviewsVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 01/10/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class ReviewsVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    
    @IBOutlet weak var tblReviews: UITableView!
    @IBOutlet weak var lblNoReviews: UILabel!
    
    var userID = String()
    var arrReviews = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        RegisterCell()
        getReviews()
    }
    
    // MARK: - Register Cell
    
    func RegisterCell()  {
        self.tblReviews.register(UINib.init(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
    }
    
    // MARK: - UITablewView Datasource and Delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrReviews.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height = CGFloat()
        
        height = 14
        
        let dataDict = arrReviews.object(at: indexPath.row) as! NSDictionary
        
        var jobTitle = String()
        if dataDict["job"] is String == true {
            
            jobTitle = ""
        }
        else {
            let jobDict = dataDict.value(forKey: "job") as! NSDictionary
            jobTitle = (jobDict["title"] as! String)
            
            let width = jobTitle.width(withConstrainedHeight: 34, font: .systemFont(ofSize: 14))
            let intWidth = Int(width)
            
            height = height + jobTitle.height(withConstrainedWidth: CGFloat(intWidth), font: .systemFont(ofSize: 14))
        }
        
        let reviewText = (dataDict.value(forKey: "review") as! String)
        
        let width = reviewText.width(withConstrainedHeight: 34, font: .systemFont(ofSize: 14))
        let intWidth = Int(width)
        
        height = height + reviewText.height(withConstrainedWidth: CGFloat(intWidth), font: .systemFont(ofSize: 14))
//        let intHeight = Int(height)
        
        if intWidth > 270 {
            
            let numberofLines = Double(width/270).rounded(.up)
            let height = 21 * numberofLines + 10
            return CGFloat(height + 30)
        }
            return height + 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblReviews.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        cell.selectionStyle = .none
        
        cell.lblSeparator.isHidden = false
        if indexPath.row == arrReviews.count - 1 {
            cell.lblSeparator.isHidden = true
        }
        
        let dataDict = arrReviews.object(at: indexPath.row) as! NSDictionary
        if dataDict["job"] is String == true {
            
            cell.lblJobTitle.text = ""
        }
        else {
            let jobDict = dataDict.value(forKey: "job") as! NSDictionary
            
            cell.lblJobTitle.text = (jobDict["title"] as! String)
        }
        cell.lblReview.text =  (dataDict.value(forKey: "review") as! String)
        
        let ratings = dataDict.value(forKey: "rating") as! Int
        
        cell.lblRatings.text = "\(ratings)"
        
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        if isModal == true {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - API
    
    func getReviews() {
        
        let dict = [
            APIManager.Parameter.limit : "100",
            APIManager.Parameter.page : "1",
            APIManager.Parameter.userID : self.userID
        ]
        
        APIManager.sharedInstance.CallAPIPost(url: Url_getReview, parameter: dict, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                if (dataDict["data"] as! NSArray).count == 0 {
                    
                    self.lblNoReviews.isHidden = false
                    self.tblReviews.isHidden = true
                    
                    self.lblNoReviews.text = (dataDict["message"] as! String)
                }
                else {
                    self.lblNoReviews.isHidden = true
                    self.tblReviews.isHidden = false
                    
                    self.arrReviews = dataDict["data"] as! NSArray
                    
                    self.tblReviews.reloadData()
                }
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
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
