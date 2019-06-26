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

class LibrarySeriesListViewModel: ListViewModelProtocol {
    
    typealias Item = SeriesViewModel
    
    private let _items = MutableProperty<[SeriesViewModel]>([])
    
    private var disposable: Disposable?
    
    lazy var items: Property<[SeriesViewModel]> = {
        return Property(_items)
    }()
    
    init() {
        setupBindings()
    }
    
    deinit {
        disposable?.dispose()
    }
    
    func hasContent() -> Bool {
        return !items.value.isEmpty
    }
    
    func isExecuting() -> Bool {
        return false
    }
    
    func loadData() -> SignalProducer<[SeriesViewModel], Error> {
        return SignalProducer { observer, _ in
            let series = SeriesManager.shared.favoriteSeries.map(SeriesViewModel.init)
            observer.send(value: series)
            observer.sendCompleted()
            }.on { [weak self] value in
                self?._items.value = value
        }
    }
    
    private func setupBindings() {
        disposable = SeriesManager.shared.didChangeSignal.observeValues { [weak self] _ in
            self?.loadData().start()
        }
    }
}
