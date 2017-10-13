//
//  AppleTVProvider.swift
//  VSaver
//
//  Created by Jarek Pendowski on 12/10/2017.
//  Copyright © 2017 Jaroslaw Pendowski. All rights reserved.
//

import Foundation

final class AppleTVProvider: Provider {
    
    private let jsonURL = URL(string: "http://a1.phobos.apple.com/us/r1000/000/Features/atv/AutumnResources/videos/entries.json")!
    private var cache: [URL] = []
    
    func isValidURL(_ url: URL) -> Bool {
        return url.host?.contains("apple.com") ?? false || url.scheme == "appletv"
    }
    
    func getVideoURL(_ url: URL, completion: @escaping (_ url: URL?) -> Void) {
        if url.scheme == "appletv" {
            
            func getRandomFromCache() -> URL {
                let random = Int(arc4random()) % (cache.count - 1)
                let screensaverURL = cache[random]
                return screensaverURL
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
                            
                            self.cache.append(url)
                        }
                }
                
                completion(getRandomFromCache())
                
            }).resume()
        } else {
            completion(url)
        }
    }
}
