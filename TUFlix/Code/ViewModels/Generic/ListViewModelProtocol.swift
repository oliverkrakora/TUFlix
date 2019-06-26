//
//  ListViewModelProtocol.swift
//  TUFlix
//
//  Created by Oliver Krakora on 18.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import ReactiveSwift
import TUFlixKit

protocol ListViewModelProtocol {
    
    associatedtype Item
    
    var items: Property<[Item]> { get }
    
    func hasContent() -> Bool
    
    func isExecuting() -> Bool
    
    func loadData() -> SignalProducer<[Item], Error>
}

protocol SearchableProtocol {
    var searchTerm: MutableProperty<String?> { get }
}

protocol PageableProtocol {
    
    func loadData<T>(reset: Bool) -> SignalProducer<[T], Error>
    
    func hasMoreToLoad() -> Bool
}

protocol PageableListViewModelProtocol: ListViewModelProtocol, PageableProtocol { }
