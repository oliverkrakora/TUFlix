//
//  UserDefaults+Extension.swift
//  TUFlixKit
//
//  Created by Oliver Krakora on 17.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation

public extension UserDefaults {
    
    @discardableResult
    func encode<T: Encodable>(_ object: T, key: String, encoder: JSONEncoder = JSONEncoder()) -> Bool {
        guard let encoded = try? encoder.encode(object) else { return false }
        
        set(encoded, forKey: key)
        return true
    }
    
    func decode<T: Decodable>(for key: String, decoder: JSONDecoder = JSONDecoder()) -> T? {
        return data(forKey: key).flatMap {
            do {
                return try decoder.decode(T.self, from: $0)
            } catch {
                print("Failed to decode \(error)")
                return nil
            }
        }
    }
}
