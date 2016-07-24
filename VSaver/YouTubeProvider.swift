//
//  YouTubeProvider.swift
//  VSaver
//
//  Created by Jaroslaw Pendowski on 7/22/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Foundation


final class YouTubeProvider: Provider {
    private let compatibleItags = ["95", "299", "266", "137", "22", "136", "135", "134", "18", "133", "160"]

    func isValidURL(url: NSURL) -> Bool {
        guard let host = url.host else {
            return false
        }

        return host.containsString("youtube.com") || host.containsString("youtu.be")
    }
    
    func getVideoURL(url: NSURL, completion: (url: NSURL?) -> Void) {
        let failed = { completion(url: nil) }
        
        guard let id = self.idFromURL(url), videoInfoURL = NSURL(string: "http://www.youtube.com/get_video_info?video_id=\(id)")  else {
            return failed()
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(videoInfoURL) { (data, response, error) in
            
            guard let data = data, string = String(data: data, encoding: NSUTF8StringEncoding)?.stringByRemovingPercentEncoding else {
                return failed()
            }
            
            var urls: [String : String] = [ : ]
            
            var itag: String?
            var url: String?
            
            string.componentsSeparatedByString("&").forEach({ line in
                let components = line.componentsSeparatedByString("=")
                
                let key = components[0]
                if key != "itag" && key != "url" {
                    return
                }
                
                guard let value = components[1].stringByRemovingPercentEncoding else {
                    return
                }
                
                if key == "itag" {
                    itag = value
                }
                if key == "url" {
                    url = value
                }
                
                if let tag = itag, videoUrl = url {
                    urls[tag] = videoUrl
                    
                    itag = nil
                    url = nil
                }
                
            })
            
            guard let videoUrl = self.compatibleItags.flatMap({
                return urls[$0]
            }).first else {
                return failed()
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(url: NSURL(string: videoUrl))
            })
        }
        
        task.resume()
    }

    private func idFromURL(url: NSURL) -> String? {
        let components = NSURLComponents(string: url.absoluteString)

        if let component = components?.queryItems?.filter({ $0.name == "v" }).first {
            return component.value
        }

        return url.path
    }

}
