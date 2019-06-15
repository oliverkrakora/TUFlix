//
//  ScrollViewPagingHandler.swift
//  TUFlix
//
//  Created by Oliver Krakora on 13.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

struct ScrollViewPagingHandler {
    
    typealias ShouldLoadCallback = (() -> Bool)
    
    typealias LoadCallback = (() -> Void)
    
    let scrollingThreshold: Double
    
    let loadClosure: LoadCallback
    
    init(threshold: Double, loadClosure: @escaping LoadCallback) {
        self.scrollingThreshold = threshold
        self.loadClosure = loadClosure
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offsetableHeight: CGFloat {
            if scrollView.contentSize.height <= scrollView.frame.height {
                return 0
            }
            return scrollView.contentSize.height - scrollView.frame.height
        }
        
        let hasReachedThreshold = scrollView.contentOffset.y >= (offsetableHeight * CGFloat(scrollingThreshold))
        let contentSmallerThanScrollView = offsetableHeight == 0
        
        if contentSmallerThanScrollView || hasReachedThreshold {
            loadClosure()
        }
    }
}
