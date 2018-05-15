//
//  URLCacheExtension.swift
//  CURL
//
//  Created by Hori,Masaki on 2018/05/04.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

extension URLCache {
    
    private static let infoExpiresKey = "Expires"
    
    func storeIfNeeded(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        
        if let response = cachedResponse.response as? HTTPURLResponse,
            let expires = response.expires() {
            
            let cache = CachedURLResponse(response: response,
                                          data: cachedResponse.data,
                                          userInfo: [URLCache.infoExpiresKey: expires],
                                          storagePolicy: .allowed)
            storeCachedResponse(cache, for: request)
        }
    }
    
    func validCache(for request: URLRequest) -> CachedURLResponse? {
        
        if let cache = cachedResponse(for: request),
            let info = cache.userInfo,
            let expires = info[URLCache.infoExpiresKey] as? Date,
            Date().compare(expires) == .orderedAscending {
            
            return cache
        }
        
        return nil
    }
}

