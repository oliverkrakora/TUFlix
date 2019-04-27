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
        case absolute(CGFloat)
        
        func absoluteValue(in scrollView: UIScrollView) -> CGFloat {
            switch self {
            case .absolute(let value):
                return value
            case .relative(let relative):
                return CGFloat(relative) * scrollView.contentSize.height
            }
        }
    }
    
    let pageAtOffset: PageOffset

    init(pageOffset: PageOffset) {
        self.pageAtOffset = pageOffset
    }
    
    func shouldLoadNextPage(for scrollView: UIScrollView) -> Bool {
        return (scrollView.contentOffset.y + scrollView.frame.height) >= pageAtOffset.absoluteValue(in: scrollView)
    }
}
