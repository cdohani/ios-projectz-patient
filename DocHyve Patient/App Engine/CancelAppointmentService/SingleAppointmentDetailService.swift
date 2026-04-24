//
//  GetProviderLocationService.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/09/2025.
//


import Foundation

class SingleAppointmentDetailService: GenericService, @unchecked Sendable {
    
    func getData(apiEndPoint:String,completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        let queryItems: [URLQueryItem] = []
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

extension SingleAppointmentDetailService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> SingleAppointmentResponseModel{
        
       var data = SingleAppointmentResponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.response.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.response.message = status
                }
               
                if let dataDic = dictionary["data"] as? [String: Any] {
                    var appointmentData = SingleAppointmentDetail()
                    if let appointmentDetail = dataDic["appointment"] as? [String: Any] {
                        
                        if let val = appointmentDetail["appointment_id"] as? Int {
                            appointmentData.appointmentID = val
                        }
                        if let val = appointmentDetail["allow_in_dr_office_btn"] as? Bool {
                            appointmentData.showInOfficeButton = val
                        }
                        if let val = appointmentDetail["dochyve_meeting_id"] as? String {
                            appointmentData.videoCallMeetingID = val
                        }
                        if let providerInfo = appointmentDetail["provider"] as? [String: Any] {
                            if let val = providerInfo["id"] as? Int {
                                appointmentData.providerInfo.id = val
                            }
                            if let val = providerInfo["firstname"] as? String {
                                appointmentData.providerInfo.firstName = val
                            }
                            if let val = providerInfo["lastname"] as? String {
                                appointmentData.providerInfo.lastName = val
                            }
                            if let val = providerInfo["practice_name"] as? String {
                                appointmentData.providerInfo.practiceName = val
                            }
                            if let val = providerInfo["provider_image"] as? String {
                                appointmentData.providerInfo.providerImage = val
                            }
                            if let val = providerInfo["specialization"] as? String {
                                appointmentData.providerInfo.specialization = val
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
                                    appointmentData.providerInfo.specialities.append(specialityData)
                                }
                            }
                        }
                        if let patientInfo = appointmentDetail["patient"] as? [String: Any] {
                            if let val = patientInfo["id"] as? Int {
                                appointmentData.patientInfo.id = val
                            }
                            if let val = patientInfo["firstname"] as? String {
                                appointmentData.patientInfo.firstName = val
                            }
                            if let val = patientInfo["lastname"] as? String {
                                appointmentData.patientInfo.lastName = val
                            }
                            if let val = patientInfo["email"] as? String {
                                appointmentData.patientInfo.email = val
                            }
                            if let val = patientInfo["date_of_birth"] as? String {
                                appointmentData.patientInfo.dateofBirth = val
                            }
                            if let val = patientInfo["gender"] as? String {
                                appointmentData.patientInfo.gender = val
                            }
                            if let val = patientInfo["address"] as? String {
                                appointmentData.patientInfo.address = val
                            }
                            if let val = patientInfo["contact_number"] as? String {
                                appointmentData.patientInfo.contactNo = val
                            }
                            if let val = patientInfo["profile_image"] as? String {
                                appointmentData.patientInfo.profileImage = val
                            }
                        }
                        
                        if let slotInfo = appointmentDetail["slot"] as? [String: Any] {
                            if let val = slotInfo["id"] as? Int {
                                appointmentData.slotInfo.id = val
                            }
                            if let val = slotInfo["start_time"] as? String {
                                appointmentData.slotInfo.start_time = val
                            }
                            if let val = slotInfo["end_time"] as? String {
                                appointmentData.slotInfo.end_time = val
                            }
                            if let val = slotInfo["slot_date"] as? String {
                                appointmentData.slotInfo.slotDate = val
                            }
                            if let val = slotInfo["address_id"] as? Int {
                                appointmentData.slotInfo.address_id = val
                            }
                            
                            if let locItem = slotInfo["address"] as? [String: Any] {
                                
                                if let val = locItem["id"] as? Int {
                                    appointmentData.slotInfo.slotAddress.id = val
                                }
                                if let val = locItem["address"] as? String {
                                    appointmentData.slotInfo.slotAddress.address1 = val
                                }
                                if let val = locItem["address_2"] as? String {
                                    appointmentData.slotInfo.slotAddress.address2 = val
                                }
                                if let val = locItem["city"] as? String {
                                    appointmentData.slotInfo.slotAddress.city = val
                                }
                                if let val = locItem["zip_code"] as? String {
                                    appointmentData.slotInfo.slotAddress.zipCode = val
                                }
                                if let val = locItem["state_id"] as? Int {
                                    appointmentData.slotInfo.slotAddress.stateID = val
                                }
                                if let val = locItem["state_name"] as? String {
                                    appointmentData.slotInfo.slotAddress.stateName = val
                                }
                                if let val = locItem["is_default"] as? Int {
                                    appointmentData.slotInfo.slotAddress.isDefault = val
                                }
                                if let val = locItem["latitude"] as? String {
                                    appointmentData.slotInfo.slotAddress.lat = val
                                }
                                if let val = locItem["longitude"] as? String {
                                    appointmentData.slotInfo.slotAddress.long = val
                                }
                                if let val = locItem["created_at"] as? String {
                                    appointmentData.slotInfo.slotAddress.createdAt = val
                                }
                                if let val = locItem["updated_at"] as? String {
                                    appointmentData.slotInfo.slotAddress.updatedAt = val
                                }
                                
                            }
                            
                        }
                        
                        if let infoData = appointmentDetail["appointment_details"] as? [String: Any] {
                            if let val = infoData["date"] as? String {
                                appointmentData.appointmentInfo.date = val
                            }
                            if let val = infoData["time"] as? String {
                                appointmentData.appointmentInfo.time = val
                            }
                            if let val = infoData["formatted_date"] as? String {
                                appointmentData.appointmentInfo.formattedDate = val
                            }
                            if let val = infoData["formatted_time"] as? String {
                                appointmentData.appointmentInfo.formattedTime = val
                            }
                            if let val = infoData["formatted_datetime"] as? String {
                                appointmentData.appointmentInfo.formattedDateTime = val
                            }
                            if let val = infoData["reason"] as? String {
                                appointmentData.appointmentInfo.reason = val
                            }
                            if let val = infoData["status"] as? String {
                                appointmentData.appointmentInfo.status = val
                            }
                            if let val = infoData["booking_type"] as? String {
                                appointmentData.appointmentInfo.bookingType = val
                            }
                            if let val = infoData["is_new_patient"] as? Int {
                                appointmentData.appointmentInfo.isNewPatient = val
                            }
                            if let val = infoData["created_at"] as? String {
                                appointmentData.appointmentInfo.createdAt = val
                            }
                            if let val = infoData["updated_at"] as? String {
                                appointmentData.appointmentInfo.updatedAt = val
                            }
                            
                        }
                        if let infoData = appointmentDetail["illness"] as? [String: Any] {
                            if let val = infoData["id"] as? Int {
                                appointmentData.illnessInfo.id = val
                            }
                            if let val = infoData["name"] as? String {
                                appointmentData.illnessInfo.name = val
                            }
                        }
                        
                        if let infoData = appointmentDetail["insurance"] as? [String: Any] {
                            if let val = infoData["id"] as? Int {
                                appointmentData.insuranceInfo.id = val
                            }
                            if let val = infoData["name"] as? String {
                                appointmentData.insuranceInfo.name = val
                            }
                            if let val = infoData["plan_type"] as? String {
                                appointmentData.insuranceInfo.planType = val
                            }
                            if let val = infoData["policy_number"] as? String {
                                appointmentData.insuranceInfo.policyNumber = val
                            }
                            if let val = infoData["group_number"] as? String {
                                appointmentData.insuranceInfo.groupNumber = val
                            }
                            if let val = infoData["expiry_date"] as? String {
                                appointmentData.insuranceInfo.expiryDate = val
                            }

                        }
                        if let infoData = appointmentDetail["office_information"] as? [String: Any] {
                            
                            if let val = infoData["address"] as? String {
                                appointmentData.officeInfo.address = val
                            }
                            if let val = infoData["phone"] as? String {
                                appointmentData.officeInfo.phone = val
                            }
                            if let val = infoData["email"] as? String {
                                appointmentData.officeInfo.email = val
                            }
                            if let val = infoData["website"] as? String {
                                appointmentData.officeInfo.website = val
                            }
                            if let val = infoData["office_hours"] as? String {
                                appointmentData.officeInfo.officeHour = val
                            }

                        }
                        
                        if let infoData = appointmentDetail["preparation_guidelines"] as? [String: Any] {
                            
                            if let val = infoData["insurance_sent_to_provider"] as? Bool {
                                appointmentData.preparationGuideline.insuranceSendToProvider = val
                            }
                            if let val = infoData["network_status"] as? String {
                                appointmentData.preparationGuideline.networkStatus = val
                            }
                            if let val = infoData["guidelines"] as? [String]{
                                appointmentData.preparationGuideline.guidelines = val
                            }
                           
                        }
                        
                        if let infoData = appointmentDetail["cancellation_details"] as? [String: Any] {
                            
                            if let primaryReason = infoData["cancellation_details"] as? [String: Any] {
                                
                                if let val = primaryReason["id"] as? Int {
                                    appointmentData.cancelationInfo.id = val
                                }
                                if let val = primaryReason["reason"] as? String {
                                    appointmentData.cancelationInfo.reason = val
                                }
                                if let val = primaryReason["type"] as? String{
                                    appointmentData.cancelationInfo.type = val
                                }
                                
                            }
                            if let val = infoData["guidelines"] as? String{
                                appointmentData.cancelationInfo.primaryOtherReason = val
                            }
                            if let val = infoData["communicated_with_provider"] as? Bool{
                                appointmentData.cancelationInfo.communicatedToProvider = val
                            }
                            if let val = infoData["found_care_outside_platform"] as? Bool{
                                appointmentData.cancelationInfo.foundCareOutsideNetwork = val
                            }
                            if let val = infoData["cancelled_by"] as? Int{
                                appointmentData.cancelationInfo.cancelBy = val
                            }
                            if let val = infoData["cancelled_at"] as? String{
                                appointmentData.cancelationInfo.cancelAt = val
                            }
                           
                           
                        }
                        if let videoInfoData = appointmentDetail["video_call"] as? [String: Any] {
                            
                            if let val = videoInfoData["platform"] as? String {
                                appointmentData.videoInfo.platform = val
                            }
                            if let val = videoInfoData["meeting_id"] as? String {
                                appointmentData.videoInfo.meetingID = val
                            }
                            if let val = videoInfoData["meeting_password"] as? String {
                                appointmentData.videoInfo.meetingPassword = val
                            }
                            if let val = videoInfoData["join_url"] as? String {
                                appointmentData.videoInfo.joinUrl = val
                            }
                            if let val = videoInfoData["host_url"] as? String {
                                appointmentData.videoInfo.hostUrl = val
                            }
                            if let val = videoInfoData["meeting_created_at"] as? String {
                                appointmentData.videoInfo.meetingCreatedAt = val
                            }
                            if let val = videoInfoData["is_joinable"] as? Bool {
                                appointmentData.videoInfo.isJoinable = val
                            }
                        }
                        data.appointmentData = appointmentData
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
