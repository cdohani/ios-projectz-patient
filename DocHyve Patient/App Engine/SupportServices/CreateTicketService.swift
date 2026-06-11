//
//  CreateTicketService.swift
//  DocHyve
//
//  Created by MacBook Pro on 12/03/2025.
//

import UIKit
import Alamofire


class CreateTicket: GenericService, @unchecked Sendable {

    func addData(
        endPoint: String,
        imgKey: String,
        images: [(UIImage, String, String)],
        parameters: [String: Any],// Array of (image, fileName, mimeType)
        completion: @escaping (String) -> Void,
        failure: @escaping (String) -> Void
    ) {
        let urlString = Constants.ServiceConfiguration.baseURL + endPoint

        guard let url = URL(string: urlString) else {
            failure("Invalid URL")
            return
        }

        // Prepare headers
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        if let token = UserDefaults.standard.authToken, !token.isEmpty {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }

        // Start uploading multiple files
        AF.upload(
            multipartFormData: { multipartFormData in
                // Add image data
                for (image, fileName, mimeType) in images {
                    if let imgData = image.jpegData(compressionQuality: 0.7) {
                        multipartFormData.append(
                            imgData,
                            withName: imgKey,
                            fileName: fileName,
                            mimeType: mimeType
                        )
                    }
                }
                // Add additional parameters
                for (key, value) in parameters {
                    if value is [Int] {
                        // Convert array of integers to JSON string
                        do {
                            let arrData = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                            multipartFormData.append(arrData, withName: key)
                        } catch {
                            failure("Error serializing array data: \(error.localizedDescription)")
                            return
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
            print("Upload Progress: \(progress.fractionCompleted * 100)%")
        }.responseDecodable(of: UploadResponse.self) { response in
            let code = response.response?.statusCode
            
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
            } else {
                if let jsonData = response.data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                           let message = json["message"] as? String {
                            failure(message) // Show API message
                        } else {
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
