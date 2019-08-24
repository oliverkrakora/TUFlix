//
//  SeriesListViewController.swift
//  TUFlix
//
//  Created by Oliver Krakora on 15.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource
import TUFlixKit
import UserNotifications

class SeriesListViewController<T: ListViewModelProtocol>: ListViewController<T> where T.Item == SeriesViewModel {
    
    typealias SelectSeriesCallback = ((SeriesViewModel) -> Void)
    
    var selectSeriesClosure: SelectSeriesCallback!
    
    override func cellDescriptors() -> [CellDescriptorType] {
        return [
            SeriesCell.cellDescriptor
                .didSelect { (viewModel, _) in
                    self.selectSeriesClosure(viewModel)
                    return .keepSelected
                }.canEdit { true }
                .trailingSwipeAction { (row, _) -> UISwipeActionsConfiguration? in
                    guard let viewModel = row.item as? SeriesViewModel else {
                        return nil
                    }
                    
                    let action: UIContextualAction = {
                        let action = UIContextualAction(style: .normal, title: nil, handler: { [weak self] (_, _, completion) in
                            if viewModel.isFavorite {
                                viewModel.unlikeSeries()
                            } else {
                                self?.likeSeries(viewModel)
                            }
                            completion(true)
                        })
                        action.backgroundColor = viewModel.isFavorite ? Asset.unlikeColor.color : Asset.likeColor.color
                        action.image = viewModel.isFavorite ? Asset.starFilled.image : Asset.starOutlined.image
                        return action
                    }()
                    
                    return UISwipeActionsConfiguration(actions: [
                        action
                        ])
            }
        ]
    }
    
    func likeSeries(_ series: SeriesViewModel) {
        series.likeSeries()
        
        UNUserNotificationCenter.current().requestAuthorization(options: .alert) { (isAuthorized, error) in
            if (!isAuthorized || error != nil) && Settings.shared.autoSubscribeToFavoriteSeries {
                let alert = UIAlertController(title: L10n.Series.Subscribe.failedTitle, message: L10n.Series.Subscribe.Failed.description(series.formattedTitle ?? ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: L10n.Global.Ok.title, style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: L10n.Settings.title, style: .default, handler: { _ in
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }))
                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
