//
//  SortOption.swift
//  TUFlixKit
//
//  Created by Oliver Krakora on 29.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation

enum SortOption {
    
    enum Order: String {
        case ascending = ""
        case descending = "_DESC"
    }
    
    case recordingDate(Order)
    case publishDate(Order)
    case title(Order)
    case author(Order)
    case contributor(Order)
    case publisher(Order)
    case series
    case language
    case license
    case subject
    case description
    
    var rawValue: String {
        switch self {
        case let .recordingDate(option):
            return "DATE_CREATED" + option.rawValue
        case let .publishDate(option):
            return "DATE_PUBLISHED" + option.rawValue
        case let .title(option):
            return "TITLE" + option.rawValue
        case let .author(option):
            return "CREATOR" + option.rawValue
        case let .contributor(option):
            return "CONTRIBUTOR" + option.rawValue
        case let .publisher(option):
            return "PUBLISHER" + option.rawValue
        case .series:
            return "SERIES_ID"
        case .language:
            return "LANGUAGE"
        case .license:
            return "LICENSE"
        case .subject:
            return "SUBJECT"
        case .description:
            return "DESCRIPTION"
        }
    }
    
    var title: String {
        switch self {
        case .recordingDate:
            return "{CREATION DATE}"
        case .publishDate:
            return "{PUBLISH DATE}"
        case .title:
            return "{TITLE}"
        case .author:
            return "{AUTHOR}"
        case .contributor:
            return "{CONTRIBUTOR}"
        case .publisher:
            return "{PUBLISHER}"
        case .series:
            return "{SERIES}"
        case .language:
            return "{LANGUAGE}"
        case .license:
            return "{LICENSE}"
        case .subject:
            return "{SUBJECT}"
        case .description:
            return "{DESCRIPTION}"
        }
    }
}
