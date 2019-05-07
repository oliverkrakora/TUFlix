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

    init(pageOffset: PageOffset) {
        self.pageAtOffset = pageOffset
    }
    
    func shouldLoadNextPage(for scrollView: UIScrollView) -> Bool {
        switch pageAtOffset {
        case .relative(let value):
            let adjustedContentSize = abs(scrollView.contentSize.height - scrollView.bounds.height)
            return (scrollView.contentOffset.y / adjustedContentSize) > value
        }
    }
}
