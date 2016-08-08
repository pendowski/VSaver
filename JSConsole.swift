//
//  JSConsole.swift
//  VSaver
//
//  Created by Jarosław Pendowski on 08/08/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Foundation
import WebKit

@objc protocol JSConsoleExport: JSExport {
    func log(object: AnyObject)
    func error(object: AnyObject)
}

@objc (JSConsole)
final class JSConsole: NSObject, JSConsoleExport {
    func log(object: AnyObject) {
        print(object)
    }
    
    func error(object: AnyObject) {
        print("ERROR: \(object)")
    }
    
    class func installInContext(context: JSContext) {
        let console = JSConsole()
        context.setObject(unsafeBitCast(console, AnyObject.self), forKeyedSubscript: "console")
    }
}