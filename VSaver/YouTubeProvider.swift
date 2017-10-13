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
    fileprivate var script: String?
    
    fileprivate var loadingUrl: URL?
    fileprivate var completion: ((URLItem?) -> Void)?
    
    override init() {
        webView = WebView()
        
        let bundle = Bundle(for: YouTubeProvider.self)
        if let path = bundle.path(forResource: "youtube", ofType: "js"), let script = try? String(contentsOfFile: path) {
            self.script = script
        }

        super.init()
        
        webView.frameLoadDelegate = self
    }

    func isValidURL(_ url: URL) -> Bool {
        guard let host = url.host else {
            return false
        }

        return host.contains("youtube.com") || host.contains("youtu.be")
    }
    
    func getVideoURL(_ url: URL, completion: @escaping (_ url: URLItem?) -> Void) {
        webView.mainFrame.stopLoading()
        
        self.completion = completion
        loadingUrl = url
        webView.mainFrame.load(URLRequest(url: url))
        
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
        if frame == sender.mainFrame, let loadingURL = loadingUrl {
            guard let script = script else {
                completion?(nil)
                return
            }
            
            let console: @convention(block) (NSString!) -> Void = { message in
                print(message)
            }
            frame.javaScriptContext.setObject(unsafeBitCast(console, to: AnyObject.self), forKeyedSubscript: "print" as NSCopying & NSObjectProtocol)
            
            // load script
            _ = frame.javaScriptContext.evaluateScript(script)
            
            let urlValue = frame.javaScriptContext.evaluateScript("vsaverGetURL()")
            let titleValue = frame.javaScriptContext.evaluateScript("vsaverGetTitle()")
            
            guard let url = urlValue, url.isString, let videoURL = URL(string: url.toString()) else {
                completion?(nil)
                return
            }
            
            let title: String
            if let value = titleValue, value.isString, let string = value.toString() {
                title = "\(string) 📽\(loadingURL.absoluteString)"
            } else {
                title = loadingURL.absoluteString
            }
            
            completion?(URLItem(title: "YouTube: \(title)", url: videoURL))
        }
    }
    
    func webView(_ sender: WebView!, didFailLoadWithError error: Error!, for frame: WebFrame!) {
        if loadingUrl != nil {
            completion?(nil)
        }
        
        loadingUrl = nil
    }
}
