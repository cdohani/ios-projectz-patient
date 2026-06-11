//
//  SupportCategoryModel.swift
//  DocHyve
//
//  Created by MacBook Pro on 11/03/2025.
//


struct TicketResponseModel{
    var responseData = GeneralResponseModel()
    var arrTickets = [TicketDataModel]()
}
struct TicketDetailResponseModel{
    var responseData = GeneralResponseModel()
    var ticketData = TicketDataModel()
}


struct TicketDataModel{
    var id = -1
    var userID = -1
    var categoryID = -1
    var subCategoryID = -1
    var subject = ""
    var description = ""
    var name = ""
    var email = ""
    var haveAccount = -1
    var userName = ""
    var status = ""
    var lastActivity = ""
    var createdAt = ""
    var updatedAt = ""
    var arrAttachments = [TicketAttachmentsModel]()
    var categoryInfo = SpecialityDataModel()
    var subCategoryInfo = SpecialityDataModel()
}
struct TicketAttachmentsModel{
    var id = -1
    var supportTicketID = -1
    var filePath = ""
    var createdAt = ""
    var updatedAt = ""
    var arrAttachments = [SubCategoryDataModel]()
}


struct TicketMessageResponseModel{
    var responseData = GeneralResponseModel()
    var arrMessages = [TicketReplyModel]()
}
struct TicketReplyModel{
    var id = -1
    var message = ""
    var createdAt = ""
    var createdFormate = ""
    var createdDiff = ""
    var user = ReplyUserModel()
}
struct ReplyUserModel{
    var id = -1
    var name = ""
    var userType = ""
    var image = ""
}

struct SpecialityDataModel: Codable {
    var id = 0
    var name = ""
}
