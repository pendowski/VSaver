//
//  Provider.swift
//  VSaver
//
//  Created by Jaroslaw Pendowski on 7/22/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Foundation

protocol Provider {
    func isValidURL(url: NSURL) -> Bool
    func getVideoURL(url: NSURL, completion: (url: NSURL?) -> Void)
}
