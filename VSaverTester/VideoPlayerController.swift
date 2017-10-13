//
//  VideoPlayer.swift
//  VSaver
//
//  Created by Jarosław Pendowski on 24/07/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Foundation
import AVFoundation

protocol VideoPlayerControllerDelegate: class {
    func videoPlayerController(_ controller: VideoPlayerController, willLoadVideo: URL)
    func videoPlayerController(_ controller: VideoPlayerController, didLoadVideo: URL?)
}

final class VideoPlayerController {
    
    enum Mode: Int {
        case random = 1
        case sequence = 0
    }
    
    static let shared: VideoPlayerController = VideoPlayerController()
    
    private var players: [AVPlayer] = []
    private var _volume: Float = 1
    private let providers: [Provider]
    private var urls: [URL] = []
    private var urlIndex: Int = -1
    private var delegates = NSHashTable<AnyObject>(options: NSHashTableWeakMemory)
    private var allDelegates: [VideoPlayerControllerDelegate] {
        return delegates.allObjects as? [VideoPlayerControllerDelegate] ?? []
    }
    
    var mode: Mode = .random
    
    init(withProviders providers: [Provider] = [ YouTubeProvider(), VimeoProvider(), AppleTVProvider() ]) {
        self.providers = providers
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFail(_:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
    }
    
    // MARK: - Public
    
    func addPlayer(_ player: AVPlayer) {
        players.append(player)
        player.volume = _volume
    }
    
    func addDelegate(_ delegate: VideoPlayerControllerDelegate) {
        delegates.add(delegate)
    }
    
    func setQueue(withURLs urls: [URL]) {
        players.forEach { $0.pause() }
        urlIndex = -1
        self.urls = urls
        playNext()
    }
    
    func setVolume(_ volume: Float) {
        _volume = volume
        players.forEach { $0.volume = volume }
    }
    
    // MARK: - AVPlayer Notifications
    
    @objc func videoDidEnd(_ notification: Notification) {
        playNext()
    }
    
    @objc func videoDidFail(_ notification: Notification) {
        playNext()
    }
    
    // MARK: - Private
    
    private func playNext() {
        guard urls.count > 0 else {
            return
        }
        
        var index = urlIndex
        let total = urls.count
        let random = Int(arc4random())
        
        switch mode {
        case .random:
            index = random % total
        case .sequence:
            index = (index + 1) % total
        }
        
        let url = urls[index]
        guard let provider = providers.filter({ $0.isValidURL(url) }).first else { // url is invalid, try another one
            urlIndex = -1
            urls.remove(at: index)
            playNext()
            return
        }
        
        urlIndex = index
        
        allDelegates.forEach {
            $0.videoPlayerController(self, willLoadVideo: url)
        }
        
        provider.getVideoURL(url) { [weak self] videoUrl in
            guard let strongSelf = self, let videoUrl = videoUrl else { return }
            
            strongSelf.allDelegates.forEach {
                $0.videoPlayerController(strongSelf, didLoadVideo: videoUrl)
            }
            
            strongSelf.players.forEach {
                let playerItem = AVPlayerItem(url: videoUrl)
                
                $0.replaceCurrentItem(with: playerItem)
                $0.actionAtItemEnd = .none
                
                $0.play()
            }
        }
    }
}
