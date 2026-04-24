//
//  MemberDataModel.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 16/10/2025.
//


struct WellnessGuideResponseModel{
    var response = GeneralResponseModel()
    var arrGuide = [WellnessGuideModel]()
}

struct WellnessGuideModel{
    var id = -1
    var name = ""
    var isDefault = false
    var description = ""
    var iconUrl = ""
    var lastVisitDate = ""
   
}


struct ExaminationResponseModel{
    var response = GeneralResponseModel()
    var arrExamination = [WellnessGuideModel]()
    var fututeFrequecy = [DropDownModel]()
    var remindeDaysrOption = [DropDownModel]()
    var reminderDays = [String]()
}


