//
//  States.swift
//  DocHyve
//
//  Created by Iftikhar Arif on 21/05/2026.
//

struct StateResponse: Codable {
    let states: [CountryState]?
    let selected_state_ids: [Int]?
 
    init(from decoder: any Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        states = try? container?.decodeIfPresent([CountryState].self, forKey: .states)
        selected_state_ids = try? container?.decodeIfPresent([Int].self, forKey: .selected_state_ids)
    }
}


struct CountryState: Codable {
    var id: Int?
    var name: String?
    var abbreviation: String?
    var created_at: String?
    var updated_at: String?
    
    init(from decoder: any Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        id = try? container?.decodeIfPresent(Int.self, forKey: .id)
        name = try? container?.decodeIfPresent(String.self, forKey: .name)
        abbreviation = try? container?.decodeIfPresent(String.self, forKey: .abbreviation)
        created_at = try? container?.decodeIfPresent(String.self, forKey: .created_at)
        updated_at = try? container?.decodeIfPresent(String.self, forKey: .updated_at)
    }
    
}
