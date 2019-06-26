//
//  LibraryCoordinator.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class LibraryCoordinator: NavigationCoordinator {
    
    func start() {
        let libraryVC = LibraryViewController(title: L10n.Library.title, viewModel: LibraryItemListViewModel())
        libraryVC.showFavoriteEpisodes = { [unowned self] in
            self.showFavoriteEpisodes()
        }
        
        libraryVC.showFavoriteSeries = { [unowned self] in
            self.showFavoriteSeries()
        }
        
        navigationController.setViewControllers([libraryVC], animated: false)
        navigationController.tabBarItem.title = libraryVC.tabBarItem.title
    }
    
    private func showFavoriteEpisodes() {
        let viewModel = LibraryEpisodeListViewModel()
        let vc = EpisodeListViewController(title: L10n.Episodes.title, viewModel: viewModel)
        push(vc, animated: true)
    }
    
    private func showFavoriteSeries() {
        let viewModel = LibrarySeriesListViewModel()
        let vc = SeriesListViewController(title: L10n.Series.title, viewModel: viewModel)
        push(vc, animated: true)
    }
}
