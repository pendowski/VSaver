//
//  NSRect+Extended.swift
//  VSaver
//
//  Created by Jarek Pendowski on 02/03/2018.
//  Copyright © 2018 Jaroslaw Pendowski. All rights reserved.
//

import Foundation

extension NSRect {
    
    func multipied(_ scale: CGFloat) -> NSRect {
        return NSRect(x: origin.x * scale, y: origin.y * scale, width: width * scale, height: height * scale)
    }
    
}

extension NSPoint {
    
    func multipled(_ scale: CGFloat) -> NSPoint {
        return NSPoint(x: x * scale, y: y * scale)
    }
    
}
