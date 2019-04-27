import Foundation
import Alamofire
import Fetch

public class API {
    
    public struct PagingConfig {
        public let limit: Int
        public let offset: Int
        
        public init(limit: Int, offset: Int) {
            self.limit = limit
            self.offset = offset
        }
        
        public static let `default` = PagingConfig(limit: 20, offset: 0)
    }
    
    public static func setup() {
        APIClient.shared.setup(with: Fetch.Config(
            baseURL: Config.API.baseURL,
            timeout: Config.API.timeout,
            eventMonitors: [APILogger(verbose: Config.API.verboseLogging)],
            jsonDecoder: Decoders.standardJSON,
            cache: MemoryCache(defaultExpiration: Config.Cache.defaultExpiration),
            shouldStub: Config.API.stubRequests))
    }
    
    public struct Episode {
        
        public static func page(with config: PagingConfig = .default) -> Resource<SearchResult<TUFlixKit.Episode>> {
            return Resource(
                path: "/search/episode.json",
                urlParameters: ["limit": config.limit, "offset": config.offset],
                rootKeys: ["search-results"]
            )
        }
        
        public static func allEpisodes() -> Resource<[TUFlixKit.Episode]> {
            return Resource(
                path: "/search/episode.json",
                urlParameters: ["limit": 20, "offset": 0],
                rootKeys: ["search-results", "result"]
            )
        }
    }
    
    public struct Series {
        
        public static func page(with config: PagingConfig = .default) -> Resource<SearchResult<TUFlixKit.Series>> {
            return Resource(
                path: "/search/series.json",
                urlParameters: ["limit": config.limit, "offset": config.offset],
                rootKeys: ["search-results"]
            )
        }
        
        public static func pageEpisodes(for seriesId: String, config: PagingConfig = .default) -> Resource<SearchResult<TUFlixKit.Episode>> {
            return Resource(
                path: "/search/series.json",
                urlParameters: ["limit": config.limit, "offset": config.offset],
                rootKeys: ["search-results"]
            )
        }
        
        public static func allSeries() -> Resource<[TUFlixKit.Series]> {
            return Resource(
                path: "/search/series.json",
                urlParameters: ["limit": 20, "offset": 0],
                rootKeys: ["search-results", "result"]
            )
        }
        
        public static func fetchEpisodes(for seriesId: String) -> Resource<[TUFlixKit.Episode]> {
            return Resource(
                path: "/search/episode.json",
                urlParameters: ["limit": 20, "offset": 0, "sid": seriesId],
                rootKeys: ["search-results", "result"]
            )
        }
    }
}
