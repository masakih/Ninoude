//
//  Ninoude.swift
//  CURL
//
//  Created by Hori,Masaki on 2018/05/05.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

public struct NinoudePreference {
    
    let cache: URLCache
    
    let cookieURL: URL
}

public extension NinoudePreference {
    
    static let `default` = NinoudePreference(cache: URLCache.shared,
                                             cookieURL: ApplicationDirecrories.support.appendingPathComponent("Cookie.txt"))
}

public class Ninoude {
    
    public static var userAgent: String = "Ninoude/1.0"
    
    private let taskQueue: DispatchQueue
    
    public let preference: NinoudePreference
    
    public let request: URLRequest
    
    public init(queue: DispatchQueue = .global(), preference: NinoudePreference = .default, request: URLRequest) {
        
        self.taskQueue = queue
        
        self.preference = preference
        
        self.request = request
    }
    
    public func response() -> Result<Response> {
        
        if let cachedResponse = preference.cache.validCache(for: request) {
            
            let result = Response(request: request,
                                    response: cachedResponse.response as? HTTPURLResponse,
                                    data: cachedResponse.data)
            
            return Result(result)
        }
        
        Curl.userAgent = type(of: self).userAgent
        
        let curl = Curl()
        curl.url = request.url
        curl.method = request.httpMethod
        curl.headers = request.allHTTPHeaderFields
        curl.body = request.httpBody
        
        curl.cookieFile = preference.cookieURL
        
        return curl.perform()
            .ifValue { (response, data) in
                
                preference.cache
                    .storeIfNeeded(CachedURLResponse(response: response, data: data), for: request)
            }
            .map { (response, data) in
                
                Response(request: request, response: response, data: data)
        }
    }
    
    public func futureResponse(queue: DispatchQueue = .global()) -> Future<Response> {
        
        let promise = Promise<Response>()
        
        taskQueue.async {
            
            let result = self.response()
            
            queue.sync { promise.complete(result) }
        }
        
        return promise.future
    }
}
