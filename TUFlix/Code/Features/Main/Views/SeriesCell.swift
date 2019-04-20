//
//  SeriesCell.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

class SeriesCell: UITableViewCell {
    
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var creatorLabel: UILabel!
    
    @IBOutlet var contributorLabel: UILabel!
    
    func configure(with series: SeriesViewModel) {
        titleLabel.text = series.formattedTitle
        creatorLabel.text = series.formattedCreator
        contributorLabel.text = series.formattedContributor
    }
}
extension SeriesCell {
    static var cellDescriptor: CellDescriptor<SeriesViewModel, SeriesCell> {
        return CellDescriptor().configure { (viewModel, cell, _) in
            cell.configure(with: viewModel)
        }
    }
}
