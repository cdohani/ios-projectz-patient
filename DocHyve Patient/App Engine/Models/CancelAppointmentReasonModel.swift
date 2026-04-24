//
//  MemberDataModel.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 16/10/2025.
//


struct CancelAppointmentResponseModel{
    var response = GeneralResponseModel()
    var arrReason = [CancelAppointmentReason]()
}

struct CancelAppointmentReason{
    var id = -1
    var reason = ""
    var type = ""
    var sortOrder = -1
    var isActive = false
   
}


