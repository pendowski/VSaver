# VSaver 1.1

VSaver is an OS X (macOS) screen saver which allows you to play videos from internet.

Currently supported sources are:

* YouTube
* Vimeo
* Apple TV screensavers

![Screen Saver settings](https://cloud.githubusercontent.com/assets/2470861/17103626/8fa827c8-527f-11e6-9fc9-09c45e144c83.png)

## How to use

1. Install VSaver as your screensaver by double-clicking it and accepting instalation/replacement in the popup from System Preferences.
2. Find VSaver in the list of active screensavers.
3. Choose Screen Saver Options... to provide urls:
	* For YouTube use something like: [https://www.youtube.com/watch?v=dQw4w9WgXcQ](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
	* For Vimeo use something like: [https://vimeo.com/45196609](https://vimeo.com/45196609)
	* For Apple TV use just `appletv://` for random screensaver or `appletv://1` where the number is the number of video (currently 1-55). Use Show source label option to see the number of video currently playing.


## Structure

The project have three targets: 

* **VSaver** the actual screen saver
* **VSaverTester** standalone application for testing the screensaver view
* **VSaverWallpaper** application which plays videos as a desktop wallpaper

*VSaver* scheme uses Automator application and shell script to automatically install screen saver from Xcode.

## VSaverWallpaper

The original tweet talked about wallpaper, so after making screen saver (which I see much more often than my actual wallpaper) I managed to make *VSaverWallpaper* which displays videos at the level of wallpaper.

![wallpaper video](https://cloud.githubusercontent.com/assets/2470861/17130381/84304abc-5318-11e6-873d-583e25c9c139.gif)

## Fun fact

The project was inspired by [Todd Thomas' tweet](https://twitter.com/toddthomas/status/756352957738725376) and I hacked it together in few hours.

## Known issues

* Some YouTube videos won't play due to restrictions that YouTube puts on some of the content available on their platform.
