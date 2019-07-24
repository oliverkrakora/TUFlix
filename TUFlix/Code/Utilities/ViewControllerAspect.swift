//
//  DefferedViewControllerSetup.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.07.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

struct ViewControllerAspect<T: UIViewController> {
    enum Kind: String, CaseIterable {
        case viewDidLoad
        case viewWillAppear
        case viewDidAppear
        case viewWillDisAppear
        case viewDidDisappear
    }
    
    let kind: Kind
    let closure: ((T) -> Void)
    
    init( kind: Kind, _ closure: @escaping ((T) -> Void)) {
        self.kind = kind
        self.closure = closure
    }
}

extension Array where Element == ViewControllerAspect<UIViewController> {
    
    func aspects(for kind: Element.Kind) -> [Element] {
        return filter { $0.kind == kind }
    }
}
