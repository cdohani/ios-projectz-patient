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
    

}
struct UserDashboardDataModel{
    var firstName = ""
    var lastName = ""
    var gender = ""
    var age = -1
    var insurance = [String]()
    var singleInsurance = ""
    var isProfileUpdated = -1
}

struct ReviewInfoDashboardModel{
    var id = -1
    var providerID = -1
    var providerName = ""
    var providerImage = ""
    var isReview = false
    var arrSpceialitoes = [DropDownModel]()
}
