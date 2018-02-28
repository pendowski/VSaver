//
//  ScreenSelectionViewController.swift
//  VSaver
//
//  Created by Jarek Pendowski on 16/10/2017.
//  Copyright © 2017 Jaroslaw Pendowski. All rights reserved.
//

import Cocoa

class ScreenSelectionViewController: NSViewController, NSTableViewDataSource {
    
    @IBOutlet private var tableView: NSTableView!
    @IBOutlet private var singleScreenCheckbox: NSButton!
    
    private var displays: [Display] = []
    private var disabledScreens: Set<Display> {
        return Set(displays.filter { !$0.shouldDisplay })
    }
    private let draggableType = "private.table-row"
    
    var settings: VSaverSettings!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        singleScreenCheckbox.state = settings.showOnSingleScreen ? NSOnState : NSOffState
        
        tableView.register(forDraggedTypes: [draggableType])
        
        var allDisplays: [Display] = []
        allDisplays.append(contentsOf: settings.displays)
        
        let displayIDs: Set<String> = Set(allDisplays.map { $0.displayID })
        
        NSScreen.screens()?.forEach {
            guard let id = ObjCHelper.displayID(from: $0), let name = ObjCHelper.displayName(from: $0) else {
                return
            }
            
            // Only add displays that we don't have settings for
            // In case of a new display - add it on top and set displaying to true
            if !displayIDs.contains(id) {
                let display = Display(displayID: id, name: name, shouldDisplay: true)
                if allDisplays.count > 0 {
                    allDisplays.insert(display, at: 0)
                } else {
                    allDisplays.append(display)
                }
            }
        }
        
        displays = allDisplays
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @IBAction func singleScreenModeChanged(_ sender: NSButton) {
        settings.showOnSingleScreen = sender.state == NSOnState
    }
    
    // MARK: - Table View data source
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return displays.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableColumn?.identifier == "show" {
            return !disabledScreens.contains(displays[row])
        } else if tableColumn?.identifier == "name" {
            return displays[row].name
        }
        
        return nil
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if tableColumn?.identifier == "show" {
            if let show = object as? Bool {
                let display = displays[row]
                display.shouldDisplay = show
            }
        }
    }
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        item.setString(String(row), forType: draggableType)
        return item
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        
        guard let oldRowString = info.draggingPasteboard().string(forType: draggableType), let oldRow = Int(oldRowString) else {
            return false
        }
        
        tableView.beginUpdates()
        let display = displays.remove(at: oldRow)
        if row < displays.count {
            displays.insert(display, at: row)
        } else {
            displays.append(display)
        }
        tableView.moveRow(at: oldRow, to: row)
        tableView.endUpdates()
        
        return true
    }
}
