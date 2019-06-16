//
//  Episode.swift
//  TUFlixKit
//
//  Created by Oliver Krakora on 19.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import Fetch

public struct Episode: Hashable, Codable {
    
    public struct MediaPackage: Hashable, Codable {
        
        private enum CodingKeys: String, CodingKey {
            case id
            case durationInMs = "duration"
            case media
            case creator = "creators"
        }
        
        public let id: String?
        public let durationInMs: String?
        public let media: Media?
        public let creator: Creator?
        
        public struct Creator: Hashable, Codable {
            public let creator: String?
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.creator = try? container.decode(String.self, forKey: .creator)
            }
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try? container.decodeIfPresent(String.self, forKey: .id)
            self.durationInMs = try? container.decodeIfPresent(String.self, forKey: .durationInMs)
            self.media = try? container.decodeIfPresent(Media.self, forKey: .media)
            self.creator = try? container.decodeIfPresent(Creator.self, forKey: .creator)
        }
        
        public struct Media: Hashable, Codable {
            
            private enum CodingKeys: String, CodingKey {
                case tracks = "track"
            }
            
            public struct Track: Hashable, Codable {
                private enum CodingKeys: String, CodingKey {
                    case id
                    case mimeType = "mimetype"
                    case url
                    case durationInMs = "duration"
                }
                
                public enum MimeType: String, Codable {
                    case mp4 = "video/mp4"
                    case mpeg = "audio/mpeg"
                    case mp3 = "audio/mp3"
                    case other
                    
                    public init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        self = try MimeType(rawValue: container.decode(String.self)) ?? .other
                    }
                }
                
                public let id: String?
                public let mimeType: MimeType?
                public let url: URL?
                public let durationInMs: Int?
            }
            
            public let tracks: [Track]?
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title = "dcTitle"
        case created = "dcCreated"
        case mediaPackage = "mediapackage"
    }
    
    public let id: String
    public let title: String?
    public let created: Date?
    public let mediaPackage: MediaPackage?
}
