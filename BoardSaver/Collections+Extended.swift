//
//  Collections+Extended.swift
//  VSaver
//
//  Created by Jarek Pendowski on 02/03/2018.
//  Copyright © 2018 Jaroslaw Pendowski. All rights reserved.
//

import Foundation

extension Sequence {
    
    func forEachIndexed(_ body: (Self.Iterator.Element, Int) throws -> Swift.Void) rethrows {
        var index: Int = 0
        try forEach { (element) in
            try body(element, index)
            index += 1
        }
    }
    
    func dictionaryMap<Key, Value>(_ body: (Self.Iterator.Element) throws -> (Key, Value)) rethrows -> [Key: Value] {
        var dictionary: [Key: Value] = [:]
        try forEach { element in
            let (key, value) = try body(element)
            dictionary[key] = value
        }
        return dictionary
    }
    
}
