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

if [ "$BUILD_JOBS" != "" ]; then
	OPTS="$OPTS -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=${BUILD_JOBS}"
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

function test_normal() {
	(
		cd ${PROJ}

		xcodebuild -workspace ${PROJ}.xcworkspace \
			-scheme "${PROJ}Tests" \
			-sdk iphonesimulator \
			-destination 'platform=iOS Simulator,name=iPhone 6' \
			test | xcpretty
	)
}

function test_fastlane() {
	(
		cd ${PROJ}

		scan --workspace ${PROJ}.xcworkspace --scheme ${PROJ}Tests
	)
}

function build_fastlane() {
	export PATH=`pwd`/scripts/git-hack:$PATH
	(cd Sensorama && fastlane beta)
}

function build_fastlane_release() {
	export PATH=`pwd`/scripts/git-hack:$PATH
	(cd Sensorama && FASTLANE_ITUNES_TRANSPORTER_USE_SHELL_SCRIPT=1 fastlane release)
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
elif [ "$ARG1" = "fastlane_release" ]; then
	build_fastlane_release
elif [ "$ARG1" = "normal" ]; then
	build_normal
elif [ "$ARG1" = "test_normal" ]; then
	test_normal
elif [ "$ARG1" = "test_fastlane" ]; then
	test_fastlane
else
	echo "build.sh [bootstrap|fastlane|normal|fastlane_release|test_normal|test_fastlane]"
fi
