import UIKit
import TUFlixKit

class DiscoverCoordinator: NavigationCoordinator {
    
    func start() {
        let episodeVC = Builder.ViewController.episodeListViewController()
        let seriesVC = Builder.ViewController.seriesListViewController { [unowned self] viewModel in
            self.showSeriesDetails(with: viewModel)
        }
        
        rootViewController.tabBarItem.title = L10n.Browse.title
        rootViewController.tabBarItem.image = Asset.discoverIcon.image
        
        let vc = PageViewController.create(with: [episodeVC, seriesVC])
        navigationController.setViewControllers([vc], animated: false)

    }
    
    func showSeriesDetails(with series: SeriesViewModel) {
        let vc = Builder.ViewController.episodeListViewController(title: series.model.title, seriesId: series.model.id, showEpisodeNameToggle: true, showEpisodesNames: !Settings.shared.preferDateOverTitleInSeries)
    
        navigationController.pushViewController(vc, animated: true)
    }
}
