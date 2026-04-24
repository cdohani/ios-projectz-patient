//
//  ViewController.swift
//  Wasel Order
//
//  Created by TheRightSW on 05/05/2020.
//  Copyright © 2020 TheRightSW. All rights reserved.
//

import UIKit
import MBProgressHUD
import SafariServices

class ParentViewController: UIViewController {
    
    //Properties
   
    var loadingView : MBProgressHUD? = nil
    fileprivate var toastView: UIView!
    fileprivate var toastMessage: UILabel!
    fileprivate var viewCenter: CGPoint!
    var initialDragCenter: CGPoint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let navigationBar = navigationController?.navigationBar
        
        // Style nav bar using new Appearance API
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "customNavColor")
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        navigationBar?.standardAppearance = navBarAppearance
        navigationBar?.scrollEdgeAppearance = navBarAppearance
        
        // Use barStyle to set status bar text color to white
        // This only work when using the old styling approach
        navigationBar?.barStyle = .black
        
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK:- Loading Views
    func setNavTitle(title: String){
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: 50, height: 40))
          label.backgroundColor = .clear
          label.font = UIFont(name: "HelveticaNeue-Bold", size: 20.0)!

          label.text = title
          label.numberOfLines = 2
          label.textColor = .black
          label.sizeToFit()
          label.textAlignment = .center

          self.navigationItem.titleView = label
    }
    //    This method is going to be used for showing the loading view only
    func showLoadingView(_ title:String) {
        
        //only creating a single instance
        if loadingView == nil {
            loadingView = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        loadingView!.mode = MBProgressHUDMode.indeterminate
        loadingView!.label.text = title;
        loadingView!.removeFromSuperViewOnHide = true
        loadingView?.show(animated: true)
    }
    
    func showLoadingViewWithZeroOpacity() {
        
        if loadingView == nil {
            
            loadingView = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        loadingView!.mode = MBProgressHUDMode.indeterminate
        loadingView!.removeFromSuperViewOnHide = true
        loadingView?.show(animated: true)
        loadingView?.alpha = 0.02
    }
    func showLoadingViewWithProgress(_ title:String) {
        
        //only creating a single instance
        if loadingView == nil {
            loadingView = MBProgressHUD.showAdded(to: self.view, animated: true)
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
    func formattedAddress(from address: LocationDataModel) -> String {
        // Collect non-empty parts of the address
        let components = [
            address.address1,
            address.address2,
            address.city,
            address.stateName,
            address.zipCode
        ].filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        // Join components with a comma and space
        return components.joined(separator: ", ")
    }
    

    
    //Pop
    @objc func menuButtonPressed() {
        
        self.navigationController?.popViewController(animated: false)
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
    
 
    
    func showAlertViewForDismiss(message: String) {
        
        let alertController = UIAlertController(title: Constants.GenericStrings.alertTitle, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: Constants.GenericStrings.ok, style: .default) { (action) in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    func showAlertViewWithCompletion(message: String,completion: @escaping ()->()) {
        
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
    
    //MARK:- Navigtion Button
    func createBackButton() {
        
        self.navigationController?.setNavigationBarHidden(false, animated:true)
        let myBackButton:UIButton = UIButton(type: .custom)
        myBackButton.setImage(UIImage(named: "back"), for: .normal)
        myBackButton.tintColor = .white
        myBackButton.setTitleColor(.white, for: .normal)
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
    func getLanguage() -> String{
        if let lang = UserDefaults.standard.string(forKey: "UserLang"){
            if lang == "en"
            {
                return "en"
            }
            else{
                return "ur"
            }
        }
        else{
            return "en"
        }
    }
  
    
    func isUserLoggedIn() -> Bool {
        return UserDefaults.standard.string(forKey: "authToken") != nil
    }
}

//extension ParentViewController: UITextFieldDelegate {
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        
//        self.view.endEditing(true)
//    }
//}

extension ParentViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if (touch.view?.isKind(of: UIButton.self))! {
            
            return false
        } else if (touch.view?.isKind(of: UITableView.self))! {
            
            return false
        } else if (touch.view?.isKind(of: UITableViewCell.self))! {
            
            return false
        } else if (touch.view?.superview?.isKind(of: UITableViewCell.self))! {
            
            return false
        }
        
        return true
    }
}
