//
//  LibraryCoordinator.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import TUFlixKit

class LibraryCoordinator: NavigationCoordinator {
    
    func start() {
        let libraryVC = LibraryViewController(title: L10n.Library.title, viewModel: LibraryListViewModel())
        libraryVC.showFavoriteEpisodes = { [unowned self] in
            self.showFavoriteEpisodes()
        }
        
        libraryVC.showFavoriteSeries = { [unowned self] in
            self.showFavoriteSeries()
        }
        
        navigationController.setViewControllers([libraryVC], animated: false)
        navigationController.tabBarItem.title = libraryVC.tabBarItem.title
        navigationController.tabBarItem.image = Asset.libraryIcon.image
    }
    
    private func showFavoriteEpisodes() {
        let viewModel = LibraryEpisodeListViewModel()
        
        let vc = EpisodeListViewController(title: L10n.Episodes.title, viewModel: viewModel)
        vc.selectEpisodeClosure = { [unowned self] episode in
            PlaybackCoordinator.playModally(on: self.rootViewController, url: episode.streamableVideoURL)
        }
        push(vc, animated: true)
    }
    
    private func showFavoriteSeries() {
        let viewModel = LibrarySeriesListViewModel()
        let vc = SeriesListViewController(title: L10n.Series.title, viewModel: viewModel)
        vc.selectSeriesClosure = { [unowned self] series in
            self.showSeries(series)
        }
        push(vc, animated: true)
    }
    
    private func showSeries(_ series: SeriesViewModel) {
        let viewModel = SearchablePageListViewModel<SearchResult<Episode>, EpisodeViewModel>(resourceProvider: { config in
            return API.Series.pageEpisodes(for: series.model.id, config: config)
        }, searchResourceProvider: { (config, term) in
            return API.Episode.search(for: term, seriesId: series.model.id, config: config)
        }, mapping: EpisodeViewModel.init)
        
        let displayEpisodeNames = !Settings.shared.preferDateOverTitleInSeries
        
        let allSeriesEpisodesVC = EpisodeListViewController(title: L10n.Episodes.allTitle, viewModel: viewModel, displayEpisodeNames: displayEpisodeNames)
        
        allSeriesEpisodesVC.selectEpisodeClosure = { [unowned self] episode in
            PlaybackCoordinator.playModally(on: self.rootViewController, url: episode.streamableVideoURL)
        }
        
        let likeEpisodesViewModel = LibraryEpisodeListViewModel(series: series.model.id)
        
        let likedSeriesEpisodeVC = EpisodeListViewController(title: L10n.Episodes.likedTitle, viewModel: likeEpisodesViewModel, displayEpisodeNames: displayEpisodeNames)
        
        likedSeriesEpisodeVC.selectEpisodeClosure = { [unowned self] episode in
            PlaybackCoordinator.playModally(on: self.rootViewController, url: episode.streamableVideoURL)
        }
        
        let pageVC = PageViewController.create(with: [likedSeriesEpisodeVC, allSeriesEpisodesVC])
        pageVC.toolbar = {
            return ToggleToolbar(title: L10n.Episodes.toggleTitle, isOn: displayEpisodeNames) { isOn in
                likedSeriesEpisodeVC.toggleEpisodeNames(showNames: isOn)
                allSeriesEpisodesVC.toggleEpisodeNames(showNames: isOn)
            }
        }()
        
        push(pageVC, animated: true)
    }
}
