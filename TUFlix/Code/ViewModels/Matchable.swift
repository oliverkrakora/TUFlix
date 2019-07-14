//
//  Searchable.swift
//  TUFlix
//
//  Created by Oliver Krakora on 14.07.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation

protocol Matchable {
    func matches(searchTerm: String?) -> Bool
}
