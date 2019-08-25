//
//  LibraryViewController.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource
import ReactiveSwift

class LibraryViewController: UIViewController {
    
    // MARK: Properties
    
    private let viewModel = LibraryListViewModel()
    
    var showFavoriteEpisodes: (() -> Void)!
    
    var showFavoriteSeries: (() -> Void)!
    
    private let disposable = CompositeDisposable()
    
    private var tableView: UITableView!
    
    private lazy var dataSource: DataSource = {
        return DataSource(cellDescriptors: [
            LibraryItemCell.cellDescriptor
                .didSelect { [unowned self] (item, _) in
                    switch item.title {
                    case L10n.Episodes.title:
                        self.showFavoriteEpisodes()
                    case L10n.Series.title:
                        self.showFavoriteSeries()
                    default: break
                    }
                    return .deselect
            },
            EpisodeDownloadCell.cellDescriptor.trailingSwipeAction { (row, _) in
                guard let download = row.item as? EpisodeDownloader.Download else { return nil }
                let action = UIContextualAction(style: .normal, title: L10n.Download.stopTitle, handler: { (_, _, completion) in
                    let success = EpisodeDownloader.shared.cancelDownload(for: download.episode.identifier) == nil
                    completion(success)
                })
                action.backgroundColor = Asset.unlikeColor.color
                action.image = Asset.cancelIcon.image
                return UISwipeActionsConfiguration(actions: [action])
            }
            ], sectionDescriptors: [
                SectionDescriptor<String>().header { (title, _) in
                    let label = UILabel()
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.font = UIFont.preferredFont(forTextStyle: .headline)
                    label.text = title
                    
                    let view = UIView()
                    view.backgroundColor = .white
                    view.addSubview(label)
                    NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    label.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
                    label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16),
                    view.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8)
                    ])
                    
                    return .view(view)
                }
            ])
    }()
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = UIView()
        
        tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.tableFooterView = UIView()
        setupBindings()
    }
    
    deinit {
        disposable.dispose()
    }
    
    // MARK: Bindings
    
    func setupBindings() {
        disposable += viewModel.downloads.producer.startWithValues { [weak self] _ in
            self?.setupDataSource()
        }
    }
    
    // MARK: DataSource
    
    private func setupDataSource() {
        dataSource.sections = [
            Section(items: viewModel.libraryItems),
            Section(L10n.Downloads.title, items: viewModel.downloads.value)
        ]
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dataSource.reloadDataAnimated(self.tableView)
        }
    }
}
