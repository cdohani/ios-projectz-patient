//
//  UploadDocument.swift
//  DocHyve
//
//  Created by MacBook Pro on 15/01/2025.
//


import Foundation
import UIKit
import Alamofire
class uploadDoc:  GenericService,@unchecked Sendable {

    func upload(
        docName: String,
        image: UIImage,
        completion: @escaping (String) -> Void,
        failure: @escaping (String) -> Void
    ) {
        // Construct the endpoint and URL
        let urlString = Constants.ServiceConfiguration.baseURL +  Constants.URLs.addFamilyMember

        guard let url = URL(string: urlString) else {
            failure("Invalid URL")
            return
        }

        // Prepare headers
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        if let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }

        // Start uploading
        AF.upload(
            multipartFormData: { multipartFormData in
                // Add image data
                if let imgData = image.jpegData(compressionQuality: 0.7) {
                    multipartFormData.append(
                        imgData,
                        withName: "image",
                        fileName: docName,
                        mimeType: "image/jpeg"
                    )
                }
            },
            to: url,
            headers: headers
        ).uploadProgress { progress in
            // Print upload progress
            print("Upload Progress: \(progress.fractionCompleted * 100)%")
        }.responseDecodable(of: UploadResponse.self) { response in
            // Handle response
            switch response.result {
            case .success(let uploadResponse):
                if let message = uploadResponse.message {
                    completion(message)
                } else {
                    failure("Failed to parse response.")
                }

            case .failure(let error):
                if let statusCode = response.response?.statusCode, statusCode == 413 {
                    failure("Uploaded file size exceeds the maximum allowed limit.")
                } else if response.response?.statusCode == 404 {
                    failure(Constants.GenericStrings.somethingWentWrong)
                } else {
                    failure(error.localizedDescription)
                }
            }
        }
    }
}


struct UploadResponse: Decodable {
    let message: String?
    let status: String?
    // Add other properties based on the response structure
}
