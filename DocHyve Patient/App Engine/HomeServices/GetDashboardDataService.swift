//
//  GetProviderLocationService.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/09/2025.
//


import Foundation

class GetDashboardDataService: GenericService, @unchecked Sendable {
    
    func getData(completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        let queryItems: [URLQueryItem] = []
        var endPoint = String(format: Constants.URLs.getDashboardData)
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

extension GetDashboardDataService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> DashboardDataResponseModel{
        
       var data = DashboardDataResponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.responseData.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.responseData.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    
                    
                    if let notificationInfo = dataDic["notifications"] as? [String: Any] {
                        
                        if let val = notificationInfo["unread_count"] as? Int{
                            data.data.notificationCount = val
                        }
                    }
                    if let userInfo = dataDic["user"] as? [String: Any] {
                        
                        if let val = userInfo["first_name"] as? String {
                            data.data.userInfo.firstName = val
                        }
                        if let val = userInfo["last_name"] as? String {
                            data.data.userInfo.lastName = val
                        }
                        if let val = userInfo["gender"] as? String {
                            data.data.userInfo.gender = val
                        }
                        if let val = userInfo["age"] as? Int {
                            data.data.userInfo.age = val
                        }
                        if let insuranceData = userInfo["insurances"] as? [[String: Any]] {
                           
                            for item in insuranceData{
                                if let val = item["name"] as? String {
                                    data.data.userInfo.insurance.append(val)
                                }
                            }
                        }
                        
                        if let singleInsurance = userInfo["single_insurance"] as? [String: Any] {
                            
                            if let val = singleInsurance["name"] as? String {
                                data.data.userInfo.singleInsurance = val
                            }
                        }
                        if let val = userInfo["is_profile_complete"] as? Int {
                            data.data.userInfo.isProfileUpdated = val
                        }
                        
                    }
                    if let appointmnetInfo = dataDic["appointment"] as? [String: Any] {
                        
                        if let val = appointmnetInfo["id"] as? Int {
                            data.data.appointmentInfo.id = val
                        }
                        if let val = appointmnetInfo["provider_id"] as? Int {
                            data.data.appointmentInfo.providerID = val
                        }
                        if let val = appointmnetInfo["provider_name"] as? String {
                            data.data.appointmentInfo.providerName = val
                        }
                        if let val = appointmnetInfo["provider_image"] as? String {
                            data.data.appointmentInfo.providerImage = val
                        }
                        if let val = appointmnetInfo["review_flag"] as? Bool{
                            data.data.appointmentInfo.isReview = val
                        }
                        if let specialities = appointmnetInfo["specialties"] as? [[String: Any]] {
                            var rating = DropDownModel()
                            for item in specialities{
                                rating = DropDownModel()
                                if let val = item["id"] as? Int {
                                    rating.id = val
                                }
                                if let val = item["name"] as? String {
                                    rating.name = val
                                }
                               
                                data.data.appointmentInfo.arrSpceialitoes.append(rating)
                            }
                            
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

