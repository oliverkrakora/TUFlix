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
    
    var formattedTitle: String? {
        return model.title
    }
    
    var formattedCreator: String? {
        return model.creator
    }
    
    var formattedContributor: String? {
        return model.contributor
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
