//
//  Episode.swift
//  TUFlixKit
//
//  Created by Oliver Krakora on 19.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import Fetch

public struct Episode: Equatable, Cacheable {
    
    public struct MediaPackage: Equatable, Codable {
        
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
        
        public struct Creator: Equatable, Codable {
            public let creator: String
        }
        
        public struct Media: Equatable, Codable {
            public enum MimeType: String, Codable {
                case mp4 = "video/mp4"
                case mpeg = "audio/mpeg"
                case other
            }
            
            private enum CodingKeys: String, CodingKey {
                case id
                case mimeType = "mimetype"
                case url
                case durationInMs = "duration"
            }
            
            public let id: String?
            public let mimeType: MimeType?
            public let url: URL?
            public let durationInMs: Int?
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
