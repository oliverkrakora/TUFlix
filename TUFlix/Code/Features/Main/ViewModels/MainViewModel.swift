//
//  MainViewModel.swift
//  TUFlix
//
//  Created by Oliver Krakora on 19.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import ReactiveSwift
import Fetch
import TUFlixKit
import Result

enum ContentType: Int {
    case episodes = 0
    case series = 1
}

class MainViewModel {
    
    let contentType = MutableProperty<ContentType>(.episodes)
    
    private(set) var episodePageResource: PagedResource<SearchResult<Episode>, EpisodeViewModel>!
    
    private(set) var seriesPageResource: PagedResource<SearchResult<Series>, SeriesViewModel>!
    
    private let shouldReloadObserver = Signal<PagingError?, NoError>.pipe()
    
    private let disposable = CompositeDisposable()
    
    var shouldReloadSignal: Signal<PagingError?, NoError> {
        return shouldReloadObserver.output
    }
    
    var hasMorePages: Bool {
        switch contentType.value {
        case .episodes:
            return episodePageResource.hasMorePages
        case .series:
            return seriesPageResource.hasMorePages
        }
    }
    
    var hasContent: Bool {
        switch contentType.value {
        case .episodes:
            return !episodePageResource.pages.isEmpty
        case .series:
            return !seriesPageResource.pages.isEmpty
        }
    }
    
    var currentPageItems: [Any] {
        switch contentType.value {
        case .episodes:
            return episodePageResource.mappedItems
        case .series:
            return seriesPageResource.mappedItems
        }
    }
    
    init() {
        episodePageResource = PagedResource(initialPage: API.Episode.page(), mappingClosure: {
            return EpisodeViewModel(model: $0)
        }, resourceConstructor: { [unowned self] _, currentPage in
            return API.Episode.page(with: self.pageConfig(for: currentPage))
        })
        
        seriesPageResource = PagedResource(initialPage: API.Series.page(), mappingClosure: {
            return SeriesViewModel(model: $0)
        }, resourceConstructor: { [unowned self] _, currentPage in
            return API.Series.page(with: self.pageConfig(for: currentPage))
        })
        
        setupBindings()
    }
    
    private func setupBindings() {
        disposable += contentType.map({ _ in nil }).signal.observe(shouldReloadObserver.input)
    }
    
    func loadData(reset: Bool = false) {
        switch contentType.value {
        case .episodes:
            episodePageResource.loadNext(reset: reset) { [weak self] result in
                self?.sendReloadSignal(for: .episodes, error: result.error)
            }
        case .series:
            seriesPageResource.loadNext(reset: reset) { [weak self] result in
                self?.sendReloadSignal(for: .series, error: result.error)
            }
        }
    }
    
    private func sendReloadSignal(for contentType: ContentType, error: PagingError?) {
        guard self.contentType.value == contentType else { return }
        shouldReloadObserver.input.send(value: error)
    }
    
    private func pageConfig<T>(for currentPage: SearchResult<T>) -> API.PagingConfig {
        return API.PagingConfig(limit: currentPage.limit, offset: currentPage.offset + currentPage.limit)
    }
}
