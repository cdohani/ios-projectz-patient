//
//  GenderModelResponse.swift
//  DocHyve
//
//  Created by MacBook Pro on 26/02/2025.
//

import Foundation


struct GenderResponseModel{
    var responseData = GeneralResponseModel()
    var arrGender = [GenderInfo]()
}
struct GenderInfo{
    var id = 999
    var name = ""
    var description = ""
    var createdAt = ""
    var updatedAt = ""
}
struct SelectedGenderResponseModel{
    var responseData = GeneralResponseModel()
    var selectedGender = ""
}
