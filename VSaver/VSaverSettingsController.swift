//
//  VSaverSettings.swift
//  VSaver
//
//  Created by Jarosław Pendowski on 25/07/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Cocoa

class VSaverSettingsController: NSWindowController, NSWindowDelegate, NSTableViewDataSource {
    
    @IBOutlet private var tableView: NSTableView!
    @IBOutlet private var muteCheckbox: NSButton!
    
    var settings: VSaverSettings?
    var urls: [String] = []
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.tableView.target = self
        self.tableView.doubleAction = #selector(self.doubleClick(_:))
    }
    
    // MARK: - Table View data source
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.urls.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return self.urls[row]
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        if let url = object as? String {
            self.urls[row] = url
        }
    }
    
    // MARK: - Window delegate
    
    func windowDidBecomeKey(notification: NSNotification) {
        if let urls = self.settings?.urls, mute = self.settings?.muteVideos {
            self.urls = urls
            
            self.muteCheckbox.state = (mute ? NSOnState : NSOffState)
            
            self.tableView.reloadData()
        }
    }
    
    func windowDidResignKey(notification: NSNotification) {
        // force commiting changes if some row is in the middle of editing
        self.tableView.editColumn(-1, row: -1, withEvent: nil, select: false)
        
        self.settings?.urls = self.urls
        self.settings?.muteVideos = (self.muteCheckbox.state == NSOnState)
    }
    
    // MARK: - Actions
    
    @IBAction func closeWindow(sender: NSButton) {
        
        if let window = self.window {
            NSApp.mainWindow?.endSheet(window)
        }
    }
    
    @IBAction func removeItem(sender: NSButton?) {
        if self.tableView.selectedRow >= 0 {
            self.tableView.beginUpdates()

            self.urls.removeAtIndex(self.tableView.selectedRow)
            self.tableView.removeRowsAtIndexes(NSIndexSet(index: self.tableView.selectedRow), withAnimation: .EffectFade)

            self.tableView.endUpdates()
        }
    }
    
    @IBAction func doubleClick(sender: NSTableView) {
        if sender.clickedRow == -1 {
            self.addItem(nil)
        } else {
            sender.editColumn(sender.clickedColumn, row: sender.clickedRow, withEvent: nil, select: true)
        }
    }
    
    @IBAction func addItem(sender: NSButton?) {
        self.tableView.beginUpdates()
        
        self.urls.append("")
        let index = self.urls.count - 1
        self.tableView.insertRowsAtIndexes(NSIndexSet(index: index), withAnimation: .EffectGap)
        
        self.tableView.endUpdates()
        
        self.tableView.editColumn(0, row: index, withEvent: nil, select: true)
    }
}
