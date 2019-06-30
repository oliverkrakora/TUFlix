//
//  LibrarySeriesListViewModel.swift
//  TUFlix
//
//  Created by Oliver Krakora on 24.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import TUFlixKit
import ReactiveSwift

class LibrarySeriesListViewModel: ListViewModelProtocol, SearchableProtocol {
    
    typealias Item = SeriesViewModel
    
    let searchTerm = MutableProperty<String?>(nil)

    private let _items = MutableProperty<[SeriesViewModel]>([])
    
    private let disposable = CompositeDisposable()
    
    lazy var items: Property<[SeriesViewModel]> = {
        return Property(_items)
    }()
    
    init() {
        setupBindings()
    }
    
    deinit {
        disposable.dispose()
    }
    
    func hasContent() -> Bool {
        return !items.value.isEmpty
    }
    
    func isLoadingData() -> Bool {
        return false
    }
    
    func loadData(reset: Bool = false) -> SignalProducer<[SeriesViewModel], Error> {
        let searchTerm = self.searchTerm.value
        return SignalProducer { observer, _ in
            let series = SeriesManager.shared.favoriteSeries
                .map(SeriesViewModel.init)
                .filter { $0.matches(searchTerm: searchTerm) }
            observer.send(value: series)
            observer.sendCompleted()
            }.on { [weak self] value in
                self?._items.value = value
        }
    }
    
    private func setupBindings() {
        disposable += SeriesManager.shared.didChangeSignal.observeValues { [weak self] _ in
            self?.loadData().start()
        }
        
        disposable += searchTerm.signal.observeValues { [weak self] _ in
            self?.loadData().start()
        }
    }
}
