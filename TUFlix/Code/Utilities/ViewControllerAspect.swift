//
//  DefferedViewControllerSetup.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.07.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

enum ViewControllerAspect<T: UIViewController> {
    case viewDidLoad(((T) -> Void))
    case viewWillAppear((T) -> Void)
    case viewDidAppear((T) -> Void)
    case viewWillDisAppear((T) -> Void)
    case viewDidDisAppear((T) -> Void)
}
