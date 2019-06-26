import UIKit
import AVKit
import TUFlixKit

class DiscoverCoordinator: Coordinator {
    
    private var splitViewController: UISplitViewController? {
        return rootViewController as? UISplitViewController
    }
    
    private var navigationController: UINavigationController!
    
    init() {
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
        
        let vc = PageViewController.create(with: [episodeVC, seriesVC])
        navigationController = UINavigationController(rootViewController: vc)
        var rootViewController: UIViewController = navigationController
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let splitViewController = UISplitViewController()
            splitViewController.viewControllers = [navigationController]
            splitViewController.preferredDisplayMode = .automatic
            rootViewController = splitViewController
        }
        
        rootViewController.tabBarItem.title = L10n.Browse.title
        
        super.init(rootViewController: rootViewController)
        
        episodeVC.selectEpisodeClosure = { [unowned self] viewModel in
            self.playEpisode(viewModel)
        }
        
        seriesVC.selectSeriesClosure = { [unowned self] viewModel in
            self.showSeriesDetails(with: viewModel)
        }
    }
    
    func showSeriesDetails(with series: SeriesViewModel) {
        let viewModel = SearchablePageListViewModel<SearchResult<Episode>, EpisodeViewModel>(resourceProvider: { config in
            return API.Series.pageEpisodes(for: series.model.id, config: config)
        }, searchResourceProvider: { (config, _) in
            return API.Series.pageEpisodes(for: series.model.id, config: config)
        }, mapping: EpisodeViewModel.init)
        
        let vc = EpisodeListViewController(title: series.model.title, viewModel: viewModel, displayEpisodeNames: true)
        vc.selectEpisodeClosure = { [unowned self] viewModel in
            self.playEpisode(viewModel)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func playEpisode(_ episode: EpisodeViewModel) {
        guard let videoURL = episode.streamableVideoURL else {
            let alert = UIAlertController(title: L10n.Episodes.PlayUnavailable.title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: L10n.Global.Ok.title, style: .cancel, handler: nil))
            displayAlert(alert)
            return
        }
        displayPlayerController(with: videoURL)
    }
    
    private func displayAlert(_ alert: UIAlertController) {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            navigationController.present(alert, animated: true, completion: nil)
            return
        }
        
        let navigationFrame = navigationController.view.frame
        
        let anchorRect = CGRect(origin: CGPoint(x: 0, y: navigationFrame.maxY), size: CGSize(width: navigationFrame.width, height: 0))
        alert.popoverPresentationController?.sourceRect = anchorRect
        alert.popoverPresentationController?.sourceView = navigationController.view
        rootViewController.present(alert, animated: true, completion: nil)
    }
    
    private func displayPlayerController(with url: URL) {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        
        if let splitViewController = splitViewController {
            splitViewController.showDetailViewController(controller, sender: nil)
        } else {
            navigationController.present(controller, animated: true, completion: nil)
        }
    }
}
