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
        private(set)var oldTotal: Int
        private(set)var newTotal: Int
        private(set)var checkDate: Date
        
        var diff: Int {
            return abs(newTotal - oldTotal)
        }
        
        mutating func update(with newTotal: Int) {
            self.oldTotal = self.newTotal
            self.newTotal = newTotal
            self.checkDate = Date()
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
    
    private let defaultsKey = "favorite_series"
    
    private let subscribedDefaultsKey = "subscribed_series"
    
    private let subscriptionCheckKey = "subscribed_series_checks"
    
    static let shared = SeriesManager()
    
    private var checkDisposable: Disposable?
    
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
    
    private(set)var seriesChecks: Set<SeriesCheck>
    
    private init() {
        self.favoriteSeries = UserDefaults.standard.decode(for: defaultsKey, decoder: Decoders.standardJSON) ?? []
        self.subscribedSeries = UserDefaults.standard.decode(for: subscribedDefaultsKey, decoder: Decoders.standardJSON) ?? []
        self.seriesChecks = UserDefaults.standard.decode(for: subscriptionCheckKey, decoder: Decoders.standardJSON) ?? []
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
        UserDefaults.standard.encode(seriesChecks, key: subscriptionCheckKey, encoder: Encoders.standardJSON)
    }
    
    func performSubscriptionCheck() {
        guard checkDisposable?.isDisposed ?? true else { return }
        
        let requests = subscribedSeries.map { seriesId in
            API.Series.pageEpisodes(for: seriesId, config: .header).requestModel().map { [weak self] pageResult in
                if var check = self?.seriesChecks.first(where: { $0.identifier == seriesId }) {
                    check.update(with: pageResult.total)
                    self?.seriesChecks.insert(check)
                } else {
                    let check = SeriesCheck(identifier: seriesId, oldTotal: pageResult.total, newTotal: pageResult.total, checkDate: Date())
                    self?.seriesChecks.insert(check)
                }
            }
        }
        checkDisposable = SignalProducer.combineLatest(requests).start()
    }
}
