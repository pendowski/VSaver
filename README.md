# VSaver

VSaver is a mac OS screen saver which allows you to play videos from different sources as a screen saver.

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

Originally the project was written in Swift. Unfortunatelly it was causing constant problems - the screen saver itself woulk work normally but `Screen Saver Options` and preview in System Preferences would sometimes fail. 

Best bet is that when the System Preferences was loaded an other version of Swift runtime would be loaded into memory and OS wouldn't load the one included with saver bundle. As a result for systems up to High Sierra it would require to compile with Xcode 8.x and an older version of Swift. As a result I decided to rewrite the whole thing into Objective-C while it was still managable to do so.

The project was inspired by [Todd Thomas' tweet](https://twitter.com/toddthomas/status/756352957738725376).