//
//  CategoriesVC.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 12/08/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit

class CategoriesVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var tblviewCategories: UITableView!
    @IBOutlet weak var searchbarCategory: UISearchBar!
    var textField: UITextField?
    
    var arrCategories = NSMutableArray()
    var newArrCategories = NSMutableArray()
    var selectedCategories = NSMutableArray()
    
    var isSearching = Bool()
    
    var isForProffesionals = Bool()
    var isForFilter = Bool()
    
    //MARK: - UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        selectedCategories = NSMutableArray.init()
        newArrCategories = NSMutableArray.init()
        
        if self.isForProffesionals == true {
            
            if isKeyPresentInUserDefaults(key: "selectedCategoriesForProffesionals") {
                
                let myArray = UserDefaults.standard.value(forKey: "selectedCategoriesForProffesionals") as! NSArray
                selectedCategories = myArray.mutableCopy() as! NSMutableArray
            }
        }
        else if self.isForFilter == true {
            
            if isKeyPresentInUserDefaults(key: "selectedCategoriesForFilter") {
                
                let myArray = UserDefaults.standard.value(forKey: "selectedCategoriesForFilter") as! NSArray
                selectedCategories = myArray.mutableCopy() as! NSMutableArray
            }
        }
        else {
            if isKeyPresentInUserDefaults(key: "selectedCategories") {
                
                let myArray = UserDefaults.standard.value(forKey: "selectedCategories") as! NSArray
                selectedCategories = myArray.mutableCopy() as! NSMutableArray
            }
        }
        RegisterCell()
    }
    
    
    // MARK: - Register Cell
    
    func RegisterCell()  {
        self.tblviewCategories.register(UINib.init(nibName: "CategoryCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
    }
    
    // MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isSearching == true {
            return newArrCategories.count
        }
        else {
            return arrCategories.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let aObjCell = tblviewCategories.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        
        aObjCell.contentView.backgroundColor = UIColor.clear
        aObjCell.selectionStyle = .none
        
        var dataDict = NSDictionary()
        
        if self.isSearching == true {
            dataDict = newArrCategories.object(at: indexPath.row) as! NSDictionary
        }
        else {
            dataDict = arrCategories.object(at: indexPath.row) as! NSDictionary
        }
        
        aObjCell.lblCategory.text = (dataDict["name"] as! String)
        
        aObjCell.btnCategorySelection.tag = indexPath.row
        aObjCell.btnCategorySelection.addTarget(self, action: #selector(btnTickClicked), for: .touchUpInside)
        
        if selectedCategories.count > 0 {
            if selectedCategories.contains(dataDict) {
                aObjCell.btnCategorySelection.isSelected = true
            }
            else {
                aObjCell.btnCategorySelection.isSelected = false
            }
        }
        
        return aObjCell
    }
    
    //MARK: - Actions
    
    @IBAction func btnCancelClicked(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDoneClicked(_ sender: UIButton) {
        
        let myArray = selectedCategories as Array
        
        if self.isForProffesionals == true {
            UserDefaults.standard.set(myArray, forKey: "selectedCategoriesForProffesionals")
            UserDefaults.standard.set(true, forKey: "isfromCategoriesForProffesionals")
        }
        else if self.isForFilter == true {
            UserDefaults.standard.set(myArray, forKey: "selectedCategoriesForFilter")
            UserDefaults.standard.set(true, forKey: "isfromCategoriesForFilter")
        }
        else {
            UserDefaults.standard.set(myArray, forKey: "selectedCategories")
            UserDefaults.standard.set(true, forKey: "isfromCategories")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnaddClicked(_ sender: UIButton) {
        
        let alert = UIAlertController(title: AppName, message: "Add Category", preferredStyle: .alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "CANCEL", style: .default, handler:nil))
        alert.addAction(UIAlertAction(title: "ADD", style: .default, handler:{ (UIAlertAction) in
            self.callAPIToAddCategory()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - API
    
    func callAPIToAddCategory() {
        
        let userID = UserSettings.userID//UserDefaults.standard.value(forKey: "userID") as! String
        
        
        let dict = [
            APIManager.Parameter.userID :userID,
            APIManager.Parameter.categoryName : textField!.text!
        ]
        
        APIManager.sharedInstance.CallAPIPost(url: Url_addCategory, parameter: dict as JSONDICTIONARY, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let response = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                let dataDict = response["data"] as! NSDictionary
                
                self.arrCategories.add(dataDict)
                
                self.tblviewCategories.reloadData()
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    
    func callAPIToGetCategories() {
        
        APIManager.sharedInstance.CallAPIPost(url: Url_Categories, parameter: nil, complition: { (error, JSONDICTIONARY) in
            
            let isError = JSONDICTIONARY!["isError"] as! Bool
            
            if  isError == false{
                print(JSONDICTIONARY as Any)
                let dataDict = JSONDICTIONARY?["response"] as! JSONDICTIONARY
                
                self.arrCategories = (dataDict["data"] as! NSArray).mutableCopy() as! NSMutableArray
                
                self.tblviewCategories.reloadData()
            }
            else{
                let message = JSONDICTIONARY!["response"] as! String
                
                SAAlertBar.show(.error, message:message.capitalized)
            }
        })
    }
    
    // MARK: - User Defined Methods
    
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!        //Save reference to the UITextField
            self.textField?.placeholder = "add your category here";
        }
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    @objc func btnTickClicked(_ sender : UIButton) {
        
        var dataDict = NSDictionary()
        if isSearching == true {
            dataDict = newArrCategories.object(at: sender.tag) as! NSDictionary
        }
        else {
            dataDict = arrCategories.object(at: sender.tag) as! NSDictionary
        }
        
        if sender.isSelected == true {
            sender.isSelected = false
            selectedCategories.remove(dataDict)
        }
        else {
            
            sender.isSelected = true
            selectedCategories.add(dataDict)
        }
        
        tblviewCategories.reloadData()
        
        print(selectedCategories)
    }
    
    // MARK: - Searchbar delegate methods
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchbarCategory.showsCancelButton = true
    }
    
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        self.isSearching = true
        
        if newArrCategories.count > 0 {
            newArrCategories = NSMutableArray.init()
        }
        
        var txtAfterUpdate = String()
        if let tempStr = searchBar.text as NSString? {
            txtAfterUpdate = tempStr.replacingCharacters(in: range, with: text as String)
        }
        
        for item in arrCategories {
            let dict = item as! NSDictionary
            let name = dict["name"] as! String
            
            if name.lowercased().range(of:txtAfterUpdate.lowercased()) != nil {
                
                print("exists")
                newArrCategories.add(dict)
                
                tblviewCategories.reloadData()
            }
        }
        
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.isSearching = false
            searchBar.showsCancelButton = false
            
            searchBar.text = ""
            searchbarCategory.resignFirstResponder()
            
            tblviewCategories.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearching = false
        searchBar.showsCancelButton = false
        
        searchBar.text = ""
        searchbarCategory.resignFirstResponder()
        
        tblviewCategories.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.isSearching = false
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.isSearching = false
        searchBar.showsCancelButton = false
        
        searchBar.resignFirstResponder()
    }
    
}
