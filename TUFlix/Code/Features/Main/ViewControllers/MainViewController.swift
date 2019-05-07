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

class MainViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet private var contentTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: Properties
    
    private let pagingHelper = PagedScrollViewHelper(pageOffset: .relative(0.8))
    
    private lazy var dataSource: DataSource = {
      return DataSource(cellDescriptors: [
        EpisodeCell.cellDescriptor,
        SeriesCell.cellDescriptor.didSelect { [weak self] (viewModel, _) in
            self?.showSeriesDetails(viewModel)
            return .keepSelected
        }
        ])
    }()
    
    private var disposable: Disposable?
    
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
                
        navigationItem.searchController = {
           let controller = UISearchController(searchResultsController: nil)
            controller.obscuresBackgroundDuringPresentation = false
            return controller
        }()
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
        contentTypeDidChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInitialViewState()
        tableView.indexPathForSelectedRow.flatMap { self.tableView.deselectRow(at: $0, animated: true) }

    }
    
    deinit {
        disposable?.dispose()
    }
    
    // MARK: Networking
    
    @objc private func forceRefresh() {
        loadData(force: true)
    }
    
    private func loadData(force: Bool = false) {
        startLoading()
        viewModel.loadData(reset: force) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.setupDataSource(with: self.viewModel.currentPageItems)
            case .failure:
                #warning("Handle error")
            }
            self.tableView.refreshControl?.endRefreshing()
            self.endLoading()
        }
    }
    
    // MARK: DataSource
    
    private func setupDataSource(with content: [Any]) {
        dataSource.sections = [Section(items: content)]
        dataSource.reloadData(tableView, animated: false)
    }
    
    // MARK: Actions
    
    @IBAction private func contentTypeDidChange() {
        viewModel.contentType = ContentType(rawValue: contentTypeSegmentedControl.selectedSegmentIndex)!
        guard !viewModel.hasContent else {
            setupDataSource(with: viewModel.currentPageItems)
            return
        }
        loadData()
    }
}

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

extension MainViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard pagingHelper.shouldLoadNextPage(for: scrollView) else { return }
        loadData()
    }
}
