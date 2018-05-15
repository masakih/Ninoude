//
//  Future.swift
//  KCD
//
//  Created by Hori,Masaki on 2018/01/13.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

public enum FutureError: Error {
    
    case unsolvedFuture
    
    case noSuchElement
}

public final class Future<T> {
    
    private let semaphore: DispatchSemaphore?
    
    private var callbacks: [(Result<T>) -> Void] = []
    
    fileprivate var result: Result<T>? {
        
        willSet {
            
            if result != nil {
                
                fatalError("Result already seted.")
            }
        }
        
        didSet {
            
            guard let result = self.result else {
                
                fatalError("set nil to result.")
            }
            
            callbacks.forEach { f in f(result) }
            callbacks = []
            
            semaphore?.signal()
        }
    }
    
    var isCompleted: Bool {
        
        return result != nil
    }
    
    var value: Result<T>? {
        
        return result
    }
    
    /// Life cycle
    public init() {
        
        // for await()
        semaphore = DispatchSemaphore(value: 0)
    }
    
    public init(in queue: DispatchQueue = .global(), _ block: @escaping () throws -> T) {
        
        // for await()
        semaphore = DispatchSemaphore(value: 0)
        
        queue.async {
            
            defer { self.semaphore?.signal() }
            
            do {
                
                self.result = Result(try block())
                
            } catch {
                
                self.result = Result(error)
            }
        }
    }
    
    public init(_ result: Result<T>) {
        
        semaphore = nil
        
        self.result = result
    }
    
    public convenience init(_ value: T) {
        
        self.init(Result(value))
    }
    
    public convenience init(_ error: Error) {
        
        self.init(Result(error))
    }
    
    deinit {
        
        semaphore?.signal()
    }
}

public extension Future {
    
    ///
    @discardableResult
    func await() -> Self {
        
        if result == nil {
            
            semaphore?.wait()
            semaphore?.signal()
        }
        
        return self
    }
    
    @discardableResult
    func onComplete(_ callback: @escaping (Result<T>) -> Void) -> Self {
        
        if let r = result {
            
            callback(r)
            
        } else {
            
            callbacks.append(callback)
        }
        
        return self
    }
    
    @discardableResult
    func onSuccess(_ callback: @escaping (T) -> Void) -> Self {
        
        onComplete { result in
            
            if case let .value(v) = result {
                
                callback(v)
            }
        }
        
        return self
    }
    
    @discardableResult
    func onFailure(_ callback: @escaping (Error) -> Void) -> Self {
        
        onComplete { result in
            
            if case let .error(e) = result {
                
                callback(e)
            }
        }
        
        return self
    }
}

public extension Future {
    
    ///
    func transform<U>(_ s: @escaping (T) -> U, _ f: @escaping (Error) -> Error) -> Future<U> {
        
        return transform { result in
            
            switch result {
                
            case let .value(value): return Result(s(value))
                
            case let .error(error): return Result(f(error))
                
            }
        }
    }
    
    func transform<U>(_ s: @escaping (Result<T>) -> Result<U>) ->Future<U> {
        
        return Promise()
            .complete {
                
                self.await().value.map(s) ?? Result(FutureError.unsolvedFuture)
            }
            .future
    }
    
    func map<U>(_ t: @escaping (T) -> U) -> Future<U> {
        
        return transform(t, { $0 })
    }
    
    func flatMap<U>(_ t: @escaping (T) -> Future<U>) -> Future<U> {
        
        return Promise()
            .completeWith {
                
                switch self.await().value {
                    
                case .value(let v)?: return t(v)
                    
                case .error(let e)?: return Future<U>(e)
                    
                case .none: fatalError("Future not complete")
                    
                }
            }
            .future
    }
    
    func filter(_ f: @escaping (T) -> Bool) -> Future<T> {
        
        return Promise()
            .complete {
                
                if case let .value(v)? = self.await().value, f(v) {
                    
                    return Result(v)
                }
                
                return Result(FutureError.noSuchElement)
            }
            .future
    }
    
    func recover(_ s: @escaping (Error) throws -> T) -> Future<T> {
        
        return transform { result in
            
            do {
                
                return try result.error.map { error in Result(try s(error)) } ?? Result(FutureError.unsolvedFuture)
                
            } catch {
                
                return Result(error)
            }
        }
    }
    
    @discardableResult
    func andThen(_ f: @escaping (Result<T>) -> Void) -> Future<T> {
        
        return Promise<T>()
            .complete {
                
                guard let result = self.await().result else {
                    
                    fatalError("Future not complete")
                }
                
                f(result)
                
                return result
            }
            .future
    }
}

private extension Future {
    
    func complete(_ result: Result<T>) {
        
        self.result = result
    }
}

private let promiseQueue = DispatchQueue(label: "Promise", attributes: .concurrent)
public final class Promise<T> {
    
    public let future: Future<T> = Future<T>()
    
    ///
    public func complete(_ result: Result<T>) {
        
        future.complete(result)
    }
    
    public func success(_ value: T) {
        
        complete(Result(value))
    }
    
    public func failure(_ error: Error) {
        
        complete(Result(error))
    }
    
    public func complete(_ completor: @escaping () -> Result<T>) -> Self {
        
        promiseQueue.async {
            
            self.complete(completor())
        }
        
        return self
    }
    
    public func completeWith(_ completor: @escaping () -> Future<T>) -> Self {
        
        promiseQueue.async {
            
            completor()
                .onSuccess {
                    
                    self.success($0)
                    
                }
                .onFailure {
                    
                    self.failure($0)
                    
            }
        }
        
        return self
    }
}
