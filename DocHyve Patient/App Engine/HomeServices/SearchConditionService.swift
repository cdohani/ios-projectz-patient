//
//  GetProviderLocationService.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/09/2025.
//


import Foundation

class SearchConditionService: GenericService, @unchecked Sendable {
    
    func getData(queryText:String,completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        let endPoint = String(format: Constants.URLs.searchCondition,queryText)
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

extension SearchConditionService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> SearchConditionResponseModel{
        
       var data = SearchConditionResponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.responseData.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.responseData.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    
                    if let specialityInfo = dataDic["specialties"] as? [[String: Any]] {
                        var list = SearchConditionDataModel()
                        for item in specialityInfo{
                            list = SearchConditionDataModel()
                            if let val = item["id"] as? Int {
                                list.id = val
                            }
                            if let val = item["name"] as? String {
                                list.name = val
                            }
                            if let val = item["type"] as? String {
                                list.type = val
                            }
                           
                            data.arrCondition.append(list)
                        }
                    }
                    
                    if let doctorInfo = dataDic["providers"] as? [[String: Any]] {
                        var list = SearchDoctorDataModel()
                        for item in doctorInfo{
                            list = SearchDoctorDataModel()
                            if let val = item["id"] as? Int {
                                list.id = val
                            }
                            if let val = item["name"] as? String {
                                list.name = val
                            }
                            if let val = item["email"] as? String {
                                list.email = val
                            }
                            if let val = item["practice_role"] as? String {
                                list.practiceRole = val
                            }
                            if let val = item["provider_image"] as? String {
                                list.providerImage = val
                            }
                            if let val = item["state"] as? String {
                                list.state = val
                            }
                            
                            if let specialityInfo = item["specialties"] as? [[String: Any]] {
                                var specialityList = DropDownModel()
                                for item in specialityInfo{
                                    specialityList = DropDownModel()
                                    if let val = item["id"] as? Int {
                                        specialityList.id = val
                                    }
                                    if let val = item["name"] as? String {
                                        specialityList.name = val
                                    }
                                    
                                   
                                    list.arrSpeciality.append(specialityList)
                                }
                            }
                            
                            if let val = item["type"] as? String {
                                list.type = val
                            }
                           
                            data.arrDoctor.append(list)
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
