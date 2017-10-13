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

    func applicationDidFinishLaunching(_ aNotification: NSNotification) {
        
        let popover = NSPopover()
        let settingsController = SaverWallpaperSettings(nibName: "SaverWallpaperSettings", bundle: nil)
        settingsController?.showSettingsHandler = self.showSettings
        settingsController?.reloadHandler = self.recreateWindows
        popover.contentViewController = settingsController
        self.popover = popover
        
        self.recreateWindows()
        
        self.setupStatusBar()
    }

    // MARK: - Actions
    
    @objc func toggleWindow(_ sender: NSStatusItem) {
        
        if self.popover.isShown {
            self.popover.performClose(nil)
        } else {
            if let statusButton = self.statusBarItem.button {
                self.popover.show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .minY)
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
        let statusItem = NSStatusBar.system().statusItem(withLength: -1)
        let icon = NSImage(named: "icon_16x16")
        icon?.isTemplate = true
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
        let window = SaverWindow(contentRect: NSRect(origin: .zero, size: screen.visibleFrame.size),
                              styleMask: [.borderless],
                              backing: NSBackingStoreType.buffered,
                              defer: false,
                              screen: screen)
        
        window.level = Int(CGWindowLevelForKey(CGWindowLevelKey.desktopWindow))
        window.backgroundColor = NSColor.black
        window.isReleasedWhenClosed = false
        window.ignoresMouseEvents = true
        
        let screenSaver = VSaverView(frame: window.frame)
        window.screenSaver = screenSaver
        window.orderFront(nil)
        
        return window
    }
}

