//
//  UserDataModel.swift
//  DocHyve
//
//  Created by MacBook Pro on 05/10/2023.
//

import Foundation
struct LoginResponseDataModel{
    
    var responseData = GeneralResponseModel()
    var userData = UserDataModel()
    var signupStep = -1
    var onBoardingState = OnBoardingDateModel()
}
struct UserDataModel{
    var id = -1
    var firstName = ""
    var lastName = ""
    var email = ""
    var emailVerifiedAt = ""
    var status = ""
    var phoneNo = ""
    var registrationStep = -1
    var isAdmin = -1
    var isParent = -1
    var signupStep = -1
    var userType = ""
    var deletedAt = ""
    var createdAt = ""
    var updatedAt = ""
}
struct OnBoardingDateModel{
    var onBoardingComplete = -1
    var mainStep = -1
    var subStep = -1
}


struct LoginInActiveResponseModel{
    
    var responseData = GeneralResponseModel()
    var userInfo = InactiveUserModel()
}

struct InactiveUserModel{
    var id = -1
    var status = ""
    var signup_step = -1
}
