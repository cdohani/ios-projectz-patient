//
//  SupportCategoryModel.swift
//  DocHyve
//
//  Created by MacBook Pro on 11/03/2025.
//


struct SupportCategoryResponseModel{
    var responseData = GeneralResponseModel()
    var arrCategory = [CategoryDataModel]()
}

struct CategoryDataModel{
    var id = -1
    var name = ""
    var createdAt = ""
    var updatedAt = ""
    var arrSubCategory = [SubCategoryDataModel]()
}

struct SubCategoryDataModel{
    var id = -1
    var name = ""
    var categoryID = -1
    var createdAt = ""
    var updatedAt = ""
}

struct FAQResponseModel{
    var responseData = GeneralResponseModel()
    var arrFaq = [CategoryFaqDataModel]()
}
struct CategoryFaqDataModel{
    var id = -1
    var subCategoryID = -1
    var question = ""
    var answer = ""
    var createdAt = ""
    var updatedAt = ""
}
