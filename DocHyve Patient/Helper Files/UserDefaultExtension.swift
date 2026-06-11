//
//  UserDefaultExtension.swift
//  DocHyve
//
//  Created by Iftikhar Arif on 1/8/26.
//

import Foundation

extension UserDefaults {
    
    enum Keys: String {
        case sideMenu
        case authToken
        case loginUserID
    }
    
    
    var loginUserID: Int? {
        get { UserDefaults.standard.object(forKey: "loginUserID") as? Int}
        set { UserDefaults.standard.setValue(newValue, forKey: "loginUserID") }
    }
    
    var authToken: String? {
        get { UserDefaults.standard.string(forKey: "authToken") }
        set { UserDefaults.standard.setValue(newValue, forKey: "authToken") }
    }
    
    
    func save<T: Codable>(_ value: T, forKey key: Keys) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(value)
            set(data, forKey: key.rawValue)
        } catch {
            print("UserDefaults save error for key \(key): \(error)")
        } 
    }
    
    func load<T: Codable>(_ type: T.Type, forKey key: Keys) -> T? {
        guard let data = data(forKey: key.rawValue) else { return nil }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(type, from: data)
        } catch {
            print("UserDefaults load error for key \(key): \(error)")
            return nil
        }
    }
    
    func removeAll() {
        //dictionaryRepresentation().keys.forEach { key in removeObject(forKey: key) }
        dictionaryRepresentation().keys.forEach { removeObject(forKey: $0)}
        synchronize()
    }
    
}
