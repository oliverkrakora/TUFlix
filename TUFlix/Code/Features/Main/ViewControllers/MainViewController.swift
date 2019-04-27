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
        
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        dataSource.fallbackDelegate = self
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.tableFooterView = UIView()
        contentTypeDidChange()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.indexPathForSelectedRow.flatMap { self.tableView.deselectRow(at: $0, animated: true) }
    }
    
    deinit {
        disposable?.dispose()
    }
    
    // MARK: Networking
    private func loadData() {
        viewModel.loadData { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.setupDataSource(with: self.viewModel.currentPageItems)
            case .failure:
                #warning("Handle error")
            }
        }
    }
    
    // MARK: DataSource
    
    private func setupDataSource(with content: [Any]) {
        dataSource.sections = [Section(items: content)]
        dataSource.reloadDataAnimated(tableView)
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

extension MainViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard pagingHelper.shouldLoadNextPage(for: scrollView) else { return }
        loadData()
    }
}
