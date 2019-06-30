//
//  SettingsCoordinator.swift
//  TUFlix
//
//  Created by Oliver Krakora on 30.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class SettingsCoordinator: NavigationCoordinator {
    
    func start() {
        rootViewController.tabBarItem.title = L10n.Settings.title
        rootViewController.tabBarItem.image = Asset.settingsIcon.image
        push(SettingsViewController(), animated: false)
    }
}
