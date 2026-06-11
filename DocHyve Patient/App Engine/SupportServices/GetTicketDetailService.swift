//
//  SupportCategoriesService.swift
//  DocHyve
//
//  Created by MacBook Pro on 11/03/2025.
//


import Foundation

class GetTicketDetialService: GenericService, @unchecked Sendable {
    
    func getData(ticketId:Int, completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        let endPoint = String(format: Constants.URLs.ticketDetail, ticketId)
        let request = createURLRequest(urlString: endPoint, requestType: .get, postData: jsonString,auth:true)
         
         let session = URLSession.shared
         let task = session.dataTask(with: request) { (data, urlResponse, error) in
             if (error != nil) {
                 //we got error from service
                 if let nsError = error as NSError? {
                     if (nsError.code == NSURLErrorTimedOut) {
                         failure(Constants.GenericStrings.requestTimedOut)
                     } else if (nsError.code == NSURLErrorCannotConnectToHost || nsError.code == NSURLErrorNetworkConnectionLost || nsError.code == NSURLErrorNotConnectedToInternet) {
                         failure(Constants.GenericStrings.internetNotFound)
                     } else {
                         failure(Constants.GenericStrings.somethingWentWrong)
                     }
                 } else {
                     failure(Constants.GenericStrings.somethingWentWrong)
                 }
                 
             } else {
                 
                 //chcek if json is valid and does not contain error key
                 let jsonString = String(data: data!, encoding:String.Encoding.utf8)
                 if(jsonString!.count == 0) {
                     //json is not valid
                     //show error message
                     failure(Constants.GenericStrings.somethingWentWrong)
                 } else {
                     var code = 0
                      if let httpResponse = urlResponse as? HTTPURLResponse {
                          print("statusCode: \(httpResponse.statusCode)")
                         code = httpResponse.statusCode
                         }
                      var errorMessages = self.checkIfErrorsExist(jsonString: jsonString ?? "",statusCode:code)
                      
                      if errorMessages.count == 0{
                          errorMessages = self.checkIfErrorsExist(jsonString: jsonString ?? "")
                      }
                     if errorMessages.count > 0 {
                         
                         //sending the first error only
                         failure(errorMessages[0])
                     } else {
                        let userData = self.parseUserInformationFromJsonString(jsonString: jsonString ?? "")
                         completion(userData)
                     }
                 }
             }
         }
         task.resume()
     }
}

extension GetTicketDetialService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> TicketDetailResponseModel{
        
       var data = TicketDetailResponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.responseData.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.responseData.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    if let ticketDic = dataDic["ticket"] as? [String: Any] {
                        var list = TicketDataModel()
                        if let val = ticketDic["id"] as? Int {
                            list.id = val
                        }
                        if let val = ticketDic["user_id"] as? Int {
                            list.userID = val
                        }
                        if let val = ticketDic["category_id"] as? Int {
                            list.categoryID = val
                        }
                        if let val = ticketDic["sub_category_id"] as? Int {
                            list.subCategoryID = val
                        }
                        if let val = ticketDic["inquiry_subject"] as? String {
                            list.subject = val
                        }
                        if let val = ticketDic["description"] as? String {
                            list.description = val
                        }
                        if let val = ticketDic["name"] as? String {
                            list.name = val
                        }
                        if let val = ticketDic["email"] as? String {
                            list.email = val
                        }
                        if let val = ticketDic["have_account"] as? Int {
                            list.haveAccount = val
                        }
                        if let val = ticketDic["username"] as? String {
                            list.userName = val
                        }
                        if let val = ticketDic["status"] as? String {
                            list.status = val
                        }
                        if let val = ticketDic["last_activity"] as? String {
                            list.lastActivity = val
                        }
                        if let val = ticketDic["created_at"] as? String {
                            list.createdAt = val
                        }
                        if let val = ticketDic["updated_at"] as? String {
                            list.updatedAt = val
                        }
                        if let attachments = ticketDic["attachments"] as? [[String: Any]] {
                            var attch = TicketAttachmentsModel()
                            for item in attachments {
                                attch = TicketAttachmentsModel()
                                
                                if let val = item["id"] as? Int {
                                    attch.id = val
                                }
                                if let val = item["support_ticket_id"] as? Int {
                                    attch.supportTicketID = val
                                }
                                if let val = item["file_path"] as? String {
                                    attch.filePath = val
                                }
                                if let val = item["created_at"] as? String {
                                    attch.createdAt = val
                                }
                                if let val = item["updated_at"] as? String {
                                    attch.updatedAt = val
                                }
                                list.arrAttachments.append(attch)
                            }
                            if let categoryData = ticketDic["category"] as? [String: Any] {
                                
                                if let val = categoryData["id"] as? Int {
                                    list.categoryInfo.id = val
                                }
                                if let val = categoryData["name"] as? String {
                                    list.categoryInfo.name  = val
                                }
                            }
                            if let categoryData = ticketDic["sub_category"] as? [String: Any] {
                                
                                if let val = categoryData["id"] as? Int {
                                    list.subCategoryInfo.id = val
                                }
                                if let val = categoryData["name"] as? String {
                                    list.subCategoryInfo.name  = val
                                }
                            }
                        }
                        data.ticketData = list
                    }
                }
                //SessionID
            } else {
                //an exception has occured
                return data
            }
        } catch  {
            
            //an exception has occured
            return data
        }
        return data
    }
}
