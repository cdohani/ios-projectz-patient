//
//  PaymentMethodModel.swift
//  DocHyve
//
//  Created by MacBook Pro on 26/03/2025.
//


struct NotificationResponseModel{
    var responseData = GeneralResponseModel()
    var arrNotification = [NotificationModel]()
    var paginationInfo = PaginationInfoModel()
}

struct NotificationModel{
    var id = -1
    var userID = -1
    var title = ""
    var message = ""
    var type = ""
    var isread = false
    var createdAt = ""
    var updatedAt = ""
}
