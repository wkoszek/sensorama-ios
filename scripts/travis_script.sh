#!/bin/bash

set -xe

TMP=/tmp/.travis_fold_name

# This is meant to be run from top-level dir. of sensorama-ios

travis_fold() {
  local action=$1
  local name=$2
  echo -en "travis_fold:${action}:${name}\r"
}

travis_fold_start() {
  travis_fold start $1
  echo $1
  /bin/echo -n $1 > $TMP
}

travis_fold_end() {
  travis_fold end `cat ${TMP}`
}

#--------------------------------------------------------------------------------

#(
#  travis_fold_start BOOSTRAPPING
#  ./build.sh bootstrap
#  travis_fold_end
#)

(
  travis_fold_start WORKSPACE_LIST
  cd Sensorama/ && xcrun xcodebuild -list -workspace Sensorama.xcworkspace
  travis_fold_end
)

#(
#  travis_fold_start XCODEBUILD_TEST
#  cd Sensorama/ && xcodebuild -workspace Sensorama.xcworkspace \
#        -scheme "SensoramaTests" \
#	-sdk iphonesimulator \
#	-destination 'platform=iOS Simulator,name=iPhone 6' \
#	test | xcpretty
#  travis_fold_end
#)

#(
#  travis_fold_start SCAN
#  cd Sensorama && scan --workspace Sensorama.xcworkspace --scheme SensoramaTests
#  travis_fold_end
#)

(
  travis_fold_start BUILDING
  ./build.sh fastlane
  travis_fold_end
)
