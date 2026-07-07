//
//  s.swift
//  DocHyve
//
//  Created by MeshSq on 23/06/2026.
//


struct CustomCarrierResponse: Codable  {
    
    var data: [CustomCarrier]?
    var pagination: Pagination?
    
    init(from decoder: any Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        data = try? container?.decodeIfPresent([CustomCarrier].self, forKey: .data)
        pagination = try? container?.decodeIfPresent(Pagination.self, forKey: .pagination)
    }
}

struct CustomCarrier: Codable  {
    
    var created_at: String?
    var id: Int?
    //var insurance: Insurance?
    var insurance_id: Int?
    var insurance_name: String?
    var insurance_type: String?
    var plans: [String]?
    var rejection_reason: String?
    var requested_by: Int?
    var reviewed_at: String?
    var reviewed_by: Int?
    var state: CountryState?
    var state_id: Int?
    var status: String?
    var updated_at: String?
    
    init(from decoder: any Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        created_at = try? container?.decodeIfPresent(String.self, forKey: .created_at)
        id = try? container?.decodeIfPresent(Int.self, forKey: .id)
        //insurance = try? container?.decodeIfPresent(Insurance.self, forKey: .insurance)
        insurance_id = try? container?.decodeIfPresent(Int.self, forKey: .insurance_id)
        insurance_name = try? container?.decodeIfPresent(String.self, forKey: .insurance_name)
        insurance_type = try? container?.decodeIfPresent(String.self, forKey: .insurance_type)
        plans = try? container?.decodeIfPresent([String].self, forKey: .plans)
        rejection_reason = try? container?.decodeIfPresent(String.self, forKey: .rejection_reason)
        requested_by = try? container?.decodeIfPresent(Int.self, forKey: .requested_by)
        reviewed_at = try? container?.decodeIfPresent(String.self, forKey: .reviewed_at)
        reviewed_by = try? container?.decodeIfPresent(Int.self, forKey: .reviewed_by)
        state = try? container?.decodeIfPresent(CountryState.self, forKey: .state)
        state_id = try? container?.decodeIfPresent(Int.self, forKey: .state_id)
        status = try? container?.decodeIfPresent(String.self, forKey: .status)
        updated_at = try? container?.decodeIfPresent(String.self, forKey: .updated_at)
        
        
    }
    
    
    
}
