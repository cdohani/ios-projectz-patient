//
//  HealthRiskScoreModel.swift
//  DocHyve Patient
//

import UIKit

struct HealthRiskScoreResponseModel {
    var response = GeneralResponseModel()
    var data = HealthRiskScoreData()
}

struct HealthRiskScoreData {
    var currentScore: Double = 0
    var riskBand = ""
    var riskLabel = ""
    var riskColorHex = ""
    var isInsufficientData = false
    var showBookCheckup = false
    var gauge = HealthRiskGaugeInfo()
    var summary = HealthRiskSummaryInfo()
    var recommendations = HealthRiskRecommendationsInfo()
    
    /// Mapped for Suggested Doctors UI (`RecommendedDoctorModel`).
    var suggestedDoctors: [RecommendedDoctorModel] {
        recommendations.providers.map { $0.asRecommendedDoctorModel() }
    }    
    var riskLevel: HealthRiskLevel {
        let band = riskBand.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let label = riskLabel.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check moderate/high first — "yellow" contains "low" as a substring.
        if band.contains("orange") || band.contains("yellow") || band.contains("moderate")
            || band == "amber" {
            return .moderate
        }
        if band.contains("red") || band.contains("high") {
            return .high
        }
        if band.contains("green") || band == "low" || band.hasPrefix("low") {
            return .low
        }
        
        if label.contains("moderate") {
            return .moderate
        }
        if label.contains("high") {
            return .high
        }
        if label == "low" || label.hasPrefix("low ") || label.hasPrefix("low risk") {
            return .low
        }
        
        // Fall back to score zones when band/label are unclear.
        let score = gauge.current
        if let zones = Optional(gauge.zones.sorted(by: { $0.from < $1.from })), zones.count >= 3 {
            if score >= zones[2].from { return .high }
            if score >= zones[1].from { return .moderate }
            return .low
        }
        if score >= 60 { return .high }
        if score >= 30 { return .moderate }
        return .low
    }
    
    var riskUIColor: UIColor {
        riskColorHex.isEmpty ? riskLevel.color : UIColor(hex: riskColorHex)
    }
    
    /// Needle position 0...1 across the gauge min...max range.
    var needleProgress: CGFloat {
        let minValue = gauge.min
        let maxValue = gauge.max
        let span = maxValue - minValue
        guard span > 0 else { return 0 }
        let current = gauge.current
        return CGFloat(min(max((current - minValue) / span, 0), 1))
    }
    
    var displayRiskTitle: String {
        let label = riskLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        if label.isEmpty { return riskLevel.title }
        // Keep meter title short (e.g. "Low Risk" → "Low")
        return label
            .replacingOccurrences(of: " Risk", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var selectedItemCount: Int {
        summary.categoryBreakdown.filter { $0.score > 0 }.count
    }
    
    var estimateText: String {
        let count = selectedItemCount
        if count > 0 {
            return "Estimated from \(count) selected item\(count == 1 ? "" : "s")"
        }
        return "Based on your health check data"
    }
    
    /// e.g. "1.6 / 100"
    var scoreDisplayText: String {
        let current = gauge.current
        let maxValue = gauge.max
        if current == floor(current) {
            return String(format: "%.0f / %.0f", current, maxValue)
        }
        return String(format: "%.1f / %.0f", current, maxValue)
    }
    
    var tipText: String {
        if isInsufficientData {
            return "More health information is needed for a better estimate. Complete your health check details."
        }
        if showBookCheckup {
            return "A specialist review within the next month is recommended."
        }
        return "A few selected conditions overlap. A specialist review within the next month is recommended."
    }
}

struct HealthRiskGaugeInfo {
    var min: Double = 0
    var max: Double = 100
    var current: Double = 0
    var zones = [HealthRiskGaugeZone]()
}

struct HealthRiskGaugeZone {
    var label = ""
    var from: Double = 0
    var to: Double = 0
    var colorHex = ""
    
    var color: UIColor {
        colorHex.isEmpty ? .gray : UIColor(hex: colorHex)
    }
    
    var shortLabel: String {
        label
            .replacingOccurrences(of: " Risk", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct HealthRiskSummaryInfo {
    var riskLabel = ""
    var totalScore: Double = 0
    var maxScore: Double = 100
    var categoryBreakdown = [HealthRiskCategoryBreakdown]()
    var ageFactor: Double = 0
    var familyMultiplier: Double = 1
}

struct HealthRiskCategoryBreakdown {
    var label = ""
    var score: Double = 0
    var weighted: Double = 0
    var multiplier: Double?
}

struct HealthRiskRecommendationsInfo {
    var success = false
    var patientId = -1
    var providers = [HealthRiskRecommendedProvider]()
}

struct HealthRiskRecommendedProvider {
    var providerId = -1
    var specialty = ""
    var location = ""
    var yearsExperience = 0
    var embeddingSimilarity: Double = 0
    var clinicalRerankerScore: Double = 0
    var locationMatch = false
    var rank = 0
    var providerName = ""
    /// Coming on live API later.
    var providerImage = ""
    /// Coming on live API later.
    var rating: Double = 0
    /// Coming on live API later (optional).
    var totalReviews = 0
    
    func asRecommendedDoctorModel() -> RecommendedDoctorModel {
        var doctor = RecommendedDoctorModel()
        doctor.id = providerId
        doctor.specialities = specialty.capitalized
        doctor.providerImage = providerImage
        doctor.avgRating = rating
        doctor.totalReviews = totalReviews
        doctor.isBoosted = false
        
        let trimmed = providerName.trimmingCharacters(in: .whitespacesAndNewlines)
        if let space = trimmed.firstIndex(of: " ") {
            doctor.firstName = String(trimmed[..<space])
            doctor.lastName = String(trimmed[trimmed.index(after: space)...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            doctor.firstName = trimmed
            doctor.lastName = ""
        }
        return doctor
    }
}

