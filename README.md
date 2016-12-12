# Sensorama for iOS

[![Build Status](https://travis-ci.org/wkoszek/sensorama-ios.svg?branch=master)](https://travis-ci.org/wkoszek/sensorama-ios)

This is an iOS version of the [http://www.sensorama.org](Sensorama project).

[![Sensorama](https://linkmaker.itunes.apple.com/assets/shared/badges/en-us/appstore-lrg.svg "Sensorama")](https://itunes.apple.com/us/app/sensorama/id1159788831?mt=8)

<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="encrypted" value="-----BEGIN
PKCS7-----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-----END
PKCS7-----
">
<input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
<img alt="" border="0" src="https://www.paypalobjects.com/en_US/i/scr/pixel.gif" width="1" height="1">
</form>



Sensorama is a data science platform. As of now (Nov, 2016) it captures the data from your phone sensors after you press "Record". Sensorama samples iPhone sensors at a given frequency and stores them on your phone, in the internal database. After you press Stop, the recorded sample is stored in a compressed JSON file and e-mailed to you. Sensorama developers (aka.: me) get the copy of this file too, for research/calibration/testing/development purposes.

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

# Tools

Jetbrain offered me an Open Source License for the whole suite of their
products, and it's great. Their website: https://www.jetbrains.com/

# Author

- Wojciech Adam Koszek, [wojciech@koszek.com](mailto:wojciech@koszek.com)
- [http://www.koszek.com](http://www.koszek.com)
