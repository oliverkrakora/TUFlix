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

class SeriesListViewController<ListViewModel: ListViewModelProtocol>: ListViewController<ListViewModel> {
    
    typealias SelectSeriesCallback = ((SeriesViewModel) -> Void)
    
    var selectSeriesClosure: SelectSeriesCallback!
    
    override func cellDescriptors() -> [CellDescriptorType] {
        return [
            SeriesCell.cellDescriptor
                .didSelect { (viewModel, _) in
                    self.selectSeriesClosure(viewModel)
                    return .keepSelected
                }.canEdit { true }
                .trailingSwipeAction { (row, _) -> UISwipeActionsConfiguration? in
                    guard let viewModel = row.item as? SeriesViewModel else {
                        return nil
                    }
                    
                    let action: UIContextualAction = {
                        let title = viewModel.isFavorite ? L10n.Episode.removeLikeTitle : L10n.Episode.addLikeTitle
                        let action = UIContextualAction(style: .normal, title: title, handler: { (_, _, completion) in
                            if viewModel.isFavorite {
                                viewModel.unlikeSeries()
                            } else {
                                viewModel.likeSeries()
                            }
                            completion(true)
                            viewModel.didUpdateLikeState?()
                        })
                        action.backgroundColor = viewModel.isFavorite ? Asset.unlikeColor.color : Asset.likeColor.color
                        return action
                    }()
                    
                    return UISwipeActionsConfiguration(actions: [
                        action
                        ])
            }
        ]
    }
}
