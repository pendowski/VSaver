//
//  AppDelegate.swift
//  VSaverWallpaper
//
//  Created by Jarosław Pendowski on 25/07/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Cocoa
import AppKit
import CoreGraphics.CGWindowLevel

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusBarItem : NSStatusItem!
    private var popover: NSPopover!

    private var windows: [SaverWindow] = []

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        let popover = NSPopover()
        let settingsController = SaverWallpaperSettings(nibName: "SaverWallpaperSettings", bundle: nil)
        settingsController?.showSettingsHandler = self.showSettings
        settingsController?.reloadHandler = self.recreateWindows
        popover.contentViewController = settingsController
        self.popover = popover
        
        self.recreateWindows()
        
        self.setupStatusBar()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    // MARK: - Actions
    
    @objc func toggleWindow(sender: NSStatusItem) {
        
        if self.popover.shown {
            self.popover.performClose(nil)
        } else {
            if let statusButton = self.statusBarItem.button {
                self.popover.showRelativeToRect(statusButton.bounds, ofView: statusButton, preferredEdge: .MinY)
            }
        }
    }
    
    private func showSettings(window: NSWindow) {
        guard let settingsWindow = self.windows.first?.screenSaver?.configureSheet() else {
            return
        }
        
        window.beginSheet(settingsWindow, completionHandler: { [unowned self] _ in
            
            self.recreateWindows()
            
        })
    }

    // MARK: - Private
    
    private func setupStatusBar() {
        let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
        let icon = NSImage(named: "icon_16x16")
        icon?.template = true
        statusItem.button?.image = icon
        statusItem.highlightMode = true
        statusItem.target = self
        statusItem.action = #selector(self.toggleWindow(_:))
        
        self.statusBarItem = statusItem
    }
    
    private func recreateWindows() {
        self.windows.forEach({
            $0.close()
        })
        
        guard let screens = NSScreen.screens() else {
            preconditionFailure("No screens?")
        }
        
        self.windows = screens.flatMap(self.windowWithSaver)
    }
    
    private func windowWithSaver(onScreen screen: NSScreen) -> SaverWindow {
        let window = SaverWindow(contentRect: screen.frame,
                              styleMask: NSBorderlessWindowMask,
                              backing: NSBackingStoreType.Buffered,
                              defer: false,
                              screen: screen)
        
        window.level = Int(CGWindowLevelForKey(CGWindowLevelKey.DesktopWindowLevelKey))
        window.backgroundColor = NSColor.blackColor()
        window.releasedWhenClosed = false
        window.ignoresMouseEvents = true
        
        guard let screenSaver = VSaverView(frame: window.frame) else {
            preconditionFailure()
        }
        
        window.screenSaver = screenSaver
        window.orderFront(nil)
        
        return window
    }
}

