//
//  GenericService.swift
//  Fatwa
//
//  Created by TheRightSW on 09/03/2020.
//

import Foundation

class RegistrationService: GenericService, @unchecked Sendable {
    
    //this api is used to add adresses and provider because same argument and returning model
    func addData(parameters: [String: Any],endPoint:String,completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        for items in parameters{
            requestBodyDict.setValue(items.value, forKey: items.key)
        }
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        let request = createURLRequest(urlString: endPoint, requestType: .post, postData: jsonString,auth:true)
         
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

extension RegistrationService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> RegisterReponseModel{
        
        var data = RegisterReponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                
                if let val = dictionary["status"] as? Int {
                    data.response.status = val
                }
                if let val = dictionary["message"] as? String {
                    data.response.message = val
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    if let val = dataDic["user_id"] as? Int {
                        data.userID = val
                    }
                    if let val = dataDic["signup_step"] as? Int {
                        data.signupStep = val
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


