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
            return episodePageResource.items.map { EpisodeViewModel(model: $0) }
        case .series:
            return seriesPageResource.items.map { SeriesViewModel(model: $0) }
        }
    }
    
    init() {
        episodePageResource = PagedResource(initalPage: API.Episode.page()) { [unowned self] _, currentPage in
            return API.Episode.page(with: self.pageConfig(for: currentPage))
        }
        seriesPageResource = PagedResource(initalPage: API.Series.page()) { [unowned self] _, currentPage in
            return API.Series.page(with: self.pageConfig(for: currentPage))
        }
    }
    
    func loadData(reset: Bool = false, callback: @escaping (Result<Any, PagingError>) -> Void) {
        switch contentType {
        case .episodes:
            return episodePageResource.loadNext(reset: reset) { result in
                callback(result.map { $0 as Any })
            }
        case .series:
            return seriesPageResource.loadNext(reset: reset) { result in
                callback(result.map { $0 as Any })
            }
        }
    }
    
    private func pageConfig<T>(for currentPage: SearchResult<T>) -> API.PagingConfig {
        return API.PagingConfig(limit: currentPage.limit, offset: currentPage.offset + currentPage.limit)
    }
}
