//
//  LoginService.swift
//  Dhalak
//
//  Created by Adeel on 6/6/22.
//


import Foundation

class SocialLoginService: GenericService, @unchecked Sendable {
    
    func login(parameters: [String: Any],completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         
         //creating payload
        //creating payload
       let requestBodyDict  = NSMutableDictionary()
       for items in parameters{
           requestBodyDict.setValue(items.value, forKey: items.key)
       }
       let jsonString = getJsonStringFromDictionary(requestBodyDict)
        let request = createURLRequest(urlString: Constants.URLs.sociallogin, requestType: .post, postData: jsonString,auth:false)
         
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

extension SocialLoginService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> LoginResponseDataModel {
        
       var data = LoginResponseDataModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let dataDic = dictionary["data"] as? [String: Any] {
                    
                    if let authDic = dataDic["authorization"] as? [String: Any]  {
                        
                        if let val = authDic["token"] as? String {
                            UserDefaults.standard.set(val, forKey: "authToken")
                        }
                    }
                    if let userDic = dataDic["user"] as? [String: Any]  {
                        
                        if let val = userDic["id"] as? Int {
                            data.userData.id = val
                        }
                        if let val = userDic["firstname"] as? String {
                            data.userData.firstName = val
                        }
                        if let val = userDic["lastname"] as? String {
                            data.userData.lastName = val
                        }
                        if let val = userDic["email"] as? String {
                            data.userData.email = val
                        }
                        if let val = userDic["email_verified_at"] as? String {
                            data.userData.emailVerifiedAt = val
                        }
                        if let val = userDic["status"] as? String {
                            data.userData.status = val
                        }
                        if let val = userDic["phone_number"] as? String {
                            data.userData.phoneNo = val
                        }
                        if let val = userDic["registration_step"] as? Int {
                            data.userData.registrationStep = val
                        }
                        if let val = userDic["deleted_at"] as? String {
                            data.userData.deletedAt = val
                        }
                        if let val = userDic["created_at"] as? String {
                            data.userData.createdAt = val
                        }
                        if let val = userDic["updated_at"] as? String {
                            data.userData.updatedAt = val
                        }
                        if let val = userDic["is_admin"] as? Int {
                            data.userData.isAdmin = val
                        }
                        if let val = userDic["is_parent"] as? Int {
                            data.userData.isParent = val
                        }
                        if let val = userDic["user_type"] as? String {
                            data.userData.userType = val
                        }
                        
                        
                    }
                    
                    if let OnBoardingDic = dataDic["users_details"] as? [String: Any]  {
                        
                        if let val = OnBoardingDic["is_on_boarding_complete"] as? Int {
                            data.onBoardingState.onBoardingComplete = val
                        }
                        if let val = OnBoardingDic["main_step"] as? Int {
                            data.onBoardingState.mainStep = val
                        }
                        if let val = OnBoardingDic["sub_step"] as? Int {
                            data.onBoardingState.subStep = val
                        }
                    }
                }
                if let val = dictionary["status"] as? Int {
                    data.responseData.status = val
                }
                if let val = dictionary["message"] as? String {
                    data.responseData.message = val
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

