//
//  SaverWallpaperSettings.swift
//  VSaver
//
//  Created by Jarosław Pendowski on 25/07/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Cocoa

class SaverWallpaperSettings: NSViewController {
    
    var beginSheet: ((window: NSWindow) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    // MARK: - Action
    
    @IBAction func openSettings(sender: NSButton) {
        guard let window = self.view.window else {
            return
        }
        
        self.beginSheet?(window: window)
    }
    
    @IBAction func close(sender: NSButton) {
        NSApp.terminate(nil)
    }
}
