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

    private var videoController: VideoPlayerController?
    private var loadingIndicator: NSProgressIndicator?
    private var sourceLabel: NSTextField?
    private let settings = VSaverSettings()
    private var settingsController: NSWindowController?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        let settingsController = VSaverSettingsController(windowNibName: "VSaverSettingsController")
        settingsController.settings = settings
        self.settingsController = settingsController

        wantsLayer = true

        guard let layer = layer else {
            return
        }

        layer.backgroundColor = NSColor.black.cgColor
        layer.frame = bounds

        let player = AVPlayer()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.autoresizingMask = [ .layerWidthSizable, .layerHeightSizable ]
        playerLayer.frame = bounds
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
        
        let label = NSTextField(labelWithString: "VSaver")
        label.textColor = NSColor.white
        label.alphaValue = 0.3
        label.sizeToFit()
        let labelMargin: CGFloat = 20
        let labelHeight = label.bounds.height
        label.frame = CGRect(x: labelMargin, y: bounds.height - labelMargin - labelHeight, width: bounds.width - labelMargin * 2, height: labelHeight)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        let layoutViews = [ "label" : label ]
        var labelConstraints = [NSLayoutConstraint]()
        labelConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(labelMargin)-[label]-\(labelMargin)-|", options: [], metrics: nil, views: layoutViews)
        labelConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=\(labelMargin))-[label(\(labelHeight))]-\(labelMargin)-|", options: [], metrics: nil, views: layoutViews)
        NSLayoutConstraint.activate(labelConstraints)
        sourceLabel = label
        
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
    
    func videoPlayerController(_ controller: VideoPlayerController, willLoadVideo url: URL) {
        DispatchQueue.main.async {
            self.loadingIndicator?.isHidden = false
            self.loadingIndicator?.startAnimation(nil)
        }
    }
    
    func videoPlayerController(_ controller: VideoPlayerController, didLoadVideo item: URLItem?) {
        DispatchQueue.main.async {
            self.loadingIndicator?.stopAnimation(nil)
            self.loadingIndicator?.isHidden = true
            self.sourceLabel?.stringValue = item?.title ?? ""
        }
    }

    // MARK: - Private methods
    
    private func reloadAndPlay() {
        guard let urls = settings.getURLs() else { return }

        sourceLabel?.isHidden = !settings.showSourceLabel
        
        videoController?.setQueue(withURLs: urls)
        videoController?.setVolume(settings.muteVideos ? 0 : 0.5)
    }
}
