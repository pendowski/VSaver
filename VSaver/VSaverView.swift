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


@objc (VSaverView)
class VSaverView: ScreenSaverView, VideoPlayerControllerDelegate {

    fileprivate var videoController: VideoPlayerController?
    fileprivate var loadingIndicator: NSProgressIndicator?
    fileprivate let settings = VSaverSettings()
    fileprivate var settingsController: NSWindowController?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        let settingsController = VSaverSettingsController(windowNibName: "VSaverSettingsController")
        settingsController.settings = settings
        self.settingsController = settingsController

        wantsLayer = true

        guard let layer = self.layer else {
            return
        }

        layer.backgroundColor = NSColor.black.cgColor
        layer.frame = self.bounds

        let player = AVPlayer()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.autoresizingMask = [ .layerWidthSizable, .layerHeightSizable ]
        playerLayer.frame = self.bounds
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        layer.addSublayer(playerLayer)
        
        let activityIndicator = NSProgressIndicator(frame: NSRect(x: 0, y: 0, width: 64, height: 64))
        activityIndicator.isDisplayedWhenStopped = false
        activityIndicator.style = .spinningStyle
        activityIndicator.controlSize = .regular
        activityIndicator.sizeToFit()
        
        if let brightFilter = CIFilter(name: "CIColorControls") {
            brightFilter.setDefaults()
            brightFilter.setValue(1, forKey: "inputBrightness")
            
            activityIndicator.contentFilters = [ brightFilter ]
        }
        activityIndicator.frame.origin.x = frame.size.width / 2 - activityIndicator.frame.size.width / 2
        activityIndicator.frame.origin.y = frame.size.height / 2 - activityIndicator.frame.size.height / 2
        activityIndicator.autoresizingMask = [ .viewMaxXMargin, .viewMaxYMargin, .viewMinXMargin, .viewMinYMargin ]
        
        addSubview(activityIndicator)
        loadingIndicator = activityIndicator
        
        let videoController: VideoPlayerController
        if settings.sameOnAllScreens {
            videoController = VideoPlayerController.shared
        } else {
            videoController = VideoPlayerController()
        }
        videoController.addPlayer(player)
        videoController.addDelegate(self)
        self.videoController = videoController
        
        reloadAndPlay()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.settingsDidClose(_:)), name: NSNotification.Name.NSWindowDidResignKey, object: nil)
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

    override func draw(_ rect: NSRect) {
        super.draw(rect)
    }

    override func animateOneFrame() {

    }

    override func hasConfigureSheet() -> Bool {
        return settingsController != nil
    }

    override func configureSheet() -> NSWindow? {
        return settingsController?.window
    }
    
    // MARK: - Notificatons
    
    @objc func settingsDidClose(_ notification: Notification) {
        guard let notificationWindow = notification.object as? NSWindow, notificationWindow == settingsController?.window else {
            return
        }
        
        self.reloadAndPlay()
    }
    
    // MARK: - Video Player delegate
    
    func videoPlayerController(_ controller: VideoPlayerController, willLoadVideo: URL) {
        DispatchQueue.main.async {
            self.loadingIndicator?.isHidden = false
            self.loadingIndicator?.startAnimation(nil)
        }
    }
    
    func videoPlayerController(_ controller: VideoPlayerController, didLoadVideo: URL?) {
        DispatchQueue.main.async {
            self.loadingIndicator?.stopAnimation(nil)
            self.loadingIndicator?.isHidden = true
        }
    }

    // MARK: - Private methods
    
    fileprivate func reloadAndPlay() {
        guard let urls = settings.getURLs() else { return }
        videoController?.setQueue(withURLs: urls)
        videoController?.setVolume(settings.muteVideos ? 0 : 0.5)
    }
}
