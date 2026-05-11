//
//  GetProviderLocationService.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/09/2025.
//


import Foundation

class GetMedicationHistoryService: GenericService, @unchecked Sendable {
    
    func getData(memberID:Int?,apiEndPoint:String,completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        var queryItems: [URLQueryItem] = []
        if let memID = memberID {
            queryItems.append(URLQueryItem(name: "member_id", value: "\(memID)"))
        }
        var endPoint = String(format: apiEndPoint)
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

extension GetMedicationHistoryService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> MedicationReponseModel{
        
       var data = MedicationReponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.response.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.response.message = status
                }
               
                if let visitDic = dictionary["data"] as? [[String: Any]] {
                    var list = MedicineDetailModel()
                    for item in visitDic{
                        list = MedicineDetailModel()
                        
                        if let val = item["id"] as? Int {
                            list.id = val
                        }
                        if let val = item["medication"] as? String {
                            list.medication = val
                        }
                        if let val = item["dosage"] as? String {
                            list.dosage = val
                        }
                        if let val = item["duration"] as? String {
                            list.duration = val
                        }
                        if let val = item["frequency"] as? String {
                            list.frequency = val
                        }
                        if let val = item["reason"] as? String {
                            list.reason = val
                        }
                        data.arrData.append(list)
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
