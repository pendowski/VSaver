# VSaver 1.1

VSaver is an OS X (macOS) screen saver which allows you to play YouTube and Vimeo videos.

It was inspired by [Todd Thomas' tweet](https://twitter.com/toddthomas/status/756352957738725376) and I hacked it together in few hours.

![Screen Saver settings](https://cloud.githubusercontent.com/assets/2470861/17103626/8fa827c8-527f-11e6-9fc9-09c45e144c83.png)

## Structure

The project have three targets: 

* **VSaver** the actual screen saver
* **VSaverTester** standalone application for testing the screensaver view
* **VSaverWallpaper** application which plays videos as a desktop wallpaper

*VSaver* scheme uses Automator application and shell script to automatically install screen saver from Xcode.

## VSaverWallpaper

The original tweet talked about wallpaper, so after making screen saver (which I see much more often than my actual wallpaper) I managed to make *VSaverWallpaper* which displays videos at the level of wallpaper.

![wallpaper video](https://cloud.githubusercontent.com/assets/2470861/17130381/84304abc-5318-11e6-873d-583e25c9c139.gif)

## Known issues

* Since the method uses unsupported method of retriving video files from YouTube player, some movies don't work
