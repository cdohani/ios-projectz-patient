//
//  GetProviderLocationService.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/09/2025.
//


import Foundation

class GetUserAppointmentService: GenericService, @unchecked Sendable {
    
    func getData(parameters: [String: Any],completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        var queryItems: [URLQueryItem] = []
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: "\(value)"))
        }
        var endPoint = String(format: Constants.URLs.getUserAppointment)
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

extension GetUserAppointmentService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> UserAppointmentReponseModel{
        
       var data = UserAppointmentReponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.response.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.response.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    if let providerInfo = dataDic["appointments"] as? [[String: Any]] {
                        var apptData = UserAppointmentDetail()
                        for appt in providerInfo {
                             apptData = UserAppointmentDetail()
                            if let val = appt["appointment_id"] as? Int {
                                apptData.appointmentID = val
                            }
                            if let providerInfo = appt["provider"] as? [String: Any] {
                                if let val = providerInfo["id"] as? Int {
                                    apptData.providerInfo.id = val
                                }
                                if let val = providerInfo["firstname"] as? String {
                                    apptData.providerInfo.firstName = val
                                }
                                if let val = providerInfo["lastname"] as? String {
                                    apptData.providerInfo.lastName = val
                                }
                                if let val = providerInfo["practice_name"] as? String {
                                    apptData.providerInfo.practiceName = val
                                }
                                if let val = providerInfo["provider_image"] as? String {
                                    apptData.providerInfo.providerImage = val
                                }
                                if let arrSpecialities = providerInfo["specialties"] as? [[String: Any]] {
                                    var specialityData = DropDownModel()
                                    for item in arrSpecialities{
                                        specialityData = DropDownModel()
                                        if let val = item["id"] as? Int {
                                            specialityData.id = val
                                        }
                                        if let val = item["name"] as? String {
                                            specialityData.name = val
                                        }
                                        apptData.providerInfo.specialities.append(specialityData)
                                    }
                                }
                            }
                            if let val = appt["patient_id"] as? Int {
                                apptData.patientID = val
                            }
                            if let illness = appt["illness"] as? [String: Any] {
                                if let val = illness["id"] as? Int {
                                    apptData.illness.id = val
                                }
                                if let val = illness["name"] as? String {
                                    apptData.illness.name = val
                                }
                            }
                            if let val = appt["date"] as? String {
                                apptData.date = val
                            }
                            if let val = appt["date_status"] as? String {
                                apptData.dateStatus = val
                            }
                            if let val = appt["time"] as? String {
                                apptData.time = val
                            }
                            if let val = appt["reason"] as? String {
                                apptData.reason = val
                            }
                            if let val = appt["status"] as? String {
                                apptData.status = val
                            }
                            if let val = appt["notes"] as? String {
                                apptData.notes = val
                            }
                            if let val = appt["booking_type"] as? String {
                                apptData.bookingType = val
                            }
                            if let val = appt["is_reviewed"] as? Bool {
                                apptData.isPendingReview = val
                            }
                            if let val = appt["member_id"] as? Int {
                                apptData.memberID = val
                            }
                            
                            if let patientInfo = appt["patient"] as? [String: Any] {
                                if let val = patientInfo["id"] as? Int {
                                    apptData.patientInfo.id = val
                                }
                                if let val = patientInfo["firstname"] as? String {
                                    apptData.patientInfo.firstName = val
                                }
                                if let val = patientInfo["lastname"] as? String {
                                    apptData.patientInfo.lastName = val
                                }
                                if let val = patientInfo["email"] as? String {
                                    apptData.patientInfo.email = val
                                }
                                if let val = patientInfo["date_of_birth"] as? String {
                                    apptData.patientInfo.dateofBirth = val
                                }
                                if let val = patientInfo["gender"] as? String {
                                    apptData.patientInfo.gender = val
                                }
                                if let val = patientInfo["address"] as? String {
                                    apptData.patientInfo.address = val
                                }
                                if let val = patientInfo["contact_number"] as? String {
                                    apptData.patientInfo.contactNo = val
                                }
                                if let val = patientInfo["profile_image"] as? String {
                                    apptData.patientInfo.profileImage = val
                                }
                                
                            }
                            data.arrAppointment.append(apptData)
                        }
                    }
                    if let paginationInfo = dataDic["pagination"] as? [String: Any] {
                        if let val = paginationInfo["current_page"] as? Int {
                            data.paginationInfo.currentPage = val
                        }
                        if let val = paginationInfo["total_pages"] as? Int {
                            data.paginationInfo.totalPage = val
                        }
                        if let val = paginationInfo["total_records"] as? Int {
                            data.paginationInfo.totalRecord = val
                        }
                        if let val = paginationInfo["per_page"] as? Int {
                            data.paginationInfo.perPage = val
                        }
                        if let val = paginationInfo["has_more_pages"] as? Bool {
                            data.paginationInfo.hasMoreRecord = val
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
