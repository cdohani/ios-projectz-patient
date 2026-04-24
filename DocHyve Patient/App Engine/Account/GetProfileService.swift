//
//  GetProviderLocationService.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/09/2025.
//


import Foundation

class GetUserProfileService: GenericService, @unchecked Sendable {
    
    func getData(completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        let queryItems: [URLQueryItem] = []
        var endPoint = String(format: Constants.URLs.getUserProfile)
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

extension GetUserProfileService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> UserProfileReponseModel{
        
       var data = UserProfileReponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.response.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.response.message = status
                }
                if let patientDic = dictionary["data"] as? [String: Any] {
                    if let dataDic = patientDic["patient"] as? [String: Any] {
                        
                        if let val = dataDic["id"] as? Int {
                            data.userData.id = val
                        }
                        
                        if let val = dataDic["first_name"] as? String {
                            data.userData.firstName = val
                        }
                        if let val = dataDic["last_name"] as? String {
                            data.userData.lastName = val
                        }
                        if let val = dataDic["email"] as? String {
                            data.userData.email = val
                        }
                        if let val = dataDic["date_of_birth_formatted"] as? String {
                            data.userData.dateOfBirth = val
                        }
                        if let val = dataDic["gender"] as? String {
                            data.userData.gender = val
                        }
                        if let genderData = dataDic["extra_gender"] as? [[String: Any]] {
                            var genderList = DropDownModel()
                            for genderItem in genderData {
                                genderList = DropDownModel()
                                if let val = genderItem["id"] as? Int {
                                    genderList.id = val
                                }
                                if let val = genderItem["name"] as? String {
                                    genderList.name = val
                                }
                                data.userData.extraGender.append(genderList)
                            }
                            
                        }
                        if let val = dataDic["contact_number"] as? String {
                            data.userData.contactNumber = val
                        }
                        if let val = dataDic["profile_image"] as? String {
                            data.userData.profileImage = val
                        }
                        if let val = dataDic["nic_image"] as? String {
                            data.userData.nicImage = val
                        }
                        if let val = dataDic["street"] as? String {
                            data.userData.streetNo = val
                        }
                        if let val = dataDic["apt"] as? String {
                            data.userData.appartment = val
                        }
                        if let val = dataDic["city"] as? String {
                            data.userData.city = val
                        }
                        if let val = dataDic["zip"] as? String {
                            data.userData.zipCode = val
                        }
                        if let val = dataDic["address"] as? String {
                            data.userData.address = val
                        }
                        if let stateData = dataDic["state"] as? [String: Any] {
                            if let val = stateData["id"] as? Int {
                                data.userData.state.id = val
                            }
                            if let val = stateData["name"] as? String {
                                data.userData.state.name = val
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
