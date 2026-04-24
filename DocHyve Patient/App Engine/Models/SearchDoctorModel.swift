//
//  InsuranceResponseModel.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/04/2025.
//


struct SearchDoctorReponseModel{
    var response = GeneralResponseModel()
    var arrProvider = [SearchDoctorModel]()
    var paginationInfo = PaginationInfoModel()
}

struct SearchDoctorModel{
    var userId = -1
    var firstName = ""
    var lastName = ""
    var email = ""
    var status = ""
    var verificationStatus = ""
    var userType = ""
    var detailId = -1
    var practiceName = ""
    var providerImage = ""
    var practiceRole = ""
    var gender = ""
    var npi = ""
    var specialities = ""
    var languages = ""
    var assignedRoles = ""
    var addresses = ""
    var totalReviews = -1
    var avgRating = 0.0
    var inNetwork = false
    var bookingType = DropDownModel()
    var nextAvailableDates = [String]()
    var slotAddress = LocationDataModel()
    var arrAddresses = [LocationDataModel]()
    var availableSlots = AvailableSlots()
}

struct AvailableSlots{
    var date = ""
    var message = ""
    var slots = [Slots]()
}
struct Slots{
    var id = -1
    var time = ""
    var endTime = ""
    var isBooked = false
}

struct PaginationInfoModel{
    var currentPage = 0
    var totalPage = 0
    var totalRecord = 0
    var perPage =  0
    var hasMoreRecord = false
}


