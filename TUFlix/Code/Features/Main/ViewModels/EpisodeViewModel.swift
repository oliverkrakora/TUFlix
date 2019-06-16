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

struct EpisodeViewModel {
    let model: Episode
        
    var durationInSeconds: TimeInterval? {
        guard let duration = model.mediaPackage?.durationInMs else { return nil }
        guard let number = Int(duration) else { return nil }
        return TimeInterval(number / 1000)
    }
    
    var isFavorite: Bool {
        return EpisodeManager.shared.isInFavorites(episode: model.id)
    }
    
    var formattedTitle: String? {
        return model.title
    }
    
    var streamableVideoURL: URL? {
        return model.mediaPackage?.media?.tracks?.first(where: { $0.mimeType == .mp4 })?.url
    }
    
    var streamableAudioURL: URL? {
        return model.mediaPackage?.media?.tracks?.first(where: { $0.mimeType == .mpeg })?.url
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
    
    func likeEpisode() {
        EpisodeManager.shared.addToFavorites(episode: model.id)
    }
    
    func unlikeEpisode() {
        EpisodeManager.shared.removeFromFavorites(episode: model.id)
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
