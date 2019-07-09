//
//  LibraryViewModel.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import ReactiveSwift

class LibraryListViewModel: ListViewModelProtocol {
    
    typealias Item = Any
    
    let items: Property<[Any]> = {
        EpisodeDownloader.shared.runningDownloads.map { downloads in
            return [
                LibraryItem(title: L10n.Episodes.title, image: nil),
                LibraryItem(title: L10n.Series.title, image: nil)
            ] + downloads
        }
    }()
    
    func hasContent() -> Bool {
        return true
    }
    
    func isLoadingData() -> Bool {
        return false
    }
    
    func loadData(reset: Bool = false) -> SignalProducer<[Any], Error> {
        return SignalProducer(value: self.items.value)
    }
}
