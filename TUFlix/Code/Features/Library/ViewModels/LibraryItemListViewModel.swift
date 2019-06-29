//
//  LibraryViewModel.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import ReactiveSwift

class LibraryItemListViewModel: ListViewModelProtocol {
    
    typealias Item = LibraryItem
    
    let items: Property<[LibraryItem]> = {
        return Property(value: [
            LibraryItem(title: L10n.Episodes.title, image: nil),
            LibraryItem(title: L10n.Series.title, image: nil)
        ])
    }()
    
    func hasContent() -> Bool {
        return true
    }
    
    func isLoadingData() -> Bool {
        return false
    }
    
    func loadData(reset: Bool = false) -> SignalProducer<[LibraryItem], Error> {
        return SignalProducer(value: self.items.value)
    }
}
