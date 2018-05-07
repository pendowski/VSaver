//
//  ScreenSelectionViewController.swift
//  VSaver
//
//  Created by Jarek Pendowski on 16/10/2017.
//  Copyright © 2017 Jaroslaw Pendowski. All rights reserved.
//

import Cocoa

class ScreenSelectionViewController: NSViewController {
    
    @IBOutlet private var screenPreview: NSView!
    @IBOutlet private var modeSelector: NSSegmentedControl!

    private var displays: [Display] = []
    private var disabledScreens: Set<Display> {
        return Set(displays.filter { !$0.shouldDisplay })
    }
    
    var settings: VSaverSettings!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        modeSelector.selectedSegment = settings.displayMode.rawValue
        
        updateScreenViews()
    }
    
    // MARK: - Actions
    
    @IBAction func modeChanged(_ sender: NSSegmentedControl) {
        guard let displayMode = VSaverSettings.DisplayMode(rawValue: sender.selectedSegment) else {
            return assertionFailure()
        }
        settings.displayMode = displayMode
    }
    
    // MARK: - Private
    
    private func updateScreenViews() {
        screenPreview.subviews.forEach { $0.removeFromSuperview() }
        
        guard let screens = NSScreen.screens() else {
            return
        }
        
        let savedDisplays: [String: Display] = settings.displays.dictionaryMap { ($0.displayID, $0) }
        var displays: [Display] = []

        var totalFrame = NSRect()
        screens.forEach {
            guard let id = ObjCHelper.displayID(from: $0),
                let name = ObjCHelper.displayName(from: $0) else {
                    return
            }
            
            totalFrame = totalFrame.union($0.frame)
            
            let savedDisplay = savedDisplays[id]
            let display = Display(displayID: id,
                                  name: name,
                                  shouldDisplay: savedDisplay?.shouldDisplay ?? true,
                                  order: 0,
                                  frame: $0.frame)
            displays.append(display)
        }
        
        let scale = min(screenPreview.bounds.width / totalFrame.width, screenPreview.bounds.height / totalFrame.height)
        let offset = totalFrame.origin.multipled(scale * -1)
        
        displays.forEachIndexed { display, index in
            let frame = display.frame.multipied(scale).offsetBy(dx: offset.x, dy: offset.y)
            let view = ScreenView(frame: frame)
            view.isMainScreen = index == 0
            view.label.textColor = .white
            view.label.stringValue = display.name
            
            screenPreview.addSubview(view)
        }
        
        self.displays = displays
    }
    
}
