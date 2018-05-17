//
//  Chikarakobu.swift
//  CURL
//
//  Created by Hori,Masaki on 2018/04/24.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

import CurlWrapper


enum CurlError: Error {
    
    case couldNotLoad(CURLcode)
    
    case missingParseHeader
    
    case couldNotCreateHTTPURLResponse
}


class Chikarakobu {
    
    class WriteData {
        
        var data = Data()
        
        func append(_ new: Data) {
            
            data.append(new)
        }
    }
    
    static var version: String {
        
        guard let vers = curl_version() else {
            
            return ""
        }
        
        return String(cString: vers)
    }
    
    static var userAgent: String = "CURL 1.0"
    
    let curl: UnsafeMutableRawPointer
    
    init() {
        
        curl = curl_easy_init()
    }
    
    deinit {
        
        curl_easy_cleanup(curl)
    }
    
    var url: URL? {
        
        didSet {
            
            guard var urlString = url?.absoluteString.cString(using: .utf8) else {
                
                print("Can not convert URL String to [UInt8]")
                
                return
            }
            
            CWSetUrl(curl, &urlString)
        }
    }
    
    var timeout: TimeInterval = 0 {
        
        didSet {
            
            guard timeout != 0 else {
                
                return
            }
            
            CWSetTimeout(curl, Int(timeout))
        }
    }
    
    var method: String? {
        
        didSet {
            
            guard let method = method?.uppercased() else {
                
                return
            }
            
            switch method {
                
            case "GET":
                CWSetMethod(curl, GET)
                
            case "POST":
                CWSetMethod(curl, POST)
                
            case "PUT":
                CWSetMethod(curl, PUT)
                
            default:
                print("Method unknown", method)
                return
            }
            
        }
    }
    
    var headers: [String: String]? {
        
        didSet {
            
            guard let h = headers.map({ $0.map { key, value in key + ": " + value } }) else {
                
                return
            }
            
            let slist: UnsafeMutablePointer<curl_slist>? = nil
            let list = h.reduce(slist) { curl_slist_append($0, $1) }
            CWSetHeaders(curl, list)
            
            // TODO: list leaked
        }
    }
    
    var body: Data? {
        
        didSet {
            
            guard body != nil else {
                
                CWSetBody(curl, nil)
                
                return
            }
            
            guard var bodyString = String(data: body!, encoding: .utf8)?.cString(using: .utf8) else {
                
                print("Can not convert URL String to [UInt8]")
                
                return
            }
            
            CWSetBody(curl, &bodyString)
        }
    }
    
    var cookieFile: URL? {
        
        didSet {
            
            guard let path = cookieFile?.path else {
                
                return
            }
            
            guard var pathString = path.cString(using: .utf8) else {
                
                print("Can not convert URL String to [UInt8]")
                
                return
            }
            
            CWSetCookieFile(curl, &pathString)
        }
    }
    
    // only use in perform()
    // curl_easy_setuseragent用
    /// headerにUAがあればcurl_easy_setuseragentに値を設定する必要がないのでnilを返す
    /// UAがなければクラス変数のuseragentの値を返す
    private func userAgent() -> [Int8]? {
        
        if headers?["User-Agent"]?.cString(using: .utf8) == nil {
            
            return type(of: self).userAgent.cString(using: .utf8)
        }
        
        return nil
    }
    
    func perform() -> Result<(HTTPURLResponse, Data)> {
        
        if var ua = userAgent() {
        
            CWSetUseragent(curl, &ua)
        }
        
        var headerData = WriteData()
        CWSetHeaderData(curl, &headerData)
        CWSetWriteHeaderFunc(curl, writeData)
        
        var bodyData = WriteData()
        CWSetData(curl, &bodyData)
        CWSetWriteFunc(curl, writeData)
        
        let result = curl_easy_perform(curl)
        
        guard result.rawValue == 0 else {
            
            print("load error.", result)
            
            return Result(CurlError.couldNotLoad(result))
        }
        
        guard let (httpVersion, httpStatus, fields) = parseHeader(data: headerData.data) else {
            
            return Result(CurlError.missingParseHeader)
        }
        
        guard let respons = HTTPURLResponse(url: url!, statusCode: httpStatus, httpVersion: httpVersion, headerFields: fields) else {
            
            return Result(CurlError.couldNotCreateHTTPURLResponse)
        }
        
        return Result((respons, bodyData.data))
    }
}

func writeData(rawData: UnsafeMutablePointer<Int8>?, unitSize: Int, unitCount: Int, stream: UnsafeMutableRawPointer?) -> Int {
    
    let size = unitSize * unitCount
    
    guard let newData = rawData.map({ Data(bytes: $0, count: size) }) else {
        
        return 0
    }
    
    guard let data = stream?.load(as: Chikarakobu.WriteData.self) else {
        
        return 0
    }
    
    data.append(newData)
    
    return size
}

func parseHeader(data: Data) -> (version: String, status: Int, fields: [String: String])? {
    
    guard let header = String(data: data, encoding: .utf8)?.split(separator: "\r\n") else {
        
        return nil
    }
    
    guard let status = header.first else {
        
        return nil
    }
    
    let stat = status.split(separator: " ")
    guard stat.count >= 3 else {
        
        return nil
    }
    
    let httpVersion = String(stat[0])
    let httpStatus = Int(stat[1]) ?? -1
    
    let headers = header
        .dropFirst()
        .map { parseHeaderFields(header: String($0)) }
        .reduce(into: [String: String]()) { $0.merge($1) { (_, new) in new } }
    
    return (version: httpVersion, status: httpStatus, fields: headers)
}

func parseHeaderFields(header: String) -> [String: String] {
    
    let keyValue = header.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
    
    guard keyValue.count == 2 else {
        
        return [:]
    }
    
    func trim(_ s: String) -> String {
        
        guard let h = s.first else {
            
            return s
        }
        
        if h != " " {
            
            return s
        }
        
        return trim(String(s.dropFirst()))
    }
    
    return [String(keyValue[0]): trim(String(keyValue[1]))]
}

