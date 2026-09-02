//
//  GenderModelResponse.swift
//  DocHyve
//
//  Created by MacBook Pro on 26/02/2025.
//

import Foundation


struct DashboardDataResponseModel{
    var responseData = GeneralResponseModel()
    var data = DashboardData()
}
struct DashboardData{
    var userInfo = UserDashboardDataModel()
    var notificationCount = -1
    var appointmentInfo = ReviewInfoDashboardModel()
    var bookingBlock = BookingBlockModel()
    
    var isAppointmentBlocked: Bool {
        bookingBlock.isBlocked || (bookingBlock.consecutiveNoShows >= bookingBlock.threshold && bookingBlock.threshold > 0)
    }
}
struct UserDashboardDataModel{
    var firstName = ""
    var lastName = ""
    var gender = ""
    var age = -1
    var insurance = [String]()
    var arrInsurances = [DashboardInsuranceModel]()
    var singleInsurance = ""
    var singleInsuranceInfo = DashboardInsuranceModel()
    var isProfileUpdated = -1
}

struct DashboardInsuranceModel{
    var id = -1
    var name = ""
    var type = ""
    var isPrimary = false
    var plans = [DashboardInsurancePlanModel]()
}

struct DashboardInsurancePlanModel{
    var id = -1
    var name = ""
    var description = ""
    var detailDescription = ""
}

struct ReviewInfoDashboardModel{
    var id = -1
    var providerID = -1
    var providerName = ""
    var providerImage = ""
    var isReview = false
    var arrSpceialitoes = [DropDownModel]()
}

struct BookingBlockModel{
    var isBlocked = false
    var consecutiveNoShows = 0
    var threshold = 4
    var blockedAt = ""
    var reason = ""
    var unblockedAt = ""
}
