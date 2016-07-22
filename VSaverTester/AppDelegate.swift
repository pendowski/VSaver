//
//  AppDelegate.swift
//  VSaverTester
//
//  Created by Jaroslaw Pendowski on 4/1/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    lazy var screenSaverView = VSaverView(frame: NSZeroRect, isPreview: false)

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let screenSaverView = screenSaverView,
            contentView = window.contentView {

            screenSaverView.frame = contentView.bounds
            screenSaverView.autoresizingMask = [ .ViewHeightSizable, .ViewWidthSizable ]
            contentView.addSubview(screenSaverView)
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }


}
