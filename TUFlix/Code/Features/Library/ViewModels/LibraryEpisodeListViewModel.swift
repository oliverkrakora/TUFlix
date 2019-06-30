//
//  LibraryEpisodeListViewModel.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import ReactiveSwift
import TUFlixKit

class LibraryEpisodeListViewModel: ListViewModelProtocol, SearchableProtocol {

    typealias Item = EpisodeViewModel
    
    let seriesId: Series.Id?
    
    private let _items = MutableProperty<[EpisodeViewModel]>([])
    
    let searchTerm = MutableProperty<String?>(nil)
    
    private let disposable = CompositeDisposable()
    
    lazy var items: Property<[EpisodeViewModel]> = {
        return Property(_items)
    }()
    
    init(series: Series.Id? = nil) {
        self.seriesId = series
        setupBindings()
    }
    
    deinit {
        disposable.dispose()
    }
    
    func hasAdditionalDataToLoad() -> Bool {
        return false
    }
    
    func hasContent() -> Bool {
        return !items.value.isEmpty
    }
    
    func isLoadingData() -> Bool {
        return false
    }
    
    func loadData(reset: Bool = false) -> SignalProducer<[EpisodeViewModel], Error> {
        let seriesId = self.seriesId
        let searchTerm = self.searchTerm.value
        return SignalProducer { observer, _ in
            let episodes = EpisodeManager.shared.favoriteEpisodes
                .filter { seriesId == nil || $0.seriesId == seriesId }
                .map(EpisodeViewModel.init)
                .filter { $0.matches(searchTerm: searchTerm) }
            observer.send(value: episodes)
            observer.sendCompleted()
            }.on { [weak self] value in
                self?._items.value = value
        }
    }
    
    private func setupBindings() {
        disposable += EpisodeManager.shared.didChangeSignal.observeValues { [weak self] _ in
            self?.loadData().start()
        }
        
        disposable += searchTerm.signal.observeValues { [weak self] _ in
            self?.loadData().start()
        }
    }
}
