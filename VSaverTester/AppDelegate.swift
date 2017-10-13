//
//  AppDelegate.swift
//  VSaverTester
//
//  Created by Jaroslaw Pendowski on 4/1/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Cocoa
import ScreenSaver

class ScreenSaverWindow: NSWindow {
    var screenSaverView: ScreenSaverView?
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    var windows: [ScreenSaverWindow] = []
    var settingsController: VSaverSettings?
    var userDefaults = ScreenSaverDefaults(forModuleWithName: "com.pendowski.VSaver")
    
    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        createNewWindow()
        return true
    }

    @IBAction func openPreferences(_ sender: NSMenuItem) {
        guard let window = NSApp.keyWindow as? ScreenSaverWindow else { return }
        
        if let settingsWindow = window.screenSaverView?.configureSheet() {
            window.beginSheet(settingsWindow, completionHandler: nil)
        }
    }
    
    @IBAction func newFile(_ sender: NSMenuItem) {
        createNewWindow()
    }
    
    private func createNewWindow() {
        let window = ScreenSaverWindow(contentRect: NSMakeRect(100, 100, 600, 600),
                           styleMask: [.resizable, .titled, .closable],
                           backing: NSBackingStoreType.buffered, defer: true)
        
        window.hidesOnDeactivate = false
        window.isReleasedWhenClosed = false
        window.delegate = self
        if let screen = window.screen {
            var frame = window.frame
            frame.size = screen.frame.size * 0.6
            window.setFrame(frame, display: true, animate: false)
        }
        
        if let contentView = window.contentView,
            let screenSaverView = VSaverView(frame: NSZeroRect, isPreview: false) {
            screenSaverView.frame = contentView.bounds
            screenSaverView.autoresizingMask = [ .viewHeightSizable, .viewWidthSizable ]
            contentView.addSubview(screenSaverView)
            
            window.screenSaverView = screenSaverView
        }
        
        window.center()
        window.makeKeyAndOrderFront(window)
        
        windows.append(window)
    }
    
    // MARK: - NSWindowDelegate
    
    func windowShouldClose(_ sender: Any) -> Bool {
        if let window = sender as? ScreenSaverWindow, let index = windows.index(where: { $0 == window }) {
            windows.remove(at: index)
        }
        return true
    }
}
