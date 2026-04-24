//
//  MoreGenderService.swift
//  DocHyve
//
//  Created by MacBook Pro on 26/02/2025.
//

import Foundation

class RecommendedDoctorService: GenericService, @unchecked Sendable {
    
    func getData(completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
    
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        let queryItems: [URLQueryItem] = []
        var urlComponents = URLComponents(string: Constants.URLs.recommendedDoctors)
        urlComponents?.queryItems = queryItems
        let endPoint = urlComponents?.url?.absoluteString ?? ""
        let request = createURLRequest(urlString: endPoint, requestType: .get, postData: jsonString,auth:false)
         
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

extension RecommendedDoctorService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> RecommendedDoctorReponseModel{
        
       var data = RecommendedDoctorReponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.response.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.response.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    if let visitDic = dataDic["providers"] as? [[String: Any]] {
                        var list = RecommendedDoctorModel()
                        for item in visitDic{
                            list = RecommendedDoctorModel()
                            if let val = item["provider_id"] as? Int {
                                list.id = val
                            }
                            if let val = item["avg_rating"] as? Double {
                                list.avgRating = val
                            }
                            if let val = item["total_reviews"] as? Int {
                                list.totalReviews = val
                            }
                            if let val = item["firstname"] as? String {
                                list.firstName = val
                            }
                            if let val = item["lastname"] as? String {
                                list.lastName = val
                            }
                            if let val = item["provider_image"] as? String {
                                list.providerImage = val
                            }
                            if let val = item["practice_name"] as? String {
                                list.practiceName = val
                            }
                            if let val = item["specialities"] as? String {
                                list.specialities = val
                            }
                            if let val = item["is_boosted"] as? Bool {
                                list.isBoosted = val
                            }
                            if let val = item["boost_payment_status"] as? String {
                                list.boostPaymentStatus = val
                            }
                            if let val = item["boost_status"] as? String {
                                list.boostStatus = val
                            }
                            data.arrDoctors.append(list)
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
