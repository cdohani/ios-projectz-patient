//
//  GenderModelResponse.swift
//  DocHyve
//
//  Created by MacBook Pro on 26/02/2025.
//

import Foundation


struct DropDownResponseModel{
    var responseData = GeneralResponseModel()
    var arrData = [DropDownModel]()
}
struct DropDownModel{
    var id = -1
    var name = ""
}

