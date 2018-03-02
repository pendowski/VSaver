//
//  WistiaProvider.swift
//  VSaver
//
//  Created by Jarek Pendowski on 16/10/2017.
//  Copyright © 2017 Jaroslaw Pendowski. All rights reserved.
//

import Foundation
import WebKit

final class WistiaProvider: NSObject, Provider, WebFrameLoadDelegate {
    fileprivate let webView: WebView
    fileprivate let jsContext: JSContext
    fileprivate var script: String?
    
    fileprivate var loadingUrl: URL?
    fileprivate var completion: ((URLItem?) -> Void)?
    
    override init() {
        webView = WebView()
        webView.preferences.arePlugInsEnabled = false
        
        jsContext = JSContext(virtualMachine: JSVirtualMachine())
        
        let bundle = Bundle(for: YouTubeProvider.self)
        if let path = bundle.path(forResource: "wistia", ofType: "js"), let script = try? String(contentsOfFile: path) {
            self.script = script
        }
        
        super.init()
        
        webView.frameLoadDelegate = self
    }
    
    func isValidURL(_ url: URL) -> Bool {
        guard let host = url.host else {
            return false
        }
        return host.contains("wistia.com")
    }
    
    func getVideoURL(_ url: URL, completion: @escaping (_ url: URLItem?) -> Void) {
        webView.mainFrame.stopLoading()
        
        self.completion = completion
        loadingUrl = url
        webView.mainFrame.load(URLRequest(url: url))
    }
    
    fileprivate func idFromURL(_ url: URL) -> String? {
        let components = URLComponents(string: url.absoluteString)
        guard let pathComponents = components?.path.lowercased().components(separatedBy: "/"),
            let mediasIndex = pathComponents.index(where: { $0 == "medias" }) else {
            return nil
        }
        
        let idIndex = pathComponents.index(after: mediasIndex)
        let id = pathComponents[idIndex]
        
        return String(id)
    }
    
    // Web Frame Load delegate
    
    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
        if frame == sender.mainFrame,
            let loadingURL = loadingUrl,
            let videoID = idFromURL(loadingURL) {
            
            func configurationAddress(from domScripts: DOMNodeList) -> String? {
                for i in 0 ..< domScripts.length {
                    guard let node = domScripts.item(i) else { continue }
                    
                    for j in 0 ..< node.attributes.length {
                        guard let attribute = node.attributes.item(j) else { continue }
                        if attribute.nodeName == "src" && attribute.nodeValue.contains(videoID) && attribute.nodeValue.contains(".json"), let src = attribute.nodeValue {
                            return src.hasPrefix("//") ? loadingURL.scheme! + "://" + src.substring(from: src.index(src.startIndex, offsetBy: 2)) : src
                        }
                    }
                }
                
                return nil
            }
            
            guard let script = script,
                let domScripts = frame.domDocument.querySelectorAll("script"),
                let configurationAddress = configurationAddress(from: domScripts) else {
                completion?(nil)
                return
            }
            
            _ = frame.javaScriptContext.evaluateScript(script)
            let titleValue = frame.javaScriptContext.evaluateScript("vsaverGetTitle()")
            
            let title: String
            if let value = titleValue, value.isString, let string = value.toString() {
                title = "\(string) 📽\(loadingURL.absoluteString)"
            } else {
                title = loadingURL.absoluteString
            }
            
            let configurationURL = URL(string: configurationAddress)!
            URLSession.shared.dataTask(with: configurationURL, completionHandler: { (data, response, error) in
                guard let data = data,
                    let jsonp: NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue),
                    let windowReplacementRegex = try? NSRegularExpression(pattern: "window([^=]+)", options: [.caseInsensitive])
                    else {
                    self.completion?(nil)
                    return
                }
                
                let configuration = windowReplacementRegex.stringByReplacingMatches(in: jsonp as String, options: [], range: NSMakeRange(0, jsonp.length), withTemplate: "vsaver.json")
                _ = self.jsContext.evaluateScript("var vsaver = {}")    // create object to put json into
                _ = self.jsContext.evaluateScript(configuration)        // load jsonp
                _ = self.jsContext.evaluateScript(script)               // load script
                
                let urlValue = self.jsContext.evaluateScript("vsaverGetURL()")
                guard let value = urlValue, value.isString, let string = value.toString(), let videoURL = URL(string: string) else {
                    self.completion?(nil)
                    return
                }
                
                self.completion?(URLItem(title: "WISTIA: \(title)", url: videoURL))
            }).resume()
            
        }
    }
    
    func webView(_ sender: WebView!, didFailLoadWithError error: Error!, for frame: WebFrame!) {
        if loadingUrl != nil {
            completion?(nil)
        }
        
        loadingUrl = nil
    }
}
