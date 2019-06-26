//
//  SeriesManager.swift
//  TUFlix
//
//  Created by Oliver Krakora on 24.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import ReactiveSwift
import TUFlixKit
import Result

class SeriesManager {
    
    private let defaultsKey = "favorite_series"
    
    static let shared = SeriesManager()
    
    private let didChangeObserver = Signal<(), NoError>.pipe()
    
    var didChangeSignal: Signal<(), NoError> {
        return didChangeObserver.output
    }
    
    private(set) var favoriteSeries: Set<Series> {
        didSet {
            persistFavorites()
            didChangeObserver.input.send(value: ())
        }
    }
    
    private init() {
        if let episodes: Set<Series> = UserDefaults.standard.decode(for: defaultsKey, decoder: Decoders.standardJSON) {
            self.favoriteSeries = episodes
        } else {
            self.favoriteSeries = Set()
        }
    }
    
    func addToFavorites(series: Series) {
        favoriteSeries.insert(series)
    }
    
    func removeFromFavorites(series: Series) {
        favoriteSeries.remove(series)
    }
    
    func isInFavorites(series: Series) -> Bool {
        return favoriteSeries.contains(series)
    }
    
    private func persistFavorites() {
        UserDefaults.standard.encode(favoriteSeries, key: defaultsKey, encoder: Encoders.standardJSON)
    }
}
