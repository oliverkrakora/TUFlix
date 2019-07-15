//
//  Settings.swift
//  TUFlix
//
//  Created by Oliver Krakora on 30.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation

class Settings: Codable {
    
    private static let userDefaultsKey = "settings"
    
    static let shared: Settings = {
        return UserDefaults.standard.decode(for: userDefaultsKey) ?? Settings()
    }()
    
    var preferDateOverTitleInSeries: Bool = true {
        didSet {
            persist()
        }
    }
    
    private init() {}
    
    private func persist() {
        let didEncode = UserDefaults.standard.encode(self, key: Settings.userDefaultsKey)
        if !didEncode {
            print("Failed to persist settings")
        }
    }
}
