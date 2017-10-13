//
//  Cocoa+Extended.swift
//  VSaver
//
//  Created by Jarek Pendowski on 13/10/2017.
//  Copyright © 2017 Jaroslaw Pendowski. All rights reserved.
//

import Foundation

extension NSSize {
    static func *(size: NSSize, float: CGFloat) -> NSSize {
        return NSSize(width: size.width * float, height: size.height * float)
    }
}
