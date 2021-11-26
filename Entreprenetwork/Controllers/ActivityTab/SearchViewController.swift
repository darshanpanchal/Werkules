

import UIKit
enum SearchType {
    case Industry
    case TravelTime
}
protocol SearchViewDelegate {
    func didSelectValuesFromSearchView(values:[Any],searchType:SearchType)
}

class SearchViewController: UIViewController {

    @IBOutlet var txtSeachCountry:UITextField!
    @IBOutlet var tableViewSearch:UITableView!
    @IBOutlet var buttonCancel:RoundButton!
    @IBOutlet var buttonSelect:RoundButton!
    @IBOutlet var topConstraint:NSLayoutConstraint!
    @IBOutlet var heightOfSearchView:NSLayoutConstraint!
    @IBOutlet var lblSearchHeader:UILabel!
    @IBOutlet var containerView:UIView!
    @IBOutlet var leadingStackConstraint:NSLayoutConstraint!
    @IBOutlet var trailingStackConstraint:NSLayoutConstraint!
    @IBOutlet var imageSearch:UIImageView!
    @IBOutlet var viewSeprator:UIView!
    
    @IBOutlet var nocountySelectorHeight:NSLayoutConstraint?
    @IBOutlet weak var testButton: UIButton?
    
    @IBOutlet var buttonAll:UIButton!
    @IBOutlet var lblAll:UILabel!
    @IBOutlet var imageViewAll:UIImageView!
    
    @IBOutlet var stackViewSelectAll:UIStackView!
    
    
    var objSearchType:SearchType = .Industry
    
    var delegate:SearchViewDelegate?
    
    var isSingleSelection:Bool = false
    
    let heightOfTableViewCell:CGFloat = 50.0
    
    var arrayOfIndustry:[Industry] = []
    var arrayOfFilterIndustry:[Industry] = []
    var selectedIndustry:NSMutableSet = NSMutableSet()
    
    var arrayOfTravelTime:[GeneralList] = []
    var arrayOfFilterTravelTime:[GeneralList] = []
    var selectedTravelTime:NSMutableSet = NSMutableSet()
    
    var typpedString:String = ""
    
    var heightOfKeyboard:CGFloat{
        get{
            return 320.0*UIScreen.main.bounds.height/667.0
        }
    }
    var countryID:String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //imageSearch.image = #imageLiteral(resourceName: "searchupdate").withRenderingMode(.alwaysTemplate)
        imageSearch.tintColor = UIColor.black
//        imageSearch.alpha = 0.3
        // Do any additional setup after loading the view.
        print(self.selectedIndustry)
        //Configure SeachView
        self.configureSearchView()

        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.heightOfSearchView.constant = UIScreen.main.bounds.height - self.heightOfKeyboard
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
   
    @objc func keyboardWillShow(notification: NSNotification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, animations: {
                self.topConstraint.constant = 0
//                self.heightOfSearchView.constant = 450.0//UIScreen.main.bounds.height - self.heightOfKeyboard
                print(keyboardSize)
                print(UIScreen.main.bounds.height)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, animations: {
                self.topConstraint.constant = 100
//                self.heightOfSearchView.constant = 450.0//434.0
                print(keyboardSize)
                print(UIScreen.main.bounds.height)
                self.view.layoutIfNeeded()
            })
        }
    }
    func configureSearchView(){
        self.txtSeachCountry.delegate = self
        self.configureTableView()
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 14.0
        
      
        
//        self.lblAll.isHidden = self.isSingleSelection
//        self.imageViewAll.isHidden = self.isSingleSelection
//        self.buttonAll.isHidden = self.isSingleSelection
//
        self.stackViewSelectAll.isHidden = self.isSingleSelection
        self.arrayOfFilterIndustry = self.arrayOfIndustry
        self.arrayOfFilterTravelTime = self.arrayOfTravelTime
        DispatchQueue.main.async {
            self.tableViewSearch.reloadData()
            self.buttonSelect.setTitle("Submit", for: .normal)
        }
        /*
        self.buttonCancel.setBackgroundColor(color:UIColor.init(hexString:"2963AF"), forState: .highlighted)
        self.buttonSelect.setBackgroundColor(color:UIColor.init(hexString:"2963AF"), forState: .highlighted)
        self.buttonCancel.applyGradient(colours: [UIColor.white.withAlphaComponent(0.1),UIColor.init(hexString:"2963AF").withAlphaComponent(0.2),
                                                  UIColor.init(hexString:"2963AF").withAlphaComponent(0.5), UIColor.init(hexString:"2963AF")])
        self.buttonSelect.applyGradient(colours: [UIColor.white.withAlphaComponent(0.1),UIColor.init(hexString:"2963AF").withAlphaComponent(0.2),
                                                  UIColor.init(hexString:"2963AF").withAlphaComponent(0.5),UIColor.init(hexString:"2963AF")])*/
    }
    func configureTableView(){
        self.tableViewSearch.tableHeaderView = UIView()
        self.tableViewSearch.rowHeight = UITableView.automaticDimension
        self.tableViewSearch.estimatedRowHeight = self.heightOfTableViewCell
        self.tableViewSearch.delegate = self
        self.tableViewSearch.dataSource = self
        self.tableViewSearch.tableFooterView = UIView()
        self.tableViewSearch.separatorStyle = .none
        let width = (UIScreen.main.bounds.height > 568.0) ? self.containerView.bounds.width/3 : self.containerView.bounds.width/3 - 20.0
        
        switch self.`objSearchType` {
            case .Industry:
                self.lblSearchHeader.text = "Search Industry"
                self.buttonSelect.isHidden = false
            case .TravelTime:
                self.lblSearchHeader.text = "Travel Time"
                self.buttonSelect.isHidden = false
            break
        }
        self.lblSearchHeader.textColor = UIColor.init(hex: "38B5A3")
        self.buttonCancel.setTitleColor(UIColor.init(hex: "38B5A3"), for: .normal)
        self.buttonSelect.setTitleColor(UIColor.init(hex: "38B5A3"), for: .normal)
    }
    // MARK: - API Request Methods
    //Get Free Search CityDetail
    /*
    func getFreeSearchCityDetail(countryID:String){
        let freeSearchURL = "base/native/locations/\(countryID)/freesearch"
        guard CommonClass.shared.isConnectedToInternet else{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage:"No Internet connection.")
            }
            return
        }
       
        let freeSearchParameters:[String:AnyObject] = ["SearchText":"\(self.typpedString)" as AnyObject]
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:freeSearchURL, parameter:freeSearchParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let arraySuccess = successDate["location"] as? NSArray{
                self.arrayOfCountry = []
                for objCountry in arraySuccess{
                    if let jsonCountry = objCountry as? [String:Any]{
                        let countryDetail = CountyDetail.init(objJSON: jsonCountry)
                        self.arrayOfCountry.append(countryDetail)
                    }
                }
                self.arrayOfFilterCounty = self.arrayOfCountry
                DispatchQueue.main.async {
                    self.view.endEditing(true)
                    self.tableViewSearch.reloadData()
                }
            }else{
                
            }
        }) { (responseFail) in
            if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
    }*/
    // MARK: - Selector Methods
    @IBAction func buttonFullViewSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.txtSeachCountry.resignFirstResponder()
        }
    }
    @IBAction func buttonNoCountrySelector(sender:UIButton){
        //self.noCountryDelegate?.selectNoCountrySelector()
    }
    @IBAction func buttonCancelSelector(sender:UIButton){
        //
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func buttonOKaySelector(sender:UIButton){
        if let _ = self.delegate{
            if self.objSearchType == .Industry{
                var arrayselectedIndustry:[Industry] = []
                if self.selectedIndustry.count > 0{
                    if let allIndustry = self.selectedIndustry.allObjects as? [Industry]{
                        for objIndustry in allIndustry{
                            let filtered = self.arrayOfIndustry.filter { $0.name == "\(objIndustry.name)"}
                            if filtered.count > 0{
                                arrayselectedIndustry.append(filtered.first!)
                            }
                        }
                    }
                }
                self.delegate!.didSelectValuesFromSearchView(values: arrayselectedIndustry  ,searchType: self.objSearchType)

            }else if self.objSearchType == .TravelTime{
                var arrayselectedTravelTime:[GeneralList] = []
                if self.selectedTravelTime.count > 0{
                    if let allTravelTime = self.selectedTravelTime.allObjects as? [String]{
                        for objTravelTime in allTravelTime{
                            let filtered = self.arrayOfTravelTime.filter { $0.name == "\(objTravelTime)"}
                            if filtered.count > 0{
                                arrayselectedTravelTime.append(filtered.first!)
                            }
                        }
                    }
                }
                self.delegate!.didSelectValuesFromSearchView(values: arrayselectedTravelTime  ,searchType: self.objSearchType)
            }
        }
        do {
            self.dismiss(animated: false, completion: nil)
        }
    }
    /*
    @IBAction func buttonSelectSelector(sender:UIButton){
        if self.objSearchType == .Langauge{
             var languages:[ExperienceLangauge] = []
            if self.selectedLangauges.count > 0{
                if let arrayOfLanID = self.selectedLangauges.allObjects as? [String]{
                    for languageID in arrayOfLanID{
                        let filtered = self.arrayOfLanguage.filter { $0.langaugeID == "\(languageID)"}
                        if filtered.count > 0{
                            languages.append(filtered.first!)
                        }
                    }
                }
            }else{
                //self.dismiss(animated: true, completion: nil)
            }
            if self.isGuideLanguage{
                //Unwind to guide languages
                self.performSegue(withIdentifier: "unwindToSettingFromGuideLanguage", sender: languages)
            }else if self.isGuideRequestLanguage{
                //Unwind to guide request
                self.performSegue(withIdentifier: "unwindToSettingFromGuideRequest", sender: languages)
            }else if self.isBecomeGuideLanguage{
                //Unwind to become guide
                self.performSegue(withIdentifier: "unwindToBecomeGuideFromLangauge", sender: languages)
            }else if self.isFilterLanguage{
                //Unwind to filter
                self.performSegue(withIdentifier: "unwindToFilterFromLangauge", sender: languages)
            }else{
                //Unwind With Languages
                self.performSegue(withIdentifier: "unwindToExperienceFromLanguage", sender: languages)
            }
        }else if self.objSearchType == .Collection{
            var collections:[Collections] = []
            if self.selectedCollections.count > 0{
                if let arrayOfCollectionID = self.selectedCollections.allObjects as? [String]{
                    for colletionID in arrayOfCollectionID{
                        let filtered = self.arrayOfCollection.filter { $0.id == "\(colletionID)"}
                        if filtered.count > 0{
                            collections.append(filtered.first!)
                        }
                    }
                }
               }
            if self.isFilterCollection{
                //Unwind With Collection
                self.performSegue(withIdentifier: "unwindToFilterFromCollection", sender: collections)
            }else{
                //Unwind With Collection
                self.performSegue(withIdentifier: "unwindToAddExperienceCollection", sender: collections)
            }
            /*else{
                self.dismiss(animated: true, completion: nil)
            }*/
        }
    }*/
    @IBAction func buttonTrasperantSelector(sender:UIButton){
        self.view.endEditing(true)
    }
    @IBAction func buttonAllOptionSelctor(sender:UIButton){
        self.buttonAll.isSelected = !self.buttonAll.isSelected
       self.configureSelectDeSelectAll()
    }
    func configureSelectDeSelectAll(){
        self.selectedIndustry.removeAllObjects()
        /*
        if self.buttonAll.isSelected{
            self.imageViewAll.image = #imageLiteral(resourceName: "check.png").withRenderingMode(.alwaysTemplate)
            if self.objSearchType == .SchoolClass{
                self.selectedSchoolClass.addObjects(from: self.arrayOfFilerClassOptions.map{$0.strClassId})

            }else if self.objSearchType == .ClassStudent{
                self.selectedStudent.addObjects(from: self.arrayOfFilterStudentOptions.map{$0.studentID})
            }else if self.objSearchType == .StudentSection{
                self.selectedSchoolSection.addObjects(from: self.arraySectionOptions.map{$0.sectionID})
            }
        }else{
            self.imageViewAll.image = #imageLiteral(resourceName: "uncheck.png").withRenderingMode(.alwaysTemplate)
            if self.objSearchType == .SchoolClass{
                self.selectedSchoolClass.removeAllObjects()

            }else if self.objSearchType == .ClassStudent{
                self.selectedStudent.removeAllObjects()

            }else if self.objSearchType == .StudentSection{
                self.selectedSchoolSection.removeAllObjects()
            }
        } */
        DispatchQueue.main.async {
            self.tableViewSearch.reloadData()
        }
    }
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "unwindToAddExperienceFromLocation",let objCountry = sender as? CountyDetail{
            if let discoverViewController: AddExperienceViewController = segue.destination as? AddExperienceViewController{
                discoverViewController.selectedCountryDetail = objCountry
            }
        }else if segue.identifier == "unwindSearchToDiscover",let objCountry = sender as? CountyDetail{
            if let discoverViewController: DiscoverViewController = segue.destination as? DiscoverViewController{
                discoverViewController.countryDetail = objCountry
            }
            //
        } else if segue.identifier == "unwindToGuideRequestFromLocation",let objCountry = sender as? CountyDetail{
            if let addNewExperience:GuideSignUpViewController = segue.destination as? GuideSignUpViewController{
                addNewExperience.selectedCity = objCountry
            }
        } else if segue.identifier == "unwindToGuideRequestFromCounty",let objCountry = sender as? BecomeGuideCountry{
            if let addNewExperience:GuideSignUpViewController = segue.destination as? GuideSignUpViewController{
                addNewExperience.selectedCountry = objCountry
            }
        }else if segue.identifier == "unWindToAddExperienceCurrency",let objCurrency = sender as? Currency{
            if let addNewExperience:AddExperienceViewController = segue.destination as? AddExperienceViewController{
                addNewExperience.selectedCurrency = objCurrency
            }
        }else if segue.identifier == "unWindToAddExperienceFromEffort",let selectedEffort = sender as? String{
            if let addNewExperience:AddExperienceViewController = segue.destination as? AddExperienceViewController{
                addNewExperience.selectedEffort = selectedEffort
            }
        }else if segue.identifier == "unwindToSettingFromGuideLanguage",let selectedLang = sender as? [ExperienceLangauge]{
            if let addNewExperience:SettingViewController = segue.destination as? SettingViewController{
                addNewExperience.selectedLangauges = selectedLang
            }
        }else if segue.identifier == "unwindToSettingFromGuideRequest",let selectedLang = sender as? [ExperienceLangauge]{
            if let guideRequest:GuideSignUpViewController = segue.destination as? GuideSignUpViewController{
                guideRequest.selectedLangauges = selectedLang
            }
        }else if segue.identifier == "unwindToExperienceFromLanguage",let selectedLang = sender as? [ExperienceLangauge]{
            if let addNewExperience:AddExperienceViewController = segue.destination as? AddExperienceViewController{
                addNewExperience.selectedLangauges = selectedLang
            }
        }else if segue.identifier == "unwindToFilterFromCollection",let selectedCollection = sender as? [Collections]{
            if let filerViewController:FilterViewController = segue.destination as? FilterViewController{
                filerViewController.selectedCollection = selectedCollection
            }
        }else if segue.identifier == "unwindToAddExperienceCollection",let selectedCollection = sender as? [Collections]{
            if let addNewExperience:AddExperienceViewController = segue.destination as? AddExperienceViewController{
                addNewExperience.selectedCollection = selectedCollection
            }
        }else if segue.identifier == "unWindToScheduleFromOccurence",let selectedOccurence = sender as? String{
            if let scheduleViewController:ScheduleViewController = segue.destination as? ScheduleViewController{
                scheduleViewController.selectedOccurence = selectedOccurence
            }
        }else if segue.identifier == "unWindToScheduleFromWeakDay",let selectedWeekDay = sender as? String{
            if let scheduleViewController:ScheduleViewController = segue.destination as? ScheduleViewController{
                scheduleViewController.selectedWeekDay = selectedWeekDay
            }
        }else if segue.identifier == "unwindToBecomeGuideFromCounty",let objCountry = sender as? BecomeGuideCountry{
            if let addNewExperience:BecomeGuideViewController = segue.destination as? BecomeGuideViewController{
                addNewExperience.selectedCountry = objCountry
            }
        }
        else if segue.identifier == "unwindToBecomeGuideFromLangauge",let selectedLang = sender as? [ExperienceLangauge]{
            if let addNewExperience:BecomeGuideViewController = segue.destination as? BecomeGuideViewController{
                addNewExperience.selectedLangauges = selectedLang
            }
        }else if segue.identifier == "unwindToFilterFromLangauge",let selectedLang = sender as? [ExperienceLangauge]{
            if let addNewExperience:FilterViewController = segue.destination as? FilterViewController{
                addNewExperience.selectedLangauges = selectedLang
            }
        }else if segue.identifier == "unwindToBecomeGuideFromLocation",let objCountry = sender as? CountyDetail{
            if let addNewExperience:BecomeGuideViewController = segue.destination as? BecomeGuideViewController{
                addNewExperience.selectedCity = objCountry
            }
        } else if segue.identifier == "unwindToInquiry",let objCountry = sender as? BecomeGuideCountry{
            if let addNewExperience:InquiryViewController = segue.destination as? InquiryViewController{
                addNewExperience.selectedCountry = objCountry
            }
        } else if segue.identifier == "unwindToSignUpFromCounty",let objCountry = sender as? BecomeGuideCountry{
            if let addNewExperience:SignUpViewController = segue.destination as? SignUpViewController{
                addNewExperience.selectedCountry = objCountry
            }
        } else if segue.identifier == "unwindToSignUpFromLocation",let objCountry = sender as? CountyDetail{
            if let addNewExperience:SignUpViewController = segue.destination as? SignUpViewController{
                addNewExperience.selectedCity = objCountry
            }
        } else if segue.identifier == "unwindToCouponCodeListFromSearch",let objCountry = sender as? Coupon{
            //unwindToCouponCodeListFromSearch
            if let addCouponCodeList:CouponCodeListViewController = segue.destination as? CouponCodeListViewController{
                addCouponCodeList.strCouponCode = "\(objCountry.couponID)"
            }
        }
    }*/
}
extension SearchViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            //"noCityResponce.hint"
        
        switch self.objSearchType {
        case .Industry:
            return self.arrayOfFilterIndustry.count
        case .TravelTime:
            return self.arrayOfFilterTravelTime.count
            /*
            case .Location:
                return 0//self.arrayOfFilterLocation.count
            case .City:
                /*
                if self.typpedString.count > 0,self.arrayOfFilterCounty.count == 0{
               tableView.showMessageLabel(msg:Vocabulary.getWordFromKey(key:"noCityResponce.hint") , backgroundColor: .clear)
                }else{
                    tableView.removeMessageLabel()

                }*/
                return 0//self.arrayOfFilterCounty.count
            case .Country:
                return 0//self.arrayOfFilterGuideCountry.count
            case .Price:
                return 0
            case .Currency:
                return 0//self.arrayOfFilterCurrency.count
            case .Effort:
                return 0//self.arrayOfFilterEffort.count
            case .Langauge:
                return 0//self.arrayOfFilterLangauge.count
            case .Collection:
                return 0//self.arrayOfFilterCollection.count
            case .Occurence:
                return 0//self.arrayOfFilterOccurance.count
            case .WeekDays:
                return 0//self.arrayOfFilterWeekDays.count
            case .Coupon:
                return 0//self.arrayOfFilterCoupon.count
            case .SchoolClass :
                return self.arrayOfFilerClassOptions.count
            case .StudentSection :
                return self.arrayOfFilerSectionOptions.count
            case .ClassStudent :
                return self.arrayOfFilterStudentOptions.count
            case .CategoryType :
                return self.arrayOfFilterRemarkCategory.count
            case .CategotyName :
                return self.arrayOfFilerRemark.count
                */
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") else {
                return SearchTableViewCell(style: .default, reuseIdentifier: "SearchTableViewCell")
            }
            return cell as! SearchTableViewCell
        }()
        cell.lblSearchResult?.textColor = .black
        cell.lblSearchResult?.adjustsFontForContentSizeCategory = true

        
        if self.objSearchType == .Industry{
            let objIndustry = self.arrayOfFilterIndustry[indexPath.row]
            if self.selectedIndustry.contains(objIndustry){
                cell.imgSelected.image = UIImage.init(named: "radio_check")
            }else{
                cell.imgSelected.image  = UIImage.init(named: "radio_uncheck")
            }
            cell.lblSearchResult?.text = "\(objIndustry.name)"
        }else if self.objSearchType == .TravelTime{
            let objTravelTime = self.arrayOfFilterTravelTime[indexPath.row]
            if self.selectedTravelTime.contains(objTravelTime.name){
                cell.lblSearchResult?.textColor = UIColor.init(hex: "38B5A3")
                cell.imgSelected.image = UIImage.init(named: "radio_check_update")
            }else{
                cell.lblSearchResult?.textColor = .black
                cell.imgSelected.image  = UIImage.init(named: "radio_uncheck")
            }
            cell.lblSearchResult?.text = "\(objTravelTime.name)"
        }
        /*
        if self.objSearchType == .ClassStudent{
            let objStudent = self.arrayOfFilterStudentOptions[indexPath.row]
            cell.lblSearchResult?.text = "\(objStudent.studentName) \(objStudent.fatherName) \(objStudent.surName)"
            if self.selectedStudent.contains("\(objStudent.studentID)"){
                cell.imgSelected.image = (self.isSingleSelection) ? #imageLiteral(resourceName: "radioselect").withRenderingMode(.alwaysTemplate) : #imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate)
            }else{
                cell.imgSelected.image = (self.isSingleSelection) ? #imageLiteral(resourceName: "radiodeselect").withRenderingMode(.alwaysTemplate) : #imageLiteral(resourceName: "uncheck").withRenderingMode(.alwaysTemplate)
            }
        }else if self.objSearchType == .SchoolClass{
            cell.lblSearchResult?.text = "\(self.arrayOfFilerClassOptions[indexPath.row].strName)"
            let objClass = self.arrayOfFilerClassOptions[indexPath.row]
            if self.selectedSchoolClass.contains("\(objClass.strClassId)"){
                cell.imgSelected.image = (self.isSingleSelection) ? #imageLiteral(resourceName: "radioselect").withRenderingMode(.alwaysTemplate) : #imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate)
            }else{
                cell.imgSelected.image = (self.isSingleSelection) ? #imageLiteral(resourceName: "radiodeselect").withRenderingMode(.alwaysTemplate) : #imageLiteral(resourceName: "uncheck").withRenderingMode(.alwaysTemplate)
            }
        }else if self.objSearchType == .StudentSection{
            cell.lblSearchResult?.text = "\(self.arrayOfFilerSectionOptions[indexPath.row].sectionName)"
            let objClass = self.arrayOfFilerSectionOptions[indexPath.row]
            if self.selectedSchoolSection.contains("\(objClass.sectionID)"){
                cell.imgSelected.image = (self.isSingleSelection) ? #imageLiteral(resourceName: "radioselect").withRenderingMode(.alwaysTemplate) : #imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate)
            }else{
                cell.imgSelected.image = (self.isSingleSelection) ? #imageLiteral(resourceName: "radiodeselect").withRenderingMode(.alwaysTemplate) : #imageLiteral(resourceName: "uncheck").withRenderingMode(.alwaysTemplate)
            }
        }else if self.objSearchType == .CategoryType{
            cell.lblSearchResult?.text = "\(self.arrayOfFilterRemarkCategory[indexPath.row].name)"
            let objClass = self.arrayOfFilterRemarkCategory[indexPath.row]
            if self.selectedRemarkCategory.contains("\(objClass.id)"){
                cell.imgSelected.image = (self.isSingleSelection) ? #imageLiteral(resourceName: "radioselect").withRenderingMode(.alwaysTemplate) : #imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate)
            }else{
                cell.imgSelected.image = (self.isSingleSelection) ? #imageLiteral(resourceName: "radiodeselect").withRenderingMode(.alwaysTemplate) : #imageLiteral(resourceName: "uncheck").withRenderingMode(.alwaysTemplate)
            }
        }else if self.objSearchType == .CategotyName{
            //arrayOfFilerRemark
            cell.lblSearchResult?.text = "\(self.arrayOfFilerRemark[indexPath.row].remarkName)"
            let objClass = self.arrayOfFilerRemark[indexPath.row]
            if self.selectedRemark.contains("\(objClass.remarkID)"){
                cell.imgSelected.image = (self.isSingleSelection) ? #imageLiteral(resourceName: "radioselect").withRenderingMode(.alwaysTemplate) : #imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate)
            }else{
                cell.imgSelected.image = (self.isSingleSelection) ? #imageLiteral(resourceName: "radiodeselect").withRenderingMode(.alwaysTemplate) : #imageLiteral(resourceName: "uncheck").withRenderingMode(.alwaysTemplate)
            }
            
        }else{
            
        }*/
    
        cell.backgroundColor = UIColor.white
        cell.imgSelected?.isHidden = false
 
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightOfTableViewCell
    }
    /*
    func selectedLocation( _ cityId: String, _ cityName: String, _ countryName: String) {
        let currentUser: User? = User.getUserFromUserDefault()
        let userId: String = (currentUser?.userID)!
        let urlBookingDetail = "users/\(userId)/native/location/\(cityId)/userlocation"
        
        APIRequestClient.shared.sendRequest(requestType: .PUT, queryString:urlBookingDetail, parameter: [:], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let _ = success["data"] as? [String:Any] {
                // Location Change Suucess Alert
                currentUser!.userLocationID = cityId
                currentUser!.userCity = cityName
                currentUser!.userCountry = countryName
                currentUser!.userCurrentCity = cityName
                currentUser!.userCurrentCountry = countryName
                currentUser!.setUserDataToUserDefault()
                //Perform Segue
                self.performSegue(withIdentifier: "unwindToSettingFromSearchLocation", sender: nil)
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }) { (responseFail) in
            if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
    }*/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        if self.objSearchType == .Industry{
                   guard self.arrayOfFilterIndustry.count > indexPath.row else {
                       return
                   }
            if self.isSingleSelection{
                           self.selectedIndustry.removeAllObjects()
            }
            let objClass = self.arrayOfFilterIndustry[indexPath.row]
                       if self.selectedIndustry.contains(objClass){
                           self.selectedIndustry.remove(objClass)
                       }else{
                         self.selectedIndustry.add(objClass)
                       }
        }else if self.objSearchType == .TravelTime{
            guard self.arrayOfFilterTravelTime.count > indexPath.row else {
                return
            }
             if self.isSingleSelection{
                    self.selectedTravelTime.removeAllObjects()
             }
            if self.selectedTravelTime.contains(self.arrayOfFilterTravelTime[indexPath.row].name){
                self.selectedTravelTime.remove(self.arrayOfFilterTravelTime[indexPath.row].name)
            }else{
                self.selectedTravelTime.add(self.arrayOfFilterTravelTime[indexPath.row].name)
            }
                }
        DispatchQueue.main.async {
            self.tableViewSearch.reloadData()
        }
    }
}
extension SearchViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        /*
        guard !self.typpedString.isContainWhiteSpace() else{
            return false
        }*/
        guard self.typpedString.count > 0 else {
            if self.objSearchType == .Industry{
                self.arrayOfFilterIndustry = self.arrayOfIndustry
                DispatchQueue.main.async {
                    self.tableViewSearch.reloadData()
                }
            }else if self.objSearchType == .TravelTime{
                self.arrayOfFilterTravelTime = self.arrayOfTravelTime
                DispatchQueue.main.async {
                    self.tableViewSearch.reloadData()
                }
            }
            /*
            if self.objSearchType == .SchoolClass{
                self.arrayOfFilerClassOptions = self.arrayclassOptions
                DispatchQueue.main.async {
                    self.tableViewSearch.reloadData()
                }
            }else if self.objSearchType == .StudentSection{
                self.arrayOfFilerSectionOptions = self.arraySectionOptions
                DispatchQueue.main.async {
                    self.tableViewSearch.reloadData()
                }
            }else if self.objSearchType == .ClassStudent{
                self.arrayOfFilterStudentOptions = self.arrayOfStudentOptions
                DispatchQueue.main.async {
                    self.tableViewSearch.reloadData()
                }
            }else if self.objSearchType == .CategoryType{
                self.arrayOfFilterRemarkCategory = self.arrayOfRemarkCategory
                DispatchQueue.main.async {
                    self.tableViewSearch.reloadData()
                }
            }else if self.objSearchType == .CategotyName{
                self.arrayOfFilerRemark = self.arrayOfRemark
                DispatchQueue.main.async {
                    self.tableViewSearch.reloadData()
                }
            }*/
            
            return true
        }
        if self.objSearchType == .Industry{
            let filtered = self.arrayOfIndustry.filter { $0.name.localizedCaseInsensitiveContains("\(typpedString)") }
            self.arrayOfFilterIndustry = filtered
        }else if self.objSearchType == .TravelTime{
            let filtered = self.arrayOfTravelTime.filter { $0.name.localizedCaseInsensitiveContains("\(typpedString)") }
            self.arrayOfFilterTravelTime = filtered
        }
        /*else if self.objSearchType == .StudentSection{
            let filtered = self.arraySectionOptions.filter { $0.sectionName.localizedCaseInsensitiveContains("\(typpedString)") }
            self.arrayOfFilerSectionOptions = filtered
        }else if self.objSearchType == .ClassStudent{
            let filtered = self.arrayOfStudentOptions.filter { $0.fullName.localizedCaseInsensitiveContains("\(typpedString)") }
            self.arrayOfFilterStudentOptions = filtered
        }else if self.objSearchType == .CategoryType{
            let filtered = self.arrayOfRemarkCategory.filter { $0.name.localizedCaseInsensitiveContains("\(typpedString)") }
            self.arrayOfFilterRemarkCategory = filtered
        }else if self.objSearchType == .CategotyName{
            let filtered = self.arrayOfRemark.filter { $0.remarkName.localizedCaseInsensitiveContains("\(typpedString)") }
            self.arrayOfFilerRemark = filtered
        }
       */

        /*
        switch self.objSearchType {
            case .Location:
                guard self.typpedString.count > 0 else {
                    self.arrayOfFilterLocation = self.arrayOfLocation
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfLocation.filter { $0.defaultCity.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterLocation = filtered
                break
            case .City:
                guard self.typpedString.count > 0 else {
                    if self.objSearchType == .City,self.isCityFreeSearch{
                        self.getFreeSearchCityDetail(countryID:self.countryID)
                    }else{
                        self.arrayOfFilterCounty = self.arrayOfCountry
                        DispatchQueue.main.async {
                            self.tableViewSearch.reloadData()
                        }
                    }
                    return true
                }
                if !self.isCityFreeSearch{
                    let filtered = self.arrayOfCountry.filter { $0.defaultCity.localizedCaseInsensitiveContains("\(typpedString)") }
                    self.arrayOfFilterCounty = filtered
                }
                break
            case .Country:
                guard self.typpedString.count > 0 else {
                    self.arrayOfFilterGuideCountry = self.arrayOfGuideCountry
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfGuideCountry.filter { $0.countyName.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterGuideCountry = filtered
                break
            case .Price:
                break
            case .Currency:
                guard self.typpedString.count > 0 else {
                    self.arrayOfFilterCurrency = self.arrayOfCurrency
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfCurrency.filter { $0.currencyText.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterCurrency = filtered
                break
            case .Effort:
                guard self.typpedString.count > 0 else{
                    self.arrayOfFilterEffort = self.araryOfEffort
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.araryOfEffort.filter { $0.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterEffort = filtered
                break
            case .Langauge:
                guard self.typpedString.count > 0 else {
                    self.arrayOfFilterLangauge = self.arrayOfLanguage
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfLanguage.filter { $0.langaugeName.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterLangauge = filtered
                break
            case .Collection:
                guard self.typpedString.count > 0 else {
                    self.arrayOfFilterCollection = self.arrayOfCollection
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfCollection.filter { $0.title.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterCollection = filtered
                break
            case .Occurence:
                guard self.typpedString.count > 0 else{
                    self.arrayOfFilterOccurance = self.arrayOfOccurance
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfOccurance.filter { $0.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterOccurance = filtered
                break
            case .WeekDays:
                guard self.typpedString.count > 0 else{
                    self.arrayOfFilterWeekDays = self.arrayOfWeekDays
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfWeekDays.filter { $0.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterWeekDays = filtered
                break
            case .Coupon:
                guard self.typpedString.count > 0 else {
                    self.arrayOfFilterCoupon = self.arrayOfCoupon
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfCoupon.filter { $0.couponID.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterCoupon = filtered
                
                break
        }*/
        DispatchQueue.main.async {
            self.tableViewSearch.reloadData()
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if self.objSearchType == .Industry{
            self.arrayOfFilterIndustry = self.arrayOfIndustry
        }else if self.objSearchType == .TravelTime{
            self.arrayOfFilterTravelTime = self.arrayOfTravelTime
        }
        
        
        /*
        switch self.objSearchType {
            case .Location:
                self.arrayOfFilterLocation = self.arrayOfLocation
            break
            case .City:
                if self.isCityFreeSearch{
                    self.getFreeSearchCityDetail(countryID: self.countryID)
                }else{
                    self.arrayOfFilterCounty = self.arrayOfCountry
                }
            break
            case .Country:
                self.arrayOfFilterGuideCountry = self.arrayOfGuideCountry
            break
            case .Price:
            break
            case .Currency:
                self.arrayOfFilterCurrency = self.arrayOfCurrency
            break
            case .Effort:
                self.arrayOfFilterEffort = self.araryOfEffort
            break
            case .Langauge:
                self.arrayOfFilterLangauge = self.arrayOfLanguage
                break
            case .Collection:
                self.arrayOfFilterCollection = self.arrayOfCollection
                break
            case .Occurence:
                self.arrayOfFilterOccurance = self.arrayOfOccurance
            break
            case .WeekDays:
                self.arrayOfFilterWeekDays = self.arrayOfWeekDays
            break
            case .Coupon:
                self.arrayOfFilterCoupon = self.arrayOfCoupon
            break
        }
        */
        defer{
            DispatchQueue.main.async {
                self.tableViewSearch.reloadData()
            }
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        /*
        if self.objSearchType == .City,self.isCityFreeSearch{
            self.getFreeSearchCityDetail(countryID:"0")
        }else{
            textField.resignFirstResponder()
        }*/
        return true
    }
}
extension UITextField {
    /*@IBInspectable var placeholderUpdateColor: UIColor {
        get {
            guard let currentAttributedPlaceholderColor = attributedPlaceholder?.attribute(NSAttributedStringKey.foregroundColor, at: 0, effectiveRange: nil) as? UIColor else { return UIColor.clear }
            return currentAttributedPlaceholderColor
        }
        set {
            guard let currentAttributedString = attributedPlaceholder else { return }
            let attributes = [NSAttributedStringKey.foregroundColor : newValue]
            
            attributedPlaceholder = NSAttributedString(string: currentAttributedString.string, attributes: attributes)
        }
    }*/
}
class SearchTableViewCell: UITableViewCell {
    @IBOutlet var lblSearchResult:UILabel!
    @IBOutlet var imgSelected:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
}
