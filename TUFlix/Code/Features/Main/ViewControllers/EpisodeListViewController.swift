//
//  EpisodeListViewController.swift
//  TUFlix
//
//  Created by Oliver Krakora on 15.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource
import TUFlixKit

class EpisodeListViewController: ListViewController<Episode, EpisodeViewModel> {
    
    typealias SelectEpisodeCallback = ((EpisodeViewModel) -> Void)
    
    private let isPartOfSeries: Bool
    
    var selectEpisodeClosure: SelectEpisodeCallback!
    
    override func cellDescriptors() -> [CellDescriptorType] {
        return [
            EpisodeCell.cellDescriptor
                .configure { [unowned self] (viewModel, cell, _) in
                    cell.configure(with: viewModel, isPartOfSeries: self.isPartOfSeries)
                }
                .didSelect { (viewModel, _) in
                    self.selectEpisodeClosure(viewModel)
                    return .keepSelected
            }
        ]
    }
    
    init(title: String?, viewModel: ListViewModel<Episode, EpisodeViewModel>, isPartOfSeries: Bool = false) {
        self.isPartOfSeries = isPartOfSeries
        super.init(title: title, viewModel: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
