//
//  InsuranceResponseModel.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/04/2025.
//


struct StateReponseModel{
    var response = GeneralResponseModel()
    var arrState = [StateModel]()
}

struct StateModel{
    var id = -1
    var name = ""
    var abbrevation = ""
}
