//
//  PaymentMethodModel.swift
//  DocHyve
//
//  Created by MacBook Pro on 26/03/2025.
//


struct SearchConditionResponseModel{
    var responseData = GeneralResponseModel()
    var arrCondition = [SearchConditionDataModel]()
    var arrDoctor = [SearchDoctorDataModel]()
}

struct SearchConditionDataModel{
    var id  = -1
    var name = ""
    var type = ""
}

struct SearchDoctorDataModel{
    var id  = -1
    var name = ""
    var email = ""
    var practiceRole = ""
    var providerImage = ""
    var arrSpeciality = [DropDownModel]()
    var state = ""
    var type = ""
}

