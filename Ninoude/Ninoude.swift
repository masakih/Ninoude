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
    
    private var redirectFunctions: [(URLRequest, HTTPURLResponse) -> Void] = []
    
    public init(queue: DispatchQueue = .global(), preference: NinoudePreference = .default, request: URLRequest) {
        
        self.taskQueue = queue
        
        self.preference = preference
        
        self.request = request
    }
    
    public func response() -> Result<Response> {
        
        return response(for: request)
    }
    
    public func futureResponse(queue: DispatchQueue = .global()) -> Future<Response> {
        
        let promise = Promise<Response>()
        
        taskQueue.async {
            
            let result = self.response()
            
            queue.sync { promise.complete(result) }
        }
        
        return promise.future
    }
    
    public func didRedirect(_ f: @escaping (URLRequest, HTTPURLResponse) -> Void) -> Self {
        
        redirectFunctions.append(f)
        
        return self
    }
    
    private func isRedirect(response: Response) -> Bool {
        
        guard let status = response.response?.statusCode else {
            
            return false
        }
        
        switch status {
            
        case 301, 302, 303, 307, 308:  return true
            
        default: return false
        }
    }
    
    private func redirectURL(from original: URL, for location: String) -> URL? {
        
        if location.hasPrefix("http") {
            
            return URL(string: location)
        }
        
        return URL(string: location, relativeTo: original)?.standardized.absoluteURL
    }
    
    private func redirectIfNeeds(response: Response) -> Result<Response> {
        
        guard let redirecetResponse = response.response else {
            
            fatalError("Redirect response has no response.")
        }
        
        if self.isRedirect(response: response),
            let newLocation = redirecetResponse.allHeaderFields["Location"] as? String,
            let originalURL = response.request?.url,
            let newURL = redirectURL(from: originalURL, for: newLocation) {
            
            let newRequest = URLRequest(url: newURL)
            
            redirectFunctions.forEach { $0(newRequest, redirecetResponse) }
            
            return self.response(for: newRequest)
        }
        
        return Result(response)
    }
    
    private func response(for request: URLRequest) -> Result<Response> {
        
        if let cachedResponse = preference.cache.validCache(for: request) {
            
            let result = Response(request: request,
                                  response: cachedResponse.response as? HTTPURLResponse,
                                  data: cachedResponse.data)
            
            return Result(result)
                .flatMap(transform: self.redirectIfNeeds(response:))
        }
        
        Chikarakobu.userAgent = type(of: self).userAgent
        
        let curl = Chikarakobu()
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
            .flatMap(transform: self.redirectIfNeeds(response:))
    }
}
