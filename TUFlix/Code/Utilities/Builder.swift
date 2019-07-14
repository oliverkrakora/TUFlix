//
//  Builder.swift
//  TUFlix
//
//  Created by Oliver Krakora on 14.07.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import TUFlixKit

struct Builder {
    
    struct ViewModel {
        
        static func episodeListViewModel(seriesId: Series.Id? = nil) -> SearchablePageListViewModel<SearchResult<Episode>, EpisodeViewModel> {
            return SearchablePageListViewModel<SearchResult<Episode>, EpisodeViewModel>(resourceProvider: { config in
                if let seriesId = seriesId {
                    return API.Series.pageEpisodes(for: seriesId, config: config).requestModel().mapError { $0 as Error }
                }
                return API.Episode.page(with: config).requestModel().mapError { $0 as Error }
            }, searchResourceProvider: { (config, searchTerm) in
                return API.Episode.search(for: searchTerm, config: config).requestModel().mapError { $0 as Error }
            },
               mapping: EpisodeViewModel.init)
        }
        
        static func seriesListViewModel() -> SearchablePageListViewModel<SearchResult<Series>, SeriesViewModel> {
            return SearchablePageListViewModel<SearchResult<Series>, SeriesViewModel>(resourceProvider: { config in
                return API.Series.page(with: config).requestModel().mapError { $0 as Error }
            }, searchResourceProvider: { (config, searchTerm) in
                return API.Series.search(for: searchTerm, config: config).requestModel().mapError { $0 as Error }
            },
               mapping: SeriesViewModel.init)
        }
    }
    
    struct ViewController {
        
        static func episodeListViewController(title: String? = L10n.Episodes.title,
                                              seriesId: Series.Id? = nil,
                                              showEpisodeNameToggle: Bool = false,
                                              showEpisodesNames: Bool = true) -> EpisodeListViewController<SearchablePageListViewModel<SearchResult<Episode>, EpisodeViewModel>> {
            let viewModel = ViewModel.episodeListViewModel(seriesId: seriesId)
            return episodeListViewController(title: title, viewModel: viewModel, showEpisodeNameToggle: showEpisodeNameToggle, showEpisodesNames: showEpisodesNames)
        }
        
        static func episodeListViewController<T: ListViewModelProtocol>(title: String? = L10n.Episodes.title,
                                                                        viewModel: T,
                                                                        showEpisodeNameToggle: Bool = false,
                                                                        showEpisodesNames: Bool = true) -> EpisodeListViewController<T> where T.Item == EpisodeViewModel {
            let vc = EpisodeListViewController(title: title, viewModel: viewModel, displayEpisodeNames: showEpisodesNames)
            vc.toolbar.isHidden = !showEpisodeNameToggle
            vc.selectEpisodeClosure = { episode in
                PlaybackCoordinator.playModally(on: vc.view.window?.topViewController() ?? vc, url: episode.playableVideoURL)
            }
            return vc
        }
        
        static func seriesListViewController(title: String? = L10n.Series.title,
                                             selectSeriesClosure: @escaping ((SeriesViewModel) -> Void)) -> SeriesListViewController<SearchablePageListViewModel<SearchResult<Series>, SeriesViewModel>> {
            let viewModel = ViewModel.seriesListViewModel()
            return seriesListViewController(title: title, viewModel: viewModel, selectSeriesClosure: selectSeriesClosure)
        }
        
        static func seriesListViewController<T: ListViewModelProtocol>(title: String? = L10n.Series.title,
                                                                       viewModel: T,
                                                                       selectSeriesClosure: @escaping ((SeriesViewModel) -> Void)) -> SeriesListViewController<T>  where T.Item == SeriesViewModel {
            let vc = SeriesListViewController(title: L10n.Series.title, viewModel: viewModel)
            vc.selectSeriesClosure = selectSeriesClosure
            return vc
        }
    }
}
