//
//  ScreenView.swift
//  VSaver
//
//  Created by Jarek Pendowski on 02/03/2018.
//  Copyright © 2018 Jaroslaw Pendowski. All rights reserved.
//

import Cocoa

final class ScreenView<AdditionalView: NSView>: NSControl {
    
    var isMainScreen: Bool = false {
        didSet { setNeedsDisplay(bounds) }
    }
    
    let label: NSTextField
    
    var textColor: NSColor = .white {
        didSet { setNeedsDisplay(bounds) }
    }
    
    var additionalView: AdditionalView? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let additionalView = additionalView else { return }
            addSubview(additionalView)
            additionalView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12)
            additionalView.topAnchor.constraint(equalTo: topAnchor, constant: 12)
        }
    }
    
    override init(frame frameRect: NSRect) {
        label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame: frameRect)
        
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func layout() {
//        super.layout()
//        label.cent
//        label.frame = bounds
//    }

    override func draw(_ dirtyRect: NSRect) {
        
        // taken from System Preferences
        let screenColor = NSColor(calibratedRed: 0.366, green: 0.537, blue: 0.78, alpha: 1)
        screenColor.setFill()
        NSColor.black.setStroke()
        
        let screenPath = NSBezierPath(rect: bounds)
        screenPath.fill()
        screenPath.lineWidth = 1
        screenPath.stroke()
        
        if isMainScreen {
            let menuBarHeight: CGFloat = max(bounds.height / 10, 4)
            let menuBarPath = NSBezierPath(rect: NSMakeRect(0, bounds.height - menuBarHeight, bounds.width, menuBarHeight))
            NSColor.white.setFill()
            menuBarPath.fill()
            menuBarPath.lineWidth = 1
            menuBarPath.stroke()
        }
        
        super.draw(dirtyRect)

    }
    
}
