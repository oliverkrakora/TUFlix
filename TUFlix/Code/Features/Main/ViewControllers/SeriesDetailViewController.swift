//
//  SeriesDetailViewController.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource
import ReactiveSwift
import StatefulViewController

class SeriesDetailViewController: UIViewController {
    
    // MARK: Outlets
 
    @IBOutlet private var tableView: UITableView!
    
    // MARK: Properties
    
    private let pagingHelper = PagedScrollViewHelper(pageOffset: .relative(0.8))
    
    private lazy var dataSource: DataSource = {
       return DataSource(cellDescriptors: [
        EpisodeCell.cellDescriptor.configure { (viewModel, cell, _) in
            cell.configure(with: viewModel, isPartOfSeries: true)
        }
        ])
    }()
    
    private var disposable: Disposable?
    
    private var viewModel: SeriesViewModel!
    
    // MARK: Lifecycle
    
    static func create(with viewModel: SeriesViewModel) -> SeriesDetailViewController {
        let vc = UIStoryboard(.main).instantiateViewController(self)
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatefulViews()
        navigationItem.title = viewModel.formattedTitle
        
        dataSource.fallbackDelegate = self
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.tableFooterView = UIView()
        setupDataSource(with: viewModel.episodes)
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInitialViewState()
    }
    
    deinit {
        disposable?.dispose()
    }
    
    // MARK: Networking
    
    private func loadData() {
        startLoading()
        
        viewModel.episodePager.loadNext { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.setupDataSource(with: self.viewModel.episodes)
            case .failure:
                #warning("Handle error")
            }
            
            self.endLoading()
        }
    }
    
    private func setupDataSource(with content: [EpisodeViewModel]) {
        dataSource.sections = [Section(items: content)]
        dataSource.reloadDataAnimated(tableView)
    }
}

extension SeriesDetailViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard pagingHelper.shouldLoadNextPage(for: scrollView) else { return }
        
        loadData()
    }
}

extension SeriesDetailViewController: StatefulViewController {
    
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
