//
//  VimeoProvider.swift
//  VSaver
//
//  Created by Jarosław Pendowski on 25/07/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Foundation

final class VimeoProvider: Provider {
    
    func isValidURL(url: NSURL) -> Bool {
        return url.host?.containsString("vimeo.com") ?? false
    }
    
    func getVideoURL(url: NSURL, completion: (url: NSURL?) -> Void) {
        let failed: () -> Void = {
            dispatch_async(dispatch_get_main_queue(), { 
                completion(url: nil)
            })
        }
        let success: (NSURL?) -> Void = { url in
            dispatch_async(dispatch_get_main_queue(), {
                completion(url: url)
            })
        }
        
        guard let videoID = url.path?.componentsSeparatedByString("/").last else {
            return failed()
        }
        
        let vimeoJsonUrl = "https://player.vimeo.com/video/\(videoID)/config"
        
        guard let url = NSURL(string: vimeoJsonUrl) else {
            return failed()
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            guard let data = data,
                optJson = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject],
                json = optJson,
                request = json["request"] as? [String: AnyObject],
                files = request["files"] as? [String: AnyObject] else {
                return failed()
            }
            
            if let streams = files["progressive"] as? [ [String: AnyObject] ] {
                let urls = streams.flatMap({ VimeoProgressiveStream.fromJson($0) }).sort({ left, right in
                    left.width > right.width
                })
                
                if let videoUrl = urls.first?.videoURL {
                    return success(videoUrl)
                }
            }
            
            if let streams = files["hls"] as? [String: AnyObject ] {
                if let url = streams["url"] as? String {
                    return success(NSURL(string: url))
                }
            }
            
            failed()
        }
        task.resume()
    }
}

protocol VimeoURL {
    var videoURL: NSURL? { get }
}

struct VimeoProgressiveStream: VimeoURL {
    let url: String
    let quality: String
    let width: Int
    
    var videoURL: NSURL? {
        return NSURL(string: self.url)
    }
    
    static func fromJson(json: [String: AnyObject]) -> VimeoProgressiveStream? {
        guard let url = json["url"] as? String,
            quality = json["quality"] as? String,
            width = json["width"] as? Int else {
                return nil
        }
        
        return VimeoProgressiveStream(url: url, quality: quality, width: width)
    }
}