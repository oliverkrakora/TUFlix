//
//  SeriesCell.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource
import ReactiveSwift

class SeriesCell: UITableViewCell {
    
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var creatorLabel: UILabel!
    
    @IBOutlet private var contributorLabel: UILabel!
    
    @IBOutlet private var isFavoriteIndicator: TriangleView!
    
    private var viewModel: SeriesViewModel!
    
    private var favoriteDisposable: Disposable?
    
    func configure(with series: SeriesViewModel) {
        self.viewModel = series
        titleLabel.text = series.formattedTitle
        creatorLabel.text = series.formattedCreator
        contributorLabel.text = series.formattedContributor
        isFavoriteIndicator.isHidden = !series.isFavorite
        
        favoriteDisposable?.dispose()
        favoriteDisposable = series.favoriteStatusDidChange.observeValues { [weak self] _ in
            self?.isFavoriteIndicator.isHidden = !series.isFavorite
        }
    }
    
}
extension SeriesCell {
    static var cellDescriptor: CellDescriptor<SeriesViewModel, SeriesCell> {
        return CellDescriptor().configure { (viewModel, cell, _) in
            cell.configure(with: viewModel)
        }
    }
}
