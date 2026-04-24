//
//  MoreGenderService.swift
//  DocHyve
//
//  Created by MacBook Pro on 26/02/2025.
//

import Foundation

class SearchDoctorService: GenericService, @unchecked Sendable {
    
    func searchData(parameters: [String: Any],completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
    
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        for items in parameters{
            requestBodyDict.setValue(items.value, forKey: items.key)
        }
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        let request = createURLRequest(urlString: Constants.URLs.searchDoctors, requestType: .post, postData: jsonString,auth:true)
         
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

extension SearchDoctorService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> SearchDoctorReponseModel{
        
       var data = SearchDoctorReponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.response.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.response.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    if let visitDic = dataDic["providers"] as? [[String: Any]] {
                        var list = SearchDoctorModel()
                        for item in visitDic{
                            list = SearchDoctorModel()
                            if let val = item["user_id"] as? Int {
                                list.userId = val
                            }
                            if let val = item["firstname"] as? String {
                                list.firstName = val
                            }
                            if let val = item["lastname"] as? String {
                                list.lastName = val
                            }
                            if let val = item["email"] as? String {
                                list.email = val
                            }
                            if let val = item["status"] as? String {
                                list.status = val
                            }
                            if let val = item["verification_status"] as? String {
                                list.verificationStatus = val
                            }
                            if let val = item["user_type"] as? String {
                                list.userType = val
                            }
                            if let val = item["detail_id"] as? Int {
                                list.detailId = val
                            }
                            if let val = item["practice_name"] as? String {
                                list.practiceName = val
                            }
                            if let val = item["provider_image"] as? String {
                                list.providerImage = val
                            }
                            if let val = item["practice_role"] as? String {
                                list.practiceRole = val
                            }
                            if let val = item["gender"] as? String {
                                list.gender = val
                            }
                            if let val = item["npi"] as? String {
                                list.npi = val
                            }
                            if let val = item["specialities"] as? String {
                                list.specialities = val
                            }
                            if let val = item["languages"] as? String {
                                list.languages = val
                            }
                            if let val = item["assigned_roles"] as? String {
                                list.assignedRoles = val
                            }
                            if let val = item["addresses"] as? String {
                                list.addresses = val
                            }
                            if let val = item["total_reviews"] as? Int {
                                list.totalReviews = val
                            }
                            if let val = item["average_rating"] as? Double {
                                list.avgRating = val
                            }
                            if let bookingType = item["booking_type"] as? [String: Any] {
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
                            if let val = item["next_available_dates"] as? [String] {
                                list.nextAvailableDates = val
                            }
                            if let val = item["in_network"] as? Bool {
                                list.inNetwork = val
                            }
                            
                            if let locItem = item["address_used_for_slots"] as? [String: Any] {
                                
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
                            
                            if let locationDic = item["addresses_list"] as? [[String: Any]] {
                                var locationList = LocationDataModel()
                                for locItem in locationDic {
                                    locationList = LocationDataModel()
                                    
                                    if let val = locItem["id"] as? Int {
                                        locationList.id = val
                                    }
                                    if let val = locItem["address"] as? String {
                                        locationList.address1 = val
                                    }
                                    if let val = locItem["address_2"] as? String {
                                        locationList.address2 = val
                                    }
                                    if let val = locItem["city"] as? String {
                                        locationList.city = val
                                    }
                                    if let val = locItem["zip_code"] as? String {
                                        locationList.zipCode = val
                                    }
                                    if let val = locItem["state_id"] as? Int {
                                        locationList.stateID = val
                                    }
                                    if let val = locItem["state_name"] as? String {
                                        locationList.stateName = val
                                    }
                                    if let val = locItem["is_default"] as? Int {
                                        locationList.isDefault = val
                                    }
                                    if let val = locItem["latitude"] as? String {
                                        locationList.lat = val
                                    }
                                    if let val = locItem["longitude"] as? String {
                                        locationList.long = val
                                    }
                                    if let val = locItem["created_at"] as? String {
                                        locationList.createdAt = val
                                    }
                                    if let val = locItem["updated_at"] as? String {
                                        locationList.updatedAt = val
                                    }
                                    list.arrAddresses.append(locationList)
                                }
                            }
                            
                            if let currSlots = item["slots"] as? [String: Any] {
                                if let val = currSlots["date"] as? String {
                                    list.availableSlots.date = val
                                }
                                if let avalSlot = currSlots["slots"] as? [[String: Any]] {
                                    var slots = Slots()
                                    for soltval in avalSlot{
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
                            
                            data.arrProvider.append(list)
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
