//
//  SingleAppointmentDetailModel.swift
//  DocHyve Patient
//
//  Created by Adeel Ahmed on 11/3/25.
//


struct SingleAppointmentResponseModel{
    var response = GeneralResponseModel()
    var appointmentData = SingleAppointmentDetail()
}

struct SingleAppointmentDetail{
    var appointmentID = -1
    var showInOfficeButton = false
    var videoCallMeetingID = ""
    var providerInfo = ProviderInfoModel()
    var patientInfo = PatientInfoModel()
    var appointmentInfo = AppointmentInfoModel()
    var slotInfo = SlotInfoModel()
    var illnessInfo = DropDownModel()
    var insuranceInfo = InsuranceInfoModel()
    var officeInfo = OfficeInfoModel()
    var preparationGuideline = PreparationGuidelineModel()
    var cancelationInfo = CancelationDetailModel()
    var videoInfo = VideoInfoModel()
   
}

struct AppointmentInfoModel{
    var date = ""
    var time = ""
    var formattedDate = ""
    var formattedTime = ""
    var formattedDateTime = ""
    var reason = ""
    var status = ""
    var bookingType = ""
    var isNewPatient = -1
    var createdAt = ""
    var updatedAt = ""
}
struct SlotInfoModel{
    var id = -1
    var start_time = ""
    var end_time = ""
    var slotDate = ""
    var address_id = -1
    var slotAddress = LocationDataModel()
}

struct InsuranceInfoModel{
    var id = -1
    var name = ""
    var planType = ""
    var memberID = -1
    var policyNumber = ""
    var groupNumber = ""
    var expiryDate = ""
}
struct OfficeInfoModel{
    var address = ""
    var phone = ""
    var email = ""
    var website = ""
    var officeHour = ""
}

struct PreparationGuidelineModel{
    var insuranceSendToProvider = false
    var networkStatus = ""
    var guidelines = [String]()
}

struct CancelationDetailModel{
    var id = -1
    var reason = ""
    var type = ""
    var primaryOtherReason = ""
    var communicatedToProvider = false
    var foundCareOutsideNetwork = false
    var cancelBy = -1
    var cancelAt = ""
}

struct VideoInfoModel{
    var platform = ""
    var meetingID = ""
    var meetingPassword = ""
    var joinUrl = ""
    var hostUrl = ""
    var meetingCreatedAt = ""
    var isJoinable = false
}
