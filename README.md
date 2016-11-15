# Sensorama for iOS

[![Build Status](https://travis-ci.org/wkoszek/sensorama-ios.svg?branch=master)](https://travis-ci.org/wkoszek/sensorama-ios)

This is an iOS version of the [http://www.sensorama.org](Sensorama project).

(![Sensorama](https://linkmaker.itunes.apple.com/assets/shared/badges/en-us/appstore-lrg.svg "Sensorama"))[https://itunes.apple.com/us/app/sensorama/id1159788831?mt=8]

# How to build

To build this application you must have a Apple Mac computer with XCode 7
and Command Line extensions installed. To build the application, run:

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

# Author

- Wojciech Adam Koszek, [wojciech@koszek.com](mailto:wojciech@koszek.com)
- [http://www.koszek.com](http://www.koszek.com)
