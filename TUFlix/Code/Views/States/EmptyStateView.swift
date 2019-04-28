//
//  EmptyStateView.swift
//  TUFlix
//
//  Created by Oliver Krakora on 28.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import StatefulViewController

class EmptyStateView: UIView, StatefulPlaceholderView {
    
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var subtitleLabel: UILabel!
    
    private var insets: UIEdgeInsets = .zero
    
    @discardableResult
    func prepare(with title: String, subtitle: String? = nil, insets: UIEdgeInsets = .zero) -> EmptyStateView {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        self.insets = insets
        return self
    }
    
    func placeholderViewInsets() -> UIEdgeInsets {
        return insets
    }
}
