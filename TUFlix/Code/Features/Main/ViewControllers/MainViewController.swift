//
//  MainViewController.swift
//  TUFlix
//
//  Created by Oliver Krakora on 19.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource
import Fetch
import ReactiveSwift
import StatefulViewController
import ReactiveCocoa

class MainViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet private var contentTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: Properties
    
    private let pagingHelper = PagedScrollViewHelper(pageOffset: .relative(0.8))
    
    private lazy var dataSource: DataSource = {
        return DataSource(cellDescriptors: [
            EpisodeCell.cellDescriptor.didSelect { [unowned self] (viewModel, _) in
                self.playEpisode(viewModel)
                return .keepSelected
            },
            SeriesCell.cellDescriptor.didSelect { [weak self] (viewModel, _) in
                self?.showSeriesDetails(viewModel)
                return .keepSelected
            }
            ])
    }()
    
    var playEpisode: ((EpisodeViewModel) -> Void)!
    
    private var disposable = CompositeDisposable()
    
    private let viewModel = MainViewModel()
    
    var showSeriesDetails: ((SeriesViewModel) -> Void)!
    
    // MARK: Lifecycle
    
    static func create() -> MainViewController {
        let vc = UIStoryboard(.main).instantiateViewController(self)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatefulViews()
        
//        navigationItem.searchController = {
//            let controller = UISearchController(searchResultsController: nil)
//            controller.obscuresBackgroundDuringPresentation = false
//            return controller
//        }()
        
        dataSource.fallbackDelegate = self
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.refreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = .white
            refreshControl.addTarget(self, action: #selector(forceRefresh), for: .valueChanged)
            return refreshControl
        }()
        tableView.tableFooterView = UIView()
        
        setupBindings()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInitialViewState()
        tableView.indexPathForSelectedRow.flatMap { self.tableView.deselectRow(at: $0, animated: true) }
    }
    
    deinit {
        disposable.dispose()
    }
    
    // MARK: Bindings
    
    private func setupBindings() {
        disposable += viewModel.shouldReloadSignal.observeValues { [weak self] error in
            guard let self = self else { return }
            
            if case .pagingInProgress? = error {
                /// The next page is being loaded wait for it
                return
            }
            
            if !self.viewModel.hasContent {
                self.loadData()
            } else {
                self.tableView.refreshControl?.endRefreshing()
                self.setupDataSource(with: self.viewModel.currentPageItems)
                self.endLoading(animated: true, error: error, completion: nil)
            }
        }
        
        disposable += contentTypeSegmentedControl.reactive.selectedSegmentIndexes.observeValues { [unowned self] selectedSegment in
            self.viewModel.contentType.value = ContentType(rawValue: selectedSegment)!
        }
    }
    
    // MARK: Networking
    
    @objc private func forceRefresh() {
        loadData(force: true)
    }
    
    private func loadData(force: Bool = false) {
        startLoading()
        viewModel.loadData(reset: force)
    }
    
    // MARK: DataSource
    
    private func setupDataSource(with content: [Any]) {
        dataSource.sections = [Section(items: content)]
        dataSource.reloadData(tableView, animated: false)
    }
}

// MARK: StatefulViewController
extension MainViewController: StatefulViewController {
    
    func hasContent() -> Bool {
        return viewModel.hasContent
    }
    
    private func setupStatefulViews() {
        self.emptyView = EmptyStateView.loadFromNib(type: EmptyStateView.self)?.prepare(with: "No data to show")
        self.loadingView = LoadingStateView.loadFromNib(type: LoadingStateView.self)?.prepare(with: "Loading data")
        self.errorView = ErrorStateView.loadFromNib(type: ErrorStateView.self)?.prepare(with: "Failed to load data", retryClosure: { [weak self] in
            self?.loadData()
        })
    }
}

/// MARK: UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard pagingHelper.shouldLoadNextPage(for: scrollView) else { return }
        self.loadData()
    }
}
