//
//  Result+Error.swift
//  TUFlixKit
//
//  Created by Oliver Krakora on 08.05.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation

extension Result {
    public var error: Failure? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}
