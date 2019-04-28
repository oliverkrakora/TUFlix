//
//  Nibable.swift
//  TUFlix
//
//  Created by Oliver Krakora on 28.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

protocol Nibable {
    static func loadFromNib<T: UIView>(from bundle: Bundle) -> T?
    
    static func loadFromNib<T: UIView>(type: T.Type, bundle: Bundle) -> T?
}

extension UIView: Nibable {
    
    /// Tries to load a view from its nib if possible
    /// - Returns: Nil if there is no such nib
    static func loadFromNib<T: UIView>(from bundle: Bundle = Bundle.main) -> T? {
        guard let nibContent = bundle.loadNibNamed("\(self)", owner: self, options: nil)?.first as? T else { return nil }
        return nibContent
    }
    
    static func loadFromNib<T: UIView>(type: T.Type, bundle: Bundle = Bundle.main) -> T? {
        let view: T? = loadFromNib(from: bundle)
        return view
    }
}
