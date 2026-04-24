//
//  GetProviderLocationService.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/09/2025.
//


import Foundation

class GetAllReviewService: GenericService, @unchecked Sendable {
    
    func getData(providerID: Int,sortBy:String,completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
         //creating payload
        let requestBodyDict  = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        var queryItems: [URLQueryItem] = []
        if sortBy != "most_recent"{
             queryItems = [
                URLQueryItem(name: "sort_by", value: sortBy)
            ]
        }
        var endPoint = String(format: Constants.URLs.getAllReviews, providerID)
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

extension GetAllReviewService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> ReviewReponseModel{
        
       var data = ReviewReponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                if let status = dictionary["status"] as? Int {
                    data.response.status = status
                }
                if let status = dictionary["message"] as? String {
                    data.response.message = status
                }
                if let dataDic = dictionary["data"] as? [String: Any] {
                    if let val = dataDic["overall_rating"] as? Double  {
                        data.reviewData.overallRating = val
                    }
                    if let val = dataDic["total_reviews"] as? Int  {
                        data.reviewData.totalReviews = val
                    }
                    if let ratingInfo = dataDic["category_ratings"] as? [[String: Any]] {
                        var rating = RatingInfo()
                        for item in ratingInfo{
                            rating = RatingInfo()
                            if let val = item["name"] as? String {
                                rating.name = val
                            }
                            if let val = item["rating"] as? Double {
                                rating.rating = val
                            }
                            data.reviewData.arrRating.append(rating)
                        }
                    }
                    
                    if let reviewData = dataDic["reviews"] as? [[String: Any]] {
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
                            if let val = item["review_text"] as? String {
                                review.comment = val
                            }
                            if let val = item["verified_patient"] as? Bool {
                                review.verifiedPatinet = val
                            }
                            if let val = item["created_at"] as? String {
                                review.createdAt = val
                            }
                            if let val = item["days_ago"] as? String {
                                review.daysAgo = val
                            }
                            if let val = item["time_ago"] as? String {
                                review.timeAgo = val
                            }
                            data.reviewData.arrReview.append(review)
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
