//
//  UserDataModel.swift
//  DocHyve
//
//  Created by MacBook Pro on 05/10/2023.
//

import Foundation

struct PopularSpecialityReponseModel{
    var response = GeneralResponseModel()
    var arrSpeciality = [SpecialityResponseModel]()
}

struct SpecialityResponseModel{
    var id = -1
    var name = ""
    var tagline = ""
    var icon = ""
    var iconUrl = ""
    var isPopular = -1
    var createdAt = ""
    var updatedAt = ""
}
