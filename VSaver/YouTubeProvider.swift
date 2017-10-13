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
    fileprivate let webView: WebView
    fileprivate var script: String? = nil
    
    fileprivate var loadingUrl: URL?
    fileprivate var completion: ((URL?) -> Void)?
    
    override init() {
        self.webView = WebView()
        
        let bundle = Bundle(for: YouTubeProvider.self)
        if let path = bundle.path(forResource: "youtube", ofType: "js"), let script = try? String(contentsOfFile: path) {
            self.script = script
        }

        super.init()
        
        self.webView.frameLoadDelegate = self
    }

    func isValidURL(_ url: URL) -> Bool {
        guard let host = url.host else {
            return false
        }

        return host.contains("youtube.com") || host.contains("youtu.be")
    }
    
    func getVideoURL(_ url: URL, completion: @escaping (_ url: URL?) -> Void) {
        
        self.webView.mainFrame.stopLoading()
        
        self.completion = completion
        self.loadingUrl = url
        self.webView.mainFrame.load(URLRequest(url: url))
        
    }

    fileprivate func idFromURL(_ url: URL) -> String? {
        let components = URLComponents(string: url.absoluteString)

        if let component = components?.queryItems?.filter({ $0.name == "v" }).first {
            return component.value
        }

        return url.path
    }

    // Web Frame Load delegate
    
    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
        if frame == sender.mainFrame && self.loadingUrl != nil {
            guard let script = self.script else {
                self.completion?(nil)
                return
            }
            
            let console: @convention(block) (NSString!) -> Void = { message in
                print(message)
            }
            frame.javaScriptContext.setObject(unsafeBitCast(console, to: AnyObject.self), forKeyedSubscript: "print" as NSCopying & NSObjectProtocol)
            
            let value = frame.javaScriptContext.evaluateScript(script)
            guard (value?.isString)!, let url = URL(string: (value?.toString())!) else {
                self.completion?(nil)
                return
            }
            
            self.completion?(url)
        }
    }
    
    func webView(_ sender: WebView!, didFailLoadWithError error: Error!, for frame: WebFrame!) {
        if self.loadingUrl != nil {
            self.completion?(nil)
        }
        
        self.loadingUrl = nil
    }
}
