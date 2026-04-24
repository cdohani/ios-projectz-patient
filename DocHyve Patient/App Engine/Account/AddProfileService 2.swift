//
//  CreateNewProviderService.swift
//  DocHyve
//
//  Created by MacBook Pro on 16/01/2025.
//

import Foundation
import UIKit
import Alamofire
class AddProfileService:  GenericService,@unchecked Sendable {
    
    func addData(
        endPoint: String,
        mimeType: String,
        images: [(key: String, image: UIImage)]?,
        parameters: [String: Any],
        completion: @escaping CompletionBlock, failure: @escaping FailureBlock
    ) {
        // Construct the endpoint and URL
        let urlString = Constants.ServiceConfiguration.baseURL + endPoint

        guard let url = URL(string: urlString) else {
            failure("Invalid URL")
            return
        }

        // Prepare headers
        var headers: HTTPHeaders = []
        if let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        headers.add(name: "Accept", value: "application/json")
        // Generate a unique filename if docName is not provided
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        let uniqueFileName = "\(currentTimestamp).jpg"  // You can change the extension based on the mimeType if needed
        
        // Start uploading
        AF.upload(
            multipartFormData: { multipartFormData in
                // Add image data
                if let images = images {
                    for (index, item) in images.enumerated() {
                        
                        let image = item.image
                        let key = item.key
                        
                        let imageData: Data?

                        if mimeType == "image/jpeg" {
                            imageData = image.jpegData(compressionQuality: 0.6)
                        } else {
                            imageData = image.pngData()
                        }

                        if let data = imageData {
                            let fileName = "\(currentTimestamp)_\(index).jpg"
                            
                            multipartFormData.append(
                                data,
                                withName: key, // 👈 dynamic key from tuple
                                fileName: fileName,
                                mimeType: mimeType
                            )
                        }
                    }
                }
                
                // Add additional parameters
                for (key, value) in parameters {
                    if let array = value as? [Int] {
                        for item in array {
                            let data = "\(item)".data(using: .utf8)!
                            multipartFormData.append(data, withName: "\(key)[]")
                        }
                    } else {
                        if let strValue = "\(value)".data(using: .utf8) {
                            multipartFormData.append(strValue, withName: key)
                        } else {
                            failure("Unable to encode value for parameter \(key).")
                            return
                        }
                    }
                }
            },
            to: url,
            headers: headers
        ).uploadProgress { progress in
            // Print upload progress
            print("Upload Progress: \(progress.fractionCompleted * 100)%")
        }.responseString { response in
            let code = response.response?.statusCode
            let jsonString = String(data: response.data!, encoding:String.Encoding.utf8)
           if code == 200 || code == 201{
               if let jsonData = response.data {
                   do {
                       if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                          let message = json["message"] as? String {
                           completion(message) // Show success message
                       } else {
                           failure(Constants.GenericStrings.somethingWentWrong)
                       }
                   } catch {
                       failure(Constants.GenericStrings.somethingWentWrong)
                   }
               } else {
                   failure(Constants.GenericStrings.somethingWentWrong)
               }
           } else if code == 413 {
               failure("Uploaded file size exceeds the maximum allowed limit.")
           } else if code == 404 {
               failure(Constants.GenericStrings.somethingWentWrong)
           }
            else {
                if let jsonData = response.data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {

                            // 1️⃣ Field-specific error
                            if let data = json["data"] as? [String: Any],
                               let errors = data["errors"] as? [String: Any],
                               let imageErrors = errors["image"] as? [String],
                               let firstError = imageErrors.first {

                                failure(firstError)
                                return
                            }

                            // 2️⃣ Fallback API message
                            if let message = json["message"] as? String {
                                failure(message)
                                return
                            }

                            // 3️⃣ Generic fallback
                            failure(Constants.GenericStrings.somethingWentWrong)
                        }
                    } catch {
                        failure(Constants.GenericStrings.somethingWentWrong)
                    }
                } else {
                    failure(Constants.GenericStrings.somethingWentWrong)
                }

           }
       }
    }
}

 extension AddProfileService {
    
    fileprivate func parseUserInformationFromJsonString (jsonString: String) -> GeneralResponseModel{
        
       var data = GeneralResponseModel()
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                
                if let val = dictionary["status"] as? Int {
                    data.status = val
                }
                if let val = dictionary["message"] as? String {
                    data.message = val
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


