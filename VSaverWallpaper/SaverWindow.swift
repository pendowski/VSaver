//
//  SaverWindow.swift
//  VSaver
//
//  Created by Jarosław Pendowski on 25/07/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Cocoa

final class SaverWindow: NSWindow {
    var screenSaver: VSaverView? {
        didSet {
            oldValue?.removeFromSuperview()
            
            guard let view = self.contentView, newValue = screenSaver else {
                return
            }
            
            newValue.frame = view.bounds
            view.addSubview(newValue)
        }
    }
}