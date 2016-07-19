#!/bin/sh

set -xe

# This is meant to be run from top-level dir. of sensorama-ios

cd Sensorama/ && xcrun xcodebuild -list -workspace Sensorama.xcworkspace && cd ..
./scripts/travis_fold start bootstrapping
./build.sh bootstrap
./scripts/travis_fold end bootstrapping
cd Sensorama && xcrun xcodebuild -list -workspace ./Sensorama.xcworkspace
cd Sensorama && scan --workspace Sensorama.xcworkspace --scheme SensoramaTests
./build.sh
