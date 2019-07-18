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
    
    private(set) var favoriteEpisodes: [Episode] {
        didSet {
            persistFavorites()
            didChangeObserver.input.send(value: ())
        }
    }
    
    private(set) var offlineEpisodes: [Episode] {
        didSet {
            persistOfflineEpisodes()
            didChangeObserver.input.send(value: ())
        }
    }
    
    private init() {
        self.favoriteEpisodes = {
            return UserDefaults.standard.decode(for: EpisodeManager.favoritesDefaultsKey, decoder: Decoders.standardJSON) ?? []
        }()
        
        self.offlineEpisodes = {
            return UserDefaults.standard.decode(for: EpisodeManager.offlineDefaultsKey, decoder: Decoders.standardJSON) ?? []
        }()
    }
    
    func addToFavorites(episode: Episode) {
        favoriteEpisodes.append(episode)
    }
    
    func removeFromFavorites(episode: Episode) {
        favoriteEpisodes.removeAll(where: { $0.identifier == episode.identifier })
    }
    
    func isInFavorites(episode: Episode) -> Bool {
        return favoriteEpisodes.contains(episode)
    }
    
    private func constructOfflineURL(for episode: Episode) -> URL {
        return episodesDiskLocation.appendingPathExtension("\(episode.identifier).mp4")
    }
    
    func offlineVideoURL(for episode: Episode) -> URL? {
        let videoURL = constructOfflineURL(for: episode)
        guard FileManager.default.fileExists(atPath: videoURL.path) else { return nil }
        
        return videoURL
    }
    
    func removeOfflineEpisode(_ episode: Episode) {
        let videoURL = constructOfflineURL(for: episode)
        guard FileManager.default.fileExists(atPath: videoURL.path) else { return }
        
        try? FileManager.default.removeItem(at: videoURL)
        offlineEpisodes.removeAll(where: { $0.identifier == episode.identifier })
    }
    
    func removeOfflineEpisodes() {
        try? FileManager.default.removeItem(at: episodesDiskLocation)
        offlineEpisodes.removeAll()
    }
    
    func reset() {
        favoriteEpisodes.removeAll()
        removeOfflineEpisodes()
    }
    
    func handleFinishedDownload(download: EpisodeDownloader.Download, currentLocation: URL, callback: @escaping ((Error?) -> Void)) {
        if !FileManager.default.fileExists(atPath: episodesDiskLocation.absoluteString) {
            try? FileManager.default.createDirectory(at: episodesDiskLocation, withIntermediateDirectories: true, attributes: nil)
        }
        
        let destinationURL = constructOfflineURL(for: download.episode)
        do {
            try FileManager.default.moveItem(at: currentLocation, to: destinationURL)
            DispatchQueue.main.async { [weak self] in
                self?.offlineEpisodes.append(download.episode)
                callback(nil)
            }
        } catch {
            DispatchQueue.main.async {
                callback(error)
            }
        }
    }
    
    private func persistFavorites() {
        UserDefaults.standard.encode(favoriteEpisodes, key: EpisodeManager.favoritesDefaultsKey, encoder: Encoders.standardJSON)
    }
    
    private func persistOfflineEpisodes() {
        UserDefaults.standard.encode(offlineEpisodes, key: EpisodeManager.offlineDefaultsKey, encoder: Encoders.standardJSON)
    }
}
