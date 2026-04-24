//
//  GetProviderLocationService.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/09/2025.
//


import Foundation

class GetAppointmentDetailService: GenericService, @unchecked Sendable {
    
    func getData(providerId:Int,slotID:Int,completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        let queryItems: [URLQueryItem] = []
        var endPoint = String(format: Constants.URLs.getAppointmnetDetail,providerId,slotID)
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

extension GetAppointmentDetailService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> AppointmentInfoDetailResponseModel{
        
       var data = AppointmentInfoDetailResponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.responseData.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.responseData.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    
                    if let providerInfo = dataDic["provider"] as? [String: Any] {
                        
                        if let val = providerInfo["id"] as? Int {
                            data.providerInfo.id = val
                        }
                        if let val = providerInfo["name"] as? String {
                            data.providerInfo.fullName = val
                        }
                        if let val = providerInfo["email"] as? String {
                            data.providerInfo.email = val
                        }
                        if let val = providerInfo["phone_number"] as? String {
                            data.providerInfo.phoneNo = val
                        }
                        if let val = providerInfo["practice_name"] as? String {
                            data.providerInfo.practiceName = val
                        }
                        if let val = providerInfo["provider_image"] as? String {
                            data.providerInfo.providerImage = val
                        }
                        if let val = providerInfo["practice_role"] as? String {
                            data.providerInfo.practiceRole = val
                        }
                        if let bookingType = providerInfo["booking_type"] as? [String: Any] {
                            if let val = bookingType["id"] as? String {
                                data.providerInfo.bookingType.id = val
                            }
                            if let val = bookingType["title"] as? String {
                                data.providerInfo.bookingType.name = val
                            }
                        }
                        
                        if let specialities = providerInfo["specialities"] as? [[String: Any]] {
                            var list = DropDownModel()
                            for item in specialities {
                                list = DropDownModel()
                                
                                if let val = item["id"] as? Int {
                                    list.id = val
                                }
                                if let val = item["name"] as? String {
                                    list.name = val
                                }
                                data.providerInfo.specialities.append(list)
                            }
                        }
                    }
                    if let patientInfo = dataDic["patient"] as? [String: Any] {
                        if let val = patientInfo["contact_number"] as? String {
                            data.patientPhoneNo = val
                        }
                    }
                    if let slotInfo = dataDic["slot"] as? [String: Any] {
                        
                        if let val = slotInfo["id"] as? Int {
                            data.slotInfo.id = val
                        }
                        if let val = slotInfo["provider_id"] as? Int {
                            data.slotInfo.providerID = val
                        }
                        if let val = slotInfo["address_id"] as? Int {
                            data.slotInfo.addressID = val
                        }
                        if let val = slotInfo["schedule_id"] as? Int {
                            data.slotInfo.scheduleID = val
                        }
                        if let val = slotInfo["start_time"] as? String {
                            data.slotInfo.startTime = val
                        }
                        if let val = slotInfo["end_time"] as? String {
                            data.slotInfo.endTime = val
                        }
                        if let val = slotInfo["slot_date"] as? String {
                            data.slotInfo.slotDate = val
                        }
                        if let val = slotInfo["slot_number"] as? Int {
                            data.slotInfo.slotNumber = val
                        }
                        if let val = slotInfo["utc_start_time"] as? String {
                            data.slotInfo.utcStartTime = val
                        }
                        if let val = slotInfo["utc_end_time"] as? String {
                            data.slotInfo.utcEndTime = val
                        }
                        if let val = slotInfo["address"] as? String {
                            data.slotInfo.address = val
                        }
                        if let val = slotInfo["address_2"] as? String {
                            data.slotInfo.address2 = val
                        }
                        if let val = slotInfo["city"] as? String {
                            data.slotInfo.city = val
                        }
                        if let val = slotInfo["state_id"] as? Int {
                            data.slotInfo.stateID = val
                        }
                        if let val = slotInfo["zip_code"] as? String {
                            data.slotInfo.zipCode = val
                        }
                        if let val = slotInfo["is_default"] as? Int {
                            data.slotInfo.isDefault = val
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
