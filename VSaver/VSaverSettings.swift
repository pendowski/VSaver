//
//  VSaverSettings.swift
//  VSaver
//
//  Created by Jarosław Pendowski on 25/07/16.
//  Copyright © 2016 Jaroslaw Pendowski. All rights reserved.
//

import Foundation
import ScreenSaver

final class VSaverSettings {
    private let URLsKey = "urls"
    private let MUTEKey = "mute"
    private let userDefaults = ScreenSaverDefaults(forModuleWithName: "com.pendowski.VSaver")
    
    var muteVideos: Bool {
        get {
            return (self.userDefaults?.boolForKey(MUTEKey)) ?? true
        }
        set {
            self.userDefaults?.setBool(newValue, forKey: MUTEKey)
            self.userDefaults?.synchronize()
        }
    }
    
    var urls: [String]? {
        get {
            return self.userDefaults?.stringArrayForKey(URLsKey)
        }
        set {
            self.userDefaults?.setObject(newValue, forKey: URLsKey)
            self.userDefaults?.synchronize()
        }
    }
    
    func getURLs() -> [NSURL]? {
        return self.urls?.flatMap({ NSURL(string: $0) })
    }
}