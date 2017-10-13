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
    @IBOutlet private var allScreensCheckbox: NSButton!
    @IBOutlet private var playMode: NSSegmentedControl!
    
    var settings: VSaverSettings?
    var urls: [String] = []
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        tableView.target = self
        tableView.doubleAction = #selector(doubleClick(_:))
    }
    
    // MARK: - Table View data source
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return urls.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return urls[row]
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if let url = object as? String {
            urls[row] = url
        }
    }
    
    // MARK: - Window delegate
    
    func windowDidBecomeKey(_ notification: Notification) {
        guard let settings = settings else { return }
        
        urls = settings.urls ?? []
            
        muteCheckbox.state = (settings.muteVideos ? NSOnState : NSOffState)
        allScreensCheckbox.state = (settings.sameOnAllScreens ? NSOnState : NSOffState)
        
        switch settings.playMode {
        case .random:
            playMode.selectedSegment = 1
        case .sequence:
            playMode.selectedSegment = 0
        }
        
        tableView.reloadData()
    }
    
    func windowDidResignKey(_ notification: Notification) {
        // force commiting changes if some row is in the middle of editing
        tableView.editColumn(-1, row: -1, with: nil, select: false)
        
        settings?.urls = urls
        settings?.muteVideos = (muteCheckbox.state == NSOnState)
        settings?.sameOnAllScreens = (allScreensCheckbox.state == NSOnState)
        
        switch playMode.selectedSegment {
        case 0:
            settings?.playMode = .sequence
        case 1:
            settings?.playMode = .random
        default:
            assertionFailure()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func closeWindow(_ sender: NSButton) {
        if let window = window,
            let parentWindow = NSApp.windows.filter({ $0.sheets.contains(window) }).first {
            parentWindow.endSheet(window)
        }
    }
    
    @IBAction func removeItem(_ sender: NSButton?) {
        if tableView.selectedRow >= 0 {
            tableView.beginUpdates()

            urls.remove(at: tableView.selectedRow)
            tableView.removeRows(at: IndexSet(integer: tableView.selectedRow), withAnimation: .effectFade)

            tableView.endUpdates()
        }
    }
    
    @IBAction func doubleClick(_ sender: NSTableView) {
        if sender.clickedRow == -1 {
            addItem(nil)
        } else {
            sender.editColumn(sender.clickedColumn, row: sender.clickedRow, with: nil, select: true)
        }
    }
    
    @IBAction func addItem(_ sender: NSButton?) {
        tableView.beginUpdates()
        
        urls.append("")
        let index = urls.count - 1
        tableView.insertRows(at: IndexSet(integer: index), withAnimation: .effectGap)
        
        tableView.endUpdates()
        
        tableView.editColumn(0, row: index, with: nil, select: true)
    }
}
