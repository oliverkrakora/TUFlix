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
import UserNotifications

class SeriesManager {
    
    struct SeriesCheck: Hashable, Codable {
        let identifier: Series.Id
        private(set)var oldTotal: Int
        private(set)var newTotal: Int
        private(set)var checkDate: Date
        var wasSeen: Bool
        
        var diff: Int {
            return abs(newTotal - oldTotal)
        }
        
        mutating func update(with newTotal: Int) {
            self.oldTotal = self.newTotal
            self.newTotal = newTotal
            self.checkDate = Date()
            self.wasSeen = false
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
    
    private(set)var seriesChecks: Set<SeriesCheck> {
        didSet {
            persistSubscriptionChecks()
            didChangeObserver.input.send(value: ())
        }
    }
    
    var numberOfSeriesWithNewEpisodes: Int {
        return seriesChecks.filter { $0.diff > 0 || Environment.current() == .debug }.count
    }
    
    private init() {
        self.favoriteSeries = UserDefaults.standard.decode(for: defaultsKey, decoder: Decoders.standardJSON) ?? []
        self.subscribedSeries = UserDefaults.standard.decode(for: subscribedDefaultsKey, decoder: Decoders.standardJSON) ?? []
        self.seriesChecks = UserDefaults.standard.decode(for: subscriptionCheckKey, decoder: Decoders.standardJSON) ?? []
    }
    
    func hasNewEpisodesAvailable(series: Series.Id) -> Bool {
        return seriesChecks.contains(where: { $0.identifier == series })
    }
    
    func addToFavorites(series: Series) {
        favoriteSeries.append(series)
    }
    
    func subscribe(for series: Series.Id) {
        subscribedSeries.append(series)
    }
    
    func unsubscribe(for series: Series.Id) {
        subscribedSeries.removeAll(where: { $0 == series })
    }
    
    func isSubscribed(for series: Series.Id) -> Bool {
        return subscribedSeries.contains(series)
    }
    
    func removeFromFavorites(series: Series) {
        favoriteSeries.removeAll(where: { $0.identifier == series.identifier })
        subscribedSeries.removeAll(where: { $0 == series.identifier })
        if let index = seriesChecks.firstIndex(where: { $0.identifier == series.identifier }) {
            seriesChecks.remove(at: index)
        }
    }
    
    func isInFavorites(series: Series) -> Bool {
        return favoriteSeries.contains(series)
    }
    
    func reset() {
        favoriteSeries.removeAll()
        subscribedSeries.removeAll()
        seriesChecks.removeAll()
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
    
    lazy var checkSubscribedSeriesAction: Action<(), Set<SeriesCheck>, Error> = {
        return Action { [unowned self] _ in
            var existingChecks = self.seriesChecks
            
            let requests = self.subscribedSeries.map { seriesId in
                API.Series.pageEpisodes(for: seriesId, config: .header).requestModel().map { [weak self] pageResult in
                    
                    if var existingCheck = self?.seriesChecks.first(where: { $0.identifier == seriesId }) {
                        existingCheck.update(with: pageResult.total)
                        existingChecks.insert(existingCheck)
                    } else {
                        let check = SeriesCheck(identifier: seriesId, oldTotal: pageResult.total, newTotal: pageResult.total, checkDate: Date(), wasSeen: false)
                        existingChecks.insert(check)
                    }
                }
            }
            
            return SignalProducer.combineLatest(requests)
                .map { _ in return existingChecks }
                .mapError { $0 as Error }
                .on { [weak self] seriesChecks in
                    self?.seriesChecks = seriesChecks
                }
        }
    }()
    
    func scheduleEpisodeAvailibilityNotification() {
        let seriesWithNewContent = seriesChecks
            .filter { $0.diff > 0 || Environment.current() == .debug } // Get only series that have new episodes
        
        let content = UNMutableNotificationContent()
        content.title = L10n.Series.newEpisodesAvailableTitle
        content.body = L10n.Series.newEpisodesAvailableSubtitle(seriesWithNewContent.count)
        
        let request = UNNotificationRequest(identifier: "newEpisodes", content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false))
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification with error \(error)")
            }
        }
    }
}
