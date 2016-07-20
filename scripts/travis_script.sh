#!/bin/bash

# set -xe

# This is meant to be run from top-level dir. of sensorama-ios

travis_fold() {
  local action=$1
  local name=$2
  echo -en "travis_fold:${action}:${name}\r"
}

travis_block() {
  travis_fold start $1
  echo "$1"
  $2
  travis_fold end $1
}

cd Sensorama/ && xcrun xcodebuild -list -workspace Sensorama.xcworkspace && cd ..

travis_block "BOOTSTRAPPING" "./build.sh bootstrap"
travis_block "WORKSPACE LIST" "cd Sensorama && xcrun xcodebuild -list -workspace ./Sensorama.xcworkspace && cd .."
travis_block "SCAN" "cd Sensorama && scan --workspace Sensorama.xcworkspace --scheme SensoramaTests"
travis_block "BUILDING" "./build.sh"
