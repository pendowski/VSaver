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
    private enum Keys: String {
        case URLs = "urls"
        case MuteVideo = "mute"
        case PlaySameOnAllScreens = "sameOnScreens"
        case PlayMode = "playMode"
    }
    
    private let userDefaults = ScreenSaverDefaults(forModuleWithName: "com.pendowski.VSaver")
    
    var muteVideos: Bool {
        get {
            return userDefaults?.bool(forKey: Keys.MuteVideo.rawValue) ?? true
        }
        set {
            userDefaults?.set(newValue, forKey: Keys.MuteVideo.rawValue)
            userDefaults?.synchronize()
        }
    }
    
    var urls: [String]? {
        get {
            return userDefaults?.stringArray(forKey: Keys.URLs.rawValue)
        }
        set {
            userDefaults?.set(newValue, forKey: Keys.URLs.rawValue)
            userDefaults?.synchronize()
        }
    }
    
    var sameOnAllScreens: Bool {
        get {
            return userDefaults?.bool(forKey: Keys.PlaySameOnAllScreens.rawValue) ?? true
        }
        set {
            userDefaults?.set(newValue, forKey: Keys.PlaySameOnAllScreens.rawValue)
            userDefaults?.synchronize()
        }
    }
    
    var playMode: VideoPlayerController.Mode {
        get {
            let mode = userDefaults?.integer(forKey: Keys.PlayMode.rawValue) ?? -1
            return VideoPlayerController.Mode(rawValue: mode) ?? .sequence
        }
        set {
            userDefaults?.set(newValue.rawValue, forKey: Keys.PlayMode.rawValue)
            userDefaults?.synchronize()
        }
    }
    
    func getURLs() -> [URL]? {
        return urls?.flatMap({ URL(string: $0) })
    }
}
