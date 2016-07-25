//
//  VSaverView.swift
//  VSaver
//
//  Created by Jaroslaw Pendowski on 4/1/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Cocoa
import ScreenSaver
import AVFoundation
import AVKit


@objc (VSaverView) class VSaverView: ScreenSaverView, VideoPlayerDelegate {

    private var videoPlayer: VideoPlayer?
    private var loadingIndicator: NSProgressIndicator?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)

        self.wantsLayer = true

        guard let layer = self.layer else {
            return
        }

        layer.backgroundColor = NSColor.blackColor().CGColor
        layer.frame = self.bounds

        let player = AVPlayer()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.autoresizingMask = [ .LayerWidthSizable, .LayerHeightSizable ]
        playerLayer.frame = self.bounds
        
        layer.addSublayer(playerLayer)
        
        let activityIndicator = NSProgressIndicator(frame: NSRect(x: 0, y: 0, width: 64, height: 64))
        activityIndicator.displayedWhenStopped = false
        activityIndicator.style = .SpinningStyle
        activityIndicator.controlSize = .RegularControlSize
        activityIndicator.sizeToFit()
        
        if let brightFilter = CIFilter(name: "CIColorControls") {
            brightFilter.setDefaults()
            brightFilter.setValue(1, forKey: "inputBrightness")
            
            activityIndicator.contentFilters = [ brightFilter ]
        }
        activityIndicator.frame.origin.x = frame.size.width / 2 - activityIndicator.frame.size.width / 2
        activityIndicator.frame.origin.y = frame.size.height / 2 - activityIndicator.frame.size.height / 2
        activityIndicator.autoresizingMask = [ .ViewMaxXMargin, .ViewMaxYMargin, .ViewMinXMargin, .ViewMinYMargin ]
        
        self.addSubview(activityIndicator)
        self.loadingIndicator = activityIndicator
        
        let videoPlayer = VideoPlayer(player: player)
        videoPlayer.delegate = self
        
        let urls = ["https://www.youtube.com/watch?v=5NgZr8-lh8s", "https://www.youtube.com/watch?v=0-7F_fqTT-s"].flatMap { NSURL(string: $0) }
        
        videoPlayer.setQueue(urls)
        self.videoPlayer = videoPlayer
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func startAnimation() {
        super.startAnimation()
    }

    override func stopAnimation() {
        super.stopAnimation()
    }

    override func drawRect(rect: NSRect) {
        super.drawRect(rect)
    }

    override func animateOneFrame() {

    }

    override func hasConfigureSheet() -> Bool {
        return false
    }

    override func configureSheet() -> NSWindow? {
        return nil
    }
    
    // Video Player delegate
    
    func videoPlayer(player: VideoPlayer, willLoadVideo: NSURL) {
        self.loadingIndicator?.startAnimation(nil)
    }
    
    func videoPlayer(player: VideoPlayer, didLoadVideo: NSURL?) {
        self.loadingIndicator?.stopAnimation(nil)
    }

}
