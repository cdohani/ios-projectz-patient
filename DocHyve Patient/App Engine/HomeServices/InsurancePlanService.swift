//
//  MoreGenderService.swift
//  DocHyve
//
//  Created by MacBook Pro on 26/02/2025.
//

import Foundation

class InsuracePlanService: GenericService, @unchecked Sendable {
    
    func getData(insuranceID : Int,completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
    
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        let queryItems: [URLQueryItem] = []

        var endPoint = String(format: Constants.URLs.getInsurancePlan, insuranceID)
        var urlComponents = URLComponents(string: endPoint)
        urlComponents?.queryItems = queryItems
        endPoint = urlComponents?.url?.absoluteString ?? ""
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

extension InsuracePlanService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> InsurancePlanReponseModel{
        
       var data = InsurancePlanReponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.response.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.response.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    if let visitDic = dataDic["plans"] as? [[String: Any]] {
                        var list = InsurancePlanModel()
                        for item in visitDic{
                            list = InsurancePlanModel()
                            
                            if let val = item["id"] as? Int {
                                list.id = val
                            }
                            if let val = item["insurance_id"] as? Int {
                                list.insuranceID = val
                            }
                            if let val = item["name"] as? String {
                                list.name = val
                            }
                            if let planDesc = item["insurance_plan_details"] as? [String: Any] {
                                if let val = planDesc["description"] as? String {
                                    list.description = val
                                }
                                if let val = planDesc["detail_description"] as? String {
                                    list.detailDescription = val
                                }
                            }
                            data.arrPlan.append(list)
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
