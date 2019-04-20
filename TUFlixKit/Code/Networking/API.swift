import Foundation
import Alamofire
import Fetch

public class API {
    
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
        public static func allEpisodes() -> Resource<[TUFlixKit.Episode]> {
            return Resource(
                path: "/search/episode.json",
                urlParameters: ["limit": 20, "offset": 0],
                rootKeys: ["search-results", "result"]
            )
        }
    }
    
    public struct Series {
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
