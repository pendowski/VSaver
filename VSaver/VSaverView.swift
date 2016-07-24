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


class VSaverView: ScreenSaverView {

    var videoPlayer: VideoPlayer?

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
        
        let videoPlayer = VideoPlayer(player: player)
        
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

}
