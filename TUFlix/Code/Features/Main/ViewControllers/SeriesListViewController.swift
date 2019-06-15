//
//  SeriesListViewController.swift
//  TUFlix
//
//  Created by Oliver Krakora on 15.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource
import TUFlixKit

class SeriesListViewController: ListViewController<Series, SeriesViewModel> {
    
    typealias SelectSeriesCallback = ((SeriesViewModel) -> Void)
    
    var selectSeriesClosure: SelectSeriesCallback!
    
    override func cellDescriptors() -> [CellDescriptorType] {
        return [
            SeriesCell.cellDescriptor
                .didSelect { (viewModel, _) in
                    self.selectSeriesClosure(viewModel)
                    return .keepSelected
            }
        ]
    }
}
