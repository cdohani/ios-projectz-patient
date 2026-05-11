//
//  Enums.swift
//  DocHyve
//
//  Created by MacBook Pro on 31/12/2024.
//

import Foundation
import UIKit

enum UserProfileStatus: String {
    case pending = "pending"
    case inProcess = "InProcess"
    case verified = "Verified"
    case updateProfile = "UpdateProfile"
    case needAttention = "NeedAttention"

    // Static method to get the color for a given status
    static func getColor(for status: String) -> UIColor {
        switch status {
        case UserProfileStatus.pending.rawValue:
            return UIColor.orange
        case UserProfileStatus.inProcess.rawValue:
            return UIColor.blue
        case UserProfileStatus.verified.rawValue:
            return UIColor.green
        case UserProfileStatus.updateProfile.rawValue:
            return UIColor.red
        case UserProfileStatus.needAttention.rawValue:
            return UIColor.red
        default:
            return UIColor.black // Default color if the status is unknown
        }
    }
}

enum AppointmentStatus: String,CaseIterable {
    case pending = "pending"
    case confirmed = "confirmed"
    case cancelled = "cancelled"
    case completed = "completed"
    case scheduled = "scheduled"
    case noShow = "no show"
    
    static func getLightColor(for status: String) -> UIColor {
        switch status {
        case AppointmentStatus.pending.rawValue:
            return UIColor(named: "customBlueLight") ?? UIColor.red
        case AppointmentStatus.confirmed.rawValue:
            return UIColor(named: "customYellowLight") ?? UIColor.blue
        case AppointmentStatus.completed.rawValue:
            return UIColor(named: "customGreenLight") ?? UIColor.red
        case AppointmentStatus.cancelled.rawValue:
            return UIColor(named: "customRedLight") ?? UIColor.red
        case AppointmentStatus.scheduled.rawValue:
            return  UIColor(named: "customYellowLight") ?? UIColor.green
        case AppointmentStatus.noShow.rawValue:
            return  UIColor(named: "customRedLight") ?? UIColor.red
        default:
            return UIColor(named: "customBlueLight") ?? UIColor.blue // Default color if the status is unknown
        }
    }
    
    static func getDarkColor(for status: String) -> UIColor {
        switch status {
        case AppointmentStatus.pending.rawValue:
            return UIColor(named: "customBlueColor") ?? UIColor.red
        case AppointmentStatus.confirmed.rawValue:
            return UIColor(named: "customYellowDark") ?? UIColor.blue
        case AppointmentStatus.completed.rawValue:
            return UIColor(named: "customGreenColor") ?? UIColor.red
        case AppointmentStatus.cancelled.rawValue:
            return UIColor(named: "customRed") ?? UIColor.red
        case AppointmentStatus.scheduled.rawValue:
            return  UIColor(named: "customYellowDark") ?? UIColor.green
        case AppointmentStatus.noShow.rawValue:
            return  UIColor(named: "customRed") ?? UIColor.red
        default:
            return UIColor.black // Default color if the status is unknown
        }
    }
}

enum TicketStatus: String,CaseIterable {
    case open = "Open"
    case resolved = "Resolved"
    case closed = "Closed"
    case inProcess = "In-Process"
    
    static func getLightColor(for status: String) -> UIColor {
        switch status {
        case TicketStatus.open.rawValue:
            return UIColor(named: "customGreenLight") ?? UIColor.green
        case TicketStatus.resolved.rawValue:
            return UIColor(named: "customBlueLight") ?? UIColor.blue
        case TicketStatus.closed.rawValue:
            return UIColor(named: "customRedLight") ?? UIColor.red
        case TicketStatus.inProcess.rawValue:
            return  UIColor(named: "customOrangeLight") ?? UIColor.green
        default:
            return UIColor.black // Default color if the status is unknown
        }
    }
    
    static func getDarkColor(for status: String) -> UIColor {
        switch status {
        case TicketStatus.open.rawValue:
            return UIColor(named: "customGreenColor") ?? UIColor.red
        case TicketStatus.resolved.rawValue:
            return UIColor(named: "customBlue") ?? UIColor.blue
        case TicketStatus.closed.rawValue:
            return UIColor(named: "customRedColor") ?? UIColor.red
        case TicketStatus.inProcess.rawValue:
            return UIColor(named: "customOrange") ?? UIColor.red
        default:
            return UIColor.black // Default color if the status is unknown
        }
    }
}

enum CardBrand: String, CaseIterable {
    case visa = "visa"
    case mastercard = "mastercard"
    case amex = "amex"
    case discover = "discover"
    case jcb = "jcb"
    case dinersClub = "diners_club"
    case unionPay = "unionpay"

    static func getCardImage(for brand: String) -> UIImage? {
        switch brand.lowercased() {
        case CardBrand.visa.rawValue:
            return UIImage(named: "pay3")
        case CardBrand.mastercard.rawValue:
            return UIImage(named: "pay2")
        case CardBrand.amex.rawValue:
            return UIImage(named: "pay1")
        case CardBrand.discover.rawValue:
            return UIImage(named: "pay4")
        case CardBrand.jcb.rawValue:
            return UIImage(named: "jcbCardImage")
        case CardBrand.dinersClub.rawValue:
            return UIImage(named: "dinersClubCardImage")
        case CardBrand.unionPay.rawValue:
            return UIImage(named: "unionPayCardImage")
        default:
            return UIImage(named: "pay3") // Default image for unknown brands
        }
    }
}

enum CredentialEnrollmentMode: Int {
    case enrollment = 1
    case establish = 2
    case reEnrollment = 3
    case disEnrollment = 4
    case validation = 5
    case licensingSignup = 6
    case customRequest = 7
    case exclusions = 8
    case EDI = 9
    case EFTDeposit = 10
}


enum MedicalCondition {
    case surgicalHistory
    case allergyHistory
    case familyHistory
    case socialHistory
    case preference

    var endpoint: String {
        switch self {
        case .surgicalHistory:
            return Constants.URLs.getSurgicalHistory
        case .allergyHistory:
            return Constants.URLs.getAllergyHistory
        case .familyHistory:
            return Constants.URLs.getFamilyHistory
        case .socialHistory:
            return Constants.URLs.getSocialHistory
        case .preference:
            return Constants.URLs.getPreference
        }
    }
    
    var storeEndpoint: String {
        switch self {
        case .surgicalHistory:
            return Constants.URLs.saveSurgicalHistory
        case .allergyHistory:
            return Constants.URLs.saveAllergyHistory
        case .familyHistory:
            return Constants.URLs.saveFamilyHistory
        case .socialHistory:
            return Constants.URLs.saveSocialHistory
        case .preference:
            return Constants.URLs.savePreference
        }
        
        
    }
    
    var storeEndpointKey: String {
        switch self {
        case .surgicalHistory:
            return "surgical_history_ids"
        case .allergyHistory:
            return "allergies_ids"
        case .familyHistory:
            return "family_history_ids"
        case .socialHistory:
            return "social_history_ids"
        case .preference:
            return "preferences"
        }
    }
    
    var heading: String {
          switch self {
          case .surgicalHistory:
              return "Surgeries"
          case .allergyHistory:
              return "Allergies"
          case .familyHistory:
              return "Family History"
          case .socialHistory:
              return "Social History"
          case .preference:
              return "Preference"
          }
      }
    
    var descHeading: String {
          switch self {
          case .surgicalHistory:
              return "Select any surgeries you have had:"
          case .allergyHistory:
              return "Select any Allergies you have:"
          case .familyHistory:
              return "Indicate if any of these conditions exist in your family."
          case .socialHistory:
              return "Indicate if you do any of the following."
          case .preference:
              return "Preference"
          }
      }
}
