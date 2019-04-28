//
//  LoadingStateView.swift
//  TUFlix
//
//  Created by Oliver Krakora on 28.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import StatefulViewController

class LoadingStateView: UIView, StatefulPlaceholderView {
    
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var insets: UIEdgeInsets = .zero
    
    @discardableResult
    func prepare(with title: String, insets: UIEdgeInsets = .zero) -> LoadingStateView {
        titleLabel.text = title
        self.insets = insets
        return self
    }
    
    func placeholderViewInsets() -> UIEdgeInsets {
        return insets
    }
}
