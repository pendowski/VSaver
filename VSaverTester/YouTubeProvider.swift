//
//  YouTubeProvider.swift
//  VSaver
//
//  Created by Jaroslaw Pendowski on 7/22/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Foundation


final class YouTubeProvider: Provider {

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

            var quality: String?
            var url: String?

            string.componentsSeparatedByString("&").forEach({ (item) in
                let b = item.componentsSeparatedByString("=")

                if b[0] == "quality" {
                    quality = b[1]
                }

                if b[0] == "url" {
                    url = b[1]
                }

                if let q = quality, u = url?.stringByRemovingPercentEncoding {
                    urls[q] = u

                    quality = nil
                    url = nil
                }
            })

            guard let videoUrl = urls["hd1080"] ?? urls["hd720"] ?? urls.first?.1 else {
                return failed()
            }

            completion(url: NSURL(string: videoUrl))
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
