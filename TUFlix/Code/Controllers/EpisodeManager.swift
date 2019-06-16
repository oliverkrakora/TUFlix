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
    
    static let shared = EpisodeManager()
    
    private var favoriteEpisodes = Set<Episode.Id>()
    
    private init() {}
    
    func addToFavorites(episode: Episode.Id) {
        favoriteEpisodes.insert(episode)
    }
    
    func removeFromFavorites(episode: Episode.Id) {
        favoriteEpisodes.remove(episode)
    }
    
    func isInFavorites(episode: Episode.Id) -> Bool {
        return favoriteEpisodes.contains(episode)
    }
}
