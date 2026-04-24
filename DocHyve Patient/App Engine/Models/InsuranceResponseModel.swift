//
//  InsuranceResponseModel.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/04/2025.
//


struct InsuranceReponseModel{
    var response = GeneralResponseModel()
    var arrInsurance = [InsuranceModel]()
}

struct InsuranceModel{
    var id = -1
    var name = ""
    var medicarePlan = -1
    var medicAidPlan = -1
    var commercialPlan = -1
    var exchangeMarketPlan = -1
    var federalCarePlan = -1
    var schipPlan = -1
    var workerCompensationPlan = -1
    var stateID = -1
}


struct InsurancePlanReponseModel{
    var response = GeneralResponseModel()
    var arrPlan = [InsurancePlanModel]()
}

struct InsurancePlanModel{
    var id = -1
    var insuranceID = -1
    var name = ""
    var description = ""
    var detailDescription = ""
}

struct UserInsuranceReponseModel{
    var response = GeneralResponseModel()
    var arrData = [UserInsuranceModel]()
}

struct UserInsuranceModel{
    var id = -1
    var memberID = -1
    var cardMembderID = ""
    var insuranceID = -1
    var insuranceName = ""
    var insuranceType = ""
    var isPrimary = false
    var planIds: [Int] = []
    var arrPlan = [InsurancePlanModel]()
}
