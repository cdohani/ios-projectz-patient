//
//  BookNewAppointment.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 09/10/2025.
//


struct ProviderAppointmentReponseModel{
    var response = GeneralResponseModel()
    var providerData = ProviderAppointmentDetail()
}

struct ProviderAppointmentDetail{
    var id = -1
    var name = ""
    var practiceName = ""
    var providerSpeciality = [String]()
    var arrAppointment = [AppointmentDetail]()

}
struct AppointmentDetail{
    var id = -1
    var date = ""
    var time = ""
    var reason = ""
    var status = ""
    var notes = ""
    var bookingType = ""
    var isNewPatient = false
    var isReviewed = false
    var patientFirstName = ""
    var patientLastName = ""
    var illness = ""
    var insurance = ""
    var member = ""
    var createdAt = ""
    var updatedAt = ""
}

