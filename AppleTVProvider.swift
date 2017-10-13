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
    
    private let jsonURL = URL(string: "http://a1.phobos.apple.com/us/r1000/000/Features/atv/AutumnResources/videos/entries.json")!
    private var cache: [Item] = []
    
    func isValidURL(_ url: URL) -> Bool {
        return url.host?.contains("apple.com") ?? false || url.scheme == "appletv"
    }
    
    func getVideoURL(_ url: URL, completion: @escaping (_ url: URLItem?) -> Void) {
        if url.scheme == "appletv" {
            
            func getRandomFromCache() -> URLItem {
                let random = Int(arc4random()) % (cache.count - 1)
                let screensaverItem = cache[random]
                return URLItem(title: "AppleTV: #\(screensaverItem.index) \(screensaverItem.label)", url: screensaverItem.url)
            }
            
            if cache.count > 0 {
                return completion(getRandomFromCache())
            }
            
            URLSession.shared.dataTask(with: jsonURL, completionHandler: { (data, response, error) in
                guard let data = data,
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
                            let index = self.cache.count + 1
                            
                            self.cache.append(Item(index: index, label: label, url: url))
                        }
                }
                
                completion(getRandomFromCache())
                
            }).resume()
        } else {
            completion(URLItem(title: url.absoluteString, url: url))
        }
    }
}
