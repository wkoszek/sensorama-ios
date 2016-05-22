#!/bin/sh
# Copyright (c) 2016 Wojciech A. Koszek <wojciech@koszek.com>

# this scripts takes the shell script from the local OSX where
# I have variables for Fastlane/Crashlytics/Slack and updates
# the Travis CI variables.

if [ $# -ne 1 ]; then
	echo "usage"
	echo "  travis_update.sh file"
	exit
fi

grep export $1 | sed 's/=/ /' | awk '{ printf("travis env set %s %s\n", $2, $3); }'
