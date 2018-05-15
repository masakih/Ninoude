//
//  HTTPURLResponseExtension.swift
//  CURL
//
//  Created by Hori,Masaki on 2018/05/04.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    
    private static var dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter
    }()
    
    func expires() -> Date? {
        
        if let cc = (allHeaderFields["Cache-Control"] as? String)?.lowercased(),
            let range = cc.range(of: "max-age="),
            let s = cc[range.upperBound...]
                .components(separatedBy: ",")
                .first,
            let age = TimeInterval(s) {
            
            return Date(timeIntervalSinceNow: age)
        }
        
        if let ex = (allHeaderFields["Expires"] as? String)?.lowercased(),
            let exp = HTTPURLResponse.dateFormatter.date(from: ex) {
            
            return exp
        }
        
        return nil
    }
}
