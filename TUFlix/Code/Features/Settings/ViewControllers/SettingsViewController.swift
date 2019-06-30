//
//  SettingsViewController.swift
//  TUFlix
//
//  Created by Oliver Krakora on 30.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

class SettingsViewController: UIViewController {
    
    private var tableView: UITableView!
    
    private lazy var dataSource: DataSource = {
      return DataSource(cellDescriptors: [
        ToggleCell.descriptor
        ], sectionDescriptors: [
            SectionDescriptor<String>().header { (title, _) -> HeaderFooter in
                return .title(title)
                }.footer { (title, _) -> HeaderFooter in
                    switch title {
                    case L10n.Series.title:
                        return .title(L10n.Settings.Series.preferDateDescription)
                    default:
                        return .none
                    }
                }
        ])
    }()
    
    override func loadView() {
        self.tableView = UITableView(frame: .zero, style: .grouped)
        view = tableView
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = L10n.Settings.title
        setupDataSource()
    }
    
    // MARK: DataSource
    
    private func setupDataSource() {
        let seriesEpisodeNameToggle = ToggleItem(title: L10n.Settings.Series.preferDateTitle, isOn: Settings.shared.preferDateOverTitleInSeries) { isOn in
            Settings.shared.preferDateOverTitleInSeries = isOn
        }
        dataSource.sections = [
            Section(L10n.Series.title, items: [
                seriesEpisodeNameToggle
                ])
        ]
        dataSource.reloadDataAnimated(tableView)
    }
}
