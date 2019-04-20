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
    
}
