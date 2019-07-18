//
//  LibraryCoordinator.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import TUFlixKit
import ReactiveSwift

class LibraryCoordinator: NavigationCoordinator {
    
    private var disposable: Disposable?
    
    func start() {
        let libraryVC = LibraryViewController()
        libraryVC.title = L10n.Library.title
        
        libraryVC.showFavoriteEpisodes = { [unowned self] in
            self.showFavoriteEpisodes()
        }
        
        libraryVC.showFavoriteSeries = { [unowned self] in
            self.showFavoriteSeries()
        }
        
        navigationController.setViewControllers([libraryVC], animated: false)
        navigationController.tabBarItem.title = libraryVC.tabBarItem.title
        navigationController.tabBarItem.image = Asset.libraryIcon.image
        setupBindings()
        updateBadgeCount()
    }
    
    deinit {
        disposable?.dispose()
    }
    
    private func setupBindings() {
        disposable = SeriesManager.shared.didChangeSignal.observeValues { [weak self] _ in
            self?.updateBadgeCount()
        }
    }
    
    private func updateBadgeCount() {
        let count = SeriesManager.shared.numberOfSeriesWithNewEpisodes
        
        if count > 0 {
            navigationController.tabBarItem.badgeValue = Formatters.numberFormatter.string(from: SeriesManager.shared.numberOfSeriesWithNewEpisodes as NSNumber)
        } else {
            navigationController.tabBarItem.badgeValue = nil
        }
    }
    
    private func showFavoriteEpisodes() {
        let viewModel = LibraryEpisodeListViewModel()
        let vc = Builder.ViewController.episodeListViewController(title: L10n.Episodes.likedTitle,
                                                                  viewModel: viewModel)
        
        let offlineViewModel = LibraryOfflineEpisodeListViewModel(series: nil)
        let offlineVC = Builder.ViewController.episodeListViewController(title: L10n.Episodes.AvailableOffline.title,
                                                                         viewModel: offlineViewModel)
        
        let pageVC = PageViewController.create(with: [vc, offlineVC])
        push(pageVC, animated: true)
    }
    
    private func showFavoriteSeries() {
        let viewModel = LibrarySeriesListViewModel()
        let vc = Builder.ViewController.seriesListViewController(viewModel: viewModel) { [unowned self] viewModel in
            self.showSeries(viewModel)
        }
        push(vc, animated: true)
    }
    
    private func showSeries(_ series: SeriesViewModel) {
        let displayEpisodeNames = !Settings.shared.preferDateOverTitleInSeries
        
        let allVC = Builder.ViewController.episodeListViewController(title: L10n.Episodes.allTitle,
                                                                     seriesId: series.model.identifier,
                                                                     showEpisodeNameToggle: false,
                                                                     showEpisodesNames: displayEpisodeNames)
        
        let likedViewModel = LibraryEpisodeListViewModel(series: series.model.identifier)
        
        let likedVC = Builder.ViewController.episodeListViewController(title: L10n.Episodes.likedTitle,
                                                                       viewModel: likedViewModel,
                                                                       showEpisodeNameToggle: false,
                                                                       showEpisodesNames: displayEpisodeNames)
        
        let offlineViewModel = LibraryOfflineEpisodeListViewModel(series: series.model.identifier)
        
        let offlineVC = Builder.ViewController.episodeListViewController(title: L10n.Episodes.AvailableOffline.title,
                                                                         viewModel: offlineViewModel,
                                                                         showEpisodeNameToggle: false,
                                                                         showEpisodesNames: displayEpisodeNames)
    
        let pageVC = PageViewController.create(with: [likedVC, offlineVC, allVC])
        
        pageVC.toolbar = {
            return ToggleToolbar(title: L10n.Episodes.toggleTitle, isOn: displayEpisodeNames) { isOn in
                likedVC.toggleEpisodeNames(showNames: isOn)
                allVC.toggleEpisodeNames(showNames: isOn)
                offlineVC.toggleEpisodeNames(showNames: isOn)
            }
        }()
        
        push(pageVC, animated: true)
    }
}
