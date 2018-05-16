//
//  AppDelegate.swift
//  TestApplication
//
//  Created by Hori,Masaki on 2018/05/13.
//  Copyright © 2018年 Hori,Masaki. All rights reserved.
//

import Cocoa

import Ninoude

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet private var textView: NSTextView!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }
    
    @IBAction private func test(_: Any) {
        
        var request = URLRequest(url: URL(string: "https://httpbin.org/headers")!)
        request.addValue("Hoge", forHTTPHeaderField: "Hoge")
        
        Ninoude(request: request)
            .futureResponse(queue: .main)
            .onSuccess { response in
                
                self.textView.string = response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "Decoding failed"
            }
            .onFailure { error in
                
                self.textView.string = error.localizedDescription
        }
    }
}
