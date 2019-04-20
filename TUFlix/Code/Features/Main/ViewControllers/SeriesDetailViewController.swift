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

class SeriesDetailViewController: UIViewController {
    
    // MARK: Outlets
 
    @IBOutlet private var tableView: UITableView!
    
    // MARK: Properties
    
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
        navigationItem.title = viewModel.formattedTitle
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.tableFooterView = UIView()
        loadData()
    }
    
    deinit {
        disposable?.dispose()
    }
    
    // MARK: Networking
    
    private func loadData() {
        disposable = viewModel.fetchEpisodes.apply().startWithResult { [weak self] result in
            switch result {
            case .success(let value):
                self?.setupDataSource(with: value)
            case .failure(let error):
                print(error)
                #warning("Handle error")
            }
        }
    }
    
    private func setupDataSource(with content: [EpisodeViewModel]) {
        dataSource.sections = [Section(items: content)]
        dataSource.reloadDataAnimated(tableView)
    }
}
