//
//  GetHealthRiskScoreService.swift
//  DocHyve Patient
//

import Foundation

class GetHealthRiskScoreService: GenericService, @unchecked Sendable {
    
    func getData(memberID: Int?, apiEndPoint: String, completion: @escaping CompletionBlock, failure: @escaping FailureBlock) {
        let requestBodyDict = NSMutableDictionary()
        let jsonString = getJsonStringFromDictionary(requestBodyDict)
        
        var queryItems: [URLQueryItem] = []
        if let memID = memberID {
            queryItems.append(URLQueryItem(name: "member_id", value: "\(memID)"))
        }
        var endPoint = String(format: apiEndPoint)
        var urlComponents = URLComponents(string: endPoint)
        urlComponents?.queryItems = queryItems.isEmpty ? nil : queryItems
        endPoint = urlComponents?.url?.absoluteString ?? endPoint
        let request = createURLRequest(urlString: endPoint, requestType: .get, postData: jsonString, auth: true)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, urlResponse, error) in
            if error != nil {
                if let nsError = error as NSError? {
                    if nsError.code == NSURLErrorTimedOut {
                        failure(Constants.GenericStrings.requestTimedOut)
                    } else if nsError.code == NSURLErrorCannotConnectToHost
                                || nsError.code == NSURLErrorNetworkConnectionLost
                                || nsError.code == NSURLErrorNotConnectedToInternet {
                        failure(Constants.GenericStrings.internetNotFound)
                    } else {
                        failure(Constants.GenericStrings.somethingWentWrong)
                    }
                } else {
                    failure(Constants.GenericStrings.somethingWentWrong)
                }
            } else {
                let jsonString = String(data: data!, encoding: String.Encoding.utf8)
                if jsonString!.count == 0 {
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
                        let userData = self.parseGaugeDataFromJsonString(jsonString: jsonString ?? "")
                        completion(userData)
                    }
                }
            }
        }
        task.resume()
    }
}

extension GetHealthRiskScoreService {
    
    fileprivate func parseGaugeDataFromJsonString(jsonString: String) -> HealthRiskScoreResponseModel {
        var data = HealthRiskScoreResponseModel()
        
        do {
            guard let dictionary = try JSONSerialization.jsonObject(
                with: jsonString.data(using: .utf8)!,
                options: .allowFragments
            ) as? [String: Any] else {
                return data
            }
            
            if let status = dictionary["status"] as? Int {
                data.response.status = status
            }
            if let message = dictionary["message"] as? String {
                data.response.message = message
            }
            
            guard let payload = dictionary["data"] as? [String: Any] else {
                return data
            }
            
            if let val = payload["current_score"] as? Double {
                data.data.currentScore = val
            } else if let val = payload["current_score"] as? Int {
                data.data.currentScore = Double(val)
            }
            if let val = payload["risk_band"] as? String {
                data.data.riskBand = val
            }
            if let val = payload["risk_label"] as? String {
                data.data.riskLabel = val
            }
            if let val = payload["risk_color"] as? String {
                data.data.riskColorHex = val
            }
            if let val = payload["is_insufficient_data"] as? Bool {
                data.data.isInsufficientData = val
            }
            if let val = payload["show_book_checkup"] as? Bool {
                data.data.showBookCheckup = val
            }
            
            if let gaugeDic = payload["gauge"] as? [String: Any] {
                data.data.gauge = parseGauge(gaugeDic)
            }
            
            if let summaryDic = payload["summary"] as? [String: Any] {
                data.data.summary = parseSummary(summaryDic)
            }
            
            if let recommendationsDic = payload["recommendations"] as? [String: Any] {
                data.data.recommendations = parseRecommendations(recommendationsDic)
            }
            
        } catch {
            return data
        }
        
        return data
    }
    
    private func parseGauge(_ dic: [String: Any]) -> HealthRiskGaugeInfo {
        var gauge = HealthRiskGaugeInfo()
        if let val = dic["min"] as? Double { gauge.min = val }
        else if let val = dic["min"] as? Int { gauge.min = Double(val) }
        
        if let val = dic["max"] as? Double { gauge.max = val }
        else if let val = dic["max"] as? Int { gauge.max = Double(val) }
        
        if let val = dic["current"] as? Double { gauge.current = val }
        else if let val = dic["current"] as? Int { gauge.current = Double(val) }
        
        if let zones = dic["zones"] as? [[String: Any]] {
            for item in zones {
                var zone = HealthRiskGaugeZone()
                if let val = item["label"] as? String { zone.label = val }
                if let val = item["from"] as? Double { zone.from = val }
                else if let val = item["from"] as? Int { zone.from = Double(val) }
                if let val = item["to"] as? Double { zone.to = val }
                else if let val = item["to"] as? Int { zone.to = Double(val) }
                if let val = item["color"] as? String { zone.colorHex = val }
                gauge.zones.append(zone)
            }
        }
        return gauge
    }
    
    private func parseSummary(_ dic: [String: Any]) -> HealthRiskSummaryInfo {
        var summary = HealthRiskSummaryInfo()
        if let val = dic["risk_label"] as? String { summary.riskLabel = val }
        if let val = dic["total_score"] as? Double { summary.totalScore = val }
        else if let val = dic["total_score"] as? Int { summary.totalScore = Double(val) }
        if let val = dic["max_score"] as? Double { summary.maxScore = val }
        else if let val = dic["max_score"] as? Int { summary.maxScore = Double(val) }
        if let val = dic["age_factor"] as? Double { summary.ageFactor = val }
        else if let val = dic["age_factor"] as? Int { summary.ageFactor = Double(val) }
        if let val = dic["family_multiplier"] as? Double { summary.familyMultiplier = val }
        else if let val = dic["family_multiplier"] as? Int { summary.familyMultiplier = Double(val) }
        
        if let list = dic["category_breakdown"] as? [[String: Any]] {
            for item in list {
                var row = HealthRiskCategoryBreakdown()
                if let val = item["label"] as? String { row.label = val }
                if let val = item["score"] as? Double { row.score = val }
                else if let val = item["score"] as? Int { row.score = Double(val) }
                if let val = item["weighted"] as? Double { row.weighted = val }
                else if let val = item["weighted"] as? Int { row.weighted = Double(val) }
                if let val = item["multiplier"] as? Double { row.multiplier = val }
                else if let val = item["multiplier"] as? Int { row.multiplier = Double(val) }
                summary.categoryBreakdown.append(row)
            }
        }
        return summary
    }
    
    private func parseRecommendations(_ dic: [String: Any]) -> HealthRiskRecommendationsInfo {
        var info = HealthRiskRecommendationsInfo()
        if let val = dic["success"] as? Bool { info.success = val }
        if let val = dic["patient_id"] as? Int { info.patientId = val }
        else if let val = dic["patient_id"] as? Double { info.patientId = Int(val) }
        
        if let list = dic["recommendations"] as? [[String: Any]] {
            for item in list {
                var provider = HealthRiskRecommendedProvider()
                if let val = item["provider_id"] as? Int { provider.providerId = val }
                else if let val = item["provider_id"] as? Double { provider.providerId = Int(val) }
                
                if let val = item["specialty"] as? String { provider.specialty = val }
                if let val = item["location"] as? String { provider.location = val }
                
                if let val = item["years_experience"] as? Int { provider.yearsExperience = val }
                else if let val = item["years_experience"] as? Double { provider.yearsExperience = Int(val) }
                
                if let val = doubleValue(item["embedding_similarity"]) {
                    provider.embeddingSimilarity = val
                }
                if let val = doubleValue(item["clinical_reranker_score"]) {
                    provider.clinicalRerankerScore = val
                }
                if let val = item["location_match"] as? Bool { provider.locationMatch = val }
                
                if let val = item["rank"] as? Int { provider.rank = val }
                else if let val = item["rank"] as? Double { provider.rank = Int(val) }
                
                if let val = item["provider_name"] as? String { provider.providerName = val }
                
                // Future live keys
                if let val = item["provider_image"] as? String { provider.providerImage = val }
                if let val = doubleValue(item["rating"]) { provider.rating = val }
                if let val = item["total_reviews"] as? Int { provider.totalReviews = val }
                else if let val = item["total_reviews"] as? Double { provider.totalReviews = Int(val) }
                
                info.providers.append(provider)
            }
        }
        return info
    }
    
    private func doubleValue(_ any: Any?) -> Double? {
        if let val = any as? Double { return val }
        if let val = any as? Int { return Double(val) }
        if let val = any as? Float { return Double(val) }
        if let val = any as? NSNumber { return val.doubleValue }
        if let val = any as? String { return Double(val) }
        return nil
    }
}
