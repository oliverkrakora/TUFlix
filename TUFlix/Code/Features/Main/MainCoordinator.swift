import UIKit

class MainCoordinator: NavigationCoordinator {
    
    func start() {
        let vc = MainViewController.create()
        vc.showSeriesDetails = { [unowned self] series in
            self.showSeriesDetails(with: series)
        }
        push(vc, animated: false)
    }
    
    func showSeriesDetails(with series: SeriesViewModel) {
        let vc = SeriesDetailViewController.create(with: series)
        push(vc, animated: true)
    }
}
