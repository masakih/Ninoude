//
//  Response.swift
//  CURL
//
//  Created by Hori,Masaki on 2018/05/07.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation


public struct Response {
    
    public let request: URLRequest?
    
    public let response: HTTPURLResponse?
    
    public let data: Data?
    
}

