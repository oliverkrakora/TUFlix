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

class PagingViewModel<Item: SearchResultItem, MappedItem> {
    
    typealias ResourceProvider = ((API.PagingConfig) -> Resource<SearchResult<Item>>)
    
    typealias ItemMapper = ((Item) -> MappedItem)
    
    private let _items = MutableProperty<[MappedItem]>([])
    
    lazy var items: Property<[MappedItem]> = {
        return Property(_items)
    }()
    
    private var lastResponse: SearchResult<Item>?
    
    private var lastPageConfig: API.PagingConfig {
        return lastResponse.flatMap { API.PagingConfig(limit: $0.limit, offset: $0.offset + $0.limit) } ?? .default
    }
    
    let resourceProvider: ResourceProvider
    
    let mapper: ItemMapper
    
    var hasMoreToLoad: Bool {
        return lastResponse.flatMap { $0.offset < ($0.total ?? Int.max) } ?? true
    }
    
    lazy var loadNextPageAction: Action<Bool, [MappedItem], Error> = {
        return Action { [unowned self] shouldReset in
            let mapper = self.mapper
            return SignalProducer<SearchResult<Item>, Error> { [weak self] observer, lifetime in
                guard let self = self else {
                    #warning("Replace with error")
                    fatalError("Can't load episodes without viewModel")
                }
                
                let config = shouldReset ? API.PagingConfig.default : self.lastPageConfig
                
                let token = self.resourceProvider(config).request { result in
                    switch result {
                    case .success(let value):
                        self.lastResponse = value.model
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
                }
                .on { [weak self] in
                    if shouldReset {
                        self?._items.value = $0
                    } else {
                        self?._items.value.append(contentsOf: $0)
                    }
            }
        }
    }()
    
    init(provider: @escaping ResourceProvider, mapper: @escaping ItemMapper) {
        self.resourceProvider = provider
        self.mapper = mapper
    }
    
    func resetPaging() -> Bool {
        guard !loadNextPageAction.isExecuting.value else { return false }
        
        _items.value.removeAll()
        lastResponse = nil
        return true
    }
}
