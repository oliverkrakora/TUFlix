//
//  MainCoordinator.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation

class MainCoordinator: TabBarCoordinator {
    
    func start() {
        let discover = DiscoverCoordinator()
        discover.start()
        let library = LibraryCoordinator()
        library.start()
        let settings = SettingsCoordinator()
        settings.start()
        addChild(discover)
        addChild(library)
        addChild(settings)
        tabBarController.setViewControllers([discover.rootViewController, library.rootViewController, settings.rootViewController], animated: false)
    }
}
