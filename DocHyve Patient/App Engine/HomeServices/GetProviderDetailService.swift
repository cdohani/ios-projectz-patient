//
//  GetProviderLocationService.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/09/2025.
//


import Foundation

class GetProviderDetailService: GenericService, @unchecked Sendable {
    
    func getData(providerID : Int,selectedDate : String,completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        let queryItems: [URLQueryItem] = [
//            URLQueryItem(name: "date", value: selectedDate),
        ]


        var endPoint = String(format: Constants.URLs.getProviderDetail, providerID)
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

extension GetProviderDetailService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> ProviderDetailReponseModel{
        
       var data = ProviderDetailReponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.response.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.response.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    var list = ProviderDetailModel()
                    if let val = dataDic["user_id"] as? Int {
                        list.userId = val
                    }
                    if let val = dataDic["is_favorite"] as? Bool {
                        list.isFavourite = val
                    }
                    if let val = dataDic["firstname"] as? String {
                        list.firstName = val
                    }
                    if let val = dataDic["lastname"] as? String {
                        list.lastName = val
                    }
                    if let val = dataDic["full_name"] as? String {
                        list.fullName = val
                    }
                    if let val = dataDic["email"] as? String {
                        list.email = val
                    }
                    if let val = dataDic["billing_email"] as? String {
                        list.billingEmail = val
                    }
                    if let val = dataDic["username"] as? String {
                        list.userName = val
                    }
                    if let val = dataDic["status"] as? String {
                        list.status = val
                    }
                    if let val = dataDic["verification_status"] as? String {
                        list.verificationStatus = val
                    }
                    
                    if let val = dataDic["practice_name"] as? String {
                        list.practiceName = val
                    }
                    if let val = dataDic["provider_image"] as? String {
                        list.providerImage = val
                    }
                    if let val = dataDic["practice_role"] as? String {
                        list.practiceRole = val
                    }
                    if let val = dataDic["gender"] as? String {
                        list.gender = val
                    }
                    if let val = dataDic["npi"] as? String {
                        list.npi = val
                    }
                    if let val = dataDic["primary_business_address"] as? String {
                        list.primaryBusinessAddress = val
                    }
                    if let val = dataDic["hospital_system"] as? String {
                        list.hospitalSystem = val
                    }
                    if let val = dataDic["practice_size"] as? String {
                        list.practiceSize = val
                    }
                    if let val = dataDic["bio"] as? String {
                        list.bio = val
                    }
                    if let val = dataDic["about_provider"] as? String {
                        list.aboutProvider = val
                    }
                    if let val = dataDic["education_and_training"] as? String {
                        list.educationAndTraning = val
                    }
                    if let val = dataDic["publications"] as? String {
                        list.publications = val
                    }
                    if let val = dataDic["achievements"] as? String {
                        list.achivements = val
                    }
                    if let val = dataDic["board_certifications"] as? String {
                        list.boardCertificate = val
                    }
                    if let val = dataDic["in_network"] as? Bool {
                        list.isInNetwork = val
                    }
                    if let val = dataDic["specialities"] as? [String] {
                        list.specialities = val
                    }
                    if let val = dataDic["languages"] as? [String] {
                        list.languages = val
                    }
                    if let val = dataDic["assigned_roles"] as? [String] {
                        list.assignRole = val
                    }
                    
                    if let bookingType = dataDic["booking_type"] as? [String: Any] {
                        if let val = bookingType["id"] as? Int {
                            list.bookingType.id = val
                        }
                        if let val = bookingType["id"] as? String {
                            list.bookingType.id = Int(val) ?? -1
                        }
                        if let val = bookingType["title"] as? String {
                            list.bookingType.name = val
                        }
                    }
                    if let locItem = dataDic["address_used_for_slots"] as? [String: Any] {
                        
                        if let val = locItem["id"] as? Int {
                            list.slotAddress.id = val
                        }
                        if let val = locItem["address"] as? String {
                            list.slotAddress.address1 = val
                        }
                        if let val = locItem["address_2"] as? String {
                            list.slotAddress.address2 = val
                        }
                        if let val = locItem["city"] as? String {
                            list.slotAddress.city = val
                        }
                        if let val = locItem["zip_code"] as? String {
                            list.slotAddress.zipCode = val
                        }
                        if let val = locItem["state_id"] as? Int {
                            list.slotAddress.stateID = val
                        }
                        if let val = locItem["state_name"] as? String {
                            list.slotAddress.stateName = val
                        }
                        if let val = locItem["is_default"] as? Int {
                            list.slotAddress.isDefault = val
                        }
                        if let val = locItem["latitude"] as? String {
                            list.slotAddress.lat = val
                        }
                        if let val = locItem["longitude"] as? String {
                            list.slotAddress.long = val
                        }
                        if let val = locItem["created_at"] as? String {
                            list.slotAddress.createdAt = val
                        }
                        if let val = locItem["updated_at"] as? String {
                            list.slotAddress.updatedAt = val
                        }
                        
                    }
                    if let locationDic = dataDic["addresses"] as? [[String: Any]] {
                        var locationList = LocationDataModel()
                        for item in locationDic {
                            locationList = LocationDataModel()
                            
                            if let val = item["id"] as? Int {
                                locationList.id = val
                            }
                            if let val = item["address"] as? String {
                                locationList.address1 = val
                            }
                            if let val = item["address_2"] as? String {
                                locationList.address2 = val
                            }
                            if let val = item["city"] as? String {
                                locationList.city = val
                            }
                            if let val = item["zip_code"] as? String {
                                locationList.zipCode = val
                            }
                            if let val = item["state_id"] as? Int {
                                locationList.stateID = val
                            }
                            if let val = item["state_name"] as? String {
                                locationList.stateName = val
                            }
                            if let val = item["is_default"] as? Int {
                                locationList.isDefault = val
                            }
                            if let val = item["latitude"] as? String {
                                locationList.lat = val
                            }
                            if let val = item["longitude"] as? String {
                                locationList.long = val
                            }
                            if let val = item["created_at"] as? String {
                                locationList.createdAt = val
                            }
                            if let val = item["updated_at"] as? String {
                                locationList.updatedAt = val
                            }
                            list.arrAddresses.append(locationList)
                        }
                    }
                    if let insuranceDic = dataDic["insurances"] as? [[String: Any]] {
                        var induranceList = InsuranceDataModel()
                        for item in insuranceDic {
                            induranceList = InsuranceDataModel()
                            
                            if let val = item["id"] as? Int {
                                induranceList.id = val
                            }
                            if let val = item["name"] as? String {
                                induranceList.name = val
                            }
                           
                            list.arrInsurance.append(induranceList)
                        }
                    }
                   
                    if let slotsData = dataDic["slots"] as? [String: Any] {
                   
                        
                        if let val = slotsData["date"] as? String {
                            list.availableSlots.date = val
                        }
                        if let val = slotsData["message"] as? String {
                            list.availableSlots.message = val
                        }
                        if let avaSlots = slotsData["slots"] as? [[String: Any]] {
                            var slots = Slots()
                            for soltval in avaSlots{
                                slots = Slots()
                                if let val = soltval["slot_id"] as? Int {
                                    slots.id = val
                                }
                                if let val = soltval["time"] as? String {
                                    slots.time = val
                                }
                                if let val = soltval["end_time"] as? String {
                                    slots.endTime = val
                                }
                                if let val = soltval["is_booked"] as? Bool {
                                    slots.isBooked = val
                                }
                                list.availableSlots.slots.append(slots)
                            }
                        }
                    }
                    if let slotsData = dataDic["highlights"] as? [String: Any] {
                   
                        if let val = slotsData["new_patient_appointments"] as? String {
                            list.higlights.newPatientAppointment = val
                        }
                        if let val = slotsData["five_star_rating"] as? String {
                            list.higlights.fiveStarRating = val
                        }
                        if let val = slotsData["excellent_wait_time"] as? String {
                            list.higlights.excellentWaitTime = val
                        }
                        if let val = slotsData["wait_time_five_star"] as? String {
                            list.higlights.waitTimeFiveStar = val
                        }
                        if let val = slotsData["highly_recommended"] as? String {
                            list.higlights.highlyRecommended = val
                        }
                        if let val = slotsData["recommendation_five_star"] as? String {
                            list.higlights.recommendedFiveStar = val
                        }
                        
                    }
                    if let reviewData = dataDic["reviews"] as? [String: Any] {
                   
                        if let val = reviewData["total"] as? Int {
                            list.review.totalReview = val
                        }
                        if let val = reviewData["average_rating"] as? Double {
                            list.review.averageRating = val
                        }
                        if let reviewData = reviewData["recent_reviews"] as? [[String: Any]] {
                            var review = ReviewModel()
                            for item in reviewData{
                                review = ReviewModel()
                                if let val = item["id"] as? Int {
                                    review.id = val
                                }
                                if let val = item["patient_name"] as? String {
                                    review.patientName = val
                                }
                                if let val = item["patient_state"] as? String {
                                    review.patientState = val
                                }
                                if let val = item["rating"] as? Double {
                                    review.rating = val
                                }
                                if let val = item["review"] as? String {
                                    review.comment = val
                                }
                                if let val = item["created_at"] as? String {
                                    review.createdAt = val
                                }
                                list.review.recentReviews.append(review)
                            }
                        }
                    }
                    data.providerData = list
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
