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

        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "http://www.youtube.com/get_video_info?video_id=iJQ36SF8BUs")!) { (data, response, error) in
            guard let data = data, string = String(data: data, encoding: NSUTF8StringEncoding)?.stringByRemovingPercentEncoding else {
                return
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

            print(urls)
        }

        task.resume()
    }

    private func

}
