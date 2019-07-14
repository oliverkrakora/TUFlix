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
    
    private(set) var favoriteSeries: [Series] {
        didSet {
            persistFavorites()
            didChangeObserver.input.send(value: ())
        }
    }
    
    private init() {
        self.favoriteSeries = UserDefaults.standard.decode(for: defaultsKey, decoder: Decoders.standardJSON) ?? []
    }
    
    func addToFavorites(series: Series) {
        favoriteSeries.append(series)
    }
    
    func removeFromFavorites(series: Series) {
        favoriteSeries.removeAll(where: { $0.id == series.id })
    }
    
    func isInFavorites(series: Series) -> Bool {
        return favoriteSeries.contains(series)
    }
    
    private func persistFavorites() {
        UserDefaults.standard.encode(favoriteSeries, key: defaultsKey, encoder: Encoders.standardJSON)
    }
}
