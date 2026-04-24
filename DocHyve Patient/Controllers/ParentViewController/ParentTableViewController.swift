//
//  ParentTableViewController.swift
//  Wasel Order
//
//  Created by TheRightSW on 06/05/2020.
//  Copyright © 2020 TheRightSW. All rights reserved.
//

import UIKit
import MBProgressHUD
import SafariServices

class ParentTableViewController: UITableViewController {
    
    //Properties
    var loadingView : MBProgressHUD? = nil
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        //        selectedAppLang = UserDBService().selectedLanguage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        

        
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    //MARK:- Loading Views
    
    //This method is going to be used for showing the loading view only
    func showLoadingView(_ title:String) {
        
        //only creating a single instance
        if loadingView == nil {
            loadingView = MBProgressHUD.showAdded(to: self.tableView, animated: true)
        }
        
        loadingView!.mode = MBProgressHUDMode.indeterminate
        loadingView!.label.text = title;
        loadingView!.removeFromSuperViewOnHide = true;
        loadingView?.show(animated: true)
    }
    
    func showLoadingViewWithProgress(_ title:String) {
        
        //only creating a single instance
        if loadingView == nil {
            loadingView = MBProgressHUD.showAdded(to: self.tableView, animated: true)
        }
        
        loadingView!.mode = MBProgressHUDMode.determinateHorizontalBar
        loadingView!.label.text = title;
        loadingView!.removeFromSuperViewOnHide = true;
        loadingView?.show(animated: true)
    }
    
    func updateLoadingViewProgress(_ progressValue: Double) {
        
        loadingView?.progress = Float(progressValue)
    }
    
    //This method is going to be used to dismiss the loading view
    func removeLoadingView() {
        
        loadingView?.hide(animated: true)
        loadingView = nil
    }
    
    
    //MARK:- deviceId
    func getDeviceId() -> String {
        var deviceId = ""
        #if DEBUG
        if UserDefaults.standard.object(forKey: "DeviceId") == nil {
            deviceId = UIDevice.current.identifierForVendor!.uuidString
            UserDefaults.standard.set(deviceId, forKey: "DeviceId")
        } else {
            deviceId = (UserDefaults.standard.object(forKey: "DeviceId") as! String)
        }
        #else
        deviceId = UIDevice.current.identifierForVendor!.uuidString
        #endif
        return deviceId
    }
    //MARK:- Alert View Methods
    
    //This method is going to be used for alert view
    func showAlertView(message: String) {
        
        let alertController = UIAlertController(title: Constants.GenericStrings.alertTitle, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: Constants.GenericStrings.ok, style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlertViewWithCompletion(message: String, completion: @escaping ()->()) {
        
        let alertController = UIAlertController(title: Constants.GenericStrings.alertTitle, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: Constants.GenericStrings.ok, style: .default) { (action) in
            DispatchQueue.main.async {
                completion()
            }
        }
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK:- SafariViewController
    
    //This Method is only going to be showing the content in the SFSafariViewController
    func openWithSafariVC(urlString: String)
    {
        let svc = SFSafariViewController(url: URL(string: urlString)!)
        self.present(svc, animated: true, completion: nil)
    }
    
    //MARK:- Navigation Button
    func createBackButton() {
        
        self.navigationController?.setNavigationBarHidden(false, animated:true)
        let myBackButton:UIButton = UIButton(type: .custom)
        myBackButton.setImage(UIImage(named: "Backchevron"), for: .normal)
        myBackButton.addTarget(self, action: #selector(backButtonPressed), for: .touchDown)
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
    }
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Language Handling
    func getStringFor(key: String) -> String {
        
//        let attributedString = LocalizationHandler.getValueFor(key: key)
//        return attributedString
        return ""
    }
    
}
