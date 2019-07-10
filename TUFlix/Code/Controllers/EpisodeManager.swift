//
//  EpisodeManager.swift
//  TUFlix
//
//  Created by Oliver Krakora on 16.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import TUFlixKit
import ReactiveSwift
import Result

class EpisodeManager {
    
    private static let favoritesDefaultsKey = "favorite_episodes"
    
    private static let offlineDefaultsKey = "offline_episodes"
    
    private var episodesDiskLocation: URL {
        let documentsURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return documentsURL.appendingPathComponent("episodes", isDirectory: true)
    }
    
    static let shared = EpisodeManager()
    
    private let didChangeObserver = Signal<(), NoError>.pipe()
    
    var didChangeSignal: Signal<(), NoError> {
        return didChangeObserver.output
    }
    
    private(set) var favoriteEpisodes: Set<Episode> {
        didSet {
            persistFavorites()
            didChangeObserver.input.send(value: ())
        }
    }
    
    private(set) var offlineEpisodes: Set<Episode> {
        didSet {
            persistOfflineEpisodes()
        }
    }
    
    private init() {
        self.favoriteEpisodes = {
             return UserDefaults.standard.decode(for: EpisodeManager.favoritesDefaultsKey, decoder: Decoders.standardJSON) ?? Set()
        }()
        
        self.offlineEpisodes = {
            return UserDefaults.standard.decode(for: EpisodeManager.offlineDefaultsKey, decoder: Decoders.standardJSON) ?? Set()
        }()
    }
    
    func addToFavorites(episode: Episode) {
        favoriteEpisodes.insert(episode)
    }
    
    func removeFromFavorites(episode: Episode) {
        favoriteEpisodes.remove(episode)
    }
    
    func isInFavorites(episode: Episode) -> Bool {
        return favoriteEpisodes.contains(episode)
    }
        
    func offlineVideoURL(for episode: Episode) -> URL? {
        let videoURL = episodesDiskLocation.appendingPathComponent(episode.id)
        guard FileManager.default.fileExists(atPath: videoURL.path) else { return nil }
        
        return videoURL
    }
    
    func removeOfflineEpisode(_ episode: Episode) {
        let videoURL = episodesDiskLocation.appendingPathComponent(episode.id)
        guard FileManager.default.fileExists(atPath: videoURL.path) else { return }
        
        try? FileManager.default.removeItem(at: videoURL)
        offlineEpisodes.remove(episode)
    }
    
    func handleFinishedDownload(download: EpisodeDownloader.Download, currentLocation: URL, callback: ((Error?) -> Void)) {
        if !FileManager.default.fileExists(atPath: episodesDiskLocation.absoluteString) {
            try? FileManager.default.createDirectory(at: episodesDiskLocation, withIntermediateDirectories: true, attributes: nil)
        }
        
        let destinationURL = episodesDiskLocation.appendingPathComponent(download.episode.id)
        do {
            try FileManager.default.moveItem(at: currentLocation, to: destinationURL)
            offlineEpisodes.insert(download.episode)
            callback(nil)
        } catch {
            callback(error)
        }
    }
    
    private func persistFavorites() {
        UserDefaults.standard.encode(favoriteEpisodes, key: EpisodeManager.favoritesDefaultsKey, encoder: Encoders.standardJSON)
    }
    
    private func persistOfflineEpisodes() {
        UserDefaults.standard.encode(offlineEpisodes, key: EpisodeManager.offlineDefaultsKey, encoder: Encoders.standardJSON)
    }
}
