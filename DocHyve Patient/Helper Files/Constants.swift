//
//  Constants.swift
//  Wasel Order
//
//  Created by TheRightSW on 05/05/2020.
//  Copyright © 2020 TheRightSW. All rights reserved.
//

import Foundation
import UIKit

typealias CompletionBlock = (_ result: Any?) -> Void
typealias FailureBlock = (_ errorString: String?) -> Void

struct Constants {
    
    struct ServiceConfiguration {
        #if DEBUG
        
        static let baseURL = "https://api.dochyve.com/api"
        #else
        static let baseURL = "https://api.dochyve.com/api"
        #endif
    }
    
    //MARK:- Generic Strings
    struct GenericStrings {
        
        //title
        static let alertTitle = "DocHyve"
        
        //buttons
        static let ok = "OK"
        
        static let yes = "Yes"
        
        static let no = "No"
        
        static let internetNotFound = "Please check your Internet connectivity."
        
        static let somethingWentWrong = "An error occurred while processing your request. Please try again in a little while"
        static let unAuthoriedRequest = "Unauthoried Request please login Again."
        
        static let requestTimedOut = "Your request has timed out."
        
        static let noItemInCart = "Please add atleat one item in cart to order."
        
        static let enterPhone = "Please enter your phone No."
        
        static let checkAggrement = "Please check Aggrement and privacy Policy."
        
        static let largeImage = "Image size exceed from server limit."
    }
    
    //MARK:- Loading View Strings
    struct LoadingViewStrings {
      static let loading = "Loading..."
    }
    struct TextFieldError {
        static let emptyString = "This field is required"
        static let passwordMismatch = "Password and Confirm password should match"
        static let invalidEmail = "Invalid email address"
        static let invalidPhone = "Invalid Phone number"
        static let invalidCnic = "Invalid CNIC number"
        static let onlyAlphabets = "Only Alphabets in name"
        static let passwordMinLength = "Password must be minimum 8 characters"
        static let passwordValidtion = "Password must contain atleast 8 characters, one letter, one number and one special character."
    }

    //MARK:- DateFormats
    struct DateFormats {
        
        static let smallDateFormat = "dd/MM/yyyy"
        
        static let reverseCompactDate = "yyyy-MM-dd"
        
        static let balanceTimerDateFormat = "yyyy-MM-dd HH:mm:ss.s"
        
        static let fullDateFormat = "dd-MM-yyyy HH:mm:ss"
        
        static let transactionDateFormat = "yyyy-MM-dd HH:mm:ss"
        
        static let dateWithCombinedLetters = "yyyyMMdd"
        
        static let dateWithSpacing = "yyyy MM dd"
        
        static let dateWithDayName = "EEEE, d MMM"
        
        static let onlyTime = "HH:mm:ss"
        
        static let dashSeperatedDayMonthYear = "dd-MM-yyy"
        
        static let onlyMonthAndDay = "MMM dd"
    }
    
    //MARK:- URLs
    struct URLs {
        static let imagePath = "https://api.dochyve.com/storage/"
        
        //MARK:- Registration
        static let login = "/login"
        static let sociallogin = "/auth/social-login"
        static let forgetPassword = "/password/send-code"
        static let resetPassword = "/password/reset-password"
        static let verifyCode = "/password/verify-code"
        static let registerStep1 = "/patient-signup/step-one"
        static let verifyPin = "/patient-signup/verify-code"
        static let allGenders = "/genders"
        static let selectedGenders = "/patient-signup/get-gender-info"
        static let saveSelectedGender = "/patient-signup/update-gender-info"
        static let registerProfile = "/patient-signup/step-three"
        static let addDeviceToken = "/device-tokens"
        static let sendSignVerificationCode = "/patient-signup/resend-verification-code"
      
        //MARK:- Dashboard
        static let getDashboardData = "/dashboard/data"
        static let popularSpecialities = "/specialities/list"
        static let recommendedDoctors = "/top-reviewed-providers"
        static let getInsurance = "/insurances"
        static let getInsurancePlan = "/insurances/%d/plans-with-details"
        
        static let getStates = "/states/list"
        static let searchDoctors = "/homepage/search-providers"
        static let getProviderAddress = "/front-providers/%d/addresses"
        static let getProviderDetail = "/provider_details/%d"
        static let getProviderAvailableSlot  = "/%d/available-slots"
        static let getAllReviews = "/providers/%d/reviews"
        static let getVisitReasons = "/visit-reasons/list"
        static let favouritUpdate = "/favorites/update"
        static let getAppointmnetDetail = "/providers/%d/slots/%d"
        static let getHeardAbout = "/patients/heard-from"
        static let saveHeardAbout = "/patients/store-heard-from"
        static let saveAppointmentReview = "/patients/store-feedback"
        static let searchCondition = "/autofill-search?q=%@"
        static let getIllness = "/illnesses/%d"
        
        //MARK:- BookAppoinment
        static let bookAppointment = "/appointments/book"
        
        //MARK:- CancelAppointment
        static let singleAppointmentDetail = "/patients/appointments/%d"
        static let cancelAppointmentReason = "/appointments/cancellation-reasons"
        static let saveCancelAppointment = "/appointments/%d/cancel"
        static let updateAppointmentSlot = "/appointments/%d/update-slot"
        static let bookfollowUp = "/appointments/book-followup"
        static let notifyDoctor = "/appointments/check-in"
        
        //MARK:- Account Setting
        static let saveUserInsurance = "/patient/insurances/attach"
        static let getUserInsurance = "/patient/insurances"
        static let deleteInsurance = "/patient/insurances/delete"
        static let addFamilyMember = "/family-members/add"
        static let getFamilyMembers = "/family-members"
        static let addMemberImage = "/family-members"
        static let deleteFamilyMembers = "/family-members/delete"
        static let editFamilyMembers = "/family-members/update"
        static let getUserProfile = "/patients/profile-info"
        static let saveUserProfile = "/patients/store-profile-info"
        static let updatePassword = "/set-new-password"
        static let deactivateAccount = "/patient/toggle-account-status"
        static let addNewPhoneNo = "/verify-phone-number"
        static let verifyPhoneNo = "/validation-phone-number-code"
        
        //MARK:- Appointment
        static let getFavouriteProvider = "/favorites/list"
        static let getBookedProvider = "/booked-providers"
        static let getProviderAppointment = "/provider/%d/appointments"
        static let getUserAppointment = "/patients/appointments"
        
        //MARK:- HealthCheck
        static let getHealthCheckHistory = "/patients/heath-care-history"
        static let getMedicalHistory = "/patients/medical-history"
        static let saveMedicalHistory = "/patients/store-medical-history"
        static let getSurgicalHistory = "/patients/surgical-history"
        static let saveSurgicalHistory = "/patients/store-surgical-history"
        static let getAllergyHistory = "/patients/allergy-history"
        static let saveAllergyHistory = "/patients/store-allergy-history"
        static let getFamilyHistory = "/patients/family-history"
        static let saveFamilyHistory = "/patients/store-family-history"
        static let getSocialHistory = "/patients/social-history"
        static let saveSocialHistory = "/patients/store-social-history"
        static let getMedicationHistory = "/patients/medication-history"
        static let getMedicationScreenData = "/patients/create-medication-history"
        static let saveMedicationHistory = "/patients/store-medication-history"
        static let updateMedicationHistory = "/patients/update-medication-history"
        static let deleteMedicationHistory = "/patients/delete-medication-history"
        static let allHealthHistory = "/patients/all-heath-care-history"
        
        static let getPreference = "/patients/preference"
        static let savePreference = "/patients/store-preference"
        static let getPremissionAutoComplete = "/patients/autocomplete-info"
        static let savePremissionAutoComplete = "/patients/store-autocomplete-info"
        static let getSecurity = "/security"
        static let sendPhoneVerificationCode = "/toggle-two-factor-auth"
        static let verifyTwoFactor = "/verify-two-factor-auth"
        
        
        //MARK:- WellnessGuide
        static let getWellnessGuide = "/patients/wellness-guide"
        static let getExaminationData = "/patients/create-wellness-guide"
        static let saveCustomExamination = "/patients/store-wellness-guide"
        static let deleteCustomExamination = "/patients/delete-wellness-guide"
        static let saveExaminationDate = "/patients/save-wellness-guide-date"
        
        //MARK: Notification calls
        static let getAllNotifications = "/notifications"
        static let getUnreadNotifications = "/notifications/get-unread"
        static let markAllReadNotification = "/notifications/read-all"
        static let markReadSingleNotification = "/notifications/%d/mark-read"
        static let deleteNotification = "/notifications/%d/delete"
    }
}
