//
//  UIStoryboard+ICT.swift
//  ICT-Dev
//
//  Created by Jawad Ali on 27/12/2019.
//  Copyright © 2019 Jawad Ali. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showToast(message: String, controller: UIViewController) {
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 25;
        toastContainer.clipsToBounds  =  true
        
        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font.withSize(12.0)
        toastLabel.text = message
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        
        toastContainer.addSubview(toastLabel)
        controller.view.addSubview(toastContainer)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
        let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
        let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
        let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
        toastContainer.addConstraints([a1, a2, a3, a4])
        
        let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: controller.view, attribute: .leading, multiplier: 1, constant: 65)
        let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: controller.view, attribute: .trailing, multiplier: 1, constant: -65)
        let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: controller.view, attribute: .bottom, multiplier: 1, constant: -75)
        controller.view.addConstraints([c1, c2, c3])
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 3.0, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: Login/Signup VC
   
    class func getSplashVC() -> SplashVC {
        let vc = UIStoryboard.home.instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
        return vc
    }
    class func getLoginVC() -> LoginVC {
        let vc = UIStoryboard.home.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        return vc
    }
    func getForgetPasswordVC() -> ForgetPasswordVC {
        let vc = UIStoryboard.home.instantiateViewController(withIdentifier: "ForgetPasswordVC") as! ForgetPasswordVC
        return vc
    }
    
    func getResetPasswordVC() -> ResetPasswordVC {
        let vc = UIStoryboard.home.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
        return vc
    }
    
    func getRegisterVC() -> RegisterVC {
        let vc = UIStoryboard.home.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        return vc
    }
    func getCreateProfileVC() -> CreateProfileVC {
        let vc = UIStoryboard.home.instantiateViewController(withIdentifier: "CreateProfileVC") as! CreateProfileVC
        return vc
    }
    func getGenderMoreInfoVC() -> GenderMoreInfoVC {
        let vc = UIStoryboard.home.instantiateViewController(withIdentifier: "GenderMoreInfoVC") as! GenderMoreInfoVC
        return vc
    }
    class func getDashboardVC() -> DashboardVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
        return vc
    }
    func getVerifyEmailVC() -> VerifyEmailVC {
        let vc = UIStoryboard.home.instantiateViewController(withIdentifier: "VerifyEmailVC") as! VerifyEmailVC
        return vc
    }
    func getVerifyPhoneNoVC() -> VerifyPhoneNoVC {
        let vc = UIStoryboard.home.instantiateViewController(withIdentifier: "VerifyPhoneNoVC") as! VerifyPhoneNoVC
        return vc
    }
    func getReactivateEmailVC() -> ReactivateEmailVC {
        let vc = UIStoryboard.home.instantiateViewController(withIdentifier: "ReactivateEmailVC") as! ReactivateEmailVC
        return vc
    }
    func getSearchConditionVC() -> SearchConditionVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "SearchConditionVC") as! SearchConditionVC
        return vc
    }
    func getLocationSearchVC() -> LocationSearchVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "LocationSearchVC") as! LocationSearchVC
        return vc
    }
    func getCustomExaminationVC() -> CustomExaminationVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "CustomExaminationVC") as! CustomExaminationVC
        return vc
    }
    func getExaminationDateVC() -> ExaminationDateVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "ExaminationDateVC") as! ExaminationDateVC
        return vc
    }
    func getPopularSpecialitiesVC() -> PopularSpecialitiesVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "PopularSpecialitiesVC") as! PopularSpecialitiesVC
        return vc
    }
    func getReminderVC() -> ReminderVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "ReminderVC") as! ReminderVC
        return vc
    }
    func getFindDoctorVC() -> FindDoctorVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "FindDoctorVC") as! FindDoctorVC
        return vc
    }
    class  func getDoctorDetailVC() -> DoctorDetailVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "DoctorDetailVC") as! DoctorDetailVC
        return vc
    }
    func getDoctorRatingVC() -> DoctorRatingVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "DoctorRatingVC") as! DoctorRatingVC
        return vc
    }
    func getFilterDoctorVC() -> FilterDoctorVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "FilterDoctorVC") as! FilterDoctorVC
        return vc
    }
    func getDoctorAvailableSlotsVC() -> DoctorAvailableSlotsVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "DoctorAvailableSlotsVC") as! DoctorAvailableSlotsVC
        return vc
    }
    func getPastAppoinmentStatusVC() -> PastAppoinmentStatusVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "PastAppoinmentStatusVC") as! PastAppoinmentStatusVC
        return vc
    } 
    class func getApptDoctorDetailVC() -> ApptDoctorDetailVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "ApptDoctorDetailVC") as! ApptDoctorDetailVC
        return vc
    }
    
    class func getVideoApptDetailVC() -> VideoApptDetailVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "VideoApptDetailVC") as! VideoApptDetailVC
        return vc
    }
    
    class func getVideoCallVC() -> VideoCallVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "VideoCallVC") as! VideoCallVC
        return vc
    }
    
    func getNotificationVC() -> NotificationVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        return vc
    }
    
    func getReviewDoctorVC() -> ReviewDoctorVC {
        let vc = UIStoryboard.dashboard.instantiateViewController(withIdentifier: "ReviewDoctorVC") as! ReviewDoctorVC
        return vc
    }
   
    func getBookApptVC() -> BookApptVC {
        let vc = UIStoryboard.booking.instantiateViewController(withIdentifier: "BookApptVC") as! BookApptVC
        return vc
    }
    
    func getCancelAppointmentReasonVC() -> CancelAppointmentReasonVC {
        let vc = UIStoryboard.booking.instantiateViewController(withIdentifier: "CancelAppointmentReasonVC") as! CancelAppointmentReasonVC
        return vc
    }
    func getCancelAppointmentQuestionVC() -> CancelAppointmentQuestionVC {
        let vc = UIStoryboard.booking.instantiateViewController(withIdentifier: "CancelAppointmentQuestionVC") as! CancelAppointmentQuestionVC
        return vc
    }
    
    func getInsuranceVC() -> InsuranceVC {
        let vc = UIStoryboard.booking.instantiateViewController(withIdentifier: "InsuranceVC") as! InsuranceVC
        return vc
    }
    func getInsurancePlanVC() -> InsurancePlanVC {
        let vc = UIStoryboard.booking.instantiateViewController(withIdentifier: "InsurancePlanVC") as! InsurancePlanVC
        return vc
    }
  
    func getSurvyVC() -> SurvyVC {
        let vc = UIStoryboard.booking.instantiateViewController(withIdentifier: "SurvyVC") as! SurvyVC
        return vc
    }
    func getSettingVC() -> SettingVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        return vc
    }
    func getProfileVC() -> ProfileVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        return vc
    }
    func getPasswordSettingVC() -> PasswordSettingVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "PasswordSettingVC") as! PasswordSettingVC
        return vc
    }
    func getUpdatePasswordVC() -> UpdatePasswordVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "UpdatePasswordVC") as! UpdatePasswordVC
        return vc
    }
    func getSecurityVC() -> SecurityVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "SecurityVC") as! SecurityVC
        return vc
    }
    func getPhoneNoVC() -> PhoneNoVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "PhoneNoVC") as! PhoneNoVC
        return vc
    }
    func getPreferenceVC() -> PreferenceVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "PreferenceVC") as! PreferenceVC
        return vc
    }
    func getPermissionVC() -> PermissionVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "PermissionVC") as! PermissionVC
        return vc
    }
    func getContactUsVC() -> ContactUsVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
        return vc
    } 
    func getAddedMemberVC() -> AddedMemberVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "AddedMemberVC") as! AddedMemberVC
        return vc
    }
    func getAddNewMemberVC() -> AddNewMemberVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "AddNewMemberVC") as! AddNewMemberVC
        return vc
    }
    func getHealthCheckVC() -> HealthCheckVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "HealthCheckVC") as! HealthCheckVC
        return vc
    }
    func getMedicalHistoryVC() -> MedicalHistoryVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "MedicalHistoryVC") as! MedicalHistoryVC
        return vc
    }
    func getSurgicalHistoryVC() -> SurgicalHistoryVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "SurgicalHistoryVC") as! SurgicalHistoryVC
        return vc
    }
    func getAddedMedicationVC() -> AddedMedicationVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "AddedMedicationVC") as! AddedMedicationVC
        return vc
    }
    func getAddNewMedicationVC() -> AddNewMedicationVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "AddNewMedicationVC") as! AddNewMedicationVC
        return vc
    }
    func getAllHealthCheckVC() -> AllHealthCheckVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "AllHealthCheckVC") as! AllHealthCheckVC
        return vc
    }
    func getAddedInsurnaceVC() -> AddedInsurnaceVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "AddedInsurnaceVC") as! AddedInsurnaceVC
        return vc
    }
    func getAddNewInsuranceVC() -> AddNewInsuranceVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "AddNewInsuranceVC") as! AddNewInsuranceVC
        return vc
    }
    
    func getAccountDeactivateReasonVC() -> AccountDeactivateReasonVC {
        let vc = UIStoryboard.account.instantiateViewController(withIdentifier: "AccountDeactivateReasonVC") as! AccountDeactivateReasonVC
        return vc
    }
    
    
    public var isVisible: Bool {
        if isViewLoaded {
            return view.window != nil
        }
        return false
    }
    
    func isModal() -> Bool {
        if self.presentingViewController != nil {
            return true
        } else if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        } else if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
}
