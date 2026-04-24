//
//  GetProviderLocationService.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/09/2025.
//


import Foundation

class GetMemberService: GenericService, @unchecked Sendable {
    
    func getData(completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        let queryItems: [URLQueryItem] = []
        var endPoint = String(format: Constants.URLs.getFamilyMembers)
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

extension GetMemberService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> MemberReponseModel{
        
       var data = MemberReponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.response.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.response.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    if let visitDic = dataDic["members"] as? [[String: Any]] {
                        var list = MemberDetailModel()
                        for item in visitDic{
                            list = MemberDetailModel()
                            
                            if let val = item["id"] as? Int {
                                list.id = val
                            }
                            if let val = item["patient_id"] as? Int {
                                list.patientID = val
                            }
                            if let val = item["first_name"] as? String {
                                list.firstName = val
                            }
                            if let val = item["last_name"] as? String {
                                list.lastName = val
                            }
                            if let val = item["relation"] as? String {
                                list.relationship = val
                            }
                            if let val = item["image"] as? String {
                                list.userImage = val
                            }
                            if let val = item["primary_insurance_id"] as? Int {
                                list.primaryInsuranceID = val
                            }
                            if let val = item["primary_member_id"] as? String {
                                list.primaryMemberID = val
                            }
                            if let val = item["secondary_insurance_id"] as? Int {
                                list.secondaryInsuranceID = val
                            }
                            if let val = item["secondary_member_id"] as? String {
                                list.secondaryMemberID = val
                            }
                            if let val = item["created_at"] as? String {
                                list.createdAT = val
                            }
                            if let val = item["updated_at"] as? String {
                                list.updatedAT = val
                            }
                            if let PrimaryInsuranceDetail = item["primary_insurance"] as? [String : Any] {
                                
                                if let InsuranceDetail = PrimaryInsuranceDetail["insurance"] as? [String : Any] {
                                    if let val = InsuranceDetail["id"] as? Int {
                                        list.primaryInsuranceInfo.id = val
                                    }
                                    if let val = InsuranceDetail["name"] as? String {
                                        list.primaryInsuranceInfo.name = val
                                    }
                                    if let val = InsuranceDetail["icon"] as? String {
                                        list.primaryInsuranceInfo.icon = val
                                    }
                                    
                                }
                                
                               
                            }
                            if let SecondaryInsuranceDetail = item["secondary_insurance"] as? [String : Any] {
                                
                                if let InsuranceDetail = SecondaryInsuranceDetail["insurance"] as? [String : Any] {
                                    if let val = InsuranceDetail["id"] as? Int {
                                        list.secondaryInsuranceInfo.id = val
                                    }
                                    if let val = InsuranceDetail["name"] as? String {
                                        list.secondaryInsuranceInfo.name = val
                                    }
                                    if let val = InsuranceDetail["icon"] as? String {
                                        list.secondaryInsuranceInfo.icon = val
                                    }
                                }
                               
                            }
                            
                           
                            data.arrMembers.append(list)
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
