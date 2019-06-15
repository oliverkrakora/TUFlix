//
//  UIView+Nib.swift
//  Toolsense
//
//  Created by Oliver Krakora on 07.02.19.
//  Copyright © 2019 aaa - all about apps Gmbh. All rights reserved.
//

import UIKit

protocol Nibable: UIView {
    static func load(from bundle: Bundle) -> Self?
}

extension UIView: Nibable {
    
    /// Tries to load a view from its nib if possible
    /// - Parameter bundle: The bundle from where to load the nib
    /// - Returns: Nil if there is no such nib
    static func load(from bundle: Bundle = Bundle.main) -> Self? {
        return loadFromNib(type: self, from: bundle)
    }
    
    private static func loadFromNib<T>(type: T.Type, from bundle: Bundle = Bundle.main) -> T? {
        return bundle.loadNibNamed("\(type)", owner: self, options: nil)?.first as? T
    }
}
