import Foundation
import Fetch

/// Global set of configuration values for this application.
public struct Config {
    static let keyPrefix = "at.allaboutapps"

    // MARK: API

    public struct API {
        
        static var baseURL: URL {
            return URL(string: "https://oc-presentation.ltcc.tuwien.ac.at")!
        }

        static let stubRequests = false
        static var timeout: TimeInterval = 120.0

        static var verboseLogging: Bool {
            return false
            switch Environment.current() {
            case .debug, .staging:
                return true
            case .release:
                return false
            }
        }
    }
    
    public static var seriesCheckInterval: TimeInterval {
        switch Environment.current() {
        case .debug:
            // Check every minute for new series
            return 60
        default:
            // Check every eight hours for new series
            return 3600 * 8
        }
    }
    
    public struct Notification {
        public struct SeriesEpisodeUpdate {
            public static let threadIdentifier = "SeriesEpisodeUpdate"
            
            public static let categoryIdentifier = threadIdentifier
        }
    }
    
    // MARK: Cache
    
    public struct Cache {
        static let defaultExpiration: Expiration = .seconds(5 * 60.0)
    }

    // MARK: User Defaults

    public struct UserDefaultsKey {
        static let lastUpdate = Config.keyPrefix + ".lastUpdate"
    }

    // MARK: Keychain

    public struct Keychain {
        static let credentialStorageKey = "CredentialsStorage"
        static let credentialsKey = "credentials"
    }
}
