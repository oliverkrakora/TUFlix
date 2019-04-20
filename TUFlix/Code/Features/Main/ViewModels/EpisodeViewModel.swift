//
//  EpisodeViewModel.swift
//  TUFlix
//
//  Created by Oliver Krakora on 19.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import TUFlixKit
import DataSource

class EpisodeViewModel {
    private let uuid = UUID()
    let model: Episode
    
    var durationInSeconds: TimeInterval? {
        guard let duration = model.mediaPackage?.durationInMs else { return nil }
        guard let number = Int(duration) else { return nil }
        return TimeInterval(number / 1000)
    }
    
    var formattedTitle: String? {
        return model.title
    }
    
    var formattedCreatorName: String? {
        return model.mediaPackage?.creator?.creator
    }
    
    var formattedCreationDate: String? {
        guard let creationDate = model.created else { return nil }
        return Formatters.defaultDateFormatter.string(from: creationDate)
    }
    
    var formattedDuration: String? {
        guard let seconds = durationInSeconds else { return nil }
        return Formatters.timeFormatter.string(from: seconds)
    }
    
    init(model: Episode) {
        self.model = model
    }
}

extension EpisodeViewModel: Diffable {
    
    var diffIdentifier: String {
        return model.id
    }
    
    func isEqualToDiffable(_ other: Diffable?) -> Bool {
        guard let other = other as? EpisodeViewModel else { return false }
        return diffIdentifier == other.diffIdentifier
    }
}
