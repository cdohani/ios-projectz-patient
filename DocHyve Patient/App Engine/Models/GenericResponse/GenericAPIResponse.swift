//
//  GenericAPIResponse.swift
//  DocHyve
//
//  Created by Iftikhar Arif on 1/21/26.
//
import Foundation

// MARK: - Generic API Response Wrapper
struct GenericAPIResponse<T: Codable>: Codable {
    var status: Int?
    var data: T?
    var message: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case data
    }
    
    
//    init(from decoder: Decoder) {
//        let values = try? decoder.container(keyedBy: CodingKeys.self)
//        status = try? values?.decodeIfPresent(Int.self, forKey: .status)
//        message = try? values?.decodeIfPresent(String.self, forKey: .message)
//        data = try? values?.decodeIfPresent(ApiData.self, forKey: .data)
//    }
        
}


struct Pagination: Codable {

    var current_page: Int?
    var last_page: Int?
    var per_page: Int?
    var total: Int?
    var has_more_pages: Bool?
   
    var total_pages: Int?
    var total_records: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        current_page = try? values.decodeIfPresent(Int.self, forKey: .current_page)
        last_page = try? values.decodeIfPresent(Int.self, forKey: .last_page)
        per_page = try? values.decodeIfPresent(Int.self, forKey: .per_page)
        total = try? values.decodeIfPresent(Int.self, forKey: .total)
        has_more_pages = try? values.decodeIfPresent(Bool.self, forKey: .has_more_pages)
        total_pages = try? values.decodeIfPresent(Int.self, forKey: .total_pages)
        total_records = try? values.decodeIfPresent(Int.self, forKey: .total_records)
    }
   
}

struct ApplicationData: Codable {
    var application_id: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        application_id = try? values.decodeIfPresent(Int.self, forKey: .application_id)
    }
    
}



struct NamedItem: Codable {
    var id: Int?
    var name: String?
    var pivot: Pivot?
    
    
    var base_price: String?
    var pricing_type: String?
    
    var icon_full_url: String?
        
    
    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        id = try? container?.decodeIfPresent(Int.self, forKey: .id)
        name = try? container?.decodeIfPresent(String.self, forKey: .name)
        pivot = try? container?.decodeIfPresent(Pivot.self, forKey: .pivot)
        
        base_price = try? container?.decodeIfPresent(String.self, forKey: .base_price)
        pricing_type = try? container?.decodeIfPresent(String.self, forKey: .pricing_type)
        
        icon_full_url = try? container?.decodeIfPresent(String.self, forKey: .icon_full_url)
    }
    
}

struct Pivot: Codable {
    
    var updated_at: String?
    var created_at: String?
    var rcm_request_id: Int?
    var mandatory_service_id: Int?
    
    var extra_answers: String?
    var optional_service_id: Int?
    var patient_count: String?
    var phone_lines: String?
    var phone_type: String?
    var price_snapshot: String?
    var selected_age_tier: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        created_at = try? container.decodeIfPresent(String.self, forKey: .created_at)
        mandatory_service_id = try? container.decodeIfPresent(Int.self, forKey: .mandatory_service_id)
        rcm_request_id = try? container.decodeIfPresent(Int.self, forKey: .rcm_request_id)
        updated_at = try? container.decodeIfPresent(String.self, forKey: .updated_at)
        
        extra_answers = try? container.decodeIfPresent(String.self, forKey: .extra_answers)
        optional_service_id = try? container.decodeIfPresent(Int.self, forKey: .optional_service_id)
        patient_count = try? container.decodeIfPresent(String.self, forKey: .patient_count)
        phone_lines = try? container.decodeIfPresent(String.self, forKey: .phone_lines)
        phone_type = try? container.decodeIfPresent(String.self, forKey: .phone_type)
        price_snapshot = try? container.decodeIfPresent(String.self, forKey: .price_snapshot)
        selected_age_tier = try? container.decodeIfPresent(String.self, forKey: .selected_age_tier)
    }
    
}


//MARK: - CodingKeys
enum CodingKeys: String, CodingKey {
    case id
    case name
    case application_id
    case mandatory_services
    case optional_services
    case price_range
    case insurance_collection_options
    case practice_management_software
    case category_ratings
    case overall_rating
    case total_reviews
    case reviews
    case pagination
    case review
    case patient
    case time_ago
    case provider_id
    case created_at
    case appointment
    case booking_type
    case practice_name
    case provider_name
    case provider_image
    case behavior_rating
    case punctuality_rating
    case satisfaction_rating
    case communication_rating
    case treatment_guidance_rating
    case rating
    case current_page
    case last_page
    case per_page
    case total
    case applications
//    case id
//    case review
//    case patient
//    case time_ago
//    case provider_id
//    case created_at
//    case appointment
//    case booking_type
//    case practice_name
//    case provider_name
//    case provider_image
//    case overall_rating
//    case behavior_rating
//    case punctuality_rating
//    case satisfaction_rating
//    case communication_rating
//    case treatment_guidance_rating
//    case category_ratings
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

