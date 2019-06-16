//
//  EpisodeCell.swift
//  TUFlix
//
//  Created by Oliver Krakora on 19.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

class EpisodeCell: UITableViewCell {
    
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var creatorTitleLabel: UILabel!
    
    @IBOutlet private var creationDateLabel: UILabel!
    
    @IBOutlet private var durationLabel: UILabel!
    
    @IBOutlet private var footerStackView: UIStackView!
    
    @IBOutlet private var isFavoriteIndicatorView: TriangleView!
    
    private var viewModel: EpisodeViewModel!
    
    func configure(with episode: EpisodeViewModel, isPartOfSeries: Bool = false) {
        self.viewModel = episode
        titleLabel.text = {
            if isPartOfSeries {
                return episode.formattedCreationDate
            }
            return episode.formattedTitle
        }()
        
        isFavoriteIndicatorView.isHidden = !episode.isFavorite
        creatorTitleLabel.text = episode.formattedCreatorName
        creatorTitleLabel.isHidden = episode.formattedCreatorName?.isEmpty ?? true
        creationDateLabel.text = episode.formattedCreationDate
        creationDateLabel.isHidden = isPartOfSeries
        durationLabel.text = episode.formattedDuration
    }
}

extension EpisodeCell {
    static var cellDescriptor: CellDescriptor<EpisodeViewModel, EpisodeCell> {
        return CellDescriptor().configure { (viewModel, cell, _) in
            cell.configure(with: viewModel)
        }
    }
}
