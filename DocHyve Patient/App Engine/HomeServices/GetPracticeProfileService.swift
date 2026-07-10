//
//  GetPracticeProfileService.swift
//  DocHyve Patient
//

import Foundation

class GetPracticeProfileService: GenericService, @unchecked Sendable {
    
    func getData(providerId: Int, completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
        let requestBodyDict = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        let endPoint = String(format: Constants.URLs.getPracticeProfile, providerId)
        let request = createURLRequest(urlString: endPoint, requestType: .get, postData: jsonString, auth: true)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, urlResponse, error) in
            if (error != nil) {
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
                let jsonString = String(data: data!, encoding: String.Encoding.utf8)
                if (jsonString!.count == 0) {
                    failure(Constants.GenericStrings.somethingWentWrong)
                } else {
                    var code = 0
                    if let httpResponse = urlResponse as? HTTPURLResponse {
                        print("statusCode: \(httpResponse.statusCode)")
                        code = httpResponse.statusCode
                    }
                    var errorMessages = self.checkIfErrorsExist(jsonString: jsonString ?? "", statusCode: code)
                    
                    if errorMessages.count == 0 {
                        errorMessages = self.checkIfErrorsExist(jsonString: jsonString ?? "")
                    }
                    if errorMessages.count > 0 {
                        failure(errorMessages[0])
                    } else {
                        let practiceData = self.parsePracticeProfileFromJsonString(jsonString: jsonString ?? "")
                        completion(practiceData)
                    }
                }
            }
        }
        task.resume()
    }
}

extension GetPracticeProfileService {
    
    fileprivate func parsePracticeProfileFromJsonString(jsonString: String) -> PracticeProfileResponseModel {
        
        var data = PracticeProfileResponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                
                if let status = dictionary["status"] as? Int {
                    data.responseData.status = status
                }
                if let message = dictionary["message"] as? String {
                    data.responseData.message = message
                }
                
                if let dataDic = dictionary["data"] as? [String: Any] {
                    
                    if let val = dataDic["practice_id"] as? Int {
                        data.data.practiceId = val
                    }
                    if let val = dataDic["practice_name"] as? String {
                        data.data.practiceName = val
                    }
                    if let val = dataDic["practice_logo"] as? String {
                        data.data.practiceLogo = val
                    }
                    if let val = dataDic["owner_name"] as? String {
                        data.data.ownerName = val
                    }
                    if let val = dataDic["about"] as? String {
                        data.data.about = val
                    }
                    if let val = dataDic["description"] as? String {
                        data.data.description = val
                    }
                    
                    // Parse office_locations
                    if let locations = dataDic["office_locations"] as? [[String: Any]] {
                        for locationDic in locations {
                            var location = PracticeLocationModel()
                            if let val = locationDic["id"] as? Int {
                                location.id = val
                            }
                            if let val = locationDic["address"] as? String {
                                location.address = val
                            }
                            if let val = locationDic["address_2"] as? String {
                                location.address2 = val
                            }
                            if let val = locationDic["city"] as? String {
                                location.city = val
                            }
                            if let val = locationDic["state_name"] as? String {
                                location.stateName = val
                            }
                            if let val = locationDic["zip_code"] as? String {
                                location.zipCode = val
                            }
                            if let val = locationDic["latitude"] as? String {
                                location.latitude = val
                            }
                            if let val = locationDic["longitude"] as? String {
                                location.longitude = val
                            }
                            if let val = locationDic["is_default"] as? Int {
                                location.isDefault = val
                            }
                            if let val = locationDic["location_name"] as? String {
                                location.locationName = val
                            }
                            data.data.officeLocations.append(location)
                        }
                    }
                    
                    // Parse metrics
                    if let metricsDic = dataDic["metrics"] as? [String: Any] {
                        if let val = metricsDic["total_patients"] as? Int {
                            data.data.metrics.totalPatients = val
                        }
                        if let val = metricsDic["total_appointments"] as? Int {
                            data.data.metrics.totalAppointments = val
                        }
                        if let val = metricsDic["rating"] as? Double {
                            data.data.metrics.rating = val
                        }
                    }
                    
                    // Parse amenities
                    if let amenities = dataDic["amenities"] as? [[String: Any]] {
                        for amenityDic in amenities {
                            var amenity = PracticeAmenityModel()
                            if let val = amenityDic["id"] as? Int {
                                amenity.id = val
                            }
                            if let val = amenityDic["name"] as? String {
                                amenity.name = val
                            }
                            data.data.amenities.append(amenity)
                        }
                    }
                    
                    // Parse specialties
                    if let specialties = dataDic["specialties"] as? [String] {
                        data.data.specialties = specialties
                    }
                    
                    // Parse providers
                    if let providers = dataDic["providers"] as? [[String: Any]] {
                        for providerDic in providers {
                            var provider = PracticeProviderModel()
                            if let val = providerDic["provider_id"] as? Int {
                                provider.providerId = val
                            }
                            if let val = providerDic["firstname"] as? String {
                                provider.firstname = val
                            }
                            if let val = providerDic["lastname"] as? String {
                                provider.lastname = val
                            }
                            if let val = providerDic["provider_image"] as? String {
                                provider.providerImage = val
                            }
                            if let val = providerDic["degree"] as? String {
                                provider.degree = val
                            }
                            if let val = providerDic["rating"] as? Double {
                                provider.rating = val
                            }
                            if let val = providerDic["review_count"] as? Int {
                                provider.reviewCount = val
                            }
                            if let val = providerDic["appointments_last_7_days"] as? Int {
                                provider.appointmentsLast7Days = val
                            }
                            if let val = providerDic["next_available_date"] as? String {
                                provider.nextAvailableDate = val
                            }
                            if let val = providerDic["specialties"] as? [String] {
                                provider.speciality = val
                            }
                            if let val = providerDic["in_network"] as? Bool {
                                provider.inNetwork = val
                            }
                            
                            // Parse provider address
                            if let addressDic = providerDic["address"] as? [String: Any] {
                                var address = PracticeProviderAddressModel()
                                if let val = addressDic["id"] as? Int {
                                    address.id = val
                                }
                                if let val = addressDic["address"] as? String {
                                    address.address = val
                                }
                                if let val = addressDic["city"] as? String {
                                    address.city = val
                                }
                                if let val = addressDic["state_name"] as? String {
                                    address.stateName = val
                                }
                                if let val = addressDic["zip_code"] as? String {
                                    address.zipCode = val
                                }
                                if let val = addressDic["is_default"] as? Int {
                                    address.isDefault = val
                                }
                                provider.address = address
                            }
                            
                            data.data.providers.append(provider)
                        }
                    }
                    
                    // Parse contact_info
                    if let contactDic = dataDic["contact_info"] as? [String: Any] {
                        if let val = contactDic["phone"] as? String {
                            data.data.contactInfo.phone = val
                        }
                        if let val = contactDic["email"] as? String {
                            data.data.contactInfo.email = val
                        }
                        if let val = contactDic["website"] as? String {
                            data.data.contactInfo.website = val
                        }
                        
                        // Parse working_hours
                        if let workingHours = contactDic["working_hours"] as? [[String: Any]] {
                            for hourDic in workingHours {
                                var hour = PracticeWorkingHourModel()
                                if let val = hourDic["day_of_week"] as? String {
                                    hour.dayOfWeek = val
                                }
                                if let val = hourDic["time_from"] as? String {
                                    hour.timeFrom = val
                                }
                                if let val = hourDic["time_to"] as? String {
                                    hour.timeTo = val
                                }
                                data.data.contactInfo.workingHours.append(hour)
                            }
                        }
                    }
                }
                
            } else {
                return data
            }
        } catch {
            return data
        }
        return data
    }
}
