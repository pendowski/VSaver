//
//  Provider.swift
//  VSaver
//
//  Created by Jaroslaw Pendowski on 7/22/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Foundation

struct URLItem {
    let title: String
    let url: URL
}

protocol Provider {
    func isValidURL(_ url: URL) -> Bool
    func getVideoURL(_ url: URL, completion: @escaping (_ url: URLItem?) -> Void)
}
