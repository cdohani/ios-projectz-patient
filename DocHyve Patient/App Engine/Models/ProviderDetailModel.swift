//
//  InsuranceResponseModel.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/04/2025.
//


struct ProviderDetailReponseModel{
    var response = GeneralResponseModel()
    var providerData = ProviderDetailModel()
}

struct ProviderDetailModel{
    var userId = -1
    var isFavourite = false
    var firstName = ""
    var lastName = ""
    var fullName = ""
    var email = ""
    var billingEmail = ""
    var userName = ""
    var status = ""
    var verificationStatus = ""
    var practiceName = ""
    var providerImage = ""
    var practiceRole = ""
    var gender = ""
    var npi = ""
    var primaryBusinessAddress = ""
    var hospitalSystem = ""
    var practiceSize = ""
    var bio = ""
    var aboutProvider = ""
    var educationAndTraning = ""
    var publications = ""
    var achivements = ""
    var boardCertificate = ""
    var isInNetwork = false
    var bookingType = DropDownModel()
    var specialities = [String]()
    var languages = [String]()
    var assignRole = [String]()
    var slotAddress = LocationDataModel()
    var arrAddresses = [LocationDataModel]()
    var arrInsurance = [InsuranceDataModel]()
    var higlights = HighlightsDataModel()
    var availableSlots = AvailableSlots()
    var review = RatingModel()
  
}
struct HighlightsDataModel{
    var newPatientAppointment = ""
    var fiveStarRating = ""
    var excellentWaitTime = ""
    var waitTimeFiveStar = ""
    var highlyRecommended = ""
    var recommendedFiveStar = ""
}
struct InsuranceDataModel{
    var id = -1
    var name = ""
    var icon = ""
}
struct RatingModel{
    var totalReview = -1
    var averageRating = 0.0
    var ratingDetail = [RatingDetail]()
    var recentReviews = [ReviewModel]()
}
struct RatingDetail{
    var count = -1
    var percentage = -1
}

struct ReviewModel{
    var id = -1
    var patientName = ""
    var patientState = ""
    var rating = 0.0
    var comment = ""
    var verifiedPatinet = true
    var createdAt = ""
    var daysAgo = ""
    var timeAgo = ""
}




struct ReviewReponseModel{
    var response = GeneralResponseModel()
    var reviewData = ReviewInfo()
}
struct ReviewInfo{
    var overallRating = 0.0
    var totalReviews = -1
    var arrRating = [RatingInfo]()
    var arrReview = [ReviewModel]()
}
struct RatingInfo{
    var name = ""
    var rating = 0.0
}

