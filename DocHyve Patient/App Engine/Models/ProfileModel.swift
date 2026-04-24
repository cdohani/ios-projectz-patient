//
//  MemberDataModel.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 16/10/2025.
//


struct UserProfileReponseModel{
    var response = GeneralResponseModel()
    var userData = UserProfileModel()
}

struct UserProfileModel{
    var id = -1
    var firstName = ""
    var lastName = ""
    var email = ""
    var dateOfBirth = ""
    var extraGender = [DropDownModel]()
    var gender = ""
    var contactNumber = ""
    var profileImage = ""
    var nicImage = ""
    var streetNo = ""
    var appartment = ""
    var city = ""
    var zipCode = ""
    var address = ""
    var state = DropDownModel()
}


struct SettingItem {
    let icon: String
    let title: String
    let action: () -> Void
}
