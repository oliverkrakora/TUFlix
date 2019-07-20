//
//  PageLoadingStateView.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.07.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import StatefulViewController

class PageLoadingStateView: UIView, StatefulViewController {
    
    var retryClosure: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStatefulViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupStatefulViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // The smallest height possible should be used
        let size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if self.frame.size.height != size.height {
            self.frame.size.height = size.height
            self.setNeedsLayout()
        }
    }
    
    func hasContent() -> Bool {
        return false
    }
    
    private func setupStatefulViews() {
        loadingView = LoadingStateView.load()?.prepare(with: nil, insets: .zero)
        errorView = ErrorStateView.load()?.prepare(with: L10n.Global.ErrorState.title, subtitle: L10n.Global.retryTapTitle, insets: .zero, retryClosure: { [weak self] in
            self?.retryClosure?()
        })
    }
}
