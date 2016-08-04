#!/bin/sh
# Copyright 2015 by Wojciech A. Koszek <wojciech@koszek.com>

ARG1=$1

PROJ=Sensorama
TOOL=xcodebuild
if [ "x$BUILDTOOL" != "x" ]; then
	TOOL="$BUILDTOOL"
fi

OPTS=""
if [ "x${TRAVIS}" != "x" ]; then
	OPTS='CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY='
fi

function build_normal() {
	(
		cd ${PROJ}

		pod install

		$TOOL $OPTS archive \
			-workspace ${PROJ}.xcworkspace \
			-scheme ${PROJ}
	)
}

function build_fastlane() {
	export PATH=`pwd`/scripts/git-hack:$PATH
	(cd Sensorama && fastlane beta)
}

function ci_env_init() {
	openssl aes-256-cbc -K $encrypted_c972abe91c70_key -iv $encrypted_c972abe91c70_iv -in scripts/travis.enc -out scripts/travis -d
	eval "$(ssh-agent -s)"
	chmod 600 scripts/travis
	ssh-add scripts/travis
	pod repo update
}

function tools_bootstrap () {
	scripts/bootstrap.sh
	exit 0
}

if [ ! -z "$TRAVIS" ]; then
	echo "# will init CI environment"
	ci_env_init
	echo "# CI environment initialized"
fi

if   [ "$ARG1" = "bootstrap" ]; then
	tools_bootstrap
elif [ "$ARG1" = "fastlane" ]; then
	build_fastlane
elif [ "$ARG1" = "normal" ]; then
	build_normal
else
	echo "build.sh [bootstrap|fastlane|normal]"
fi
