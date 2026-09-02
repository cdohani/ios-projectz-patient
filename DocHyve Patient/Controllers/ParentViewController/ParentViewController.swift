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
    private var backButtonCallback: (() -> Void)?
    
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
    func setNaviTitle(_ title: String, imgName: String? = nil, backAction: (() -> Void)? = nil){
        backButtonCallback = backAction // store the closure
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width*0.8, height: 40))
        label.font = UIFont.mySystemFont(ofSize: 18, weight: .bold)
        label.backgroundColor = .clear
        label.textColor = .customBlue
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = title
        if #available(iOS 26.0, *) {
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
        }
        label.sizeToFit()
        navigationItem.titleView = label
        createBackButton(icon: imgName)
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
    func push(_ vc: UIViewController, animated: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.pushViewController(vc, animated: animated)
        }
    }
    func popController() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
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
    @discardableResult
    func blockBookingIfNeeded() -> Bool {
        guard UserDefaults.standard.isAppointmentBookingBlocked else { return false }
        showAlertView(message: Constants.GenericStrings.accountBlockedDueToNoShows)
        return true
    }
    
    func showAlertView(message: String) {
        
        let alertController = UIAlertController(title: Constants.GenericStrings.alertTitle, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: Constants.GenericStrings.ok, style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        let presenter = topMostViewController() ?? self
        if presenter.presentedViewController == nil {
            presenter.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func topMostViewController() -> UIViewController? {
        var top = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
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
    
    func showAlertViewWithContine(message: String, completion: @escaping () -> ()) {
        
        let alertController = UIAlertController(
            title: Constants.GenericStrings.alertTitle,
            message: message,
            preferredStyle: .alert
        )
        
        // Cancel Button
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        
        // Continue Button
        let continueAction = UIAlertAction(
            title: "Continue",
            style: .default
        ) { _ in
            DispatchQueue.main.async {
                completion()
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(continueAction)
        
        present(alertController, animated: true)
    }

    
 
    

    
    //MARK:- SafariViewController
    
    //This Method is only going to be showing the content in the SFSafariViewController
    func openWithSafariVC(urlString: String)
    {
        let svc = SFSafariViewController(url: URL(string: urlString)!)
        self.present(svc, animated: true, completion: nil)
    }
    
    //MARK:- Navigtion Button
    func createBackButton(icon: String? = nil) {
        
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
    
    func alert(title: String? = nil, message: String? = nil, image: UIImage? = nil , buttonTitle: String = "OK", completion: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add Image
        if let image = image {
            let maxSize = CGSize(width: 245, height: 100)
            let imageSize = image.size
            
            var ratio: CGFloat!
            if imageSize.width > imageSize.height {
                ratio = maxSize.width / imageSize.width
            } else {
                ratio = maxSize.height / imageSize.height
            }
            
            let scaledSize = CGSize(width: imageSize.width * ratio,
                                    height: imageSize.height * ratio)
            
            let resizedImage = UIGraphicsImageRenderer(size: scaledSize).image { _ in
                image.draw(in: CGRect(origin: .zero, size: scaledSize))
            }
            
            let imageView = UIImageView(image: resizedImage)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            alert.view.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 45),
                imageView.widthAnchor.constraint(equalToConstant: scaledSize.width),
                imageView.heightAnchor.constraint(equalToConstant: scaledSize.height)
            ])
            
            // Add space for image
            let height = NSLayoutConstraint(item: alert.view!,
                                            attribute: .height,
                                            relatedBy: .greaterThanOrEqual,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1,
                                            constant: 180)
            alert.view.addConstraint(height)
        }
        
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default) { _ in
            completion?()
        })
        
        self.present(alert, animated: true)
    }
    
    func animateView() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
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
