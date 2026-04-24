//
//  GenericService.swift
//  Fatwa
//
//  Created by TheRightSW on 09/03/2020.
//

import Foundation
import Localize_Swift
//RequestType
enum RequestType {
    case get
    case post
    case delete
    case put
}

class GenericService: Operation, @unchecked Sendable {
    
    //MARK:- URL Request
    func createURLRequest(isPagination:Bool = false,urlString: String, requestType: RequestType, postData: String,auth:Bool) -> URLRequest {
        
        let finalEndPoint = getFinalEndPoint(currentEndPoint: urlString)
        var url : URL!
//        if isPagination{
//           url = URL(string: urlString)
//        }else{
//             url = URL(string: Constants.ServiceConfiguration.baseURL + urlString)
//        }
        url = URL(string: Constants.ServiceConfiguration.baseURL + finalEndPoint)
       
       
        
        var request =  URLRequest(url: url!)
        
        //Post Data
        if (requestType == .post) {
            
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = postData.data(using: .utf8)
        } else if requestType == .put {
            
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = postData.data(using: .utf8)
        } else if requestType == .delete {
            
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = postData.data(using: .utf8)
        } else {
            
            request.httpMethod = "GET"
            request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        }
        
        //generic header
        request.addValue("application/json", forHTTPHeaderField: "Accept")
    
        
        //adding the header
        if auth{
            if  let token  = UserDefaults.standard.string(forKey: "authToken"){
                    if token != "" {
                        request.addValue(String(format: "Bearer %@", token), forHTTPHeaderField: "Authorization")
                }
            }

        }
      
            
        
        return request
    }
    
    
    //MARK:- Creating request payload
    //payload from dictionary
    func getJsonStringFromDictionary(_ dic:NSDictionary) -> String {
        var jsonString = String()
        
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            jsonString = String(data: jsonData, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            
            
        } catch {
            
        }
        return jsonString
    }
    
    //payload from Array
    func getJsonStringFromArray(_ array:NSArray)->String{
        var jsonString = String()
        
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: array, options: JSONSerialization.WritingOptions.prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            jsonString = String(data: jsonData, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            
        } catch {
            
        }
        return jsonString
    }
    
    //MARK:- Parse Error Message
    func checkIfErrorFromJsonDict(responseDictionary: [String: Any],code:Int) -> [String] {
        
        var errorMessages = [String]()
        
         let status = code
            
            if status == 500 {
                
                //failure
                //sample response: {"message":"DateTime::__construct(): Failed to parse time string (15) at position 0 (1): Unexpected character","status_code":500}
                if let errorMessage = responseDictionary["message"] as? String {
                    errorMessages.append(errorMessage)
                } else {
                    errorMessages.append(Constants.GenericStrings.somethingWentWrong)
                }
            }else if status == 401 {
                
                
                if let errorMessage = responseDictionary["message"] as? String {
                    errorMessages.append(errorMessage)
                } else {
                    errorMessages.append(Constants.GenericStrings.somethingWentWrong)
                }
            }
            
            else if status != 200 {
                
                
                //failure
                //parsing the error dictionary
                if let errorDictionary = responseDictionary["errors"] as? [String : Any] {
                    
                    for (_, value) in errorDictionary {
                        errorMessages.append(value as! String)
                    }
                } else {
                    
                    //cannot parse error message
                    errorMessages.append(Constants.GenericStrings.somethingWentWrong)
                }
            }
        
        
        return errorMessages
    }
    
    func checkIfErrorsExist(jsonString: String,statusCode:Int) -> [String] {
        
        var errorMessages = [String]()
        
        do {
            if let responseDictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                
                let status = statusCode
                
                if status == 500 {
                    
                    //failure
                    //sample response: {"message":"DateTime::__construct(): Failed to parse time string (15) at position 0 (1): Unexpected character","status_code":500}
                    if let errorMessage = responseDictionary["message"] as? String {
                        errorMessages.append(errorMessage)
                    } else {
                        errorMessages.append(Constants.GenericStrings.somethingWentWrong)
                    }
                }
                else  if status == 401 {
                    
                    //failure
                    //sample response: {"message":"DateTime::__construct(): Failed to parse time string (15) at position 0 (1): Unexpected character","status_code":500}
                    if let errorMessage = responseDictionary["message"] as? String {
                        errorMessages.append(errorMessage)
                    } else {
                        errorMessages.append(Constants.GenericStrings.somethingWentWrong)
                    }
                }
                
                else if status != 200 && status != 201{
                    
                    
                    if let errorDictionary = responseDictionary["errors"] as? [String : Any] {
                        for (key, _) in errorDictionary {
                            let errorMSg = errorDictionary[key] as! [String]
                            errorMessages.append(errorMSg[0])
                        }
                    }
                    if let errorDictionary = responseDictionary["data"] as? [String : Any] {
                        for (key, _) in errorDictionary {
                            let errorMSg = errorDictionary[key] as! [String]
                            errorMessages.append(errorMSg[0])
                        }
                    }
                    else if let errorMsg = responseDictionary["message"] as? String{
                       errorMessages.append(errorMsg)
                   }
                    else {
                        
                        //cannot parse error message
                        errorMessages.append(Constants.GenericStrings.somethingWentWrong)
                    }
                }
            }
        } catch  {
            
            //an exception has occured
            errorMessages.append(Constants.GenericStrings.somethingWentWrong)
        }

        return errorMessages
    }
    func checkIfErrorsExist(jsonString: String) -> [String] {
        
        var errorMessages = [String]()
        
        do {
            if let responseDictionary = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, options: .allowFragments) as? [String: Any] {
                
                 var status = 0
                if let dataArray = responseDictionary["data"] as? [String: Any] {
                    if let code = dataArray["code"] as? Int{
                         status = code
                    }
                    if status == 500 {
                        
                        //failure
                        //sample response: {"message":"DateTime::__construct(): Failed to parse time string (15) at position 0 (1): Unexpected character","status_code":500}
                        if let errorMessage = responseDictionary["message"] as? String {
                            errorMessages.append(errorMessage)
                        } else {
                            errorMessages.append(Constants.GenericStrings.somethingWentWrong)
                        }
                    }
                    else  if status == 401 {
                        
                        //failure
                        //sample response: {"message":"DateTime::__construct(): Failed to parse time string (15) at position 0 (1): Unexpected character","status_code":500}
                        if let errorMessage = responseDictionary["message"] as? String {
                            errorMessages.append(errorMessage)
                        } else {
                            errorMessages.append(Constants.GenericStrings.somethingWentWrong)
                        }
                    }
                   
                    else if status == 422 {
                        
                       
                        //failure
                        //parsing the error dictionary
                        if let errorDictionary = dataArray["errors"] as? [String : Any] {
                            
                            for (key, _) in errorDictionary {
                                let errorMSg = errorDictionary[key] as! [String]
                                errorMessages.append(errorMSg[0])
                            }
                        } else if let errorMsg = dataArray["message"] as? String{
                            errorMessages.append(errorMsg)
                        }
                        else {
                            
                            //cannot parse error message
                            errorMessages.append(Constants.GenericStrings.somethingWentWrong)
                        }
                    }
                }

            }
        } catch  {
            
            //an exception has occured
            errorMessages.append(Constants.GenericStrings.somethingWentWrong)
        }

        return errorMessages
    }
    

    
    func getFinalEndPoint(currentEndPoint: String) -> String{
       var endPoint = ""
       let currentLang =  Localize.currentLanguage()
        if currentLang == "en"{
            return currentEndPoint
        }else{
            endPoint = "\(currentEndPoint)?locale=\(currentLang)"
            return endPoint
        }
    }
}

