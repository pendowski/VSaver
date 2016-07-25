# VSaver

VSaver is an OS X (macOS) screen saver which allows you to play YouTube videos as your screen savers.

It was inspired by [Todd Thomas' tweet](https://twitter.com/toddthomas/status/756352957738725376) and hacked together in few hours.

## Structure

The project have two targets: 

* VSaver for the actual screen saver
* VSaverTester for an application that acts as a standalone test application for the screen saver

VSaver scheme uses Automator application and shell script to automatically install screen saver from Xcode.

## Known issues

* Since the method uses unsupported method of retriving video files from YouTube player, some movies don't work
