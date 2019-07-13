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
import ReactiveSwift
import Result

class EpisodeViewModel {
    
    let model: Episode
    
    var durationInSeconds: TimeInterval? {
        guard let duration = model.mediaPackage?.durationInMs else { return nil }
        guard let number = Int(duration) else { return nil }
        return TimeInterval(number / 1000)
    }
    
    var favoriteStatusDidChange: Signal<(), NoError> {
        return EpisodeManager.shared.didChangeSignal
    }
    
    var isAvailableOffline: Bool {
        return EpisodeManager.shared.offlineVideoURL(for: model) != nil
    }
    
    var isDownloading: Bool {
        return EpisodeDownloader.shared.download(for: model.id) != nil
    }
    
    var isFavorite: Bool {
        return EpisodeManager.shared.isInFavorites(episode: model)
    }
    
    var formattedTitle: String? {
        return model.title
    }
    
    var playableVideoURL: URL? {
        return offlineVideoURL ?? streamableVideoURL
    }
    
    var streamableVideoURL: URL? {
        return model.mediaPackage?.media?.tracks?.first(where: { $0.mimeType == .mp4 })?.url
    }
    
    var offlineVideoURL: URL? {
        return EpisodeManager.shared.offlineVideoURL(for: model)
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
        EpisodeManager.shared.addToFavorites(episode: model)
    }
    
    func unlikeEpisode() {
        EpisodeManager.shared.removeFromFavorites(episode: model)
    }
    
    func download() -> Bool {
        guard let url = streamableVideoURL else { return false }
        
        EpisodeDownloader.shared.download(episode: model, url: url)
        return true
    }
    
    func cancelDownload() {
        EpisodeDownloader.shared.cancelDownload(for: model.id)
    }
    
    func delete() {
        EpisodeManager.shared.removeOfflineEpisode(model)
    }
    
    func matches(searchTerm: String?) -> Bool {
        guard let searchTerm = searchTerm?.lowercased(), !searchTerm.isEmpty else { return true }
        
        return (model.title?.lowercased().contains(searchTerm) ?? false)
            || (formattedCreatorName?.lowercased().contains(searchTerm) ?? false)
            || (formattedCreationDate?.lowercased().contains(searchTerm) ?? false)
    }
}

extension EpisodeViewModel: Diffable {
    
    var diffIdentifier: String {
        return model.id
    }
    
    func isEqualToDiffable(_ other: Diffable?) -> Bool {
        guard let other = other as? EpisodeViewModel else { return false }
        return model == other.model
    }
}
