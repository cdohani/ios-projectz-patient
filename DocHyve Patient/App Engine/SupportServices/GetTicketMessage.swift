//
//  SupportCategoriesService.swift
//  DocHyve
//
//  Created by MacBook Pro on 11/03/2025.
//


import Foundation

class GetTicketMessageService: GenericService, @unchecked Sendable {
    
    func getData(ticketId:Int, completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        let endPoint = String(format: Constants.URLs.ticketMessageDetail, ticketId)
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

extension GetTicketMessageService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> TicketMessageResponseModel{
        
       var data = TicketMessageResponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.responseData.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.responseData.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    if let ticketDic = dataDic["replies"] as? [[String: Any]] {
                        var list = TicketReplyModel()
                        for item in ticketDic {
                            list = TicketReplyModel()
                            if let val = item["id"] as? Int {
                                list.id = val
                            }
                             if let val = item["message"] as? String {
                                 list.message = val
                             }
                             if let val = item["created_at"] as? String {
                                 list.createdAt = val
                             }
                             if let val = item["created_formatted"] as? String {
                                 list.createdFormate = val
                             }
                             if let val = item["created_diff"] as? String {
                                 list.createdDiff = val
                             }
                             if let userData = item["user"] as? [String: Any] {
                                 
                                 if let val = userData["id"] as? Int {
                                     list.user.id = val
                                 }
                                 if let val = userData["name"] as? String {
                                     list.user.name = val
                                 }
                                 if let val = userData["user_type"] as? String {
                                     list.user.userType = val
                                 }
                                 if let val = userData["image_url"] as? String {
                                     list.user.image = val
                                 }
                             }
                            data.arrMessages.append(list)
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
