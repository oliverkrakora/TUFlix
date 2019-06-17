//
//  EpisodeManager.swift
//  TUFlix
//
//  Created by Oliver Krakora on 16.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import TUFlixKit

class EpisodeManager {
    
    private let defaultsKey = "favorite_episodes"
    
    static let shared = EpisodeManager()
    
    private var favoriteEpisodes: Set<Episode.Id> {
        didSet {
            persistFavorites()
        }
    }
    
    private init() {
        if let episodes: Set<Episode.Id> = UserDefaults.standard.decode(for: defaultsKey, decoder: Decoders.standardJSON) {
            self.favoriteEpisodes = episodes
        } else {
            self.favoriteEpisodes = Set()
        }
    }
    
    func addToFavorites(episode: Episode.Id) {
        favoriteEpisodes.insert(episode)
    }
    
    func removeFromFavorites(episode: Episode.Id) {
        favoriteEpisodes.remove(episode)
    }
    
    func isInFavorites(episode: Episode.Id) -> Bool {
        return favoriteEpisodes.contains(episode)
    }
    
    private func persistFavorites() {
        UserDefaults.standard.encode(favoriteEpisodes, key: defaultsKey, encoder: Encoders.standardJSON)
    }
}
