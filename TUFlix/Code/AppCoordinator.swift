import UIKit
import TUFlixKit
import ReactiveSwift

class AppCoordinator: Coordinator {
    
    static let shared = AppCoordinator()
    
    var window: UIWindow!
    let mainCoordinator = MainCoordinator()
    
    func start(window: UIWindow) {
        self.window = window
        
        mainCoordinator.start()
        addChild(mainCoordinator)
       
        window.rootViewController = mainCoordinator.rootViewController
        window.makeKeyAndVisible()
    }
    
    func reset(animated: Bool) {
        childCoordinators
            .filter { $0 !== mainCoordinator }
            .forEach { removeChild($0) }
        
        mainCoordinator.popToRoot(animated: animated)
    }
}
