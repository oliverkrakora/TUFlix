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

class PageListViewModel<Page: PageProtocol, MappedItem>: ListViewModelProtocol, PageableProtocol {
    
    typealias ResourceProvider = ((API.PagingConfig) -> Resource<Page>)
    
    typealias ItemMapper = ((Page.Item) -> MappedItem)
    
    private let resourceProvider: ResourceProvider
    
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
            return SignalProducer<Page, Error> { [weak self] observer, lifetime in
                guard let self = self else {
                    #warning("Replace with error")
                    fatalError("Can't load episodes without viewModel")
                }
                
                let config: API.PagingConfig = (shouldReset ? .default : self.lastPageConfig) ?? .default
                
                let token = self.resourceProvider(config).request { result in
                    switch result {
                    case .success(let value):
                        self.lastResponse = value.model
                        self.lastPageConfig = API.PagingConfig(limit: config.limit, offset: config.offset + value.model.items.count)
                        observer.send(value: value.model)
                        observer.sendCompleted()
                    case .failure(let error):
                        observer.send(error: error)
                    }
                }
                
                lifetime.observeEnded {
                    token?.cancel()
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
    
    init(provider: @escaping ResourceProvider, mapper: @escaping ItemMapper) {
        self.resourceProvider = provider
        self.mapper = mapper
    }
    
    func hasContent() -> Bool {
        return !items.value.isEmpty
    }
    
    func hasMoreToLoad() -> Bool {
        return lastResponse?.hasNext ?? true
    }
    
    func isExecuting() -> Bool {
        return loadNextPageAction.isExecuting.value
    }
    
    func loadData() -> SignalProducer<[MappedItem], Error> {
        return loadDataAction
            .apply()
            .mapError { $0 as Error }
    }
    
    func loadData<T>(reset: Bool) -> SignalProducer<[T], Error> {
        return loadNextPageAction
            .apply(reset)
            .map { $0 as! [T] }
            .mapError { $0 as Error }
    }
    
    func resetPaging() -> Bool {
        guard !loadNextPageAction.isExecuting.value else { return false }
        
        _items.value.removeAll()
        lastResponse = nil
        return true
    }
}
