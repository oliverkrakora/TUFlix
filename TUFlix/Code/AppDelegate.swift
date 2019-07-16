import UIKit
import ReactiveSwift
import Fetch
import TUFlixKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Appearance.setup()
        API.setup()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        AppCoordinator.shared.start(window: window!)
        UIApplication.shared.setMinimumBackgroundFetchInterval(Config.seriesCheckInterval)
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
         EpisodeDownloader.shared.backgroundCompletionHandler = completionHandler
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        SeriesManager.shared.checkSubscribedSeriesAction.apply().startWithResult { result in
            switch result {
            case .success(let value):
                let hasNewEpisodes = value.contains(where: { $0.diff > 0 })
                if hasNewEpisodes {
                    SeriesManager.shared.scheduleEpisodeAvailibilityNotifications()
                }
                completionHandler(hasNewEpisodes ? .newData : .noData)
            case .failure:
                completionHandler(.failed)
            }
        }
    }
}
