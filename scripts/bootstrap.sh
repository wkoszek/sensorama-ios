#!/bin/sh
gem update
gem cleanup
gem install bundler
gem install cocoapods --pre
gem install fastlane --pre
pod repo update
