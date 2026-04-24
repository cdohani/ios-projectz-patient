//
//  UserDataModel.swift
//  DocHyve
//
//  Created by MacBook Pro on 05/10/2023.
//

import Foundation

struct RegisterReponseModel{
    var userID = -1
    var signupStep = -1
    var response = GeneralResponseModel()
}
struct GeneralResponseModel{
    var status = -1
    var message = ""
    var authToken = ""
}
