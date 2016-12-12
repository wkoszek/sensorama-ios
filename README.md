# Sensorama for iOS

[![Build Status](https://travis-ci.org/wkoszek/sensorama-ios.svg?branch=master)](https://travis-ci.org/wkoszek/sensorama-ios)

This is an iOS version of the [http://www.sensorama.org](Sensorama project).

[![Sensorama](https://linkmaker.itunes.apple.com/assets/shared/badges/en-us/appstore-lrg.svg "Sensorama")](https://itunes.apple.com/us/app/sensorama/id1159788831?mt=8)

If you want to Donate, link: https://www.paypal.me/wkoszek

Sensorama is a data science platform. As of now (Nov, 2016) it captures the data from your phone sensors after you press "Record". Sensorama samples iPhone sensors at a given frequency and stores them on your phone, in the internal database. After you press Stop, the recorded sample is stored in a compressed JSON file and e-mailed to you. Sensorama developers (aka.: me) get the copy of this file too, for research/calibration/testing/development purposes.

# How to use

I suggest you start using it from the App version available on the App
Store. Then move to using it in the developer environment.

App has 3 screens:

1. Record
2. Files
3. Settings

![Sensorama images](http://www.sensorama.org/images/sensorama_3_screens.png)

You start in `Record`. You can tap recording ("circle") and the app will start
collecting data from all sensors on your phone. You can then tap Stop
("square"). Tap on "Files" tab. Recorded file will be on top of "Files" tab.
You can click it to see general file specs. You also have a way to remove
the file from there. In the "Settings" tab you have an ability to see what
is being recorded and modify things like sampling rate and cloud storage
options.

# How to build

To build this application you must have a Apple Mac computer with XCode 7
and Command Line extensions installed. You will have to have Ruby installed,
and have an access to `gem` and `bundle` commands. To build the application, run:

	./build.sh normal

to build using `xcodebuild` (most of the users will want that). To run a
suite of regression tests, run:

	./build.sh test_normal

Sensorama uses Fastlane tools for build and release process and this is what
we use to deploy Sensorama for production. If you're setup with the
`fastlane` you can do:

	./build.sh fastlane

and for tests, you can do:

	./build.sh test_fastlane

# Tools

Jetbrains offered me an Open Source License for the whole suite of their
products, and it's great. Their website: https://www.jetbrains.com/

# Author

- Wojciech Adam Koszek, [wojciech@koszek.com](mailto:wojciech@koszek.com)
- Website: [http://www.koszek.com](http://www.koszek.com)
- Twitter: https://twitter.com/wkoszek
- LinkedIn: https://www.linkedin.com/in/wkoszek
