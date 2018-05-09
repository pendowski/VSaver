# VSaver

VSaver is a mac OS screen saver which allows you to play videos from different sources as a screen saver.

It was inspired by [Todd Thomas' tweet](https://twitter.com/toddthomas/status/756352957738725376) and I hacked it together in few hours.

![Screen Saver settings](https://cloud.githubusercontent.com/assets/2470861/17103626/8fa827c8-527f-11e6-9fc9-09c45e144c83.png)

## Structure

The project have three targets: 

* **VSaver** the actual screen saver
* **VSaverTester** standalone application for testing the screensaver view
* **VSaverWallpaper** application which plays videos as a desktop wallpaper

All apps/savers share the same settings.

## VSaverWallpaper

The original tweet talked about wallpaper, so after making screen saver (which I see much more often than my actual wallpaper) I managed to make *VSaverWallpaper* which displays videos at the level of wallpaper.

![wallpaper video](https://cloud.githubusercontent.com/assets/2470861/17130381/84304abc-5318-11e6-873d-583e25c9c139.gif)

## Why Objective-C

Originally the project was written in Swift. Unfortunatelly it was causing constant problems - the screen saver itself woulk work normally but `Screen Saver Options` and preview in System Preferences would sometimes fail. 

Best bet is that when the System Preferences was loaded an other version of Swift runtime would be loaded into memory and OS wouldn't load the one included with saver bundle. As a result for systems up to High Sierra it would require to compile with Xcode 8.x and an older version of Swift. As a result I decided to rewrite the whole thing into Objective-C while it was still managable to do so.