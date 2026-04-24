//
//  PaymentMethodModel.swift
//  DocHyve
//
//  Created by MacBook Pro on 26/03/2025.
//


struct AppointmentInfoDetailResponseModel{
    var responseData = GeneralResponseModel()
    var providerInfo = BookAppointmentProviderModel()
    var slotInfo = BookingSlotDetailInfo()
    var patientPhoneNo = ""
}

struct BookAppointmentProviderModel{
    var id = -1
    var fullName = ""
    var email = ""
    var phoneNo = ""
    var practiceName = ""
    var providerImage = ""
    var practiceRole = ""
    var bookingType = BookingTypeModel()
    var specialities = [DropDownModel]()
    
}
struct BookingTypeModel{
    var id = ""
    var name = ""
}
struct BookingSlotDetailInfo{
    var id = -1
    var providerID = -1
    var addressID = -1
    var scheduleID = -1
    var startTime = ""
    var endTime = ""
    var slotDate = ""
    var slotNumber = -1
    var utcStartTime = ""
    var utcEndTime = ""
    var address = ""
    var address2 = ""
    var city = ""
    var stateID = -1
    var zipCode = ""
    var isDefault = 0
}
