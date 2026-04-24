//
//  LocationDataModel.swift
//  DocHyve
//
//  Created by MacBook Pro on 06/03/2025.
//

import Foundation


struct LocationResponseModel{
    var responseData = GeneralResponseModel()
    var arrLocations = [LocationDataModel]()
}

struct LocationDataModel{
    var id = -1
    var address1 = ""
    var address2 = ""
    var city = ""
    var zipCode = ""
    var stateID = -1
    var stateName = ""
    var isDefault = -1
    var lat = ""
    var long = ""
    var createdAt = ""
    var updatedAt = ""
}

struct AvailableSlotsResponseModel{
    var responseData = GeneralResponseModel()
    var selectedDate = ""
    var arrSlots = [Slots]()
}

struct GoogleLocationModel{
    var placeName = ""
    var placeAddress = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
}
