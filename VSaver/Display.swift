//
//  Display.swift
//  VSaver
//
//  Created by Jarek Pendowski on 16/10/2017.
//  Copyright © 2017 Jaroslaw Pendowski. All rights reserved.
//

import Foundation

class Display: Equatable, Hashable {
    let displayID: String
    let name: String
    let frame: NSRect
    var shouldDisplay: Bool
    var order: Int
    
    var hashValue: Int {
        return displayID.hashValue
    }
    
    init(displayID: String, name: String, shouldDisplay: Bool, order: Int, frame: NSRect) {
        self.displayID = displayID
        self.name = name
        self.shouldDisplay = shouldDisplay
        self.frame = frame
        self.order = order
    }
    
    init?(fromJSON json: [String: Any]) {
        guard let displayID = json["id"] as? String,
            let name = json["name"] as? String,
            let shouldDisplay = json["display"] as? Bool,
            let frameString = json["frame"] as? String,
            let order = json["order"] as? Int
            else {
                return nil
        }
        self.displayID = displayID
        self.name = name
        self.shouldDisplay = shouldDisplay
        self.frame = NSRectFromString(frameString)
        self.order = order
    }
    
    func toJSON() -> [String: Any] {
        return [
            "id": displayID,
            "name": name,
            "shouldDisplay": shouldDisplay,
            "order": order,
            "frame": NSStringFromRect(frame)
        ]
    }
    
    static func ==(l: Display, r: Display) -> Bool {
        return l.displayID == r.displayID
    }
}
