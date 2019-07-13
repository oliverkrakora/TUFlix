//
//  EpisodeDownloadCell.swift
//  TUFlix
//
//  Created by Oliver Krakora on 09.07.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource
import ReactiveSwift

class EpisodeDownloadCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet private var nameLabel: UILabel!
    
    @IBOutlet private var progressView: UIProgressView!
    
    @IBOutlet private var progressLabel: UILabel!
    
    // MARK: Properties
    
    private var disposable = CompositeDisposable()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposable.dispose()
        disposable = CompositeDisposable()
    }
    
    func configure(with download: EpisodeDownloader.Download) {
        let viewModel = EpisodeViewModel(model: download.episode)
        nameLabel.text = viewModel.formattedTitle
        
        disposable += download.progress.producer.skipRepeats().startWithValues { progress in
            DispatchQueue.main.async { [weak self] in
                self?.progressView.progress = Float(progress)
                self?.progressLabel.text = download.formattedProgress
            }
        }
    }
}

extension EpisodeDownloadCell {
    static var cellDescriptor: CellDescriptor<EpisodeDownloader.Download, EpisodeDownloadCell> {
        return CellDescriptor().configure { (download, cell, _) in
            cell.configure(with: download)
            }.canEdit { true }
    }
}
