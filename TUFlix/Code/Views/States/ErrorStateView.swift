//
//  ErrorStateView.swift
//  TUFlix
//
//  Created by Oliver Krakora on 28.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import StatefulViewController

class ErrorStateView: UIView, StatefulPlaceholderView {
    
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var retryButton: UIButton!
    
    private var retryClosure: (() -> Void)?
    
    private var insets: UIEdgeInsets = .zero
    
    @discardableResult
    func prepare(with title: String, insets: UIEdgeInsets = .zero, retryClosure: (() -> Void)? = nil) -> ErrorStateView {
        self.titleLabel.text = title
        self.insets = insets
        self.retryClosure = retryClosure
        self.retryButton.isHidden = retryClosure == nil
        return self
    }
    
    @IBAction private func retry(_ sender: Any) {
        retryClosure?()
    }
}
