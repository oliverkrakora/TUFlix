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
        ToggleCell.descriptor,
        SimpleCell.descriptor.configure { (title, cell, _) in
            switch title {
            case L10n.Settings.Reset.title:
                cell.textLabel?.textColor = Asset.unlikeColor.color
            default: break
            }
            
            cell.textLabel?.text = title
            }.didSelect { [weak self] (title, _) -> SelectionResult in
                if title == L10n.Settings.Reset.title {
                    self?.eraseAppContent()
                }
                return .deselect
            }
        ], sectionDescriptors: [
            SectionDescriptor<String>().header { (title, _) -> HeaderFooter in
                switch title {
                case L10n.Series.title:
                    return .title(title)
                case L10n.Settings.Series.AutoSubscribe.title:
                    return .title("")
                default: return .title(title)
                }
                }.footer { (title, _) -> HeaderFooter in
                    switch title {
                    case L10n.Series.title:
                        return .title(L10n.Settings.Series.preferDateDescription)
                    case L10n.Settings.Series.AutoSubscribe.title:
                        return .title(L10n.Settings.Series.AutoSubscribe.description)
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
        
        let subscribeToSeriesToggle = ToggleItem(title: L10n.Settings.Series.AutoSubscribe.title, isOn: Settings.shared.autoSubscribeToFavoriteSeries) { isOn in
            Settings.shared.autoSubscribeToFavoriteSeries = isOn
        }
        
        dataSource.sections = [
            Section(L10n.Series.title, items: [
                seriesEpisodeNameToggle
                ]),
            Section(L10n.Settings.Series.AutoSubscribe.title, items: [
                subscribeToSeriesToggle
            ]),
            Section("", items: [L10n.Settings.Reset.title])
        ]
        dataSource.reloadDataAnimated(tableView)
    }
    
    private func eraseAppContent() {
        let alert = UIAlertController(title: L10n.Settings.ResetAlert.title, message: L10n.Settings.ResetAlert.description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Settings.Reset.title, style: .destructive, handler: { _ in
            EpisodeManager.shared.reset()
            SeriesManager.shared.reset()
        }))
        alert.addAction(UIAlertAction(title: L10n.Global.Cancel.title, style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
