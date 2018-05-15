# VSaver

VSaver is a macOS screen saver which allows you to play videos from different sources as a screen saver.

Supported sources:

* [YouTube](https://youtube.com)
* [Vimeo](https://vimeo)
* [Wistia](https://wistia.com)
* AppleTV aerial videos (use `appletv://` or `appletv://<NUMBER>` for a specific video)

![Screen Saver settings](https://user-images.githubusercontent.com/2470861/39940285-0d2f0f26-5559-11e8-818c-4600d1fbf444.png)

## Structure

The project have three targets: 

* **VSaver** the actual screen saver
* **VSaverTester** standalone application for testing the screensaver view
* **VSaverWallpaper** application which plays videos as a desktop wallpaper

All apps/savers share the same settings.

## Why Objective-C

Originally the project was written in Swift. Unfortunately it was causing constant problems - the screen saver itself worked normally but `Screen Saver Options` and preview in System Preferences sometimes failed. 

Best bet is that the OS didn't load the Swift runtime included with saver bundle because it had another version already loaded into memory when loading the System Preferences. As a result for systems up to High Sierra it would require to compile with Xcode 8.x and an older version of Swift. That's the reason I decided to rewrite the whole thing into Objective-C while it was still managable to do so.

The project was inspired by [Todd Thomas' tweet](https://twitter.com/toddthomas/status/756352957738725376).
