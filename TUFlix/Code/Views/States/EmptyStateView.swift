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
    
    @IBOutlet private var stackView: UIStackView!
    
    private var insets: UIEdgeInsets = .zero
    
    private var retry: (() -> Void)?
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        return tap
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if tapRecognizer.view == nil {
            addGestureRecognizer(tapRecognizer)
        }
    }
    
    @discardableResult
    func prepare(with title: String, subtitle: String? = nil, insets: UIEdgeInsets = .zero, retryClosure: (() -> Void)?) -> EmptyStateView {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        self.insets = insets
        self.retry = retryClosure
        return self
    }
    
    @objc private func didTap() {
        retry?()
    }
    
    func placeholderViewInsets() -> UIEdgeInsets {
        return insets
    }
}
