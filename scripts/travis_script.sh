#!/bin/sh

# set -xe

# This is meant to be run from top-level dir. of sensorama-ios

travis_fold() {
  local action=$1
  local name=$2
  echo -en "travis_fold:${action}:${name}\r"
}

cd Sensorama/ && xcrun xcodebuild -list -workspace Sensorama.xcworkspace && cd ..
travis_fold start foo
echo "This line is a LABEL"
./build.sh bootstrap
travis_fold end foo
cd Sensorama && xcrun xcodebuild -list -workspace ./Sensorama.xcworkspace
cd Sensorama && scan --workspace Sensorama.xcworkspace --scheme SensoramaTests
./build.sh
