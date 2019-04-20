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

class SeriesViewModel {
    
    let model: Series
    
    lazy var fetchEpisodes: Action<(), [EpisodeViewModel], FetchError> = {
        return Action { [unowned self] _ in
            return API.Series.fetchEpisodes(for: self.model.id).fetch()
                .map { $0.model.map { EpisodeViewModel(model: $0) } }
        }
    }()
    
    var formattedTitle: String? {
        return model.title
    }
    
    var formattedCreator: String? {
        return model.creator
    }
    
    var formattedContributor: String? {
        return model.contributor
    }
    
    init(series: Series) {
        self.model = series
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
