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

enum ContentType: Int {
    case episodes = 0
    case series = 1
}

class MainViewModel {
    
    var contentType: ContentType = .episodes
    
    private(set) var episodePageResource: PagedResource<SearchResult<Episode>>!
    
    private(set) var seriesPageResource: PagedResource<SearchResult<Series>>!
    
    var hasMorePages: Bool {
        switch contentType {
        case .episodes:
            return episodePageResource.hasMorePages
        case .series:
            return seriesPageResource.hasMorePages
        }
    }
    
    var hasContent: Bool {
        switch contentType {
        case .episodes:
            return !episodePageResource.pages.isEmpty
        case .series:
            return !seriesPageResource.pages.isEmpty
        }
    }
    
    var currentPageItems: [Any] {
        switch contentType {
        case .episodes:
            return episodePageResource.pages.reduce(into: [], { (arr, result) in
                arr += result.items.map { EpisodeViewModel(model: $0) }
            })
        case .series:
            return seriesPageResource.pages.reduce(into: [], { (arr, result) in
                arr += result.items.map { SeriesViewModel(series: $0) }
            })
        }
    }

    lazy var fetchEpisodes: Action<(), [EpisodeViewModel], FetchError> = {
        return Action { _ in
            return API.Episode.allEpisodes().fetch()
                .map { $0.model.map { EpisodeViewModel(model: $0) } }
        }
    }()
    
    lazy var fetchSeries: Action<(), [SeriesViewModel], FetchError> = {
        return Action { _ in
            return API.Series.allSeries().fetch()
                .map { $0.model.map { SeriesViewModel(series: $0) } }
        }
    }()
    
    init() {
        episodePageResource = PagedResource(initalPage: API.Episode.page()) { [unowned self] _, currentPage in
            return API.Episode.page(with: self.pageConfig(for: currentPage))
        }
        seriesPageResource = PagedResource(initalPage: API.Series.page()) { [unowned self] _, currentPage in
            return API.Series.page(with: self.pageConfig(for: currentPage))
        }
    }
    
    func loadData(force: Bool = false, callback: @escaping (Result<Any, PagingError>) -> Void) {
        switch contentType {
        case .episodes:
            return episodePageResource.loadNext(force: force) { result in
                callback(result.map { $0 as Any })
            }
        case .series:
            return seriesPageResource.loadNext(force: force) { result in
                callback(result.map { $0 as Any })
            }
        }
    }
    
    private func pageConfig<T>(for currentPage: SearchResult<T>) -> API.PagingConfig {
        return API.PagingConfig(limit: currentPage.limit, offset: currentPage.offset + currentPage.limit)
    }
}
