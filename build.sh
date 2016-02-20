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

(
	cd ${PROJ}

	pod install

	$TOOL $OPTS archive \
		-workspace ${PROJ}.xcworkspace \
		-scheme ${PROJ}
)
