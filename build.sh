#!/bin/sh
# Copyright 2015 by Wojciech A. Koszek <wojciech@koszek.com>

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

FASTLANE=`which fastlane`
if [ "x$FASTNAME" != "/usr/local/bin/fastlane" ]; then
	# New world...
	(cd Sensorama && fastlane beta)
else
	# Old way of building stuff.
	build_old
fi
