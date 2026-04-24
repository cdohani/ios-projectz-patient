//
//  BookNewAppointment.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 09/10/2025.
//


struct UserAppointmentReponseModel{
    var response = GeneralResponseModel()
    var arrAppointment = [UserAppointmentDetail]()
    var paginationInfo = PaginationInfoModel()
}

struct UserAppointmentDetail{
    var appointmentID = -1
    var providerInfo = ProviderInfoModel()
    var patientID = -1
    var illness = DropDownModel()
    var date = ""
    var dateStatus = ""
    var time = ""
    var reason = ""
    var status = ""
    var notes = ""
    var bookingType = ""
    var isPendingReview = false
    var memberID = -1
    var patientInfo = PatientInfoModel()

}

struct ProviderInfoModel{
    var id = -1
    var firstName = ""
    var lastName = ""
    var practiceName = ""
    var providerImage = ""
    var specialities = [DropDownModel]()
    var specialization = ""
}

struct PatientInfoModel{
    var id = -1
    var firstName = ""
    var lastName = ""
    var email = ""
    var dateofBirth = ""
    var gender = ""
    var address = ""
    var contactNo = ""
    var profileImage = ""
}


