//
//  JobDetailViewController.swift
//  Entreprenetwork
//
//  Created by IPS on 15/02/21.
//  Copyright © 2021 Sujal Adhia. All rights reserved.
//

import UIKit

class JobDetailViewController: UIViewController {

    var attributesBold: [NSAttributedString.Key: Any] = [
    .font: UIFont.init(name: "Avenir Heavy", size: 16.0)!,
    .foregroundColor: UIColor.black,
       ]
    var attributesNormal: [NSAttributedString.Key: Any] = [
       .font:  UIFont.init(name: "Avenir Medium", size: 16.0)!,
       .foregroundColor: UIColor.black,
       ]
    @IBOutlet weak var buttonBack:UIButton!
    @IBOutlet weak var collectionJOBDetail:UICollectionView!
    
    var images:[[String:Any]] = []
    
    var arrayOfJOBImages:[[String:Any]]{
        get{
            return images
        }
        set{
            self.images = newValue
            self.objPageController.numberOfPages = newValue.count
        }
    }


    @IBOutlet weak var stackViewUpdateLocationTime:UIStackView!
    @IBOutlet weak var imageUpdateUser:UIImageView!
    @IBOutlet weak var lblUpdateUserName:UILabel!
    @IBOutlet weak var lblUpdateDate:UILabel!
    @IBOutlet weak var lblUpdateLocation:UILabel!
    @IBOutlet weak var lblUpdateTravelTime:UILabel!
    @IBOutlet weak var lblDistanceInMiles:UILabel!
    @IBOutlet weak var viewDistanceToCustomer:UIView!

    @IBOutlet weak var lblUpdateBudget:UILabel!
    @IBOutlet weak var lblUpdateActive:UILabel!
    @IBOutlet weak var lblUpdateKeyword:UILabel!
    @IBOutlet weak var lblUpdateDiscription:UILabel!

    @IBOutlet weak var buttonUpdateSendOffer:UIButton!


    @IBOutlet weak var objPageController:UIPageControl!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var imgUserProfile:UIImageView!
    @IBOutlet weak var tableViewDetail:UITableView!
    
    @IBOutlet weak var buttonGetDirectionOnMap:UIButton!
    
    var jobId:String = ""
    var currentJOBDetail:JOBDetail?
    
    var arrayTableView:[String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
/*         self.arrayOfJOBImages = ["https://projectw-host.s3.amazonaws.com/images/main/job-1613455304-IMG_20210216_113134190.jpg","https://homepages.cae.wisc.edu/~ece533/images/airplane.png","https://homepages.cae.wisc.edu/~ece533/images/arctichare.png"]*/
        
        
        // Do any additional setup after loading the view.
        //self.setup()
        self.imgUserProfile.contentMode = .scaleAspectFill
        self.imgUserProfile.clipsToBounds = true
        self.imgUserProfile.layer.cornerRadius = 12.5
        self.imageUpdateUser.layer.borderWidth = 0.7
        self.imageUpdateUser.layer.borderColor = UIColor.lightGray.cgColor

        self.imageUpdateUser.contentMode = .scaleAspectFill
        self.imageUpdateUser.clipsToBounds = true
        self.imageUpdateUser.layer.cornerRadius = 40.0





        //fetch job detail
        self.fetchJOBDetailAPIRequest()
        
        self.configureTableView()
        
        let underlineGetDirection = NSAttributedString(string: "Get Directions",
                                                                            attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.buttonGetDirectionOnMap.setAttributedTitle(underlineGetDirection, for: .normal)
        self.buttonUpdateSendOffer.addTarget(self,
                                  action: #selector(buttonSendOfferDetail(sender:)),
                                  for: .touchUpInside)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setup()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                   self.tableViewDetail.isScrollEnabled = (self.tableViewDetail.contentSize.height > self.tableViewDetail.bounds.height)
        }
    }
    func configureTableView(){
      
        self.tableViewDetail.delegate = self
        self.tableViewDetail.dataSource = self
        self.tableViewDetail.rowHeight = UITableView.automaticDimension
       self.tableViewDetail.estimatedRowHeight = 180.0
        self.tableViewDetail.allowsSelection = false
        self.tableViewDetail.sizeHeaderFit()
        self.tableViewDetail.reloadData()
    }
    // MARK: - User Methods
    func setup(){
        self.objPageController.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//        self.objPageController.customPageControl(dotFillColor: .white, dotBorderColor: .white, dotBorderWidth: 0.7)
        self.objPageController.isUserInteractionEnabled = false
        self.objPageController.pageIndicatorTintColor = UIColor.lightGray
        self.objPageController.currentPageIndicatorTintColor = UIColor.init(hex: "#38B5A3")
        let objCollectioncell = UINib.init(nibName: "JOBDetailCollectionViewCell", bundle: nil)
              self.collectionJOBDetail.register(objCollectioncell, forCellWithReuseIdentifier: "JOBDetailCollectionViewCell")
        
        self.collectionJOBDetail.isPagingEnabled = true
        self.collectionJOBDetail.isUserInteractionEnabled = true

        self.collectionJOBDetail.delegate = self
        self.collectionJOBDetail.dataSource = self
        self.collectionJOBDetail.reloadData()
        self.collectionJOBDetail.allowsSelection = false
    }
    func configureCurrentJOBDetail(){
       
        
        if let jobdetail = self.currentJOBDetail{
            DispatchQueue.main.async {
                let handleTap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapGesture))
                
                self.imageUpdateUser.addGestureRecognizer(handleTap)
                self.lblUpdateUserName.addGestureRecognizer(handleTap)
                self.lblTitle.text = jobdetail.title
                let userDetail = jobdetail.userDetail
                if let firstname = userDetail["firstname"],let lastname = userDetail["lastname"]{
                    if let currentUser = UserDetail.getUserFromUserDefault(){
                        if currentUser.userRoleType == .customer{
                            self.lblUserName.text = "\(firstname) \(lastname)"// TRUE
                            self.lblUpdateUserName.text = "\(firstname) \(lastname)"// TRUE
                        }else{
                            if jobdetail.isFullNameShow {
                                self.lblUserName.text = "\(firstname) \(lastname)"// TRUE
                                self.lblUpdateUserName.text = "\(firstname) \(lastname)"// TRUE
                            }else{
                                self.lblUserName.text = "\(firstname)" //\(lastname)"// FALSE
                                self.lblUpdateUserName.text = "\(firstname)" //\(lastname)"// TRUE
                            }
                        }
                    }

                    
                }
                if let profile = userDetail["profile_pic"],let imageURl = URL.init(string: "\(profile)"){
                        self.imgUserProfile.sd_setImage(with: imageURl, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                        self.imageUpdateUser.sd_setImage(with: imageURl, placeholderImage: UIImage.init(named: "user_placeholder"), options: .refreshCached, context: nil)
                }
                let dateformatter = DateFormatter()
                                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                        let date = dateformatter.date(from: jobdetail.createdAt)
                                         dateformatter.dateFormat = "MM/dd/yyyy"
                self.lblDate.text = dateformatter.string(from: date!)
                self.lblUpdateDate.text = dateformatter.string(from: date!)

                let mutableString = NSMutableAttributedString.init(string: "Location: ", attributes: self.attributesNormal)
                let mutableString1 = NSMutableAttributedString.init(string: "\(jobdetail.address)", attributes: self.attributesBold)
                mutableString.append(mutableString1)

                self.lblUpdateLocation.attributedText = mutableString

                let mutableString2 = NSMutableAttributedString.init(string: "Budget: ", attributes: self.attributesNormal)
                let mutableString3 = NSMutableAttributedString.init(string: "\(CurrencyFormate.Currency(value: Double(jobdetail.askingPrice) ?? 0.00))", attributes: self.attributesBold)
                mutableString2.append(mutableString3)
                self.lblUpdateBudget.attributedText = mutableString2
                //self.lblUpdateBudget.text = "Budget: \(CurrencyFormate.Currency(value: Double(jobdetail.askingPrice) ?? 0.00))"
                if let _ = jobdetail.keepPostActive{
                    let mutableString5 = NSMutableAttributedString.init(string: "Active for \(jobdetail.keepPostActive?.name ?? "N/A")", attributes: self.attributesBold)
                    self.lblUpdateActive.attributedText = mutableString5
                }else{
                    self.lblUpdateActive.text = ""
                }

                //self.lblUpdateActive.text = "Active for \(jobdetail.keepPostActive?.name ?? "")"

                let mutableString6 = NSMutableAttributedString.init(string: "\(jobdetail.tavelTime?.name ?? "") away", attributes: self.attributesBold)
                self.lblUpdateTravelTime.attributedText = mutableString6
                //self.lblUpdateTravelTime.text = "\(jobdetail.tavelTime?.name ?? "") away"


                self.lblUpdateKeyword.text = "\(jobdetail.title)"
                self.lblUpdateDiscription.text = "\(jobdetail.descriptionDetail)"




                self.arrayOfJOBImages = jobdetail.images
                self.buttonGetDirectionOnMap.isHidden = !jobdetail.isDirectionShowHide
                self.collectionJOBDetail.reloadData()
                self.tableViewDetail.reloadData()

                guard let currentUser = UserDetail.getUserFromUserDefault() else {
                                return
                    }
                if currentUser.userRoleType  == .customer{
                    self.buttonGetDirectionOnMap.isHidden = true
                    self.buttonUpdateSendOffer.isHidden = true
                    self.lblDistanceInMiles.isHidden = true
                    self.lblUpdateTravelTime.isHidden = true
                    self.buttonUpdateSendOffer.isHidden = true
                    self.stackViewUpdateLocationTime.axis = .vertical
                    self.lblUpdateTravelTime.textAlignment = .right
                    self.viewDistanceToCustomer.isHidden = true
                }else{
                    self.viewDistanceToCustomer.isHidden = false
                    self.lblDistanceInMiles.isHidden = false
                    self.lblUpdateTravelTime.isHidden = false//!jobdetail.isDirectionShowHide
                    self.stackViewUpdateLocationTime.axis = .vertical
                    self.lblUpdateTravelTime.textAlignment = .left
//                    self.buttonUpdateSendOffer.isHidden = false
                    let mutableString7 = NSMutableAttributedString.init(string: "Distance to Customer: ", attributes: self.attributesNormal)
                  
                    
                    let mutableString8 = NSMutableAttributedString.init(string: "\(jobdetail.distance)", attributes: self.attributesBold)
                    self.lblUpdateTravelTime.attributedText =  mutableString7
                    self.lblDistanceInMiles.attributedText = mutableString8
                    if jobdetail.isForSendOffer{
                        self.buttonUpdateSendOffer.isHidden = true
                    }else{
                        self.buttonUpdateSendOffer.isHidden = false
                    }

                }
                self.tableViewDetail.sizeHeaderFit()
            }
            
        }
        
    }
    @objc func handleTapGesture(){
        guard let currentUser = UserDetail.getUserFromUserDefault() else {
                        return
            }
        if currentUser.userRoleType  == .customer{
            let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "EntrepreneurProfileVC") as! EntrepreneurProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            if let userDetail = self.currentJOBDetail?.userDetail{
                self.pushtocustomerdetailViewcontroller(dict: userDetail)
            }
            
        }
    }
    // MARK: - API  Methods
    func fetchJOBDetailAPIRequest(){
        var dict:[String:Any] = [:]
        dict["job_id"] = "\(self.jobId)"
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            dict["lat"] = appDelegate.providerHomeLat
            dict["lng"] = appDelegate.providerHomeLng
        }
        APIRequestClient.shared.sendAPIRequest(requestType: .POST, queryString:kJOBDetail , parameter: dict as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let userInfo = success["success_data"] as? [String:Any]{
                                   
                                     let objDetail = JOBDetail.init(jobDetail: userInfo)
                                    self.currentJOBDetail = objDetail
                                    self.configureCurrentJOBDetail()
                    if self.currentJOBDetail?.isPreoffer == false{
                        self.arrayTableView = ["Category","Description","Budget","Keep post active","Location","Travel Time"]
                    }else{
                        self.arrayTableView = ["Description","Agreed Price","Location"]
                    }
                                     }else{
                                         DispatchQueue.main.async {
                                             //SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                         }
                                     }
                                 }) { (responseFail) in
                                  
                               if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["error_data"] as? [String]{
                                      
                                      DispatchQueue.main.async {
                                          if errorMessage.count > 0{
                                              SAAlertBar.show(.error, message:"\(errorMessage.first!)".localizedLowercase)
                                          }
                                      }
                                  }else{
                                         DispatchQueue.main.async {
                                            // SAAlertBar.show(.error, message:"\(kCommonError)".localizedLowercase)
                                         }
                                     }
                                 }
        
    }
    // MARK: - Selector Methods
    @IBAction func buttonUserImageAndUserNameSelector(sender:UIButton){
        self.handleTapGesture()
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonSendOfferDetail(sender:UIButton){

        if let jobdetail = self.currentJOBDetail{
            let offerDetail = OfferDetail.init(offerDetail: [:])
            let jobdetail = ["job_id":"\(jobdetail.id)","title":"\(jobdetail.title)"]
            offerDetail.jobDetail = JOB.init(jobDetail: jobdetail)
            offerDetail.customerDetail = CustomerDetail.init(customerDetail: self.currentJOBDetail!.userDetail)
            self.pushtosendofferviewcontrollewith(offerdetail: offerDetail)
        }
    }
    func pushtosendofferviewcontrollewith(offerdetail:OfferDetail){
        if let sendofferviewcontroller = UIStoryboard.main.instantiateViewController(withIdentifier: "SendOfferViewController") as? SendOfferViewController{
            sendofferviewcontroller.objOfferDetail = offerdetail
            sendofferviewcontroller.hidesBottomBarWhenPushed = true

            self.navigationController?.pushViewController(sendofferviewcontroller, animated: true)
        }
    }
    @IBAction func buttonGetDirectionSelector(sender:UIButton){
        if let currentJOB = self.currentJOBDetail,let urlString = currentJOB.directionLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
                if let url = URL(string:"\(urlString)") {
                                UIApplication.shared.open(url, options: [:])
                       }
               }
    }
    func pushtocustomerdetailViewcontroller(dict:[String:Any]){
             
                let profilestoryboard  = UIStoryboard.init(name: "Profile", bundle: nil)
                if let profileViewcontroller = profilestoryboard.instantiateViewController(withIdentifier: "CustomerProfileAsProviderVC") as? CustomerProfileAsProviderVC{
               
                    if let user_id = dict["id"]{
                        profileViewcontroller.userId = "\(user_id)"
                    }
                    if let profile_pic = dict["profile_pic"]{
                        profileViewcontroller.userProfile = "\(profile_pic)"
                    }
                    if let firstname = dict["firstname"],let lastname = dict["lastname"]{
                        profileViewcontroller.userName = "\(firstname) \(lastname)"
                    }
                    profileViewcontroller.isFromMyGroupScreen = true
                    profileViewcontroller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(profileViewcontroller, animated: true)
                }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
extension JobDetailViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0 //self.arrayTableView.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JOBDetailTableViewCell", for: indexPath) as! JOBDetailTableViewCell
        cell.tag = indexPath.row
        let objtitle = self.arrayTableView[indexPath.row]
        cell.lblTitle.text = objtitle
        
        if let jobdetail = self.currentJOBDetail{
            if indexPath.row == 0{
                if self.currentJOBDetail?.isPreoffer == true{
                  cell.lblDetail.text = ""
                  cell.lblDiscription.text = "\(jobdetail.descriptionDetail)"
                }else{
                    cell.lblDetail.text = "\(jobdetail.category?.name ?? "")"
                    cell.lblDiscription.text = ""
                }
              }else if indexPath.row == 1{
                if self.currentJOBDetail?.isPreoffer == true{
                    cell.lblDetail.text = CurrencyFormate.Currency(value: Double(jobdetail.askingPrice) ?? 0.00)//"\(jobdetail.askingPrice)".add2DecimalString
                    cell.lblDiscription.text = ""
                }else{
                    cell.lblDetail.text = ""
                    cell.lblDiscription.text = "\(jobdetail.descriptionDetail)"
                }
              }else if indexPath.row == 2{
                if self.currentJOBDetail?.isPreoffer == true{
                    cell.lblDiscription.text = "\(jobdetail.address)"
                }else{
                    cell.lblDetail.text = CurrencyFormate.Currency(value: Double(jobdetail.askingPrice) ?? 0)//"\(jobdetail.askingPrice)".add2DecimalString
                    cell.lblDiscription.text = ""
                }
              }else if indexPath.row == 3{
                cell.lblDetail.text = "\(jobdetail.keepPostActive?.name ?? "")"
                  cell.lblDiscription.text = ""
              }else if indexPath.row == 4{
                  cell.lblDetail.text = ""
                if jobdetail.isDirectionShowHide{
                    cell.lblDiscription.text = "\(jobdetail.address)"
                }else{
                    cell.lblDiscription.text = ""
                }
              }else if indexPath.row == 5{
                 cell.lblDetail.text = "\(jobdetail.tavelTime?.name ?? "")"
                  cell.lblDiscription.text = ""
              }else{
                  cell.lblDiscription.text = ""
              }
        }
  
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return UITableView.automaticDimension
       }
}
extension JobDetailViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,JOBDetailCellDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.objPageController.isHidden = (self.arrayOfJOBImages.count == 0)
        self.collectionJOBDetail.isHidden = (self.arrayOfJOBImages.count == 0)
        return self.arrayOfJOBImages.count//JobsModel.Shared.arrJobs.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JOBDetailCollectionViewCell", for: indexPath) as! JOBDetailCollectionViewCell
        DispatchQueue.main.async {
            cell.tag = indexPath.item
            cell.delegate = self
            cell.buttonJOBDetail.isHidden = false
            if self.arrayOfJOBImages.count > indexPath.item{
                let objImage = self.arrayOfJOBImages[indexPath.item]
                if let image = objImage["image"] as? String,image.count > 0{
                    if let imageURL = URL.init(string: image){
                        cell.imgView.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                        
                    }
                }
            }
        }
  
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //return CGSize.init(width: 100, height: 100)//
        return CGSize(width: UIScreen.main.bounds.width, height:collectionView.bounds.height)
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //self.objPageController.currentPage = indexPath.item
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        self.objPageController.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.presentImageSliderViewDetail(index:indexPath.item)
    }
    func presentImageSliderViewDetail(index:Int){
        if let objStory = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailImageSliderViewController") as? JobDetailImageSliderViewController{
                       objStory.modalPresentationStyle = .overFullScreen
                        objStory.arrayOfJOBImages = self.arrayOfJOBImages
                        objStory.currentIndex = index
                       self.present(objStory, animated: true, completion: nil)
                   }
    }
    func buttonDetailSelectionWithIndex(index: Int) {
        self.presentImageSliderViewDetail(index: index)
    }
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
        let index = scrollView.contentOffset.x / witdh
        let roundedIndex = round(index)
        self.objPageController.currentPage = Int(roundedIndex)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        self.objPageController.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {

        self.objPageController.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }*/
}
protocol JOBDetailCellDelegate {
    func buttonDetailSelectionWithIndex(index:Int)
}
class JOBDetailCollectionViewCell: UICollectionViewCell,UIScrollViewDelegate,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var objScrollView:UIScrollView!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var buttonJOBDetail:UIButton!
    
    var delegate:JOBDetailCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgView.contentMode = .scaleAspectFill
//        self.imgView.clipsToBounds = false
//        self.layoutIfNeeded()
        self.objScrollView.minimumZoomScale = 1.0
        self.objScrollView.maximumZoomScale = 3.5
        self.objScrollView.isPagingEnabled = true
        self.objScrollView.alwaysBounceVertical = false
        self.objScrollView.alwaysBounceHorizontal = false
        self.objScrollView.bounces = false
        self.objScrollView.isScrollEnabled = false
        self.objScrollView.clipsToBounds = true
        self.imgView.clipsToBounds = true
        self.objScrollView.delegate = self

        

    }
    override func prepareForReuse() {
        super.prepareForReuse()
        DispatchQueue.main.async {
            
            self.objScrollView.setZoomScale(1.0, animated: true)
        }
    }
    func configureDoubleTapGesture(){
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(Self.handleTap(_:)))
            tapGR.delegate = self
            tapGR.numberOfTapsRequired = 2
            self.addGestureRecognizer(tapGR)
    }
    @objc func handleTap(_ gesture: UITapGestureRecognizer){
        DispatchQueue.main.async {
            if self.objScrollView.zoomScale == 1.0{
                self.objScrollView.setZoomScale(3.0, animated: true)
            }else{
                self.objScrollView.setZoomScale(1.0, animated: true)
            }
        }
        print("---- doubletapped \(self.objScrollView.zoomScale)")
       }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
           
        return self.imgView
        }


    @IBAction func buttonDetailSelector(sender:UIButton){
        //Build1
        self.delegate?.buttonDetailSelectionWithIndex(index: self.tag)
        
    }
    
}

class JOBDetailTableViewCell :UITableViewCell{
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDetail:UILabel!
    @IBOutlet weak var lblDiscription:UILabel!
    
    override func awakeFromNib() {
           super.awakeFromNib()
        
       }
    
}


class JobDetailImageSliderViewController: UIViewController {
    @IBOutlet weak var collectionJOBDetail:UICollectionView!
    
    var images:[[String:Any]] = []
    
    var arrayOfJOBImages:[[String:Any]] = []
    var currentIndex:Int = 0
    /*{
        get{
            return images
        }
        set{
            self.images = newValue
            self.objPageController.numberOfPages = newValue.count
        }
    }*/
    
    @IBOutlet weak var objPageController:UIPageControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    @IBAction func buttonCloseSelector(sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    func setup(){
        self.objPageController.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//        self.objPageController.customPageControl(dotFillColor: .white, dotBorderColor: .white, dotBorderWidth: 0.7)
        self.objPageController.isUserInteractionEnabled = false
        self.objPageController.currentPageIndicatorTintColor = UIColor.init(hex: "#38B5A3")
        let objCollectioncell = UINib.init(nibName: "JOBDetailCollectionViewCell", bundle: nil)
              self.collectionJOBDetail.register(objCollectioncell, forCellWithReuseIdentifier: "JOBDetailCollectionViewCell")
        
        self.collectionJOBDetail.isPagingEnabled = true
        
        self.objPageController.numberOfPages = self.arrayOfJOBImages.count
        self.collectionJOBDetail.delegate = self
        self.collectionJOBDetail.dataSource = self
        self.collectionJOBDetail.reloadData()
        self.collectionJOBDetail.allowsSelection = false
        self.collectionJOBDetail.backgroundColor = .clear
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.15) {
            let currentIndexPath = IndexPath.init(item: self.currentIndex, section: 0)
            self.objPageController.currentPage = self.currentIndex
            self.collectionJOBDetail.scrollToItem(at: currentIndexPath, at: .left, animated: false)
        }
        
    }
    
}
extension JobDetailImageSliderViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.objPageController.isHidden = (self.arrayOfJOBImages.count == 0)
        self.collectionJOBDetail.isHidden = (self.arrayOfJOBImages.count == 0)
        return self.arrayOfJOBImages.count//JobsModel.Shared.arrJobs.count
    }
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JOBDetailCollectionViewCell", for: indexPath) as! JOBDetailCollectionViewCell
        DispatchQueue.main.async {
//            cell.objScrollView.setZoomScale(1.0, animated: true)
            cell.imgView.contentMode = .scaleAspectFit
            cell.imgView.backgroundColor = .clear
            cell.backgroundColor = .clear
            cell.objScrollView.backgroundColor = .clear
            cell.configureDoubleTapGesture()
            cell.buttonJOBDetail.isHidden = true
            if self.arrayOfJOBImages.count > indexPath.item{
                let objImage = self.arrayOfJOBImages[indexPath.item]
                if let image = objImage["image"] as? String,image.count > 0{
                    if let imageURL = URL.init(string: image){
    //                    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
    //                    cell.isUserInteractionEnabled = true
    //                    cell.addGestureRecognizer(pinchGesture)
                        cell.imgView.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "image_placeholder"), options: .refreshCached, context: nil)
                    }
                }
            }
        }

  
        
        
        return cell
    }
    @objc
      private func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
      }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //return CGSize.init(width: 100, height: 100)//
        return CGSize(width: UIScreen.main.bounds.width, height:collectionView.bounds.height)
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
//            collectionView.reloadItems(at: [indexPath])
        }
        //self.objPageController.currentPage = indexPath.item
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
//        let objIndexpath = IndexPath.init(item: self.objPageController.currentPage, section: 0)
//
//        if let cell = self.collectionJOBDetail.cellForItem(at: objIndexpath) as? JOBDetailCollectionViewCell{
//            DispatchQueue.main.async {
////                cell.objScrollView.setZoomScale(1.0, animated: false)
//
//            }
//        }
        self.objPageController.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
        let index = scrollView.contentOffset.x / witdh
        let roundedIndex = round(index)
        self.objPageController.currentPage = Int(roundedIndex)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        self.objPageController.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {

        self.objPageController.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }*/
    
}

extension UIImageView {
  func enableZoom() {
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
    isUserInteractionEnabled = true
    addGestureRecognizer(pinchGesture)
  }

  @objc
  private func startZooming(_ sender: UIPinchGestureRecognizer) {
    let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
    guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
    sender.view?.transform = scale
    sender.scale = 1
  }
}
