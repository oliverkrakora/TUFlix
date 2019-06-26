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
    
    private let defaultsKey = "favorite_episodes"
    
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
    
    private init() {
        if let episodes: Set<Episode> = UserDefaults.standard.decode(for: defaultsKey, decoder: Decoders.standardJSON) {
            self.favoriteEpisodes = episodes
        } else {
            self.favoriteEpisodes = Set()
        }
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
    
    private func persistFavorites() {
        UserDefaults.standard.encode(favoriteEpisodes, key: defaultsKey, encoder: Encoders.standardJSON)
    }
}
