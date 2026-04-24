//
//  DashboardVC.swift
//  FootBallConnect
//
//  Created by Adeel Qazi on 1/8/19.
//  Copyright © 2019 LM Mac. All rights reserved.
//

import UIKit
import Cosmos

class DashboardVC: ParentViewController {

    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var tabbar: UITabBar!
    @IBOutlet weak var vwOverlay: UIView!
    @IBOutlet weak var vwRateVisit: UIView!
    @IBOutlet weak var lblShareFeedback: UILabel!
    @IBOutlet weak var imgDoc: UIImageView!
    @IBOutlet weak var lblDocName: UILabel!
    @IBOutlet weak var lblDocSpeciality: UILabel!
    @IBOutlet weak var vwRatingMain: CosmosView!
    @IBOutlet weak var lblHowWasAppt: UILabel!
    @IBOutlet weak var vwRateWaitTime: CosmosView!
    @IBOutlet weak var lblWaitTime: UILabel!
    @IBOutlet weak var vwRateCommunication: CosmosView!
    @IBOutlet weak var lblCommunication: UILabel!
    @IBOutlet weak var vwRateCleanliness: CosmosView!
    @IBOutlet weak var lblCleanliness: UILabel!
    @IBOutlet weak var vwRateBooking: CosmosView!
    @IBOutlet weak var lblBooking: UILabel!
    @IBOutlet weak var lblTotalRating: UILabel!
    @IBOutlet weak var lblLeaveComment: UILabel!
    @IBOutlet weak var txtComment: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet var lblBedsideManner: UILabel!
    @IBOutlet var vwRateBedsideManner: CosmosView!
    
    var showNotificationBadge = false
    var selectedIndex = 0
    var notificationCount = 0
    var totalScore = 0.0
    var punctualityRating = 0.0
    var commRating = 0.0
    var treatmentGuidenceRating = 0.0
    var satisfactionRating = 0.0
    var behaviourRating = 0.0
    
    var dashboardData = DashboardData()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            
        add(asChildViewController: homeVC)
        
        customization()
        lblTotalRating.text = "Total Score: \(totalScore/5)"
        
        vwOverlay.alpha = 0
        vwRateVisit.alpha = 0
        
        if isUserLoggedIn(){
            getDashboardData()
        }
//        let numbers = [0]
//        let _ = numbers[1]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tabbar.invalidateIntrinsicContentSize()
        vwRateVisit.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
    }
    
    func customization(){
        tabbar.selectedItem = tabbar.items?[0]
        tabbar.delegate = self
        
        vwRatingMain.settings.fillMode = .precise

        
        vwRateWaitTime.didFinishTouchingCosmos = { [self] wait in
            
            updateRating(for: wait, with: &punctualityRating, label: lblTotalRating, totalRatingView: vwRateWaitTime)
        }
        vwRateCommunication.didFinishTouchingCosmos = { [self] comm in
            
            updateRating(for: comm, with: &commRating, label: lblTotalRating, totalRatingView: vwRateCommunication)
        }
        vwRateCleanliness.didFinishTouchingCosmos = { [self] clean in
            
            updateRating(for: clean, with: &treatmentGuidenceRating, label: lblTotalRating, totalRatingView: vwRateCleanliness)
        }
        vwRateBooking.didFinishTouchingCosmos = { [self] booking in
            
            updateRating(for: booking, with: &satisfactionRating, label: lblTotalRating, totalRatingView: vwRateBooking)
        }
        vwRateBedsideManner.didFinishTouchingCosmos = { [self] bedsideManner in
            
            updateRating(for: bedsideManner, with: &behaviourRating, label: lblTotalRating, totalRatingView: vwRateBedsideManner)
        }
      
    }
    
    func getDashboardData(){
        showLoadingView("")
        GetDashboardDataService().getData(completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = response as? DashboardDataResponseModel
                {
                    dashboardData = data.data
                    if (!dashboardData.appointmentInfo.isReview && dashboardData.appointmentInfo.id != -1){
                        setScreenData()
                    }else{
                        vwOverlay.alpha = 0
                        vwRateVisit.alpha = 0
                    }
                    
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    func setScreenData(){
        vwOverlay.alpha = 0.3
        vwRateVisit.alpha = 1
        let imageURL = Constants.URLs.imagePath + dashboardData.appointmentInfo.providerImage
        imgDoc.loadImage(from: imageURL)
        lblDocName.text = dashboardData.appointmentInfo.providerName
        lblDocSpeciality.text = dashboardData.appointmentInfo.arrSpceialitoes.map { $0.name }.joined(separator: ", ")
    }
    
    func selectTab(index: Int) {
        guard let items = tabbar.items, index < items.count else { return }
        tabbar.selectedItem = items[index]
        tabBar(tabbar, didSelect: items[index])
    }
    func updateRating(for rating: Double, with oldRating: inout Double, label: UILabel, totalRatingView: CosmosView) {
        totalScore -= oldRating
        totalScore += rating
        oldRating = rating
        lblTotalRating.text = "Total Score: \(totalScore/5)"
        vwRatingMain.rating = totalScore/5
    }
    
    func submitReview(){
        
        let param: [String: Any] = [
            "provider_id": dashboardData.appointmentInfo.providerID,
            "appointment_id":dashboardData.appointmentInfo.id,
            "punctuality_rating":punctualityRating,
            "communication_rating":commRating,
            "behavior_rating":behaviourRating,
            "treatment_guidance_rating":treatmentGuidenceRating,
            "satisfaction_rating":satisfactionRating,
            "review":txtComment.text!,
//            "rating":vwRatingMain.rating,
        ]
        
        let endPoint =  Constants.URLs.saveAppointmentReview
        
        showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:endPoint,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if let data = success as? GeneralResponseModel
                {
                    self.showAlertViewWithCompletion(message: data.message) { [weak self] in
                        self?.vwOverlay.alpha = 0
                        self?.vwRateVisit.alpha = 0
                    }
                }
            }
        }) { (faliure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: faliure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
        
    }
    
    @IBAction func btnCloseRatingAction(_ sender: Any) {
        vwOverlay.alpha = 0
        vwRateVisit.alpha = 0
    }
    @IBAction func btnSubmitAction(_ sender: Any) {
        submitReview()
    }
    public func add(asChildViewController viewController: UIViewController) {
        //if the vc is already stacked, go to that one! - lousy but crash free until the navigation logic is shared
        var vcExists = false
        var firstVcAfter = true
        
        for vc in self.children {
            if vcExists {
                if firstVcAfter {
                    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                        //            viewController.view.frame = newFrame
                        vc.view.alpha = 0.0
                    }, completion: { (finished: Bool) -> Void in
                        vc.view.removeFromSuperview()
                        vc.removeFromParent()
                    })
                    
                    firstVcAfter = false
                } else {
                    vc.view.removeFromSuperview()
                    vc.removeFromParent()
                }
            }
            
            if (viewController.classForCoder == vc.classForCoder) {
                vcExists = true
                
            }
            
        }
        
        // and then well push the new one, not the old one!
        // Add Child View Controller
        
        if !vcExists {
            addChild(viewController)
            
            // Add Child View as Subview
            vwContainer.addSubview(viewController.view)
            
            // Configure Child View
            viewController.view.frame = vwContainer.bounds
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            
            viewController.view.alpha = 0.0
            viewController.beginAppearanceTransition(true, animated: true)
        }
        
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            //            var newFrame = self.containerView.bounds
            //            viewController.view.frame = newFrame
            viewController.view.alpha = 1.0
        }, completion: { (finished: Bool) -> Void in
            viewController.endAppearanceTransition()
            // Notify Child View Controller
            viewController.didMove(toParent: self)
        })
        
    }
    public func remove(asChildViewController viewController: UIViewController) {
       
        viewController.view.alpha = 1.0
        viewController.beginAppearanceTransition(true, animated: true)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            //            viewController.view.frame = newFrame
            viewController.view.alpha = 0.0
            
        }, completion: { (finished: Bool) -> Void in
            viewController.endAppearanceTransition()
            // Notify Child View Controller
            viewController.willMove(toParent: nil)
            
            // Remove Child View From Superview
            viewController.view.removeFromSuperview()
            
            // Notify Child View Controller
            viewController.removeFromParent()
            
          
        })
    }
    public func removeWithoutAnimation(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
  
    }
}

extension DashboardVC: UITabBarDelegate{
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

         if item.tag == 0{
           
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            add(asChildViewController: controller)
        }
        else if item.tag == 1{
            let controller = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "AppoinmentVC") as! AppoinmentVC
            add(asChildViewController: controller)
        }
        else if item.tag == 2{
            let controller = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "DoctorVC") as! DoctorVC
            add(asChildViewController: controller)
        }
        else if item.tag == 3{
            let controller = getHealthCheckVC()
            add(asChildViewController: controller)
        }
        else if item.tag == 4{
            let controller = UIStoryboard.account.instantiateViewController(withIdentifier: "MyAccountVC") as! MyAccountVC
            add(asChildViewController: controller)
        }
    }
    
    
}
