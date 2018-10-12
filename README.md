# VSaver

VSaver is a macOS screensaver which allows you to play videos from different sources as a screen saver.

Supported sources:

* [YouTube](https://youtube.com)
* [Vimeo](https://vimeo)
* [Wistia](https://wistia.com)
* AppleTV aerial videos
    * `appletv://` or `appletv://<NUMBER>` for "classic" videos
    * `appletv://tvos12` or `appletv://tvos12/<NUMBER>` for videos added in tvOS 12
    * With tvOS 12 you can also choose specific quality: `1080`, `1080sdr`, `4ksdr`, `1080hdr` or `4khdr` (e.g. `appletv://tvos12?q=4ksdr`). Just keep in mind that HDR versions won't likely play on 10.14 or lower.

![Screen Saver settings](https://user-images.githubusercontent.com/2470861/39940285-0d2f0f26-5559-11e8-818c-4600d1fbf444.png)

## Settings

### Play videos mode

`Loop` will play videos in the order specified on the URL source list, one by one. `Random` will use play a random URL from specified as a source.

### Mute videos

Since with many sources you might not be able to have videos without sound this option will allow you to mute them.

### Show source label

Each video provides a source information in the bottom-left corner, usually showing the provider (like YouTube) and sometimes additional information like quality, a title or an URL. Other than interesting information you can use a number displayed for AppleTV videos to hardcode specific ones (using `appletv://12` if the label says it's video #12).

### Same video on all screens

By selecting that option you choose to have the same video being played on all screens. Unchecking that option allows you to play a different one on each screen.

### Video quality

Here you can select which video quality should be used if multiple choices are available (currently only __Vimeo__ and tvOS 12 __AppleTV__ videos support this). You can prefer 4K video, 1080p or let the screensaver decide. This last option will choose the best quality for a screen that video is being played on (or best of all screens if `Same video on all screens` option is checked).

## Structure

The project has three targets: 

* **VSaver** the actual screen saver
* **VSaverTester** standalone application for testing the screensaver view
* **VSaverWallpaper** application which plays videos as a desktop wallpaper

All apps/savers share the same settings.

## Why Objective-C

Originally the project was written in Swift. Unfortunately, it was causing constant problems - the screen saver itself worked normally but `Screen Saver Options` and preview in System Preferences sometimes failed. 

Best bet is that the OS didn't load the Swift runtime included with saver bundle because it had another version already loaded into memory when loading the System Preferences. As a result for systems up to High Sierra, it would require to compile with Xcode 8.x and an older version of Swift. That's the reason I decided to rewrite the whole thing into Objective-C while it was still manageable to do so.

The project was inspired by [Todd Thomas' tweet](https://twitter.com/toddthomas/status/756352957738725376).