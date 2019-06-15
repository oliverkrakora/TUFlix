//
//  ListViewModel.swift
//  TUFlix
//
//  Created by Oliver Krakora on 15.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import ReactiveSwift
import Fetch
import TUFlixKit

class ListViewModel<Item: SearchResultItem, MappedItem> {
    
    typealias SearchableResourceProvider = ((_ config: API.PagingConfig, _ searchTerm: String) -> Resource<SearchResult<Item>>)
    
    private let pagingViewModel: PagingViewModel<Item, MappedItem>
    
    private var searchPagingViewModel: PagingViewModel<Item, MappedItem>!
    
    private var currentPagingViewModel: PagingViewModel<Item, MappedItem> {
        return isSearching.value ? searchPagingViewModel : pagingViewModel
    }
    
    private var episodesBinding: Disposable?
    
    private var searchBinding: Disposable?
    
    private let _items = MutableProperty<[MappedItem]>([])
    
    lazy var items: Property<[MappedItem]> = {
        return Property(_items)
    }()
    
    let searchTerm = MutableProperty<String>("")
    
    lazy var isSearching: Property<Bool> = {
        return searchTerm.map { !$0.isEmpty }
    }()
    
    var hasMoreToLoad: Bool {
        return currentPagingViewModel.hasMoreToLoad
    }
    
    var loadNextPageAction: Action<Bool, [MappedItem], Error> {
        return currentPagingViewModel.loadNextPageAction
    }
    
    var hasContent: Bool {
        return !currentPagingViewModel.items.value.isEmpty
    }
    
    init(resourceProvider: @escaping PagingViewModel<Item, MappedItem>.ResourceProvider,
         searchResourceProvider: @escaping SearchableResourceProvider, mapping: @escaping PagingViewModel<Item, MappedItem>.ItemMapper) {
        pagingViewModel = PagingViewModel(provider: resourceProvider, mapper: mapping)
        searchPagingViewModel = PagingViewModel(provider: { config in
            return searchResourceProvider(config, self.searchTerm.value)
        }, mapper: mapping)
        setupBindings()
    }
    
    deinit {
        searchBinding?.dispose()
        episodesBinding?.dispose()
    }
    
    private func setupBindings() {
        searchBinding = isSearching.producer.startWithValues { [unowned self] _ in
            self.episodesBinding?.dispose()
            self.episodesBinding = self._items <~ self.currentPagingViewModel.items
        }
    }
    
    func resetPaging() -> Bool {
        return currentPagingViewModel.resetPaging()
    }
}
