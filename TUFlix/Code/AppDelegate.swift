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
        
        return true
    }
    
    func applicationWillResignActive(_: UIApplication) {
    }

    func applicationDidEnterBackground(_: UIApplication) {
    }

    func applicationWillEnterForeground(_: UIApplication) {
    }

    func applicationDidBecomeActive(_: UIApplication) {
    }

    func applicationWillTerminate(_: UIApplication) {
    }
}
