import UIKit
import TUFlixKit
import ReactiveSwift

class AppCoordinator: Coordinator {
    
    static let shared = AppCoordinator()
    
    var window: UIWindow!
    let mainCoordinator = MainCoordinator()
    
    func start(window: UIWindow) {
        self.window = window
        
        addChild(mainCoordinator)
        mainCoordinator.start()
       
        window.rootViewController = mainCoordinator.rootViewController
        window.makeKeyAndVisible()
    }
}
