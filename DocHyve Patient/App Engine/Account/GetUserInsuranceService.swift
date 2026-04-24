//
//  GetProviderLocationService.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/09/2025.
//


import Foundation

class GetUserInsuranceService: GenericService, @unchecked Sendable {
    
    func getData(completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        let queryItems: [URLQueryItem] = []
        var endPoint = String(format: Constants.URLs.getUserInsurance)
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

extension GetUserInsuranceService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> UserInsuranceReponseModel{
        
       var data = UserInsuranceReponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.response.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.response.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    if let visitDic = dataDic["insurances"] as? [[String: Any]] {
                        var list = UserInsuranceModel()
                        for item in visitDic{
                            list = UserInsuranceModel()
                            
                            if let pateintInsurance = item["patient_insurance"] as? [[String: Any]] {
                                for insuranceInfo in pateintInsurance{
                                    if let val = insuranceInfo["id"] as? Int {
                                        list.id = val
                                    }
                                }
                            }
                            
                            if let val = item["member_id"] as? Int {
                                list.memberID = val
                            }
                            if let val = item["card_member_id"] as? String {
                                list.cardMembderID = val
                            }
                            if let val = item["insurance_id"] as? Int {
                                list.insuranceID = val
                            }
                            if let val = item["insurance_name"] as? String {
                                list.insuranceName = val
                            }
                            if let val = item["insurance_type"] as? String {
                                list.insuranceType = val
                            }
                            if let val = item["is_primary"] as? Bool {
                                list.isPrimary = val
                            }
                            if let val = item["insurance_plan_ids"] as? [Int] {
                                list.planIds = val
                            }
                            if let plans = item["plans"] as? [[String: Any]] {
                                var planList = InsurancePlanModel()
                                for item in plans{
                                    planList = InsurancePlanModel()
                                    
                                    if let val = item["id"] as? Int {
                                        planList.id = val
                                    }
                                    
                                    if let val = item["name"] as? String {
                                        planList.name = val
                                    }
                                    if let planDesc = item["detail"] as? [String: Any] {
                                        if let val = planDesc["description"] as? String {
                                            planList.description = val
                                        }
                                        if let val = planDesc["detail_description"] as? String {
                                            planList.detailDescription = val
                                        }
                                    }
                                    list.arrPlan.append(planList)
                                }
                            }
                           
                            data.arrData.append(list)
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
