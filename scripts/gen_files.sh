#!/bin/sh

[ -z "$FABRIC_API_KEY" ] && echo "FABRIC_API_KEY can't be empty" && exit 1
[ -z "$FABRIC_BUILD_SECRET" ] && echo "FABRIC_BUILD_SECRET can't be empty" && exit 1

BUILD_INFO="`date +%Y%m%d.%H%M`;`hostname`;`whoami`(`id -u`)"

echo "const char *BUILD_INFO = \"$BUILD_INFO\";"
echo "const char *FABRIC_API_KEY = \"$FABRIC_API_KEY\";"
echo "const char *FABRIC_BUILD_SECRET = \"$FABRIC_BUILD_SECRET\";"
