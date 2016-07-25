//
//  VideoPlayer.swift
//  VSaver
//
//  Created by Jarosław Pendowski on 24/07/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Foundation
import AVFoundation

enum PlayerMode {
    case Loop
    case Random
    case Sequence
}

final class VideoPlayer {
    private let player: AVPlayer
    private let providers: [Provider]
    private var urls: [NSURL] = []
    private var urlIndex: Int = -1
    
    var mode: PlayerMode = .Random
    
    init(player: AVPlayer) {
        self.player = player
        self.providers = [ YouTubeProvider() ]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.videoDidEnd(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.videoDidFail(_:)), name: AVPlayerItemFailedToPlayToEndTimeNotification, object: nil)
        
    }
    
    func setQueue(urls: [NSURL]) {
        self.player.pause()
        
        self.urlIndex = -1
        
        self.urls = urls
        
        self.playNext()
    }
    
    private func playNext() {
        guard urls.count > 0 else {
            return
        }
        
        var index = self.urlIndex
        let total = self.urls.count
        let random = Int(arc4random())
        
        switch mode {
        case .Loop:
            if index < 0 {
                index = random % total
            }
        case .Random:
            index = random % total
        case .Sequence:
            index = (index + 1) % total
        }
        
        let url = self.urls[index]
        guard let provider = self.providers.filter({ $0.isValidURL(url) }).first else { // url is invalid, try another one
            self.urlIndex = -1
            self.urls.removeAtIndex(index)
            self.playNext()
            return
        }
        
        self.urlIndex = index
        
        provider.getVideoURL(url) { videoUrl in
            
            guard let videoUrl = videoUrl else {
                return
            }
            
            print("Playing: ", videoUrl)
            let playerItem = AVPlayerItem(URL: videoUrl)
            self.player.replaceCurrentItemWithPlayerItem(playerItem)
            self.player.volume = 0
            self.player.actionAtItemEnd = .None
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.player.play()
            })
        }
    }
    
    @objc func videoDidEnd(notification: NSNotification) {
        if let item = notification.object as? AVPlayerItem where self.player.currentItem == item {
            self.playNext()
        }
    }
    
    @objc func videoDidFail(notification: NSNotification) {
        if let item = notification.object as? AVPlayerItem where self.player.currentItem == item {
            self.playNext()
        }
    }
}