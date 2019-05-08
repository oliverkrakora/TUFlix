//
//  SeriesViewModel.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import TUFlixKit
import Fetch
import ReactiveSwift
import DataSource

struct SeriesViewModel {
    
    let model: Series
    
    let episodePager: PagedResource<SearchResult<Episode>, EpisodeViewModel>
    
    var episodes: [EpisodeViewModel] {
        return episodePager.mappedItems
    }
    
    var formattedTitle: String? {
        return model.title
    }
    
    var formattedCreator: String? {
        return model.creator
    }
    
    var formattedContributor: String? {
        return model.contributor
    }
    
    var hasContent: Bool {
        return !episodes.isEmpty
    }
    
    init(model: Series) {
        self.model = model
        let episodeResource = API.Series.pageEpisodes(for: model.id)
        self.episodePager = PagedResource(initialPage: episodeResource, mappingClosure: {
            return EpisodeViewModel(model: $0)
        }, resourceConstructor: { (_, currentPage) in
            let pageConfig = API.PagingConfig(limit: currentPage.limit, offset: currentPage.offset + currentPage.limit)
            return API.Series.pageEpisodes(for: model.id, config: pageConfig)
        })
    }
}

extension SeriesViewModel: Diffable {
    var diffIdentifier: String {
        return model.id
    }
    
    func isEqualToDiffable(_ other: Diffable?) -> Bool {
        guard let other = other as? SeriesViewModel else { return false }
        return diffIdentifier == other.diffIdentifier
    }
}
