//
//  YouTubeProvider.swift
//  VSaver
//
//  Created by Jaroslaw Pendowski on 7/22/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Foundation
import WebKit

final class YouTubeProvider: NSObject, Provider, WebFrameLoadDelegate {
    private let webView: WebView
    private var script: String? = nil
    
    private var loadingUrl: NSURL?
    private var completion: ((NSURL?) -> Void)?
    
    override init() {
        self.webView = WebView()
        
        let bundle = NSBundle(forClass: YouTubeProvider.self)
        if let path = bundle.pathForResource("youtube", ofType: "js"), script = try? String(contentsOfFile: path) {
            self.script = script
        }

        super.init()
        
        self.webView.frameLoadDelegate = self
    }

    func isValidURL(url: NSURL) -> Bool {
        guard let host = url.host else {
            return false
        }

        return host.containsString("youtube.com") || host.containsString("youtu.be")
    }
    
    func getVideoURL(url: NSURL, completion: (url: NSURL?) -> Void) {
        
        self.webView.mainFrame.stopLoading()
        
        self.completion = completion
        self.loadingUrl = url
        self.webView.mainFrame.loadRequest(NSURLRequest(URL: url))
        
    }

    private func idFromURL(url: NSURL) -> String? {
        let components = NSURLComponents(string: url.absoluteString)

        if let component = components?.queryItems?.filter({ $0.name == "v" }).first {
            return component.value
        }

        return url.path
    }

    // Web Frame Load delegate
    
    func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
        if frame == sender.mainFrame && self.loadingUrl != nil {
            guard let script = self.script else {
                self.completion?(nil)
                return
            }
            
            let console: @convention(block) (NSString!) -> Void = { message in
                print(message)
            }
            frame.javaScriptContext.setObject(unsafeBitCast(console, AnyObject.self), forKeyedSubscript: "print")
            
            let value = frame.javaScriptContext.evaluateScript(script)
            guard value.isString, let url = NSURL(string: value.toString()) else {
                self.completion?(nil)
                return
            }
            
            self.completion?(url)
        }
    }
    
    func webView(sender: WebView!, didFailLoadWithError error: NSError!, forFrame frame: WebFrame!) {
        if self.loadingUrl != nil {
            self.completion?(nil)
        }
        
        self.loadingUrl = nil
    }
}
