//
//  ListViewController.swift
//  TUFlix
//
//  Created by Oliver Krakora on 15.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import ReactiveSwift
import TUFlixKit
import DataSource
import StatefulViewController

class ListViewController<Item: SearchResultItem, MappedItem>: UIViewController, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: Outlets
    
    var tableView: UITableView {
        return view as! UITableView
    }
    
    // MARK: Properties
    
    private lazy var dataSource: DataSource = {
        return DataSource(cellDescriptors: cellDescriptors())
    }()
    
    private var viewModel: ListViewModel<Item, MappedItem>!
    
    private lazy var pagingHelper: ScrollViewPagingHandler = {
        return ScrollViewPagingHandler(threshold: 0.9,
                                       loadClosure: {
                                        self.loadNextPage()
        })
    }()
    
    private var disposable = CompositeDisposable()
    
    private var requestDisposable: Disposable?
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = UITableView()
    }
    
    init(title: String?, viewModel: ListViewModel<Item, MappedItem>) {
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = title
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatefulViews()
        setupTableView()
        setupBindings()
        loadNextPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInitialViewState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    deinit {
        disposable.dispose()
    }
    
    private func setupTableView() {
        dataSource.fallbackDelegate = self
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.showsVerticalScrollIndicator = false
        tableView.refreshControl = {
            let control = UIRefreshControl()
            control.addTarget(self, action: #selector(didTriggerRefreshControl), for: .valueChanged)
            return control
        }()
        tableView.tableFooterView = UIView()
    }
    
    func cellDescriptors() -> [CellDescriptorType] {
        return []
    }
    
    // MARK: Networking
    /// - Parameter reset: Removes all loaded items, resets the offset to zero and interrupts the current request if existing
    private func loadNextPage(reset: Bool = false) {
        guard (!viewModel.loadNextPageAction.isExecuting.value && viewModel.hasMoreToLoad) || reset else { return }
        
        startLoading()
        requestDisposable?.dispose()
        requestDisposable = viewModel.loadNextPageAction.apply(reset).startWithResult { [weak self] result in
            self?.endLoading(animated: true, error: result.error, completion: nil)
            self?.tableView.refreshControl?.endRefreshing()
            switch result {
            case .success:
                print("Load success")
            case .failure(let error):
                print("Load failure: \(error)")
            }
        }
    }
    
    // MARK: Bindings
    private func setupBindings() {
        disposable += viewModel.items.producer.startWithValues { [weak self] episodes in
            self?.setupDataSource(with: episodes)
        }
        
        disposable += KeyboardObserver.observeKeyboardChanges().observeValues { [weak self] notification in
            if notification.willShow {
                self?.tableView.contentInset.bottom = notification.keyboardHeight
            } else {
                 self?.tableView.contentInset.bottom = 0
            }
        }
    }
    
    // MARK: DataSource
    private func setupDataSource(with episodes: [MappedItem]) {
        dataSource.sections = [Section(items: episodes)]
        dataSource.reloadData(tableView, animated: true)
    }
    
    // MARK: Actions
    
    @objc private func didTriggerRefreshControl() {
        loadNextPage(reset: true)
    }
    
    // MARK: UITableViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pagingHelper.scrollViewDidScroll(scrollView)
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchTerm.value = searchText
        loadNextPage(reset: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        requestDisposable?.dispose()
        viewModel.searchTerm.value = ""
        endLoading()
    }
}

extension ListViewController: StatefulViewController {
    
    func hasContent() -> Bool {
        return viewModel.hasContent
    }
    
    private func setupStatefulViews() {
        emptyView = EmptyStateView.load()?.prepare(with: L10n.Global.EmptyState.title, subtitle: L10n.Global.retryTapTitle, insets: .zero) { [weak self] in
            self?.loadNextPage(reset: true)
        }
        
        loadingView = LoadingStateView.load()?.prepare(with: L10n.Global.LoadingState.title)
        
        errorView = ErrorStateView.load()?.prepare(with: L10n.Global.ErrorState.title, subtitle: L10n.Global.retryTapTitle, insets: .zero, retryClosure: { [weak self] in
            self?.loadNextPage()
        })
    }
}
