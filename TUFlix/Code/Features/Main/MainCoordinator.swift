import UIKit
import AVKit
import TUFlixKit

class MainCoordinator: Coordinator {
    
    private var splitViewController: UISplitViewController? {
        return rootViewController as? UISplitViewController
    }
    
    private var navigationController: UINavigationController!
    
    init() {
        let episodeViewModel = ListViewModel<Episode, EpisodeViewModel>(resourceProvider: { config in
            return API.Episode.page(with: config)
        }, searchResourceProvider: { (config, searchTerm) in
            return API.Episode.search(for: searchTerm, config: config)
        },
           mapping: EpisodeViewModel.init)
        
        let episodeVC = EpisodeListViewController(title: "Episodes", viewModel: episodeViewModel)
        
        let seriesViewModel = ListViewModel<Series, SeriesViewModel>(resourceProvider: { config in
            return API.Series.page(with: config)
        }, searchResourceProvider: { (config, searchTerm) in
            return API.Series.search(for: searchTerm, config: config)
        },
           mapping: SeriesViewModel.init)
        
        let seriesVC = SeriesListViewController(title: "Series", viewModel: seriesViewModel)
        
        let vc = PageViewController.create(with: [episodeVC, seriesVC])
        navigationController = UINavigationController(rootViewController: vc)
        navigationController.view.backgroundColor = UIColor(named: "primaryColor")!
        var rootViewController: UIViewController = navigationController
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let splitViewController = UISplitViewController()
            splitViewController.viewControllers = [navigationController]
            splitViewController.preferredDisplayMode = .automatic
            rootViewController = splitViewController
        }
        
        super.init(rootViewController: rootViewController)
        
        episodeVC.selectEpisodeClosure = { [unowned self] viewModel in
            self.playEpisode(viewModel)
        }
        
        seriesVC.selectSeriesClosure = { [unowned self] viewModel in
            self.showSeriesDetails(with: viewModel)
        }
    }
    
    func showSeriesDetails(with series: SeriesViewModel) {
        let viewModel = ListViewModel<Episode, EpisodeViewModel>(resourceProvider: { config in
            return API.Series.pageEpisodes(for: series.model.id, config: config)
        }, searchResourceProvider: { (config, _) in
            return API.Series.pageEpisodes(for: series.model.id, config: config)
        }, mapping: EpisodeViewModel.init)
        
        let vc = EpisodeListViewController(title: series.model.title, viewModel: viewModel)
        vc.selectEpisodeClosure = { [unowned self] viewModel in
            self.playEpisode(viewModel)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func playEpisode(_ episode: EpisodeViewModel) {
        
        // Video and audio content available
        if let audio = episode.streamableAudioURL, let video = episode.streamableVideoURL {
            let alert = UIAlertController(title: "Select how you would like to consume the episode", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { [unowned self] _ in
                self.displayPlayerController(with: video)

            }))
            
            alert.addAction(UIAlertAction(title: "Audio", style: .default, handler: { [unowned self] _ in
                self.displayPlayerController(with: audio)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            displayAlert(alert)
        }
        // Only video content available
        else if let single = episode.streamableVideoURL ?? episode.streamableVideoURL {
            displayPlayerController(with: single)
        }
        // No content available
        else {
            let alert = UIAlertController(title: "The selected episode can not be streamed", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            displayAlert(alert)
        }
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
