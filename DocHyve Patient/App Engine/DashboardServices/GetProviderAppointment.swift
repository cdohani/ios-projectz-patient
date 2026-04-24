//
//  GetProviderLocationService.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/09/2025.
//


import Foundation

class GetProviderAppointmentService: GenericService, @unchecked Sendable {
    
    func getData(providerID:Int,completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        let queryItems: [URLQueryItem] = []
        var endPoint = String(format: Constants.URLs.getProviderAppointment, providerID)
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

extension GetProviderAppointmentService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> ProviderAppointmentReponseModel{
        
       var data = ProviderAppointmentReponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.response.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.response.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    if let providerInfo = dataDic["provider"] as? [String: Any] {
                        if let val = providerInfo["id"] as? Int {
                            data.providerData.id = val
                        }
                        if let val = providerInfo["name"] as? String {
                            data.providerData.name = val
                        }
                        if let val = providerInfo["practice_name"] as? String {
                            data.providerData.practiceName = val
                        }
                        if let val = providerInfo["specialities"] as? [String] {
                            data.providerData.providerSpeciality = val
                        }
                    }
                    
                    if let visitDic = dataDic["appointments"] as? [[String: Any]] {
                        var list = AppointmentDetail()
                        for item in visitDic{
                            list = AppointmentDetail()
                            
                            if let val = item["id"] as? Int {
                                list.id = val
                            }
                            
                            if let val = item["date"] as? String {
                                list.date = val
                            }
                            if let val = item["time"] as? String {
                                list.time = val
                            }
                            if let val = item["reason"] as? String {
                                list.reason = val
                            }
                            if let val = item["status"] as? String {
                                list.status = val
                            }
                            if let val = item["notes"] as? String {
                                list.notes = val
                            }
                            if let val = item["booking_type"] as? String {
                                list.bookingType = val
                            }
                            if let val = item["is_new_patient"] as? Bool {
                                list.isNewPatient = val
                            }
                            if let val = item["is_reviewed"] as? Bool {
                                list.isReviewed = val
                            }
                            if let patientInfo = item["patient"] as? [String : Any] {
                                if let val = patientInfo["firstname"] as? String {
                                    list.patientFirstName = val
                                }
                                if let val = patientInfo["lastname"] as? String {
                                    list.patientLastName = val
                                }
                            }
                            if let val = item["illness"] as? String {
                                list.illness = val
                            }
                            if let val = item["insurance"] as? String {
                                list.insurance = val
                            }
                            if let val = item["member"] as? String {
                                list.member = val
                            }
                            if let val = item["created_at"] as? String {
                                list.createdAt = val
                            }
                            if let val = item["updated_at"] as? String {
                                list.updatedAt = val
                            }
                            data.providerData.arrAppointment.append(list)
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
