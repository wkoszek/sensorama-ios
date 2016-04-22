#!/bin/sh
# Copyright 2015 by Wojciech A. Koszek <wojciech@koszek.com>

if [ $1 = "bootstrap" ]; then
	rvm get stable --auto-dotfiles
	rvm install 2.2
	gem install cocoapods
	gem install fastlane
fi

PROJ=Sensorama
TOOL=xcodebuild
if [ "x$BUILDTOOL" != "x" ]; then
	TOOL="$BUILDTOOL"
fi

OPTS=""
if [ "x${TRAVIS}" != "x" ]; then
	OPTS='CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY='
fi

function build_old() {
	(
		cd ${PROJ}

		pod install

		$TOOL $OPTS archive \
			-workspace ${PROJ}.xcworkspace \
			-scheme ${PROJ}
	)
}

which fastlane 2>/dev/null >/dev/null
if [ $? -eq 0 ]; then
	(cd Sensorama && fastlane beta)
else
	build_old
fi
