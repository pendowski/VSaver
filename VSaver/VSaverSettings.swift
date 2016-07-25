//
//  VSaverSettings.swift
//  VSaver
//
//  Created by Jarosław Pendowski on 25/07/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Cocoa

class VSaverSettings: NSWindowController, NSWindowDelegate, NSTableViewDataSource {
    
    @IBOutlet private var tableView: NSTableView!
    
    var userDefaults: NSUserDefaults?
    var urls: [String] = []
    
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
        if let urls = self.userDefaults?.stringArrayForKey("urls") {
            self.urls = urls
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func closeWindow(sender: NSButton) {
        
        let filteredUrls = self.urls.flatMap({ NSURL(string: $0) }).map({ $0.absoluteString }) // remove broken urls
        self.userDefaults?.setObject(filteredUrls, forKey: "urls")
        
        self.close()
    }
    
    @IBAction func removeItem(sender: NSButton) {
        if self.tableView.selectedRow >= 0 {
            self.tableView.beginUpdates()

            self.urls.removeAtIndex(self.tableView.selectedRow)
            self.tableView.removeRowsAtIndexes(NSIndexSet(index: self.tableView.selectedRow), withAnimation: .EffectFade)

            self.tableView.endUpdates()
        }
    }
    
    @IBAction func addItem(sender: NSButton) {
        self.tableView.beginUpdates()
        
        self.urls.append("")
        self.tableView.insertRowsAtIndexes(NSIndexSet(index: self.urls.count), withAnimation: .SlideLeft)
        
        self.tableView.endUpdates()
    }
}
