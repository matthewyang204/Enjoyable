Enjoyable is an application for Mac OS X which allows you to use
controller inputs like a mouse or keyboard.

If you've ever played a video game which only supports mouse and
keyboard input but you want to use a joystick or gamepad, then
Enjoyable will help you do that.

Enjoyable supports

 * Mapping gamepad and joystick buttons to keyboard and mouse actions
 * Fine control over mouse movement and scrolling using analog axis
   inputs
 * Automatic and dynamic switching between different input mappings
 * Downloading and sharing input presets for different applications
 * Modern OS X features like resume and automatic termination

Enjoyable is free software written by Joe Wreschnig with minor additions
by Sam Deane, and is based on the Enjoy codebase written by [Yifeng Huang](http://nongraphical.com)
and [Sam McCall](http://abstractable.net/enjoy/).

## How to Use

To start, just press a button on your joystick or gamepad, then press
the key you want to map it for. Then press the ▶ button and switch
back to your game. For more details, Enjoyable has a in-application
manual available in Help Viewer via `⌘?`.

## Requirements

* Mac OS X 11+
* One or more HID-compatible (e.g. USB or Bluetooth) input devices

## License

Copyright 2013 Joe Wreschnig  
          2012 Yifeng Huang  
          2009 Sam McCall, University of Otago

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

The joystick icon is from the Tango icon set and is public domain.

# Building
If you just want to get a binary of the architecture of your current computer, just run Product > Build in Xcode. However, if you want a universal binary for distribution on other websites, here's how:
1. Clone and `cd` into the repo
2. Run `xcodebuild -project Enjoyable.xcodeproj -scheme Enjoyable -configuration Release -arch arm64 -derivedDataPath ./build build` and copy the resulting app bundle to another location, such as the Downloads folder. You'll need it later.
3. Run `xcodebuild -project Enjoyable.xcodeproj -scheme Enjoyable -configuration Release -arch x86_64 -derivedDataPath ./build build` and copy the resulting app bundle to the same location as you copied the first bundle, but just with a number after it.
4. Copy the binary within the first bundle's MacOS folder into the second bundle's MacOS folder with `Enjoyable2` as its name and then delete the first bundle.
5. Append a `1` to the remaining bundle's original binary's filename. The first binary should be named `Enjoyable1` by now.
6. `cd` into the bundle's MacOS folder and then run `lipo -create -output Enjoyable Enjoyable1 Enjoyable2`
7. Delete `Enjoyable1` and `Enjoyable2` and then run `killall Finder` to restart Finder's metadata cache. The bundle should now show up as Universal.

# Blocked execution
If your Mac says something like "Unidentified developer" in a pop-up when you try to open the app, try running this in a terminal under an administrator account:
```
sudo spctl --master-disable
```

# Credits
- [erpapa's Enjoyable 1.3](https://github.com/erpapa/Enjoyable-1.3): I used a few of his fixes to get the main Enjoyable 1.3 to work properly because I could not figure out some problems in it.
