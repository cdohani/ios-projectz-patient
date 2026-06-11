//
//  SupportCategoriesService.swift
//  DocHyve
//
//  Created by MacBook Pro on 11/03/2025.
//


import Foundation

class GetCategoryFaqService: GenericService, @unchecked Sendable {
    
    func getData(categoryID: Int,completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        //let queryItems: [URLQueryItem] = []
        let endPoint = String(format: Constants.URLs.getCategoryFaqs,categoryID)
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

extension GetCategoryFaqService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> FAQResponseModel{
        
       var data = FAQResponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.responseData.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.responseData.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    if let locationDic = dataDic["faqs"] as? [[String: Any]] {
                        var list = CategoryFaqDataModel()
                        for item in locationDic {
                            list = CategoryFaqDataModel()
                            
                            if let val = item["id"] as? Int {
                                list.id = val
                            }
                            if let val = item["subcategory_id"] as? Int {
                                list.subCategoryID = val
                            }
                            if let val = item["question"] as? String {
                                list.question = val
                            }
                            if let val = item["answer"] as? String {
                                list.answer = val
                            }
                            if let val = item["created_at"] as? String {
                                list.createdAt = val
                            }
                            if let val = item["updated_at"] as? String {
                                list.updatedAt = val
                            }
                            
                            data.arrFaq.append(list)
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
