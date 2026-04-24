//
//  MemberDataModel.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 16/10/2025.
//


struct HealthCheckReponseModel{
    var response = GeneralResponseModel()
    var arrData = [HealthCheckModel]()
}

struct HealthCheckModel{
    var id = -1
    var name = ""
    var otherValue = ""
    var lastModifiedAt = ""
    var isSelected = false
}

struct MedicationReponseModel{
    var response = GeneralResponseModel()
    var arrData = [MedicineDetailModel]()
}
struct MedicineDetailModel{
    var id = -1
    var medication = ""
    var dosage = ""
    var duration = ""
    var frequency = ""
    var reason = ""
}

struct AllHealthRecordReponseModel{
    var response = GeneralResponseModel()
    var arrHealthRecord = [AllHealthRecordDetail]()
}
struct AllHealthRecordDetail{
    var name = ""
    var arrData = [HealthCheckModel]()
}

struct MedicationDropdownReponseModel{
    var response = GeneralResponseModel()
    var arrDosage = [String]()
    var arrUsage = [String]()
    var arrFrequency = [String]()
}

struct TwoFactorAuthReponseModel{
    var response = GeneralResponseModel()
    var phoneNum =  ""
    var isVerifiedPhone =  false
    var isTwoFactorAuthEnabled = false
}
