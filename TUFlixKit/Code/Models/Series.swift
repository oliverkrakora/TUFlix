//
//  Series.swift
//  TUFlixKit
//
//  Created by Oliver Krakora on 20.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import Fetch

public struct Series: Hashable, Cacheable {
    
    public typealias Id = String
    
    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case title = "dcTitle"
        case creator = "dcCreator"
        case contributor = "dcContributor"
    }
    
    public let identifier: Id
    public let title: String?
    public let creator: String?
    public let contributor: String?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
