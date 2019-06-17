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
                }.canEdit { true }
                .trailingSwipeAction { (row, _) -> UISwipeActionsConfiguration? in
                    guard let viewModel = row.item as? EpisodeViewModel else {
                        return nil
                    }
                    
                    let action: UIContextualAction = {
                        let title = viewModel.isFavorite ? L10n.Episode.removeLikeTitle : L10n.Episode.addLikeTitle
                        let action = UIContextualAction(style: .normal, title: title, handler: { (_, _, completion) in
                            if viewModel.isFavorite {
                                viewModel.unlikeEpisode()
                            } else {
                                viewModel.likeEpisode()
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
    
    init(title: String?, viewModel: ListViewModel<Episode, EpisodeViewModel>, isPartOfSeries: Bool = false) {
        self.isPartOfSeries = isPartOfSeries
        super.init(title: title, viewModel: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
