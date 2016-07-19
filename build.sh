#!/bin/sh
# Copyright 2015 by Wojciech A. Koszek <wojciech@koszek.com>

# Do `git pull` to make sure we're running the latest code and
# to make sure we have the SSH key added, so that we know that
# fastlane, when run, will quite likely succeed.
git pull
if [ $? -ne 0 ]; then
	echo "failed on 'git pull' quiting"
	exit 1
fi

if [ "$1" = "bootstrap" ]; then
	gem update
	gem install bundler
	gem install cocoapods --pre
	gem install fastlane --pre
	pod repo update
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

function build_new() {
	export PATH=`pwd`/scripts/git-hack:$PATH
	(cd Sensorama && fastlane beta)
}

function build_ci() {
	openssl aes-256-cbc -K $encrypted_c972abe91c70_key -iv $encrypted_c972abe91c70_iv -in scripts/travis.enc -out scripts/travis -d
	eval "$(ssh-agent -s)"
	chmod 600 scripts/travis
	ssh-add scripts/travis
	build_new
}

which fastlane 2>/dev/null >/dev/null
if [ $? -eq 0 ]; then
	if [ ! -z "$TRAVIS" ]; then
		build_ci
	else
		build_new
	fi
else
	build_old
fi
