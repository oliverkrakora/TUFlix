//
//  EpisodeCoordinator.swift
//  TUFlix
//
//  Created by Oliver Krakora on 26.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import TUFlixKit

class EpisodeCoordinator<T: ListViewModelProtocol>: NavigationCoordinator where T.Item == Episode {
    
    override init(navigationController: UINavigationController = UINavigationController()) {
        super.init(navigationController: navigationController)
    }
}
