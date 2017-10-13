//
//  VimeoProvider.swift
//  VSaver
//
//  Created by Jarosław Pendowski on 25/07/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Foundation

final class VimeoProvider: Provider {
    
    func isValidURL(_ url: URL) -> Bool {
        return url.host?.contains("vimeo.com") ?? false
    }
    
    func getVideoURL(_ url: URL, completion: @escaping (_ url: URLItem?) -> Void) {
        let failed: () -> Void = {
            DispatchQueue.main.async(execute: { 
                completion(nil)
            })
        }
        
        let success: (URLItem?) -> Void = { url in
            DispatchQueue.main.async(execute: {
                completion(url)
            })
        }
        
        guard let videoID = url.path.components(separatedBy: "/").last,
            case let vimeoJsonUrl = "https://player.vimeo.com/video/\(videoID)/config",
            let jsonURL = URL(string: vimeoJsonUrl) else {
            return failed()
        }
        
        let task = URLSession.shared.dataTask(with: jsonURL, completionHandler: { (data, response, error) in
            guard let data = data,
                let optJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject],
                let json = optJson,
                let request = json["request"] as? [String: AnyObject],
                let files = request["files"] as? [String: AnyObject]
                 else {
                return failed()
            }
            
            let title: String
            if let video = json["video"] as? [String: AnyObject], let videoTitle = video["title"] as? String {
                title = "\(videoTitle) 📽\(url)"
            } else {
                title = url.absoluteString
            }
            
            if let streams = files["progressive"] as? [ [String: AnyObject] ] {
                let urls = streams.flatMap({ VimeoProgressiveStream.fromJson($0) }).sorted(by: { left, right in
                    left.width > right.width
                })
                
                if let videoURL = urls.first?.videoURL {
                    return success(URLItem(title: "Vimeo: \(title)", url: videoURL))
                }
            }
            
            if let streams = files["hls"] as? [String: AnyObject ] {
                if let urlString = streams["url"] as? String, let videoURL = URL(string: urlString) {
                    return success(URLItem(title: "Vimeo: \(title)", url: videoURL))
                }
            }
            
            failed()
        }) 
        task.resume()
    }
}

protocol VimeoURL {
    var videoURL: URL? { get }
}

struct VimeoProgressiveStream: VimeoURL {
    let url: String
    let quality: String
    let width: Int
    
    var videoURL: URL? {
        return URL(string: self.url)
    }
    
    static func fromJson(_ json: [String: AnyObject]) -> VimeoProgressiveStream? {
        guard let url = json["url"] as? String,
            let quality = json["quality"] as? String,
            let width = json["width"] as? Int else {
                return nil
        }
        
        return VimeoProgressiveStream(url: url, quality: quality, width: width)
    }
}
