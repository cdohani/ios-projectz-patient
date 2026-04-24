//
//  MemberDataModel.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 16/10/2025.
//


struct MemberReponseModel{
    var response = GeneralResponseModel()
    var arrMembers = [MemberDetailModel]()
}

struct MemberDetailModel{
    var id = -1
    var patientID = -1
    var firstName = ""
    var lastName = ""
    var relationship = ""
    var userImage = ""
    var primaryInsuranceID = -1
    var primaryMemberID = ""
    var secondaryInsuranceID = -1
    var secondaryMemberID = ""
    var createdAT = ""
    var updatedAT = ""
    
    var primaryInsuranceInfo = InsuranceDataModel()
    var secondaryInsuranceInfo = InsuranceDataModel()
   
  
}
