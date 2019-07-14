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
    
    struct SeriesCheck: Hashable, Codable {
        let identifier: Series.Id
        let oldTotal: Int
        let newTotal: Int
        let checkDate: Date
        
        var diff: Int {
            return abs(newTotal - oldTotal)
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
    
    private let defaultsKey = "favorite_series"
    
    private let subscribedDefaultsKey = "subscribed_series"
    
    private let subscriptionCheckKey = "subscribed_series_checks"
    
    static let shared = SeriesManager()
    
    private let didChangeObserver = Signal<(), NoError>.pipe()
    
    var didChangeSignal: Signal<(), NoError> {
        return didChangeObserver.output
    }
    
    private(set)var favoriteSeries: [Series] {
        didSet {
            persistFavorites()
            didChangeObserver.input.send(value: ())
        }
    }
    
    private(set)var subscribedSeries: [Series.Id] {
        didSet {
            persistSubscribedSeries()
            didChangeObserver.input.send(value: ())
        }
    }
    
    private(set)var subscriptionChecks: Set<SeriesCheck>
    
    private init() {
        self.favoriteSeries = UserDefaults.standard.decode(for: defaultsKey, decoder: Decoders.standardJSON) ?? []
        self.subscribedSeries = UserDefaults.standard.decode(for: subscribedDefaultsKey, decoder: Decoders.standardJSON) ?? []
        self.subscriptionChecks = UserDefaults.standard.decode(for: subscriptionCheckKey, decoder: Decoders.standardJSON) ?? []
    }
    
    func addToFavorites(series: Series) {
        favoriteSeries.append(series)
    }
    
    func removeFromFavorites(series: Series) {
        favoriteSeries.removeAll(where: { $0.identifier == series.identifier })
        subscribedSeries.removeAll(where: { $0 == series.identifier })
    }
    
    func isInFavorites(series: Series) -> Bool {
        return favoriteSeries.contains(series)
    }
    
    private func persistFavorites() {
        UserDefaults.standard.encode(favoriteSeries, key: defaultsKey, encoder: Encoders.standardJSON)
    }
    
    private func persistSubscribedSeries() {
        UserDefaults.standard.encode(subscribedSeries, key: subscribedDefaultsKey, encoder: Encoders.standardJSON)
    }
    
    private func persistSubscriptionChecks() {
        UserDefaults.standard.encode(subscriptionChecks, key: subscriptionCheckKey, encoder: Encoders.standardJSON)
    }
    
    func performSubscriptionCheck() {
        let requests = subscribedSeries.map { API.Series.pageEpisodes(for: $0, config: .header).requestModel() }
        let combined = SignalProducer.combineLatest(requests)
    }
}
