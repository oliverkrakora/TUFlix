import UIKit
import AVKit

class MainCoordinator: Coordinator {
    
    private var splitViewController: UISplitViewController? {
        return rootViewController as? UISplitViewController
    }
    
    private var navigationController: UINavigationController!
    
    init() {
        let vc = MainViewController.create()
        navigationController = UINavigationController(rootViewController: vc)
        var rootViewController: UIViewController = navigationController
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let splitViewController = UISplitViewController()
            splitViewController.viewControllers = [navigationController]
            splitViewController.preferredDisplayMode = .automatic
            rootViewController = splitViewController
        }
        
        super.init(rootViewController: rootViewController)
        
        vc.showSeriesDetails = { [unowned self] series in
            self.showSeriesDetails(with: series)
        }
        
        vc.playEpisode = { [unowned self] episode in
            self.playEpisode(episode)
        }
    }
    
    func showSeriesDetails(with series: SeriesViewModel) {
        let vc = SeriesDetailViewController.create(with: series)
        vc.playEpisode = { [unowned self] episode in
            self.playEpisode(episode)
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
