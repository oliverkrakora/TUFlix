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
import Result

class SeriesViewModel {
    
    let model: Series
    
    var favoriteStatusDidChange: Signal<(), NoError> {
        return SeriesManager.shared.didChangeSignal
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
    
    var isFavorite: Bool {
        return SeriesManager.shared.isInFavorites(series: model)
    }
    
    func likeSeries() {
        SeriesManager.shared.addToFavorites(series: model)
    }
    
    func unlikeSeries() {
        SeriesManager.shared.removeFromFavorites(series: model)
    }
    
    init(model: Series) {
        self.model = model
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
