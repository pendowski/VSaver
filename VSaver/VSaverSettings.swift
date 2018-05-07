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
        case muteVideo = "mute"
        case playSameOnAllScreens = "sameOnScreens"
        case playMode = "playMode"
        case showSource = "showSource"
        case displays = "displays"
        case displayMode = "displayMode"
        case selectedDisplays = "selectedDisplays"
    }
    
    enum DisplayMode: Int {
        case allScreens = 0
        case selectedScreens = 1
        case firstAvailable = 2
    }
    
    static let shared = VSaverSettings()
    
    private let userDefaults = ScreenSaverDefaults(forModuleWithName: "com.pendowski.VSaver")
    
    init() {
        if let displaysData = userDefaults?.data(forKey: Keys.displays.rawValue),
            let displaysObject = try? JSONSerialization.jsonObject(with: displaysData, options: []),
            let displayJSON = displaysObject as? [[String: Any]]
            {
            displays = displayJSON.flatMap({ Display(fromJSON: $0) })
        } else {
            displays = []
        }
    }
    
    deinit {
        let allDisplays = displays.flatMap { $0.toJSON() }
        if let displaysJSON = try? JSONSerialization.data(withJSONObject: allDisplays, options: []) {
            userDefaults?.set(displaysJSON, forKey: Keys.displays.rawValue)
        }
    }
    
    var muteVideos: Bool {
        get {
            return userDefaults?.bool(forKey: Keys.muteVideo.rawValue) ?? true
        }
        set {
            userDefaults?.set(newValue, forKey: Keys.muteVideo.rawValue)
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
            return userDefaults?.bool(forKey: Keys.playSameOnAllScreens.rawValue) ?? true
        }
        set {
            userDefaults?.set(newValue, forKey: Keys.playSameOnAllScreens.rawValue)
            userDefaults?.synchronize()
        }
    }
    
    var playMode: VideoPlayerController.Mode {
        get {
            let mode = userDefaults?.integer(forKey: Keys.playMode.rawValue) ?? -1
            return VideoPlayerController.Mode(rawValue: mode) ?? .sequence
        }
        set {
            userDefaults?.set(newValue.rawValue, forKey: Keys.playMode.rawValue)
            userDefaults?.synchronize()
        }
    }
    
    var showSourceLabel: Bool {
        get {
            return userDefaults?.bool(forKey: Keys.showSource.rawValue) ?? false
        }
        set {
            userDefaults?.set(newValue, forKey: Keys.showSource.rawValue)
            userDefaults?.synchronize()
        }
    }
    
    var displayMode: DisplayMode {
        get {
            return DisplayMode(rawValue: userDefaults?.integer(forKey: Keys.displayMode.rawValue) ?? 0) ?? .allScreens
        }
        set {
            userDefaults?.set(newValue.rawValue, forKey: Keys.displayMode.rawValue)
            userDefaults?.synchronize()
        }
    }
    
    var selectedDisplayIDs: [String] {
        get {
            return userDefaults?.stringArray(forKey: Keys.selectedDisplays.rawValue) ?? []
        }
        set {
            userDefaults?.set(newValue, forKey: Keys.selectedDisplays.rawValue)
            userDefaults?.synchronize()
        }
    }
    
    var displays: [Display]
    
    func getURLs() -> [URL]? {
        return urls?.flatMap({ URL(string: $0) })
    }
    
}
