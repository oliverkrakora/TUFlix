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

class ListViewController<T: ListViewModelProtocol>: UIViewController, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: Outlets
    
    var tableView: UITableView {
        return view as! UITableView
    }
    
    // MARK: Properties
    
    private lazy var dataSource: DataSource = {
        return DataSource(cellDescriptors: cellDescriptors())
    }()
    
    private(set) var viewModel: T!
    
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
    
    init(title: String?, viewModel: T) {
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = title
        self.tabBarItem.title = title
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatefulViews()
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
    
    func cellDescriptors() -> [CellDescriptorType] {
        return []
    }
    
    // MARK: Networking
    /// - Parameter reset: Removes all loaded items, resets the offset to zero and interrupts the current request if existing
    private func loadNextPage(reset: Bool = false) {
        
        let signalProducer: SignalProducer<[T.Item], Error> = {
            if let viewModel = viewModel as? PageableProtocol {
                return viewModel.loadData(reset: reset)
            } else {
                return viewModel.loadData()
            }
        }()
        
        let hasMoreToLoad: Bool = {
            if let viewModel = viewModel as? PageableProtocol {
                return viewModel.hasMoreToLoad()
            }
            return true
        }()
        
        guard (!viewModel.isExecuting() && hasMoreToLoad) || reset else { return }
        
        startLoading()
        requestDisposable?.dispose()
        requestDisposable = signalProducer.startWithResult { [weak self] result in
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
        disposable += viewModel.items.producer.startWithValues { [weak self] _ in
            self?.setupDataSource()
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
    func setupDataSource() {
        
        dataSource.sections = [Section(items: viewModel.items.value)]
        dataSource.reloadData(tableView, animated: true)
    }
    
    // MARK: Actions
    
    @objc private func didTriggerRefreshControl() {
        loadNextPage(reset: true)
    }
    
    // MARK: UITableViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard viewModel is PageableProtocol else { return }
        
        pagingHelper.scrollViewDidScroll(scrollView)
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let viewModel = viewModel as? SearchableProtocol else { return }
        
        viewModel.searchTerm.value = searchText
        loadNextPage(reset: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let viewModel = viewModel as? SearchableProtocol else { return }

        requestDisposable?.dispose()
        viewModel.searchTerm.value = ""
        endLoading()
    }
}

extension ListViewController: StatefulViewController {
    
    func hasContent() -> Bool {
        return viewModel.hasContent()
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
