//
//  SaverWallpaperSettings.swift
//  VSaver
//
//  Created by Jarosław Pendowski on 25/07/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Cocoa

class SaverWallpaperSettings: NSViewController {
    
    var showSettingsHandler: ((window: NSWindow) -> Void)?
    
    var reloadHandler: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    // MARK: - Action
    
    @IBAction func reload(sender: NSButton) {
        self.reloadHandler?()
    }
    
    @IBAction func openSettings(sender: NSButton) {
        guard let window = self.view.window else {
            return
        }
        
        self.showSettingsHandler?(window: window)
    }
    
    @IBAction func close(sender: NSButton) {
        NSApp.terminate(nil)
    }
}
