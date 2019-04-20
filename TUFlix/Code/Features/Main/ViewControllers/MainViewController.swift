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
        switch viewModel.contentType {
        case .episodes:
            disposable = viewModel.fetchEpisodes.apply().startWithResult { [weak self] result in
                switch result {
                case .success(let value):
                    self?.setupDataSource(with: value)
                case .failure(let error):
                    print(error)
                    #warning("Handle error")
                }
            }
        case .series:
            disposable = viewModel.fetchSeries.apply().startWithResult { [weak self] result in
                switch result {
                case .success(let value):
                    self?.setupDataSource(with: value)
                case .failure(let error):
                    print(error)
                    #warning("Handle error")
                }
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
        loadData()
    }
}
