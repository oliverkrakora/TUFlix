import UIKit
import TUFlixKit

class DiscoverCoordinator: NavigationCoordinator {
    
    func start() {
        let episodeViewModel = SearchablePageListViewModel<SearchResult<Episode>, EpisodeViewModel>(resourceProvider: { config in
            return API.Episode.page(with: config)
        }, searchResourceProvider: { (config, searchTerm) in
            return API.Episode.search(for: searchTerm, config: config)
        },
           mapping: EpisodeViewModel.init)
        
        let episodeVC = EpisodeListViewController(title: L10n.Episodes.title, viewModel: episodeViewModel)
        
        let seriesViewModel = SearchablePageListViewModel<SearchResult<Series>, SeriesViewModel>(resourceProvider: { config in
            return API.Series.page(with: config)
        }, searchResourceProvider: { (config, searchTerm) in
            return API.Series.search(for: searchTerm, config: config)
        },
           mapping: SeriesViewModel.init)
        
        let seriesVC = SeriesListViewController(title: L10n.Series.title, viewModel: seriesViewModel)
        
        rootViewController.tabBarItem.title = L10n.Browse.title
        rootViewController.tabBarItem.image = Asset.discoverIcon.image
        
        episodeVC.selectEpisodeClosure = { [unowned self] viewModel in
            PlaybackCoordinator.playModally(on: self.rootViewController, url: viewModel.playableVideoURL)
        }
        
        seriesVC.selectSeriesClosure = { [unowned self] viewModel in
            self.showSeriesDetails(with: viewModel)
        }
        
        let vc = PageViewController.create(with: [episodeVC, seriesVC])
        navigationController.setViewControllers([vc], animated: false)

    }
    
    func showSeriesDetails(with series: SeriesViewModel) {
        let viewModel = SearchablePageListViewModel<SearchResult<Episode>, EpisodeViewModel>(resourceProvider: { config in
            return API.Series.pageEpisodes(for: series.model.id, config: config)
        }, searchResourceProvider: { (config, term) in
            return API.Episode.search(for: term, seriesId: series.model.id, config: config)
        }, mapping: EpisodeViewModel.init)
    
        let vc = EpisodeListViewController(title: series.model.title, viewModel: viewModel, displayEpisodeNames: !Settings.shared.preferDateOverTitleInSeries)
        vc.toolbar.isHidden = false
        vc.selectEpisodeClosure = { [unowned self] viewModel in
            PlaybackCoordinator.playModally(on: self.rootViewController, url: viewModel.playableVideoURL)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
}
