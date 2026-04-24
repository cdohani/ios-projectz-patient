//
//  GenericFunctions.swift
//  DocHyve
//
//  Created by MacBook Pro on 07/02/2025.
//

import Foundation

func timeAgo(from dateTimeString: String, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    // Convert string to Date
    guard let eventDate = dateFormatter.date(from: dateTimeString) else {
        return "Invalid date"
    }
    
    let now = Date()
    let timeInterval = now.timeIntervalSince(eventDate)
    
    let minutes = Int(timeInterval) / 60
    let hours = minutes / 60
    let days = hours / 24
    let weeks = days / 7
    let months = days / 30
    let years = days / 365
    
    if minutes < 1 {
        return "Just now"
    } else if minutes < 60 {
        return "\(minutes) min ago"
    } else if hours < 24 {
        return "\(hours) hr ago"
    } else if days < 7 {
        return "\(days) days ago"
    } else if weeks < 4 {
        return "\(weeks) weeks ago"
    } else if months < 12 {
        return "\(months) months ago"
    } else {
        return "\(years) years ago"
    }
}


