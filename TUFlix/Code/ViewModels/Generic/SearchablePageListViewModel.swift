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

class SearchablePageListViewModel<Page: PageProtocol, MappedItem>: ListViewModelProtocol, SearchableProtocol {
    
    typealias SearchableResourceProvider = ((_ config: API.PagingConfig, _ searchTerm: String) -> SignalProducer<Page, Error>)
    
    private let pagingViewModel: PageListViewModel<Page, MappedItem>
    
    private var searchPagingViewModel: PageListViewModel<Page, MappedItem>!
    
    private var currentPagingViewModel: PageListViewModel<Page, MappedItem> {
        return isSearching.value ? searchPagingViewModel : pagingViewModel
    }
    
    private var episodesBinding: Disposable?
    
    private var searchBinding: Disposable?
    
    private let _items = MutableProperty<[MappedItem]>([])
    
    lazy var items: Property<[MappedItem]> = {
        return Property(_items)
    }()
    
    let searchTerm = MutableProperty<String?>(nil)
    
    lazy var isSearching: Property<Bool> = {
        return searchTerm.map { !($0?.isEmpty ?? true) }
    }()
    
    var loadNextPageAction: Action<Bool, [MappedItem], Error> {
        return currentPagingViewModel.loadNextPageAction
    }
    
    var loadDataAction: Action<(), [MappedItem], Error> {
        return currentPagingViewModel.loadDataAction
    }
    
    init(resourceProvider: @escaping PageListViewModel<Page, MappedItem>.PageProvider,
         searchResourceProvider: @escaping SearchableResourceProvider, mapping: @escaping PageListViewModel<Page, MappedItem>.ItemMapper) {
        pagingViewModel = PageListViewModel(provider: resourceProvider, mapper: mapping)
        searchPagingViewModel = PageListViewModel(provider: { config in
            return searchResourceProvider(config, self.searchTerm.value ?? "")
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
    
    func hasContent() -> Bool {
        return currentPagingViewModel.hasContent()
    }
    
    func hasAdditionalDataToLoad() -> Bool {
        return currentPagingViewModel.hasAdditionalDataToLoad()
    }
    
    func isLoadingData() -> Bool {
        return currentPagingViewModel.isLoadingData()
    }
    
    func loadData(reset: Bool = false) -> SignalProducer<[MappedItem], Error> {
        return currentPagingViewModel.loadData(reset: reset)
    }
    
    func resetPaging() -> Bool {
        return currentPagingViewModel.resetPaging()
    }
}
