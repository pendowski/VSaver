//
//  AppleTVProvider.swift
//  VSaver
//
//  Created by Jarek Pendowski on 12/10/2017.
//  Copyright © 2017 Jaroslaw Pendowski. All rights reserved.
//

import Foundation

final class AppleTVProvider: Provider {
    
    struct Item {
        let index: Int
        let label: String
        let url: URL
    }
    
    enum Index {
        case random
        case index(Int)
    }
    
    private let jsonURL = URL(string: "http://a1.phobos.apple.com/us/r1000/000/Features/atv/AutumnResources/videos/entries.json")!
    private var cache: [Item] = []
    
    func isValidURL(_ url: URL) -> Bool {
        return url.host?.contains("apple.com") ?? false || url.scheme == "appletv"
    }
    
    func getVideoURL(_ url: URL, completion: @escaping (_ url: URLItem?) -> Void) {
        if url.scheme == "appletv" {
            
            let playIndex: Index
            if let indexString = url.host ?? url.fragment, let index = Int(indexString), index > 0 {
                playIndex = .index(index - 1) // - 1 because we present human indexes
            } else {
                playIndex = .random
            }
            
            if cache.count > 0 {
                return completion(getItemFromCache(at: playIndex))
            }
            
            URLSession.shared.dataTask(with: jsonURL, completionHandler: { [weak self] (data, response, error) in
                guard let strongSelf = self,
                    let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let jsonDictionary = json as? [NSDictionary]else {
                    return completion(nil)
                }
                
                jsonDictionary.flatMap {
                    return $0["assets"] as? [[String: String]]
                    }.forEach { arr in
                        for obj in arr {
                            guard let string = obj["url"], let url = URL(string: string) else {
                                continue
                            }
                            
                            let label = obj["accessibilityLabel"] ?? ""
                            let index = strongSelf.cache.count + 1
                            
                            strongSelf.cache.append(Item(index: index, label: label, url: url))
                        }
                }
                
                completion(strongSelf.getItemFromCache(at: playIndex))
                
            }).resume()
        } else {
            completion(URLItem(title: url.absoluteString, url: url))
        }
    }
    
    // MARK: - Private
    
    private func getItemFromCache(at playIndex: Index) -> URLItem {
        switch playIndex {
        case .random:
            return getRandomFromCache()
        case .index(let index):
            if index < cache.count {
                let screensaverItem = cache[index]
                return URLItem(title: "AppleTV: #\(screensaverItem.index) \(screensaverItem.label)", url: screensaverItem.url)
            } else {
                return getRandomFromCache()
            }
        }
        
    }
    
    private func getRandomFromCache() -> URLItem {
        let random = Int(arc4random()) % (cache.count - 1)
        let screensaverItem = cache[random]
        return URLItem(title: "AppleTV: #\(screensaverItem.index) \(screensaverItem.label)", url: screensaverItem.url)
    }
}
