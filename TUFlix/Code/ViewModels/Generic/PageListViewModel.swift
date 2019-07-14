//
//  PagingViewModel.swift
//  TUFlix
//
//  Created by Oliver Krakora on 15.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import ReactiveSwift
import TUFlixKit
import Fetch

class PageListViewModel<Page: PageProtocol, MappedItem>: ListViewModelProtocol {
    
    typealias PageProvider = ((API.PagingConfig) -> SignalProducer<Page, Error>)
    
    typealias ItemMapper = ((Page.Item) -> MappedItem)
    
    private let resourceProvider: PageProvider
    
    private let mapper: ItemMapper
    
    private let _items = MutableProperty<[MappedItem]>([])
    
    lazy var items: Property<[MappedItem]> = {
        return Property(_items)
    }()
    
    private var lastResponse: Page?
    
    private var lastPageConfig: API.PagingConfig?
    
    lazy var loadDataAction: Action<(), [MappedItem], Error> = {
        return Action { [unowned self] in
            self.loadNextPageAction.apply(false)
                .mapError { $0 as Error }
        }
    }()
    
    lazy var loadNextPageAction: Action<Bool, [MappedItem], Error> = {
        return Action { [unowned self] shouldReset in
            let mapper = self.mapper
            let config: API.PagingConfig = shouldReset ? .default : (self.lastPageConfig ?? .default)
            let producer = self.resourceProvider(config)
    
            return SignalProducer<Page, Error> { [weak self] observer, lifetime in
                
                let disposable = producer.startWithResult { result in
                    switch result {
                    case .success(let value):
                        self?.lastResponse = value
                        self?.lastPageConfig = API.PagingConfig(limit: config.limit, offset: config.offset + value.items.count)
                        observer.send(value: value)
                        observer.sendCompleted()
                    case .failure(let error):
                        observer.send(error: error)
                    }
                }
                
                lifetime.observeEnded {
                    disposable.dispose()
                }
                }.map {
                    $0.items.map { mapper($0) }
                }.on { [weak self] items in
                    if shouldReset {
                        self?._items.value = items
                    } else {
                        self?._items.value.append(contentsOf: items)
                    }
            }
        }
    }()
    
    init(provider: @escaping PageProvider, mapper: @escaping ItemMapper) {
        self.resourceProvider = provider
        self.mapper = mapper
    }
    
    func hasContent() -> Bool {
        return !items.value.isEmpty
    }
    
    func hasAdditionalDataToLoad() -> Bool {
        return lastResponse?.hasNext ?? true
    }
    
    func isLoadingData() -> Bool {
        return loadNextPageAction.isExecuting.value
    }
    
    func loadData(reset: Bool = false) -> SignalProducer<[MappedItem], Error> {
        return loadDataAction
            .apply()
            .mapError { $0 as Error }
    }
    
    func resetPaging() -> Bool {
        guard !loadNextPageAction.isExecuting.value else { return false }
        
        _items.value.removeAll()
        lastResponse = nil
        return true
    }
}
