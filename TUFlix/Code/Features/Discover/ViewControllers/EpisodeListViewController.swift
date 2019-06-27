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
import ReactiveSwift

class EpisodeListViewController<T: ListViewModelProtocol>: ListViewController<T> {
    
    typealias SelectEpisodeCallback = ((EpisodeViewModel) -> Void)
    
    var showEpisodeNames: Bool
    
    private var disposable: Disposable?
    
    var selectEpisodeClosure: SelectEpisodeCallback!
    
    init(title: String?, viewModel: T, displayEpisodeNames: Bool = true) {
        self.showEpisodeNames = displayEpisodeNames
        super.init(title: title, viewModel: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func cellDescriptors() -> [CellDescriptorType] {
        return [
            EpisodeCell.cellDescriptor
                .configure { [unowned self] (viewModel, cell, _) in
                    cell.configure(with: viewModel, isPartOfSeries: !self.showEpisodeNames)
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
