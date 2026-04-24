//
//  MemberDataModel.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 16/10/2025.
//


struct FavouriteProviderReponseModel{
    var response = GeneralResponseModel()
    var arrFavouriteProvider = [FavouriteProviderModel]()
}

struct FavouriteProviderModel{
    var id = -1
    var providerID = -1
    var fullName = ""
    var providerSpeciality = [String]()
    var providerImage = ""
    var phoneNo = ""
    var appointmentCount = 0
    var rating = 0.0
}
