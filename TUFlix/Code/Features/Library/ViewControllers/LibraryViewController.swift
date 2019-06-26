//
//  LibraryViewController.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

class LibraryViewController<T: ListViewModelProtocol>: ListViewController<T> {
    
    var showFavoriteEpisodes: (() -> Void)!
    
    var showFavoriteSeries: (() -> Void)!
    
    override func cellDescriptors() -> [CellDescriptorType] {
        return [
            LibraryItemCell.cellDescriptor.didSelect { [unowned self] (item, _) -> SelectionResult in
                switch item.title {
                case L10n.Episodes.title:
                    self.showFavoriteEpisodes()
                case L10n.Series.title:
                    self.showFavoriteSeries()
                default:
                    break
                }
                return .keepSelected
            }
        ]
    }
}
