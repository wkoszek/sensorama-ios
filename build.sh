#!/bin/sh
# Copyright 2015 by Wojciech A. Koszek <wojciech@koszek.com>

PROJ=Sensorama
TOOL=xcodebuild
if [ "x$IOSTOOL" != "x" ]; then
	TOOL="$IOSTOOL"
fi

OPTS=""
if [ "x${TRAVIS}" != "x" ]; then
	OPTS='CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY='
fi

(
	cd ${PROJ}

	$TOOL $OPTS \
		-workspace ${PROJ}.xcworkspace \
		-scheme ${PROJ}
)
