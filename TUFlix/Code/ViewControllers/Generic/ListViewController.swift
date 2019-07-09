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
    
    // MARK: Properties
    
    private(set) var tableView: UITableView!
    
    private(set)lazy var dataSource: DataSource = {
        return DataSource(cellDescriptors: cellDescriptors(), sectionDescriptors: sectionDescriptors())
    }()
    
    private lazy var pagingHelper: ScrollViewPagingHandler = {
        return ScrollViewPagingHandler(threshold: 0.9,
                                       loadClosure: {
                                        self.loadData()
        })
    }()
    
    private(set) var viewModel: T!
    
    private var requestDisposable: Disposable?
    
    private var bindingsDisposable = CompositeDisposable()
    
    // MARK: Lifecycle

    init(title: String?, viewModel: T) {
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = title
        self.tabBarItem.title = title
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        bindingsDisposable.dispose()
    }
    
    override func loadView() {
        view = UIView()
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
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
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatefulViews()
        setupBindings()
        setupSearchController()
        loadData()
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
    
    func cellDescriptors() -> [CellDescriptorType] {
        return []
    }
    
    func sectionDescriptors() -> [SectionDescriptorType] {
        return []
    }
    
    private func setupSearchController() {
        guard viewModel is SearchableProtocol else {
            navigationItem.searchController = nil
            return
        }
        
        let controller = UISearchController(searchResultsController: nil)
        controller.dimsBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = true
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.barStyle = .black
        controller.searchBar.delegate = self
        navigationItem.searchController = controller
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: Networking
    
    /// - Parameter reset: Removes all loaded items, resets the offset to zero and interrupts the current request if existing
    private func loadData(reset: Bool = false) {
        guard !viewModel.isLoadingData() || reset else { return }
        
        startLoading()
        requestDisposable?.dispose()
        requestDisposable = viewModel.loadData(reset: reset).startWithResult { [weak self] result in
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
        bindingsDisposable += viewModel.items.producer.startWithValues { [weak self] _ in
            self?.setupDataSource()
        }
        
        bindingsDisposable += KeyboardObserver.observeKeyboardChanges().observeValues { [weak self] notification in
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
        loadData(reset: true)
    }
    
    // MARK: UITableViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard viewModel.hasContent() && viewModel.hasAdditionalDataToLoad() else { return }
        
        pagingHelper.scrollViewDidScroll(scrollView)
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let viewModel = viewModel as? SearchableProtocol else { return }
        
        viewModel.searchTerm.value = searchText
        loadData(reset: true)
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
    
    func setupStatefulViews(insets: UIEdgeInsets = .zero) {
        emptyView = EmptyStateView.load()?.prepare(with: L10n.Global.EmptyState.title, subtitle: L10n.Global.retryTapTitle, insets: insets) { [weak self] in
            self?.loadData(reset: true)
        }
        
        loadingView = LoadingStateView.load()?.prepare(with: L10n.Global.LoadingState.title, insets: insets)
        
        errorView = ErrorStateView.load()?.prepare(with: L10n.Global.ErrorState.title, subtitle: L10n.Global.retryTapTitle, insets: insets, retryClosure: { [weak self] in
            self?.loadData()
        })
    }
}
