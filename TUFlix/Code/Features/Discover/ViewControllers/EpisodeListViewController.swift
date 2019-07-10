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
    
    private(set) lazy var toolbar: ToggleToolbar = {
        let toolbar = ToggleToolbar(title: L10n.Episodes.toggleTitle, isOn: false, callback: { [unowned self] isOn in
            self.toggleEpisodeNames(showNames: isOn)
        })
        toolbar.isHidden = true
        return toolbar
    }()
    
    private var disposable: Disposable?
    
    var selectEpisodeClosure: SelectEpisodeCallback!
    
    init(title: String?, viewModel: T, displayEpisodeNames: Bool = true) {
        super.init(title: title, viewModel: viewModel)
        self.toolbar.toggle.isOn = displayEpisodeNames
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset.bottom = toolbar.frame.height
        setupStatefulViews(insets: UIEdgeInsets(top: 0, left: 0, bottom: toolbar.frame.height, right: 0))
    }
    
    override func cellDescriptors() -> [CellDescriptorType] {
        return [
            EpisodeCell.cellDescriptor
                .configure { [unowned self] (viewModel, cell, _) in
                    cell.configure(with: viewModel, showEpisodeNames: self.toolbar.toggle.isOn)
                }
                .didSelect { (viewModel, _) in
                    self.selectEpisodeClosure(viewModel)
                    return .keepSelected
                }.canEdit { true }
                .trailingSwipeAction { (row, _) -> UISwipeActionsConfiguration? in
                    guard let viewModel = row.item as? EpisodeViewModel else {
                        return nil
                    }
                    
                    let favoriteAction: UIContextualAction = {
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
                    
                    let downloadAction: UIContextualAction = {
                        let titleAndAction: (title: String, action: (() -> Bool)) = {
                            if viewModel.isAvailableOffline {
                                let action: (() -> Bool) = {
                                    viewModel.delete()
                                    return true
                                }
                                return (L10n.Download.deleteTitle, action)
                            } else if viewModel.isDownloading {
                                let action: (() -> Bool) = {
                                    viewModel.cancelDownload()
                                    return true
                                }
                                return (L10n.Download.stopTitle, action)
                            } else {
                                return (L10n.Download.startTitle, viewModel.download)
                            }
                        }()
                        return UIContextualAction(style: .normal, title: titleAndAction.title, handler: { (_, _, completion) in
                            completion(titleAndAction.action())
                        })
                    }()
                    
                    return UISwipeActionsConfiguration(actions: [
                        downloadAction,
                        favoriteAction
                        ])
            }
        ]
    }
    
    func toggleEpisodeNames(showNames: Bool) {
        toolbar.toggle.isOn = showNames
        
        if isViewLoaded {
            tableView.reloadData()
        }
    }
}
