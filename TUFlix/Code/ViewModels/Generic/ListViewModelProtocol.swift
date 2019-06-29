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
    
    /// Tells if the viewModel has data in the items array
    func hasContent() -> Bool
    
    /// Returns true if the viewModel is currently loading data
    func isLoadingData() -> Bool
    
    /// Returns true if there is data that can be loaded
    func hasAdditionalDataToLoad() -> Bool
    
    func loadData(reset: Bool) -> SignalProducer<[Item], Error>
}

extension ListViewModelProtocol {
    func hasAdditionalDataToLoad() -> Bool {
        return false
    }
}

protocol SearchableProtocol {
    var searchTerm: MutableProperty<String?> { get }
}
