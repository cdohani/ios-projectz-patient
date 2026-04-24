//
//  UserDataModel.swift
//  DocHyve
//
//  Created by MacBook Pro on 05/10/2023.
//

import Foundation

struct RecommendedDoctorReponseModel{
    var response = GeneralResponseModel()
    var arrDoctors = [RecommendedDoctorModel]()
}

struct RecommendedDoctorModel{
    var id = -1
    var avgRating = 0.0
    var totalReviews = -1
    var firstName = ""
    var lastName = ""
    var providerImage = ""
    var practiceName = ""
    var specialities = ""
    var isBoosted = false
    var boostPaymentStatus = ""
    var boostStatus = ""
}
