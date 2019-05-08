//
//  PagedScrollViewHelper.swift
//  TUFlix
//
//  Created by Oliver Krakora on 27.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class PagedScrollViewHelper {
    
    enum PageOffset {
        case relative(CGFloat)
    }
    
    let pageAtOffset: PageOffset
    
    let rateInterval: TimeInterval
    
    private var nextAllowedRefresh = Date()
    
    init(pageOffset: PageOffset, rateInterval: TimeInterval = 5.0) {
        self.pageAtOffset = pageOffset
        self.rateInterval = rateInterval
    }
    
    func shouldLoadNextPage(for scrollView: UIScrollView) -> Bool {
        switch pageAtOffset {
        case .relative(let value):
            guard Date() > nextAllowedRefresh else { return false }
            
            let adjustedContentSize = abs(scrollView.contentSize.height - scrollView.bounds.height)
            let shouldLoad = (scrollView.contentOffset.y / adjustedContentSize) > value
        
            if shouldLoad {
                nextAllowedRefresh = Date(timeIntervalSinceNow: rateInterval)
            }
            
            return shouldLoad
        }
    }
}
