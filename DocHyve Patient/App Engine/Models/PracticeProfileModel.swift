//
//  PracticeProfileModel.swift
//  DocHyve Patient
//

import Foundation

struct PracticeProfileResponseModel {
    var responseData = GeneralResponseModel()
    var data = PracticeProfileData()
}

struct PracticeProfileData {
    var practiceId = -1
    var practiceName = ""
    var practiceLogo = ""
    var ownerName = ""
    var about = ""
    var description = ""
    var officeLocations = [PracticeLocationModel]()
    var metrics = PracticeMetricsModel()
    var amenities = [PracticeAmenityModel]()
    var specialties = [String]()
    var providers = [PracticeProviderModel]()
    var contactInfo = PracticeContactInfoModel()
}

struct PracticeLocationModel {
    var id = -1
    var address = ""
    var address2 = ""
    var city = ""
    var stateName = ""
    var zipCode = ""
    var latitude = ""
    var longitude = ""
    var isDefault = 0
    var locationName = ""
}

struct PracticeMetricsModel {
    var totalPatients = 0
    var totalAppointments = 0
    var rating = 0.0
}

struct PracticeAmenityModel {
    var id = -1
    var name = ""
}

struct PracticeProviderModel {
    var providerId = -1
    var firstname = ""
    var lastname = ""
    var providerImage = ""
    var degree = ""
    var rating = 0.0
    var reviewCount = 0
    var appointmentsLast7Days = 0
    var nextAvailableDate = ""
    var speciality = [String]()
    var address: PracticeProviderAddressModel?
    var inNetwork = false
}

struct PracticeProviderAddressModel {
    var id = -1
    var address = ""
    var city = ""
    var stateName = ""
    var zipCode = ""
    var isDefault = 0
}

struct PracticeContactInfoModel {
    var phone = ""
    var email = ""
    var website = ""
    var workingHours = [PracticeWorkingHourModel]()
}

struct PracticeWorkingHourModel {
    var dayOfWeek = ""
    var timeFrom = ""
    var timeTo = ""
}
