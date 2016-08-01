#!/bin/sh
# Copyright 2016 Wojciech Adam Koszek <wojciech@koszek.com>

TOOLS+=" fastlane"
TOOLS+=" deliver"
TOOLS+=" supply"
TOOLS+=" snapshot"
TOOLS+=" screengrab"
TOOLS+=" frameit"
TOOLS+=" pem"
TOOLS+=" sigh"
TOOLS+=" produce"
TOOLS+=" cert"
TOOLS+=" spaceship"
TOOLS+=" pilot"
TOOLS+=" boarding"
TOOLS+=" gym"
TOOLS+=" match"
TOOLS+=" scan"

for T in ${TOOLS}; do
	gem $1 $T
done
