//
//  SearchResult.swift
//  TUFlixKit
//
//  Created by Oliver Krakora on 28.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import Fetch

public protocol PageProtocol: Decodable {
    
    associatedtype Item: Decodable
    
    var hasNext: Bool { get }
    
    var items: [Item] { get }
}

public typealias SearchResultItem = Codable & Equatable

public struct SearchResult<Item: SearchResultItem>: Decodable, PageProtocol {
    
    private enum CodingKeys: String, CodingKey {
        case offset
        case limit
        case total
        case items = "result"
    }
    
    public let offset: Int
    
    public let limit: Int
    
    public let total: Int
    
    public var hasNext: Bool {
        return offset < total
    }
    
    public let items: [Item]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        offset = try Int(container.decode(String.self, forKey: .offset))!
        limit = try Int(container.decode(String.self, forKey: .limit))!
        total = try Int(container.decode(String.self, forKey: .total))!
        
        do {
            items = try container.decodeIfPresent([Item].self, forKey: .items) ?? []
        } catch {
            let item = try container.decodeIfPresent(Item.self, forKey: .items)
            items = item.flatMap { [$0] } ?? []
        }
    }
}
