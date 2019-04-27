//
//  PagedResource.swift
//  Fetch
//
//  Created by Oliver Krakora on 12.04.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import Foundation
import Fetch

public enum PagingError: Error {
    case pagingInProgress
    case fetchError(FetchError)
}

public class PagedResource<Page: PageProtocol> {
    
    public typealias PageResourceConstructor = ((Resource<Page>, Page) -> Resource<Page>)
    
    public typealias PageResultClosure = ((Result<Page, PagingError>) -> Void)
    
    private let initialPage: Resource<Page>
    
    private var currentPage: Resource<Page>
    
    public private(set) var hasMorePages: Bool = true
    
    public private(set) var pages: [Page] = []
    
    private var currentPageRequestToken: RequestToken?
    
    public let constructPageResource: PageResourceConstructor
    
    /// - Parameter initialPage: The initial page where the paging begins
    /// - Parameter resourceConstructor: A closure which provides the next page for a given Resource
    public init(initalPage: Resource<Page>, resourceConstructor: @escaping PageResourceConstructor) {
        self.initialPage = initalPage
        self.currentPage = initalPage
        self.constructPageResource = resourceConstructor
    }
    
    public func loadNext(force: Bool = false, _ callback: @escaping PageResultClosure) {
        if force {
            reset()
        }
        guard currentPageRequestToken == nil || currentPageRequestToken!.isCancelled else {
            callback(.failure(.pagingInProgress))
            return
        }
        
        currentPageRequestToken = currentPage.request(completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let value):
                if value.model.items.count == 0 || (self.pages.first?.total != nil && (self.pages.first?.total == value.model.total)) {
                    self.hasMorePages = false
                }
                self.pages.append(value.model)
                callback(.success(value.model))
            case .failure(let error):
                print(error)
                callback(.failure(.fetchError(error)))
            }
            
            self.currentPageRequestToken = nil
        })
    }
    
    public func reset() {
        currentPageRequestToken?.cancel()
        currentPageRequestToken = nil
        hasMorePages = true
        currentPage = initialPage
        pages.removeAll()
    }
}
