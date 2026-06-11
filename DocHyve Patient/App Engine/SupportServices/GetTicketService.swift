//
//  SupportCategoriesService.swift
//  DocHyve
//
//  Created by MacBook Pro on 11/03/2025.
//


import Foundation

class GetTicketService: GenericService, @unchecked Sendable {
    
    func getData(completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        let queryItems: [URLQueryItem] = []


        var urlComponents = URLComponents(string: Constants.URLs.getTickets)
        urlComponents?.queryItems = queryItems
        let endPoint = urlComponents?.url?.absoluteString ?? ""
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

extension GetTicketService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> TicketResponseModel{
        
       var data = TicketResponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.responseData.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.responseData.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    if let ticketDic = dataDic["tickets"] as? [[String: Any]] {
                        var list = TicketDataModel()
                        for item in ticketDic {
                            list = TicketDataModel()
                            
                            if let val = item["id"] as? Int {
                                list.id = val
                            }
                            if let val = item["user_id"] as? Int {
                                list.userID = val
                            }
                            if let val = item["category_id"] as? Int {
                                list.categoryID = val
                            }
                            if let val = item["sub_category_id"] as? Int {
                                list.subCategoryID = val
                            }
                            if let val = item["inquiry_subject"] as? String {
                                list.subject = val
                            }
                            if let val = item["description"] as? String {
                                list.description = val
                            }
                            if let val = item["name"] as? String {
                                list.name = val
                            }
                            if let val = item["email"] as? String {
                                list.email = val
                            }
                            if let val = item["have_account"] as? Int {
                                list.haveAccount = val
                            }
                            if let val = item["username"] as? String {
                                list.userName = val
                            }
                            if let val = item["status"] as? String {
                                list.status = val
                            }
                            if let val = item["last_activity"] as? String {
                                list.lastActivity = val
                            }
                            if let val = item["created_at"] as? String {
                                list.createdAt = val
                            }
                            if let val = item["updated_at"] as? String {
                                list.updatedAt = val
                            }
                            if let attachments = item["attachments"] as? [[String: Any]] {
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
                            }
                            data.arrTickets.append(list)
                        }
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
