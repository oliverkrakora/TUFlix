//
//  LibraryViewModel.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import ReactiveSwift

class LibraryListViewModel {
    
    let libraryItems: [LibraryItem] = {
        return [
            LibraryItem(title: L10n.Episodes.title, image: nil),
            LibraryItem(title: L10n.Series.title, image: nil)
        ]
    }()
    
    var downloads: Property<[EpisodeDownloader.Download]> {
        return EpisodeDownloader.shared.downloads
    }
}
