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

    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)

        self.layer = CALayer()

        guard let layer = self.layer else {
            return
        }

        self.wantsLayer = true
        layer.backgroundColor = NSColor.blackColor().CGColor
        layer.frame = self.bounds

        let player = AVPlayer(URL: NSURL(string: "https://r5---sn-oxup5-2v1l.googlevideo.com/videoplayback?upn=vUpL00y0q6k&signature=B758BC0515E023C82247FF70F5B2F971F17261D1.22B265F4ED7F30C78E737ACFF68B4970C875CECE&sparams=cnr%2Cdur%2Cid%2Cinitcwndbps%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cpl%2Cratebypass%2Csource%2Cupn%2Cexpire&ipbits=0&source=youtube&initcwndbps=988750&id=o-ADuNeWjZbvBGlvo9OW6HER6esVzH3hwvZl8JP1NI244a&sver=3&key=yt6&ip=78.11.16.58&lmt=1468484063956729&dur=2097.667&expire=1469224185&mt=1469202109&mv=m&ms=au&ratebypass=yes&mm=31&mn=sn-oxup5-2v1l&cnr=14&fexp=9410705%2C9416891%2C9419451%2C9422596%2C9425619%2C9428398%2C9431012%2C9433096%2C9433223%2C9433946%2C9434203%2C9435526%2C9435876%2C9436222%2C9437066%2C9437553%2C9438035%2C9438327%2C9438662%2C9439652%2C9439683%2C9440165%2C9440644%2C9440880%2C9440928%2C9441772%2C9442254%2C9442424&mime=video%2Fmp4&pl=20&itag=22")!)

        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.autoresizingMask = [ .LayerWidthSizable, .LayerHeightSizable ]
        playerLayer?.frame = self.bounds
        
        layer.addSublayer(playerLayer!)
        
        player.volume = 0
        player.play()
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
