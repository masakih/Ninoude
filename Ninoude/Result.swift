//
//  Result.swift
//  CURL
//
//  Created by Hori,Masaki on 2018/05/08.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

public enum Result<Value> {
    
    case value(Value)
    
    case error(Error)
    
    init(_ value: Value) {
        
        self = .value(value)
    }
    
    init(_ error: Error) {
        
        self = .error(error)
    }
}
public extension Result {
    
    var value: Value? {
        
        if case let .value(value) = self { return value }
        
        return nil
    }
    
    var error: Error? {
        
        if case let .error(error) = self { return error }
        
        return nil
    }
}

public extension Result {
    
    @discardableResult
    func ifValue(_ f: (Value) -> Void) -> Result {
        
        if case let .value(value) = self {
            
            f(value)
        }
        
        return self
    }
    
    @discardableResult
    func ifError(_ f: (Error) -> Void) -> Result {
        
        if case let .error(error) = self {
            
            f(error)
        }
        
        return self
    }
}

public extension Result {
    
    func map<T>(transform: (Value) -> T) -> Result<T> {
        
        switch self {
            
        case let .value(value): return Result<T>(transform(value))
            
        case let .error(error): return Result<T>(error)
        }
    }
    
    func flatMap<T>(transform: (Value) -> Result<T>) -> Result<T> {
        
        switch self {
            
        case let .value(value): return transform(value)
            
        case let .error(error): return Result<T>(error)
        }
    }
}
